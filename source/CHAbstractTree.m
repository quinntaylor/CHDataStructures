/*
 CHAbstractTree.m
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

#import "CHAbstractTree.h"

// Definitions of variables declared as 'extern' in CHAbstractTree.h
NSUInteger kCHTreeNodeSize = sizeof(CHTreeNode);
NSUInteger kCHTreeListNodeSize = sizeof(CHTreeListNode);

@implementation CHAbstractTree

- (void) dealloc {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super dealloc];
}

- (void) finalize {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super finalize];
}

/**
 Only to be called from concrete child classes to initialize shared variables.
 */
- (id) init {
	if ([super init] == nil) return nil;
	count = 0;
	mutations = 0;
	
	sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->right = sentinel;
	sentinel->left = sentinel;
	
	header = malloc(kCHTreeNodeSize);
	header->object = [CHTreeHeaderObject headerObject];
	header->left = sentinel;
	header->right = sentinel;
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	// Allow concrete child class to have a chance to initialize its own state
	// Calls the concrete subclass' -init, which calls [super init] declared here
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[self addObject:anObject];
	return self;
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given keyed unarchiver.
 
 @param decoder An keyed unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	// Allow concrete child class to have a chance to initialize its own state
	// Calls the concrete subclass' -init, which calls [super init] declared here
	if ([self init] == nil) return nil;
	for (id anObject in [decoder decodeObjectForKey:@"objects"])
		[self addObject:anObject];
	return self;
}

/**
 Encodes the receiver using a given keyed archiver.
 
 @param encoder An keyed archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	NSEnumerator *e = [self objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	[encoder encodeObject:[e allObjects] forKey:@"objects"];
}

#pragma mark <NSCopying> methods

/**
 Returns a new instance that's a copy of the receiver. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
        instance. If zone is <code>NULL</code>, the new instance is allocated
        from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. Since the nature of storing data in trees is always the same,
 copies returned by this method are always mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	id<CHTree> newTree = [[[self class] alloc] init];
	NSEnumerator *e = [self objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	for (id anObject in e)
		[newTree addObject:anObject];
	return newTree;
}

#pragma mark <NSFastEnumeration> Methods

/**
 A method for NSFastEnumeration, called by <code><b>for</b> (type variable
 <b>in</b> collection)</code> constructs.
 
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
	CHTreeNode *current;
	CHTreeListNode *stack, *tmp; 
	
	// For the first call, start at leftmost node, otherwise start at last saved node
	if (state->state == 0) {
		current = header->right;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
		stack = NULL;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		current = (CHTreeNode*) state->state;
		stack = (CHTreeListNode*) state->extra[0];
	}
	
	// Accumulate objects from the tree until we reach all nodes or the maximum
	NSUInteger batchCount = 0;
	while ( (current != sentinel || stack != NULL) && batchCount < len) {
		while (current != sentinel) {
			CHTreeList_PUSH(current);
			current = current->left;
			// TODO: How to not push/pop leaf nodes unnecessarily?
		}
		current = CHTreeList_TOP; // Save top node for return value
		CHTreeList_POP;
		stackbuf[batchCount] = current->object;
		current = current->right;
		batchCount++;
	}
	
	if (current == sentinel && stack == NULL)
		state->state = 1; // used as a termination flag
	else {
		state->state = (unsigned long) current;
		state->extra[0] = (unsigned long) stack;
	}
	return batchCount;
}

#pragma mark Concrete Implementations

- (NSArray*) allObjects {
	return [self allObjectsWithTraversalOrder:CHTraverseAscending];
}

- (NSArray*) allObjectsWithTraversalOrder:(CHTraversalOrder)order {
	return [[self objectEnumeratorWithTraversalOrder:order] allObjects];
}

- (BOOL) containsObject:(id)anObject {
	return ([self findObject:anObject] != nil);
}

- (NSUInteger) count {
	return count;
}

- (NSString*) description {
	return [[self allObjectsWithTraversalOrder:CHTraverseAscending] description];
}

- (id) findMax {
	sentinel->object = nil;
	CHTreeNode *current = header->right;
	while (current->right != sentinel)
		current = current->right;
	return current->object;
}

- (id) findMin {
	sentinel->object = nil;
	CHTreeNode *current = header->right;
	while (current->left != sentinel)
		current = current->left;
	return current->object;
}

- (id) findObject:(id)anObject {
	if (anObject == nil)
		return nil;
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHTreeNode *current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel) ? current->object : nil;
}

/**
 Frees all the nodes in the tree and releases the objects they point to. The pointer
 to the root node remains NULL until an object is added to the tree. Uses a linked
 list to store the objects waiting to be deleted; in a binary tree, no more than half
 of the nodes will be on the queue.
 */
- (void) removeAllObjects {
	if (count == 0)
		return;
	
	CHTreeNode *current;
	CHTreeListNode *queue = NULL;
	CHTreeListNode *queueTail = NULL;
	CHTreeListNode *tmp;
	
	CHTreeList_ENQUEUE(header->right);
	while (current = CHTreeList_FRONT) {
		CHTreeList_DEQUEUE;
		if (current->left != sentinel)
			CHTreeList_ENQUEUE(current->left);
		if (current->right != sentinel)
			CHTreeList_ENQUEUE(current->right);
		[current->object release];
		free(current);
	}
	header->right = sentinel;
	count = 0;
	++mutations;
}

- (NSEnumerator*) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseAscending];
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHTreeEnumerator alloc] initWithTree:self
	                                          root:header->right
	                                      sentinel:sentinel
	                                traversalOrder:order
	                               mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseDescending];
}

#pragma mark Unsupported Implementations

- (void) addObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
}

- (void) removeObject:(id)element {
	CHUnsupportedOperationException([self class], _cmd);
}

@end


#pragma mark -

@implementation CHTreeEnumerator

- (id) initWithTree:(id<CHTree>)tree
               root:(CHTreeNode*)root
           sentinel:(CHTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order)) return nil;
	stack = NULL;
	traversalOrder = order;
	collection = (root != sentinel) ? collection = [tree retain] : nil;
	if (traversalOrder == CHTraverseLevelOrder) {
		CHTreeList_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		CHTreeList_PUSH(root);
	} else {
		current = root;
	}
	sentinel->object = nil;
	sentinelNode = sentinel;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
	while (stack != NULL)
		CHTreeList_POP;
	while (queue != NULL)
		CHTreeList_DEQUEUE;
	[super dealloc];
}

- (void) finalize {
	while (stack != NULL)
		CHTreeList_POP;
	while (queue != NULL)
		CHTreeList_DEQUEUE;
	[super finalize];
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [self nextObject]))
		[array addObject:object];
	[collection release];
	collection = nil;
	return [array autorelease];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	
	switch (traversalOrder) {
		case CHTraverseAscending: {
			if (stack == NULL && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (current != sentinelNode) {
				CHTreeList_PUSH(current);
				current = current->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHTreeList_TOP; // Save top node for return value
			CHTreeList_POP;
			id tempObject = current->object;
			current = current->right;
			return tempObject;
		}
			
		case CHTraverseDescending: {
			if (stack == NULL && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (current != sentinelNode) {
				CHTreeList_PUSH(current);
				current = current->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHTreeList_TOP; // Save top node for return value
			CHTreeList_POP;
			id tempObject = current->object;
			current = current->left;
			return tempObject;
		}
			
		case CHTraversePreOrder: {
			current = CHTreeList_TOP;
			CHTreeList_POP;
			if (current == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			if (current->right != sentinelNode)
				CHTreeList_PUSH(current->right);
			if (current->left != sentinelNode)
				CHTreeList_PUSH(current->left);
			return current->object;
		}
			
		case CHTraversePostOrder: {
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (stack == NULL && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (1) {
				while (current != sentinelNode) {
					CHTreeList_PUSH(current);
					current = current->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (CHTreeList_TOP != NULL) {
					current = CHTreeList_TOP->right;
					CHTreeList_PUSH(NULL);
					// TODO: explore how to not use null pad for leaf nodes
				}
				else {
					CHTreeList_POP; // ignore the null pad
					id tempObject = CHTreeList_TOP->object;
					CHTreeList_POP;
					return tempObject;
				}				
			}
		}
			
		case CHTraverseLevelOrder: {
			current = CHTreeList_FRONT;
			if (current == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			CHTreeList_DEQUEUE;
			if (current->left != sentinelNode)
				CHTreeList_ENQUEUE(current->left);
			if (current->right != sentinelNode)
				CHTreeList_ENQUEUE(current->right);
			return current->object;
		}
	}
	return nil;
}

@end



#pragma mark -


static CHTreeHeaderObject *headerObject = nil;

@implementation CHTreeHeaderObject

+ (id) headerObject {
	if (headerObject == nil)
		headerObject = [[CHTreeHeaderObject alloc] init];
	return headerObject;
}

- (NSComparisonResult) compare:(id)otherObject {
	return NSOrderedAscending;
}

@end
