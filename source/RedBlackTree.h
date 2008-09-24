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
//
//  RedBlackTree.h
//  DataStructuresFramework
//
//  Created by Phillip Morelock on Sat Apr 06 2002.
//  Copyright (c) 2002 Phillip Morelock. All rights reserved, except as licensed to you.
//  This class is a direct port to Objective-C of the Red Black tree found in 
//  Data Structures and Problem Solving Using Java by Mark Allen Weiss, Addison Wesley
//

/**
 * A red black tree is a nonrecursive binary search tree. It results in a very well
 * balanced, yet fast, binary search tree with guaranteed logarithmic search time.
 *
 * Four rules:
 * (taken from Data Structures and Problem Solving Using Java by Mark Allen Weiss, Addison Wesley)
 * 1. Every node is red or black.
 * 2. The root is black.
 * 3. If a node is red, its children must be black.
 * 4. Every path from a node to a null link must contain the same number of black nodes.
 *
 * Also note that nil nodes are considered black for many purposes.
 * This is really hard to make work right.  For me at least.
 */

#import <Foundation/Foundation.h>
#import "AbstractTree.h"
#import "RBNode.h"

@interface RedBlackTreeEnumerator : NSEnumerator
{
    struct RBNode *currentNode;
	CHTraversalOrder traversalOrder;
    BOOL hasStarted;
    BOOL beenLeft;
    BOOL beenRight;
}

/** Create an enumerator which traverses a given subtree in the specified order. */
- (id)initWithRoot:(RBNode *)root traversalOrder:(CHTraversalOrder)order;

/** Returns the next object from the collection being enumerated. */
- (id)nextObject;

/** Returns an array of objects the receiver has yet to enumerate. */
- (NSArray *)allObjects;
@end

#pragma mark -

@interface RedBlackTree : AbstractTree
{
    RBNode *header;   // links to the root -- eliminates special cases
    RBNode *sentinel; // always black, stands in for nil
    
    @private RBNode *current;
    @private RBNode *parent;
    @private RBNode *grandparent;
    @private RBNode *greatgrandparent;
}

/**
 Create a new RedBlackTree with no nodes or stored objects.
 */
- (id)init;

@end
