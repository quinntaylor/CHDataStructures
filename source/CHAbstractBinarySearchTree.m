/*
 CHAbstractBinarySearchTree.m
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

#import "CHAbstractBinarySearchTree.h"

// Definitions of variables declared as 'extern' in CHAbstractBinarySearchTree.h
NSUInteger kCHBinaryTreeNodeSize = sizeof(CHBinaryTreeNode);
NSUInteger kPointerSize = sizeof(void*);

@implementation CHAbstractBinarySearchTree

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
	
	sentinel = malloc(kCHBinaryTreeNodeSize);
	sentinel->object = nil;
	sentinel->right = sentinel;
	sentinel->left = sentinel;
	
	header = malloc(kCHBinaryTreeNodeSize);
	header->object = [CHSearchTreeHeaderObject headerObject];
	header->left = sentinel;
	header->right = sentinel;
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	// Allow concrete child class to have a chance to initialize its own state.
	// (The subclass' -init calls -[CHAbstractBinarySearchTree init] first.)
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[self addObject:anObject];
	return self;
}

#pragma mark <NSCoding> methods

- (id) initWithCoder:(NSCoder *)decoder {
	// Allow concrete child class to have a chance to initialize its own state.
	// (The subclass' -init calls -[CHAbstractBinarySearchTree init] first.)
	if ([self init] == nil) return nil;
	for (id anObject in [decoder decodeObjectForKey:@"objects"])
		[self addObject:anObject];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[self allObjectsWithTraversalOrder:CHTraverseLevelOrder]
				   forKey:@"objects"];
}

#pragma mark <NSCopying> methods

- (id) copyWithZone:(NSZone *)zone {
	id<CHSearchTree> newTree = [[[self class] alloc] init];
	for (id anObject in [self allObjectsWithTraversalOrder:CHTraverseLevelOrder])
		[newTree addObject:anObject];
	return newTree;
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHBinaryTreeNode *current;
	CHBinaryTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	
	// For the first call, start at leftmost node, otherwise the last saved node
	if (state->state == 0) {
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
		current = header->right;
		CHBinaryTreeStack_INIT(stack);
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		current = (CHBinaryTreeNode*) state->state;
		stack = (CHBinaryTreeNode**) state->extra[0];
		stackSize = (NSUInteger) state->extra[1];
		elementsInStack = (NSUInteger) state->extra[2];
	}
	
	// Accumulate objects from the tree until we reach all nodes or the maximum
	NSUInteger batchCount = 0;
	while ( (current != sentinel || elementsInStack > 0) && batchCount < len) {
		while (current != sentinel) {
			CHBinaryTreeStack_PUSH(current);
			current = current->left;
		}
		current = CHBinaryTreeStack_POP; // Save top node for return value
		stackbuf[batchCount] = current->object;
		current = current->right;
		batchCount++;
	}
	
	if (current == sentinel && elementsInStack == 0) {
		free(stack);
		state->state = 1; // used as a termination flag
	}
	else {
		state->state = (unsigned long) current;
		state->extra[0] = (unsigned long) stack;
		state->extra[1] = (unsigned long) stackSize;
		state->extra[2] = (unsigned long) elementsInStack;
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
	CHBinaryTreeNode *current = header->right;
	while (current->right != sentinel)
		current = current->right;
	return current->object;
}

- (id) findMin {
	sentinel->object = nil;
	CHBinaryTreeNode *current = header->right;
	while (current->left != sentinel)
		current = current->left;
	return current->object;
}

- (id) findObject:(id)anObject {
	if (anObject == nil)
		return nil;
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHBinaryTreeNode *current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel) ? current->object : nil;
}

/**
 Frees all nodes in the tree and releases the objects they point to. The pointer
 to the root node is reset to the sentinel, and element count is reset to zero.
 This method deletes nodes using a pre-order traversal by pushing child nodes on
 a stack. This approach generally requires less space than level-order traversal
 since it is depth-first rather than breadth-first, and should be faster, too.
 */
- (void) removeAllObjects {
	if (count == 0)
		return;
	++mutations;
	
	CHBinaryTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHBinaryTreeStack_INIT(stack);
	CHBinaryTreeStack_PUSH(header->right);

	CHBinaryTreeNode *current;
	while (current = CHBinaryTreeStack_POP) {
		if (current->right != sentinel)
			CHBinaryTreeStack_PUSH(current->right);
		if (current->left != sentinel)
			CHBinaryTreeStack_PUSH(current->left);
		[current->object release];
		free(current);
	}
	free(stack);

	header->right = sentinel;
	count = 0;
}

- (NSEnumerator*) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseAscending];
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHBinarySearchTreeEnumerator alloc]
			 initWithTree:self
	                 root:header->right
	             sentinel:sentinel
	       traversalOrder:order
	      mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseDescending];
}

- (NSString*) debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
	                                @"<%@: 0x%x> = {\n", [self class], self];
	CHBinaryTreeNode *current;
	CHBinaryTreeNode **stack;
	NSUInteger stackSize, elementsInStack;
	CHBinaryTreeStack_INIT(stack);
	
	sentinel->object = nil;
	if (header->right != sentinel)
		CHBinaryTreeStack_PUSH(header->right);	
	while (current = CHBinaryTreeStack_POP) {
		if (current->right != sentinel)
			CHBinaryTreeStack_PUSH(current->right);
		if (current->left != sentinel)
			CHBinaryTreeStack_PUSH(current->left);
		// Append entry for the current node, including children
		[description appendFormat:@"\t%@ -> \"%@\" and \"%@\"\n",
		 [self debugDescriptionForNode:current],
		 current->left->object, current->right->object];
	}
	free(stack);
	[description appendString:@"}"];
	return description;
}

- (NSString*) debugDescriptionForNode:(CHBinaryTreeNode*)node {
	return [NSString stringWithFormat:@"\"%@\"", node->object];
}

- (NSString*) dotGraphString {
	NSMutableString *graph = [NSMutableString stringWithFormat:
							  @"digraph %@\n{\n", [self className]];
	if (header->right == sentinel) {
		[graph appendFormat:@"  nil;\n"];
	} else {
		NSString *leftChild, *rightChild;
		NSUInteger sentinelCount = 0;
		sentinel->object = nil;
		
		CHBinaryTreeNode *current;
		CHBinaryTreeNode **stack;
		NSUInteger stackSize, elementsInStack;
		CHBinaryTreeStack_INIT(stack);
		CHBinaryTreeStack_PUSH(header->right);
		while (current = CHBinaryTreeStack_POP) {
			if (current->left != sentinel)
				CHBinaryTreeStack_PUSH(current->left);
			if (current->right != sentinel)
				CHBinaryTreeStack_PUSH(current->right);
			// Append entry for node with any subclass-specific customizations.
			[graph appendString:[self dotStringForNode:current]];
			// Append entry for edges from current node to both its children.
			[graph appendFormat:@"  \"%@\" -> {%@;%@};\n", current->object,
			 (leftChild = current->left->object)
			    ? [NSString stringWithFormat:@"\"%@\"", leftChild]
			    : [NSString stringWithFormat:@"nil%d", ++sentinelCount],
			 (rightChild = current->right->object)
			    ? [NSString stringWithFormat:@"\"%@\"", rightChild]
			    : [NSString stringWithFormat:@"nil%d", ++sentinelCount]];
		}
		free(stack);
		
		// Create entry for each null leaf node (each nil is modeled separately)
		for (int i = 1; i <= sentinelCount; i++)
			[graph appendFormat:@"  nil%d [shape=point,fillcolor=black];\n", i];
	}
	// Terminate the graph string, then return it
	[graph appendString:@"}\n"];
	return graph;
}

- (NSString*) dotStringForNode:(CHBinaryTreeNode*)node {
	return [NSString stringWithFormat:@"  \"%@\";\n", node->object];
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

@implementation CHBinarySearchTreeEnumerator

- (id) initWithTree:(id<CHSearchTree>)tree
               root:(CHBinaryTreeNode*)root
           sentinel:(CHBinaryTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order)) return nil;
	traversalOrder = order;
	collection = (root != sentinel) ? [tree retain] : nil;
	CHBinaryTreeStack_INIT(stack);
	CHBinaryTreeQueue_INIT(queue);
	if (traversalOrder == CHTraverseLevelOrder) {
		CHBinaryTreeQueue_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		CHBinaryTreeStack_PUSH(root);
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
	free(stack);
	free(queue);
	[super dealloc];
}

- (void) finalize {
	free(stack);	
	free(queue);
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
			if (elementsInStack == 0 && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (current != sentinelNode) {
				CHBinaryTreeStack_PUSH(current);
				current = current->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHBinaryTreeStack_POP; // Save top node for return value
			id tempObject = current->object;
			current = current->right;
			return tempObject;
		}
			
		case CHTraverseDescending: {
			if (elementsInStack == 0 && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (current != sentinelNode) {
				CHBinaryTreeStack_PUSH(current);
				current = current->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			current = CHBinaryTreeStack_POP; // Save top node for return value
			id tempObject = current->object;
			current = current->left;
			return tempObject;
		}
			
		case CHTraversePreOrder: {
			current = CHBinaryTreeStack_POP;
			if (current == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			if (current->right != sentinelNode)
				CHBinaryTreeStack_PUSH(current->right);
			if (current->left != sentinelNode)
				CHBinaryTreeStack_PUSH(current->left);
			return current->object;
		}
			
		case CHTraversePostOrder: {
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (elementsInStack == 0 && current == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (1) {
				while (current != sentinelNode) {
					CHBinaryTreeStack_PUSH(current);
					current = current->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (CHBinaryTreeStack_TOP != NULL) {
					current = CHBinaryTreeStack_TOP->right;
					CHBinaryTreeStack_PUSH(NULL);
					// TODO: How to not push a null pad for leaf nodes?
				}
				else {
					CHBinaryTreeStack_POP; // ignore the null pad
					return CHBinaryTreeStack_POP->object;
				}				
			}
		}
			
		case CHTraverseLevelOrder: {
			current = CHBinaryTreeQueue_FRONT;
			CHBinaryTreeQueue_DEQUEUE;
			if (current == NULL) {
				[collection release];
				collection = nil;
				free(queue);
				return nil;
			}
			if (current->left != sentinelNode)
				CHBinaryTreeQueue_ENQUEUE(current->left);
			if (current->right != sentinelNode)
				CHBinaryTreeQueue_ENQUEUE(current->right);
			return current->object;
		}
	}
	return nil;
}

@end

#pragma mark -

static CHSearchTreeHeaderObject *headerObject = nil;

@implementation CHSearchTreeHeaderObject

+ (id) headerObject {
	if (headerObject == nil)
		headerObject = [[CHSearchTreeHeaderObject alloc] init];
	return headerObject;
}

- (NSComparisonResult) compare:(id)otherObject {
	return NSOrderedAscending;
}

@end
