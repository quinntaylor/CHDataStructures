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
 balanced binary tree with guaranteed O(log n) access. This is an Objective-C port of
 the Red-Black tree from <i>"Data Structures and Problem Solving Using Java"</i>
 by Mark Allen Weiss, published by Addison Wesley. Method names have been changed to
 match the APIs of existing Cocoa collections classes provided by Apple, and several
 optimizations in straight C have been made to optimize speed and memory usage.

 A Red-Black tree has four fundamental rules: (taken from the book mentioned above)
 <ol>
 <li>Every node is red or black.
 <li>The root is black.
 <li>If a node is red, its children must be black.
 <li>Every path from a node to a null link must contain the same number of black nodes.
 </ol>
 
 Also note that <code>nil</code> nodes are considered black for many purposes.
 This is really hard to make work right. For me at least.
 */
@interface CHRedBlackTree : CHAbstractTree
{
	CHBalancedTreeNode *header;   // Links to the root -- eliminates special cases
	CHBalancedTreeNode *sentinel; // Stands in for NULL leaf node; always kBLACK

	@private
	CHBalancedTreeNode *current;
	CHBalancedTreeNode *parent;
	CHBalancedTreeNode *grandparent;
	CHBalancedTreeNode *greatgrandparent;
}

/**
 Represent detailed information about a red-black tree, printed in level order.
 This method is called by the "print-object" ("po") command in the gdb console,
 but can also be called directly in code. Intended only for testing purposes.
 */
- (NSString*) debugDescription;
	
@end
