//  CHListDeque.m
//  CHDataStructures.framework

/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

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
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [[CHDoublyLinkedList alloc] init];
	return self;
}

// TODO: Add a custom -initWithList: to create a new CHDoublyLinkedList with contents

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	[list prependObject:anObject];
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
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
