#! /bin/sh

cd ..
doxygen doxygen/Doxyfile
mkdir -p /Library/WebServer/Documents/CHDataStructures
cp -R docs/ /Library/WebServer/Documents/CHDataStructures/
