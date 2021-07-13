#include "window.h"
#include <stdlib.h>
#include <time.h>

Window::Window() : width(0), height(0) {}

Window::Window(const unsigned short width, const unsigned short height, SDL_PixelFormatEnum pixelFormat) 
: width(width), height(height), pixelFormat(pixelFormat) {
    pixels = new unsigned int[width * height];
    clear();
}

Window::~Window() {
    delete [] pixels;
}

// May be broken, use with cuation
void Window::setPixel(unsigned x, unsigned y, glm::ivec3 rgb) {
    unsigned int color = 0;
    color |= (rgb.x << 24);
    color |= (rgb.y << 16);
    color |= (rgb.z << 8);
    pixels[y*width+x] = color;
}

void Window::setPixel(unsigned x, unsigned y, glm::vec3 rgb) {
    setPixel(x, y, glm::ivec3(255.9999f * rgb));
}

void Window::clear() {
    memset(pixels, 0, width * height * sizeof(unsigned int));
}

void Window::savePPM() {
    char filepath[1024];
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);
    sprintf(filepath, "images/%d-%02d-%02d-%02d-%02d-%02d.ppm", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec);
    FILE* ppmfile = fopen(filepath, "w");

    if (ppmfile == NULL) {
        printf("Error saving image\n");
        return;
    }
    char buffer[1024];
    sprintf(buffer, "P6\n%d %d\n255\n", width, height);
    fwrite(buffer, 1, strlen(buffer), ppmfile);
    for (int i = 0; i < width * height; i++) {
        unsigned char color[3];
        memset(color, 0, 3);
        color[0] = (pixels[i] >> 24);
        color[1] = (pixels[i] >> 16);
        color[2] = (pixels[i] >> 8);
        fwrite(color, 1, 3, ppmfile);
    }
    fclose(ppmfile);
    printf("\nSaving image as %s\n", filepath);
}


/*
void init_sdl() {
    SDL_Init(SDL_INIT_VIDEO);
    // Make sure that sdl does not mess with compositor
    SDL_SetHint(SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0"); 
    SDL_Window *window = SDL_CreateWindow("R-Two", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_OPENGL);
    renderer = SDL_CreateRenderer
}*/

