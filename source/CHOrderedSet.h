/*
 CHDataStructures.framework -- CHOrderedSet.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableSet.h"

/**
 @file CHOrderedSet.h
 A set which also maintains order of insertion, including manual reordering.
 */

/**
 A set which also maintains order of insertion, including manual reordering.
 
 An <strong>ordered set</strong> is a composite data structure which combines a <a href="http://en.wikipedia.org/wiki/Set_(computer_science)">set</a> and a <a href="http://en.wikipedia.org/wiki/List_(computing)">list</a>. It blends the uniqueness aspect of sets with the ability to recall the order in which items were added to the set. While this is possible with only a ordered set, the speedy test for membership is a set means  that many basic operations (such as add, remove, and contains) that take linear time for a list can be accomplished in constant time (i.e. O(1) instead of O(n) complexity. Compared to these gains, the time overhead required for maintaining the list is negligible, although it does increase memory requirements.
 
 One of the most common implementations of an insertion-ordered set is Java's <a href="http://java.sun.com/javase/6/docs/api/java/util/LinkedHashSet.html">LinkedHashSet</a>. This implementation wraps an NSMutableSet and a circular buffer to maintain insertion order. The API is designed to be as consistent as possible with that of NSSet and NSMutableSet.
 
 @todo Allow setting a maximum size, and either reject additions or evict the "oldest" item when the limit is reached? (Perhaps this would be better done by the user...)
 */
@interface CHOrderedSet : CHLockableSet {
	id ordering; /**< A structure for maintaining ordering of the objects. */
}

#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

#if OBJC_API_2
/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 For this class, the objects are enumerated in the order in which they were inserted.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @since Mac OS X v10.5 and later.
 
 @see NSFastEnumeration protocol
 @see objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;
#endif

// @}
#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Adds a given object to the receiver at a given index. If the receiver already contains an equivalent object, it is replaced with @a anObject.
 
 @param anObject The object to add to the receiver.
 @param index The index at which @a anObject should be inserted.
 
 @see addObject:
 @see indexOfObject:
 @see objectAtIndex:
 */
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;

/**
 Exchange the objects in the receiver at given indexes.
 
 @param idx1 The index of the object to replace with the object at @a idx2.
 @param idx2 The index of the object to replace with the object at @a idx1.
 
 @throw NSRangeException If @a idx1 or @a idx2 exceeds the bounds of the receiver.
 
 @see indexOfObject:
 @see insertObject:atIndex:
 @see objectAtIndex:
 */
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array of the objects in the set, in the order in which they were inserted.
 
 @return An array of the objects in the set, in the order in which they were inserted.
 
 @see anyObject
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 */
- (NSArray*) allObjects;

/**
 Returns the "oldest" member of the receiver.
 
 @return The "oldest" member of the receiver.
 
 @see addObject:
 @see anyObject
 @see lastObject
 @see removeFirstObject
 */
- (id) firstObject;

/**
 Returns the index of a given object based on insertion order.
 
 @param anObject The object to search for in the receiver.
 @return The index of @a anObject based on insertion order. If the object does not existsin the receiver, @c NSNotFound is returned.
 
 @see firstObject
 @see lastObject
 @see objectAtIndex:
 @see removeObjectAtIndex:
 */
- (NSUInteger) indexOfObject:(id)anObject;

/**
 Compares the receiving ordered set to another ordered set. Two ordered sets have equal contents if they each hold the same number of objects and objects at a given position in each ordered set satisfy the \link NSObject#isEqual: -isEqual:\endlink test.
 
 @param otherOrderedSet A ordered set.
 @return @c YES if the contents of @a otherOrderedSet are equal to the contents of the receiver, otherwise @c NO.
 */
- (BOOL) isEqualToOrderedSet:(CHOrderedSet*)otherOrderedSet;

/**
 Returns the "youngest" member of the receiver.

 @see addObject:
 @see anyObject
 @see firstObject
 @see removeLastObject
 */
- (id) lastObject;

/**
 Returns the value at the specified index.
 
 @param index The insertion-order index of the value to retrieve.
 @return The value at the specified index, based on insertion order.
 
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @see indexOfObject:
 @see removeObjectAtIndex:
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Returns an enumerator object that lets you access each object in the receiver in order.
 
 @return An enumerator object that lets you access each object in the receiver in order.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 If you need to modify the entries concurrently, you can enumerate over a "snapshot" of the set's values obtained from #allObjects.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) objectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the "oldest" member of the receiver.
 
 @see firstObject
 @see removeAllObjects
 @see removeObject:
 @see removeObjectAtIndex:
 */
- (void) removeFirstObject;

/**
 Remove the "youngest" member of the receiver. 

 @see lastObject
 @see removeAllObjects
 @see removeObject:
 @see removeObjectAtIndex:
 */
- (void) removeLastObject;

/**
 Remove the object at a given index from the receiver.
 
 @param index The index of the object to remove.
 
 @throw NSRangeException If @a index exceeds the bounds of the receiver.
 
 @see minusSet:
 @see removeAllObjects
 @see removeFirstObject
 @see removeLastObject
 @see removeObject:
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

// @}
@end
