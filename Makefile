SRC := src
OBJ := build

SOURCES := $(wildcard $(SRC)/*.cpp)
CFILES := $(wildcard $(SRC)/*.c)
OBJS := $(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(SOURCES))

CXX := g++
CXXFLAGS := -Wall -g
LD := g++
LDFLAGS := 
LIBS := -lSDL2 

all: $(OBJS) 
	$(LD) $(LDFLAGS) $^ -o rtwo $(LIBS) 

$(OBJ)/%.o: $(SRC)/%.cpp
	$(CC) $(CXXFLAGS) -I$(SRC) -c $< -o $@

$(OBJ)/%.o: $(SRC)/%.c
	$(CC) $(CXXFLAGS) -I$(SRC) -c $< -o $@

.PHONY: clean
clean: 
	rm $(OBJ)/*
	rm rtwo

