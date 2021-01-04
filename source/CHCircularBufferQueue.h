//
//  CHCircularBufferQueue.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

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
