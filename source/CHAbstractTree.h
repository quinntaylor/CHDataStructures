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

extern NSUInteger kCHTreeNodeSize, kCHTreeListNodeSize;

/**
 A node used by binary search trees for internal storage and representation.
 
 The nested anonymous union and structs are to provide flexibility for dealing
 with various types of trees and access. The first union—with pointers to the
 struct itself—provide 2 ways to access child nodes at the same memory address,
 based on what is most convenient and efficient. (e.g. 'left' is equivalent to
 'link[0]', and 'right' is equivalent to 'link[1]'). The second union—with the
 NSUInteger values—allows the same node to be used in several different balanced
 trees, while preserving useful semantic meaning appropriate for each algorithm.
 */
typedef struct CHTreeNode {
	id object;                           /**< The object stored in the node. */
	union {
		struct {
			struct CHTreeNode *left;   /**< Link to left child node. */
			struct CHTreeNode *right;  /**< Link to right child node. */
		};
		struct CHTreeNode *link[2]; /**< Links to left/right childen. */
	};
	union {
		NSUInteger color;         /**< The node's color (for red-black trees) */
		NSUInteger height;        /**< The node's height (for AVL trees) */
		NSUInteger level;         /**< The node's level (for Andersson trees) */
	};
} CHTreeNode;

#pragma mark -
#pragma mark Enumeration Struct & Macros

// A struct used to maintain state when traversing tree nodes
typedef struct CHTreeListNode {
	struct CHTreeNode *node;
	struct CHTreeListNode *next;
} CHTreeListNode;

#pragma mark - Stack Operations

#define CHTreeList_PUSH(o) \
        {tmp=malloc(kCHTreeListNodeSize);tmp->node=o;tmp->next=stack;stack=tmp;}
#define CHTreeList_POP() \
        {if(stack!=NULL){tmp=stack;stack=stack->next;free(tmp);}}
#define CHTreeList_TOP \
        ((stack!=NULL)?stack->node:NULL)

#pragma mark - Queue Operations

#define CHTreeList_ENQUEUE(o) \
        {tmp=malloc(kCHTreeListNodeSize);tmp->node=o;tmp->next=NULL;\
        if(queue==NULL){queue=tmp;queueTail=tmp;}\
        queueTail->next=tmp;queueTail=queueTail->next;}
#define CHTreeList_DEQUEUE() \
        {if(queue!=NULL){tmp=queue;queue=queue->next;free(tmp);}\
        if(queue==tmp)queue=NULL;if(queueTail==tmp)queueTail=NULL;}
#define CHTreeList_FRONT \
        ((queue!=NULL)?queue->node:NULL)

#pragma mark -

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
	CHTreeNode *header; // Links to the root -- eliminates special cases
	CHTreeNode *sentinel; // Represents a NULL leaf node; reduces checks
	NSUInteger count; /**< A count of how many elements are currently in the tree. */
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}

@end


/**
 An NSEnumerator for traversing a CHAbstractTree subclass in a specified order.
 
 This enumerator uses iterative tree traversal algorithms for two main reasons:
 <ol>
 <li>Recursive algorithms cannot easily be stopped in the middle of a traversal.
 <li>Iterative algorithms are faster since they reduce overhead of function calls.
 </ol>
 
 Also, the stacks and queues used for storing traversal state are composed of C
 structs and <code>\#define</code> pseudo-functions to increase performance and
 reduce the required memory footprint by dynamically allocating as needed.
 
 Enumerators encapsulate their own state, and more than one may be active at once.
 However, like an enumerator for a mutable data structure, any instances of this
 enumerator become invalid if the tree is modified.
 */
@interface CHTreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder; /**< Order in which to traverse the tree. */
	id<CHTree> collection;
	CHTreeNode *current;
	CHTreeNode *sentinelNode;
	id tempObject;         /**< Temporary variable, holds the object to be returned.*/
	CHTreeListNode *stack;     /**< Pointer to the top of a stack for most traversals. */
	CHTreeListNode *queue;     /**< Pointer to the head of a queue for level-order. */
	CHTreeListNode *queueTail; /**< Pointer to the tail of a queue for level-order. */
	CHTreeListNode *tmp;       /**< Temporary variable for stack and queue operations. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;	
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param tree The tree collection that is being enumerated. This collection is to
        be retained while the enumerator has not exhausted all its objects.
 @param root The root node of the @a tree whose elements are to be enumerated.
 @param sentinel The sentinel value used at the leaves of the specified @a tree.
 @param order The traversal order to use for enumerating the given @a tree.
 @param mutations A pointer to the collection's mutation count for invalidation.
 */
- (id) initWithTree:(id<CHTree>)tree
               root:(CHTreeNode*)root
           sentinel:(CHTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray*) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or
         <code>nil</code> when all objects have been enumerated.
 */
- (id) nextObject;

@end


/**
 A dummy object that resides in the header node for a tree. Using a header node
 can simplify insertion logic by eliminating the need to check whether the root
 is null. In such cases, the tree root is generally stored as the right child of
 the header. In order to always proceed to the right child when traversing down
 the tree, instances of this class always return <code>NSOrderedAscending</code>
 when called as the receiver of the <code>-compare:</code> method.
 */
@interface CHTreeHeaderObject : NSObject

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
