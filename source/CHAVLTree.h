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
 although all operations are still O(log n) in both average and worst cases.
 
 In an AVL tree, the heights of the two child subtrees of any node may differ by
 at most one. If one subtree is deeper than the other, one or more rotations are
 required to rebalance the tree. On insertion or deletion, balance is maintained
 by one or more rotations based around the unbalanced node. The performance hit
 for AVL trees exists because AVL algorithms are less tolerant of slight amounts
 of imbalance in the tree, and balances more frequently and more rigorously.
 The upside is that the depth of AVL trees is at most <em>1.44 log n</em>,
 compared to <em>2 log n</em> for Red-Black trees.

 AVL trees were originally described in the following paper:
 
 <div style="margin: 0 25px; font-weight: bold;">
	 G. M. Adelson-Velsky and E. M. Landis.
	 "An algorithm for the organization of information."
	 <em>Proceedings of the USSR Academy of Sciences</em>, 146:263–266, 1962.
	 (English translation in <em>Soviet Mathematics</em>, 3:1259–1263, 1962.)
 </div>
 */
@interface CHAVLTree : CHAbstractTree

@end
