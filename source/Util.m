/*
 Util.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import "Util.h"

void CHIndexOutOfRangeException(Class aClass, SEL method,
                                NSUInteger index, NSUInteger elements) {
	[NSException raise:NSRangeException
	            format:@"[%@ %s] -- Index (%d) out of range (0-%d).",
	                   aClass, sel_getName(method), index, elements-1];
}

void CHInvalidArgumentException(Class aClass, SEL method, NSString *string) {
	[NSException raise:NSInternalInconsistencyException
	            format:@"[%@ %s] -- %@",
	                   aClass, sel_getName(method), string];
}

void CHNilArgumentException(Class aClass, SEL method) {
	CHInvalidArgumentException(aClass, method, @"Invalid nil argument.");
}

void CHMutatedCollectionException(Class aClass, SEL method) {
	[NSException raise:NSGenericException
	            format:@"[%@ %s] -- Collection was mutated during enumeration.",
	                   aClass, sel_getName(method)];
}

void CHUnsupportedOperationException(Class aClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
	            format:@"[%@ %s] -- Unsupported operation.",
	                   aClass, sel_getName(method)];
}

void CHQuietLog(NSString *format, ...) {
	if (format == nil) {
		printf("(null)\n");
		return;
	}
	// Get a reference to the arguments that follow the format parameter
	va_list argList;
	va_start(argList, format);
	// Do format string argument substitution, reinstate %% escapes, then print
	NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
	printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%"
											 withString:@"%%%%"] UTF8String]);
	[s release];
	va_end(argList);
}
