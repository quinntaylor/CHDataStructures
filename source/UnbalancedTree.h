/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

//  UnbalancedTree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractTree.h"

/**
 A node for use by UnbalancedTree for internal storage and representation.
 Holds an obejct and link to 2 children and a parent.
 */
typedef struct UnbalancedTreeNode {
	id object;		/**< The object stored in a particular node. */
	struct UnbalancedTreeNode *left;	/**< The left child node, if any. */
	struct UnbalancedTreeNode *right;	/**< The right child node, if any. */
	struct UnbalancedTreeNode *parent;	/**< Link to the parent node, if any. */
} UnbalancedTreeNode;

#pragma mark -

/**
 A simple, unbalanced binary tree that <b>does not</b> guarantee O(log n) access.
 Even though the tree is never balanced when items are added or removed, access is
 <b>at worst</b> linear if the tree essentially degenerates into a linked list.
 This class is fast, and without stack risk because it works without recursion.
 In release 0.4.0, nodes objects were changed to C structs for enhanced performance.
 */
@interface UnbalancedTree : AbstractTree
{
	/** A pointer to the root of the tree, set to <code>NULL</code> if empty. */
	UnbalancedTreeNode *root;
}

@end

