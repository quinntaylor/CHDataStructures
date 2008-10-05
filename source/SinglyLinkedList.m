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

//  SinglyLinkedList.m
//  DataStructuresFramework

#import "SinglyLinkedList.h"

static NSUInteger kSinglyLinkedListNodeSize = sizeof(SinglyLinkedListNode);

/**
 An NSEnumerator for traversing a SinglyLinkedList from front to back.
 */
@interface SinglyLinkedListEnumerator : NSEnumerator {
	SinglyLinkedListNode *current; /**< The next node that is to be enumerated. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;
}

/**
 Create an enumerator which traverses a given list in the specified order.
 
 @param startNode The node at which to begin the enumeration.
 @param mutations A pointer to the collection's count of mutations, for invalidation.
 */
- (id) initWithStartNode:(SinglyLinkedListNode*)startNode
         mutationPointer:(unsigned long*)mutations;

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

@implementation SinglyLinkedListEnumerator

- (id) initWithStartNode:(SinglyLinkedListNode*)startNode
         mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	current = startNode; // If startNode is NULL, nothing will be returned, anyway.
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;	
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		mutatedCollectionException([self class], _cmd);
	if (current == NULL)
		return nil;
	id object = current->object;
	current = current->next;
	return object;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		mutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (current != NULL) {
		[array addObject:current->object];
		current = current->next;
	}
	return [array autorelease];	
}

@end

#pragma mark -

@implementation SinglyLinkedList

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
	[self removeAllObjects]; // frees every node struct
	[super dealloc];
}

- (NSUInteger) count {
	return listSize;
}

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	SinglyLinkedListNode *new;
	new = malloc(kSinglyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = head;
	head = new;
	if (tail == NULL)
		tail = new;
	++listSize;
	++mutations;
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	SinglyLinkedListNode *new;
	new = malloc(kSinglyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = NULL;
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
	return [[[SinglyLinkedListEnumerator alloc]
			 initWithStartNode:head
			 mutationPointer:&mutations] autorelease];
}

- (BOOL) containsObject:(id)anObject {
	if (listSize > 0) {
		SinglyLinkedListNode *current = head;
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
		SinglyLinkedListNode *current = head;
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
	SinglyLinkedListNode *old = head;
	[head->object release];
	head = head->next;
	if (tail == old)
		tail = NULL;
	free(old);
	--listSize;
	++mutations;
}

- (void) removeLastObject {
	if (listSize == 0)
		return;
	if (head == tail) {
		[head->object release];
		free(head);
		head = tail = NULL;
		listSize = 0;
	}
	// This is the expensive part: O(n) instead of O(1) for doubly-linked lists
	else {
		SinglyLinkedListNode *old = head;
		// Iterate to penultimate node
		while (old->next != tail)
			old = old->next;
		// Delete current last node, move tail back one node
		[tail->object release];
		free(tail);
		old->next = NULL;
		tail = old;
		--listSize;
		++mutations;
	}
}

- (void) removeObject:(id)anObject {
	if (listSize == 0)
		return;
	if ([head->object isEqual:anObject]) {
		[self removeFirstObject];
		return;
	}
	SinglyLinkedListNode *node = head;
	// Iterate until the next node contains the object to remove, or is nil
	while (node->next != NULL && ![node->next->object isEqual:anObject])
		node = node->next;
	if (node->next != NULL) {
		// Remove the node with a matching object, steal its 'next' link for my own
		SinglyLinkedListNode *temp = node->next;
		node->next = temp->next;
		[temp->object release];
		free(temp);
		--listSize;
		++mutations;
	}
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (listSize == 0)
		return;
	if (head->object == anObject) {
		[self removeFirstObject];
		return;
	}
	SinglyLinkedListNode *node = head;
	// Iterate until the next node contains the object to remove, or is nil
	while (node->next != NULL && node->next->object != anObject)
		node = node->next;
	if (node->next != NULL) {
		// Remove the node with a matching object, steal its 'next' link for my own
		SinglyLinkedListNode *temp = node->next;
		node->next = temp->next;
		[temp->object release];
		free(temp);
		--listSize;
		++mutations;
	}	
}

- (void) removeAllObjects {
	SinglyLinkedListNode *temp;
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

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(id*)stackbuf
                                    count:(NSUInteger)len
{
	SinglyLinkedListNode *currentNode;
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
		currentNode = (SinglyLinkedListNode*) state->state;
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
