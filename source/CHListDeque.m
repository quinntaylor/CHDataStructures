/*
 CHDataStructures.framework -- CHListDeque.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHListDeque.h"

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
