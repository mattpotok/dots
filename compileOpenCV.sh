#!/bin/bash

echo "Compiling $1"

g++ -ggdb `pkg-config --cflags opencv` -o `basename $1 .cpp` $1 `pkg-config --libs opencv`;

echo "Output file => ${1%.*}"
