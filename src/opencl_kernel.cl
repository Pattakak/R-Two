float noise(float3 seed) {
    float floor;
    return fract(sin(dot(seed, (float3)(1323232.9898f,7843432.233f, 23872.23232f)) * 4375348.5453123f), &floor);
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

typedef struct ray {
	float3 pos;
	float3 dir;
	float3 energy; // color 
} Ray;

typedef struct Sphere {
	float3 pos;
	float  radius;
} Sphere;

typedef struct GroundPlane {
	float  height;
} GroundPlane;


Ray createCamRay(float2 uv, float3 camPos, float3 camDir) {
	Ray ray;
	ray.pos = camPos;
	ray.dir = normalize((float3)(uv.x, uv.y, -1.0f)); //assumption for now
	ray.energy = (float3)(0.0f,0.0f,0.0f);
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

float intersectGroundPlane(const Ray *ray, GroundPlane plane) {
	if (ray->dir.y != 0) {
		float t = (plane.height - ray->pos.y) / ray->dir.y;
		if (t > 0.0f) return t;
	}
	return MAXFLOAT;
}

void intersectScene(Ray *ray) {
	Sphere sphere;
	sphere.pos = (float3)(0.0f,1.0f,-2.0f);
	sphere.radius = 0.5f;
	GroundPlane plane;
	plane.height = 0.0f;

	float3 hitPos, normal;
	float t, hitDist = MAXFLOAT, epsilon = 0.000001f;


	if ((t = intersectSphere(ray, sphere)) < hitDist) {
		hitPos = ray->pos + t*ray->dir;
		normal = normalize(hitPos - sphere.pos);
		hitPos += epsilon*normal;
		ray->energy = normal;
		hitDist = t;
	}

	// if ((t = intersectGroundPlane(ray, plane)) < hitDist) {
	// 	hitPos = ray->pos + t*ray->dir;
	// 	normal = (float3)(0.0f,1.0f,0.0f);
	// 	hitPos += epsilon*normal;
	// 	ray->energy = normal;
	// 	hitDist = t;
	// }


}

float4 traceRay(Ray *ray) {

	intersectScene(ray);
	return (float4)(ray->energy, 1.0f);
}

__kernel void render_kernel(__global float4 *frame, __global uint *pixels, int width, int height, unsigned long frameCount) {
    const int work_item_id = get_global_id(0);
    int x_coord = work_item_id % width;
    int y_coord = work_item_id / width;
    float2 uv = (float2)((float)x_coord - 0.5f*(float)width, 0.5f*(float)height - (float)y_coord) / (float)height;

	// generate initial ray
    float3 camPos = (float3)(0.0f, 1.0f, 0.0f);
	float3 camDir = (float3)(0.0f, 0.0f, -1.0f);
	Ray camRay = createCamRay(uv, camPos, camDir);

	// trace
	float4 result = traceRay(&camRay);	
	
	//result = (float4)(uv, 0.0f,1.0f);

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