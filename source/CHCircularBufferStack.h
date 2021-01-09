//
//  CHCircularBufferStack.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHStack.h>
#import <CHDataStructures/CHCircularBuffer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @file CHCircularBufferStack.h
 A simple CHStack implemented using a CHCircularBuffer.
 */

/**
 A simple CHStack implemented using a CHCircularBuffer.
 */
@interface CHCircularBufferStack : CHCircularBuffer <CHStack>

@end

NS_ASSUME_NONNULL_END
