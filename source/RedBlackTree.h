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
#import "RBNode.h"

/**
 Enumerators are tricky to do without recursion.
 Consider using a stack to store path so far?
 */
@interface RedBlackTreeEnumerator : NSEnumerator
{
    struct RBNode *currentNode;
	CHTraversalOrder traversalOrder;
    BOOL hasStarted;
    BOOL beenLeft;
    BOOL beenRight;
}

/** Create an enumerator which traverses a given subtree in the specified order. */
- (id)initWithRoot:(RedBlackNode *)root traversalOrder:(CHTraversalOrder)order;

/** Returns the next object from the collection being enumerated. */
- (id)nextObject;

/** Returns an array of objects the receiver has yet to enumerate. */
- (NSArray *)allObjects;
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

@end
