#pragma once

#include <include/utilities.cl>

//// MATERIALS

// Material struct definition in utilities.cl

Material createMaterial(float3 albedo, float3 specular, float3 emission, float ir, MaterialType type) {
    return (Material){albedo, specular, emission, ir, type};
}


// Use Schlick's approximation for reflectance.
float reflectance(float cosine, float ref_idx) {
    float r0 = (1 - ref_idx) / (1 + ref_idx);
    r0 = r0 * r0;
    return r0 + (1 - r0) * pow((1 - cosine), 5);
}

void dielectricBRDF(Ray *ray, HitInfo *hit, float3 *seed) {
    // lifted from Ray Tracing In One Weekend by Peter Shirley
    bool frontFace = dot(ray->direction, hit->normal) < 0.0f;
    float refraction_ratio = frontFace ? (1.0f / hit->material.ir) : hit->material.ir;

    float3 normal = frontFace ? hit->normal : -(hit->normal);

    float cos_theta = min(dot(-ray->direction, normal), 1.0f);
    float sin_theta = sqrt(1.0f - cos_theta * cos_theta);

    bool cannot_refract = refraction_ratio * sin_theta > 1.0f;
    float3 direction;

    if (cannot_refract || reflectance(cos_theta, refraction_ratio) > noise(seed)) {
        direction = reflect(ray->direction, normal);
        ray->position = hit->position + 0.00001f*normal;
    }
    else {
        direction = refract(ray->direction, normal, refraction_ratio);
        ray->position = hit->position - 0.00001f*normal;
    }

    ray->radiance += ray->weakness * hit->material.emission;
    ray->weakness *= hit->material.albedo;
    ray->direction = direction;
}

void metallicBRDF(Ray *ray, HitInfo *hit) {
    // Schlick approximation for metallic reflections: https://github.com/RayTracing/raytracing.github.io/issues/844
    float cos_theta = sdot(hit->normal, -ray->direction);

    ray->radiance += ray->weakness * hit->material.emission;
    ray->position = hit->position;
    ray->direction = normalize(reflect(ray->direction, hit->normal));
    ray->weakness *= hit->material.specular + ((float3)(1) - hit->material.specular) * pow(1 - cos_theta, 5);
}

void diffuseBRDF(Ray *ray, HitInfo *hit, unsigned long frameCount, float3 *seed) {
    float3 lightOutDir = sampleHemisphere(hit->normal, frameCount, seed);
    ray->radiance += ray->weakness * hit->material.emission;
    ray->weakness *= 2.0f * hit->material.albedo * sdot(hit->normal, lightOutDir);
    ray->position = hit->position;
    ray->direction = lightOutDir;
}

