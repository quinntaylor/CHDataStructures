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
#import "CHAbstractBinarySearchTree_Private.h"

// Remove left horizontal links
#define skew(node) { \
	if ( node->left->level == node->level && node->level != 0 ) { \
		CHBinaryTreeNode *save = node->left; \
		node->left = save->right; \
		save->right = node; \
		node = save; \
	} \
}

// Remove consecutive horizontal links
#define split(node) { \
	if ( node->right->right->level == node->level && node->level != 0 ) { \
		CHBinaryTreeNode *save = node->right; \
		node->right = save->left; \
		save->left = node; \
		node = save; \
		++(node->level); \
	} \
}

#pragma mark -

@implementation CHAnderssonTree

- (id) init {
	if ([super init] == nil) return nil;
	sentinel->level = 0;
	header->level = 0;
	return self;
}

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	++mutations;
	
	CHBinaryTreeNode *parent, *current = header;
	CHBinaryTreeStack_DECLARE();
	CHBinaryTreeStack_INIT();
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHBinaryTreeStack_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	
	[anObject retain]; // Must retain whether replacing value or adding new node
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;
		// No need to rebalance up the path since we didn't modify the structure
		goto done;
	} else {
		current = NSAllocateCollectable(kCHBinaryTreeNodeSize, NSScannedOption);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		current->level  = 1;
		++count;
		// Link from parent as the proper child, based on last comparison
		parent = CHBinaryTreeStack_POP;
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
		parent = CHBinaryTreeStack_POP;
	}
done:
	CHBinaryTreeStack_FREE(stack);
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (count == 0)
		return;
	++mutations;
	
	CHBinaryTreeNode *parent, *current = header;
	CHBinaryTreeStack_DECLARE();
	CHBinaryTreeStack_INIT();
	
	sentinel->object = anObject; // Assure that we stop at a leaf if not found.
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		CHBinaryTreeStack_PUSH(current);
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	// Exit if the specified node was not found in the tree.
	if (current == sentinel) {
		goto done;
	}
	
	[current->object release]; // Object must be released in any case
	--count;
	if (current->left == sentinel || current->right == sentinel) {
		// Single/zero child case -- replace node with non-nil child (if exists)
		parent = CHBinaryTreeStack_TOP;
		parent->link[parent->right == current]
			= current->link[current->left == sentinel];
		if (CHGarbageCollectionDisabled)
			free(current);
	} else {
		// Two child case -- replace with minimum object in right subtree
		CHBinaryTreeStack_PUSH(current); // Need to start here when rebalancing
		parent = current;
		CHBinaryTreeNode *replacement = current->right;
		while (replacement->left != sentinel) {
			CHBinaryTreeStack_PUSH(replacement);
			replacement = replacement->left;
		}
		parent = CHBinaryTreeStack_TOP;
		// Grab object from replacement node, steal its right child, deallocate
		current->object = replacement->object;
		parent->link[parent->right == replacement] = replacement->right;
		if (CHGarbageCollectionDisabled)
			free(replacement);
	}
	
	// Walk back up the path and rebalance as we go
	// Note that 'parent' always has the correct value coming into the loop
	BOOL isRightChild;
	while (current != NULL && stackSize > 1) {
		current = parent;
		CHBinaryTreeStack_POP;
		parent = CHBinaryTreeStack_TOP;
		isRightChild = (parent->right == current);
		
		if (current->left->level < current->level-1 ||
			current->right->level < current->level-1)
		{
			if (current->right->level > --(current->level)) {
				current->right->level = current->level;
			}
			skew(current);
			skew(current->right);
			skew(current->right->right);
			split(current);
			split(current->right);
		}
		parent->link[isRightChild] = current;
	}
done:
	CHBinaryTreeStack_FREE(stack);
}

- (NSString*) debugDescriptionForNode:(CHBinaryTreeNode*)node {
	return [NSString stringWithFormat:@"[%2d]\t\"%@\"", node->level, node->object];
}

- (NSString*) dotStringForNode:(CHBinaryTreeNode*)node {
	return [NSString stringWithFormat:@"  \"%@\" [label=\"%@\\n%d\"];\n",
			node->object, node->object, node->level];
}

@end
