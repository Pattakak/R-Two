#pragma once

//// UTILITIES

#define PI 3.141592654359f

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

// have to put the Material and HitInfo structs here, or else there will be circular dependencies.
typedef struct Material {
    float3 albedo;      // used for diffuse objects. All objects must have this!
    float3 specular;    // used for metallic objects
    float3 emission;    // used for lights
    float  ir;          // index of refraction, for dielectrics
} Material;

typedef struct HitInfo {
    float3 normal;
    float3 position;
    float  distance;
    Material material;
} HitInfo;


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