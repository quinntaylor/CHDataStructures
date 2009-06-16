/*
 CHDataStructures.framework -- CHLinkedDictionary.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableDictionary.h"
#import "CHQueue.h"

/** @todo Document CHLinkedDictionary */
@interface CHLinkedDictionary : CHLockableDictionary {
	id<CHQueue> insertionOrder;
}

#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns the first key in the receiver, according to insertion order.
 
 @return The first key in the receiver, or @c nil if the receiver is empty.
 
 @see lastKey
 @see removeObjectForFirstKey
 */
- (id) firstKey;

/**
 Returns the last key in the receiver, according to insertion order.
 
 @return The last key in the receiver, or @c nil if the receiver is empty.
 
 @see firstKey
 @see removeObjectForLastKey
 */
- (id) lastKey;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{
/**
 Remove the first key and object from the receiver, according to insertion order.
 
 @see firstKey
 @see removeObjectForKey:
 @see removeObjectForLastKey
 */
- (void) removeObjectForFirstKey;

/**
 Remove the last key and object from the receiver, according to insertion order.
 
 @see lastKey
 @see removeObjectForKey:
 @see removeObjectForFirstKey
 */
- (void) removeObjectForLastKey;

// @}
@end
