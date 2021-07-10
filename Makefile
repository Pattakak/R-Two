SRC := src
OBJ := build

SOURCES := $(wildcard $(SRC)/*.cpp)
CFILES := $(wildcard $(SRC)/*.c)
OBJS := $(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(SOURCES))
OBJSOPT := $(patsubst $(SRC)/%.cpp, $(OBJ)/%-opt.o, $(SOURCES))

CXX := g++
CXXFLAGS := -Wall -g -std=c++14 -DCL_HPP_TARGET_OPENCL_VERSION=120 -DCL_HPP_MINIMUM_OPENCL_VERSION=120 -DRTWO_DEBUG -Iinclude/
# Release C++ Flags
RCXXFLAGS := -O3 -std=c++14 -DCL_HPP_TARGET_OPENCL_VERSION=120 -DCL_HPP_MINIMUM_OPENCL_VERSION=120 -DRTWO_RELEASE -Iinclude/
EXE := rtwo
REXE := rtwo-opt
LD := g++
LDFLAGS := 
LIBS := -lSDL2
LIBOPENCL := -lOpenCL



$(EXE): $(OBJS) 
	$(LD) $(LDFLAGS) $^ -o $(EXE) $(LIBS) $(LIBOPENCL)

$(OBJ)/%.o: $(SRC)/%.cpp
	$(CC) $(CXXFLAGS) -c $< -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) $(CXXFLAGS) -c $< -o $@

.PHONY: release
$(REXE) release: $(OBJSOPT)
	$(LD) $(LDFLAGS) $^ -o $(REXE) $(LIBS) 

$(OBJ)/%-opt.o: $(SRC)/%.cpp
	$(CC) $(RCXXFLAGS) -c $< -o $@

$(OBJ)/%-opt.o: $(SRC)/%.c
	$(CC) $(RCXXFLAGS) -c $< -o $@


.PHONY: linux
linux all: $(EXE)

.PHONY: poopoo peepee
poopoo: LIBOPENCL := -framework OpenCL
poopoo: $(EXE)

peepee: LIBS += -lOpenCL 
peepee: $(EXE)

.PHONY: clean
clean: 
	rm $(OBJ)/*
	rm rtwo

