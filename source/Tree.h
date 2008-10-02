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

//  Tree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Util.h"
#import "Stack.h"

/**
 A set of constant values denoting the order in which to traverse a tree structure.
 For details, see: http://en.wikipedia.org/wiki/Tree_traversal#Traversal_methods
 */
enum _CHTraversalOrder {
	CHTraverseInOrder,      /**< Visit left subtree, ROOT, then right subtree. */
	CHTraverseReverseOrder, /**< Visit right subtree, ROOT, then left subtree. */
	CHTraversePreOrder,     /**< Visit ROOT, left subtree, then right subtree. */
	CHTraversePostOrder,    /**< Visit left subtree, right subtree, then ROOT. */
	CHTraverseLevelOrder    /**< Visit nodes on each level left-right, top-bottom. */
};
typedef short CHTraversalOrder;

#define isValidTraversalOrder(o) (o>=CHTraverseInOrder && o<=CHTraverseLevelOrder)

/**
 A <a href="http://en.wikipedia.org/wiki/Tree_(data_structure)">tree</a> protocol
 which specifes an interface for N-ary tree structures. Defines methods to
 support insertion, removal, search, and element enumeration. This protocol works for
 trees where nodes have any number of children, not just binary trees. Although any
 conforming class must implement all these methods, they may document that certain of
 them are unsupported, and/or raise exceptions when they are called.
 
 Objects in a Tree are inserted according to their sorted order, so they must respond
 to the <code>compare:</code> selector, which accepts another object and returns one
 of <code>{NSOrderedAscending|NSOrderedSame|NSOrderedDescending}</code> as the
 receiver is less than, equal to, or greater than the argument, respectively. (See
 <code>NSComparisonResult</code> in NSObjCRuntime.h for details.)

 @todo Add support for methods in NSCoding, NSMutableCopying, and NSFastEnumeration.
 */
@protocol Tree <NSObject>

/**
 Initialize a newly-allocated tree with no objects.
 */
- (id) init;

/**
 Add an object to the tree. Ordering is based on an object's response to the
 <code>compare:</code> message. Since no duplicates are allowed, if the tree already
 has an object for which <code>compare:</code> returns <code>NSOrderedSame</code>,
 the old object is released and replaced by the new object.
 */
- (void) addObject:(id)anObject;

/**
 Determines if the tree contains a given object (or one identical to it). Matches are
 based on an object's response to the <code>isEqual:</code> message.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Creates an NSArray which contains the objects in this tree.
 The tree traversal ordering (in-order, pre-order, post-order) must be specified.
 The object traversed last will be at the end of the array.
 
 @param order The traversal order to use for enumerating the given tree.
 */
- (NSArray*) contentsAsArrayUsingTraversalOrder:(CHTraversalOrder)order;

/**
 Creates an NSSet which contains the objects in this tree. Generally uses a pre-order
 traversal, since it uses less space, is extremely fast, and sets are unordered.
 */
- (NSSet*) contentsAsSet;

/**
 Returns the number of objects currently in the tree.
 */
- (NSUInteger) count;

/**
 Return the maximum (rightmost) object in the tree.
 */
- (id) findMax;

/**
 Return the minimum (leftmost) object in the tree.
 */
- (id) findMin;

/**
 Return the object for which <code>compare:</code> returns NSOrderedSame, or
 <code>nil</code> if no matching object is found in the tree.
 
 @param anObject The object to be matched and located in the tree.
 */
- (id) findObject:(id)anObject;

/**
 Remove an object from the tree (or one identical to it) if it exists. Matches are
 based on an object's response to the <code>isEqual:</code> message. If no matching
 object exists, there is no effect.
 */
- (void) removeObject:(id)element;

/**
 Remove all objects from the tree; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an enumerator that accesses each object using the specified traversal order.
 
 NOTE: When you use an enumerator, you must not modify the tree during enumeration.
 
 @param order The order in which an enumerator should traverse the nodes in the tree.
 */
- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order;

/**
 Returns an enumerator that accesses each object in the tree in ascending order.
 
 NOTE: When you use an enumerator, you must not modify the tree during enumeration.
 
 @see #objectEnumeratorWithTraversalOrder:
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the tree in descending order.
 
 NOTE: When you use an enumerator, you must not modify the tree during enumeration.
 
 @see #objectEnumeratorWithTraversalOrder:
 */
- (NSEnumerator*) reverseObjectEnumerator;

@end
