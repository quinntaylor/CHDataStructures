/*
 CHAnderssonTree.h
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
 An <a href="http://en.wikipedia.org/wiki/AA_tree">AA-tree</a>, a balanced binary
 search tree with guaranteed O(log n) access. The algorithms for insertion and
 removal have been adapted from code in the
 <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_andersson.aspx">
 Andersson Tree tutorial</a>, which is in the public domain, courtesy of <a href=
 "http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have been
 changed to match the APIs of existing Cocoa collections provided by Apple.
 
 An <i>Arne Andersson tree</i> is similar to a RedBlackTree, but with a simple
 restriction that simplifies maintenance operations for balancing the tree.
 Rather than balancing all 7 possible subtrees of 2 and 3 nodes, an AA-tree need
 only be concerned with 2, so consequently only 2 operations (called <i>skew</i>
 and <i>split</i>, or left and right rotations, respectively) are required.

 The performance of an AA-tree is equivalent to the performance of a Red-Black
 tree. While an AA-tree makes more rotations than a Red-Black tree, the simpler
 algorithms tend to be faster, and all of this balances out to result in similar
 performance. A Red-Black tree has more consistent performance than an AA-tree,
 but an AA-tree tends to be flatter, which results in slightly faster search.
 */
@interface CHAnderssonTree : CHAbstractTree

@end
