//  CHHeap.h
//  CHDataStructures.framework

/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

/**
 @file CHHeap.h
 
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol,
 suitable for use with many variations of the heap structure.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol,
 suitable for use with many variations of the heap structure.
 
 Since objects in a Heap are inserted according to their sorted order, all objects
 must respond to the <code>compare:</code> selector, which accepts another object
 and returns NSOrderedAscending, NSOrderedSame, or NSOrderedDescending as the
 receiver is less than, equal to, or greater than the argument, respectively. (See
 NSComparisonResult in NSObjCRuntime.h for details.) 
 
 @todo Add support for NSCoding and NSCopying.
 */
@protocol CHHeap <NSObject, NSFastEnumeration>

/**
 Initialize a heap with ascending ordering and no objects.
 */
- (id) init;

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

 @param anObject The object to add to the heap; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObject:(id)anObject;

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
 
 If the heap does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 */
- (void) removeObject:(id)anObject;

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
 @return <code>YES</code> if <i>anObject</i> is present in the heap, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a heap contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the heap.
 @return <code>YES</code> if <i>anObject</i> is present in the heap, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns an enumerator that accesses each object in the heap in sorted order. Uses
 the NSArray returned by #allObjects for enumeration, so all the same caveats apply.
 
 @return An enumerator that accesses each object in the heap in sorted order.
 
 NOTE: When you use an enumerator, you must not modify the heap during enumeration.
 
 @see #allObjects
 */
- (NSEnumerator*) objectEnumerator;

@end
