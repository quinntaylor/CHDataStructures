/*
 CHDataStructures.framework -- CHAbstractBinarySearchTree.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableObject.h"
#import "CHSearchTree.h"

/**
 @file CHAbstractBinarySearchTree.h
 An abstract CHSearchTree implementation with many default method implementations.
 */

/**
 A node used by binary search trees for internal storage and representation.
 
 <pre>
    typedef struct CHBinaryTreeNode {
        id object;
        union {
            struct {
                __strong struct CHBinaryTreeNode *left;
                __strong struct CHBinaryTreeNode *right;
            };
            __strong struct CHBinaryTreeNode *link[2];
        };
        union {
              int32_t balance;   // Used by CHAVLTree
            u_int32_t color;     // Used by CHRedBlackTree
            u_int32_t level;     // Used by CHAnderssonTree
            u_int32_t priority;  // Used by CHTreap
        };
    } CHBinaryTreeNode;</pre>
 
 The nested anonymous union and structs are to provide flexibility for dealing with various types of trees and access. (For those not familiar, a <a href="http://en.wikipedia.org/wiki/Union_(computer_science)">union</a> is a data structure in which all members are stored at the same memory location, and can take on the value of any of its fields. A union occupies only as much space as the largest member, whereas a struct requires space equal to at least the sum of the size of its members.)
 
 - The first union provides two equivalent ways to access child nodes, based on what is most convenient and efficient. Because of the order in which the fields are declared, <code>left === link[0]</code> and <code>right === link[1]</code>, meaning these respective pairs point to the same memory address. (This technique is an adaptation of the idiom used in the BST tutorials on <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_bst1.aspx">EternallyConfuzzled.com</a>.)
 - The second union allows balanced trees to store extra data at each node, while using the field name and type that makes sense for its algorithms. This allows for generic reuse while promoting meaningful semantics and preserving space. These fields use 32-bit-only types since we don't need extra space in 64-bit mode.
 
 Since CHUnbalancedTree doesn't store any extra data, the second union is essentially 4 bytes of pure overhead per node. However, since unbalanced trees are generally not a good choice for sorting large data sets anyway, this is largely a moot point.
 */
typedef struct CHBinaryTreeNode {
	id object;                        ///< The object stored in the node.
	union {
		struct {
			__strong struct CHBinaryTreeNode *left;  ///< Link to left child.
			__strong struct CHBinaryTreeNode *right; ///< Link to right child.
		};
		__strong struct CHBinaryTreeNode *link[2];   ///< Links to both childen.
	};
	union {
		  int32_t balance;   // Used by CHAVLTree
		u_int32_t color;     // Used by CHRedBlackTree
		u_int32_t level;     // Used by CHAnderssonTree
		u_int32_t priority;  // Used by CHTreap
	};
} CHBinaryTreeNode;

/**
 An abstract CHSearchTree with many default method implementations. Methods for search, size, and enumeration are implemented in this class, as are methods for NSCoding, NSCopying, and NSFastEnumeration. (This works since all child classes use the CHBinaryTreeNode struct.) Any subclass @b must implement \link #addObject: -addObject:\endlink and \link #removeObject: -removeObject:\endlink according to the inner workings of that specific tree, and @b should also override \link #dotGraphStringForNode: -dotGraphStringForNode:\endlink and \link #debugDescriptionForNode: -debugDescriptionForNode:\endlink to display any algorithm-specific information in generated DOT graphs and debugging output, respectively.
 
 Rather than enforcing that this class be abstract, the contract is implied. If this class were actually instantiated, it would be of little use since there is attempts to insert or remove will result in runtime exceptions being raised.
 
 Much of the code and algorithms for trees was distilled from information in the <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_bst1.aspx">Binary Search Trees tutorial</a>, which is in the public domain, courtesy of <a href="http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have been changed to match the APIs of existing Cocoa collections provided by Apple.
 */
@interface CHAbstractBinarySearchTree : CHLockableObject <CHSearchTree>
{
	__strong CHBinaryTreeNode *header; // Dummy header; no more checks for root.
	__strong CHBinaryTreeNode *sentinel; // Dummy leaf; no more checks for NULL.
	NSUInteger count; // The number of objects currently in the tree.
	unsigned long mutations; // Tracks mutations for NSFastEnumeration.
}

/**
 Produces a representation of the receiver that can be useful for debugging.
 
 Whereas @c -description outputs only the contents of the tree in ascending order, this method outputs the internal structure of the tree (showing the objects in each node and its children) using a pre-order traversal.
 
 Calls #debugDescriptionForNode: to get the representation for each node in the tree. Sentinel leaf nodes are represented as nil children.
 
 @note Using @c print-object or @c po within GDB automatically calls the @c -debugDescription method of the specified object.
 
 @see debugDescriptionForNode:
 */
- (NSString*) debugDescription;

/**
 Produces a debugging description for a given tree node.
 
 This method determines the appearance of nodes in the graph produced by #debugDescription, and may be overriden by subclasses to display any additional relevant information, such as the extra field used by self-balancing trees. The default implementation returns the @c -description for the object in the node, surrounded by quote marks.
 
 @param node The tree node for which to create a debugging representation.
 @return A representation of a tree node intended for debugging purposes.
 
 @see debugDescription
 */
- (NSString*) debugDescriptionForNode:(CHBinaryTreeNode*)node;

/**
 Produces a <a href="http://en.wikipedia.org/wiki/DOT_language">DOT language</a> graph description for the receiver tree.
 
 A DOT graph can be rendered with <a href="http://www.graphviz.org/">GraphViz</a>, <a href="http://www.omnigroup.com/applications/OmniGraffle/">OmniGraffle</a>, or other similar tools.
 
 Calls #dotGraphStringForNode: to get the representation for each node in the tree. Sentinel leaf nodes are represented by a small black dot.
 
 @return A graph description for the receiver tree in the DOT language.
 
 @see dotGraphStringForNode:
 */
- (NSString*) dotGraphString;

/**
 Produces a <a href="http://en.wikipedia.org/wiki/DOT_language">DOT language</a> description for a given tree node.
 
 This method determines the appearance of nodes in the graph produced by #dotGraphString, and may be overriden by subclasses to display any additional relevant information, such as the extra field used by self-balancing trees. The default implementation creates an oval containing the value returned by @c -description for the object in the node.
 
 @param node The tree node for which to create a DOT representation.
 @return A representation of a tree node in the DOT language.
 
 @see dotGraphString
 */
- (NSString*) dotGraphStringForNode:(CHBinaryTreeNode*)node;

@end
