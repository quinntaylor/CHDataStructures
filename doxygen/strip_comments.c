#import <getopt.h>
#import <stdio.h>

typedef enum {
	SOURCE,
	STRING_LITERAL,
	CHAR_LITERAL,
	SLASH,
	SLASH_STAR,
	COMMENT_LINE,
	COMMENT_CSTYLE,
	COMMENT_JAVADOC,
	COMMENT_HEADERDOC
} State;

#define YES 1
#define NO  0

int main (int argc, const char *argv[]) {
	char *inputFile = 0;
	int stripLine = 0, stripCStyle = 0, stripJavadoc = 0, stripHeaderDoc = 0;
	unsigned errors = 0;
	
#pragma mark Process command-line options
	
	static struct option long_options[] = {
		{"line",      no_argument,       0, 'L'},
		{"cstyle",    no_argument,       0, 'C'},
		{"javadoc",   no_argument,       0, 'J'},
		{"headerdoc", no_argument,       0, 'H'},
		{"input",     required_argument, 0, 'i'},
		{"help",      no_argument,       0, 'h'},
		{0, 0, 0, 0}
	};
	
	int option_index = 0; // getopt_long() stores the option index here
	char option; // the short character for the last processed option
	while ((option = getopt_long(argc, (char**)argv, "LCJHi:h",
	                             long_options, &option_index)) != -1)
	{
		if (option == 'L')
			stripLine = YES;
		else if (option == 'C')
			stripCStyle = YES;
		else if (option == 'J')
			stripJavadoc = YES;
		else if (option == 'H')
			stripHeaderDoc = YES;
		else if (option == 'i')
			inputFile = optarg;
		else if (option == 'h')
			errors++; // Will cause help to print, then exit before processing
	}
	
#pragma mark Handle any options errors
	
	if (stripLine + stripCStyle + stripJavadoc + stripHeaderDoc == 0) {
		printf("  ERROR: Must specify at least one comment style.\n");
		printf("         (Options include -L, -C, -J, and -H.)\n");
		errors++;
	}
	if (inputFile == NULL) {
		printf("  ERROR: Must specify input file to process.\n");
		errors++;
	}
	if (optind < argc) {
		printf("  ERROR: Invalid non-option arguments:");
		while (optind < argc)
			printf(" `%s'", argv[optind++]);
		printf("\n");
		errors++;
	}

	if (errors > 0) {
		printf("\nusage: StripComments [options] --input file\n\n");
		printf("  Utility for stripping comments from source code. An input\n");
		printf("  file must be specified. If an output file is not specified,\n");
		printf("  output is printed to standard output.\n\n");
		printf("Valid options:\n");
		printf("  -L [--line]      : Strip single-line comments    //...\\n\n");
		printf("  -C [--cstyle]    : Strip C-style comments        /*...*/\n");
		printf("  -J [--javadoc]   : Strip Javadoc comments        /**...*/\n");
		printf("  -H [--headerdoc] : Strip HeaderDoc comments      /*!...*/\n");
		printf("  -i [--input]     : File from which to read input\n");
		printf("\n");
		return -1;
	}	
	
#pragma mark Strip comments from input
	
	FILE *file = fopen(inputFile, "r");
	
	char prevChar = '\n', thisChar = '\n';
	State currentState = SOURCE;
	
	while ((thisChar = fgetc(file)) != EOF) {
		
		switch (currentState) {
			case SOURCE:
				if (thisChar == '/')
					currentState = SLASH;
				else {
					if (thisChar == '"')
						currentState = STRING_LITERAL;
					else if (thisChar == '\'')
						currentState = CHAR_LITERAL;
					printf("%C", thisChar);
				}
				break;
			
			case STRING_LITERAL:
				if (thisChar == '"' && prevChar != '\\')  // Account for \" char
					currentState = SOURCE;
				printf("%C", thisChar);
				break;
				
			case CHAR_LITERAL:
				if (thisChar == '\'' && prevChar != '\\') // Account for \' char
					currentState = SOURCE;
				printf("%C", thisChar);
				break;

			case SLASH:
				if (thisChar == '*') {
					currentState = SLASH_STAR;
				}
				else if (thisChar == '/') {
					if (!stripLine)
						printf("//");
					currentState = COMMENT_LINE;
				}
				else {
					printf("/%C", thisChar);
					currentState = SOURCE;
				}
				break;
				
			case SLASH_STAR:
				if (thisChar == '*') {
					if (!stripJavadoc)
						printf("/**");
					currentState = COMMENT_JAVADOC;
				}
				else if (thisChar == '!') {
					if (!stripHeaderDoc)
						printf("/*!");
					currentState = COMMENT_HEADERDOC;
				}
				else {
					if (!stripCStyle)
						printf("/*%C", thisChar);
					currentState = COMMENT_CSTYLE;
					thisChar = 0;  // Prevents counting "/*/" as a block comment
				}
				break;
				
			case COMMENT_LINE:
				if (thisChar == '\n') {
					printf("\n");
					currentState = SOURCE;					
				}
				if (!stripLine)
					printf("%C", thisChar);
				break;
				
			case COMMENT_CSTYLE:
				if (!stripCStyle)
					printf("%C", thisChar);
				if (prevChar == '*' && thisChar == '/')
					currentState = SOURCE;
				break;
				
			case COMMENT_JAVADOC:
				if (!stripJavadoc)
					printf("%C", thisChar);
				if (prevChar == '*' && thisChar == '/')
					currentState = SOURCE;
				break;
				
			case COMMENT_HEADERDOC:
				if (!stripHeaderDoc)
					printf("%C", thisChar);
				if (prevChar == '*' && thisChar == '/')
					currentState = SOURCE;
				break;
				
		}
		prevChar = thisChar;

	}
	if (thisChar != '\n')
		printf("\n", thisChar);
	
	fclose(file);
    return 0;
}
