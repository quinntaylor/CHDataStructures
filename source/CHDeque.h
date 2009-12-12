/*
 CHDataStructures.framework -- CHDeque.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

/**
 @file CHDeque.h
 
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for insertion and removal on both ends.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for insertion and removal on both ends. This differs from standard stacks (where objects are inserted and removed from the same end, a.k.a. LIFO) and queues (where objects are inserted at one end and removed at the other, a.k.a. FIFO). However, a deque can act as either a stack or a queue (or other possible sub-types) by selectively restricting a subset of its input and output operations.
 */
@protocol CHDeque
#if OBJC_API_2
<NSObject, NSCoding, NSCopying, NSFastEnumeration>
#else
<NSObject, NSCoding, NSCopying>
#endif

/**
 Initialize a deque with no objects.
 
 @see initWithArray:
 */
- (id) init;

/**
 Initialize a deque with the contents of an array. Objects are appended in the order they occur in the array.
 
 @param anArray An array containing objects with which to populate a new deque.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Add an object to the front of the deque.
 
 @param anObject The object to add to the front of the deque.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see firstObject
 @see removeFirstObject
 */
- (void) prependObject:(id)anObject;

/**
 Add an object to the back of the deque.
 
 @param anObject The object to add to the back of the deque.
 @throw NSInvalidArgumentException If @a anObject is @c nil.

 @see lastObject
 @see removeLastObject
 */
- (void) appendObject:(id)anObject;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array with the objects in this deque, ordered from front to back.
 
 @return An array with the objects in this deque. If the deque is empty, the array is also empty.
 
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
 @see reverseObjectEnumerator
 */
- (NSArray*) allObjects;

/**
 Determine whether the receiver contains a given object, matched using \link NSObject#isEqual: -isEqual:\endlink.
 
 @param anObject The object to test for membership in the receiver.
 @return @c YES if the receiver contains @a anObject (as determined by \link NSObject#isEqual: -isEqual:\endlink), @c NO if @a anObject is @c nil or not present.
 
 @see containsObjectIdenticalTo:
 @see removeObject:
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determine whether the receiver contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the receiver.
 @return @c YES if the receiver contains @a anObject (as determined by the == operator), @c NO if @a anObject is @c nil or not present.
 
 @see containsObject:
 @see removeObjectIdenticalTo:
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the number of objects currently in the deque.
 
 @return The number of objects currently in the deque.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Returns the first object in the deque without removing it.
 
 @return The first object in the deque, or @c nil if it is empty.
 
 @see lastObject
 */
- (id) firstObject;

/**
 Compares the receiving deque to another deque. Two deques have equal contents if they each hold the same number of objects and objects at a given position in each deque satisfy the \link NSObject#isEqual: -isEqual:\endlink test.
 
 @param otherDeque A deque.
 @return @c YES if the contents of @a otherDeque are equal to the contents of the receiver, otherwise @c NO.
 */
- (BOOL) isEqualToDeque:(id<CHDeque>)otherDeque;

/**
 Returns the last object in the deque without removing it.
 
 @return The last object in the deque, or @c nil if it is empty.
 
 @see firstObject
 */
- (id) lastObject;

/**
 Returns an enumerator that accesses each object in the deque from front to back.
 
 @return An enumerator that accesses each object in the deque from front to back. The enumerator returned is never @c nil; if the deque is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 @see reverseObjectEnumerator
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the deque from back to front.
 
 @return An enumerator that accesses each object in the deque from back to front. The enumerator returned is never @c nil; if the deque is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 */
- (NSEnumerator*) reverseObjectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the first object in the deque; no effect if it is empty.
 
 @see firstObject
 @see removeLastObject
 @see removeObject:
 */
- (void) removeFirstObject;

/**
 Remove the last object in the deque; no effect if it is empty.
 
 @see lastObject
 @see removeFirstObject
 @see removeObject:
 */
- (void) removeLastObject;

/**
 Remove @b all occurrences of @a anObject, matched using @c isEqual:.
 
 @param anObject The object to be removed from the deque.

 If the deque is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObject:
 @see removeObjectIdenticalTo:
 */
- (void) removeObject:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using the == operator.
 
 @param anObject The object to be removed from the deque.
 
 If the deque is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObjectIdenticalTo:
 @see removeObject:
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Empty the receiver of all of its members.
 
 @see allObjects
 @see removeFirstObject
 @see removeLastObject
 @see removeObject:
 @see removeObjectIdenticalTo:
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
- (id) initWithCoder:(NSCoder*)decoder;

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.
 
 @see NSCoding protocol
 */
- (void) encodeWithCoder:(NSCoder*)encoder;

// @}
#pragma mark <NSCopying>
/** @name <NSCopying> */
// @{

/**
 Returns a new instance that is a mutable copy of the receiver. If garbage collection is @b not enabled, the copy is retained before being returned, but the sender is responsible for releasing it.
 
 @param zone An area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. 
 
 @note The default \link NSObject#copy -copy\endlink method invokes this method with a @c nil argument.
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone*)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

#if OBJC_API_2
/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @since Mac OS X v10.5 and later.
 
 @see NSFastEnumeration protocol
 @see allObjects
 @see objectEnumerator
 @see reverseObjectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

// @}
@end
