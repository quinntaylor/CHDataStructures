/*
 CHDataStructures.framework -- CHAbstractListCollection.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableObject.h"
#import "CHLinkedList.h"

/**
 @file CHAbstractListCollection.h
 An abstract class which implements common behaviors of list-based collections.
 */

/**
 An abstract class which implements common behaviors of list-based collections. This class has a single instance variable on which all the implemented methods act, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration
 
 Rather than enforcing that this class be abstract, the contract is implied.
 */
@interface CHAbstractListCollection : CHLockableObject 
#if OBJC_API_2
<NSCoding, NSCopying, NSFastEnumeration>
#else
<NSCoding, NSCopying>
#endif
{
	id<CHLinkedList> list; /**< List used for storing contents of collection. */
}

- (id) initWithArray:(NSArray*)anArray;
- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSArray*) allObjects;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;

#pragma mark Indexed Operations
// These operations aren't a part of the stack/queue/deque protocols, but are
// provided as a convenience for working directly with a circular buffer.

/**
 Exchange the objects in the receiver at given indexes.
 
 @param idx1 The index of the object to replace with the object at @a idx2.
 @param idx2 The index of the object to replace with the object at @a idx1.
 
 @throw NSRangeException If @a idx1 or @a idx2 exceeds the bounds of the receiver.
 
 @attention Indexed operations on linked lists generally require traversing nodes in order, which is significantly slower than similar operations on an array.
 
 @see indexOfObject:
 @see objectAtIndex:
 */
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

/**
 Returns the lowest index of a given object, matched using @c isEqual:.
 
 @param anObject The object to be matched and located in the receiver.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the receiver match @a anObject, returns @c NSNotFound.
 
 @attention Indexed operations on linked lists generally require traversing nodes in order, which is significantly slower than similar operations on an array.
 
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObject:(id)anObject;

/**
 Returns the lowest index of a given object, matched using the == operator.
 
 @param anObject The object to be matched and located in the receiver.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the receiver match @a anObject, returns @c NSNotFound.
 
 @attention Indexed operations on linked lists generally require traversing nodes in order, which is significantly slower than similar operations on an array.
 
 @see indexOfObject:
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;

/**
 Returns the object located at @a index in the receiver.
 
 @param index An index from which to retrieve an object.
 @return The object located at @a index.
 
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @attention Indexed operations on linked lists generally require traversing nodes in order, which is significantly slower than similar operations on an array.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see removeObjectAtIndex:
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Remove the object at a given index from the receiver.
 
 @param index The index from which to remove the object.
 
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @attention Indexed operations on linked lists generally require traversing nodes in order, which is significantly slower than similar operations on an array.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 @see objectAtIndex:
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

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
