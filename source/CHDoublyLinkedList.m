/*
 CHDataStructures.framework -- CHDoublyLinkedList.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHDoublyLinkedList.h"

static size_t kCHDoublyLinkedListNodeSize = sizeof(CHDoublyLinkedListNode);

/**
 An NSEnumerator for traversing a CHDoublyLinkedList in forward or reverse order.
 */
@interface CHDoublyLinkedListEnumerator : NSEnumerator {
	CHDoublyLinkedList *collection; /**< The source of enumerated objects. */
	CHDoublyLinkedListNode *current; /**< The next node to be enumerated. */
	CHDoublyLinkedListNode *sentinel; /**< The node that signifies completion. */
	BOOL reverse; /**< Whether the enumerator is proceeding from back to front. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */
}

/**
 Create an enumerator which traverses a list in either forward or revers order.
 
 @param list The linked list collection being enumerated. This collection is to
        be retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param endNode The node which signifies that enumerations should terminate.
 @param direction The direction in which to enumerate. If greater than zero, uses
        <code>NSOrderedDescending</code>, else <code>NSOrderedAscending</code>.
 @param mutations A pointer to the collection's mutation count, for invalidation.
 
 The enumeration direction is inferred from the state of the provided start node.
 If <code>startNode->next</code> is <code>NULL</code>, enumeration proceeds from
 back to front; otherwise, enumeration proceeds from front to back. This works
 since the head and tail nodes always have NULL for their <code>prev</code> and
 <code>next</code> links, respectively. When there is only one node, order won't
 matter anyway.
 
 This enumerator doesn't support enumerating over a sub-list of nodes. (When a
 node from the middle is provided, enumeration will proceed towards the tail.)
 */
- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
            endNode:(CHDoublyLinkedListNode*)endNode
          direction:(NSComparisonResult)direction
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

@implementation CHDoublyLinkedListEnumerator

- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
            endNode:(CHDoublyLinkedListNode*)endNode
          direction:(NSComparisonResult)direction
    mutationPointer:(unsigned long*)mutations;
{
	if ([super init] == nil) return nil;
	collection = ([list count] > 0) ? [list retain] : nil;
	current = startNode;
	sentinel = endNode;
	reverse = (direction > 0) ? YES : NO;
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
	if (current == sentinel) {
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
	while (current != sentinel) {
		[array addObject:current->object];
		current = (reverse) ? current->prev : current->next;
	}
	[collection release];
	collection = nil;
	return [array autorelease];
}

@end

#pragma mark -

// Creates variable "node" and points it at the node found at the given index.
#define findNodeAtIndex(i) \
	if (i > count || i < 0) \
		CHIndexOutOfRangeException([self class], _cmd, index, count); \
	CHDoublyLinkedListNode *node; \
	NSUInteger nodeIndex; \
	if (i < count/2) { \
		node = head->next; \
		nodeIndex = 0; \
		while (i > nodeIndex++) \
			node = node->next; \
	} else { \
		node = tail; \
		nodeIndex = count; \
		while (i < nodeIndex--) \
			node = node->prev; \
	}

// Remove the specified node, patching prev/next links of neighbors around it.
#define removeNode(node) \
	{ \
		node->prev->next = node->next; node->next->prev = node->prev; \
		if (!objc_collectingEnabled() && node != NULL) { \
			[node->object release]; \
			free(node); \
		} \
		--count; ++mutations; \
	}

@implementation CHDoublyLinkedList

- (void) dealloc {
	[self removeAllObjects];
	free(head);
	free(tail);
	[super dealloc];
}

- (id) init {
	if ([super init] == nil) return nil;
	head = NSAllocateCollectable(kCHDoublyLinkedListNodeSize, NSScannedOption);
	tail = NSAllocateCollectable(kCHDoublyLinkedListNodeSize, NSScannedOption);
	head->object = tail->object = nil;
	head->next = tail;
	head->prev = NULL;
	tail->next = NULL;
	tail->prev = head;
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

#pragma mark <NSCoding>

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"objects"]];
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	NSArray *array = [[self objectEnumerator] allObjects];
	[encoder encodeObject:array forKey:@"objects"];
}

#pragma mark <NSCopying>

/**
 Returns a new instance that is a copy of the receiver.
 
 @param zone The zone identifies an area of memory from which to allocate the
        new instance. If zone is <code>NULL</code>, the instance is allocated
        from the default zone.
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. For this class and its children, all copies are mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	CHDoublyLinkedList *newList = [[CHDoublyLinkedList alloc] init];
	for (id anObject in self)
		[newList appendObject:anObject];
	return newList;
}

#pragma mark <NSFastEnumeration>

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
	CHDoublyLinkedListNode *currentNode;
	// On the first call, start at head, otherwise start at last saved node
	if (state->state == 0) {
		currentNode = head->next;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		currentNode = (CHDoublyLinkedListNode*) state->state;
	}
	
	// Accumulate objects from the list until we reach the tail, or the maximum
    NSUInteger batchCount = 0;
    while (currentNode != tail && batchCount < len) {
        stackbuf[batchCount] = currentNode->object;
        currentNode = currentNode->next;
		batchCount++;
    }
	if (currentNode == tail)
		state->state = 1; // used as a termination flag
	else
		state->state = (unsigned long)currentNode;
    return batchCount;
}

#pragma mark Insertion

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:0];
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:count];
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (index < 0 || index > count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);

	findNodeAtIndex(index); // If found, the node is stored in "node"
	CHDoublyLinkedListNode *newNode;
	newNode = NSAllocateCollectable(kCHDoublyLinkedListNodeSize, NSScannedOption);
	newNode->object = [anObject retain];
	newNode->next = node;          // point forward to displaced node
	newNode->prev = node->prev;    // point backward to preceding node
	newNode->prev->next = newNode; // point preceding node forward to new node
	node->prev = newNode;          // point displaced node backward to new node
	++count;
	++mutations;
}

#pragma mark Access

- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	tail->object = nil;
	return head->next->object; // nil if there are no objects between head/tail
}

- (id) lastObject {
	head->object = nil;
	return tail->prev->object; // nil if there are no objects between head/tail
}

- (NSArray*) allObjects {
	return [[self objectEnumerator] allObjects];
}

- (NSEnumerator*) objectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
	          initWithList:self
	             startNode:head->next
	               endNode:tail
	             direction:NSOrderedAscending
	       mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
	          initWithList:self
	             startNode:tail->prev
	               endNode:head
	             direction:NSOrderedDescending
	       mutationPointer:&mutations] autorelease];
}

#pragma mark Search

- (BOOL) containsObject:(id)anObject {
	return ([self indexOfObject:anObject] != CHNotFound);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([self indexOfObjectIdenticalTo:anObject] != CHNotFound);
}

- (NSUInteger) indexOfObject:(id)anObject {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (![current->object isEqual:anObject]) {
		current = current->next;
		++index;
	}
	return (current == tail) ? CHNotFound : index;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (current->object != anObject) {
		current = current->next;
		++index;
	}
	return (current == tail) ? CHNotFound : index;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	findNodeAtIndex(index); // If found, the node is stored in "node"
	return node->object;
}

#pragma mark Removal

- (void) removeFirstObject {
	if (count == 0)
		return;
	CHDoublyLinkedListNode *node = head->next;
	removeNode(node); // don't use head->next directly; macro treats as L-value
}

- (void) removeLastObject {
	if (count == 0)
		return;
	CHDoublyLinkedListNode *node = tail->prev;
	removeNode(node); // don't use tail->prev directly; macro treats as L-value
}

- (void) removeObject:(id)anObject {
	if (count == 0)
		return;
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while ([node->object compare:anObject] != NSOrderedSame)
			node = node->next;
		if (node != tail) {
			temp = node->next;
			removeNode(node);
			node = temp;
		}
	} while (node != tail);
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (count == 0)
		return;
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while (node->object != anObject)
			node = node->next;
		if (node != tail) {
			temp = node->next;
			removeNode(node);
			node = temp;
		}
	} while (node != tail);
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	findNodeAtIndex(index); // If found, the node is stored in "node"
	removeNode(node);
}

- (void) removeAllObjects {
	if (count > 0 && !objc_collectingEnabled()) {
		// Only bother with free() calls if garbage collection is NOT enabled.
		CHDoublyLinkedListNode *node = head->next, *temp;
		while (node != tail) {
			temp = node->next;
			[node->object release];
			free(node);
			node = temp;
		}
	}
	head->next = tail;
	tail->prev = head;
	count = 0;
	++mutations;
}

@end
