/*
 CHDoublyLinkedList.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <Foundation/Foundation.h>
#import "CHLinkedList.h"

/**
 @file CHDoublyLinkedList.h
 A standard doubly-linked list implementation with pointers to head and tail.
 */

/** A struct for nodes in a CHDoublyLinkedList. */
typedef struct CHDoublyLinkedListNode {
	id object; /**< The object associated with this node in the list. */
	struct CHDoublyLinkedListNode *next; /**< The next node in the list. */
	struct CHDoublyLinkedListNode *prev; /**< The previous node in the list. */
} CHDoublyLinkedListNode;

#pragma mark -

/**
 A standard doubly-linked list implementation with pointers to head and tail.
 The extra 'previous' link allows for reverse enumeration and cheap removal from
 the tail of the list. The tradeoff is a little extra storage in each list node
 and a little extra work when inserting and removing. Nodes are represented with
 C structs rather than Obj-C classes, providing much faster performance.
 
 The use of head and tail nodes allows for simplification of the algorithms for
 insertion and deletion, since the special cases of checking whether a node is
 the first or last in the list (and handling the next and previous pointers) are
 done away with. The figures below demonstrate what a doubly-linked list looks
 like when it contains 0 objects, 1 object, and 2 or more objects.
 
 @image html doubly-linked-0.png Figure 1 - Doubly-linked list with 0 objects.

 @image html doubly-linked-1.png Figure 2 - Doubly-linked list with 1 object.

 @image html doubly-linked-N.png Figure 3 - Doubly-linked list with 2+ objects.
 
 Just as with sentinel nodes used in binary search trees, the object pointer in
 the head and tail nodes can be nil or set to the value being searched for. This
 means there is no need to check whether the next node is null before moving on;
 just stop at the node whose object matches, then check after the match is found
 whether the node containing it was the head/tail or a valid internal node.
 
 The operations \link #insertObject:atIndex: -insertObject:atIndex:\endlink and
 \link #removeObjectAtIndex: -removeObjectAtIndex:\endlink take advantage of the
 bi-directional links, and begin searching for the given index from the closer
 end of the list. To reduce code duplication, all methods that append or prepend
 objects call \link #insertObject:atIndex: -insertObject:atIndex:\endlink, and
 the methods to remove the first or last objects use \link #removeObjectAtIndex:
 -removeObjectAtIndex:\endlink underneath. (Note that \link #removeObject:
 -removeObject:\endlink removes all occurrences of an object. To remove only the
 first occurrence, use \link #indexOfObject: -indexOfObject:\endlink and \link
 #removeObjectAtIndex: -removeObjectAtIndex:\endlink instead.)
 
 Doubly-linked lists are well-suited as an underlying collection for other data
 structures, such as a @a deque (double-ended queue) like the one declared in
 CHListDeque. The same functionality can be achieved using a circular buffer and
 an array, and many libraries choose to do so when objects are only added to or
 removed from the ends, but the dynamic structure of a linked list is much more
 flexible when inserting and deleting in the middle of a list.
 */
@interface CHDoublyLinkedList : NSObject <CHLinkedList> {
	NSUInteger count; /**< The number of objects currently in the list. */
	CHDoublyLinkedListNode *head; /**< A dummy node at the front of the list. */
	CHDoublyLinkedListNode *tail;   /**< A dummy node at the back of the list. */
	unsigned long mutations; /**< Tracks mutations for NSFastEnumeration. */
}

/**
 Returns an enumerator that accesses each object in the list from back to front.
 
 NOTE: When using an enumerator, you must not modify the list during enumeration.
 */
- (NSEnumerator*) reverseObjectEnumerator;

@end
