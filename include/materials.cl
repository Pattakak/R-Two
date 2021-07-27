#pragma once

#include <include/utilities.cl>

//// MATERIALS

// Material struct definition in utilities.cl

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

