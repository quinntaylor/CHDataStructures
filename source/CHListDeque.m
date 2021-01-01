/*
 CHDataStructures.framework -- CHListDeque.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHListDeque.h>
#import <CHDataStructures/CHDoublyLinkedList.h>

@implementation CHListDeque

- (instancetype)init {
	if ((self = [super init]) == nil) return nil;
	list = [[CHDoublyLinkedList alloc] init];
	return self;
}

- (void)prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list prependObject:anObject];
}

- (void)appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list addObject:anObject];
}

- (id)firstObject {
	return [list firstObject];
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHDeque)])
		return [self isEqualToDeque:otherObject];
	else
		return NO;
}

- (BOOL)isEqualToDeque:(id<CHDeque>)otherDeque {
	return collectionsAreEqual(self, otherDeque);
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
