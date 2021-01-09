//
//  CHCircularBufferQueue.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHQueue.h>
#import <CHDataStructures/CHCircularBuffer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @file CHCircularBufferQueue.h
 A simple CHQueue implemented using a CHCircularBuffer.
 */

/**
 A simple CHQueue implemented using a CHCircularBuffer.
 */
@interface CHCircularBufferQueue : CHCircularBuffer <CHQueue>

@end

NS_ASSUME_NONNULL_END
