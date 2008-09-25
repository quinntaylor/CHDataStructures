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
 A doubly-linked struct for nodes in DoublyLinkedList. Performance is much faster
 with a struct than with a proper object.
 */
typedef struct DoublyLinkedNode {
    struct DoublyLinkedNode *next;
    struct DoublyLinkedNode *prev;
    id data;
} DoublyLinkedNode;

/** A simplification for malloc'ing list nodes. */
#define NODESIZE sizeof(struct DoublyLinkedNode)

/**
 A standard doubly-linked LinkedList implementation.
 I called it Standard because i have no plans to implement a singly-linked
 list...i really don't think the extra pointers matter too much when
 you're using OO technology with its lot of excess pointers, do they?
 */

/**
 A pretty standard linked list class with a header and tail.
 This has changed from earlier versions: the nodes are now simple
 C structs rather than Obj C classes -- much faster.
 Max Horn gave me the suggestion.  Thanks Max.
 Max also has helped steer the interfaces and protocols to follow much more
 closely the API you find in Apple's collections classes.
 */

@interface DoublyLinkedList : NSObject <LinkedList>
{
    int listSize;
    DoublyLinkedNode *beginMarker;
    DoublyLinkedNode *endMarker;
}

//a bonus method.  supplies an enumerator that goes backwards
//meaning from tail to head.
- (NSEnumerator *) reverseObjectEnumerator;

#pragma mark Inherited Methods
- (BOOL) addFirst:(id)object;
- (BOOL) addLast:(id)object;
- (id) first;
- (id) last;
- (unsigned int) count;
- (BOOL) containsObject:(id)object;
- (BOOL) containsObjectIdenticalTo:(id)object;
- (BOOL) insertObject:(id)obj atIndex:(unsigned int)index;
- (id) objectAtIndex:(unsigned int)index;
- (NSEnumerator *) objectEnumerator;
- (BOOL) removeFirst;
- (BOOL) removeLast;
- (BOOL) removeObject:(id)obj;
- (BOOL) removeObjectAtIndex:(unsigned int)index;
- (BOOL) removeObjectIdenticalTo:(id)obj;
- (void) removeAllObjects;

#pragma mark Redefined Methods
+ (DoublyLinkedList *) listFromArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
