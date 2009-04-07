/*
 CHAbstractBinarySearchTree.h
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

#import "CHLockable.h"
#import "CHSearchTree.h"

/**
 @file CHAbstractBinarySearchTree.h
 An abstract CHSearchTree implementation with many default method implementations.
 */

/**
 A node used by binary search trees for internal storage and representation.
 
 The nested anonymous union and structs are to provide flexibility for dealing
 with various types of trees and access. The first union (with pointers to the
 struct itself) provides 2 distinct yet equivalent ways to access child nodes,
 based on what is most convenient and efficient. (e.g. 'left' is equivalent to
 'link[0]', and 'right' is equivalent to 'link[1]'). The second union (which has
 integer fields) allows the same node to be used in several different balanced
 trees, while preserving useful semantic meaning appropriate for each algorithm.
 */
typedef struct CHBinaryTreeNode {
	id object;                        /**< The object stored in the node. */
	union {
		struct {
			struct CHBinaryTreeNode *left;  /**< Link to left child node. */
			struct CHBinaryTreeNode *right; /**< Link to right child node. */
		};
		struct CHBinaryTreeNode *link[2];   /**< Links to left and right childen. */
	};
	union {
		  int32_t balance;            /**< A node's balance factor (CHAVLTree) */
		u_int32_t color;              /**< A node's color (CHRedBlackTree) */
		u_int32_t level;              /**< A node's level (CHAnderssonTree) */
		u_int32_t priority;           /**< A node's priority value (CHTreap) */
	};
} CHBinaryTreeNode;

// These are used by subclasses; marked as HIDDEN to reduce external visibility.
HIDDEN extern size_t kCHBinaryTreeNodeSize;
HIDDEN extern size_t kCHPointerSize;
HIDDEN extern BOOL kCHGarbageCollectionDisabled;


/**
 An abstract CHSearchTree with many default method implementations. Methods for
 search, size, and enumeration are implemented in this class, as are methods for
 NSCoding, NSCopying, and NSFastEnumeration. (This works since all child classes
 use the CHBinaryTreeNode struct.) Any subclass must implement \link #addObject:
 -addObject:\endlink and \link #removeObject: -removeObject: \endlink such that
 they conform to the inner workings of that specific subclass.
 
 Rather than enforcing that this class be abstract, the contract is implied. If
 this class were actually instantiated, it would be of little use since there is
 attempts to insert or remove will result in runtime exceptions being raised.
 
 Much of the code and algorithms for trees was distilled from information in the
 <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_bst1.aspx">
 Binary Search Trees tutorial</a>, which is in the public domain, courtesy of
 <a href="http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have
 been changed to match the APIs of existing Cocoa collections provided by Apple.
 */
@interface CHAbstractBinarySearchTree : CHLockable <CHSearchTree>
{
	NSUInteger count; /**< The number of objects currently in the tree. */
	CHBinaryTreeNode *header; /**< Dummy header node; eliminates root checks. */
	CHBinaryTreeNode *sentinel; /**< Dummy leaf node; reduces checks for NULL. */
	unsigned long mutations; /**< Tracks mutations for NSFastEnumeration. */
}

// Declared to prevent compile warnings, but undocumented on purpose.
// Called to obtain detailed information about the structure of a tree object.
- (NSString*) debugDescription;

// Declared to prevent compile warnings, but undocumented on purpose.
// Each subclass may override this to specify how node entries should appear.
- (NSString*) debugDescriptionForNode:(CHBinaryTreeNode*)node;

/**
 Produces a graph description in the DOT language for the receiver tree. A dot
 graph can be rendered with GraphViz, OmniGraffle, dotty, or other tools. This
 method uses an adaptation of an iterative pre-order traversal to organize the
 diagram such that it renders in order like a binary search tree. Null sentinel
 nodes are represented by arrows which point to empty space.
 
 @return A graph description in the DOT language for the receiver tree.
 */
- (NSString*) dotGraphString;

/**
 Create a string DOT description for a node in the tree.
 Override in subclasses to display additional information for tree nodes.
 
 @param node The node for which to create a DOT language representation.
 @return A string representation of a node in the dot language.
 
 @see dotGraphString
 */
- (NSString*) dotStringForNode:(CHBinaryTreeNode*)node;

/**
 Returns a new instance that's a copy of the receiver. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
        instance. If zone is <code>NULL</code>, the new instance is allocated
        from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. Copies returned by this method are always mutable.
 
 Implementation of NSCopying protocol.
 */
- (id) copyWithZone:(NSZone*)zone;

/**
 Returns an object initialized from data in a given keyed unarchiver.
 
 @param decoder An unarchiver object.
 
 Implementation of NSCoding protocol.
 */
- (id) initWithCoder:(NSCoder*)decoder;

/**
 Encodes the receiver using a given keyed archiver.
 
 @param encoder An archiver object.
 
 Implementation of NSCoding protocol.
 */
- (void) encodeWithCoder:(NSCoder*)encoder;

/**
 A method called within <code>for-in</code> constructs via NSFastEnumeration.
 This method is intended to be called implicitly by code automatically generated
 by the compiler, and stores its enumeration information in the @a state struct.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf (up to a maximum of @a len)
         or 0 when iteration is done.
 
 Implementation of NSFastEnumeration protocol.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

@end

