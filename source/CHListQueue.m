//
//  CHListQueue.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//  Copyright © 2002, Phillip Morelock
//

#import <CHDataStructures/CHListQueue.h>
#import <CHDataStructures/CHSinglyLinkedList.h>

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than
 using a CHDoublyLinkedList, and requires a little less memory. Also, since it's
 a queue, it's unlikely that there is any need to enumerate over the object from
 back to front.
 */
@implementation CHListQueue

- (id<CHLinkedList>)_newList {
	return [[CHSinglyLinkedList alloc] init];
}

- (void)addObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
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
	return CHCollectionsAreEqual(self, otherQueue);
}

- (id)lastObject {
	return [list lastObject];
}

- (void)removeFirstObject {
	[list removeFirstObject];
}

@end
