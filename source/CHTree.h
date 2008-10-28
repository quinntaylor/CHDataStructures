/*
 CHTree.h
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
#import "Util.h"

/**
 @file CHTree.h
 
 A <a href="http://en.wikipedia.org/wiki/Tree_(data_structure)">tree</a> protocol
 which specifes an interface for N-ary tree structures.
 */

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
 of <code>{NSOrderedAscending | NSOrderedSame | NSOrderedDescending}</code> as the
 receiver is less than, equal to, or greater than the argument, respectively. (See
 <code>NSComparisonResult</code> in NSObjCRuntime.h for details.)
 
 There are several methods for visiting each node in a tree data structure, known as
 <a href="http://en.wikipedia.org/wiki/Tree_traversal">tree traversal</a> techniques.
 (Traversal applies to N-ary trees, not just binary trees.) Whereas linked lists and
 arrays have one or two logical means of stepping through the elements, because trees
 are branching structures, there are many different ways to choose how to visit all
 of the nodes. There are 5 most commonly-used tree traversal methods; of these, 4 are
 <a href="http://en.wikipedia.org/wiki/Depth-first_traversal">depth-first</a> and 1
 is <a href="http://en.wikipedia.org/wiki/Breadth-first_traversal">breadth-first</a>.
 These methods are described below:
 
 <table align="center" width="100%" border="0" cellpadding="0">
 <tr>
 <td style="vertical-align: bottom">
	@image html tree-traversal.png "Figure 1 — A sample binary tree."
 </td>
 <td style="vertical-align: bottom" align="center">
 
 <table style="border-collapse: collapse;">
 <tr style="background: #ddd;">
     <th>Traversal</th>     <th>Visit Order</th> <th>Node Ordering</th>
 </tr>
 <tr><td>In-order</td>	    <td>L, node, R</td>  <td>A B C D E F G H I</td></tr>
 <tr><td>Reverse-order</td> <td>R, node, L</td>  <td>I H G F E D C B A</td></tr>
 <tr><td>Pre-order</td>	    <td>node, L, R</td>  <td>F B A D C E G I H</td></tr>
 <tr><td>Post-order</td>	<td>L, R, node</td>  <td>A C E D B H I G F</td></tr>
 <tr><td>Level-order</td>	<td>L→R, T→B</td>    <td>F B G A D I C E H</td></tr>
 </table>
 <p><strong>Table 1 - Various tree traversals on Figure 1.</strong></p>
 
 </td></tr>
 </table>
 
 These orderings correspond to the following constants, also declared in CHTree.h:
 
 - <code>CHTraverseInOrder</code>
 - <code>CHTraverseReverseOrder</code>
 - <code>CHTraversePreOrder</code>
 - <code>CHTraversePostOrder</code>
 - <code>CHTraverseLevelOrder</code>
 
 These constants are used primarily with @link #objectEnumeratorWithTraversalOrder:
 -[Tree objectEnumeratorWithTraversalOrder:]@endlink to obtain an NSEnumerator that
 provides objects from the tree by traversing using the specified order.
 */
@protocol CHTree <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a tree with no objects.
 */
- (id) init;

/**
 Initialize a tree with the contents of an array. Objects are added to the tree
 in the order they occur in the array.
 
 @param anArray An array containing object with which to populate a new deque.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Add an object to the tree. Ordering is based on an object's response to the
 <code>compare:</code> message. Since no duplicates are allowed, if the tree already
 has an object for which <code>compare:</code> returns <code>NSOrderedSame</code>,
 the old object is released and replaced by the new object.
 
 @param anObject The object to add to the queue; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObject:(id)anObject;

/**
 Determines if the tree contains a given object (or one identical to it). Matches are
 based on an object's response to the <code>isEqual:</code> message.

 @param anObject The object to test for membership in the queue.
 @return <code>YES</code> if <i>anObject</i> is present in the queue, <code>NO</code>
         if it not present or <code>nil</code>.
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
 Returns the maximum (rightmost) object in the tree.
 
 @return The maximum (rightmost) object in the tree, or <code>nil</code> if empty.
 */
- (id) findMax;

/**
 Returns the minimum (leftmost) object in the tree.
 
 @return The minimum (leftmost) object in the tree, or <code>nil</code> if empty.
 */
- (id) findMin;

/**
 Return the object for which <code>compare:</code> returns <code>NSOrderedSame</code>.
 
 @param anObject The object to be matched and located in the tree.
 @return An object which matches @a anObject, or <code>nil</code> if none is found.
 */
- (id) findObject:(id)anObject;

/**
 Remove an object for which <code>compare:</code> returns <code>NSOrderedSame</code>.
 If no matching object exists, there is no effect.

 @param anObject The object to be removed from the tree.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all objects from the tree; if it is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an array containing the objects in this tree in ascending sorted order.
 
 @return An array containing the objects in this tree. If the tree is empty, the
         array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns an enumerator that accesses each object using the specified traversal order.
 The enumerator returned should never be nil; if the tree is empty, the enumerator
 will always return nil for -nextObject, and an empty array for -allObjects.
 
 NOTE: When you use an enumerator, you must not modify the tree during enumeration.
 
 @param order The order in which an enumerator should traverse the nodes in the tree.
 */
- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order;

/**
 Returns an enumerator that accesses each object in the tree in ascending order.
 
 NOTE: When you use an enumerator, you must not modify the tree during enumeration.
 
 @see @link #objectEnumeratorWithTraversalOrder:
      -[Tree objectEnumeratorWithTraversalOrder:] @endlink
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the tree in descending order.
 
 NOTE: When you use an enumerator, you must not modify the tree during enumeration.
 
 @see @link #objectEnumeratorWithTraversalOrder:
      -[Tree objectEnumeratorWithTraversalOrder:] @endlink
 */
- (NSEnumerator*) reverseObjectEnumerator;

@end
