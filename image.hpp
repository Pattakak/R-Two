#pragma once

#include <cfloat>
#include <stdio.h>
#include <string.h>
#include <glm/glm.hpp>

class Image{
    public:
        unsigned short width, height;
        unsigned int* pixels;
        float* zBuffer;

        Image() : width(0), height(0) {}
        Image(const unsigned short width, const unsigned short height) :width(width), height(height) {

            pixels = new unsigned int[width * height];
            zBuffer = new float[width * height];
            clear();
        }

        ~Image(){
            delete[] pixels;
            delete[] zBuffer;
        }

        virtual void setPixel(unsigned int x, unsigned int y, glm::ivec3 RGB, float zDepth){

            unsigned int color = 0;

            color |= RGB.x;
            color |= (RGB.y << 8);
            color |= (RGB.z << 16);


            unsigned int idx = y * width + x; 


            if (zDepth > zBuffer[idx]) {
                pixels[idx] = color;
                zBuffer[idx] = zDepth;
            } 
        }


        virtual void clear() {

            memset(pixels, 0, width * height * sizeof(unsigned int));

            //can't use memset for floats
            for(int i = 0; i < (width * height); i++) {
                zBuffer[i] = -FLT_MAX;
            }

        }

};

