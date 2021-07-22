#define PI 3.141592654359f

__constant float rand_nums[512] = {
0.477375f, 0.459094f, 0.482722f, 0.188934f, 0.759475f, 0.927543f, 0.633613f, 0.092689f, 
0.258921f, 0.340642f, 0.094641f, 0.218927f, 0.367774f, 0.986310f, 0.802782f, 0.579785f, 
0.835959f, 0.421707f, 0.828711f, 0.873321f, 0.332948f, 0.433597f, 0.539871f, 0.810074f, 
0.168880f, 0.330703f, 0.152019f, 0.120433f, 0.504916f, 0.892678f, 0.885269f, 0.025574f, 
0.673968f, 0.675283f, 0.771443f, 0.721862f, 0.097571f, 0.235591f, 0.098726f, 0.232831f, 
0.640556f, 0.012481f, 0.810952f, 0.342638f, 0.881979f, 0.400693f, 0.923513f, 0.135504f, 
0.522902f, 0.091716f, 0.232073f, 0.385639f, 0.031970f, 0.701327f, 0.311596f, 0.738524f, 
0.078745f, 0.028098f, 0.356675f, 0.128748f, 0.830238f, 0.548039f, 0.326691f, 0.557591f, 
0.908250f, 0.170195f, 0.155945f, 0.706463f, 0.571960f, 0.833308f, 0.643321f, 0.098512f, 
0.838675f, 0.381938f, 0.205305f, 0.016467f, 0.381577f, 0.238593f, 0.926744f, 0.291274f, 
0.129859f, 0.799298f, 0.482663f, 0.655927f, 0.218934f, 0.370017f, 0.795897f, 0.709531f, 
0.337425f, 0.694739f, 0.822070f, 0.884161f, 0.697558f, 0.732867f, 0.100083f, 0.255849f, 
0.676110f, 0.594623f, 0.215371f, 0.340430f, 0.768705f, 0.575039f, 0.365886f, 0.246980f, 
0.309648f, 0.293285f, 0.654158f, 0.141869f, 0.716541f, 0.643738f, 0.308118f, 0.215406f, 
0.883712f, 0.981381f, 0.591806f, 0.218265f, 0.855199f, 0.214212f, 0.474623f, 0.201259f, 
0.713125f, 0.763723f, 0.933759f, 0.051488f, 0.088392f, 0.016451f, 0.590298f, 0.646087f, 
0.867954f, 0.974124f, 0.791288f, 0.326587f, 0.204444f, 0.281091f, 0.899866f, 0.593632f, 
0.345161f, 0.129977f, 0.662616f, 0.689046f, 0.357778f, 0.905721f, 0.339085f, 0.483590f, 
0.348905f, 0.759119f, 0.698868f, 0.779543f, 0.026312f, 0.639027f, 0.931736f, 0.549301f, 
0.056366f, 0.954138f, 0.165277f, 0.247467f, 0.791299f, 0.915249f, 0.117955f, 0.970620f, 
0.989272f, 0.042556f, 0.407173f, 0.760898f, 0.313580f, 0.840346f, 0.601330f, 0.453379f, 
0.359847f, 0.558848f, 0.375647f, 0.281789f, 0.034162f, 0.546559f, 0.128968f, 0.808949f, 
0.492532f, 0.963351f, 0.480953f, 0.099589f, 0.296016f, 0.768180f, 0.095878f, 0.062685f, 
0.711595f, 0.647248f, 0.210517f, 0.034189f, 0.890889f, 0.678308f, 0.251699f, 0.531722f, 
0.715179f, 0.412397f, 0.961145f, 0.479609f, 0.934394f, 0.943690f, 0.356782f, 0.349011f, 
0.006471f, 0.884460f, 0.872741f, 0.129117f, 0.735407f, 0.800486f, 0.513251f, 0.553728f, 
0.174543f, 0.058466f, 0.368830f, 0.133462f, 0.577116f, 0.581011f, 0.770635f, 0.063309f, 
0.342535f, 0.466727f, 0.968854f, 0.681843f, 0.373302f, 0.889237f, 0.692114f, 0.124767f, 
0.612203f, 0.923527f, 0.333847f, 0.104702f, 0.222504f, 0.934578f, 0.613099f, 0.199714f, 
0.619949f, 0.700264f, 0.562332f, 0.834881f, 0.637609f, 0.557882f, 0.163723f, 0.209052f, 
0.897071f, 0.129126f, 0.866885f, 0.151012f, 0.020854f, 0.627895f, 0.366473f, 0.783672f, 
0.462381f, 0.472621f, 0.413110f, 0.449693f, 0.442296f, 0.627598f, 0.022661f, 0.879034f, 
0.495498f, 0.791511f, 0.209884f, 0.101142f, 0.665866f, 0.316568f, 0.716944f, 0.468931f, 
0.816857f, 0.910178f, 0.694781f, 0.946878f, 0.731088f, 0.653558f, 0.440871f, 0.693994f, 
0.848151f, 0.864415f, 0.425603f, 0.678462f, 0.175835f, 0.308397f, 0.268211f, 0.497267f, 
0.896487f, 0.331613f, 0.500001f, 0.015866f, 0.202972f, 0.306102f, 0.071483f, 0.327877f, 
0.560403f, 0.170401f, 0.834647f, 0.644374f, 0.051182f, 0.403856f, 0.765901f, 0.755151f, 
0.760471f, 0.928790f, 0.140377f, 0.797489f, 0.585685f, 0.487398f, 0.412003f, 0.397725f, 
0.470601f, 0.930252f, 0.245361f, 0.929735f, 0.735832f, 0.574775f, 0.919900f, 0.063320f, 
0.788862f, 0.303374f, 0.846661f, 0.138628f, 0.079390f, 0.871368f, 0.551810f, 0.127766f, 
0.784646f, 0.255884f, 0.712355f, 0.213293f, 0.100309f, 0.137696f, 0.264943f, 0.513300f, 
0.633784f, 0.401123f, 0.730318f, 0.727520f, 0.918648f, 0.766104f, 0.829497f, 0.740601f, 
0.553640f, 0.347131f, 0.819544f, 0.067441f, 0.173310f, 0.864602f, 0.427982f, 0.602724f, 
0.811626f, 0.511962f, 0.043858f, 0.658961f, 0.842948f, 0.174114f, 0.900608f, 0.001772f, 
0.626605f, 0.210386f, 0.711363f, 0.583940f, 0.035718f, 0.921826f, 0.344783f, 0.572241f, 
0.197406f, 0.554890f, 0.014816f, 0.309916f, 0.179559f, 0.251000f, 0.819930f, 0.140791f, 
0.130486f, 0.895346f, 0.803543f, 0.446852f, 0.963876f, 0.500691f, 0.269318f, 0.151672f, 
0.451032f, 0.156163f, 0.919865f, 0.345493f, 0.646817f, 0.596775f, 0.248823f, 0.253713f, 
0.304131f, 0.936027f, 0.418802f, 0.335879f, 0.957938f, 0.449398f, 0.062857f, 0.658680f, 
0.683524f, 0.345982f, 0.080895f, 0.137999f, 0.120609f, 0.211801f, 0.013222f, 0.753079f, 
0.968705f, 0.487568f, 0.142430f, 0.417808f, 0.774667f, 0.145967f, 0.015138f, 0.478029f, 
0.001361f, 0.901937f, 0.592300f, 0.421640f, 0.997975f, 0.848213f, 0.489652f, 0.661975f, 
0.236701f, 0.142535f, 0.363198f, 0.065579f, 0.432726f, 0.127809f, 0.406269f, 0.189405f, 
0.065024f, 0.329005f, 0.030047f, 0.589432f, 0.485749f, 0.738821f, 0.942436f, 0.388950f, 
0.163666f, 0.226536f, 0.293833f, 0.278633f, 0.234338f, 0.912934f, 0.383685f, 0.570969f, 
0.288327f, 0.047069f, 0.826360f, 0.055467f, 0.339572f, 0.676479f, 0.829548f, 0.055632f, 
0.169641f, 0.262041f, 0.088865f, 0.483602f, 0.317196f, 0.798939f, 0.389061f, 0.589062f, 
0.940937f, 0.647220f, 0.707290f, 0.262558f, 0.944383f, 0.244326f, 0.313759f, 0.488218f, 
0.168208f, 0.898089f, 0.596423f, 0.592176f, 0.947539f, 0.207542f, 0.561518f, 0.053827f, 
0.517886f, 0.464699f, 0.213747f, 0.447566f, 0.018639f, 0.849292f, 0.418516f, 0.819475f, 
0.145255f, 0.839599f, 0.011923f, 0.766093f, 0.551483f, 0.638516f, 0.043070f, 0.121553f, 
0.279275f, 0.205919f, 0.173929f, 0.041281f, 0.844952f, 0.187198f, 0.174344f, 0.121377f, 
0.789951f, 0.152602f, 0.791472f, 0.040180f, 0.196005f, 0.620131f, 0.198640f, 0.395716f, 
0.447499f, 0.111468f, 0.326338f, 0.602453f, 0.468704f, 0.611892f, 0.438497f, 0.958476f
};


// current shitty noise
float noise(float3 *seed) {
    float floor;
    float result = fract(sin(dot(*seed, (float3)(1323232.9898f,7843432.233f, 23872.23232f)) * 4375348.5453123f), &floor);
    //float result = rand_nums[((int) dot(*seed, (float3)(1323232.9898f,7843432.233f, 23872.23232f))) % 512];
    //float result = 0.5f;
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

// saturated dot product
float sdot(float3 a, float3 b) {
    return clamp(dot(a,b), 0.0f, 1.0f);
}

typedef struct Mat3 {
    float3 col0;
    float3 col1;
    float3 col2;
} Mat3;

typedef struct Ray {
    float3 position;
    float3 direction;
    float3 weakness;   // running absorption 
    float3 radiance;   // running emmision
} Ray;

typedef struct PhongMaterial {
    float3 ambient;
    float3 albedo;
    float3 specular;
    float3 emission;
} PhongMaterial;

PhongMaterial createPhongMaterial(float3 ambient, float3 albedo, float3 specular, float3 emission) {
    float3 myAmbient = albedo / 10.0f;
    return (PhongMaterial){myAmbient, albedo, specular, emission};
}

float3 phongBRDF(PhongMaterial material, float3 lightOutDir, float3 lightInDir) {
    float alpha = 15.0f; // specular intensity
    return 2.0f * material.albedo + material.specular*(alpha+2.0f)*pow(sdot(lightInDir, lightOutDir),alpha);
}

typedef struct Sphere {
	float3 position;
	float  radius;
	PhongMaterial material;
} Sphere;

Sphere createSphere(float3 position, float radius, PhongMaterial material) {
    return (Sphere){position, radius, material};
}

typedef struct Plane {
    float3 point;
    float3 normal;
    PhongMaterial material;
} Plane;

typedef struct Triangle {
    float3 a;
    float3 b;
    float3 c;
    float3 normal;
    PhongMaterial material;
} Triangle;

typedef struct Disc {
    float3 center;
    float3 normal;
    float radius;
    PhongMaterial material;
} Disc;

typedef struct HitInfo {
    float3 normal;
    float3 position;
    float  distance;
    PhongMaterial material;
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
    
    // Next line explaination:
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
    float3 disp = ray->position- sphere.position;
    float p1 = -1.0f*dot(ray->direction, disp);
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

HitInfo intersectScene(Ray *ray) {
    Plane planes[6];
    planes[0].point  = (float3)(-2, 0, 0); // left wall
    planes[0].normal = (float3)(1, 0, 0);
    planes[0].material = createPhongMaterial((float3)(0.0), (float3)(1.0, 0.2, 0.2), (float3)(0), (float3)(0));

    planes[1].point  = (float3)(2, 0, 0);  // right wall
    planes[1].normal = (float3)(-1, 0, 0);
    planes[1].material = createPhongMaterial((float3)(0.0), (float3)(0.2f, 1.0f, 0.2f), (float3)(0), (float3)(0));

    planes[2].point  = (float3)(0, 0, -5); // front wall
    planes[2].normal = (float3)(0, 0, 1);
    planes[2].material = createPhongMaterial((float3)(0.0), (float3)(0.81, 0.68, 0.40), (float3)(0), (float3)(0));

    planes[3].point  = (float3)(0, -0.5, 0); // floor
    planes[3].normal = (float3)(0,  1, 0);
    planes[3].material = createPhongMaterial((float3)(0.0), (float3)(0.8, 0.8, 0.8), (float3)(0), (float3)(0));
    
    planes[4].point  = (float3)(0, 2, 0); // ceiling
    planes[4].normal = (float3)(0, -1, 0);
    planes[4].material = createPhongMaterial((float3)(0.0), (float3)(0.2f, 0.2f, 1.0f), (float3)(0), (float3)(0));

    planes[5].point  = (float3)(0, 0, 4);   // back wall
    planes[5].normal = (float3)(0, 0, -1);
    planes[5].material = createPhongMaterial((float3)(0.0), (float3)(0.81, 0.68, 0.40), (float3)(0), (float3)(0));

    Sphere spheres[2];
	spheres[0].position = (float3)(0.5f, 0.0f, -2.5f);	// inner sphere 1
	spheres[0].radius = 0.5f;
	spheres[0].material = createPhongMaterial((float3)(0.0), (float3)(1.0f, 1.0f, 1.0f), (float3)(1.0f,1.0f,1.0f), (float3)(0));

	spheres[1].position = (float3)(-0.5f, 0.0f, -3.0f);	// inner sphere 2
	spheres[1].radius = 0.5f;
	spheres[1].material = createPhongMaterial((float3)(0.0), (float3)(0.5f, 0.5f, 1.0f), (float3)(0), (float3)(0));
    

    Triangle tri;
    tri.a = (float3)(-0.5f, 0, -2.0f);
    tri.b = (float3)(0, -0.5f, -1.75f);
    tri.c = (float3)(0, -0.25f, -2.25f);
    tri.material = createPhongMaterial((float3)(0), (float3)(0.2f, 1.0f, 0.2f), (float3)(0), (float3)(0));

    Disc disc;
    disc.center = (float3)(0, 1.99, -3);
    disc.normal = (float3)(0, -1, 0);
    disc.material = createPhongMaterial((float3)(0), (float3)(0.0f, 0.0f, 0.0f), (float3)(0), (float3)(6));
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

    for (int i = 0; i < 2; i++) {
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

void BRDF(Ray *ray, HitInfo *hit, unsigned long framecount, float3 *seed, float3 *lightOutDir, float3 lightInDir) {
    ray->radiance += ray->weakness*hit->material.emission;
    if (hit->material.specular.x > 0.001) {
        // metallic object
        *lightOutDir = (normalize(reflect(lightInDir, hit->normal)));
    } else {
        // diffuse object
        *lightOutDir = sampleHemisphere(hit->normal, framecount, seed);
    }
    ray->weakness *= phongBRDF(hit->material, -ray->direction, *lightOutDir) * sdot(hit->normal, *lightOutDir);
    ray->direction = *lightOutDir;
}

void updateRay(Ray *ray, HitInfo *hit, unsigned long frameCount, float3 *seed) {
    const float epsilon = 0.0001f;
    ray->position= hit->position+ epsilon*hit->normal;
    
    // choose sample direction
    // float3 outDir = sampleHemisphere(hit->normal, frameCount, seed);
    // // accumulate radiance and weakness according to rendering equation
    // ray->radiance += ray->weakness*hit->material.emission;
    // ray->weakness *= phongBRDF(hit->material, -ray->direction, outDir) * sdot(hit->normal, outDir);
    // // update ray direction
    // ray->direction = outDir;
    float3 lightOutDir = (float3)(0);
    BRDF(ray, hit, frameCount, seed, &lightOutDir, ray->direction);
}

float4 traceRay(Ray *ray, unsigned long frameCount, float3 *seed) {
	const int RECURSION_DEPTH = 4;
	//float4 bg_color = (float4)(1.0f, 1.0f, 1.0f, 1.0f);
    for (int i = 0; i < RECURSION_DEPTH; i++) {
        HitInfo info = intersectScene(ray);
        if (i == RECURSION_DEPTH-1) info.material.emission = info.material.ambient; // current way to fudge remaining recursion results
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