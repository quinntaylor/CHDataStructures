/*
 CHDataStructures.framework -- CHAbstractMutableArrayCollection.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableObject.h"

/**
 @file CHAbstractMutableArrayCollection.h
 An abstract class which implements common behaviors of array-based collections.
 */

/**
 An abstract class which implements common behaviors of array-based collections. This class has a single instance variable on which all the implemented methods act, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration
 
 Rather than enforcing that this class be abstract, the contract is implied.
 */
@interface CHAbstractMutableArrayCollection : CHLockableObject 
#if MAC_OS_X_VERSION_10_5_AND_LATER
<NSCoding, NSCopying, NSFastEnumeration>
#else
<NSCoding, NSCopying>
#endif
{
	NSMutableArray *array; /**< Array used for storing contents of collection. */
}

- (id) initWithArray:(NSArray*)anArray;

- (NSArray*) allObjects;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
/**
 Returns an enumerator that accesses each object in the receiver from back to front.
 
 @return An enumerator that accesses each object in the receiver from back to front. The enumerator returned is never @c nil; if the receiver is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 */
- (NSEnumerator*) reverseObjectEnumerator;

- (void) removeAllObjects;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;

#pragma mark Indexed Operations
// These operations aren't a part of the stack/queue/deque protocols, but are
// provided as a convenience for working directly with a circular buffer.

/**
 Exchange the objects in the receiver at given indexes.
 
 @param idx1 The index of the object to replace with the object at @a idx2.
 @param idx2 The index of the object to replace with the object at @a idx1.
 
 @throw NSRangeException If @a idx1 or @idx2 is greater than the number of elements in the receiver.
 
 @see indexOfObject:
 @see objectAtIndex:
 */
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

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
 Returns the object located at @a index in the receiver.
 
 @param index An index from which to retrieve an object.
 @return The object located at @a index.
 
 @throw NSRangeException If @a index is greater than the number of elements in the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see removeObjectAtIndex:
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Remove the object at a given index from the receiver.
 
 @param index The index from which to remove the object.
 
 @throw NSRangeException If @a index is greater than the number of elements in the receiver.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

#pragma mark Adopted Protocols

- (void) encodeWithCoder:(NSCoder*)encoder;
- (id) initWithCoder:(NSCoder*)decoder;
- (id) copyWithZone:(NSZone*)zone;
#if MAC_OS_X_VERSION_10_5_AND_LATER
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

@end
