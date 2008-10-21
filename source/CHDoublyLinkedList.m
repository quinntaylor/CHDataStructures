//  CHDoublyLinkedList.m
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

#import "CHDoublyLinkedList.h"

static NSUInteger kCHDoublyLinkedListNodeSize = sizeof(CHDoublyLinkedListNode);

/**
 An NSEnumerator for traversing a CHDoublyLinkedList in forward or reverse order.
 */
@interface CHDoublyLinkedListEnumerator : NSEnumerator {
	CHDoublyLinkedList *collection;
	CHDoublyLinkedListNode *current; /**< The next node that is to be enumerated. */
	BOOL reverse; /**< Whether the enumerator is proceeding from back to front. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;
}

/**
 Create an enumerator which traverses a list starting from either the head or tail.
 
 @param list The linked list collection being enumerated. This collection is to be
        retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param mutations A pointer to the collection's count of mutations, for invalidation.
 
 The enumeration direction is inferred from the state of the provided start node. If
 <code>startNode->next</code> is <code>NULL</code>, enumeration proceeds from back to
 front; otherwise, enumeration proceeds from front to back. This works since the head
 and tail nodes always have NULL for their <code>prev</code> and <code>next</code>
 links, respectively. When there is only one node, order doesn't matter anyway.
 
 This enumerator doesn't explicitly support enumerating over a sub-list of nodes. (If
 a node from the middle is provided, enumeration will proceed towards the tail.)
 */
- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
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

@implementation CHDoublyLinkedListEnumerator

- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
    mutationPointer:(unsigned long*)mutations;
{
	if ([super init] == nil)
		return nil;
	collection = (startNode != NULL) ? collection = [list retain] : nil;
	current = startNode; // If startNode is NULL, nothing will be returned, anyway.
	if (startNode != NULL)
		reverse = (startNode->next == nil) ? YES : NO;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
	[super dealloc];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	if (current == NULL) {
		[collection release];
		collection = nil;
		return nil;
	}
	id object = current->object;
	current = (reverse) ? current->prev : current->next;
	return object;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (current != NULL) {
		[array addObject:current->object];
		current = (reverse) ? current->prev : current->next;
	}
	[collection release];
	collection = nil;
	return [array autorelease];
}

@end

#pragma mark -

// Sets "node" to point to the node found at the given index
// Requires that "CHDoublyLinkedListNode *node" and "NSUInteger nodeIndex" be declared.
#define findNodeAtIndex(i) \
        if (i<listSize/2) {\
            node=head; nodeIndex=0; while(i>nodeIndex++) node=node->next;\
        } else {\
            node=tail; nodeIndex=listSize-1; while(i<nodeIndex--) node=node->prev;\
        }

// Remove the node with a matching object, patch prev/next links around it
#define removeNodeFromMiddle(node) { \
        if (node->prev) node->prev->next = node->next; \
        if (node->next) node->next->prev = node->prev; \
        [node->object release]; free(node); --listSize; ++mutations; }

@implementation CHDoublyLinkedList

- (void) dealloc {
	[self removeAllObjects];
	[super dealloc];
}

- (id) init {
	if ([super init] == nil)
		return nil;
	head = NULL;
	tail = NULL;
	listSize = 0;
	mutations = 0;
	return self;
}

- (NSString*) description {
	return [[self allObjects] description];
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super init] == nil)
		return nil;
	for (id anObject in [decoder decodeObjectForKey:@"objects"])
		[self appendObject:anObject];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	NSArray *array = [[self objectEnumerator] allObjects];
	[encoder encodeObject:array forKey:@"objects"];
}

#pragma mark <NSCopying> Methods

- (id) copyWithZone:(NSZone *)zone {
	CHDoublyLinkedList *newList = [[CHDoublyLinkedList alloc] init];
	for (id anObject in self)
		[newList appendObject:anObject];
	return newList;
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHDoublyLinkedListNode *currentNode;
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
		currentNode = (CHDoublyLinkedListNode*) state->state;
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

#pragma mark Insertion

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	CHDoublyLinkedListNode *new;
	new = malloc(kCHDoublyLinkedListNodeSize);
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
		CHNilArgumentException([self class], _cmd);	
	CHDoublyLinkedListNode *new;
	new = malloc(kCHDoublyLinkedListNodeSize);
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

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (index >= listSize || index < 0)
		CHIndexOutOfRangeException([self class], _cmd, index, listSize);
	
	if (index == 0)
		[self prependObject:anObject];
	else {
		CHDoublyLinkedListNode *node;
		NSUInteger nodeIndex;
		findNodeAtIndex(index);
		
		CHDoublyLinkedListNode *newNode;
		newNode = malloc(kCHDoublyLinkedListNodeSize);
		newNode->object = [anObject retain];
		newNode->next = node;          // point to node previously at this index
		newNode->prev = node->prev;    // point to preceding node
		newNode->prev->next = newNode; // point preceding node to new node
		node->prev = newNode;          // point next (displaced) node to new node
		++listSize;
		++mutations;
	}
}

#pragma mark Access

- (NSUInteger) count {
	return listSize;
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
	return [[[CHDoublyLinkedListEnumerator alloc]
              initWithList:self
			 	startNode:head
          mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
              initWithList:self
                 startNode:tail
           mutationPointer:&mutations] autorelease];
}

#pragma mark Search

- (BOOL) containsObject:(id)anObject {
	return ([self indexOfObject:anObject] != NSNotFound);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([self indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) indexOfObject:(id)anObject {
	if (listSize > 0) {
		CHDoublyLinkedListNode *current = head;
		NSUInteger index = 0;
		while (current != NULL) {
			if ([current->object isEqual:anObject])
				return index;
			current = current->next;
			++index;
		}
	}
	return NSNotFound;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	if (listSize > 0) {
		CHDoublyLinkedListNode *current = head;
		NSUInteger index = 0;
		while (current != NULL) {
			if (current->object == anObject)
				return index;
			current = current->next;
			++index;
		}
	}
	return NSNotFound;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= listSize || index < 0)
		CHIndexOutOfRangeException([self class], _cmd, index, listSize);
	
	CHDoublyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);
	return node->object;
}

#pragma mark Removal

- (void) removeFirstObject {
	if (listSize == 0)
		return;
	CHDoublyLinkedListNode *old = head;
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
	CHDoublyLinkedListNode *old = tail;
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

- (void) removeObject:(id)anObject {
	if (listSize == 0)
		return;
	if ([head->object isEqual:anObject]) {
		[self removeFirstObject];
		return;
	}
	CHDoublyLinkedListNode *node = head, *temp;
	do {
		while (node != NULL && ![node->object isEqual:anObject])
			node = node->next;
		if (node != NULL) {
			temp = node->next;
			removeNodeFromMiddle(node);
			node = temp;
		}
	} while (node != NULL);
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (listSize == 0)
		return;
	if (head->object == anObject) {
		[self removeFirstObject];
		return;
	}
	CHDoublyLinkedListNode *node = head, *temp;
	do {
		while (node != NULL && node->object != anObject)
			node = node->next;
		if (node != NULL) {
			temp = node->next;
			removeNodeFromMiddle(node);
			node = temp;
		}
	} while (node != NULL);
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= listSize || index < 0)
		CHIndexOutOfRangeException([self class], _cmd, index, listSize);
	
	if (index == 0)
		[self removeFirstObject];
	else if (index == (listSize - 1))
		[self removeLastObject];
	else {
		CHDoublyLinkedListNode *node;
		NSUInteger nodeIndex;
		findNodeAtIndex(index);
		if (node != NULL)
			removeNodeFromMiddle(node);
	}
}

- (void) removeAllObjects {
	if (listSize > 0) {
		CHDoublyLinkedListNode *temp;
		while (head != NULL) {
			temp = head;
			head = head->next;
			[temp->object release];
			free(temp);
		}
		tail = NULL;
		listSize = 0;
	}
	++mutations;
}

@end
