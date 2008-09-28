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

//  AATree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractTree.h"

/**
 A node for use by AATree for internal storage and representation.
 Holds an obejct, 2 child links, and level within the tree.
 */
typedef struct AATreeNode {
	id object;		/**< The object stored in a particular node. */
	struct AATreeNode *left;	/**< The left child node, if any. */
	struct AATreeNode *right;	/**< The right child node, if any. */
	NSInteger level;            /**< The level of this node in the AA-tree. */
} AATreeNode;

/**
 
 */
@interface AATree : AbstractTree {
	/** A pointer to the root of the tree, set to <code>NULL</code> if empty. */
	AATreeNode *root;
}

/**
 Create a new AATree with no nodes or stored objects.
 */
- (id) init;

#pragma mark Inherited Methods
- (void) addObject:(id)anObject;
- (id) findObject:(id)target;
- (id) findMin;
- (id) findMax;
- (BOOL) containsObject:(id)anObject;
- (void) removeObject:(id)anObject;
- (void) removeAllObjects;
- (NSEnumerator *) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order;

@end
