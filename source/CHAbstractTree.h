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
 A node used by binary search trees for internal storage and representation.
 
 The nested anonymous union and structs are to provide flexibility for dealing
 with various types of trees and access. The first union—with pointers to the
 struct itself—provide 2 ways to access child nodes at the same memory address,
 based on what is most convenient and efficient. (e.g. 'left' is equivalent to
 'link[0]', and 'right' is equivalent to 'link[1]'). The second union (which has
 integer fields) allows the same node to be used in several different balanced
 trees, while preserving useful semantic meaning appropriate for each algorithm.
 */
typedef struct CHTreeNode {
	id object;                        /**< The object stored in the node. */
	union {
		struct {
			struct CHTreeNode *left;  /**< Link to left child node. */
			struct CHTreeNode *right; /**< Link to right child node. */
		};
		struct CHTreeNode *link[2];   /**< Links to left and right childen. */
	};
	union {
		NSUInteger color;             /**< A node's color (CHRedBlackTree) */
		NSUInteger level;             /**< A node's level (CHAnderssonTree) */
		NSInteger balance;            /**< A node's balance factor (CHAVLTree) */
		NSInteger priority;           /**< A node's priority value (CHTreap) */
	};
} CHTreeNode;

extern NSUInteger kCHTreeNodeSize;
extern NSUInteger kPointerSize;

#pragma mark Stack Macros

#define CHTreeStack_INIT(stack) { \
	stackSize = 16; \
	stack = malloc(stackSize * kCHTreeNodeSize); \
	elementsInStack = 0; \
}
// Since this stack starts at 0 and goes to N-1, resizing is pretty simple.
#define CHTreeStack_PUSH(obj) { \
	stack[elementsInStack++] = obj; \
	if (elementsInStack >= stackSize) \
		stack = realloc(stack, (stackSize*=2)); \
}
#define CHTreeStack_POP ((elementsInStack) ? stack[--elementsInStack] : NULL)
#define CHTreeStack_TOP ((elementsInStack) ? stack[elementsInStack-1] : NULL)

#pragma mark Queue Macros

#define CHTreeQueue_INIT(queue) { \
	queueSize = 32; \
	queue = malloc(queueSize * kCHTreeNodeSize); \
	queueHead = queueTail = 0; \
}
// This queue is a circular array, so resizing it takes a little extra care.
// (memcpy() take the destination address, source address, and number of bytes.)
#define CHTreeQueue_ENQUEUE(obj) { \
	queue[queueTail++] = obj; \
	queueTail %= queueSize; \
	if (queueHead == queueTail) { \
		queue = realloc(queue, queueSize*2); \
		memcpy(queue+queueSize, queue, queueTail * kPointerSize); \
		queueTail += queueSize; \
		queueSize *= 2; \
	} \
}
#define CHTreeQueue_DEQUEUE \
	if (queueHead != queueTail) queueHead = (queueHead + 1) % queueSize
#define CHTreeQueue_FRONT \
	((queueHead == queueTail) ? NULL : queue[queueHead])

#pragma mark -

/**
 An abstract CHTree implementation with some default method implementations. The
 methods for search, size, and enumeration are implemented in this class, as are
 implementations of NSCoding, NSCopying, and NSFastEnumeration. This works since
 each child class uses the CHTreeNode struct. Each child class must implement
 \link #addObject: -addObject:\endlink and \link #removeObject: -removeObject:
 \endlink so as to conform to their inner workings.
 
 Rather than enforcing that this class be abstract, the contract is implied. If
 this class were actually instantiated, it would be of little use since there is
 attempts to insert or remove will result in runtime exceptions being raised.
 
 Much of the code and algorithms for trees was distilled from information in the
 <a href="http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_bst1.aspx">
 Binary Search Trees tutorial</a>, which is in the public domain, courtesy of
 <a href="http://eternallyconfuzzled.com/">Julienne Walker</a>. Method names have
 been changed to match the APIs of existing Cocoa collections provided by Apple.
 */
@interface CHAbstractTree : NSObject <CHTree>
{
	CHTreeNode *header;      /**< Dummy header that eliminates special cases. */
	CHTreeNode *sentinel;    /**< Represents a NULL leaf node; reduces checks. */
	NSUInteger count;        /**< The number of elements currently in the tree. */
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}

// This is declared to prevent compile warnings, but is undocumented in purpose.
- (NSString*) debugDescription;

#pragma mark Adopted Protocols

/**
 Returns a new instance that's a copy of the receiver. Invoked automatically by
 the default <code>-copy</code> method inherited from NSObject.
 
 @param zone Identifies an area of memory from which to allocate the new
        instance. If zone is <code>NULL</code>, the new instance is allocated
        from the default zone. (<code>-copy</code> invokes with a NULL param.)
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. Copies returned by this method are always mutable.
 */
- (id) copyWithZone:(NSZone *)zone;

/**
 Returns an object initialized from data in a given keyed unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder;

/**
 Encodes the receiver using a given keyed archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder;

/**
 A method for NSFastEnumeration, called by <code><b>for</b> (type variable
 <b>in</b> collection)</code> constructs.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

@end

#pragma mark -

/**
 An NSEnumerator for traversing a CHAbstractTree subclass in a specified order.
 
 This enumerator uses iterative tree traversal algorithms for two main reasons:
 <ol>
 <li>Recursive algorithms cannot easily be stopped in the middle of a traversal.
 <li>Iterative algorithms are faster since they reduce overhead of function calls.
 </ol>
 
 The stacks and queues used for storing traversal state use malloced C structs
 and <code>\#define</code> pseudo-functions to increase performance and reduce
 the required memory footprint by dynamically allocating as needed.
 
 Enumerators encapsulate their own state, and more than one may be active at once.
 However, like an enumerator for a mutable data structure, any instances of this
 enumerator become invalid if the tree is modified.
 */
@interface CHTreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder; /**< Order in which to traverse the tree. */
	id<CHTree> collection; /**< The source of enumerated objects. */
	CHTreeNode *current; /**< The next node to be enumerated. */
	CHTreeNode *sentinelNode;  /**< Sentinel used in the tree being traversed. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */

	CHTreeNode **stack, **queue;
	NSUInteger stackSize, elementsInStack;
	NSUInteger queueSize, queueHead, queueTail;
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

#pragma mark -

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
