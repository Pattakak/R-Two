#pragma once

#include <SDL2/SDL.h>
#include <cfloat>
#include <stdio.h>
#include <string.h>
#include <glm/glm.hpp>

class PixelBuffer {
    public:
        unsigned short width, height;
        unsigned int* pixels;
        SDL_PixelFormatEnum pixelFormat;

        PixelBuffer() : width(0), height(0) {}
        PixelBuffer(const unsigned short width, const unsigned short height, SDL_PixelFormatEnum pixelFormat = SDL_PIXELFORMAT_RGBA8888) 
        : width(width), height(height), pixelFormat(pixelFormat) {
            pixels = new unsigned int[width * height];
            clear();
        }

        ~PixelBuffer(){
            delete[] pixels;
        }

        virtual void setPixel(unsigned x, unsigned y, glm::ivec3 rgb) {
            unsigned int color = 0;
            color |= rgb.x;
            color |= (rgb.y << 8);
            color |= (rgb.z << 16);
            pixels[y*width+x] = color;
        }

        virtual void setPixel(unsigned x, unsigned y, glm::vec3 rgb) {setPixel(x,y,glm::ivec3(255.99999f*rgb));}

        virtual void clear() {
            memset(pixels, 0, width * height * sizeof(unsigned int));
        }
};