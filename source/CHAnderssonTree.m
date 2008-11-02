/*
 CHAnderssonTree.m
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

#import "CHAnderssonTree.h"

static NSUInteger kCHTreeNodeSize = sizeof(CHTreeNode);
static NSUInteger kCHTreeListNodeSize = sizeof(CHTreeListNode);

/**
 An NSEnumerator for traversing an CHAnderssonTree in a specified order.
 
 This enumerator uses iterative tree traversal algorithms for two main reasons:
 <ol>
 <li>Recursive algorithms cannot easily be stopped in the middle of a traversal.
 <li>Iterative algorithms are faster since they reduce overhead of function calls.
 </ol>
 
 In addition, the stacks and queues used for storing traversal state are composed of
 C structs and <code>\#define</code> pseudo-functions to increase performance and
 reduce the required memory footprint.
 
 Enumerators encapsulate their own state, and more than one may be active at once.
 However, like an enumerator for a mutable data structure, any instances of this
 enumerator become invalid if the tree is modified.
 */
@interface CHAnderssonTreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder; /**< Order in which to traverse the tree. */
	@private
	id<CHTree> collection;
	CHTreeNode *current;
	CHTreeNode *sentinelNode;
	id tempObject;         /**< Temporary variable, holds the object to be returned.*/
	CHTreeListNode *stack;     /**< Pointer to the top of a stack for most traversals. */
	CHTreeListNode *queue;     /**< Pointer to the head of a queue for level-order. */
	CHTreeListNode *queueTail; /**< Pointer to the tail of a queue for level-order. */
	CHTreeListNode *tmp;       /**< Temporary variable for stack and queue operations. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param tree The tree collection that is being enumerated. This collection is to be
             retained while the enumerator has not exhausted all its objects.
 @param root The root node of the (sub)tree whose elements are to be enumerated.
 @param sentinel The sentinel value used at the leaves of this Andersson tree.
 @param order The traversal order to use for enumerating the given (sub)tree.
 @param mutations A pointer to the collection's count of mutations, for invalidation.
 */
- (id) initWithTree:(id<CHTree>)tree
               root:(CHTreeNode*)root
           sentinel:(CHTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray*) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or <code>nil</code>
 when all objects have been enumerated.
 */
- (id) nextObject;

@end

#pragma mark -

@implementation CHAnderssonTreeEnumerator

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
		CHTreeList_POP();
	while (queue != NULL)
		CHTreeList_DEQUEUE();
	[super dealloc];
}

- (void) finalize {
	while (stack != NULL)
		CHTreeList_POP();
	while (queue != NULL)
		CHTreeList_DEQUEUE();
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
		case CHTraverseAscending:
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
			CHTreeList_POP();
			tempObject = current->object;
			current = current->right;
			return tempObject;
			
		case CHTraverseDescending:
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
			CHTreeList_POP();
			tempObject = current->object;
			current = current->left;
			return tempObject;
			
		case CHTraversePreOrder:
			current = CHTreeList_TOP;
			CHTreeList_POP();
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
			
		case CHTraversePostOrder:
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
					CHTreeList_POP(); // ignore the null pad
					tempObject = CHTreeList_TOP->object;
					CHTreeList_POP();
					return tempObject;
				}				
			}
			
		case CHTraverseLevelOrder:
			current = CHTreeList_FRONT;
			if (current == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			CHTreeList_DEQUEUE();
			if (current->left != sentinelNode)
				CHTreeList_ENQUEUE(current->left);
			if (current->right != sentinelNode)
				CHTreeList_ENQUEUE(current->right);
			return current->object;
	}
	return nil;
}

@end

#pragma mark -

// Remove left horizontal links
#define skew(node) { \
	if ( node->left->level == node->level && node->level != 0 ) { \
		CHTreeNode *save = node->left; \
		node->left = save->right; \
		save->right = node; \
		node = save; \
	} }

// Remove consecutive horizontal links
#define split(node) { \
	if ( node->right->right->level == node->level && node->level != 0 ) { \
		CHTreeNode *save = node->right; \
		node->right = save->left; \
		save->left = node; \
		node = save; \
		++(node->level); \
	} }

/**
 Skew primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
CHTreeNode* _skew(CHTreeNode *node) {
	if (node->left->level == node->level) {
		CHTreeNode *other = node->left;
		node->left = other->right;
		other->right = node;
		return other;
	}
	return node;
}

/**
 Split primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
CHTreeNode* _split(CHTreeNode *node) {
	if (node->right->right->level == node->level)
	{
		CHTreeNode *other = node->right;
		node->right = other->left;
		other->left = node;
		other->level++;
		return other;
	}
	return node;
}

@implementation CHAnderssonTree

- (id) init {
	if ([super init] == nil) return nil;
	sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->right = sentinel;
	sentinel->left = sentinel;
	sentinel->level = 0;
	
	header = malloc(kCHTreeNodeSize);
	header->object = [CHAbstractTreeHeaderObject headerObject];
	header->left = sentinel;
	header->right = sentinel;
	header->level = 0;
	return self;
}

- (void) dealloc {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super dealloc];
}

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHTreeNode *parent, *current = header;
	CHTreeListNode *stack = NULL, *tmp;
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHTreeList_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	
	++mutations;
	[anObject retain]; // Must retain whether replacing value or adding new node
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;
		// No need to rebalance up the path since we didn't modify the structure
		while (stack != NULL)
			CHTreeList_POP();  // deallocate wrappers for nodes pushed to the stack		
		return;
	} else {
		current = malloc(kCHTreeNodeSize);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		current->level  = 1;
		++count;
		// Link from parent as the proper child, based on last comparison
		parent = CHTreeList_TOP;
		CHTreeList_POP();
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rebalancing as we go
	BOOL isRightChild;
	while (parent != NULL) {
		isRightChild = (parent->right == current);
		skew(current);
		split(current);
		parent->link[isRightChild] = current;
		// Move to the next node up the path to the root
		current = parent;
		parent = CHTreeList_TOP;
		CHTreeList_POP();
	}
}

- (BOOL) containsObject:(id)anObject {
	if (anObject == nil)
		return NO;
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHTreeNode *current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel);
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

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	/*
	sentinel->object = anObject;
	
	CHTreeNode *current = header->right;
	CHTreeNode *nodeToDelete = NULL;
	CHTreeListNode *stack = NULL;
	CHTreeListNode *tmp;
	NSComparisonResult comparison;
	
	while (current != sentinel) {
		CHTreeList_PUSH(current);
		comparison = [(current->object) compare:anObject];
		if (comparison == NSOrderedDescending)
			current = current->left;
		else  {
			if (comparison == NSOrderedSame)
				nodeToDelete = current;
			current = current->right;
		}
	}
	if (nodeToDelete == sentinel) {  // the specified object was not found
		while (stack != NULL)
			CHTreeList_POP();  // deallocate wrappers for nodes pushed to the stack
		return;
	}

	current = CHTreeList_TOP;
	CHTreeList_POP();
	nodeToDelete->object = current->object;
	nodeToDelete->level = current->level;
	// TODO: Is this where the malloced struct for the node needs to be freed?
	current = current->right;
			
	CHTreeNode *previous = NULL;
	while (stack != NULL)  {
		current = CHTreeList_TOP;
		CHTreeList_POP();
		if (previous != sentinel) {
			if ([current->object compare:previous->object] == NSOrderedAscending)
				current->right = previous;
			else
				current->left = previous;
		}
		if ((current->left != sentinel && current->left->level < current->level - 1) || 
			(current->right != sentinel && current->right->level < current->level - 1)) 
		{
			--(current->level);
			if (current->right->level > current->level)
				current->right->level = current->level;
			current               = _skew(current);
			current->right        = _skew(current->right);
			current->right->right = _skew(current->right->right);
			current               = _split(current);
			current->right        = _split(current->right);
		}
		previous = current;
	}
	header->right = current;
	--count;
	++mutations;
	 */
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
		CHTreeList_DEQUEUE();
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

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHAnderssonTreeEnumerator alloc] initWithTree:self
                                                       root:header->right
                                                   sentinel:sentinel
                                             traversalOrder:order
                                            mutationPointer:&mutations] autorelease];
}

#pragma mark <NSFastEnumeration> Methods

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
		CHTreeList_POP();
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

- (NSString*) debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
									@"<%@: 0x%x> = {\n", [self class], self];
	CHTreeNode *current;
	CHTreeListNode *queue = NULL, *queueTail = NULL, *tmp;
	CHTreeList_ENQUEUE(header->right);
	
	sentinel->object = nil;
	while (current != sentinel && queue != NULL) {
		current = CHTreeList_FRONT;
		CHTreeList_DEQUEUE();
		if (current->left != sentinel)
			CHTreeList_ENQUEUE(current->left);
		if (current->right != sentinel)
			CHTreeList_ENQUEUE(current->right);
		// Append entry for the current node, including color and children
		[description appendFormat:@"\t%d : %@ -> %@ and %@\n",
		 current->level, current->object,
		 current->left->object, current->right->object];
	}
	[description appendString:@"}"];
	return description;
}

@end
