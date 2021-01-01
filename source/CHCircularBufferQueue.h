/*
 CHDataStructures.framework -- CHCircularBufferQueue.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHQueue.h>
#import <CHDataStructures/CHCircularBuffer.h>

/**
 @file CHCircularBufferQueue.h
 A simple CHQueue implemented using a CHCircularBuffer.
 */

/**
 A simple CHQueue implemented using a CHCircularBuffer.
 */
@interface CHCircularBufferQueue : CHCircularBuffer <CHQueue>

@end
