SRC := src
OBJ := build

SOURCES := $(wildcard $(SRC)/*.cpp)
CFILES := $(wildcard $(SRC)/*.c)
OBJS := $(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(SOURCES))

CXX := g++
CXXFLAGS := -Wall -g
LD := g++
LDFLAGS := -lSDL2

all: $(OBJS) 
	$(LD) $^ -o rtwo $(LDFLAGS) 

$(OBJ)/%.o: $(SRC)/%.cpp
	$(CC) -I$(SRC) -c $< -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) -I$(SRC) -c $< -o $@

poopoo:
	g++ src/main.cpp -o rtwo\
	 -framework OpenCL -lSDL2 \
	 -g -Wall -pedantic -std=c++14 \
	 -DCL_HPP_TARGET_OPENCL_VERSION=120 -DCL_HPP_MINIMUM_OPENCL_VERSION=120

peepee:
	g++ src/main.cpp -o rtwo\
	 -lOpenCL -lSDL2 \
	 -g -Wall -pedantic -std=c++14 \
	 -DCL_HPP_TARGET_OPENCL_VERSION=120 -DCL_HPP_MINIMUM_OPENCL_VERSION=120

.PHONY: clean
clean: 
	rm $(OBJ)/*
	rm rtwo

