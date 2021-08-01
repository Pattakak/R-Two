#include <include/generators/tinymt32.cl>
#include <include/utilities.cl>
#include <include/geometry.cl>
#include <include/materials.cl>


//// SCENE

void updateRay(Ray *ray, HitInfo *hit, unsigned long frameCount, float3 *seed) {
    // if (hit->material.ir > 0) {
    //     dielectricBRDF(ray, hit, seed);
    // }
    // else if (hit->material.specular.x > 0) {
    //     metallicBRDF(ray, hit);
    // } 
    // else {
    //     diffuseBRDF(ray, hit, frameCount, seed);
    // }
    if (hit->material.type == DIELECTRIC) {
        dielectricBRDF(ray, hit, seed);
    }
    else if (hit->material.type == METALLIC) {
        metallicBRDF(ray, hit);
    }
    else {
        diffuseBRDF(ray, hit, frameCount, seed);
    }
    
}

HitInfo intersectScene(Ray *ray) {
    Plane planes[1];
    planes[0].point  = (float3)(0, -0.5, 0); // floor
    planes[0].normal = (float3)(0,  1, 0);
    planes[0].material = createMaterial((float3)(0.6), (float3)(0), (float3)(0), 0, DIFFUSE);

    Sphere spheres[4];
	spheres[0].position = (float3)(0.5f, 0.0f, -2.5f);	// inner sphere 1
	spheres[0].radius = 0.5f;
	spheres[0].material = createMaterial((float3)(1.0f, 1.0f, 1.0f), (float3)(1, 0.2f, 0.2f), (float3)(0), 0, METALLIC);

	spheres[1].position = (float3)(-0.5f, 0.0f, -3.0f);	// inner sphere 2
	spheres[1].radius = 0.5f;
	spheres[1].material = createMaterial((float3)(0.5f, 0.5f, 1.0f), (float3)(0), (float3)(0), 0, DIFFUSE);

    spheres[2].position = (float3)(0.0f, 0.2f, -1.5f);	// inner sphere 3
	spheres[2].radius = 0.2f;
	spheres[2].material = createMaterial((float3)(1, 1, 1), (float3)(0), (float3)(0), 1.5, DIELECTRIC);

    spheres[3].position = (float3)(-0.5f, -0.3f, -2.25);	// inner sphere 4
	spheres[3].radius = 0.2f;
	spheres[3].material = createMaterial((float3)(1.0f, 1.0f, 1.0f), (float3)(0.8), (float3)(0), 0, METALLIC);
    
    Triangle tri;
    tri.a = (float3)(-0.5f, 0, -2.0f);
    tri.b = (float3)(0, -0.5f, -1.75f);
    tri.c = (float3)(0, -0.25f, -2.25f);
    tri.material = createMaterial((float3)(0.2f, 1.0f, 0.2f), (float3)(0), (float3)(0), 0, DIFFUSE);

    Disc disc;
    disc.center = (float3)(0, 1.99, -3);
    disc.normal = (float3)(0, -1, 0);
    disc.material = createMaterial((float3)(0.0f, 0.0f, 0.0f), (float3)(0), (float3)(6), 0, DIFFUSE);
    disc.radius = 0.5;

	float t = MAXFLOAT;
    HitInfo bestHit;
    bestHit.normal = (float3)(0.0f,0.0f,0.0f);
    bestHit.material = createMaterial((float3)(0), (float3)(0), (float3)(1), 0, DIFFUSE);
	bestHit.distance = MAXFLOAT;

    for (int i = 0; i < 1; i++) {
        if ((t = intersectPlane(ray, &planes[i])) < bestHit.distance) {
            bestHit.distance = t;
            bestHit.position = ray->position + t*ray->direction;
            bestHit.normal = planes[i].normal;
			bestHit.material = planes[i].material;
        }
    }

    for (int i = 0; i < 4; i++) {
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