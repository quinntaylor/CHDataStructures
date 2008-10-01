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

//  StandardLinkedList.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "LinkedList.h"

/**
 A doubly-linked struct for nodes use by DoublyLinkedList. Performance is much faster
 with a struct than with a proper object.
 */
typedef struct DoublyLinkedListNode {
	id object; /**< The object associated with this node in the list. */
	struct DoublyLinkedListNode *next; /**< The next node in the list. */
	struct DoublyLinkedListNode *prev; /**< The previous node in the list. */
} DoublyLinkedListNode;

#pragma mark -

/**
 A standard doubly-linked list implementation with pointers to head and tail. The
 extra 'previous' link allows for reverse enumeration and cheap removal from the tail
 of the list. The tradeoff is a little extra storage for each list node, and a little
 extra work when inserting and removing.
 
 Nodes are now represented with C structs rather than Obj-C classes, providing much
 faster performance. (Thanks to Max Horn for the suggestion and additional guidance.)
 */
@interface DoublyLinkedList : NSObject <LinkedList> {
	NSUInteger listSize; /**< The number of object currently stored in the list. */
	DoublyLinkedListNode *head; /**< A pointer to the front node of the list. */
	DoublyLinkedListNode *tail;   /**< A pointer to the back node of the list. */
}

/**
 Returns an enumerator that accesses each object in the list from back to front.
 
 NOTE: When you use an enumerator, you must not modify the list during enumeration.
 */
- (NSEnumerator*) reverseObjectEnumerator;

#pragma mark Method Implementations

- (void) prependObject:(id)anObject;
- (void) prependObjectsFromEnumerator:(NSEnumerator*)enumerator;
- (void) appendObject:(id)anObject;
- (void) appendObjectsFromEnumerator:(NSEnumerator*)enumerator;
- (id) firstObject;
- (id) lastObject;
- (NSUInteger) count;
- (NSArray*) allObjects;
- (NSEnumerator*) objectEnumerator;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) removeAllObjects;

#pragma mark - Optional Protocol Methods

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;
- (id) objectAtIndex:(NSUInteger)index;
- (void) removeObjectAtIndex:(NSUInteger)index;

@end
