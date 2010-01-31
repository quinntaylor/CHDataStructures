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
#if OBJC_API_2
<NSCoding, NSCopying, NSFastEnumeration>
#else
<NSCoding, NSCopying>
#endif
{
	__strong id *array; /**< Primitive C array for storing collection contents. */
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

/**
 Returns a boolean value that indicates whether a given object is present in the receiver.  Objects are considered equal if @c isEqual: returns @c YES.
 
 @param anObject The object to be matched and located in the receiver.
 @return @c YES if @a anObject is present in the receiver, otherwise @c NO.
 
 @see containsObjectIdenticalTo:
 @see indexOfObject:
 */
- (BOOL) containsObject:(id)anObject;

/**
 Returns a boolean value that indicates whether a given object is present in the receiver.  Objects are considered identical if their object addresses are the same.
 
 @param anObject The object to be matched and located in the receiver.
 @return @c YES if @a anObject is present in the receiver, otherwise @c NO.
 
 @see containsObject:
 @see indexOfObjectIdenticalTo:
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

- (id) firstObject;
- (id) lastObject;

/**
 Returns an enumerator that accesses each object in the receiver from front to back.
 
 @return An enumerator that lets you access each object in the receiver, in order, from front to back. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the receiver from back to front.
 
 @return An enumerator that lets you access each object in the receiver, in order, from back to front. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
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
// These operations aren't a part of the stack/queue/deque protocols, but are
// provided as a convenience for working directly with a circular buffer.

/**
 Exchange the objects in the receiver at given indexes.
 
 @param idx1 The index of the object to replace with the object at @a idx2.
 @param idx2 The index of the object to replace with the object at @a idx1.
 
 @throw NSRangeException If @a idx1 or @a idx2 exceeds the bounds of the receiver.
 
 @see indexOfObject:
 @see objectAtIndex:
 */
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

/**
 Returns the lowest index whose corresponding array value is equal to a given object. Objects are considered equal if @c isEqual: returns @c YES.
 
 @param anObject The object to be matched and located in the receiver.
 @return The lowest index whose corresponding array value is equal to @a anObject. If none of the objects in the receiver is equal to @a anObject, returns @c NSNotFound.
 
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObject:(id)anObject;

/**
 Returns the lowest index within a specified range whose corresponding array value is equal to a given object. Objects are considered equal if @c isEqual: returns @c YES.
 
 @param anObject The object to be matched and located in the receiver.
 @param range The range of indexes in the receiver within which to search for @a anObject.
 @return The lowest index within @a range whose corresponding array value is equal to @a anObject. If none of the objects within range is equal to @a anObject, returns @c NSNotFound.
 
 @see containsObject:
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:inRange:
 */
- (NSUInteger) indexOfObject:(id)anObject inRange:(NSRange)range;

/**
 Returns the lowest index whose corresponding array value is identical to a given object. Objects are considered identical if their object addresses are the same.
 
 @param anObject The object to be matched and located in the receiver.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the receiver match @a anObject, returns @c NSNotFound.
 
 @see indexOfObject:
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;

/**
 Returns the lowest index within a specified range whose corresponding array value is identical to a given object. Objects are considered identical if their object addresses are the same.
 
 @param anObject The object to be matched and located in the receiver.
 @param range The range of indexes in the receiver within which to search for @a anObject.
 @return The lowest index within @a range whose corresponding array value is equal to @a anObject. If none of the objects within range is equal to @a anObject, returns @c NSNotFound.
 
 Return Value
 The lowest index within range whose corresponding array value is identical to anObject. If none of the objects within range is identical to anObject, returns NSNotFound.
 */
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range;

/**
 Insert a given object at a given index. If @a index is already occupied, then objects from @a index to the non-wrapped end of the buffer are shifted one spot to make room for @a anObject.
 
 @param anObject The object to add to the receiver.
 @param index The index at which to insert @a anObject.
 
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @attention Inserting in the middle of an array is a somewhat inefficient operation &mdash; one or more values must be shifted by one slot using @c memmove().
 */
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;

/**
 Returns the object located at @a index in the receiver.
 
 @param index An index from which to retrieve an object.
 @return The object located at @a index.
 
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see objectsAtIndexes:
 @see objectsInRange:
 @see removeObjectAtIndex:
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Returns an array containing the objects in the receiver at the indexes specified by a given index set.
 
 @param indexes A set of positions for objects to retrieve from the receiver.
 @return An array containing the objects in the receiver at the positions specified by @a indexes.
 @throw NSInvalidArgumentException If @a indexes is @c nil.
 @throw NSRangeException If any location in @a indexes exceeds the bounds of the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 @see \link NSArray#objectsAtIndexes: - [NSArray objectsAtIndexes:]\endlink
 */
- (NSArray*) objectsAtIndexes:(NSIndexSet*)indexes;

/**
 Returns a new array containing the receiver's elements that fall within the limits specified by a given range.
 
 @param range A range within the receiver's bounds.
 @return An array containing the receiver's elements that fall within the limits specified by @a range.
 
 @see objectAtIndex:
 @see objectsAtIndexes:
 @see \link NSArray#subarrayWithRange: - [NSArray subarrayWithRange:]\endlink
 */
- (NSArray*) objectsInRange:(NSRange)range;

/**
 Remove the object at a given index from the receiver. Elements on the non-wrapped end of the buffer are shifted one spot to fill the gap.
 
 @param index The index from which to remove the object.
 
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

/**
 Removes the objects at the specified indexes from the receiver. This method is similar to #removeObjectAtIndex: but allows you to efficiently remove multiple objects with a single operation.
 
 @param indexes The indexes of the objects to remove from the receiver.
 @throw NSInvalidArgumentException If @a indexes is @c nil.
 @throw NSRangeException If any location in @a indexes exceeds the bounds of the receiver.
 
 @attention To remove objects in a given @c NSRange, pass <code>[NSIndexSet indexSetWithIndexesInRange:range]</code> as the parameter to this method.
 
 @see objectsAtIndexes:
 @see removeObjectAtIndex:
 */
- (void) removeObjectsAtIndexes:(NSIndexSet*)indexes;

#pragma mark Adopted Protocols

- (void) encodeWithCoder:(NSCoder*)encoder;
- (id) initWithCoder:(NSCoder*)decoder;
- (id) copyWithZone:(NSZone*)zone;
#if OBJC_API_2
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

@end
