/*
 CHTreap.h
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
 A <a href="http://en.wikipedia.org/wiki/Treap">Treap</a>, a balanced binary
 tree with O(log n) access in general, and improbable worst cases. The name
 treap is a portmanteau of "tree" and "heap", which is fitting since treaps
 exhibit properties of both binary search trees and heaps. Each node in a treap
 contains an object and a priority value which is unrelated to the object. Nodes
 in a treap are arranged such that the objects are ordered as in a binary search
 tree, and the priorities are ordered to obey the heap property (every node must
 have a higher priority than both its children). A sample treap is presented
 below, with priorities shown below the nodes.
 
 @image html treap-sample.png "Figure 1 - A sample treap."
 
 Notice that, unlike a binary heap, a treap need not be a <i>complete tree</i>,
 which is a tree where every level is complete, with the possible exception of
 the lowest level, in which case any gaps must occur only on the right side.
 Also, the priority can be any numerical value—it doesn't matter whether it's an
 int or a float, positive or negative, signed or unsigned, as long as the range
 is large enough to accommodate the number of objects that may be present in the
 treap. Priorities are also not strictly required to be unique, but it can help.
 
 Nodes are reordered to satisfy the heap property using rotations involving only
 two nodes, which change the position of children in the tree, but leave the
 subtrees unchanged. The rotation operations are mirror images of each other,
 and are shown below:
 
 @image html treap-rotations.png "Figure 2 - The effect of rotation operations."
 
 Since subtrees may be rotated to satisfy the heap property without violating
 the BST property, these two properties never conflict. In fact, for a given set
 of objects and priorities, there is only one treap structure that can satisfy
 both properties. In practice, when the priority for each node is truly random,
 the tree is relatively well balanced, with expected height of Θ(log n). Treap
 performance is extremely fast on average, with a small risk of slow performance
 in random worst cases, which tend to be quite rare in practice.
 
 Insertion is a cross between standard BST insertion and heap insertion: a new
 leaf node is created in the appropriate sorted location, and a random value is
 assigned. The path back to the root is then retraced, rotating the node upward
 as necessary until the new node's priority is greater than both its children's.
 Deletion is generally implemented by rotating the node to be removed down the
 tree until it becomes a leaf and can be clipped. At each rotation, the child
 whose priority is higher is rotated to become the root, and the node to delete
 descends the opposite subtree. (It is also possible to swap with the successor
 node as is common in BST deletion, but in order to preserve the tree's balance,
 the priorities should also be swapped, and the successor be bubbled up until
 the heap property is again satisfied, an approach quite similar to insertion.)
 
 The principles of treaps were originally described in the following paper: (See
 <a href="http://sims.berkeley.edu/~aragon/pubs/rst89.pdf">PDF original</a> or
 <a href="http://www-tcs.cs.uni-sb.de/Papers/rst.ps">PostScript revision</a>)
 
 <b>R. Seidel and C. R. Aragon. Randomized Binary Search Trees.<br>
 <em>Algorithmica</em>, 16(4/5):464-497, 1996.
 </b>
 */
@interface CHTreap : CHAbstractTree

@end
