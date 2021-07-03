float noise(float3 seed) {
	float floor;
    return fract(sin(dot(seed, (float3)(1323232.9898f,7843432.233f, 23872.23232f)) * 4375348.5453123f), &floor);
}

__kernel void render_kernel(__global char3* output, __global char3* input, int width, int height, unsigned long frameCount, int rendermode)
{
	const int work_item_id = get_global_id(0);		/* the unique global id of the work item for the current pixel */
	int x_coord = work_item_id % width;					/* x-coordinate of the pixel */
	int y_coord = work_item_id / width;					/* y-coordinate of the pixel */

	float2 uv = (float2)((float)x_coord / (float)width, (float)y_coord / (float)height);
	
	/* generate new noise each frame */
	float n = noise((float3)(uv, frameCount));
	float3 finalColor = (float3)(n, n, n);

	/* blend */
	//output[work_item_id] = convert_char3((input[work_item_id] * (frameCount-1)  + finalColor) / (frameCount) * 255.999f);
	output[work_item_id] = (work_item_id, work_item_id*2, work_item_id*3);
}
