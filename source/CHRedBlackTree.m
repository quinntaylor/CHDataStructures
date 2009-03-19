/*
 CHRedBlackTree.m
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

#import "CHRedBlackTree.h"
#import "CHAbstractBinarySearchTree_Internal.h"

#pragma mark C Functions for Optimized Operations

static inline CHBinaryTreeNode * rotateNodeWithLeftChild(CHBinaryTreeNode *node) {
	CHBinaryTreeNode *leftChild = node->left;
	node->left = leftChild->right;
	leftChild->right = node;
	node->color = kRED;
	leftChild->color = kBLACK;
	return leftChild;
}

static inline CHBinaryTreeNode * rotateNodeWithRightChild(CHBinaryTreeNode *node) {
	CHBinaryTreeNode *rightChild = node->right;
	node->right = rightChild->left;
	rightChild->left = node;
	node->color = kRED;
	rightChild->color = kBLACK;
	return rightChild;
}

HIDDEN CHBinaryTreeNode* rotateObjectOnAncestor(id anObject, CHBinaryTreeNode *ancestor) {
	if ([ancestor->object compare:anObject] == NSOrderedDescending) {
		return ancestor->left =
			([ancestor->left->object compare:anObject] == NSOrderedDescending)
				? rotateNodeWithLeftChild(ancestor->left)
				: rotateNodeWithRightChild(ancestor->left);
	}
	else {
		return ancestor->right =
			([ancestor->right->object compare:anObject] == NSOrderedDescending)
				? rotateNodeWithLeftChild(ancestor->right)
				: rotateNodeWithRightChild(ancestor->right);
	}
}

static inline CHBinaryTreeNode* singleRotation(CHBinaryTreeNode *node, BOOL goingRight) {
	CHBinaryTreeNode *save = node->link[!goingRight];
	node->link[!goingRight] = save->link[goingRight];
	save->link[goingRight] = node;
	node->color = kRED;
	save->color = kBLACK;
	return save;
}

static inline CHBinaryTreeNode* doubleRotation(CHBinaryTreeNode *node, BOOL goingRight) {
	node->link[!goingRight] = singleRotation(node->link[!goingRight], !goingRight);
	return singleRotation(node, goingRight);	
}

#pragma mark -

@implementation CHRedBlackTree

- (void) _reorient:(id)anObject {
	// Color flip
	current->color = kRED;
	current->left->color = kBLACK;
	current->right->color = kBLACK;
	// Fix red violation
	if (parent->color == kRED) 	{
		grandparent->color = kRED;
		if ([grandparent->object compare:anObject] != [parent->object compare:anObject])
			parent = rotateObjectOnAncestor(anObject, grandparent);
		current = rotateObjectOnAncestor(anObject, greatgrandparent);
		current->color = kBLACK;
	}
	header->right->color = kBLACK;  // Always reset root to black
}

- (id) init {
	if ([super init] == nil) return nil;
	sentinel->color = kBLACK;
	header->color = kBLACK;
	return self;
}

/*
 Basically, as you walk down the tree to insert, if the present node has two
 red children, you color it red and change the two children to black. If its
 parent is red, the tree must be rotated. (Just change the root's color back
 to black if you changed it). Returns without incrementing the count if the
 object already exists in the tree.
 */
- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	++mutations;

	grandparent = parent = current = header;
	sentinel->object = anObject;
	
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		greatgrandparent = grandparent, grandparent = parent, parent = current;
		current = current->link[comparison == NSOrderedAscending];
		
		// Check for the bad case of red parent and red sibling of parent
		if (current->left->color == kRED && current->right->color == kRED) {
			// Simple red violation: resolve with color flip
			current->color = kRED;
			current->left->color = kBLACK;
			current->right->color = kBLACK;
			
			// Hard red violation: rotations necessary
			if (parent->color == kRED) {
//				BOOL lastWentRight = (grandparent->right == parent);
//				greatgrandparent->link[greatgrandparent->right == grandparent]
//					= (parent->link[lastWentRight])
//						? singleRotation(grandparent, !lastWentRight)
//						: doubleRotation(grandparent, !lastWentRight);
				grandparent->color = kRED;
				if ([grandparent->object compare:anObject] != [parent->object compare:anObject])
					parent = rotateObjectOnAncestor(anObject, grandparent);
				current = rotateObjectOnAncestor(anObject, greatgrandparent);
				current->color = kBLACK;
			}
		}
	}
	
	[anObject retain];
	if (current != sentinel) {
		// If an existing node matched, simply replace the existing value.
		[current->object release];
		current->object = anObject;
	} else {
		++count;
		current = NSAllocateCollectable(kCHBinaryTreeNodeSize, NSScannedOption);
		current->object = anObject;
		current->left = sentinel;
		current->right = sentinel;
		
		parent->link[([parent->object compare:anObject] == NSOrderedAscending)] = current;
		
		[self _reorient:anObject]; // one last reorientation check...
	}
}

/**
 @param anObject The object to be removed from the tree.
 @todo Speed up red-black removal: performance currently grows exponentially.
 The EC tutorial opts to push a red node down the tree using rotations and flips
 to avoid a nasty case of deleting a black node. This is almost certainly what
 causes the performance problems.

 http://www.stanford.edu/~blp/avl/libavl.html/Deleting-from-an-RB-Tree.html
 http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_rbtree.aspx
 */
- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (count == 0)
		return;
	++mutations;
	
	grandparent = parent = current = header;
	sentinel->object = anObject;
	CHBinaryTreeNode *found = NULL, *sibling;
	NSComparisonResult comparison;
	BOOL isGoingRight = YES, prevWentRight = YES;
	while (current->link[isGoingRight] != sentinel) {
		grandparent = parent;
		parent = current;
		current = current->link[isGoingRight];
		comparison = [current->object compare:anObject];
		prevWentRight = isGoingRight;
		isGoingRight = (comparison != NSOrderedDescending);
		if (comparison == NSOrderedSame)
			found = current; // Save a pointer; removal happens outside the loop
		
		// There are only potential violations when removing a black node.
		// If so, push the child red node down using rotations and color flips.
		if (current->color != kRED && current->link[isGoingRight]->color != kRED) {
			if (current->link[!isGoingRight]->color == kRED)
				parent = parent->link[prevWentRight] = singleRotation(current, isGoingRight);
			else {
				sibling = parent->link[prevWentRight];
				if (sibling != sentinel) {
					if (sibling->left->color == kBLACK && sibling->right->color == kBLACK) {
						// If sibling's children are both black, do a color flip
						parent->color = kBLACK;
						sibling->color = kRED;
						current->color = kRED;
					}
					else {
						CHBinaryTreeNode *tempNode =
							grandparent->link[(grandparent->right == parent)];
						if (sibling->link[prevWentRight]->color == kRED)
							tempNode = doubleRotation(parent, prevWentRight);
						else if (sibling->link[!prevWentRight]->color == kRED)
							tempNode = singleRotation(parent, prevWentRight);
						/* Ensure correct coloring */
						current->color = tempNode->color = kRED;
						tempNode->left->color = kBLACK;
						tempNode->right->color = kBLACK;
					}
				} // if (sibling != sentinel)
			}
		}
	}
	
	// Transfer replacement value up to outgoing node, remove the "donor" node.
    if (found != NULL) {
		[found->object release];
		found->object = current->object;
		parent->link[(parent->right == current)]
			= current->link[(current->left == sentinel)];
		if (kCHGarbageCollectionDisabled)
			free(current);
		--count;
    }
	header->right->color = kBLACK; // Make the root black for simplified logic
}

- (NSString*) debugDescriptionForNode:(CHBinaryTreeNode*)node {
	return [NSString stringWithFormat:@"[%s]\t\"%@\"",
			(node->color == kBLACK) ? "BLACK" : " RED ", node->object];
}

- (NSString*) dotStringForNode:(CHBinaryTreeNode*)node {
	return [NSString stringWithFormat:@"  \"%@\" [color=%@];\n",
			node->object, (node->color == kRED) ? @"red" : @"black"];
}

@end
