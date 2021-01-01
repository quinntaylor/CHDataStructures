/*
 CHDataStructures.framework -- CHCircularBufferStack.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

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
