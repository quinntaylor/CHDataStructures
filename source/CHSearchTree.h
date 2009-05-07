/*
 CHDataStructures.framework -- CHSearchTree.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHSortedSet.h"

/**
 @file CHSearchTree.h
 
 A protocol which specifes an interface for N-ary search trees.
 */

/**
 A set of constant values denoting the order in which to traverse a tree structure. For details, see: http://en.wikipedia.org/wiki/Tree_traversal#Traversal_methods
 */
typedef enum {
	CHTraverseAscending,   /**< Visit left subtree, node, then right subtree. */
	CHTraverseDescending,  /**< Visit right subtree, node, then left subtree. */
	CHTraversePreOrder,    /**< Visit node, left subtree, then right subtree. */
	CHTraversePostOrder,   /**< Visit left subtree, right subtree, then node. */
	CHTraverseLevelOrder   /**< Visit nodes from left-right, top-bottom. */
} CHTraversalOrder;

#define isValidTraversalOrder(o) (o>=CHTraverseAscending && o<=CHTraverseLevelOrder)

/**
 A protocol which specifes an interface for search trees, whether the customary <a href="http://en.wikipedia.org/wiki/Binary_search_tree">binary tree</a>, an N-ary tree structure, or any similary tree-like structure. This protocol extends the CHSortedSet protocol with two additional methods (\link #allObjectsWithTraversalOrder: -allObjectsWithTraversalOrder:\endlink and \link #objectEnumeratorWithTraversalOrder: -objectEnumeratorWithTraversalOrder:\endlink) specific to search tree implementations of a sorted set.
 
 Trees have a hierarchical structure and make heavy use of pointers to child nodes to organize information. There are several methods for visiting each node in a tree data structure, known as <a href="http://en.wikipedia.org/wiki/Tree_traversal">tree traversal</a> techniques. (Traversal applies to N-ary trees, not just binary trees.) Whereas linked lists and arrays have one or two logical means of stepping through the elements, because trees are branching structures, there are many different ways to choose how to visit all of the nodes. There are 5 most commonly-used tree traversal methods; of these, 4 are depth first and 1 is breadth-first. These methods are described below:
 
 <table align="center" width="100%" border="0" cellpadding="0">
 <tr>
 <td style="vertical-align: bottom">
 @image html tree-traversal.png "Figure 1 — A sample binary search tree."
 </td>
 <td style="vertical-align: bottom" align="center">
 
 <table style="border-collapse: collapse;">
 <tr style="background: #ddd;">
     <th>#</th> <th>Traversal</th>     <th>Visit Order</th> <th>Node Ordering</th>
 </tr>
 <tr><td>1</td> <td>In-order</td>      <td>L, node, R</td> <td>A B C D E F G H I</td></tr>
 <tr><td>2</td> <td>Reverse-order</td> <td>R, node, L</td> <td>I H G F E D C B A</td></tr>
 <tr><td>3</td> <td>Pre-order</td>     <td>node, L, R</td> <td>F B A D C E G I H</td></tr>
 <tr><td>4</td> <td>Post-order</td>    <td>L, R, node</td> <td>A C E D B H I G F</td></tr>
 <tr><td>5</td> <td>Level-order</td>   <td>L→R, T→B</td>   <td>F B G A D I C E H</td></tr>
 </table>
 <p><strong>Table 1 - Various tree traversals on Figure 1.</strong></p>
 
 </td></tr>
 </table>
 
 These orderings correspond to the following constants, respectively:
 
 <ol>
 <li>@c CHTraverseAscending</li>
 <li>@c CHTraverseDescending</li>
 <li>@c CHTraversePreOrder</li>
 <li>@c CHTraversePostOrder</li>
 <li>@c CHTraverseLevelOrder</li>
 </ol>
 
 These constants are used primarily in connection with \link #objectEnumeratorWithTraversalOrder: -objectEnumeratorWithTraversalOrder:\endlink for enumerating over objects from a search tree in a specified order.
 */
@protocol CHSearchTree <CHSortedSet>

/**
 Initialize a search tree with no objects.
 */
- (id) init;

/**
 Initialize a search tree with the contents of an array. Objects are added to the tree in the order they occur in the array.
 
 @param anArray An array containing objects with which to populate a new search tree.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an NSArray which contains the objects in this tree in a given ordering. The object traversed last will appear last in the array.
 
 @param order The traversal order to use for enumerating the given tree.
 @return An array containing the objects in this tree. If the tree is empty, the array is also empty.

 @see allObjects
 @see objectEnumeratorWithTraversalOrder:
 @see removeAllObjects
 @see reverseObjectEnumerator
 */
- (NSArray*) allObjectsWithTraversalOrder:(CHTraversalOrder)order;

/**
 Returns an enumerator that accesses each object using a given traversal order.
 
 @param order The order in which an enumerator should traverse nodes in the tree. @return An enumerator that accesses each object in the tree in a given order. The enumerator returned is never @c nil; if the tree is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see allObjectsWithTraversalOrder:
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see reverseObjectEnumerator
 */
- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order;

// @}
@end
