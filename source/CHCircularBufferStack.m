//
//  CHCircularBufferStack.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHCircularBufferStack.h>

@implementation CHCircularBufferStack

// Overridden from parent class to make the stack grow left from the last slot.
- (BOOL)_insertBackToFront {
	return YES;
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
	[self removeFirstObject];
}

- (void)pushObject:(id)anObject {
	[self insertObject:anObject atIndex:0];
}

- (id)topObject {
	return [self firstObject];
}

@end
