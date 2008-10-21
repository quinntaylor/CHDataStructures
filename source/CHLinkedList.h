//  CHLinkedList.h
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
 @file CHLinkedList.h
 
 A <a href="http://en.wikipedia.org/wiki/Linked_list">linked list</a> protocol with
 methods that work in singly- or doubly-linked lists.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 A <a href="http://en.wikipedia.org/wiki/Linked_list">linked list</a> protocol with
 methods that work in singly- or doubly-linked lists.
 
 This type of data structure is useful for storing sparse data that will be traversed
 often. (Linked lists are very memory efficient when dealing with sparse data, unlike
 hashing and some array schemes.) Insertion and removal at either end of a list is
 extremely fast, but if fast random access (whether insertion, search, or removal) is
 desired, a linked list will generally incur a substantial performance penalty.
 
 Linked lists maintain references to both the start and end of the list, but there is
 no externally-visibly notion of state, such as a "current node". Implementations may
 choose to add indexing or hashing schemes to improve index-based or object-relative
 random access; several optional methods are included to allow such flexibility if
 desired. However, bear in mind that any such additions will increase memory cost and
 diminish the comparative advantages over classes such as NSMutableArray.
 
 Index-based operations are included in this protocol, but users should be aware that
 unless a subclass chooses to use a special indexing scheme, all index-based methods
 in a linked list are O(n). If indexed operations are used frequently, it is likely
 that a better alternative is to use an NSMutableArray.
 */ 
@protocol CHLinkedList <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a linked list with no objects.
 */
- (id) init;

/**
 Initialize a linked list with the contents of an array. Objects are appended in the
 order they occur in the array.
 
 @param anArray An array containing object with which to populate a new linked list.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Insertion

/**
 Add an object to the front of the list.
 
 @param anObject The object to add to the list; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> is raised.
 */
- (void) prependObject:(id)anObject;

/**
 Add an object to the back of the list.
 
 @param anObject The object to add to the list; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> is raised.
 */
- (void) appendObject:(id)anObject;

/**
 Inserts a given object at a given index. If <i>index</i> is already occupied, then
 objects at <i>index</i> and beyond are shifted one spot toward the end of the list.
 
 @param anObject The object to add to the list; must not be <code>nil</code>.
 @param index The index at which to insert anObject. If <i>index</i> is greater
        than or equal to the number of elements, an NSRangeException is raised.
 
 NOTE: Inserting in the middle of a linked list is a somewhat inefficient operation;
 although values aren't shifted like in arrays, the list must be traversed to find
 the specified index.
 */
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;

#pragma mark Access

/**
 Returns the number of objects currently in the list.
 
 @return The number of objects currently in the list.
 */
- (NSUInteger) count;

/**
 Access the object at the head of the list.

 @return The object with the lowest index, or <code>nil</code> if the list is empty.
 */
- (id) firstObject;

/**
 Access the object at the tail of the list.
 
 @return The object with the highest index, or <code>nil</code> if the list is empty.
 */
- (id) lastObject;

/**
 Returns an array containing the objects in this linked list, in the same order.
 
 @return An array containing the objects in this linked list. If the list is empty,
         the array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns an enumerator object that provides access to each object in the receiver.
 The enumerator returned should never be nil; if the list is empty, the enumerator
 will always return nil for -nextObject, and an empty array for -allObjects.
 
 @return An enumerator object that lets you access each object in the receiver, from
         the element at the lowest index upwards.
 */
- (NSEnumerator*) objectEnumerator;

#pragma mark Search

/**
 Determines if a list contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the list.
 @return <code>YES</code> if <i>anObject</i> is present in the list, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a list contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the list.
 @return <code>YES</code> if <i>anObject</i> is present in the list, <code>NO</code>
         if it not present or <code>nil</code>.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the lowest indexof a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be matched and located in the tree.
 @return The index of the first object which is equal to @a anObject. If none of the
         objects in the list is equal to @a anObject, returns <code>NSNotFound</code>.
 */
- (NSUInteger) indexOfObject:(id)anObject;

/**
 Returns the lowest indexof a given object, matched using the == operator.
 
 @param anObject The object to be matched and located in the tree.
 @return The index of the first object which is equal to @a anObject. If none of the
         objects in the list is equal to @a anObject, returns <code>NSNotFound</code>.
 */
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;

/**
 Returns the object located at <i>index</i>.
 
 @param index An index from which to retrieve an object. If <i>index</i> is greater
        than or equal to the number of elements, an NSRangeException is raised.
 @return The object located at index.
 */
- (id) objectAtIndex:(NSUInteger)index;

#pragma mark Removal

/**
 Remove the item at the head of the list.
 */
- (void) removeFirstObject;

/**
 Remove the item at the tail of the list.
 */
- (void) removeLastObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to remove from the list.

 If the list does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 
 If you want to remove only the first object which matches <i>anObject</i>, use
 #indexOfObject: and #removeObjectAtIndex: instead.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to remove from the list.
 
 If the list does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 
 If you want to remove only the first object which matches <i>anObject</i>, use
 #indexOfObjectIdenticalTo: and #removeObjectAtIndex: instead.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Removes the object at <i>index</i>. To fill the gap, elements beyond <i>index</i>
 have 1 subtracted from their index.
 
 @param index The index from which to remove the object. If <i>index</i> is greater
        than or equal to the number of elements, an NSRangeException is raised.
 
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

/**
 Remove all objects from the list. If the list is already empty, there is no effect.
 */
- (void) removeAllObjects;

@end
