//
//  CHCircularBufferQueue.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHCircularBufferQueue.h>

@implementation CHCircularBufferQueue

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHQueue)])
		return [self isEqualToQueue:otherObject];
	else
		return NO;
}

- (BOOL)isEqualToQueue:(id<CHQueue>)otherQueue {
	return CHCollectionsAreEqual(self, otherQueue);
}

@end
