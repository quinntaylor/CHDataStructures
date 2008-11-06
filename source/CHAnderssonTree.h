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
 
 An <i>Arne Andersson tree</i> is similar to a Red-Black tree, but with a simple
 restriction that simplifies maintenance operations for balancing the tree: red
 nodes (which represent horizontal links to subtrees) are only allowed as the
 right child of a node. Thus, rather than balancing all 7 possible subtrees of 2
 and 3 nodes, an AA-tree need only be concerned with 2, so consequently only 2
 operations (called <i>skew</i> and <i>split</i>) are required. These operations
 are designed to eliminate red nodes on the left side and consecutive red nodes
 on the right side, respectively, and are illustrated below:
 
 <table align="center" border="0" cellpadding="0">
 <tr>
 <th style="vertical-align: top">
	Figure 1 - The <code>skew</code> operation
	@image html aa-tree-skew.png
 </th>
 <td width="50"></td>
 <th style="vertical-align: top">
	Figure 2 - The <code>split</code> operation
	@image html aa-tree-split.png
 </th>
 </table>

 Performance of an AA-tree is roughly equivalent to that of a Red-Black tree.
 While an AA-tree makes more rotations than a Red-Black tree, the algorithms are
 simpler to understand and tend to be somewhat faster, and all of this balances
 out to result in similar performance. A Red-Black tree is more consistent in
 its performance than an AA-tree, but an AA-tree tends to be flatter, which
 results in slightly faster search.
 */
@interface CHAnderssonTree : CHAbstractTree

@end
