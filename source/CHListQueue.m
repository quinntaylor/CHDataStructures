/*
 CHDataStructures.framework -- CHListQueue.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 */

#import <CHDataStructures/CHListQueue.h>
#import <CHDataStructures/CHSinglyLinkedList.h>

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than
 using a CHDoublyLinkedList, and requires a little less memory. Also, since it's
 a queue, it's unlikely that there is any need to enumerate over the object from
 back to front.
 */
@implementation CHListQueue

- (id<CHLinkedList>)_createList {
	return [[CHSinglyLinkedList alloc] init];
}

- (void)addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list addObject:anObject];
}

- (id)firstObject {
	return [list firstObject];
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHQueue)])
		return [self isEqualToQueue:otherObject];
	else
		return NO;
}

- (BOOL)isEqualToQueue:(id<CHQueue>)otherQueue {
	return collectionsAreEqual(self, otherQueue);
}

- (id)lastObject {
	return [list lastObject];
}

- (void)removeFirstObject {
	[list removeFirstObject];
}

@end
