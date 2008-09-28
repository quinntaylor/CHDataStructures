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

//  RedBlackTree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractTree.h"

#define nRED 0
#define nBLACK 1

#pragma mark -

/**
 A node for use by RedBlackTree for internal storage and representation.
 */
@interface RedBlackTreeNode : NSObject 
{
	BOOL color;
	RedBlackTreeNode *left;
	RedBlackTreeNode *right;
	id object;
}

- (id) initWithObject:(id)theObject;
- (id) initWithObject:(id)theObject
             withLeft:(RedBlackTreeNode *)theLeft
            withRight:(RedBlackTreeNode *)theRight;

- (BOOL) color;
- (RedBlackTreeNode *) left;
- (RedBlackTreeNode *) right;
- (id) object;

- (void) setColor:(BOOL)newColor;
- (void) setLeft:(RedBlackTreeNode *)newLeft;
- (void) setRight:(RedBlackTreeNode *)newRight;
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
@interface RedBlackTree : AbstractTree
{
	RedBlackTreeNode *header;   // links to the root -- eliminates special cases
	RedBlackTreeNode *sentinel; // always black, stands in for nil
	
	@private RedBlackTreeNode *current;
	@private RedBlackTreeNode *parent;
	@private RedBlackTreeNode *grandparent;
	@private RedBlackTreeNode *greatgrandparent;
}

/**
 Create a new RedBlackTree with no nodes or stored objects.
 */
- (id)init;

#pragma mark Inherited Methods
- (void)addObject:(id)object;
- (id) findObject:(id)target;
- (id) findMin;
- (id) findMax;
//- (BOOL) containsObject:(id)anObject;
//- (void)removeObject:(id)object;
//- (void)removeAllObjects;
- (NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)traversalOrder;

@end
