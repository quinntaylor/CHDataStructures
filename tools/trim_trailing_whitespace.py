#! /usr/bin/python

import os.path
import sys

for arg in sys.argv[1:]: # skip this filename
	file = open(arg, "r")
	stripped = '\n'.join([line.rstrip(' \t\n') for line in file.readlines()])
	stripped = stripped.replace("\n\n\n\n", "\n\n").replace("\n\n\n", "\n\n")
	file.close()

	file = open(arg, "w")
	file.write(stripped);
	file.close()