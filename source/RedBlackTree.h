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
#import "Comparable.h"

#define nRED 0
#define nBLACK 1

#pragma mark -

/**
 A node for use by RedBlackTree for internal storage and representation.
 */
@interface RedBlackNode : NSObject 
{
	short int color;
	id <Comparable> object;
	RedBlackNode *left;
	RedBlackNode *right;
}

- (id)initWithObject:(id <Comparable>)theObject;
- (id)initWithObject:(id <Comparable>)theObject
			withLeft:(RedBlackNode *)theLeft
		   withRight:(RedBlackNode *)theRight;

- (short int)color;
- (RedBlackNode *)left;
- (RedBlackNode *)right;
- (id)object;

- (void)setColor:(short int)newColor;
- (void)setLeft:(RedBlackNode *)newLeft;
- (void)setRight:(RedBlackNode *)newRight;
- (void)setObject:(id <Comparable>)newObject;

@end

#pragma mark -

/**
 A fast, balanced, non-recursive binary tree with guaranteed O(log n) access. This
 class is a direct Objective-C port of the Red Black tree found in "Data Structures
 and Problem Solving Using Java" by Mark Allen Weiss, published by Addison Wesley.

 There are four fundamental rules: (taken from the book mentioned above)
 <ol>
 <li> Every node is red or black.
 <li> The root is black.
 <li> If a node is red, its children must be black.
 <li> Every path from a node to a null link must contain the same number of black nodes.
 </ol>
 
 Also note that <code>nil</code> nodes are considered black for many purposes.
 This is really hard to make work right. For me at least.
 */
@interface RedBlackTree : AbstractTree
{
	RedBlackNode *header;   // links to the root -- eliminates special cases
	RedBlackNode *sentinel; // always black, stands in for nil
	
	@private RedBlackNode *current;
	@private RedBlackNode *parent;
	@private RedBlackNode *grandparent;
	@private RedBlackNode *greatgrandparent;
}

/**
 Create a new RedBlackTree with no nodes or stored objects.
 */
- (id)init;

#pragma mark Inherited Methods
- (void)addObject:(id <Comparable>)object;
- (id) findObject:(id <Comparable>)target;
- (id) findMin;
- (id) findMax;
//- (void)removeObject:(id <Comparable>)object;
//- (void)removeAllObjects;
- (NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)traversalOrder;

@end
