//
//  CHCircularBufferDeque.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

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
