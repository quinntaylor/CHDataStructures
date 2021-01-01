/*
 CHDataStructures.framework -- CHCircularBufferStack.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHCircularBufferStack.h>

@implementation CHCircularBufferStack

// Overridden from parent class to make the stack grow left from the last slot.
- (instancetype)initWithCapacity:(NSUInteger)capacity {
	if ((self = [super initWithCapacity:capacity]) == nil) return nil;
	// Initialize head and tail to last slot; avoids wrapping on second insert.
	headIndex = tailIndex = arrayCapacity - 1;
	return self;
}

// Overridden from parent class so objects are inserted in reverse order.
- (instancetype)initWithArray:(NSArray *)anArray {
	NSUInteger capacity = 16;
	while (capacity <= [anArray count])
		capacity *= 2;
	if ([self initWithCapacity:capacity] == nil) return nil;
	if ([anArray count] > 0) {
		headIndex = capacity; // Puts the bottom of the stack at the last slot.
		tailIndex = 0;
		count = [anArray count];
		for (id anObject in anArray) {
			array[--headIndex] = [anObject retain];
		}
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
