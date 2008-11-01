/*
 CHAbstractTree.h
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
#import "CHTree.h"

/**
 An abstract CHTree implementation with some default method implementations. Methods
 for insertion, search, removal and order-specific enumeration must be re-implemented
 by child classes so as to conform to their inner workings. The methods defined in
 this abstract class rely on the implementations of such operations, so they cannot
 be implemented here.
 
 Rather than enforcing that this class be abstract, the contract is implied. In any
 case, if this class is actually instantiated, it will be of little use since all the
 methods for insertion, removal, and search are unsupported and raise exceptions.
 */
@interface CHAbstractTree : NSObject <CHTree>
{
	NSUInteger count; /**< A count of how many elements are currently in the tree. */
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}
@end


/**
 A dummy object that resides in the header node for a tree. Using a header node
 can simplify insertion logic by eliminating the need to check whether the root
 is null. In such cases, the tree root is generally stored as the right child of
 the header. In order to always proceed to the right child when traversing down
 the tree, instances of this class always return <code>NSOrderedAscending</code>
 when called as the receiver of the <code>-compare:</code> method.
 */
@interface CHAbstractTreeHeaderObject : NSObject

/**
 Returns the singleton instance of this class.
 
 @return The singleton instance of this class.
 */
+ (id) headerObject;
// NOTE: The singleton is declared as a static variable in CHAbstractTree.m.

/**
 Always indicate that the other object should appear to the right side. @b Note:
 To work correctly, this object @b must be the receiver of the -compare: message.
 
 @param otherObject The object to be compared to the receiver.
 @return <code>NSOrderedAscending</code>, indicating that traversal should go to
         the right child of the containing tree node.
 */
- (NSComparisonResult) compare:(id)otherObject;

@end


#pragma mark -

/**
 A node used by balanced binary trees for internal storage and representation.
 
 The nested anonymous union and structs are to provide flexibility for dealing
 with various types of trees and access. The first union—with pointers to the
 struct itself—provide 2 ways to access child nodes at the same memory address,
 based on what is most convenient and efficient. (e.g. 'left' is equivalent to
 'link[0]', and 'right' is equivalent to 'link[1]'). The second union—with the
 NSUInteger values—allows the same node to be used in several different balanced
 trees, while preserving useful semantic meaning appropriate for each algorithm.
 */
typedef struct CHBalancedTreeNode {
	id object;                           /**< The object stored in the node. */
	union {
		struct {
			struct CHBalancedTreeNode *left;   /**< Link to left child node. */
			struct CHBalancedTreeNode *right;  /**< Link to right child node. */
		};
		struct CHBalancedTreeNode *link[2]; /**< Links to left/right childen. */
	};
	union {
		NSUInteger color;         /**< The node's color (for red-black trees) */
		NSUInteger height;        /**< The node's height (for AVL trees) */
		NSUInteger level;         /**< The node's level (for Andersson trees) */
	};
} CHBalancedTreeNode;


#pragma mark Enumeration Struct & Macros

// A struct used by balanced binary tree enumerators to maintain traversal state
typedef struct CHTREE_NODE {
	struct CHBalancedTreeNode *node;
	struct CHTREE_NODE *next;
} CHTREE_NODE;

// Stack Operations

#define CHTREE_PUSH(o) \
        {tmp=malloc(kCHTREE_SIZE);tmp->node=o;tmp->next=stack;stack=tmp;}
#define CHTREE_POP() \
        {if(stack!=NULL){tmp=stack;stack=stack->next;free(tmp);}}
#define CHTREE_TOP \
        ((stack!=NULL)?stack->node:NULL)

// Queue Operations

#define CHTREE_ENQUEUE(o) \
        {tmp=malloc(kCHTREE_SIZE);tmp->node=o;tmp->next=NULL;\
        if(queue==NULL){queue=tmp;queueTail=tmp;}\
        queueTail->next=tmp;queueTail=queueTail->next;}
#define CHTREE_DEQUEUE() \
        {if(queue!=NULL){tmp=queue;queue=queue->next;free(tmp);}\
        if(queue==tmp)queue=NULL;if(queueTail==tmp)queueTail=NULL;}
#define CHTREE_FRONT \
        ((queue!=NULL)?queue->node:NULL)
