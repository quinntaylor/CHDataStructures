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

//  LinkedList.h
//  DataStructuresFramework

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
 */ 
@protocol LinkedList <NSObject, NSCoding, NSCopying, NSFastEnumeration>

#pragma mark Required Methods

@required

/**
 Initialize a newly-allocated linked list with no objects.
 */
- (id) init;

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
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to remove from the list.
 
 If the list does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the list. If the list is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an array containing the objects in this linked list, in the same order.
 
 @return An array containing the objects in this linked list. If the list is empty,
         the array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns the number of objects currently in the list.
 
 @return The number of objects currently in the list.
 */
- (NSUInteger) count;

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
 Returns an enumerator object that provides access to each object in the receiver.
 
 @return An enumerator object that lets you access each object in the receiver, from
         the element at the lowest index upwards.
 */
- (NSEnumerator*) objectEnumerator;

#pragma mark Optional Methods

@optional

/**
 Inserts an object before <i>otherObject</i>, matched using <code>compare:</code>.
 
 @param anObject The object to add to the list; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> is raised.
 @param otherObject The object before which to add <i>anObject</i>.
 */
- (void) insertObject:(id)anObject beforeObject:(id)otherObject;

/**
 Inserts an object after <i>otherObject</i>, matched using <code>compare:</code>.
 
 @param anObject The object to add to the list; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> is raised.
 @param otherObject The object after which to add <i>anObject</i>.
 */
- (void) insertObject:(id)anObject afterObject:(id)otherObject;

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

/**
 Returns the object located at <i>index</i>.
 
 @param index An index from which to retrieve an object. If <i>index</i> is greater
        than or equal to the number of elements, an NSRangeException is raised.
 @return The object located at index.
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Removes the object at <i>index</i>. To fill the gap, elements beyond <i>index</i>
 have 1 subtracted from their index.
 
 @param index The index from which to remove the object. If <i>index</i> is greater
        than or equal to the number of elements, an NSRangeException is raised.
 
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

@end
