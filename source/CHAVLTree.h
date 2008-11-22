/*
 CHAVLTree.h
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

/**
 @file CHAVLTree.h
 An <a href="http://en.wikipedia.org/wiki/Avl_tree">AVL tree</a> implementation
 of CHTree.
 */

/**
 An <a href="http://en.wikipedia.org/wiki/Avl_tree">AVL tree</a>, a balanced
 binary search tree with guaranteed O(log n) access. The algorithms for insertion
 and removal in this implementation have been adapted from code in the
 <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_avl.aspx">
 AVL trees tutorial</a>, which is in the public domain, courtesy of <a href=
 "http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have been
 changed to match the APIs of existing Cocoa collections provided by Apple.
 
 AVL trees are more strictly balanced that most self-balancing binary trees, and
 consequently have slower insertion and deletion performance but faster lookup,
 although all operations are still O(log n) in both average and worst cases. AVL
 trees are shallower than their counterparts; for example, the maximum depth of
 AVL trees is <em>1.44 log n</em>, versus <em>2 log n</em> for Red-Black trees.
 In practice, AVL trees are quite competitive with other self-balancing trees,
 and the insertion and removal algorithms are much easier to understand.
 
 In an AVL tree, the heights of the child subtrees of any node may differ by at
 most one. If the heights differ by more than one, then one or more rotations
 around the unbalanced node are required to rebalance the tree. The 4 possible
 unbalanced cases and how to rebalance them are shown in Figure 1.
 
 <div align="center"><b>Figure 1 - Rebalancing cases in an AVL tree.</b></div>
 @image html avl-tree-rotations.png
 
 Although traditional AVL algorithms track the height of each node (one plus the
 maximum of the height of its chilren) this approach requires updating all the
 heights along the search path when inserting or removing objects. This penalty
 can be mitigated by instead storing a balance factor for each node, calculated
 as the height of the right subtree minus the height of the left subtree. (Any
 node with a balance factor of -1, 0, or +1 is considered to bebalanced.) If the
 balance factor of a node is -2 or +2, then rebalancing is required.
 
 Balance factors are updated when rotating, and at each rotation we must proceed
 back up the search path. However, on deletion, we can drop out of the loop when
 a node's balance factor becomes -1 or +1, since the heights of its subtrees has
 not changed. (If a node's balance factor becomes 0, the parent's balance factor
 must be updated, and may change to -2 or +2, requiring another rebalance.)
 
 Figure 2 shows a sample AVL tree, with tree heights in blue and balance factors
 in red beside each node.

 <div align="center"><b>Figure 2 - Sample AVL tree and balancing data.</b></div>
 @image html avl-tree-sample.png

 AVL trees were originally described in the following paper:
 
 <div style="margin: 0 25px; font-weight: bold;">
	 G. M. Adelson-Velsky and E. M. Landis.
	 "An algorithm for the organization of information."
	 <em>Proceedings of the USSR Academy of Sciences</em>, 146:263-266, 1962.
	 (English translation in <em>Soviet Mathematics</em>, 3:1259-1263, 1962.)
 </div>
 */
@interface CHAVLTree : CHAbstractTree

@end
