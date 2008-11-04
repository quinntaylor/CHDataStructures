/*
 CHRedBlackTree.h
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

#define kBLACK 0
#define kRED 1

/**
 A <a href="http://en.wikipedia.org/wiki/Red-black_trees">Red-Black tree</a>, a
 balanced binary search tree with guaranteed O(log n) access. The algorithms for
 insertion and removal in this implementation have been adapted from code in the
 <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_rbtree.aspx">
 Red-Black trees tutorial</a>, which is in the public domain, courtesy of
 <a href="http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have
 been changed to match the APIs of existing Cocoa collections provided by Apple.

 A Red-Black tree has four fundamental rules:
 <ol>
 <li>Every node is red or black.
 <li>The root is black.
 <li>If a node is red, its children must be black.
 <li>Every path from a node to a leaf contains the same number of black nodes.
 </ol>
 
 Also note that <code>nil</code> nodes are considered black for many purposes.
 This is really hard to make work right. For me at least.
 */
@interface CHRedBlackTree : CHAbstractTree
{
	CHTreeNode *current;
	CHTreeNode *parent;
	CHTreeNode *grandparent;
	CHTreeNode *greatgrandparent;
}

@end
