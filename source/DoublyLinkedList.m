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
	listSize++;
}

- (void) prependObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		nilArgumentException([self class], _cmd);
	DoublyLinkedListNode *new;
	for (id anObject in enumerator) {
		new = malloc(kDoublyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = head;
		new->prev = NULL;
		if (head != NULL)
			head->prev = new;
		head = new;
		if (tail == NULL)
			tail = new;
		listSize++;
	}
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
	listSize++;
}

- (void) appendObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		nilArgumentException([self class], _cmd);
	DoublyLinkedListNode *new;
	for (id anObject in enumerator) {
		new = malloc(kDoublyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = NULL;
		new->prev = tail;
		if (tail == NULL)
			head = new;
		else
			tail->next = new;
		tail = new;
		listSize++;
	}
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
}

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
	if (node != NULL) {
		// Remove the node with a matching object, patch prev/next links around it
		if (node->prev)
			node->prev->next = node->next;
		if (node->next)
			node->next->prev = node->prev;
		[node->object release];
		free(node);
		--listSize;
	}
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
	if (node != NULL) {
		// Remove the node with a matching object, patch prev/next links around it
		if (node->prev)
			node->prev->next = node->next;
		if (node->next)
			node->next->prev = node->prev;
		[node->object release];
		free(node);
		--listSize;
	}
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
}

#pragma mark - Optional Protocol Methods

// TODO: Clean up methods for indexed insertion, search, and removal.

- (DoublyLinkedListNode*) _nodeAtIndex:(NSUInteger)index {
	NSUInteger i;
	DoublyLinkedListNode *p; //a runner, also our return val
	
	// need to handle special case -- they can "insert it" at the index of the size
	// of the list (in other words, at the end) but not beyond.
	if (index > listSize)
		return nil;
	else if (index == 0)
		return head->next;
	
	if (index < listSize / 2) {
		p = head->next;
		for (i = 0; i < index; ++i)
			p = p->next;
	}
	else {
		// note that we start at the tail itself, because we may just be displacing
		// it with a new object at the end.
		p = tail;
		for (i = listSize; i > index; --i)
			p = p->prev;
	}
	return p;
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	if (index >= listSize)
		rangeException([self class], _cmd);
	
	DoublyLinkedListNode *p, *newNode;
	
	// find node to attach to
	// _nodeAtIndex: does range checking, etc., by returning nil on error
	if ((p = [self _nodeAtIndex:index]) == nil)
		return;
	
	newNode = malloc(kDoublyLinkedListNodeSize);
	
	newNode->object = [anObject retain];
	// prev is set to the prev pointer of the node it displaces
	newNode->prev = p->prev;
	// next is set to the node it displaces
	newNode->next = p;
	// previous node is set to point to us as next
	newNode->prev->next = newNode;
	// next node is set to point to us as previous
	p->prev = newNode;
	
	++listSize;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= listSize)
		rangeException([self class], _cmd);
	DoublyLinkedListNode *theNode = [self _nodeAtIndex:index];
	return (theNode == nil) ? nil : theNode->object;
}

- (void) _removeNode:(DoublyLinkedListNode*)node {
	if (node == nil || node == head || node == tail)
		return;
	
	// Patch neighboring nodes together, then release this node
	node->next->prev = node->prev;
	node->prev->next = node->next;
	[node->object release];
	free(node);
	--listSize;
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= listSize)
		rangeException([self class], _cmd);
	[self _removeNode:[self _nodeAtIndex:index]];
}

@end
