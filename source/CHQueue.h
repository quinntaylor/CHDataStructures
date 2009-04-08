/*
 CHDataStructures.framework -- CHQueue.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHQueue.h
 
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a>
 protocol with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a>
 ("First In, First Out") operations.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a>
 protocol with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a>
 ("First In, First Out") operations.
 
 A queue is commonly compared to waiting in line. When objects are added, they
 go to the back of the line, and objects are always removed from the front of
 the line. These actions are accomplished using @link #addObject:
 -addObject:\endlink and @link #removeFirstObject -removeFirstObject\endlink,
 respectively. The frontmost object may be examined (not removed) using @link
 #firstObject -firstObject\endlink.
 */
@protocol CHQueue <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a queue with no objects.
 */
- (id) init;

/**
 Initialize a queue with the contents of an array. Objects are enqueued in the
 order they occur in the array.
 
 @param anArray An array containing object with which to populate a new queue.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Add an object to the back of the queue.
 
 @param anObject The object to add to the back of the queue.
 @throw NSInvalidArgumentException If @a anObject is <code>nil</code>.
 */
- (void) addObject:(id)anObject;

/**
 Examine the object at the front of the queue without removing it.
 
 @return The frontmost object in the queue, or <code>nil</code> if the queue is
         empty.
 */
- (id) firstObject;

/**
 Remove the front object in the queue; no effect if the queue is already empty.
 */
- (void) removeFirstObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the queue.
 
 If the queue does not contain @a anObject, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to be removed from the queue.
 
 If the queue does not contain @a anObject, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the queue; no effect if the queue is already empty.
 */
- (void) removeAllObjects;

/**
 Returns an array with the objects in this queue, ordered from front to back.
 
 @return An array with the objects in this queue. If the queue is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the queue.
 
 @return The number of objects currently in the queue.
 */
- (NSUInteger) count;

/**
 Checks if a queue contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the queue.
 @return <code>YES</code> if @a anObject is present in the queue,
         <code>NO</code>if it is not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Checks if a queue contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the queue.
 @return <code>YES</code> if @a anObject is present in the queue,
         <code>NO</code> if it is not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the queue from front to back.
 
 NOTE: When using an enumerator, you must not modify the queue during enumeration. 
 */
- (NSEnumerator*) objectEnumerator;

@end
