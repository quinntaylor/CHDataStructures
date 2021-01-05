//
//  CHListStack.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//  Copyright © 2002, Phillip Morelock
//

#import <CHDataStructures/CHListStack.h>
#import <CHDataStructures/CHSinglyLinkedList.h>

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than using a CHDoublyLinkedList, and requires a little less memory. Also, since it's a stack, it's unlikely that there is any need to enumerate over the object from bottom to top.
 */
@implementation CHListStack

- (id<CHLinkedList>)_createList {
	return [[CHSinglyLinkedList alloc] init];
}

- (instancetype)initWithArray:(NSArray *)anArray {
	self = [super initWithArray:@[]]; // Don't let superclass add objects, we prepend them below.
	if (self == nil) return nil;
	for (id anObject in anArray) {
		[list prependObject:anObject];
	}
	return self;
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHStack)])
		return [self isEqualToStack:otherObject];
	else
		return NO;
}

- (BOOL)isEqualToStack:(id<CHStack>)otherStack {
	return CHCollectionsAreEqual(self, otherStack);
}

- (void)popObject {
	[list removeFirstObject];
}

- (void)pushObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	[list prependObject:anObject];
}

- (id)topObject {
	return [list firstObject];
}

@end
