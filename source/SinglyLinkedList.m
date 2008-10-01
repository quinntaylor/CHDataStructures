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
}

/**
 Create an enumerator which traverses a given list in the specified order.
 
 @param startNode The node at which to begin the enumeration.
 */
- (id) initWithStartNode:(SinglyLinkedListNode*)startNode;

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

- (id) initWithStartNode:(SinglyLinkedListNode*)startNode {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	current = startNode; // If startNode is NULL, nothing will be returned, anyway.
	return self;	
}

- (id) nextObject {
	if (current == NULL)
		return nil;
	id object = current->object;
	current = current->next;
	return object;
}

- (NSArray*) allObjects {
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
		invalidNilArgumentException([self class], _cmd);
	SinglyLinkedListNode *new;
	new = malloc(kSinglyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = head;
	head = new;
	if (tail == NULL)
		tail = new;
	listSize++;
}

- (void) prependObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		invalidNilArgumentException([self class], _cmd);
	SinglyLinkedListNode *new;
	for (id anObject in enumerator) {
		new = malloc(kSinglyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = head;
		head = new;
		if (tail == NULL)
			tail = new;
		listSize++;
	}
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		invalidNilArgumentException([self class], _cmd);
	SinglyLinkedListNode *new;
	new = malloc(kSinglyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = NULL;
	if (tail == NULL)
		head = new;
	else
		tail->next = new;
	tail = new;
	listSize++;
}

- (void) appendObjectsFromEnumerator:(NSEnumerator*)enumerator {
	if (enumerator == nil)
		invalidNilArgumentException([self class], _cmd);
	SinglyLinkedListNode *new;
	for (id anObject in enumerator) {
		new = malloc(kSinglyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = NULL;
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
	return [[[SinglyLinkedListEnumerator alloc] initWithStartNode:head] autorelease];
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
	if (head == NULL)
		return;
	[head->object release];
	if (tail == head)
		tail = NULL;
	SinglyLinkedListNode *old = head;
	head = head->next;
	free(old);
	listSize--;
}

/**
 NOTE: Removing from the end of a singly-linked list is O(n) complexity!
 */
- (void) removeLastObject {
	if (listSize == 0)
		return;
	if (head == tail) {
		[head->object release];
		free(head);
		head = tail = NULL;
		listSize = 0;
	}
	else {
		SinglyLinkedListNode *current = head;
		// Iterate to penultimate node
		while (current->next != tail)
			current = current->next;
		// Delete current last node, move tail back one node
		[tail->object release];
		free(tail);
		current->next = NULL;
		tail = current;
		listSize--;
	}
}

- (void) removeObject:(id)anObject {
	if (listSize == 0)
		return;
	if ([head->object isEqual:anObject]) {
		[self removeFirstObject];
		return;
	}
	SinglyLinkedListNode *current = head;
	// Iterate until the next node contains the object to remove, or is nil
	while (current->next != nil && ![current->next->object isEqual:anObject])
		current = current->next;
	if (current->next != nil) {
		// Remove the node with a matching object, steal its 'next' link for my own
		SinglyLinkedListNode *temp = current->next;
		current->next = temp->next;
		[temp->object release];
		free(temp);
		listSize--;
	}
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (listSize == 0)
		return;
	if (head->object == anObject) {
		[self removeFirstObject];
		return;
	}
	SinglyLinkedListNode *current = head;
	// Iterate until the next node contains the object to remove, or is nil
	while (current->next != nil && current->next->object != anObject)
		current = current->next;
	if (current->next != nil) {
		// Remove the node with a matching object, steal its 'next' link for my own
		SinglyLinkedListNode *temp = current->next;
		current->next = temp->next;
		[temp->object release];
		free(temp);
		listSize--;
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
}

@end
