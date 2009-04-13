/*
 CHDataStructures.framework -- CHAbstractBinarySearchTree_Internal.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHAbstractBinarySearchTree.h"

/**
 @file CHAbstractBinarySearchTree_Internal.h
 Contains \#defines for performing various traversals of binary search trees.
 
 This file is a private header that is only used by internal implementations, and is not included in the the compiled framework. The memory (re)allocated for stacks and queues is obtained using NSScannedOption because the nodes which may be placed in a stack or queue are known to the garbage collector. Since a stack or queue is only used in connection with a tree that is active (usually during insertion, removal or iteration) this should not leak. The macros and variables are internal and/or private, we assume that the stack or queue will not outlive the underlying nodes, but this behavior may not be threadsafe.
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
	if (stack != NULL && kCHGarbageCollectionDisabled) \
		free(stack); \
	stack = NULL; \
}

// Since this stack starts at 0 and goes to N-1, resizing is pretty simple.
#define CHBinaryTreeStack_PUSH(node) { \
	stack[stackSize++] = node; \
	if (stackSize >= stackCapacity) { \
		stackCapacity *= 2; \
		stack = NSReallocateCollectable(stack, kCHPointerSize*stackCapacity, NSScannedOption); \
	} \
}

#define CHBinaryTreeStack_TOP \
	((stackSize > 0) ? stack[stackSize-1] : NULL)

#define CHBinaryTreeStack_POP() \
	((stackSize > 0) ? stack[--stackSize] : NULL)


#pragma mark Queue macros

#define CHBinaryTreeQueue_INIT() { \
	queueCapacity = 16; \
	queue = NSAllocateCollectable(kCHPointerSize*queueCapacity, NSScannedOption); \
	queueHead = queueTail = 0; \
}

#define CHBinaryTreeQueue_FREE(queue) { \
	if (queue != NULL && kCHGarbageCollectionDisabled) \
		free(queue); \
	queue = NULL; \
}

// This queue is a circular array, so resizing it takes a little extra care.
#define CHBinaryTreeQueue_ENQUEUE(node) { \
	queue[queueTail++] = node; \
	queueTail %= queueCapacity; \
	if (queueHead == queueTail) { \
		queue = NSReallocateCollectable(queue, kCHPointerSize*queueCapacity*2, NSScannedOption); \
		/* Copy wrapped-around portion to end of queue and move tail index */ \
		memcpy(queue+queueCapacity, queue, kCHPointerSize*queueTail); \
		/* Zeroing out shifted memory can simplify debugging queue problems */ \
		/*memset(queue, 0, kCHPointerSize*queueTail);*/ \
		queueTail += queueCapacity; \
		queueCapacity *= 2; \
	} \
}

// Due to limitations of using macros, you must always call FRONT, then DEQUEUE.
#define CHBinaryTreeQueue_FRONT \
	((queueHead != queueTail) ? queue[queueHead] : NULL)

#define CHBinaryTreeQueue_DEQUEUE() \
	if (queueHead != queueTail) queueHead = (queueHead + 1) % queueCapacity
