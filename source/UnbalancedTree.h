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

//  UnbalancedTree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractTree.h"

/**
 Represents a node in an unbalanced binary tree, with 1 parent and 2 child links.
 */
typedef struct BinaryNode {
    id <Comparable> object;		/**< The object stored in a particular node. */
    struct BinaryNode *left;	/**< The left child node, if any. */
    struct BinaryNode *right;	/**< The right child node, if any. */
    struct BinaryNode *parent;	/**< The parent node, if not the root of the tree. */
} BinaryNode;

#define bNODESIZE sizeof(struct BinaryNode)

#pragma mark -

/**
 An enumerator which traverses a specified subtree in the specified order.

 NOTE: Tree enumerators are tricky to do without recursion.
 Consider using a stack to store path so far?
 */
@interface UnbalancedTreeEnumerator : NSEnumerator
{
    struct BinaryNode *currentNode;		/**< The next node that is to be returned. */
	CHTraversalOrder traversalOrder;	/**< Order in which to traverse the tree. */
    BOOL hasStarted;
    BOOL beenLeft;
    BOOL beenRight;
}

/** Create an enumerator which traverses a given subtree in the specified order. */
- (id)initWithRoot:(struct BinaryNode *)root traversalOrder:(CHTraversalOrder)order;

/** Returns the next object from the collection being enumerated. */
- (id)nextObject;

/** Returns an array of objects the receiver has yet to enumerate. */
- (NSArray *)allObjects;
@end

#pragma mark -

/**
 A simple, unbalanced binary tree that <b>does not</b> guarantee O(log n) access.
 Even though the tree is never balanced when items are added or removed, access is
 <b>at worst</b> linear if the tree essentially degenerates into a linked list.
 This class is fast, and without stack risk because it works without recursion.
 In release 0.4.0, nodes objects were changed to C structs for enhanced performance.
 */
@interface UnbalancedTree : AbstractTree
{
	/** A pointer to the root node of the tree, set to NULL if it is empty. */
    struct BinaryNode *root;
}

/**
 Create a new UnbalancedTree with no nodes or stored objects.
 */
- (id)init;

/**
 Create a new UnbalancedTree with a single root node that stores the given object.
 */
- (id)initWithObject:(id <Comparable>)rootObject;

@end

