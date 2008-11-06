#! /usr/bin/python

from optparse import OptionParser
import os.path
import sys

parser = OptionParser()
parser.add_option("-L", "--line", dest="stripLine",
                  action="store_true", default=False,
                  help="strip single-line comments   //...\\n")
parser.add_option("-C", "--cstyle", dest="stripCStyle",
                  action="store_true", default=False,
                  help="strip C-style comments       /*...*/")
parser.add_option("-J", "--javadoc", dest="stripJavadoc",
                  action="store_true", default=False,
                  help="strip Javadoc comments       /**...*/")
parser.add_option("-H", "--headerdoc", dest="stripHeaderDoc",
                  action="store_true", default=False,
                  help="strip HeaderDoc comments      /*!...*/")
parser.add_option("--input", dest="inputFile", default="",
                  help="file from which to read input")
(options, args) = parser.parse_args()

error = False
if len(args) != 0:
	print "ERROR: Invalid non-option arguments:"
	for arg in args:
		print "  "+arg
	error = True
if not options.stripLine and not options.stripCStyle and \
   not options.stripJavadoc and not options.stripHeaderDoc:
	print "ERROR: Please specify at least one comment style to strip."
	error = True
if options.inputFile == "":
	print "ERROR: Must specify input file to process using '--input'."
	error = True
elif os.path.exists(options.inputFile) == False:
	print "ERROR: Specified input file does not exist!"
	error = True
else:
	file = open(options.inputFile, "r")
if error == True:
	sys.exit()

(SOURCE, STRING_LITERAL, CHAR_LITERAL, SLASH, SLASH_STAR, COMMENT_LINE,
COMMENT_CSTYLE, COMMENT_JAVADOC, COMMENT_HEADERDOC) = range(9) #state constants

state = SOURCE
thisChar = '\n'
while (1):
	prevChar = thisChar
	thisChar = file.read(1)
	if not thisChar:
		break
	
	if state == SOURCE:
		if thisChar == '/':
			state = SLASH
		else:
			if thisChar == '"':
				state = STRING_LITERAL
			elif thisChar == '\'':
				state = CHAR_LITERAL
			sys.stdout.write(thisChar)
	
	elif state == STRING_LITERAL:
		if thisChar == '"' and prevChar != '\\':
			state = SOURCE
		sys.stdout.write(thisChar)
				
	elif state == CHAR_LITERAL:
		if thisChar == '\'' and prevChar != '\\':
			state = SOURCE
		sys.stdout.write(thisChar)

	elif state == SLASH:
		if thisChar == '*':
			state = SLASH_STAR
		elif thisChar == '/':
			if not options.stripLine:
				sys.stdout.write("//")
			state = COMMENT_LINE
		else:
			sys.stdout.write("/")
			sys.stdout.write(thisChar)
			state = SOURCE

	elif state == SLASH_STAR:
		if thisChar == '*':
			if not options.stripJavadoc:
				sys.stdout.write("/**")
			state = COMMENT_JAVADOC
		elif thisChar == '!':
			if not options.stripHeaderDoc:
				sys.stdout.write("/*!")
			state = COMMENT_HEADERDOC
		else:
			if not options.stripCStyle:
				sys.stdout.write("/*")
				sys.stdout.write(thisChar)
			state = COMMENT_CSTYLE
			thisChar = 0
			# Prevents counting "/*/" as a C-style block comment

	elif state == COMMENT_LINE:
		if thisChar == '\n':
			sys.stdout.write("\n")
			state = SOURCE					
		if not options.stripLine:
			sys.stdout.write(thisChar)

	elif state == COMMENT_CSTYLE:
		if not options.stripCStyle:
			sys.stdout.write(thisChar)
		if prevChar == '*' and thisChar == '/':
			state = SOURCE

	elif state == COMMENT_JAVADOC:
		if not options.stripJavadoc:
			sys.stdout.write(thisChar)
		if prevChar == '*' and thisChar == '/':
			state = SOURCE
		
	elif state == COMMENT_HEADERDOC:
		if not options.stripHeaderDoc:
			sys.stdout.write(thisChar)
		if prevChar == '*' and thisChar == '/':
			state = SOURCE

file.close()
