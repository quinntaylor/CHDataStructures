/*
 CHDataStructures.framework -- CHCircularBufferQueue.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHCircularBufferQueue.h>

@implementation CHCircularBufferQueue

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHQueue)])
		return [self isEqualToQueue:otherObject];
	else
		return NO;
}

- (BOOL)isEqualToQueue:(id<CHQueue>)otherQueue {
	return collectionsAreEqual(self, otherQueue);
}

@end
