#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <SDL2/SDL.h>
#include <glm/glm.hpp>
#include "pixelBuffer.hpp"

// Get a random number from 0 to 255
int randInt(int rmin, int rmax) {
    return rand() % rmax + rmin;
}
    
// Window dimensions
static const int width = 800;
static const int height = 600;

int main(int argc, char **argv) {
    // Initialize the random number generator
    srand((unsigned int)time(NULL));
    
    // Initialize SDL
    SDL_Init(SDL_INIT_VIDEO);

    // Create an SDL window
    SDL_Window *window = SDL_CreateWindow("Hello, SDL2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_OPENGL);

    // Create a renderer (accelerated and in sync with the display refresh rate)
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);    

    PixelBuffer pixelBuffer = PixelBuffer(width, height);
    
    SDL_Texture * texture = SDL_CreateTexture(renderer,
            pixelBuffer.pixelFormat, SDL_TEXTUREACCESS_STREAMING, width, height);

    // Initial renderer color
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);


    bool running = true;
    SDL_Event event;
    while(running) {
        // Process events
        while(SDL_PollEvent(&event)) {
            if(event.type == SDL_QUIT) {
                running = false;
            } else if(event.type == SDL_KEYDOWN) {
                const char *key = SDL_GetKeyName(event.key.keysym.sym);
                if(strcmp(key, "C") == 0) {
                    SDL_SetRenderDrawColor(renderer, randInt(0, 255), randInt(0, 255), randInt(0, 255), 255);
                }                    
            }
        }

        SDL_UpdateTexture(texture, NULL, pixelBuffer.pixels,  width * sizeof(Uint32));
        pixelBuffer.clear();

        // Clear screen
        SDL_RenderClear(renderer);
        pixelBuffer.setPixel(width / 2, height / 2, glm::vec3(0, 1, 0));
        SDL_RenderCopy(renderer, texture, NULL, NULL);

        // Show what was drawn
        SDL_RenderPresent(renderer);
    }

    // Release resources
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}

