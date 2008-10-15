//  CHDoublyLinkedList.h
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

#import <Foundation/Foundation.h>
#import "CHLinkedList.h"

// A struct for nodes in a CHDoublyLinkedList. Performance is faster than an object.
typedef struct CHDoublyLinkedListNode {
	id object; /**< The object associated with this node in the list. */
	struct CHDoublyLinkedListNode *next; /**< The next node in the list. */
	struct CHDoublyLinkedListNode *prev; /**< The previous node in the list. */
} CHDoublyLinkedListNode;

#pragma mark -

/**
 A standard doubly-linked list implementation with pointers to head and tail. The
 extra 'previous' link allows for reverse enumeration and cheap removal from the tail
 of the list. The tradeoff is a little extra storage for each list node, and a little
 extra work when inserting and removing. Nodes are now represented with C structs
 rather than Obj-C classes, providing much faster performance.
 */
@interface CHDoublyLinkedList : NSObject <CHLinkedList> {
	NSUInteger listSize; /**< The number of object currently stored in the list. */
	CHDoublyLinkedListNode *head; /**< A pointer to the front node of the list. */
	CHDoublyLinkedListNode *tail;   /**< A pointer to the back node of the list. */
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}

/**
 Returns an enumerator that accesses each object in the list from back to front.
 
 NOTE: When you use an enumerator, you must not modify the list during enumeration.
 */
- (NSEnumerator*) reverseObjectEnumerator;

@end
