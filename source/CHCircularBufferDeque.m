/*
 CHDataStructures.framework -- CHCircularBufferDeque.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHCircularBufferDeque.h>

@implementation CHCircularBufferDeque

- (void)prependObject:(id)anObject {
	[self insertObject:anObject atIndex:0];
}

- (void)appendObject:(id)anObject {
	[self insertObject:anObject atIndex:count];	
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

@end
