/*
 CHDataStructures.framework -- CHSortedDictionary.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableDictionary.h"
#import "CHSortedSet.h"

/** @todo Implement and document CHSortedDictionary */
@interface CHSortedDictionary : CHLockableDictionary {
	id<CHSortedSet> sortedKeys;
}

#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns the minimum key in the receiver, according to natural sorted order.
 
 @return The minimum key in the receiver, or @c nil if the receiver is empty.
 
 @see lastKey
 @see removeObjectForFirstKey
 */
- (id) firstKey;

/**
 Returns the maximum key in the receiver, according to natural sorted order.
 
 @return The maximum key in the receiver, or @c nil if the receiver is empty.
 
 @see firstKey
 @see removeObjectForLastKey
 */
- (id) lastKey;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{
/**
 Remove the minimum object from the receiver, according to natural sorted order.
 
 @see firstKey
 @see removeObjectForKey:
 @see removeObjectForLastKey
 */
- (void) removeObjectForFirstKey;

/**
 Remove the maximum object from the receiver, according to natural sorted order.
 
 @see lastKey
 @see removeObjectForKey:
 @see removeObjectForFirstKey
 */
- (void) removeObjectForLastKey;

// @}
@end
