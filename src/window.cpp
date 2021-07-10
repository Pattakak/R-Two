#include "window.h"

Window::Window() : width(0), height(0) {}

Window::Window(const unsigned short width, const unsigned short height, SDL_PixelFormatEnum pixelFormat) 
: width(width), height(height), pixelFormat(pixelFormat) {
    pixels = new unsigned int[width * height];
    clear();
}

Window::~Window() {
    delete [] pixels;
}

void Window::setPixel(unsigned x, unsigned y, glm::ivec3 rgb) {
    unsigned int color = 0;
    color |= rgb.x;
    color |= (rgb.y << 8);
    color |= (rgb.z << 16);
    pixels[y*width+x] = color;
}

void Window::setPixel(unsigned x, unsigned y, glm::vec3 rgb) {
    setPixel(x, y, glm::ivec3(255.9999f * rgb));
}

void Window::clear() {
    memset(pixels, 0, width * height * sizeof(unsigned int));
}


/*
void init_sdl() {
    SDL_Init(SDL_INIT_VIDEO);
    // Make sure that sdl does not mess with compositor
    SDL_SetHint(SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0"); 
    SDL_Window *window = SDL_CreateWindow("R-Two", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_OPENGL);
    renderer = SDL_CreateRenderer
}*/

