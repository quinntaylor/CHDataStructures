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
 
 @todo Add support for methods in NSCoding, NSMutableCopying, and NSFastEnumeration.
 */ 
@protocol LinkedList <NSObject>

/**
 Returns the number of objects currently in the list.
 
 @return The number of objects currently in the list.
 */
- (NSUInteger) count;

/**
 Determines if a list contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the list.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a list contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the list.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Inserts a given object at a given index. If index is already occupied, the objects
 at index and beyond are shifted by adding 1 to their indices to make room.
 
 @param anObject The object to add to the list. This value must not be <code>nil</code>.
 @param index The index in the receiver at which to insert anObject. This value must
        not be greater than the count of elements in the array.
 */
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;

/**
 Returns the object located at <i>index</i>.
 
 @param index An index within the bounds of the receiver.
 @return The object located at index.
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Add an object at the head of the list.
 
 @param anObject The object to add to the list (must not be <code>nil</code>).
 */
- (void) addObjectToFront:(id)anObject;

/**
 Add an object at the tail of the list.
 
 @param anObject The object to add to the list (must not be <code>nil</code>).
 */
- (void) addObjectToBack:(id)anObject;

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
 Returns an array containing the objects in this linked list.
 
 @return An array containing the objects in this linked list. If the deque is empty,
 the array is also empty. The array is ordered as the objects are in the list. 
 */
- (NSArray*) allObjects;

/**
 Remove the item at the head of the list.
 */
- (void) removeFirstObject;

/**
 Remove the item at the tail of the list.
 */
- (void) removeLastObject;

/**
 Remove all occurrences of a given object , matched using <code>isEqual:</code>.
 
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
 Removes the object at <i>index</i>.
 
 @param index The index from which to remove the object. The value must not exceed
        the bounds of the receiver. To fill the gap, all elements beyond <i>index</i>
        are moved by subtracting 1 from their index.
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

/**
 Remove all objects from the list. If the list is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an enumerator object that provides access to each object in the receiver.
 
 @return An enumerator object that lets you access each object in the receiver, from
        the element at the lowest index upwards.
 */
- (NSEnumerator*) objectEnumerator;

/**
 Create an autoreleased LinkedList with the contents of the array in the given order.

 @param array An array of objects to add to the queue.
 @param direction The order in which to enqueue objects from the array. YES means the 
        natural index order (0...n), NO means reverse index order (n...0).
 
 @todo Switch to <code>+listWithArray:byReversingOrder:</code> like Stack.
 */
+ (id<LinkedList>) listWithArray:(NSArray*)array ofOrder:(BOOL)direction;

@end
