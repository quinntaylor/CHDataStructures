/*
 CHListStack.m
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

#import "CHListStack.h"

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than
 using a CHDoublyLinkedList, and requires a little less memory. Also, since it's
 a stack, it's unlikely that there is any need to enumerate over the object from
 bottom to top.
 */
@implementation CHListStack

- (id) init {
	if ([super init] == nil) return nil;
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[list prependObject:anObject];
	return self;
}

- (void) pushObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	else
		[list prependObject:anObject];
}

- (id) topObject {
	return [list firstObject];
}

- (void) popObject {
	[list removeFirstObject];
}

@end
