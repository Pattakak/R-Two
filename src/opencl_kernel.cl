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

__kernel void render_kernel(__global float4 *frame, __global uint *pixels, int width, int height, unsigned long frameCount) {
    const int work_item_id = get_global_id(0);            /* the unique global id of the work item for the current pixel */
    int x_coord = work_item_id % width;                    /* x-coordinate of the pixel */
    int y_coord = work_item_id / width;                    /* y-coordinate of the pixel */

    float2 uv = (float2)((float)x_coord / (float)width, (float)y_coord / (float)height);

    /* generate new noise each frame */
    float n = noise((float3)(uv, frameCount));
    float4 result = (float4)(n, n, n, 1.0f);

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