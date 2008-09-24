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
/*
 *  Tree.h
 *  DataStructuresFramework
 */

#import <Foundation/Foundation.h>
#import "Comparable.h"
#import "Stack.h"

/**
 A set of constant values denoting the order in which to traverse a tree structure.
 For details, see: http://en.wikipedia.org/wiki/Tree_traversal#Traversal_methods
 */
enum _CHTraversalOrder {
	CHTraverseInOrder,		/**< Visit left subtree, ROOT, then right subtree. */
	CHTraversePreOrder,		/**< Visit ROOT, left subtree, then right subtree. */
	CHTraversePostOrder,	/**< Visit left subtree, right subtree, then ROOT. */
	CHTraverseLevelOrder	/**< Visit nodes on each level left-right, top-bottom. */
};
typedef short CHTraversalOrder;

#define isValidTraversalOrder(o) (o>=CHTraverseInOrder && o<=CHTraverseLevelOrder)

/**
 A protocol which specifies a tree and defines methods to support insertion, removal,
 search, and element enumeration. This protocol works for N-ary trees, not just those
 with only 2 children per node (aka "binary search trees"). Although any conforming
 class must implement all these methods, they may document that certain of them are
 unsupported, and/or raise exceptions when they are called.
 */
@protocol Tree <NSObject>

/**
 Returns an autoreleased tree containing the objects obtained from an enumerator,
 inserted in the order they are provided via <code>nextObject</code>. Each object
 is retained as it is inserted in the tree, but no copies are made. The behavior is
 unspecified if the objects do not conform to the Comparable protocol.
 */
+ (id<Tree>)treeWithObjectsFromEnumerator:(NSEnumerator*)enumerator;

/**
 Returns an autoreleased tree containing the objects obtained from a collection,
 inserted in the order they are provided via fast enumeration. Each object is
 retained as it is inserted in the tree, but no copies are made. The behavior is
 unspecified if the objects do not conform to the Comparable protocol.
 
 NOTE: Only supported on 10.5 and beyond.
 */
+ (id<Tree>)treeWithObjectsFromFastEnumeration:(id<NSFastEnumeration>)collection;

/**
 Add an object to the tree. Since no duplicates are allowed, if the tree already has
 an object for which compare: returns NSOrderedSame, the old object is released and
 replaced by the new object.
 */
- (void)addObject:(id <Comparable>)anObject;

/**
 Add multiple objects to the tree, inserted in the order they appear in the array.
 All objects in the array must conform to Comparable.
 */
- (void)addObjectsFromArray:(NSArray *)anArray;

/**
 Returns <code>YES</code> if compare: returns NSOrderedSame for an object in the
 tree, <code>NO</code> otherwise.
 */
- (BOOL)containsObject:(id <Comparable>)anObject;

/**
 If the tree contains an object for which compare: returns NSOrderedSame, then that
 object is removed; otherwise, there is no effect.
 */
- (void)removeObject:(id <Comparable>)element;

/**
 Remove all objects from the tree. If the tree is already empty, there is no effect.
 */
- (void)removeAllObjects;

/**
 Return the maximum (rightmost) object in the tree.
 */
- (id)findMax;

/**
 Return the minimum (leftmost) object in the tree.
 */
- (id)findMin;

/**
 Return the object for which compare: returns NSOrderedSame, or <code>nil</code> if
 no matching object is found in the tree.
 */
- (id)findObject:(id <Comparable>)anObject;

/**
 Returns<code>YES</code> if the tree contains no objects, <code>NO</code> otherwise.
 */
- (BOOL)isEmpty;

/**
 Create an enumerator which uses the specified traversal order.
 */
- (NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)traversalOrder;

@end
