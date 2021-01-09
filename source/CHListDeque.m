//
//  CHListDeque.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <CHDataStructures/CHListDeque.h>
#import <CHDataStructures/CHDoublyLinkedList.h>

@implementation CHListDeque

- (id<CHLinkedList>)_newList {
	return [[CHDoublyLinkedList alloc] init];
}

- (void)prependObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	[list prependObject:anObject];
}

- (void)appendObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	[list addObject:anObject];
}

- (id)firstObject {
	return [list firstObject];
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHDeque)]) {
		return [self isEqualToDeque:otherObject];
	} else {
		return NO;
	}
}

- (BOOL)isEqualToDeque:(id<CHDeque>)otherDeque {
	return CHCollectionsAreEqual(self, otherDeque);
}

- (id)lastObject {
	return [list lastObject];
}

- (void)removeFirstObject {
	[list removeFirstObject];
}

- (void)removeLastObject {
	[list removeLastObject];
}

- (NSEnumerator *)reverseObjectEnumerator {
	return [(CHDoublyLinkedList *)list reverseObjectEnumerator];
}

@end
