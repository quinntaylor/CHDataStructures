/*
 CHDataStructures.framework -- CHCircularBufferDeque.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHDeque.h>
#import <CHDataStructures/CHCircularBuffer.h>

/**
 @file CHCircularBufferDeque.h
 A simple CHDeque implemented using a CHCircularBuffer.
 */

/**
 A simple CHDeque implemented using a CHCircularBuffer.
 */
@interface CHCircularBufferDeque : CHCircularBuffer <CHDeque>

@end
