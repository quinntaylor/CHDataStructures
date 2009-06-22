/*
 CHDataStructures.framework -- CHAbstractCircularBufferCollection.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableObject.h"

/**
 @file CHAbstractCircularBufferCollection.h
 An abstract class which implements common behaviors of circular array buffers.
 */

/**
 An abstract class which implements common behaviors of circular array buffers. This class maintains a C array of object pointers in which objects can be added or removed from either end cheaply, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration

 Rather than enforcing that this class be abstract, the contract is implied.
 */

@interface CHAbstractCircularBufferCollection : CHLockableObject 
#if MAC_OS_X_VERSION_10_5_AND_LATER
<NSCoding, NSCopying, NSFastEnumeration>
#else
<NSCoding, NSCopying>
#endif
{
	id *array; /**< Primitive C array used for storing contents of collection. */
	NSUInteger arrayCapacity; /**< How many pointers @a array can accommodate. */
	NSUInteger count; /**< The number of objects currently in the buffer. */
	NSUInteger headIndex; /**< The array index of the first object. */
	NSUInteger tailIndex; /**< The array index after the last object. */
	unsigned long mutations; /**< Tracks mutations for NSFastEnumeration. */
}

/**
 Initialize a collection with a given initial capacity for the circular buffer.
 
 @param capacity The number of elements that can be stored in the collection before the allocated memory must be expanded. (The default value is 16.)
 */
- (id) initWithCapacity:(NSUInteger)capacity;
- (id) initWithArray:(NSArray*)anArray;

- (void) appendObject:(id)anObject;
- (void) prependObject:(id)anObject;

- (NSArray*) allObjects;	
- (NSUInteger) count;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (id) firstObject;
- (id) lastObject;
- (NSEnumerator*) objectEnumerator;
/**
 Returns an enumerator that accesses each object in the receiver from back to front.
 
 @return An enumerator that accesses each object in the receiver from back to front. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 */
- (NSEnumerator*) reverseObjectEnumerator;

- (void) removeAllObjects;
- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;

#pragma mark Indexed Operations
// These operations aren't strictly a part of stack/queue/deque subclasses, but
// are provided as a convenience for working directly with a circular buffer.

/**
 Returns the lowest index of a given object, matched using @c isEqual:.
 
 @param anObject The object to be matched and located in the receiver.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the receiver match @a anObject, returns @c CHNotFound.
 
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObject:(id)anObject;

/**
 Returns the lowest index of a given object, matched using the == operator.
 
 @param anObject The object to be matched and located in the receiver.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the receiver match @a anObject, returns @c CHNotFound.
 
 @see indexOfObject:
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;

/**
 Insert a given object at a given index. If @a index is already occupied, then objects from @a index to the non-wrapped end of the buffer are shifted one spot to make room for @a anObject.
 
 @param anObject The object to add to the receiver.
 @param index The index at which to insert @a anObject.
 
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 @throw NSRangeException If @a index is greater than the number of elements in the receiver.
 
 @attention Inserting in the middle of an array is a somewhat inefficient operation &mdash; one or more values must be shifted by one slot using @c memmove().
 */
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;

/**
 Returns the object located at @a index.
 
 @param index An index from which to retrieve an object.
 @return The object located at @a index.
 
 @throw NSRangeException If @a index is greater than the number of elements in the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see removeObjectAtIndex:
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Remove the object at a given index. Elements on the non-wrapped end of the buffer are shifted one spot  to fill the gap.
 
 @param index The index from which to remove the object.
 
 @throw NSRangeException If @a index is greater than the number of elements in the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

#pragma mark Adopted Protocols

- (void) encodeWithCoder:(NSCoder *)encoder;
- (id) initWithCoder:(NSCoder *)decoder;
- (id) copyWithZone:(NSZone *)zone;
#if MAC_OS_X_VERSION_10_5_AND_LATER
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

@end
