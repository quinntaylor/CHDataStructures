/*
 CHDataStructures.framework -- CHCircularBufferStack.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHCircularBufferStack.h"

@implementation CHCircularBufferStack

// Overridden from parent class so objects are inserted in reverse order.
- (id) initWithArray:(NSArray*)anArray {
	NSUInteger capacity = 16;
	while (capacity <= [anArray count])
		capacity *= 2;
	if ([self initWithCapacity:capacity] == nil) return nil;
	// Add objects in reverse order so headIndex ends up at 0.
	headIndex = tailIndex = count = [anArray count];
	for (id anObject in anArray)
		array[--headIndex] = [anObject retain];
	return self;
}

- (void) pushObject:(id)anObject {
	[self prependObject:anObject];
}

- (id) topObject {
	return [self firstObject];
}

- (void) popObject {
	[self removeFirstObject];
}

@end
