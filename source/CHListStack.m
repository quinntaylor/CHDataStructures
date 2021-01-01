/*
 CHDataStructures.framework -- CHListStack.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 */

#import <CHDataStructures/CHListStack.h>
#import <CHDataStructures/CHSinglyLinkedList.h>

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than using a CHDoublyLinkedList, and requires a little less memory. Also, since it's a stack, it's unlikely that there is any need to enumerate over the object from bottom to top.
 */
@implementation CHListStack

- (instancetype)init {
	if ((self = [super init]) == nil) return nil;
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

- (instancetype)initWithArray:(NSArray *)anArray {
	if ([self init] == nil) return nil;
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
	return collectionsAreEqual(self, otherStack);
}

- (void)popObject {
	[list removeFirstObject];
}

- (void)pushObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list prependObject:anObject];
}

- (id)topObject {
	return [list firstObject];
}

@end
