float noise(float3 seed) {
    float floor;
    return fract(sin(dot(seed, (float3)(1323232.9898f,7843432.233f, 23872.23232f)) * 4375348.5453123f), &floor);
}

static float get_random(unsigned int *seed0, unsigned int *seed1) {

	/* hash the seeds using bitwise AND operations and bitshifts */
	*seed0 = 36969 * ((*seed0) & 65535) + ((*seed0) >> 16);
	*seed1 = 18000 * ((*seed1) & 65535) + ((*seed1) >> 16);

	unsigned int ires = ((*seed0) << 16) + (*seed1);

	/* use union struct to convert int to float */
	union {
		float f;
		unsigned int ui;
	} res;

	res.ui = (ires & 0x007fffff) | 0x40000000;  /* bitwise AND, bitwise OR */
	return (res.f - 2.0f) / 2.0f;
}

uint float4ToInt32(float4 color) {
    uint r = (uint)(color.x * 255.99999f);
    uint g = (uint)(color.y * 255.99999f);
    uint b = (uint)(color.z * 255.99999f);
    uint a = (uint)(color.w * 255.99999f);
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

typedef struct Mat3 {
    float3 col0;
    float3 col1;
    float3 col2;
} Mat3;

typedef struct ray {
    float3 pos;
    float3 dir;
    float3 energy; // color 
} Ray;

typedef struct Sphere {
	float3 pos;
	float3 albedo;
	float  radius;
} Sphere;

typedef struct Plane {
    float3 point;
    float3 normal;
    float3 albedo;
} Plane;

typedef struct HitInfo {
    float3 normal;
    float3 albedo;
    float3 pos;
    float  distance;
	bool hitSomething;
} HitInfo;

float3 mul(Mat3 mat, float3 vec) {
    return vec.x*mat.col0+vec.y*mat.col1+vec.z*mat.col2;
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

float3 sampleHemisphere(float3 normal, unsigned long frameCount) {
    // returns a vector uniformly sampled from the hemisphere around a given normal
    // borrowed from http://three-eyed-games.com/2018/05/12/gpu-path-tracing-in-unity-part-2/
    // uniformly sample hemisphere direction
    float cosTheta = noise((float3)(normal.x, normal.y, frameCount));
    float sinTheta = sqrt(max(0.0f, 1.0f - cosTheta * cosTheta));
    float phi = 2 * 3.141528 * noise(normal.yzx);
    float3 tangentSpaceDir = (float3)(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
    // transform direction to world space
    return mul(getTangentSpace(normal), tangentSpaceDir);
}

Ray createCamRay(float2 uv, float3 camPos, float3 camDir, float3 camRight, float3 camUp) {
	Ray ray;
	ray.pos = camPos;
    ray.dir = normalize((float3)(camDir.x + uv.x * camRight.x + uv.y * camUp.x, 
                                camDir.y + uv.x * camRight.y + uv.y * camUp.y,
                                camDir.z + uv.x * camRight.z + uv.y * camUp.z));
	ray.energy = (float3) (1.0f, 1.0f, 1.0f);
	return ray;
}

float intersectSphere(const Ray *ray, Sphere sphere) {
    // line-sphere intersection: 0, 1, or 2 intersections
    float3 disp = ray->pos - sphere.pos;
    float p1 = -1.0f*dot(ray->dir, disp);
    float p2sqr = p1*p1 - dot(disp, disp) + sphere.radius*sphere.radius;
    if (p2sqr < 0.0f) {
        return MAXFLOAT; // no intersection
    }
    // find closer intersection
    float p2 = sqrt(p2sqr);
    float t = p1 - p2 > 0.0f ? p1 - p2 : p1 + p2;
    if (t > 0.0f) {
          return t;
    }
    else {
        return MAXFLOAT;
    }
}

float intersectPlane(const Ray *ray, const Plane *plane) {
    float d_dot_n = dot(ray->dir, plane->normal);
    if (fabs(d_dot_n) <= 0.0000001f) {
        return MAXFLOAT;    // the ray and the plane are parallel
    }
	float retval = (float)(dot((plane->point - ray->pos), plane->normal) / d_dot_n);
	if (retval > 0) {
		return retval;
	} else {
		return MAXFLOAT;
	}
}

HitInfo intersectScene(Ray *ray) {
	Sphere spheres[8];
	spheres[0].pos = (float3)(0.5f, 0.0f, -2.0f);	// inner sphere 1
	spheres[0].radius = 0.5f;
	spheres[0].albedo = (float3)(1.0f, 0.5f, 0.5f);

	spheres[1].pos = (float3)(-0.5f, 0.0f, -2.0f);	// inner sphere 2
	spheres[1].radius = 0.5f;
	spheres[1].albedo = (float3)(0.5f, 0.5f, 1.0f);

	spheres[2].pos = (float3)(0.0f, -100.5f, 0.0f);	// bottom
	spheres[2].radius = 100.0f;
	spheres[2].albedo = (float3)(0.81, 0.68, 0.40);

	spheres[3].pos = (float3)(102.0f, 0.0f, 0.0f);	// right
	spheres[3].radius = 100.0f;
	spheres[3].albedo = (float3)(0.2f, 1.0f, 0.2f);

	spheres[4].pos = (float3)(-102.0f, 0.0f, 0.0f);	// left
	spheres[4].radius = 100.0f;
	spheres[4].albedo = (float3)(1.0f, 0.2f, 0.2f);

	spheres[5].pos = (float3)(0.0f, 0.0f, -104.0f);	// back
	spheres[5].radius = 100.0f;
	spheres[5].albedo = (float3) (0.81, 0.68, 0.40);

	spheres[6].pos = (float3)(0.0f, 104.0f, -2.0f);	// top
	spheres[6].radius = 100.0f;
	spheres[6].albedo = (float3)(0.2f, 0.2f, 1.0f);

	spheres[7].pos = (float3)(0.0f, 4.0f, -2.0f);	// light
	spheres[7].radius = 1.0f;
	spheres[7].albedo = (float3)(12, 12, 12);

	float3 hitPos, hitNormal;
	float t, hitDist = MAXFLOAT;
    HitInfo bestHit;
    bestHit.normal = (float3)(0.0f,0.0f,0.0f);
	bestHit.hitSomething = false;
	
	bestHit.distance = MAXFLOAT;
    for (int i = 0; i < 8; i++) {
        if ((t = intersectSphere(ray, spheres[i])) < bestHit.distance) {
            bestHit.distance = t;
            bestHit.pos = ray->pos + t*ray->dir;
            bestHit.normal = normalize(bestHit.pos - spheres[i].pos);
			bestHit.albedo = spheres[i].albedo;
			bestHit.hitSomething = true;
	    }
    }
    return bestHit;

}

void updateRay(Ray *ray, HitInfo *hit, unsigned long frameCount) {
    const float epsilon = 0.000001f;
    ray->pos = hit->pos + epsilon*hit->normal;
    
    // simple albedo brdf
    float3 outDir = sampleHemisphere(hit->normal, frameCount);
    ray->energy *= hit->albedo * fabs(dot(hit->normal, outDir));

    ray->dir = outDir;
}

float4 traceRay(Ray *ray, unsigned long frameCount) {
	const int RECURSION_DEPTH = 3;
	float4 bg_color = (float4)(1.0f, 1.0f, 1.0f, 1.0f);

    for (int i = 0; i < RECURSION_DEPTH; i++) {
        HitInfo info = intersectScene(ray);
		if (info.hitSomething == false) {
			// if this is the primary ray, ray->energy should be (1,1,1).
			return (float4)(ray->energy, 1.0f) * bg_color;
		} else {
			updateRay(ray, &info, frameCount);
			// hit an emissive object?
			if (info.albedo.x > 1 || info.albedo.y > 1 || info.albedo.z > 1) {
				if (i == 0) {
					ray->energy = clamp(info.albedo, 0.0f, 1.0f);
				}
				break;
			}
		}
    }

	return (float4)(ray->energy, 1.0f);
}

__kernel void render_kernel(__global float4 *frame, __global uint *pixels, int width, int height, unsigned long frameCount, float3 camDir, float3 camRight, float3 camUp, float3 camPos, float2 rands) {
    const int work_item_id = get_global_id(0);
    int x_coord = work_item_id % width;
    int y_coord = work_item_id / width;
    float2 uv = (float2)((float)(x_coord + rands.x) - 0.5f*(float)width, 0.5f*(float)height - (float)(y_coord + rands.y)) / (float)height;

	// Anti-aliasing
	Ray camRay = createCamRay(uv, camPos, camDir, camRight, camUp);
    float4 result = traceRay(&camRay, frameCount);

    if (frameCount <= 0) {
        // clear running average
        frame[work_item_id] = (float4)(0.0f,0.0f,0.0f,0.0f);
    }
    else {
        // blend
        result = (frame[work_item_id] * (frameCount-1)  + result) / frameCount;
    }

    /* write output */
    frame[work_item_id]  = result;
    pixels[work_item_id] = float4ToInt32(result);
}