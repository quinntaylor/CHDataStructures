/*
 CHUnbalancedTree.m
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

#import "CHUnbalancedTree.h"
#import "CHAbstractBinarySearchTree_Internal.h"

@implementation CHUnbalancedTree

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	++mutations;
	
	CHBinaryTreeNode *parent = header, *current = header->right;
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		parent = current;
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	
	[anObject retain]; // Must retain whether replacing value or adding new node
	if (current != sentinel) {
		// Replace the existing object with the new object.
		[current->object release];
		current->object = anObject;		
	} else {
		// Create a new node to hold the value being inserted
		current = NSAllocateCollectable(kCHBinaryTreeNodeSize, NSScannedOption);
		current->object = anObject;
		current->left   = sentinel;
		current->right  = sentinel;
		++count;
		// Link from parent as the proper child, based on last comparison
		comparison = [parent->object compare:anObject]; // restore prior compare
		parent->link[comparison == NSOrderedAscending] = current;
	}
}

/**
 Removal is guaranteed not to make the tree deeper/taller, since it uses the
 "min of the right subtree" algorithm if the node to be removed has 2 children.
 */
- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (count == 0)
		return;
	++mutations;
	
	CHBinaryTreeNode *parent, *current = header;
	
	sentinel->object = anObject; // Assure that we find a spot to insert
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		parent = current;
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	}
	// Exit if the specified node was not found in the tree.
	if (current == sentinel)
		return;

	[current->object release]; // Object must be released in any case
	--count;
	if (current->left == sentinel || current->right == sentinel) {
		// One or both of the child pointers are null, so removal is simpler
		parent->link[parent->right == current]
			= current->link[current->left == sentinel];
		if (kCHGarbageCollectionDisabled)
			free(current);
	} else {
		// The most complex case: removing a node with 2 non-null children
		// (Replace object with the leftmost object in the right subtree.)
		parent = current;
		CHBinaryTreeNode *replacement = current->right;
		while (replacement->left != sentinel) {
			parent = replacement;
			replacement = replacement->left;
		}
		current->object = replacement->object;
		parent->link[parent->right == replacement] = replacement->right;
		if (kCHGarbageCollectionDisabled)
			free(replacement);
	}
}

@end
