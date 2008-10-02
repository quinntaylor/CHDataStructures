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

//  StandardLinkedList.m
//  DataStructuresFramework

#import "DoublyLinkedList.h"

static NSUInteger kDoublyLinkedListNodeSize = sizeof(DoublyLinkedListNode);

/**
 An NSEnumerator for traversing a DoublyLinkedList in forward or reverse order.
 */
@interface DoublyLinkedListEnumerator : NSEnumerator {
	DoublyLinkedListNode *current; /**< The next node that is to be enumerated. */
	BOOL reverse; /**< Whether the enumerator is proceeding from back to front. */
}

/**
 Create an enumerator which traverses a list starting from either the head or tail.
 
 @param startNode The node at which to begin the enumeration.
 
 The enumeration direction is inferred from the state of the provided start node. If
 <code>startNode->next</code> is <code>NULL</code>, enumeration proceeds from back to
 front; otherwise, enumeration proceeds from front to back. This works since the head
 and tail nodes always have NULL for their <code>prev</code> and <code>next</code>
 links, respectively. When there is only one node, order doesn't matter anyway.
 
 This enumerator doesn't explicitly support enumerating over a sub-list of nodes. (If
 a node from the middle is provided, enumeration will proceed towards the tail.)
 */
- (id) initWithStartNode:(DoublyLinkedListNode*)startNode;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or <code>nil</code>
         when all objects have been enumerated.
 */
- (id) nextObject;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray*) allObjects;

@end

#pragma mark -

@implementation DoublyLinkedListEnumerator

- (id) initWithStartNode:(DoublyLinkedListNode*)startNode {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	current = startNode; // If startNode is NULL, nothing will be returned, anyway.
	if (startNode != NULL)
		reverse = (startNode->next == nil) ? YES : NO;
	return self;
}

- (id) nextObject {
	if (current == NULL)
		return nil;
	id object = current->object;
	current = (reverse) ? current->prev : current->next;
	return object;
}

- (NSArray*) allObjects {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (current != NULL) {
		[array addObject:current->object];
		current = (reverse) ? current->prev : current->next;
	}
	return [array autorelease];
}

@end

#pragma mark -

@implementation DoublyLinkedList

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	head = NULL;
	tail = NULL;
	listSize = 0;
	mutations = 0;
	return self;
}

- (void) dealloc {
	[self removeAllObjects];
	[super dealloc];
}

- (NSUInteger) count {
	return listSize;
}

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	DoublyLinkedListNode *new;
	new = malloc(kDoublyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = head;
	new->prev = NULL;
	if (head != NULL)
		head->prev = new;
	head = new;
	if (tail == NULL)
		tail = new;
	++listSize;
	++mutations;
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);	
	DoublyLinkedListNode *new;
	new = malloc(kDoublyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = NULL;
	new->prev = tail;
	if (tail == NULL)
		head = new;
	else
		tail->next = new;
	tail = new;
	++listSize;
	++mutations;
}

- (id) firstObject {
	return (head != NULL) ? head->object : nil;
}

- (id) lastObject {
	return (tail != NULL) ? tail->object : nil;
}

- (NSArray*) allObjects {
	return [[self objectEnumerator] allObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [[[DoublyLinkedListEnumerator alloc] initWithStartNode:head] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [[[DoublyLinkedListEnumerator alloc] initWithStartNode:tail] autorelease];
}

- (BOOL) containsObject:(id)anObject {
	if (listSize > 0) {
		DoublyLinkedListNode *current = head;
		while (current != NULL) {
			if ([current->object isEqual:anObject])
				return YES;
			current = current->next;
		}
	}
	return NO;
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	if (listSize > 0) {
		DoublyLinkedListNode *current = head;
		while (current != NULL) {
			if (current->object == anObject)
				return YES;
			current = current->next;
		}
	}
	return NO;
}

- (void) removeFirstObject {
	if (listSize == 0)
		return;
	DoublyLinkedListNode *old = head;
	[head->object release];
	head = head->next;
	if (tail == old)
		tail = NULL;
	if (head)
		head->prev = NULL;
	free(old);
	--listSize;
	++mutations;
}

- (void) removeLastObject {
	if (listSize == 0)
		return;
	DoublyLinkedListNode *old = tail;
	[tail->object release];
	tail = tail->prev;
	if (tail)
		tail->next = NULL;
	if (head == old)
		head = NULL;
	free(old);
	--listSize;
	++mutations;
}

// Remove the node with a matching object, patch prev/next links around it
#define removeNodeFromMiddle(node) \
		if (node != NULL) { \
		if (node->prev) node->prev->next = node->next; \
		if (node->next) node->next->prev = node->prev; \
		[node->object release]; free(node); --listSize; ++mutations; }

- (void) removeObject:(id)anObject {
	if (listSize == 0)
		return;
	if ([head->object isEqual:anObject]) {
		[self removeFirstObject];
		return;
	}
	DoublyLinkedListNode *node = head;
	while (node != NULL && ![node->object isEqual:anObject])
		node = node->next;
	removeNodeFromMiddle(node); // checks for NULL node
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (listSize == 0)
		return;
	if (head->object == anObject) {
		[self removeFirstObject];
		return;
	}
	DoublyLinkedListNode *node = head;
	while (node != NULL && node->object != anObject)
		node = node->next;
	removeNodeFromMiddle(node); // checks for NULL node
}

- (void) removeAllObjects {
	DoublyLinkedListNode *temp;
	while (head != NULL) {
		temp = head;
		head = head->next;
		[temp->object release];
		free(temp);
	}
	tail = NULL;
	listSize = 0;
	++mutations;
}

#pragma mark - Optional Protocol Methods

// Sets "node" to point to the node found at the given index
// Requires that "DoublyLinkedListNode *node" and "NSUInteger nodeIndex" be declared.
#define findNodeAtIndex(i) \
		if (i<listSize/2) {\
			node=head; nodeIndex=0; while(i>nodeIndex++) node=node->next;\
		} else {\
			node=tail; nodeIndex=listSize-1; while(i<nodeIndex--) node=node->prev;\
		}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (index >= listSize)
		rangeException([self class], _cmd, index, listSize);
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	
	DoublyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);
	
	DoublyLinkedListNode *newNode;
	newNode = malloc(kDoublyLinkedListNodeSize);
	newNode->object = [anObject retain];
	newNode->next = node;          // point to node previously at this index
	newNode->prev = node->prev;    // point to preceding node
	newNode->prev->next = newNode; // point preceding node to new node
	node->prev = newNode;          // point following (displaced) node to new node
	++listSize;
	++mutations;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= listSize)
		rangeException([self class], _cmd, index, listSize);
	
	DoublyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);

	return node->object;
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= listSize)
		rangeException([self class], _cmd, index, listSize);
	
	if (index == 0)
		[self removeFirstObject];
	else if (index == (listSize - 1))
		[self removeLastObject];
	else {
		DoublyLinkedListNode *node;
		NSUInteger nodeIndex;
		findNodeAtIndex(index);
		removeNodeFromMiddle(node);		
	}
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
								  objects:(id*)stackbuf
									count:(NSUInteger)len
{
	DoublyLinkedListNode *currentNode;
	// If this is the first call, start at head, otherwise start at last saved node
	if (state->state == 0) {
		currentNode = head;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		currentNode = (DoublyLinkedListNode*) state->state;
	}
	
	// Accumulate objects from the list until we reach the tail, or the maximum limit
    NSUInteger batchCount = 0;
    while (currentNode != NULL && batchCount < len) {
        stackbuf[batchCount] = currentNode->object;
        currentNode = currentNode->next;
		batchCount++;
    }
	if (currentNode == NULL)
		state->state = 1; // used as a termination flag
	else
		state->state = (unsigned long)currentNode;
    return batchCount;
}

@end
