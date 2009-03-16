/*
 CHAbstractBinarySearchTree_Internal.h
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

#import "CHAbstractBinarySearchTree.h"

/**
 @file CHAbstractBinarySearchTree_Internal.h
 Contains \#defines for performing various traversals of binary search trees.
 
 This file is a private header that is only used by internal implementations,
 and is not included in the the compiled framework. The memory (re)allocated for
 stacks and queues is obtained using NSScannedOption because the nodes which may
 be placed in a stack or queue are known to the garbage collector. Since a stack
 or queue is only used in connection with a tree that is active (usually during
 insertion, removal or iteration) this should not leak. The macros and variables
 are internal and/or private, we assume that the stack or queue will not outlive
 the underlying nodes, but this behavior may not be threadsafe.
 */

#pragma mark Stack macros

#define CHBinaryTreeStack_DECLARE() \
	CHBinaryTreeNode** stack; \
	NSUInteger stackCapacity, stackSize

#define CHBinaryTreeStack_INIT() { \
	stackCapacity = 16; \
	stack = NSAllocateCollectable(kCHBinaryTreeNodeSize*stackCapacity, NSScannedOption); \
	stackSize = 0; \
}
#define CHBinaryTreeStack_FREE(stack) { \
	if (stack != NULL && CHGarbageCollectionDisabled) \
		free(stack); \
	stack = NULL; \
}
// Since this stack starts at 0 and goes to N-1, resizing is pretty simple.
#define CHBinaryTreeStack_PUSH(node) { \
	stack[stackSize++] = node; \
	if (stackSize >= stackCapacity) { \
		stackCapacity *= 2; \
		stack = NSReallocateCollectable(stack, kPointerSize*stackCapacity, NSScannedOption); \
	} \
}
#define CHBinaryTreeStack_TOP \
	((stackSize) ? stack[stackSize-1] : NULL)
#define CHBinaryTreeStack_POP() \
	((stackSize) ? stack[--stackSize] : NULL)


#pragma mark Queue macros

#define CHBinaryTreeQueue_INIT() { \
	queueCapacity = 16; \
	queue = NSAllocateCollectable(kPointerSize*queueCapacity, NSScannedOption); \
	queueHead = queueTail = 0; \
}
#define CHBinaryTreeQueue_FREE(queue) { \
	if (queue != NULL && CHGarbageCollectionDisabled) \
		free(queue); \
	queue = NULL; \
}
// This queue is a circular array, so resizing it takes a little extra care.
#define CHBinaryTreeQueue_ENQUEUE(node) { \
	queue[queueTail++] = node; \
	queueTail %= queueCapacity; \
	if (queueHead == queueTail) { \
		queue = NSReallocateCollectable(queue, kPointerSize*queueCapacity*2, NSScannedOption); \
		/* Copy wrapped-around portion to end of queue and move tail index */ \
		memcpy(queue+queueCapacity, queue, kPointerSize*queueTail); \
		/* Zeroing out shifted memory can simplify debugging queue problems */ \
		memset(queue, 0, kPointerSize*queueTail); \
		queueTail += queueCapacity; \
		queueCapacity *= 2; \
	} \
}
// Due to limitations of using macros, you must always call FRONT, then DEQUEUE.
#define CHBinaryTreeQueue_FRONT \
	((queueHead != queueTail) ? queue[queueHead] : NULL)
#define CHBinaryTreeQueue_DEQUEUE() \
	if (queueHead != queueTail) queueHead = (queueHead + 1) % queueCapacity
