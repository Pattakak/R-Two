SRC := src
OBJ := build

SOURCES := $(wildcard $(SRC)/*.cpp)
CFILES := $(wildcard $(SRC)/*.c)
OBJS := $(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(SOURCES))
OBJSOPT := $(patsubst $(SRC)/%.cpp, $(OBJ)/%-opt.o, $(SOURCES))

CXX := g++
CXXFLAGS := -Wall -g -std=c++14 -DCL_HPP_TARGET_OPENCL_VERSION=120 -DCL_HPP_MINIMUM_OPENCL_VERSION=120 -DRTWO_DEBUG
# Release C++ Flags
RCXXFLAGS := -O3 -std=c++14 -DCL_HPP_TARGET_OPENCL_VERSION=120 -DCL_HPP_MINIMUM_OPENCL_VERSION=120 -DRTWO_RELEASE
EXE := rtwo
REXE := rtwo-opt
LD := g++
LDFLAGS := 
LIBS := -lSDL2 -lOpenCL


.PHONY: linux
all linux $(EXE): $(OBJS) 
	$(LD) $(LDFLAGS) $^ -o $(EXE) $(LIBS) 

$(OBJ)/%.o: $(SRC)/%.cpp
	$(CC) $(CXXFLAGS) -I$(SRC) -c $< -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) $(CXXFLAGS) -I$(SRC) -c $< -o $@

.PHONY: release
$(REXE) release: $(OBJSOPT)
	$(LD) $(LDFLAGS) $^ -o $(REXE) $(LIBS) 

$(OBJ)/%-opt.o: $(SRC)/%.cpp
	$(CC) $(RCXXFLAGS) -I$(SRC) -c $< -o $@

$(OBJ)/%-opt.o: $(SRC)/%.c
	$(CC) $(RCXXFLAGS) -I$(SRC) -c $< -o $@


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

