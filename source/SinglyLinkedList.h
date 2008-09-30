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

//  SinglyLinkedList.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "LinkedList.h"

/**
 A singly-linked struct for nodes use by SinglyLinkedList. Performance is much faster
 with a struct than with a proper object. In addition, the requirements for time and
 memory can be reduced when only one link is stored and maintained for each node.
 */
typedef struct SinglyLinkedListNode {
	id data; /**< The object associated with this node in the list. */
	struct SinglyLinkedListNode *next; /**< The next node in the list. */
} SinglyLinkedListNode;

#pragma mark -


@interface SinglyLinkedList : NSObject <LinkedList> {
	NSUInteger listSize; /**< The number of object currently stored in the list. */
	SinglyLinkedListNode *head;  /**< A pointer to the front node of the list. */
	SinglyLinkedListNode *tail;  /**< A pointer to the back node of the list. */
}

#pragma mark Method Implementations

- (id) initWithObjectsFromEnumerator:(NSEnumerator*)enumerator;
- (NSUInteger) count;
- (void) prependObject:(id)anObject;
- (void) prependObjectsFromEnumerator:(NSEnumerator*)enumerator;
- (void) appendObject:(id)anObject;
- (void) appendObjectsFromEnumerator:(NSEnumerator*)enumerator;
- (id) firstObject;
- (id) lastObject;
- (NSArray*) allObjects;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSEnumerator*) objectEnumerator;
- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeObject:(id)anObject;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) removeAllObjects;
- (NSEnumerator*) objectEnumerator;

// Doesn't currently support index-based operations or inserting in the middle

@end
