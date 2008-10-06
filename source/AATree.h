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

//  AATree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractTree.h"

/**
 A node for use by AATree for internal storage and representation.
 Holds an obejct, 2 child links, and level within the tree.
 */
typedef struct AATreeNode {
	id object;		/**< The object stored in a particular node. */
	struct AATreeNode *left;	/**< The left child node, if any. */
	struct AATreeNode *right;	/**< The right child node, if any. */
	NSInteger level;            /**< The level of this node in the AA-tree. */
} AATreeNode;

/**
 An <a href="http://en.wikipedia.org/wiki/AA_tree">AA-tree</a>, a balanced binary
 tree with guaranteed O(log n) access. This is an Objective-C port of the AA-tree
 from <i>"Data Structures and Problem Solving Using Java"</i> by Mark Allen Weiss,
 published by Addison Wesley. Method names have been changed to match the APIs of
 existing Cocoa collections classes provided by Apple, and several optimizations in 
 straight C have been made to optimize speed and memory usage.
 
 An <i>Arne Andersson tree</i> is similar to a RedBlackTree, but with
 a simple restriction that simplifies maintenance operations for balancing the tree.
 Rather than balancing all 7 possible subtrees of 2 and 3 nodes, an AA-tree need only
 be concerned with 2, so consequently only 2 operations&mdash;called <i>skew</i> and
 <i>split</i>, or left and right rotations, respectively&mdash;are required.

 The performance of an AA-tree is equivalent to the performance of a Red-Black tree.
 While an AA-tree makes more rotations than a Red-Black tree, the simpler algorithms
 tend to be faster, and all of this balances out to result in similar performance. A
 Red-Black tree is more consistent in its performance than an AA-tree, but an AA-tree
 tends to be flatter, which results in slightly faster search times.
 */
@interface AATree : AbstractTree
{
	/** A pointer to the root of the tree, set to <code>NULL</code> if empty. */
	AATreeNode *root;
}

@end
