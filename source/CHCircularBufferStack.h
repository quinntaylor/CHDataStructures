//
//  CHCircularBufferStack.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHStack.h>
#import <CHDataStructures/CHCircularBuffer.h>

/**
 @file CHCircularBufferStack.h
 A simple CHStack implemented using a CHCircularBuffer.
 */

/**
 A simple CHStack implemented using a CHCircularBuffer.
 */
@interface CHCircularBufferStack : CHCircularBuffer <CHStack>

@end
