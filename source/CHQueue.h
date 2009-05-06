/*
 CHDataStructures.framework -- CHQueue.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

/**
 @file CHQueue.h
 
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a> protocol with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a> ("First In, First Out") operations.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Queue_(data_structure)">queue</a> protocol with methods for <a href="http://en.wikipedia.org/wiki/FIFO">FIFO</a> ("First In, First Out") operations.
 
 A queue is commonly compared to waiting in line. When objects are added, they go to the back of the line, and objects are always removed from the front of the line. These actions are accomplished using \link #addObject: -addObject:\endlink and \link #removeFirstObject -removeFirstObject\endlink, respectively. The frontmost object may be examined (not removed) using \link #firstObject -firstObject\endlink.
 */
@protocol CHQueue <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a queue with no objects.
 */
- (id) init;

/**
 Initialize a queue with the contents of an array. Objects are enqueued in the order they occur in the array.
 
 @param anArray An array containing object with which to populate a new queue.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Add an object to the back of the queue.
 
 @param anObject The object to add to the back of the queue.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see lastObject
 @see removeFirstObject
 */
- (void) addObject:(id)anObject;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array with the objects in this queue, ordered from front to back.
 
 @return An array with the objects in this queue. If the queue is empty, the array is also empty.
 
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
 */
- (NSArray*) allObjects;

/**
 Checks if a queue contains a given object, matched using @c isEqual:.
 
 @param anObject The object to test for membership in the queue.
 @return @c YES if @a anObject is in the queue, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Checks if a queue contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the queue.
 @return @c YES if @a anObject is in the queue, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the number of objects currently in the queue.
 
 @return The number of objects currently in the queue.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Examine the object at the front of the queue without removing it.
 
 @return The first object in the queue, or @c nil if the queue is empty.
 
 @see lastObject
 @see removeFirstObject
 */
- (id) firstObject;

/**
 Examine the object at the back of the queue without removing it.
 
 @return The last object in the queue, or @c nil if the queue is empty.
 
 @see addObject:
 @see firstObject
 */
- (id) lastObject;

/**
 Returns an enumerator that accesses each object in the queue from front to back.
 
 @return An enumerator that accesses each object in the queue from front to back. The enumerator returned is never @c nil; if the queue is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.

 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) objectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the front object in the queue; no effect if the queue is already empty.
 
 @see firstObject
 */
- (void) removeFirstObject;

/**
 Remove @b all occurrences of @a anObject, matched using @c isEqual:.
 
 @param anObject The object to be removed from the queue.
 
 If the queue is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using the == operator.
 
 @param anObject The object to be removed from the queue.
 
 If the queue is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the queue; no effect if the queue is already empty.
 */
- (void) removeAllObjects;

// @}
#pragma mark <NSCoding>
/** @name <NSCoding> */
// @{

/**
 Initialize the receiver using data from a given keyed unarchiver.
 
 @param decoder A keyed unarchiver object.
 
 @see NSCoding protocol
 */
- (id) initWithCoder:(NSCoder *)decoder;

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.
 
 @see NSCoding protocol
 */
- (void) encodeWithCoder:(NSCoder *)encoder;

// @}
#pragma mark <NSCopying>
/** @name <NSCopying> */
// @{

/**
 Returns a new instance that is a mutable copy of the receiver. If garbage collection is @b not enabled, the copy is retained before being returned, but the sender is responsible for releasing it.
 
 @param zone An area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. 
 
 @note \link NSObject#copy -[NSObject copy]\endlink invokes this method with a @c nil argument.
 @return A new instance that is a copy of the receiver.
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see NSFastEnumeration protocol
 @see allObjects
 @see objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @{
@end
