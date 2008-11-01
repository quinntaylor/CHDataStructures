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
 tree with guaranteed O(log n) access. This is an Objective-C port of the AA-tree
 from <i>"Data Structures and Problem Solving Using Java"</i> by Mark Allen Weiss,
 published by Addison Wesley. Method names have been changed to match the APIs of
 existing Cocoa collections classes provided by Apple, and several optimizations
 in straight C have been made to optimize speed and memory usage.
 
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
{
	@private
	CHBalancedTreeNode *header; // Links to the root -- eliminates special cases
	CHBalancedTreeNode *sentinel; // Represents a NULL leaf node; reduces checks
}

/**
 Represent detailed information about an Andersson tree, printed in level order.
 This method is called by the "print-object" ("po") command in the gdb console,
 but can also be called directly in code. Intended only for testing purposes.
 */
- (NSString*) debugDescription;

@end
