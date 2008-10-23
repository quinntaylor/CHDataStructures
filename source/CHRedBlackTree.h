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

#define nRED 0
#define nBLACK 1

#pragma mark -

// A node for use by CHRedBlackTree for internal storage and representation.
// TODO: Replace getters/setters with Objective-C 2.0 properties, or class with struct.
@interface CHRedBlackTreeNode : NSObject 
{
	BOOL color;
	CHRedBlackTreeNode *left;
	CHRedBlackTreeNode *right;
	id object;
}

- (id) initWithObject:(id)theObject;
- (id) initWithObject:(id)theObject
             withLeft:(CHRedBlackTreeNode*)theLeft
            withRight:(CHRedBlackTreeNode*)theRight;

- (BOOL) color;
- (CHRedBlackTreeNode*) left;
- (CHRedBlackTreeNode*) right;
- (id) object;

- (void) setColor:(BOOL)newColor;
- (void) setLeft:(CHRedBlackTreeNode*)newLeft;
- (void) setRight:(CHRedBlackTreeNode*)newRight;
- (void) setObject:(id)newObject;

@end

#pragma mark -

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
	CHRedBlackTreeNode *header;   // links to the root -- eliminates special cases
	CHRedBlackTreeNode *sentinel; // always black, stands in for nil

	@private
	CHRedBlackTreeNode *current;
	CHRedBlackTreeNode *parent;
	CHRedBlackTreeNode *grandparent;
	CHRedBlackTreeNode *greatgrandparent;
}

@end
