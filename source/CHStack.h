/*
 CHDataStructures.framework -- CHStack.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

/**
 @file CHStack.h
 
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a> protocol with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a> ("Last In, First Out") operations. 
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Stack_(data_structure)">stack</a> protocol with methods for <a href="http://en.wikipedia.org/wiki/LIFO">LIFO</a> ("Last In, First Out") operations. 
 
 A stack is commonly compared to a stack of plates. Objects may be added in any order (\link #pushObject: -pushObject:\endlink) and the most recently added object may be removed (\link #popObject -popObject\endlink) or returned without removing it (\link #topObject -topObject\endlink).
 */
@protocol CHStack <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a stack with no objects.
 
 @see initWithArray:
 */
- (id) init;

/**
 Initialize a stack with the contents of an array. Objects are pushed on the stack in the order they occur in the array.
 
 @param anArray An array containing objects with which to populate a new stack.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Add an object to the top of the stack.
 
 @param anObject The object to add to the top of the stack.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see popObject
 @see topObject
 */
- (void) pushObject:(id)anObject;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array of the objects in this stack, ordered from top to bottom.
 
 @return An array of the objects in this stack. If the stack is empty, the array is also empty.
 
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
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
 Returns the number of objects currently on the stack.
 
 @return The number of objects currently on the stack.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Returns an enumerator that accesses each object in the stack from top to bottom.
 
 @return An enumerator that accesses each object in the stack from top to bottom. The enumerator returned is never @c nil; if the stack is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.

 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns the object on the top of the stack without removing it.
 
 @return The topmost object from the stack.
 
 @see popObject
 @see pushObject:
 */
- (id) topObject;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the topmost object on the stack; no effect if the stack is already empty.
 
 @see pushObject:
 @see removeObject:
 @see topObject
 */
- (void) popObject;

/**
 Remove @b all occurrences of @a anObject, matched using @c isEqual:.
 
 @param anObject The object to be removed from the stack.
 
 If the stack is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObject:
 @see removeObjectIdenticalTo:
 */
- (void) removeObject:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using the == operator.
 
 @param anObject The object to be removed from the stack.
 
 If the stack is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @see containsObjectIdenticalTo:
 @see removeObject:
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Empty the receiver of all of its members.
 
 @see allObjects
 @see popObject
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
 
 @note The default \link NSObject#copy -copy\endlink method invokes this method with a @c nil argument.
 
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

// @}
@end
