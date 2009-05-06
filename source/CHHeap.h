/*
 CHDataStructures.framework -- CHHeap.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

/**
 @file CHHeap.h
 
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol, suitable for use with many variations of the heap structure.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol, suitable for use with many variations of the heap structure.
 
 Objects are "heapified" according to their sorted order, so they must respond to the @c -compare: selector, which accepts another object and returns @c NSOrderedAscending, @c NSOrderedSame, or @c NSOrderedDescending (constants in <a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_DataTypes/Reference/reference.html#//apple_ref/c/tdef/NSComparisonResult">NSComparisonResult</a>) as the receiver is less than, equal to, or greater than the argument, respectively. (Several Cocoa classes already implement the @c -compare: method, including NSString, NSDate, NSNumber, NSDecimalNumber, and NSCell.) 
 */
@protocol CHHeap <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a heap with ascending ordering and no objects.
 
 @see initWithOrdering:array:
 */
- (id) init;

/**
 Initialize a heap with the contents of an array. Objects are added to the heap as they occur in the array, then "heapified" using an @c NSOrderedAscending heap ordering.
 
 @param anArray An array containing object with which to populate a new heap.
 
 @see initWithOrdering:array:
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Initialize a heap with a given sort ordering and no objects.
 
 @param order The sort order to use, either @c NSOrderedAscending or @c NSOrderedDescending. The root element of the heap will be the smallest or largest (according to the @c -compare: method), respectively. For any other value, an @c NSInvalidArgumentException is raised.
 
 @see initWithOrdering:array:
 */
- (id) initWithOrdering:(NSComparisonResult)order;

/**
 Initialize a heap with a given sort ordering and objects from the given array.
 
 @param order The sort order to use, either @c NSOrderedAscending or @c NSOrderedDescending. The root element of the heap will be the smallest or largest (according to the @c -compare: method), respectively. For any other value, an @c NSInvalidArgumentException is raised.
 @param anArray An array containing objects to be added to this heap.
 */
- (id) initWithOrdering:(NSComparisonResult)order array:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Insert a given object into the heap.
 
 @param anObject The object to add to the heap.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see addObjectsFromArray:
 */
- (void) addObject:(id)anObject;

/**
 Adds the objects in a given array to this heap, then re-establish the heap property. After all the objects have been inserted, objects are "heapified" as necessary, proceeding backwards from index @c count/2 down to @c 0.
 
 @param anArray An array of objects to add to the heap.
 
 @see addObject:
 */
- (void) addObjectsFromArray:(NSArray*)anArray;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array containing the objects in this heap in their current order. The contents are almost certainly not sorted (since only the heap property need be satisfied) but this is the quickest way to retrieve all the elements in a heap.
 
 @return An array containing the objects in this heap in their current order. If the heap is empty, the array is also empty.
 
 @see allObjectsInSortedOrder
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
 */
- (NSArray*) allObjects;

/**
 Returns an array containing the objects in this heap in sorted order.
 
 @return An array containing the objects in this heap in sorted order. If the heap is empty, the array is also empty.
 
 @attention Since a heap structure is only "sorted" as elements are removed, this method incurs extra costs of (A) time for sorting the contents and (B) memory for storing the extra array. However, it does not affect the order of elements in the heap itself.
 
 @see allObjects
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 */
- (NSArray*) allObjectsInSortedOrder;

/**
 Determines if a heap contains a given object, matched using @c isEqual:.
 
 @param anObject The object to test for membership in the heap.
 @return @c YES if @a anObject is in the heap, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a heap contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the heap.
 @return @c YES if @a anObject is in the heap, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the number of objects currently in the heap.
 
 @return The number of objects currently in the heap.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Examine the first object in the heap without removing it.
 
 @return The first object in the heap, or @c nil if the heap is empty.
 */
- (id) firstObject;

/**
 Returns an enumerator that accesses each object in the heap.
 
 @return An enumerator that accesses each object in the heap. The enumerator returned is never @c nil; if the heap is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention Due to the nature of a heap, this method is not guaranteed to provide the objects in sorted order. If you want the objects to be sorted without removing them from the heap, use #allObjectsInSortedOrder instead.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see allObjects
 @see allObjectsInSortedOrder
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) objectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the front object in the heap; if it is already empty, there is no effect.
 
 @see removeAllObjects
 */
- (void) removeFirstObject;

/**
 Remove @b all occurrences of @a anObject, matched using @c isEqual:.
 
 @param anObject The object to be removed from the heap.
 
 If the heap is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using the == operator.
 
 @param anObject The object to be removed from the heap.
 
 If the heap is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the heap; if it is already empty, there is no effect.
 
 @see removeFirstObject
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
 
 @attention Due to the nature of a heap, this method is not guaranteed to provide the objects in sorted order. If you want the objects to be sorted without removing them from the heap, use #allObjectsInSortedOrder instead.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see NSFastEnumeration protocol
 @see allObjects
 @see allObjectsInSortedOrder
 @see objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
@end
