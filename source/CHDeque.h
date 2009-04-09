/*
 CHDataStructures.framework -- CHDeque.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHDeque.h
 
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for insertion and removal on both ends.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for insertion and removal on both ends of a queue.
 */
@protocol CHDeque <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a deque with no objects.
 */
- (id) init;

/**
 Initialize a deque with the contents of an array. Objects are appended in the
 order they occur in the array.
 
 @param anArray An array containing object with which to populate a new deque.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Insertion

/**
 Add an object to the front of the deque.
 
 @param anObject The object to add to the front of the deque.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 */
- (void) prependObject:(id)anObject;

/**
 Add an object to the back of the deque.
 
 @param anObject The object to add to the back of the deque.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 */
- (void) appendObject:(id)anObject;

#pragma mark Access

/**
 Returns an array with the objects in this deque, ordered from front to back.
 
 @return An array with the objects in this deque. If the deque is empty, the array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the deque.
 
 @return The number of objects currently in the deque.
 */
- (NSUInteger) count;

/**
 Examine the first object in the deque without removing it.
 
 @return The first object in the deque, or @c nil if it is empty.
 */
- (id) firstObject;

/**
 Examine the last object in the deque without removing it.
 
 @return The last object in the deque, or @c nil if it is empty.
 */
- (id) lastObject;

/**
 Returns an enumerator that accesses each object in the deque from front to back. This enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 
 @return An enumerator that accesses each object in the deque from front to back. The enumerator returned is never @c nil; if the deque is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 <div class="warning">
 @b Warning: Requesting objects from an enumerator whose underlying collection has been modified is unsafe, and may cause a mutation exception to be raised.
 </div>
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the deque from back to front. This enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 
 @return An enumerator that accesses each object in the deque from back to front. The enumerator returned is never @c nil; if the deque is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 <div class="warning">
 @b Warning: Requesting objects from an enumerator whose underlying collection has been modified is unsafe, and may cause a mutation exception to be raised.
 </div>
 */
- (NSEnumerator*) reverseObjectEnumerator;

#pragma mark Search

/**
 Determines if a deque contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the deque. 
 @return @c YES if @a anObject is in the deque, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a deque contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the deque.
 @return @c YES if @a anObject is in the deque, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

#pragma mark Removal

/**
 Remove the first object in the deque; no effect if it is empty.
 */
- (void) removeFirstObject;

/**
 Remove the last object in the deque; no effect if it is empty.
 */
- (void) removeLastObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the deque.

 If no object matching @a anObject is found, there is no effect, aside from the overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to be removed from the deque.
 
 If no object matching @a anObject is found, there is no effect, aside from the overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the deque; no effect if it is empty.
 */
- (void) removeAllObjects;

#pragma mark <NSCoding>

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

#pragma mark <NSCopying>

/**
 Returns a new instance that is a mutable copy of the receiver. The copy is implicitly retained by the sender, who is responsible for releasing it.
 
 @param zone Identifies an area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. (The \link NSObject#copy -copy\endlink method in NSObject invokes this method with a @c nil argument.)
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone;

#pragma mark <NSFastEnumeration>

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 <div class="warning">
 @b Warning: Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 </div>
 
 @param state Context information used to track progress of an enumeration..
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @see NSFastEnumeration protocol
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

@end
