/*
 Util.c
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

void CHIndexOutOfRangeException(Class theClass, SEL method,
                                       NSUInteger index, NSUInteger elements) {
	[NSException raise:NSRangeException
	            format:@"[%@ %s] -- Index (%d) out of range (0-%d).",
	                   theClass, sel_getName(method), index, elements-1];
}

void CHNilArgumentException(Class theClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
	            format:@"[%@ %s] -- Invalid nil argument.",
	                   theClass, sel_getName(method)];
}

void CHMutatedCollectionException(Class theClass, SEL method) {
	[NSException raise:NSGenericException
	            format:@"[%@ %s] -- Collection was mutated while being enumerated.",
	                   theClass, sel_getName(method)];
}

int CHUnsupportedOperationException(Class theClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
	            format:@"[%@ %s] -- Unsupported operation.",
	                   theClass, sel_getName(method)];
	return 0;
}

void CHQuietLog(NSString *format, ...) {
    if (format == nil) {
        printf("nil\n");
        return;
    }
    // Get a reference to the arguments that follow the format parameter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSString *s = [[NSString alloc] initWithFormat:format arguments:argList];
    printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%"
                                                 withString:@"%%%%"] UTF8String]);
	[s release];
    va_end(argList);
}
