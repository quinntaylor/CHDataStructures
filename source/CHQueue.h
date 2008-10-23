/*
 CHQueue.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHQueue.h
 
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a> ("First In,
 First Out") operations.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a> protocol
 with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a> ("First In,
 First Out") operations.
 
 A queue is commonly compared to waiting in line. When objects are added, they go to
 the back of the line, and objects are always removed from the front of the line.
 These actions are accomplished using @link #addObject: -addObject:\endlink
 and @link #removeFirstObject -removeFirstObject\endlink, respectively. The frontmost
 object may be examined (not removed) using @link #firstObject -firstObject\endlink.
 */
@protocol CHQueue <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a queue with no objects.
 */
- (id) init;

/**
 Initialize a queue with the contents of an array. Objects are enqueued in the order
 they occur in the array.
 
 @param anArray An array containing object with which to populate a new queue.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Add an object to the back of the queue.
 
 @param anObject The object to add to the queue; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObject:(id)anObject;

/**
 Examine the object at the front of the queue without removing it.
 
 @return The frontmost object in the queue, or <code>nil</code> if the queue is empty.
 */
- (id) firstObject;

/**
 Remove the front object in the queue; if it is already empty, there is no effect.
 */
- (void) removeFirstObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the queue.
 
 If the queue does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 */
- (void) removeObject:(id)anObject;

/**
 Remove all objects from the queue; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an array containing the objects in this queue, ordered from front to back.
 
 @return An array containing the objects in this queue. If the queue is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the queue.
 
 @return The number of objects currently in the queue.
 */
- (NSUInteger) count;

/**
 Determines if a queue contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the queue.
 @return <code>YES</code> if <i>anObject</i> is present in the queue, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a queue contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the queue.
 @return <code>YES</code> if <i>anObject</i> is present in the queue, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the queue from front to back.
 
 NOTE: When you use an enumerator, you must not modify the queue during enumeration. 
 */
- (NSEnumerator*) objectEnumerator;

@end
