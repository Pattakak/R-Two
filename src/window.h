#ifndef WINDOW_H
#define WINDOW_H

#include <SDL2/SDL.h>
#include <cfloat>
#include <stdio.h>
#include <string.h>
#include <glm/glm.hpp>
#include <SDL2/SDL.h>

// Window dimensions
static const int WINDOW_WIDTH = 1280;
static const int WINDOW_HEIGHT = 720;

typedef enum {
    KEY_DEF,
    KEY_W,
    KEY_A,
    KEY_S,
    KEY_D,
    KEY_SPACE,
    KEY_SHIFT,
    KEY_NUM_KEYS // Make sure this is the last 
} keypress_t;

class Window {
    public:
    unsigned short width, height;
    unsigned int* pixels;
    SDL_PixelFormatEnum pixelFormat;

    Window();
    Window(const unsigned short width, const unsigned short height, SDL_PixelFormatEnum pixelFormat = SDL_PIXELFORMAT_RGBA8888); 

    ~Window();

    virtual void setPixel(unsigned x, unsigned y, glm::ivec3 rgb);
    virtual void setPixel(unsigned x, unsigned y, glm::vec3 rgb);
    virtual void clear();
    void savePPM();

};




#endif
