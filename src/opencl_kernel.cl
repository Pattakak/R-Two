#define PI 3.141592654359f
#include <generators/tinymt32.cl>


//// UTILITIES
typedef struct Mat3 {
    float3 col0;
    float3 col1;
    float3 col2;
} Mat3;

// current shitty noise
float noise(float3 *seed) {
    float floor;
    float result = fract(sin(dot(*seed, (float3)(1323232.9898f,7843432.233f, 23872.23232f)) * 4375348.5453123f), &floor);
    seed->x += 2.*result;
    seed->y += 23423.*result;
    seed->z += -5443.*result;
    return result;
}

uint float4ToInt32(float4 color) {
    color = clamp(color, 0.0f,1.0f);
    uint r = (uint)(color.x * 255.9999f);
    uint g = (uint)(color.y * 255.9999f);
    uint b = (uint)(color.z * 255.9999f);
    uint a = (uint)(color.w * 255.9999f);
    uint conversion = (r << 24) | (g << 16) | (b << 8) | a;
    return conversion;
}
    
float4 int32ToFloat4(uint color) {
    uint r = (color & 0xFF000000 ) >> 24;
    uint g = (color & 0x00FF0000 ) >> 16;
    uint b = (color & 0x0000FF00 ) >> 8;
    uint a = (color & 0x000000FF );
    return (float4)((float)r, (float)g, (float)b, (float)a) / 255.0f;
}

float3 reflect(float3 I, float3 N) {
    return I - 2.0f * dot(N, I) * N;
}

float3 refract(const float3 light_in, const float3 normal, float etai_over_etat) {
    float cos_theta = min(dot(-light_in, normal), 1.0f);
    float3 r_out_perp =  etai_over_etat * (light_in + cos_theta * normal);
    float temp = 1.0f - pow(length(r_out_perp), 2);
    float3 r_out_parallel = -sqrt(fabs(temp)) * normal;
    return r_out_perp + r_out_parallel;
}

// saturated dot product
float sdot(float3 a, float3 b) {
    return clamp(dot(a,b), 0.0f, 1.0f);
}

float3 mul(Mat3 mat, float3 vec) {
    return vec.x*mat.col0+vec.y*mat.col1+vec.z*mat.col2;
}



//// GEOMETRY (and the Material struct)
typedef struct Ray {
    float3 position;
    float3 direction;
    float3 weakness;   // running absorption 
    float3 radiance;   // running emmision
} Ray;

typedef struct Material {
    float3 albedo;      // used for diffuse objects. All objects must have this!
    float3 specular;    // used for etallic objects
    float3 emission;    // used for lights
    float  ir;          // index of refraction, for dielectrics
} Material;

typedef struct Sphere {
	float3 position;
	float  radius;
	Material material;
} Sphere;

typedef struct Plane {
    float3 point;
    float3 normal;
    Material material;
} Plane;

typedef struct Triangle {
    float3 a;
    float3 b;
    float3 c;
    float3 normal;
    Material material;
} Triangle;

typedef struct Disc {
    float3 center;
    float3 normal;
    float radius;
    Material material;
} Disc;

typedef struct HitInfo {
    float3 normal;
    float3 position;
    float  distance;
    Material material;
} HitInfo;

// https://gamedev.stackexchange.com/questions/23743/whats-the-most-efficient-way-to-find-barycentric-coordinates
// Transcribed from Real Time Collision Detection
float3 barycentric(const float3 *p, const Triangle *tri) {
    float3 v0 = tri->b - tri->a;
    float3 v1 = tri->c - tri->a;
    float3 v2 = *p - tri->a;
    float d00 = dot(v0, v0);
    float d01 = dot(v0, v1);
    float d11 = dot(v1, v1);
    float d20 = dot(v2, v0);
    float d21 = dot(v2, v1);
    float denom = d00 * d11 - d01 * d01;
    float v = (d11 * d20 - d01 * d21) / denom;
    float w = (d00 * d21 - d01 * d20) / denom;
    float u = 1.0f - v - w;
    return (float3)(u, v, w);
}

Mat3 getTangentSpace(float3 normal) {
    // gets an orthonormal frame with a given normal as the last basis vector
    // borrowed from http://three-eyed-games.com/2018/05/12/gpu-path-tracing-in-unity-part-2/
    // choose a helper vector for the cross product
    float3 helper = (float3)(1.0f, 0.0f, 0.0f);
    if (fabs(normal.x) > 0.99f) helper = (float3)(0.0f, 0.0f, 1.0f);
    // generate vectors
    float3 tangent = normalize(cross(normal, helper));
    float3 binormal = normalize(cross(normal, tangent));
    Mat3 mat; mat.col0 = tangent; mat.col1 = binormal; mat.col2 = normal;
    return mat;
}

float3 sampleHemisphere(float3 normal, unsigned long frameCount, float3 *seed) {
    // returns a vector uniformly sampled from the hemisphere around a given normal
    // borrowed from http://three-eyed-games.com/2018/05/12/gpu-path-tracing-in-unity-part-2/
    // uniformly sample hemisphere direction
    float cosTheta = noise(seed);
    float sinTheta = sqrt(max(0.0f, 1.0f - cosTheta * cosTheta));
    float phi = 2 * 3.141528 * noise(seed);
    float3 tangentSpaceDir = (float3)(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
    // transform direction to world space
    return mul(getTangentSpace(normal), tangentSpaceDir);
}

Ray createCamRay(float2 uv, float3 camPos, float3 camDir, float3 camRight, float3 camUp) {
	Ray ray;
    ray.position= camPos;
    float fovy = 60.0f / 180.0f * 3.141526f; 
    
    // Next line explanation:
    // y is from (-.5, .5), we give an outward vector with length 1, (x side is 1), and the 
    // angle must be half of the fov of y, since we are looking at one side.
    // Therefore we must satisfy tan(fovy / 2) = weight * .5
    float weight = tan(fovy / 2) * 2;
    ray.direction = normalize((float3) (camDir.x + (uv.x * camRight.x + uv.y * camUp.x) * weight, 
                                  camDir.y +  (uv.x * camRight.y + uv.y * camUp.y) * weight,
                                  camDir.z +  (uv.x * camRight.z + uv.y * camUp.z) * weight));
	ray.weakness = (float3)(1.0f, 1.0f, 1.0f);
    ray.radiance  = (float3)(0.0f,0.0f,0.0f);
	return ray;
}

float intersectSphere(const Ray *ray, Sphere sphere) {
    // line-sphere intersection: 0, 1, or 2 intersections
    float3 disp = ray->position - sphere.position;
    float p1 = -1.0f * dot(ray->direction, disp);
    float p2sqr = p1*p1 - dot(disp, disp) + sphere.radius*sphere.radius;
    if (p2sqr < 0.0f) {
        return MAXFLOAT; // no intersection
    }
    // find closer intersection
    float p2 = sqrt(p2sqr);
    float t = p1 - p2 > 0.0f ? p1 - p2 : p1 + p2;
    if (t > 0.0001f) {  // keep a minimum so that we can later set ray->position = hitPosition.
          return t;
    }
    else {
        return MAXFLOAT;
    }
}

float intersectPlane(const Ray *ray, const Plane *plane) {
    float d_dot_n = dot(ray->direction, plane->normal);
    if (fabs(d_dot_n) <= 0.0000001f) {
        return MAXFLOAT;    // the ray and the plane are parallel
    }
	float retval = (float)(dot((plane->point - ray->position), plane->normal) / d_dot_n);
	if (retval > 0) {
		return retval;
	} else {
		return MAXFLOAT;
	}
}

float intersectTriangle(const Ray *ray, Triangle *tri) {
    Plane p;
    p.point = (tri->a + tri->b + tri->c) / 3.0f;
    p.normal = normalize(cross(tri->b - tri->a, tri->c - tri->a));
    tri->normal = p.normal;
    float t = intersectPlane(ray, &p);
    if (t == MAXFLOAT) {
        return MAXFLOAT;    // missed the plane of the triangle
    }
    float3 hitPoint = ray->position + t * ray->direction;
    float3 bary = barycentric(&hitPoint, tri);
    if (0 < bary.x && bary.x < 1 && 0 < bary.y && bary.y < 1 && 0 < bary.z && bary.z < 1) {
        return t;
    }
    return MAXFLOAT;
}

float intersectDisc(const Ray *ray, const Disc* disc) {
    Plane p;
    p.point = disc->center;
    p.normal = disc->normal;
    float t = intersectPlane(ray, &p);
    if (t == MAXFLOAT) {
        return MAXFLOAT;
    }
    float3 hitPoint = ray->position + t * ray->direction;
    if (distance(hitPoint, disc->center) > disc->radius) {
        return MAXFLOAT;
    }
    return t;
}



//// MATERIALS
Material createMaterial(float3 albedo, float3 specular, float3 emission, float ir) {
    return (Material){albedo, specular, emission, ir};
}

void dielectricBRDF(Ray *ray, HitInfo *hit) {
    // lifted from Ray Tracing In One Weekend by Peter Shirley
    bool frontFace = dot(ray->direction, hit->normal) < 0;
    float refraction_ratio = frontFace ? (1.0f / hit->material.ir) : hit->material.ir;

    float cos_theta = min(dot(-ray->direction, hit->normal), 1.0f);
    float sin_theta = sqrt(1.0f - cos_theta * cos_theta);

    bool cannot_refract = refraction_ratio * sin_theta > 1.0f;
    float3 direction;

    if (cannot_refract)
        direction = reflect(ray->direction, hit->normal);
    else
        direction = refract(ray->direction, hit->normal, refraction_ratio);

    ray->radiance += ray->weakness * hit->material.emission;
    ray->weakness *= hit->material.albedo;
    ray->position = hit->position;
    ray->direction = direction;
}

void metallicBRDF(Ray *ray, HitInfo *hit) {
    ray->radiance += ray->weakness * hit->material.emission;
    ray->weakness *= hit->material.specular;
    ray->position = hit->position;
    ray->direction = normalize(reflect(ray->direction, hit->normal));
}

void diffuseBRDF(Ray *ray, HitInfo *hit, unsigned long frameCount, float3 *seed) {
    float3 lightOutDir = sampleHemisphere(hit->normal, frameCount, seed);
    ray->radiance += ray->weakness * hit->material.emission;
    ray->weakness *= 2.0f * hit->material.albedo * sdot(hit->normal, lightOutDir);
    ray->position = hit->position;
    ray->direction = lightOutDir;
}



//// SCENE
void updateRay(Ray *ray, HitInfo *hit, unsigned long frameCount, float3 *seed) {
    if (hit->material.ir > 0) {
        dielectricBRDF(ray, hit);
    }
    else if (hit->material.specular.x > 0) {
        metallicBRDF(ray, hit);
    } else {
        diffuseBRDF(ray, hit, frameCount, seed);
    }
}

HitInfo intersectScene(Ray *ray) {
    Plane planes[6];
    planes[0].point  = (float3)(-2, 0, 0); // left wall
    planes[0].normal = (float3)(1, 0, 0);
    planes[0].material = createMaterial((float3)(1.0, 0.2, 0.2), (float3)(0), (float3)(0), 0);

    planes[1].point  = (float3)(2, 0, 0);  // right wall
    planes[1].normal = (float3)(-1, 0, 0);
    planes[1].material = createMaterial((float3)(0.2f, 1.0f, 0.2f), (float3)(0), (float3)(0), 0);

    planes[2].point  = (float3)(0, 0, -5); // front wall
    planes[2].normal = (float3)(0, 0, 1);
    planes[2].material = createMaterial((float3)(0.81, 0.68, 0.40), (float3)(0), (float3)(0), 0);

    planes[3].point  = (float3)(0, -0.5, 0); // floor
    planes[3].normal = (float3)(0,  1, 0);
    planes[3].material = createMaterial((float3)(0.8, 0.8, 0.8), (float3)(0), (float3)(0), 0);
    
    planes[4].point  = (float3)(0, 2, 0); // ceiling
    planes[4].normal = (float3)(0, -1, 0);
    planes[4].material = createMaterial((float3)(0.2f, 0.2f, 1.0f), (float3)(0), (float3)(0), 0);

    planes[5].point  = (float3)(0, 0, 4);   // back wall
    planes[5].normal = (float3)(0, 0, -1);
    planes[5].material = createMaterial((float3)(0.81, 0.68, 0.40), (float3)(0), (float3)(0), 0);

    Sphere spheres[3];
	spheres[0].position = (float3)(0.5f, 0.0f, -2.5f);	// inner sphere 1
	spheres[0].radius = 0.5f;
	spheres[0].material = createMaterial((float3)(1.0f, 1.0f, 1.0f), (float3)(1, 0.2f, 0.2f), (float3)(0), 0);

	spheres[1].position = (float3)(-0.5f, 0.0f, -3.0f);	// inner sphere 2
	spheres[1].radius = 0.5f;
	spheres[1].material = createMaterial((float3)(0.5f, 0.5f, 1.0f), (float3)(0), (float3)(0), 0);

    spheres[2].position = (float3)(0.0f, 0.2f, -1.5f);	// inner sphere 3
	spheres[2].radius = 0.2f;
	spheres[2].material = createMaterial((float3)(1, 1, 1), (float3)(0), (float3)(0), 1.5);
    
    Triangle tri;
    tri.a = (float3)(-0.5f, 0, -2.0f);
    tri.b = (float3)(0, -0.5f, -1.75f);
    tri.c = (float3)(0, -0.25f, -2.25f);
    tri.material = createMaterial((float3)(0.2f, 1.0f, 0.2f), (float3)(0), (float3)(0), 0);

    Disc disc;
    disc.center = (float3)(0, 1.99, -3);
    disc.normal = (float3)(0, -1, 0);
    disc.material = createMaterial((float3)(0.0f, 0.0f, 0.0f), (float3)(0), (float3)(6), 0);
    disc.radius = 0.5;

	float t = MAXFLOAT;
    HitInfo bestHit;
    bestHit.normal = (float3)(0.0f,0.0f,0.0f);
	bestHit.distance = MAXFLOAT;

    for (int i = 0; i < 6; i++) {
        if ((t = intersectPlane(ray, &planes[i])) < bestHit.distance) {
            bestHit.distance = t;
            bestHit.position = ray->position + t*ray->direction;
            bestHit.normal = planes[i].normal;
			bestHit.material = planes[i].material;
        }
    }

    for (int i = 0; i < 3; i++) {
        if ((t = intersectSphere(ray, spheres[i])) < bestHit.distance) {
            bestHit.distance = t;
            bestHit.position = ray->position + t*ray->direction;
            bestHit.normal = normalize(bestHit.position - spheres[i].position);
			bestHit.material = spheres[i].material;
	    }
    }

    if ((t = intersectTriangle(ray, &tri)) < bestHit.distance) {
        bestHit.distance = t;
        bestHit.position = ray->position + t * ray->direction;
        bestHit.normal = tri.normal;
        bestHit.material = tri.material;
    }
    if ((t = intersectDisc(ray, &disc)) < bestHit.distance) {
        bestHit.distance = t;
        bestHit.position = ray->position + t * ray->direction;
        bestHit.normal = disc.normal;
        bestHit.material = disc.material;
    }

    return bestHit;
}

float4 traceRay(Ray *ray, unsigned long frameCount, float3 *seed) {
	const int RECURSION_DEPTH = 4;
    for (int i = 0; i < RECURSION_DEPTH; i++) {
        HitInfo info = intersectScene(ray);
        if (i == RECURSION_DEPTH-1) info.material.emission = float3(0.5); // current way to fudge remaining recursion results
		updateRay(ray, &info, frameCount, seed);
    }
	return (float4)(ray->radiance, 1.0f);
}

__kernel void render_kernel(__global float4 *frame, __global uint *pixels, int width, int height, unsigned long frameCount, float3 camDir, float3 camRight, float3 camUp, float3 camPos, float2 rands) {
    const int work_item_id = get_global_id(0);
    int x_coord = work_item_id % width;
    int y_coord = work_item_id / width;
    float2 uv = (float2)((float)(x_coord + rands.x) - 0.5f*(float)width, 0.5f*(float)height - (float)(y_coord + rands.y)) / (float)height;

	// trace
	Ray camRay = createCamRay(uv, camPos, camDir, camRight, camUp);
    float3 seed = (float3)(uv.x, uv.y, frameCount);
    float4 result = traceRay(&camRay, frameCount, &seed);

    if (frameCount <= 0) {
        // clear running average
        frame[work_item_id] = (float4)(0.0f,0.0f,0.0f,0.0f);
    }
    else {
        // blend
        result = (frame[work_item_id] * (frameCount-1)  + result) / frameCount;
    }

    // write output
    frame[work_item_id]  = result;
    pixels[work_item_id] = float4ToInt32(result);
}