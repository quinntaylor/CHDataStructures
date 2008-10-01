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

/**
 @todo Clean up methods for insertion and search.
 */
@implementation DoublyLinkedList

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	
	// set up the markers pointing to each other	
	beginMarker = malloc(kDoublyLinkedListNodeSize);
	endMarker = malloc(kDoublyLinkedListNodeSize);
	
	beginMarker->next = endMarker;
	beginMarker->prev = NULL;
	beginMarker->object = nil;
	
	endMarker->next = NULL;
	endMarker->prev = beginMarker;
	endMarker->object = nil;
	
	return self;
}

- (void) dealloc {
	[self removeAllObjects];
	if (beginMarker != NULL) {
		[beginMarker->object release];
		free(beginMarker);
	}
	if (endMarker != NULL) {
		[endMarker->object release];
		free(endMarker);
	}
	[super dealloc];
}

- (NSUInteger) count {
	return listSize;
}

- (DoublyLinkedListNode*) _findPos:(id)anObject identical:(BOOL)identical {
	if (anObject == nil)
		return nil;
	
	// simply iterate through
	DoublyLinkedListNode *p;
	for (p = beginMarker->next; p != endMarker; p = p->next) {
		if (!identical) {
			if ([anObject isEqual:p->object])
				return p;
		}
		else {
			if (anObject == p->object)
				return p;
		}
	}
	return nil; // not found
}

- (DoublyLinkedListNode*) _nodeAtIndex:(NSUInteger)index {
	NSUInteger i;
	DoublyLinkedListNode *p; //a runner, also our return val
	
	// need to handle special case -- they can "insert it" at the index of the size
	// of the list (in other words, at the end) but not beyond.
	if (index > listSize)
		return nil;
	else if (index == 0)
		return beginMarker->next;
	
	if (index < listSize / 2) {
		p = beginMarker->next;
		for (i = 0; i < index; ++i)
			p = p->next;
	}
	else {
		// note that we start at the tail itself, because we may just be displacing
		// it with a new object at the end.
		p = endMarker;
		for (i = listSize; i > index; --i)
			p = p->prev;
	}
	return p;
}

- (BOOL) containsObject:(id)anObject {
	// if that returns nil, we'll return NO automagically
	return ([self _findPos:anObject identical:NO] != nil);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([self _findPos:anObject identical:YES] != nil);
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		invalidNilArgumentException([self class], _cmd);
	
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

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		invalidNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:0];
}

- (void) prependObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		invalidNilArgumentException([self class], _cmd);
	for (id object in enumerator)
		[self insertObject:object atIndex:0];	
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		invalidNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:listSize];
}

- (void) appendObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		invalidNilArgumentException([self class], _cmd);
	for (id object in enumerator)
		[self insertObject:object atIndex:listSize];
}

- (id) firstObject {
	DoublyLinkedListNode *theNode = [self _nodeAtIndex:0];
	return theNode->object;
}

- (id) lastObject {
	DoublyLinkedListNode *theNode = [self _nodeAtIndex:(listSize - 1)];
	return theNode->object;
}

- (NSArray*) allObjects {
	return [[self objectEnumerator] allObjects];
}

- (id) objectAtIndex:(NSUInteger)index {
	DoublyLinkedListNode *theNode = [self _nodeAtIndex:index];
	if (theNode == nil)
		return nil;
	return theNode->object;
}

- (void) _removeNode:(DoublyLinkedListNode*)node {
	if (node == nil || node == beginMarker || node == endMarker)
		return;
	
	// Patch neighboring nodes together, then release this node
	node->next->prev = node->prev;
	node->prev->next = node->next;
	[node->object release];
	free(node);
	--listSize;
}

- (void) removeFirstObject {
	[self _removeNode:(beginMarker->next)];
}

- (void) removeLastObject {
	[self _removeNode:(endMarker->prev)];
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	[self _removeNode:[self _nodeAtIndex:index]];
}

- (void) removeObject:(id)anObject {
	[self _removeNode:[self _findPos:anObject identical:NO]]; // checks for nil, etc.
}

- (void) removeObjectIdenticalTo:(id)anObject {
	[self _removeNode:[self _findPos:anObject identical:YES]]; // checks for nil, etc.
}

- (void) removeAllObjects {
	DoublyLinkedListNode *runner, *old;
	
	runner = beginMarker->next;
	
	while (runner != endMarker) {
		old = runner;  runner = runner->next;
		[old->object release];
		free(old);
	}
	
	listSize = 0;
	
	beginMarker->next = endMarker;
	endMarker->prev = beginMarker;
}

- (NSEnumerator*) objectEnumerator {
	return [[[DoublyLinkedListEnumerator alloc]
			 initWithStartNode:beginMarker] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [[[DoublyLinkedListEnumerator alloc]
			 initWithStartNode:endMarker] autorelease];
}

@end
