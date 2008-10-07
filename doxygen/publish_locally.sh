#! /bin/sh

cd ..
doxygen doxygen/Doxyfile
mkdir -p /Library/WebServer/Documents/dsf
cp -R docs/ /Library/WebServer/Documents/dsf/