all:
	mkdir -p build
	clang++ -std=c++11 -Wall -pedantic main.cpp -o build/main -lSDL2