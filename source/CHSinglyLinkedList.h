/*
 CHSinglyLinkedList.h
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

// A struct for nodes in a CHSinglyLinkedList. Performance is faster than an object.
typedef struct CHSinglyLinkedListNode {
	id object; /**< The object associated with this node in the list. */
	struct CHSinglyLinkedListNode *next; /**< The next node in the list. */
} CHSinglyLinkedListNode;

#pragma mark -

/**
 A standard singly-linked list implementation with pointers to head and tail. This is
 ideally suited for use in LIFO and FIFO structures (stacks and queues). The lack of
 backwards links prevents backwards enumeration, and removing from the tail of the
 list is O(n), rather than O(1). However, other operations should be slightly faster.
 Nodes are now represented with C structs rather than Obj-C classes, providing much
 faster performance.
 */

@interface CHSinglyLinkedList : NSObject <CHLinkedList> {
	NSUInteger listSize; /**< The number of object currently stored in the list. */
	CHSinglyLinkedListNode *head;  /**< A pointer to the front node of the list. */
	CHSinglyLinkedListNode *tail;  /**< A pointer to the back node of the list. */
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}

@end
