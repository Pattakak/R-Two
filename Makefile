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
	$(CXX) $(CXXFLAGS) $^ -o rtwo

$(OBJ)/%.o: $(SRC)/%.cpp
	$(CC) -I$(SRC) -c $< -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) -I$(SRC) -c $< -o $@

.PHONY: clean
clean: 
	rm $(OBJ)/*
	rm rtwo

