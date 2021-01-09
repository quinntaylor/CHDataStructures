//
//  CHDoublyLinkedList.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//  Copyright © 2002, Phillip Morelock
//

#import <CHDataStructures/CHDoublyLinkedList.h>

static size_t kCHDoublyLinkedListNodeSize = sizeof(CHDoublyLinkedListNode);

/**
 An NSEnumerator for traversing a CHDoublyLinkedList in forward or reverse order.
 */
@interface CHDoublyLinkedListEnumerator : NSEnumerator

@end

@implementation CHDoublyLinkedListEnumerator
{
	CHDoublyLinkedList *collection; // The source of enumerated objects.
	__strong CHDoublyLinkedListNode *current; // The next node to be enumerated.
	__strong CHDoublyLinkedListNode *sentinel; // Node that signifies completion.
	BOOL reverse; // Whether the enumerator is proceeding from back to front.
	unsigned long mutationCount; // Stores the collection's initial mutation.
	unsigned long *mutationPtr; // Pointer for checking changes in mutation.
	NSUInteger remainingCount; ///< Number of elements in @a collection remaining to be enumerated.
}

/**
 Create an enumerator which traverses a list in either forward or revers order.
 
 @param list The linked list collection being enumerated. This collection is to be retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param endNode The node which signifies that enumerations should terminate.
 @param direction The direction in which to enumerate. (@c NSOrderedDescending is back-to-front).
 @param mutations A pointer to the collection's mutation count, for invalidation.
 @return An initialized CHDoublyLinkedListEnumerator which will enumerate objects in @a list in the order specified by @a direction.
 
 The enumeration direction is inferred from the state of the provided start node. If @c startNode->next is @c NULL, enumeration proceeds from back to front; otherwise, enumeration proceeds from front to back. This works since the head and tail nodes always have @c NULL for their @c prev and @c next links, respectively. When there is only one node, order won't matter anyway.
 
 This enumerator doesn't support enumerating over a sub-list of nodes. (When a node from the middle is provided, enumeration will proceed towards the tail.)
 */
- (instancetype)initWithList:(CHDoublyLinkedList *)list
				   startNode:(CHDoublyLinkedListNode *)startNode
					 endNode:(CHDoublyLinkedListNode *)endNode
				   direction:(NSComparisonResult)direction
			 mutationPointer:(unsigned long *)mutations;
{
	if ((self = [super init]) == nil) return nil;
	remainingCount = [list count];
	collection = remainingCount ? [list retain] : nil;
	current = startNode;
	sentinel = endNode;
	reverse = (direction == NSOrderedDescending);
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void)dealloc {
	[collection release];
	[super dealloc];
}

- (id)nextObject {
	if (mutationCount != *mutationPtr)
		CHRaiseMutatedCollectionException();
	if (current == sentinel) {
		[self _collectionExhausted];
		return nil;
	}
	remainingCount--;
	id object = current->object;
	current = (reverse) ? current->prev : current->next;
	return object;
}

- (NSArray *)allObjects {
	if (mutationCount != *mutationPtr)
		CHRaiseMutatedCollectionException();
	if (remainingCount == 0) {
		return @[];
	}
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:remainingCount];
	while (current != sentinel) {
		[array addObject:current->object];
		current = (reverse) ? current->prev : current->next;
	}
	[self _collectionExhausted];
	return [array autorelease];
}

- (void)_collectionExhausted {
	[collection release];
	collection = nil;
	current = nil;
	sentinel = nil;
	remainingCount = 0;
}

@end

#pragma mark -

/** A macro for easily finding the absolute difference between two values. */
#define ABS_DIF(A,B) \
({ __typeof__(A) a = (A); __typeof__(B) b = (B); (a > b) ? (a - b) : (b - a); })

@implementation CHDoublyLinkedList

// An internal method for locating a node at a specific position in the list.
// If the index is invalid, an NSRangeException is raised.
- (CHDoublyLinkedListNode *)nodeAtIndex:(NSUInteger)index {
	CHRaiseIndexOutOfRangeExceptionIf(index, >, count); // If it's equal, we return the dummy tail node
	// Start with the end of the linked list (head or tail) closest to the index
	BOOL closerToHead = (index < count/2);
	CHDoublyLinkedListNode *node = closerToHead ? head->next : tail;
	NSUInteger nodeIndex = closerToHead ? 0 : count;
	// If a node is cached and it's closer to the index, start there instead
	if (cachedNode != NULL && ABS_DIF(index,cachedIndex) < ABS_DIF(index,nodeIndex)) {
		node = cachedNode;
		nodeIndex = cachedIndex;
	}
	// Iterate through the list elements until we find the requested node index
	if (index > nodeIndex) {
		while (index > nodeIndex++)
			node = node->next;
	} else {
		while (index < nodeIndex--)
			node = node->prev;
	}
	// Update cached node and corresponding index (it can never be null here)
	cachedNode = node;
	cachedIndex = index;
	return node;
}

// An internal method for removing a given node and patching up neighbor links.
// Since we use dummy head and tail nodes, there is no need to check for null.
- (void)removeNode:(CHDoublyLinkedListNode *)node {
	node->prev->next = node->next;
	node->next->prev = node->prev;
	[node->object release];
	free(node);
	cachedNode = NULL;
	--count;
	++mutations;
}

#pragma mark -

- (void)dealloc {
	[self removeAllObjects];
	free(head);
	free(tail);
	[super dealloc];
}

- (instancetype)init {
	return [self initWithArray:@[]];
}

// This is the designated initializer for CHDoublyLinkedList
- (instancetype)initWithArray:(NSArray *)anArray {
	if ((self = [super init]) == nil) return nil;
	head = malloc(kCHDoublyLinkedListNodeSize);
	tail = malloc(kCHDoublyLinkedListNodeSize);
	head->object = tail->object = nil;
	head->next = tail;
	head->prev = NULL;
	tail->next = NULL;
	tail->prev = head;
	count = 0;
	mutations = 0;
	for (id anObject in anArray) {
		[self addObject:anObject];
	}
	return self;
}

- (NSString *)description {
	return [[self allObjects] description];
}

#pragma mark <NSCoding>

- (instancetype)initWithCoder:(NSCoder *)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"objects"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[[self objectEnumerator] allObjects] forKey:@"objects"];
}

#pragma mark <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
	CHDoublyLinkedList *newList = [[CHDoublyLinkedList allocWithZone:zone] init];
	for (id anObject in self) {
		[newList addObject:anObject];
	}
	return newList;
}

#pragma mark <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
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
		currentNode = (CHDoublyLinkedListNode *) state->state;
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

#pragma mark Querying Contents

- (NSArray *)allObjects {
	return [[self objectEnumerator] allObjects];
}

- (BOOL)containsObject:(id)anObject {
	return ([self indexOfObject:anObject] != NSNotFound);
}

- (BOOL)containsObjectIdenticalTo:(id)anObject {
	return ([self indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger)count {
	return count;
}

- (id)firstObject {
	tail->object = nil;
	return head->next->object; // nil if there are no objects between head/tail
}

- (NSUInteger)hash {
	return CHHashOfCountAndObjects(count, [self firstObject], [self lastObject]);
}

- (BOOL)isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHLinkedList)])
		return [self isEqualToLinkedList:otherObject];
	else
		return NO;
}

- (BOOL)isEqualToLinkedList:(id<CHLinkedList>)otherLinkedList {
	return CHCollectionsAreEqual(self, otherLinkedList);
}

- (id)lastObject {
	head->object = nil;
	return tail->prev->object; // nil if there are no objects between head/tail
}

- (NSUInteger)indexOfObject:(id)anObject {
	return [self _indexOfObject:anObject withEqualityTest:&CHObjectsAreEqual];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
	return [self _indexOfObject:anObject withEqualityTest:&CHObjectsAreIdentical];
}

- (NSUInteger)_indexOfObject:(id)anObject withEqualityTest:(CHObjectEqualityTest)objectsMatch {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (!objectsMatch(current->object, anObject)) {
		current = current->next;
		++index;
	}
	return (current == tail) ? NSNotFound : index;
}

- (id)objectAtIndex:(NSUInteger)index {
	CHRaiseIndexOutOfRangeExceptionIf(index, >=, count);
	return [self nodeAtIndex:index]->object;
}

- (NSEnumerator *)objectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
	          initWithList:self
	             startNode:head->next
	               endNode:tail
	             direction:NSOrderedAscending
	       mutationPointer:&mutations] autorelease];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
	CHRaiseInvalidArgumentExceptionIfNil(indexes);
	if ([indexes count] == 0) {
		return @[];
	}
	CHRaiseIndexOutOfRangeExceptionIf([indexes lastIndex], >=, count);
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[indexes count]];
	CHDoublyLinkedListNode *current = head;
	NSUInteger nextIndex = [indexes firstIndex], index = 0;
	while (nextIndex != NSNotFound) {
		do
			current = current->next;
		while (index++ < nextIndex);
		[objects addObject:current->object];
		nextIndex = [indexes indexGreaterThanIndex:nextIndex];
	}
	return objects;
}

- (NSEnumerator *)reverseObjectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
	          initWithList:self
	             startNode:tail->prev
	               endNode:head
	             direction:NSOrderedDescending
	       mutationPointer:&mutations] autorelease];
}

#pragma mark Modifying Contents

- (void)addObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	[self insertObject:anObject atIndex:count];
}

- (void)addObjectsFromArray:(NSArray *)anArray {
	for (id anObject in anArray) {
		[self insertObject:anObject atIndex:count];
	}
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	CHRaiseIndexOutOfRangeExceptionIf(idx1, >=, count);
	CHRaiseIndexOutOfRangeExceptionIf(idx2, >=, count);
	if (idx1 != idx2) {
		// Find the nodes as the provided indexes
		CHDoublyLinkedListNode *node1 = [self nodeAtIndex:idx1];
		CHDoublyLinkedListNode *node2 = [self nodeAtIndex:idx2];
		// Swap the objects at the provided indexes
		id tempObject = node1->object;
		node1->object = node2->object;
		node2->object = tempObject;
		++mutations;
	}
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	CHDoublyLinkedListNode *node = [self nodeAtIndex:index];
	CHDoublyLinkedListNode *newNode;
	newNode = malloc(kCHDoublyLinkedListNodeSize);
	newNode->object = [anObject retain];
	newNode->next = node;          // point forward to displaced node
	newNode->prev = node->prev;    // point backward to preceding node
	newNode->prev->next = newNode; // point preceding node forward to new node
	node->prev = newNode;          // point displaced node backward to new node
	cachedNode = newNode;
	cachedIndex = index;
	++count;
	++mutations;
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
	CHRaiseInvalidArgumentExceptionIfNil(objects);
	CHRaiseInvalidArgumentExceptionIfNil(indexes);
	if ([objects count] != [indexes count])
		CHRaiseInvalidArgumentException(@"Unequal object and index counts.");
	NSUInteger index = [indexes firstIndex];
	for (id anObject in objects) {
		[self insertObject:anObject atIndex:index];
		index = [indexes indexGreaterThanIndex:index];
	}
}

- (void)prependObject:(id)anObject {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	[self insertObject:anObject atIndex:0];
}

- (void)removeAllObjects {
	CHDoublyLinkedListNode *node = head->next, *temp;
	while (node != tail) {
		temp = node->next;
		[node->object release];
		free(node);
		node = temp;
	}
	head->next = tail;
	tail->prev = head;
	cachedNode = NULL;
	count = 0;
	++mutations;
}

- (void)removeFirstObject {
	if (count > 0)
		[self removeNode:head->next];
}

- (void)removeLastObject {
	if (count > 0)
		[self removeNode:tail->prev];
}

- (void)_removeObject:(id)anObject withEqualityTest:(CHObjectEqualityTest)objectsMatch {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	if (count == 0) {
		return;
	}
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while (!objectsMatch(node->object, anObject))
			node = node->next;
		if (node != tail) {
			temp = node->next;
			[self removeNode:node];
			node = temp;
		}
	} while (node != tail);
}

- (void)removeObject:(id)anObject {
	[self _removeObject:anObject withEqualityTest:&CHObjectsAreEqual];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	CHRaiseIndexOutOfRangeExceptionIf(index, >=, count);
	[self removeNode:[self nodeAtIndex:index]];
}

- (void)removeObjectIdenticalTo:(id)anObject {
	[self _removeObject:anObject withEqualityTest:&CHObjectsAreIdentical];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
	CHRaiseInvalidArgumentExceptionIfNil(indexes);
	if ([indexes count]) {
		CHRaiseIndexOutOfRangeExceptionIf([indexes lastIndex], >=, count);
		NSUInteger nextIndex = [indexes firstIndex], index = 0;
		CHDoublyLinkedListNode *current = head->next, *temp;
		while (nextIndex != NSNotFound) {
			while (index++ < nextIndex)
				current = current->next;
			temp = current->next;
			[self removeNode:current];
			current = temp;
			nextIndex = [indexes indexGreaterThanIndex:nextIndex];
		}	
	}
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	CHRaiseIndexOutOfRangeExceptionIf(index, >=, count);
	CHDoublyLinkedListNode *node = [self nodeAtIndex:index];
	[node->object autorelease];
	node->object = [anObject retain];
}

@end
