/*
 CHListDeque.m
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

#import "CHListDeque.h"

/**
 This implementation uses a CHDoublyLinkedList, since a deque supports insertion and
 removal at both ends, and removing from the tail of a singly-linked list is an O(n)
 operation. The trade-off to this speed increase is marginally higher storage cost,
 and marginally slower operations due to handling the reverse links. This also allows
 for reverse enumeration of objects in the deque.
 */
@implementation CHListDeque

- (id) init {
	if ([super init] == nil) return nil;
	list = [[CHDoublyLinkedList alloc] init];
	return self;
}

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list prependObject:anObject];
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list appendObject:anObject];
}

- (id) firstObject {
	return [list firstObject];
}

- (id) lastObject {
	return [list lastObject];
}

- (void) removeFirstObject {
	[list removeFirstObject];
}

- (void) removeLastObject {
	[list removeLastObject];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [(CHDoublyLinkedList*)list reverseObjectEnumerator];
}

@end
