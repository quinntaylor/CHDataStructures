/*
 CHDataStructures.framework -- CHMutableArrayDeque.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHMutableArrayDeque.h"

@implementation CHMutableArrayDeque

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	else
		[array insertObject:anObject atIndex:0];
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) firstObject {
	@try {
		return [array objectAtIndex:0];
	}
	@catch (NSException *exception) {}
	return nil;
}

- (BOOL) isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHDeque)])
		return [self isEqualToDeque:otherObject];
	else
		return NO;
}

- (BOOL) isEqualToDeque:(id<CHDeque>)otherDeque {
	return collectionsAreEqual(self, otherDeque);
}

- (id) lastObject {
	return [array lastObject];
}

- (void) removeFirstObject {
	@try {
		[array removeObjectAtIndex:0];
	}
	@catch (NSException *exception) {}
}

- (void) removeLastObject {
	@try {
		[array removeLastObject];	
	}
	@catch (NSException *exception) {}
}

@end
