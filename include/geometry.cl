#pragma once

#include <include/utilities.cl>

//// GEOMETRY

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
