/*
 CHUnbalancedTree.h
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

#import <Foundation/Foundation.h>
#import "CHAbstractTree.h"

// A node for use by CHUnbalancedTree for internal storage and representation.
typedef struct CHUnbalancedTreeNode {
	id object;		/**< The object stored in a particular node. */
	struct CHUnbalancedTreeNode *left;	/**< The left child node, if any. */
	struct CHUnbalancedTreeNode *right;	/**< The right child node, if any. */
	struct CHUnbalancedTreeNode *parent;	/**< Link to the parent node, if any. */
} CHUnbalancedTreeNode;

#pragma mark -

/**
 A simple, unbalanced binary tree that <b>does not</b> guarantee O(log n) access.
 Even though the tree is never balanced when items are added or removed, access is
 <b>at worst</b> linear if the tree essentially degenerates into a linked list.
 This class is fast, and without stack risk because it works without recursion.
 In release 0.4.0, nodes objects were changed to C structs for enhanced performance.
 */
@interface CHUnbalancedTree : CHAbstractTree
{
	/** A pointer to the root of the tree, set to <code>NULL</code> if empty. */
	CHUnbalancedTreeNode *root;
}

@end

