//
//  CHTreap.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <CHDataStructures/CHTreap.h>
#import "CHAbstractBinarySearchTree_Internal.h"

@implementation CHTreap

// Two-way single rotation; 'dir' is the side to which the root should rotate.
#define singleRotation(node,dir,parent) {         \
	CHBinaryTreeNode *save = node->link[!dir];    \
	node->link[!dir] = save->link[dir];           \
	save->link[dir] = node;                       \
	parent->link[(parent->right == node)] = save; \
}

- (void)_subclassSetup {
	header->priority = CHTreapNotFound; // This is the highest possible priority
}

- (void)addObject:(id)anObject {
	[self addObject:anObject withPriority:arc4random()];
}

- (void)addObject:(id)anObject withPriority:(NSUInteger)priority {
	CHRaiseInvalidArgumentExceptionIfNil(anObject);
	++mutations;

	CHBinaryTreeNode *parent, *current = header;
	CHBinaryTreeStack_DECLARE();
	CHBinaryTreeStack_INIT();
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while ((comparison = [current->object compare:anObject])) {
		CHBinaryTreeStack_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	parent = CHBinaryTreeStack_POP();
	NSAssert(parent != nil, @"Illegal state, parent should never be nil!");
	
	[anObject retain]; // Must retain whether replacing value or adding new node
	u_int32_t direction;
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;
		// Assign new priority; bubble down if needed, or just wait to bubble up
		current->priority = (u_int32_t) (priority % CHTreapNotFound);
		while (current->left != current->right) { // sentinel check
			direction = (current->right->priority > current->left->priority);
			if (current->priority >= current->link[direction]->priority)
				break;
			NSAssert(parent != nil, @"Illegal state, parent should never be nil!");
			singleRotation(current, !direction, parent);
			parent = current;
			current = current->link[!direction];
		}
	} else {
		current = CHCreateBinaryTreeNodeWithObject(anObject);
		current->left   = sentinel;
		current->right  = sentinel;
		current->priority = (u_int32_t) (priority % CHTreapNotFound);
		++count;
		// Link from parent as the correct child, based on the last comparison
		comparison = [parent->object compare:anObject];
		parent->link[comparison == NSOrderedAscending] = current; // R if YES
	}
	
	// Trace back up the path, rotating as we go to satisfy the heap property.
	// Loop exits once the heap property is satisfied, even after bubble down.
	while (parent != header && current->priority > parent->priority) {
		// Rotate current node up, push parent down to opposite subtree.
		direction = (parent->left == current);
		NSAssert(parent != nil, @"Illegal state, parent should never be nil!");
		NSAssert(stackSize > 0, @"Illegal state, stack should never be empty!");
		singleRotation(parent, direction, CHBinaryTreeStack_TOP);
		parent = CHBinaryTreeStack_POP();
	}
	CHBinaryTreeStack_FREE(stack);
}

- (void)removeObject:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	++mutations;
	
	CHBinaryTreeNode *parent = nil, *current = header;
	NSComparisonResult comparison;
	u_int32_t direction;
	
	// First, we must locate the object to be removed, or we exit if not found
	sentinel->object = anObject; // Assure that we stop at a sentinel leaf node
	while ((comparison = [current->object compare:anObject])) {
		parent = current;
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	NSAssert(parent != nil, @"Illegal state, parent should never be nil!");
	
	if (current != sentinel) {
		// Percolate node down the tree, always rotating towards lower priority
		BOOL isRightChild;
		while (current->left != current->right) { // sentinel check
			direction = (current->right->priority > current->left->priority);
			isRightChild = (parent->right == current);
			singleRotation(current, !direction, parent);
			parent = parent->link[isRightChild];
		}
//		NSAssert(parent != nil, @"Illegal state, parent should never be nil!");
		parent->link[parent->right == current] = sentinel;
		[current->object release];
		free(current);
		--count;
	}
}

- (NSUInteger)priorityForObject:(id)anObject {
	if (anObject == nil)
		return CHTreapNotFound;
	sentinel->object = anObject; // Make sure the target value is always "found"
	CHBinaryTreeNode *current = header->right;
	NSComparisonResult comparison;
	while ((comparison = [current->object compare:anObject])) {
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	return (current != sentinel) ? current->priority : CHTreapNotFound;
}

- (NSString *)debugDescriptionForNode:(CHBinaryTreeNode *)node {
	return [NSString stringWithFormat:@"[%11d]\t\"%@\"",
			node->priority, node->object];
}

- (NSString *)dotGraphStringForNode:(CHBinaryTreeNode *)node {
	return [NSString stringWithFormat:@"  \"%@\" [label=\"%@\\n%d\"];\n",
			node->object, node->object, node->priority];
}

@end
