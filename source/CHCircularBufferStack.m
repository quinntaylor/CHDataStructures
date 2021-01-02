/*
 CHDataStructures.framework -- CHCircularBufferStack.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

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
	return collectionsAreEqual(self, otherStack);
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
