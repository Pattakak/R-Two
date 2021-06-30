#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <SDL2/SDL.h>
#include <glm/glm.hpp>
#include "pixelBuffer.hpp"
#include "../include/opencl.hpp"

using namespace std;
using namespace cl;

using std::vector;

// Window dimensions
static const int WINDOW_WIDTH = 1280;
static const int WINDOW_HEIGHT = 720;

cl_float4* cpu_output;
CommandQueue queue;
Kernel kernel;
Context context;
Program program;
Buffer cl_output;

void pickPlatform(Platform& platform, const std::vector<Platform>& platforms){
	
	if (platforms.size() == 1) platform = platforms[0];
	else{
		int input = 0;
		cout << "\nChoose an OpenCL platform: ";
		cin >> input;

		// handle incorrect user input
		while (input < 1 || input > platforms.size()){
			cin.clear(); //clear errors/bad flags on cin
			cin.ignore(cin.rdbuf()->in_avail(), '\n'); // ignores exact number of chars in cin buffer
			cout << "No such option. Choose an OpenCL platform: ";
			cin >> input;
		}
		platform = platforms[input - 1];
	}
}

void pickDevice(Device& device, const std::vector<Device>& devices){
	
	if (devices.size() == 1) device = devices[0];
	else{
		int input = 0;
		cout << "\nChoose an OpenCL device: ";
		cin >> input;

		// handle incorrect user input
		while (input < 1 || input > devices.size()){
			cin.clear(); //clear errors/bad flags on cin
			cin.ignore(cin.rdbuf()->in_avail(), '\n'); // ignores exact number of chars in cin buffer
			cout << "No such option. Choose an OpenCL device: ";
			cin >> input;
		}
		device = devices[input - 1];
	}
}

void printErrorLog(const Program& program, const Device& device){
	
	// Get the error log and print to console
	string buildlog = program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device);
	cerr << "Build log:" << std::endl << buildlog << std::endl;

	// Print the error log to a file
	FILE *log = fopen("errorlog.txt", "w");
	fprintf(log, "%s\n", buildlog.c_str());
	cout << "Error log saved in 'errorlog.txt'" << endl;
	system("PAUSE");
	exit(1);
}

void selectRenderMode(unsigned int& rendermode){
	cout << endl << "Rendermodes: " << endl << endl;
	cout << "\t(1) Simple gradient" << endl;
	cout << "\t(2) Sphere with plain colour" << endl;
	cout << "\t(3) Sphere with cosine weighted colour" << endl;
	cout << "\t(4) Stripey sphere" << endl;
	cout << "\t(5) Sphere with screen door effect" << endl;
	cout << "\t(6) Sphere with normals" << endl;

	unsigned int input;
	cout << endl << "Select rendermode (1-6): ";
	cin >> input; 

	// handle incorrect user input
	while (input < 1 || input > 6){
		cin.clear(); //clear errors/bad flags on cin
		cin.ignore(cin.rdbuf()->in_avail(), '\n'); // ignores exact number of chars in cin buffer
		cout << "No such option. Select rendermode: ";
		cin >> input;
	}
	rendermode = input;
}

void initOpenCL()
{
	// Get all available OpenCL platforms (e.g. AMD OpenCL, Nvidia CUDA, Intel OpenCL)
	std::vector<Platform> platforms;
	Platform::get(&platforms);
	cout << "Available OpenCL platforms : " << endl << endl;
	for (int i = 0; i < platforms.size(); i++)
		cout << "\t" << i + 1 << ": " << platforms[i].getInfo<CL_PLATFORM_NAME>() << endl;

	// Pick one platform
	Platform platform;
	pickPlatform(platform, platforms);
	cout << "\nUsing OpenCL platform: \t" << platform.getInfo<CL_PLATFORM_NAME>() << endl;

	// Get available OpenCL devices on platform
	std::vector<Device> devices;
	platform.getDevices(CL_DEVICE_TYPE_ALL, &devices);

	cout << "Available OpenCL devices on this platform: " << endl << endl;
	for (int i = 0; i < devices.size(); i++){
		cout << "\t" << i + 1 << ": " << devices[i].getInfo<CL_DEVICE_NAME>() << endl;
		cout << "\t\tMax compute units: " << devices[i].getInfo<CL_DEVICE_MAX_COMPUTE_UNITS>() << endl;
		cout << "\t\tMax work group size: " << devices[i].getInfo<CL_DEVICE_MAX_WORK_GROUP_SIZE>() << endl << endl;
	}

	// Pick one device
	Device device;
	pickDevice(device, devices);
	cout << "\nUsing OpenCL device: \t" << device.getInfo<CL_DEVICE_NAME>() << endl;
	cout << "\t\t\tMax compute units: " << device.getInfo<CL_DEVICE_MAX_COMPUTE_UNITS>() << endl;
	cout << "\t\t\tMax work group size: " << device.getInfo<CL_DEVICE_MAX_WORK_GROUP_SIZE>() << endl;

	// Create an OpenCL context and command queue on that device.
	context = Context(device);
	queue = CommandQueue(context, device);

	// Convert the OpenCL source code to a string
	string source;
	ifstream file("src/opencl_kernel.cl");
	if (!file){
		cout << "\nNo OpenCL file found!" << endl << "Exiting..." << endl;
		system("PAUSE");
		exit(1);
	}
	while (!file.eof()){
		char line[256];
		file.getline(line, 255);
		source += line;
	}

	const char* kernel_source = source.c_str();

	// Create an OpenCL program by performing runtime source compilation for the chosen device
	program = Program(context, kernel_source);
	cl_int result = program.build({ device });
	if (result) cout << "Error during compilation OpenCL code!!!\n (" << result << ")" << endl;
	if (result == CL_BUILD_PROGRAM_FAILURE) printErrorLog(program, device);

	// Create a kernel (entry point in the OpenCL source program)
	kernel = Kernel(program, "render_kernel");
}

inline float clamp(float x){ return x < 0.0f ? 0.0f : x > 1.0f ? 1.0f : x; }

// convert RGB float in range [0,1] to int in range [0, 255]
inline int toInt(float x){ return int(clamp(x) * 255 + .5); }


int main(int argc, char **argv) {
    // Initialize SDL
    SDL_Init(SDL_INIT_VIDEO);

    // Create an SDL window
    SDL_Window *window = SDL_CreateWindow("Hello, SDL2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_OPENGL);

    // Create a renderer (accelerated and in sync with the display refresh rate)
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);    

    PixelBuffer pixelBuffer = PixelBuffer(WINDOW_WIDTH, WINDOW_HEIGHT);
    
    SDL_Texture * texture = SDL_CreateTexture(renderer,
            pixelBuffer.pixelFormat, SDL_TEXTUREACCESS_STREAMING, pixelBuffer.width, pixelBuffer.height);

    // Initial renderer color
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);

	cpu_output = new cl_float3[WINDOW_WIDTH * WINDOW_HEIGHT];

	initOpenCL();

	// Create image buffer on the OpenCL device
	cl_output = Buffer(context, CL_MEM_WRITE_ONLY, WINDOW_WIDTH * WINDOW_HEIGHT * sizeof(cl_float3));

	// pick a rendermode
	unsigned int rendermode;
	selectRenderMode(rendermode);

	// specify OpenCL kernel arguments
	kernel.setArg(0, cl_output);
	kernel.setArg(1, WINDOW_WIDTH);
	kernel.setArg(2, WINDOW_HEIGHT);
	kernel.setArg(3, rendermode);

	std::size_t global_work_size = WINDOW_WIDTH * WINDOW_HEIGHT;
	std::size_t local_work_size = 64; 

    bool running = true;
    SDL_Event event;
    while(running) {
        // Process events
        while(SDL_PollEvent(&event)) {
            if(event.type == SDL_QUIT) {
                running = false;
            } else if(event.type == SDL_KEYDOWN) {
                const char *key = SDL_GetKeyName(event.key.keysym.sym);
                if(strcmp(key, "Escape") == 0) {
                    running = false;
                }                    
            }
        }

		// Clear screen
        SDL_UpdateTexture(texture, NULL, pixelBuffer.pixels,  pixelBuffer.width * sizeof(Uint32));
        pixelBuffer.clear();
        SDL_RenderClear(renderer);

		// Draw
		// launch the kernel
		queue.enqueueNDRangeKernel(kernel, NULL, global_work_size, local_work_size);
		queue.finish();

		// read and copy OpenCL output to CPU
		queue.enqueueReadBuffer(cl_output, CL_TRUE, 0, WINDOW_WIDTH * WINDOW_HEIGHT * sizeof(cl_float3), cpu_output);

		for (int i = 0; i < WINDOW_WIDTH; i++) {
			for (int j = 0; j < WINDOW_HEIGHT; j++) {
				cl_float4 cl_vec = cpu_output[i + j * WINDOW_WIDTH];
				glm::vec3 myVec(cl_vec.s[0], cl_vec.s[1], cl_vec.s[2]);
				pixelBuffer.setPixel(i, j, myVec);
			}
		}

        pixelBuffer.setPixel(pixelBuffer.width / 2, pixelBuffer.height / 2, glm::vec3(0, 1, 0));
        SDL_RenderCopy(renderer, texture, NULL, NULL);

        // Show what was drawn
        SDL_RenderPresent(renderer);
    }

    // Release resources
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}

