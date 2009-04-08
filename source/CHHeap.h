/*
 CHDataStructures.framework -- CHHeap.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHHeap.h
 
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol,
 suitable for use with many variations of the heap structure.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol,
 suitable for use with many variations of the heap structure.
 
 Since objects in a Heap are inserted according to their sorted order, all objects
 must respond to the <code>compare:</code> selector, which accepts another object
 and returns NSOrderedAscending, NSOrderedSame, or NSOrderedDescending as the
 receiver is less than, equal to, or greater than the argument, respectively. (See
 NSComparisonResult in NSObjCRuntime.h for details.) 
 */
@protocol CHHeap <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a heap with ascending ordering and no objects.
 */
- (id) init;

/**
 Initialize a heap with the contents of an array. Objects are added to the heap
 as they occur in the array, then sorted using <code>NSOrderedAscending</code>.
 
 @param anArray An array containing object with which to populate a new heap.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Initialize a heap with a given sort ordering and no objects.
 
 @param order The sort order to use, either <code>NSOrderedAscending</code> or
        <code>NSOrderedDescending</code>. The root element of the heap will be the
        smallest or largest (according to <code>-compare:</code>), respectively.
        For any other value, an <code>NSInvalidArgumentException</code> is raised.
 */
- (id) initWithOrdering:(NSComparisonResult)order;

/**
 Initialize a heap with a given sort ordering and objects from the given array.
 
 @param order The sort order to use, either <code>NSOrderedAscending</code> or
        <code>NSOrderedDescending</code>. The root element of the heap will be the
        smallest or largest (according to <code>-compare:</code>), respectively.
        For any other value, an <code>NSInvalidArgumentException</code> is raised.
 @param anArray An array containing objects to be added to this heap.
 */
- (id) initWithOrdering:(NSComparisonResult)order array:(NSArray*)anArray;

/**
 Insert a given object into the heap.

 @param anObject The object to add to the heap.
 @throw NSInvalidArgumentException If @a anObject is <code>nil</code>.
 */
- (void) addObject:(id)anObject;

/**
 Adds the objects in a given array to this heap, then re-establish the heap property.
 After all the objects have been inserted, objects are percolated down the heap as
 necessary, starting from @a count/2 and decrementing to 0.
 
 @param anArray An array of objects to add to the heap.
 */
- (void) addObjectsFromArray:(NSArray*)anArray;

/**
 Examine the first object in the heap without removing it.
 
 @return The first object in the heap, or <code>nil</code> if the heap is empty.
 */
- (id) firstObject;

/**
 Remove the front object in the heap; if it is already empty, there is no effect.
 */
- (void) removeFirstObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the heap.
 
 If the heap does not contain @a anObject, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to be removed from the heap.
 
 If the heap does not contain @a anObject, there is no effect, although it
 does incur the overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the heap; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an array containing the objects in this heap in sorted order.
 
 NOTE: Since a heap structure is only "sorted" as elements are removed, this incurs
 extra costs for sorting and storing the duplicate array, but does not affect the
 order of elements in the heap itself.

 @return An array containing the objects in this heap. If the heap is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the heap.
 
 @return The number of objects currently in the heap.
 */
- (NSUInteger) count;

/**
 Determines if a heap contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the heap.
 @return <code>YES</code> if @a anObject is present in the heap, <code>NO</code>
         if it is not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a heap contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the heap.
 @return <code>YES</code> if @a anObject is present in the heap, <code>NO</code>
         if it is not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the heap in sorted order. Uses
 the NSArray returned by #allObjects for enumeration, so all the same caveats apply.
 
 @return An enumerator that accesses each object in the heap in sorted order.
 
 NOTE: When using an enumerator, you must not modify the heap during enumeration.
 
 @see #allObjects
 */
- (NSEnumerator*) objectEnumerator;

@end
