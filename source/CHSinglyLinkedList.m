/*
 CHSinglyLinkedList.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import "CHSinglyLinkedList.h"

static NSUInteger kSinglyLinkedListNodeSize = sizeof(CHSinglyLinkedListNode);

/**
 An NSEnumerator for traversing a CHSinglyLinkedList from front to back.
 */
@interface CHSinglyLinkedListEnumerator : NSEnumerator {
	CHSinglyLinkedList *collection; /**< The source of enumerated objects. */
	CHSinglyLinkedListNode *current; /**< The next node to be enumerated. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */
}

/**
 Create an enumerator which traverses a singly-linked list from front to back.
 
 @param list The linked list collection being enumerated. This collection is to
             be retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param mutations A pointer to the collection's mutation count, for invalidation.
 */
- (id) initWithList:(CHSinglyLinkedList*)list
          startNode:(CHSinglyLinkedListNode*)startNode
    mutationPointer:(unsigned long*)mutations;

/**
 Returns the next object in the collection being enumerated.
 
 @return The next object in the collection being enumerated, or <code>nil</code>
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

@implementation CHSinglyLinkedListEnumerator

- (id) initWithList:(CHSinglyLinkedList*)list
          startNode:(CHSinglyLinkedListNode*)startNode
    mutationPointer:(unsigned long*)mutations;
{
	if ([super init] == nil) return nil;
	collection = (startNode != NULL) ? collection = [list retain] : nil;
	current = startNode; // If startNode is NULL, both methods will return nil.
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
	current = current->next;
	return object;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (current != NULL) {
		[array addObject:current->object];
		current = current->next;
	}
	[collection release];
	collection = nil;
	return [array autorelease];
}

@end

#pragma mark -

// These macros require "SinglyLinkedListNode *node" and "NSUInteger nodeIndex".

// Sets "node" to point to the node found at the given index
#define findNodeAtIndex(i) \
        { node=head; nodeIndex=0; while(i>nodeIndex++) node=node->next; }

// Sets "node" to point to the node found one before the given index
#define findNodeBeforeIndex(i) \
        { node=head; nodeIndex=1; while(i>nodeIndex++) node=node->next; }

// Remove the node with a matching object, steal its 'next' link for my own
#define removeNode(node) \
        { temp = node->next; node->next = temp->next; \
        [temp->object release]; free(temp); --count; ++mutations;}

@implementation CHSinglyLinkedList

- (void) dealloc {
	[self removeAllObjects];
	[super dealloc];
}

- (id) init {
	if ([super init] == nil) return nil;
	head = NULL;
	tail = NULL;
	count = 0;
	mutations = 0;
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[self appendObject:anObject];
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
	if ([super init] == nil) return nil;
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

/**
 Returns a new instance that is a copy of the receiver.
 
 @param zone The zone identifies an area of memory from which to allocate the
        new instance. If zone is <code>NULL</code>, the instance is allocated
        from the default zone.
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. For this class and its children, all copies are mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	CHSinglyLinkedList *newList = [[CHSinglyLinkedList alloc] init];
	for (id anObject in self)
		[newList appendObject:anObject];
	return newList;
}

#pragma mark <NSFastEnumeration> Methods

/**
 Returns by reference a C array of objects over which the sender should iterate,
 and as the return value the number of objects in the array.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHSinglyLinkedListNode *currentNode;
	// On the first call, start at head, otherwise start at last saved node
	if (state->state == 0) {
		currentNode = head;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		currentNode = (CHSinglyLinkedListNode*) state->state;
	}
	
	// Accumulate objects from the list until we reach the tail, or the maximum
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
	CHSinglyLinkedListNode *new;
	new = malloc(kSinglyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = head;
	head = new;
	if (tail == NULL)
		tail = new;
	++count;
	++mutations;
}

- (void) prependObjectsFromArray:(NSArray*)anArray {
	CHSinglyLinkedListNode *new;
	for (id anObject in [anArray reverseObjectEnumerator]) {
		new = malloc(kSinglyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = head;
		head = new;
		if (tail == NULL)
			tail = new;
	}
	count += [anArray count];
	++mutations;
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	CHSinglyLinkedListNode *new;
	new = malloc(kSinglyLinkedListNodeSize);
	new->object = [anObject retain];
	new->next = NULL;
	if (tail == NULL)
		head = new;
	else
		tail->next = new;
	tail = new;
	++count;
	++mutations;
}

- (void) appendObjectsFromArray:(NSArray*)anArray {
	CHSinglyLinkedListNode *new;
	for (id anObject in anArray) {
		new = malloc(kSinglyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = NULL;
		if (tail == NULL)
			head = new;
		else
			tail->next = new;
		tail = new;
	}
	count += [anArray count];
	++mutations;
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (index >= count || index < 0)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	
	if (index == 0)
		[self prependObject:anObject];
	else {
		CHSinglyLinkedListNode *node;
		NSUInteger nodeIndex;
		findNodeBeforeIndex(index);
		
		CHSinglyLinkedListNode *new;
		new = malloc(kSinglyLinkedListNodeSize);
		new->object = [anObject retain];
		new->next = node->next;
		node->next = new;
		++count;
		++mutations;
	}
}

#pragma mark Access

- (NSUInteger) count {
	return count;
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
	return [[[CHSinglyLinkedListEnumerator alloc]
              initWithList:self
                 startNode:head
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
	if (count > 0) {
		CHSinglyLinkedListNode *current = head;
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
	if (count > 0) {
		CHSinglyLinkedListNode *current = head;
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
	if (index >= count || index < 0)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	
	CHSinglyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);
	
	return node->object;
}

#pragma mark Removal

- (void) removeFirstObject {
	if (count == 0)
		return;
	CHSinglyLinkedListNode *old = head;
	[head->object release];
	head = head->next;
	if (tail == old)
		tail = NULL;
	free(old);
	--count;
	++mutations;
}

- (void) removeLastObject {
	if (count == 0)
		return;
	if (head == tail) {
		[head->object release];
		free(head);
		head = tail = NULL;
		count = 0;
		++mutations;
	}
	// This is the expensive part: O(n) instead of O(1) for doubly-linked lists
	else {
		CHSinglyLinkedListNode *old = head;
		// Iterate to penultimate node
		while (old->next != tail)
			old = old->next;
		// Delete current last node, move tail back one node
		[tail->object release];
		free(tail);
		old->next = NULL;
		tail = old;
		--count;
		++mutations;
	}
}

- (void) removeObject:(id)anObject {
	if (count == 0)
		return;
	if ([head->object isEqual:anObject]) {
		[self removeFirstObject];
		return;
	}
	CHSinglyLinkedListNode *node = head, *temp;
	do {
		// Iterate until the next node contains the object to remove, or is nil
		while (node->next != NULL && ![node->next->object isEqual:anObject])
			node = node->next;
		if (node->next != NULL)
			removeNode(node); // ++mutations
	} while (node->next != NULL);
	++mutations;
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (count == 0)
		return;
	if (head->object == anObject) {
		[self removeFirstObject];
		return;
	}
	CHSinglyLinkedListNode *node = head, *temp;
	do {
		// Iterate until the next node contains the object to remove, or is nil
		while (node->next != NULL && node->next->object != anObject)
			node = node->next;
		if (node->next != NULL)
			removeNode(node); // ++mutations
	} while (node->next != NULL);
	++mutations;
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count || index < 0)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	
	if (index == 0)
		[self removeFirstObject];
	else {
		CHSinglyLinkedListNode *node, *temp;
		NSUInteger nodeIndex;
		findNodeBeforeIndex(index);
		removeNode(node); // ++mutations, assigns the node's address to 'temp'
		if (tail == temp)
			tail = node;
	}
}

- (void) removeAllObjects {
	if (count > 0) {
		CHSinglyLinkedListNode *temp;
		while (head != NULL) {
			temp = head;
			head = head->next;
			[temp->object release];
			free(temp);
		}
		tail = NULL;
		count = 0;
	}
	++mutations;
}

@end
