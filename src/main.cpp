#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sys/time.h>
#include <SDL2/SDL.h>
#include <glm/glm.hpp>
#include "pixelBuffer.hpp"
#ifdef __APPLE__
#include "../include/opencl.hpp"
#else
#include "opencl.hpp"
#endif
#include "window.h"
#include "camera.h"
#include "clmacros.h"

using namespace std;
using namespace cl;

using std::vector;


CommandQueue queue;
Kernel kernel;
Context context;
Program program;
Buffer cl_frame;
Buffer cl_pixels;

bool keys_pressed[KEY_NUM_KEYS];

void pickPlatform(Platform& platform, const std::vector<Platform>& platforms){
    
    if (platforms.size() == 1) platform = platforms[0];
    else{
        int input = 0;
        cout << "\nChoose an OpenCL platform: ";
        cin >> input;

        // handle incorrect user input
        while ((unsigned) input < 1 || (unsigned) input > platforms.size()){
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
        while ((unsigned) input < 1 || (unsigned) input > devices.size()){
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

cl_float3 glmVec3ToCl(glm::vec3 vec) {
    return (cl_float3){{vec.x, vec.y, vec.z}};
}

void initOpenCL()
{
    // Get all available OpenCL platforms (e.g. AMD OpenCL, Nvidia CUDA, Intel OpenCL)
    std::vector<Platform> platforms;
    Platform::get(&platforms);
    cout << "Available OpenCL platforms : " << endl << endl;
    for (unsigned i = 0; i < platforms.size(); i++)
        cout << "\t" << i + 1 << ": " << platforms[i].getInfo<CL_PLATFORM_NAME>() << endl;

    // Pick one platform
    Platform platform;
    pickPlatform(platform, platforms);
    cout << "\nUsing OpenCL platform: \t" << platform.getInfo<CL_PLATFORM_NAME>() << endl;

    // Get available OpenCL devices on platform
    std::vector<Device> devices;
    platform.getDevices(CL_DEVICE_TYPE_ALL, &devices);

    cout << "Available OpenCL devices on this platform: " << endl << endl;
    for (unsigned i = 0; i < devices.size(); i++){
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
        source += '\n';
    }

    const char* kernel_source = source.c_str();

    // Create an OpenCL program by performing runtime source compilation for the chosen device
    program = Program(context, kernel_source);
    std::string options("-I ../include/generators/");
    cl_int result = program.build({ device }, options.c_str());
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
    SDL_SetHint(SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0");
    SDL_Window *window = SDL_CreateWindow("R-Two", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_OPENGL);

    // Create a renderer (accelerated and in sync with the display refresh rate)
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);    

    Window pixelBuffer = Window(WINDOW_WIDTH, WINDOW_HEIGHT);
    
    SDL_Texture * texture = SDL_CreateTexture(renderer,
            pixelBuffer.pixelFormat, SDL_TEXTUREACCESS_STREAMING, pixelBuffer.width, pixelBuffer.height);

    // Initial renderer color
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);

    initOpenCL();

    // Create image buffers on the OpenCL device
    cl_pixels = Buffer(context, CL_MEM_READ_ONLY,  WINDOW_WIDTH * WINDOW_HEIGHT * sizeof(cl_uint));   // output pixels
    cl_frame  = Buffer(context, CL_MEM_WRITE_ONLY, WINDOW_WIDTH * WINDOW_HEIGHT * sizeof(cl_float4)); // higher precision blend buffer

    unsigned long frameCount = 0;

    // Camera to link to program, and a mousedown functionality that lets you capture the mouse
    Camera cam = Camera(0.0f, 0.0f, 0.0f, 0.0f, -3.1415f / 2.0f);

    // specify OpenCL kernel arguments
    kernel.setArg(CL_INPUT_FRAME, cl_frame);
    kernel.setArg(CL_INPUT_PIXELS, cl_pixels);
    kernel.setArg(CL_INPUT_WIDTH, WINDOW_WIDTH);
    kernel.setArg(CL_INPUT_HEIGHT, WINDOW_HEIGHT);
    kernel.setArg(CL_INPUT_FRAMECOUNT, frameCount);
    kernel.setArg(CL_INPUT_CAM_DIR, glmVec3ToCl(cam.dir));
    kernel.setArg(CL_INPUT_CAM_RIGHT, glmVec3ToCl(cam.right));
    kernel.setArg(CL_INPUT_CAM_UP, glmVec3ToCl(cam.up));
    kernel.setArg(CL_INPUT_CAM_POS, glmVec3ToCl(cam.pos));

    std::size_t global_work_size = WINDOW_WIDTH * WINDOW_HEIGHT;
    std::size_t local_work_size = 64;

    // Timestamps for measuring fps and performance
    struct timeval timestamp;
    gettimeofday(&timestamp, NULL);
    long long init_ms;
    long long msi, msf;
    init_ms = timestamp.tv_sec * 1000000 + timestamp.tv_usec;
    msi = init_ms;

    
    bool mousedown = false;

    bool running = true;
    SDL_Event event;
    long long tdiff = 1000000; // Init tdiff to 1 second (arbitrary)
    while(running) {
        // Process events
        
        while(SDL_PollEvent(&event)) {
            const char * key;
            switch (event.type) {
                case SDL_QUIT:
                running = false;
                break;

                case SDL_KEYDOWN:
                key = SDL_GetKeyName(event.key.keysym.sym);
                if (strcmp(key, "Escape") == 0) {
                    running = false;
                } else if (strcmp(key, "Space") == 0) {
                    // Signal next blend cycle
                    frameCount = 0;
                } 
                break;

                case SDL_KEYUP:
                break;

                case SDL_MOUSEMOTION: {
                if (mousedown) {
                    int mouse_x = event.motion.xrel;
                    int mouse_y = event.motion.yrel;
                    //printf("%d %d\n", mouse_x, mouse_y);
                    cam.addOrient(-CAM_SENSITIVITY * mouse_y, CAM_SENSITIVITY * mouse_x);
                    kernel.setArg(CL_INPUT_CAM_UP, glmVec3ToCl(cam.up));
                    kernel.setArg(CL_INPUT_CAM_RIGHT, glmVec3ToCl(cam.right));
                    kernel.setArg(CL_INPUT_CAM_DIR, glmVec3ToCl(cam.dir));
                    frameCount = 0;
                }
                break;
                }

                case SDL_MOUSEBUTTONDOWN: {
                    if (mousedown) SDL_SetRelativeMouseMode(SDL_FALSE);
                    else SDL_SetRelativeMouseMode(SDL_TRUE);
                    mousedown = !mousedown;
                    break;
                }

                default:
                break;
            }
        }
        const Uint8 *keystates = SDL_GetKeyboardState(NULL);
        float forward = 0.0f, sideways = 0.0f, vertical = 0.0f;
        bool moved = false;
        if (keystates[SDL_SCANCODE_W]) {
            forward += CAM_SPEED * (float) tdiff / 1000.0f;
            moved = true;
        }
        if (keystates[SDL_SCANCODE_S]) {
            forward -= CAM_SPEED * (float) tdiff / 1000.0f;
            moved = true;
        }
        if (keystates[SDL_SCANCODE_A]) {
            sideways += CAM_SPEED * (float) tdiff / 1000.0f;
            moved = true;
        }
        if (keystates[SDL_SCANCODE_D]) {
            sideways -= CAM_SPEED * (float) tdiff / 1000.0f;
            moved = true;
        }
        if (keystates[SDL_SCANCODE_LSHIFT]) {
            vertical += CAM_SPEED * (float) tdiff / 1000.0f;
            moved = true;
        }
        if (keystates[SDL_SCANCODE_RSHIFT]) {
            vertical  -= CAM_SPEED * (float) tdiff / 1000.0f;
            moved = true;
        }
        if (moved) {
            cam.moveDirection(forward, sideways, vertical);
            frameCount = 0;
            kernel.setArg(CL_INPUT_CAM_POS, glmVec3ToCl(cam.pos));
        }


        kernel.setArg(CL_INPUT_FRAMECOUNT, frameCount++);

        // Clear screen
        SDL_UpdateTexture(texture, NULL, pixelBuffer.pixels,  pixelBuffer.width * sizeof(cl_uint));
        SDL_RenderClear(renderer);

        // Draw
        // launch the kernel
        queue.enqueueNDRangeKernel(kernel, 0, global_work_size, local_work_size);
        queue.finish();

        // read and copy OpenCL output to pixel buffer
        queue.enqueueReadBuffer(cl_pixels, CL_TRUE, 0, WINDOW_WIDTH * WINDOW_HEIGHT * sizeof(cl_uint), pixelBuffer.pixels);

        SDL_RenderCopy(renderer, texture, NULL, NULL);

        // Show what was drawn
        SDL_RenderPresent(renderer);
        // Show the fps and update the timestamps
        gettimeofday(&timestamp, NULL);
        msf = timestamp.tv_sec * 1000000 + timestamp.tv_usec;
        tdiff = msf - msi;
#if 1
        printf("\r%10f FPS", (double) 1000000 / (double) tdiff); 
#endif
        msi = msf;

    }

    // Release resources
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    printf("\n");

    return 0;
}

