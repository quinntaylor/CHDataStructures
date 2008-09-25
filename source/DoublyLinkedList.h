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
typedef struct DoublyLinkedNode {
    struct DoublyLinkedNode *next; /**< The next node in the list. */
    struct DoublyLinkedNode *prev; /**< The previous node in the list. */
    id data; /**< The object associated with this node in the list. */
} DoublyLinkedNode;

/** A simplification for malloc'ing list nodes. */
#define NODESIZE sizeof(struct DoublyLinkedNode)

#pragma mark -

/**
 A standard doubly-linked list implementation with pointers to head and tail.
 I call it standard because I have no plans to implement a singly-linked list...
 Does the extra pointer for each node really add that much excess?
 
 Nodes are now represented with C structs rather than Obj-C classes, providing much
 faster performance. (Thanks to Max Horn for the suggestion and additional guidance.)
 The protocols and interfaces also follow Apple's collection APIs more closely.
 */
@interface DoublyLinkedList : NSObject <LinkedList>
{
    int listSize; /**< The number of object currently stored in the list. */
    DoublyLinkedNode *beginMarker; /**< A pointer to the front node of the list. */
    DoublyLinkedNode *endMarker;   /**< A pointer to the back node of the list. */
}

//a bonus method.  supplies an enumerator that goes backwards
//meaning from tail to head.
- (NSEnumerator *) reverseObjectEnumerator;

#pragma mark Inherited Methods
- (void) addObjectToFront:(id)anObject;
- (void) addObjectToBack:(id)anObject;
- (id) firstObject;
- (id) lastObject;
- (unsigned int) count;
- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (void) insertObject:(id)anObject atIndex:(unsigned int)index;
- (id) objectAtIndex:(unsigned int)index;
- (NSEnumerator *) objectEnumerator;
- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeObject:(id)anObject;
- (void) removeObjectAtIndex:(unsigned int)index;
- (void) removeObjectIdenticalTo:(id)anObject;
- (void) removeAllObjects;

#pragma mark Redefined Methods
+ (DoublyLinkedList *) listWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
