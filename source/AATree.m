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

//  AATree.m
//  DataStructuresFramework

#import "AATree.h"

static NSUInteger kAATreeNodeSize = sizeof(AATreeNode);

#pragma mark Enumeration Struct & Macros

/**
 A struct for use by AATreeEnumerator to maintain traversal state.
 */
typedef struct AATE_NODE {
	struct AATreeNode *node;
	struct AATE_NODE *next;
} AATE_NODE;

static NSUInteger kAATE_SIZE = sizeof(AATE_NODE);

#pragma mark - Stack Operations

#define AATE_PUSH(o) {tmp=malloc(kAATE_SIZE);tmp->node=o;tmp->next=stack;stack=tmp;}
#define AATE_POP()   {if(stack!=NULL){tmp=stack;stack=stack->next;free(tmp);}}
#define AATE_TOP     ((stack!=NULL)?stack->node:NULL)

#pragma mark - Queue Operations

#define AATE_ENQUEUE(o) {tmp=malloc(kAATE_SIZE);tmp->node=o;tmp->next=NULL;\
                         if(queue==NULL){queue=tmp;queueTail=tmp;}\
                         queueTail->next=tmp;queueTail=queueTail->next;}
#define AATE_DEQUEUE()  {if(queue!=NULL){tmp=queue;queue=queue->next;free(tmp);}\
                         if(queue==tmp)queue=NULL;if(queueTail==tmp)queueTail=NULL;}
#define AATE_FRONT      ((queue!=NULL)?queue->node:NULL)

#pragma mark -

/**
 An NSEnumerator for traversing an AATree in a specified order.
 
 This enumerator uses iterative tree traversal algorithms for two main reasons:
 <ol>
 <li>Recursive algorithms cannot easily be stopped in the middle of a traversal.
 <li>Iterative algorithms are faster since they reduce overhead of function calls.
 </ol>
 
 In addition, the stacks and queues used for storing traversal state are composed of
 C structs and <code>\#define</code> pseudo-functions to increase performance and
 reduce the required memory footprint.
 
 Enumerators encapsulate their own state, and more than one may be active at once.
 However, like an enumerator for a mutable data structure, any instances of this
 enumerator become invalid if the tree is modified.
 */
@interface AATreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder; /**< Order in which to traverse the tree. */
	@private
	AATreeNode *currentNode; /**< The next node that is to be returned. */
	id tempObject;         /**< Temporary variable, holds the object to be returned.*/
	AATE_NODE *stack;     /**< Pointer to the top of a stack for most traversals. */
	AATE_NODE *queue;     /**< Pointer to the head of a queue for level-order. */
	AATE_NODE *queueTail; /**< Pointer to the tail of a queue for level-order. */
	AATE_NODE *tmp;       /**< Temporary variable for stack and queue operations. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param root The root node of the (sub)tree whose elements are to be enumerated.
 @param order The traversal order to use for enumerating the given (sub)tree.
 @param mutations A pointer to the collection's count of mutations, for invalidation.
 */
- (id) initWithRoot:(AATreeNode*)root
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
 
 @return The next object from the collection being enumerated, or <code>nil</code>
 when all objects have been enumerated.
 */
- (id) nextObject;

@end

#pragma mark -

@implementation AATreeEnumerator

- (id) initWithRoot:(AATreeNode*)root
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order)) {
		[self release];
		return nil;
	}
	stack = NULL;
	traversalOrder = order;
	if (traversalOrder == CHTraverseLevelOrder) {
		AATE_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		AATE_PUSH(root);
	} else {
		currentNode = root;
	}
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		mutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [self nextObject]))
		[array addObject:object];
	return [array autorelease];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		mutatedCollectionException([self class], _cmd);
	switch (traversalOrder) {
		case CHTraversePreOrder:
			currentNode = AATE_TOP;
			AATE_POP();
			if (currentNode == NULL)
				return nil;
			if (currentNode->right != NULL) {
				AATE_PUSH(currentNode->right);
			}
			if (currentNode->left != NULL) {
				AATE_PUSH(currentNode->left);
			}
			return currentNode->object;
			
		case CHTraverseInOrder:
			if (stack == NULL && currentNode == NULL)
				return nil;
			while (currentNode != NULL) {
				AATE_PUSH(currentNode);
				currentNode = currentNode->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = AATE_TOP; // Save top node for return value
			AATE_POP();
			tempObject = currentNode->object;
			currentNode = currentNode->right;
			return tempObject;
			
		case CHTraverseReverseOrder:
			if (stack == NULL && currentNode == NULL)
				return nil;
			while (currentNode != NULL) {
				AATE_PUSH(currentNode);
				currentNode = currentNode->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = AATE_TOP; // Save top node for return value
			AATE_POP();
			tempObject = currentNode->object;
			currentNode = currentNode->left;
			return tempObject;
			
		case CHTraversePostOrder:
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (stack == NULL && currentNode == NULL)
				return nil;
			while (1) {
				while (currentNode != NULL) {
					AATE_PUSH(currentNode);
					currentNode = currentNode->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (AATE_TOP != NULL) {
					currentNode = AATE_TOP->right;
					AATE_PUSH(NULL);
					// TODO: explore how to not use null pad for leaf nodes
				}
				else {
					AATE_POP(); // ignore the null pad
					tempObject = AATE_TOP->object;
					AATE_POP();
					return tempObject;
				}				
			}
			
		case CHTraverseLevelOrder:
			currentNode = AATE_FRONT;
			if (currentNode == NULL)
				return nil;
			AATE_DEQUEUE();
			if (currentNode->left != NULL) {
				AATE_ENQUEUE(currentNode->left);
			}
			if (currentNode->right != NULL) {
				AATE_ENQUEUE(currentNode->right);
			}
			return currentNode->object;
			
		default:
			return nil;
	}
}

@end

#pragma mark -

@implementation AATree

#pragma mark - Private Functions

void _rotateWithLeftChild(AATreeNode *node) {
	AATreeNode *other = node->left;
	node->left = other->right;
	other->right = node;
	node = other;
}

void _rotateWithRightChild(AATreeNode *node) {
	AATreeNode *other = node->right;
	node->right = other->left;
	other->left = node;
	node = other;
}

/**
 Skew primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
void _skew(AATreeNode *node) {
	if (node->left->level == node->level) {
		_rotateWithLeftChild(node);
	}
}

/**
 Split primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
void _split(AATreeNode *node) {
	if (node->right->right->level == node->level) {
		_rotateWithRightChild(node);
		node->level++;
	}
}

#pragma mark - Public Methods

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	root = NULL;
	return self;
}

- (void) dealloc {
	[self removeAllObjects];
	[super dealloc];
}

- (void) addObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	unsupportedOperationException([self class], _cmd);
	
	AATreeNode *newNode = malloc(kAATreeNodeSize);
	newNode->object = [anObject retain];
	newNode->left = NULL;
	newNode->right = NULL;
	
	 // TODO: Handle adding node, plus skew/split as needed
}

- (id) findObject:(id)target {
	if (count == 0)
		return nil;
	unsupportedOperationException([self class], _cmd);
	return nil;
}

- (id) findMin {
	if (count == 0)
		return nil;
	unsupportedOperationException([self class], _cmd);
	return nil;
}

- (id) findMax {
	if (count == 0)
		return nil;
	unsupportedOperationException([self class], _cmd);
	return nil;
}

- (BOOL) containsObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	unsupportedOperationException([self class], _cmd);
	return NO;
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	unsupportedOperationException([self class], _cmd);
}

/**
 Frees all the nodes in the tree and releases the objects they point to. The pointer
 to the root node remains NULL until an object is added to the tree. Uses a linked
 list to store the objects waiting to be deleted; in a binary tree, no more than half
 of the nodes will be on the queue.
 */
- (void) removeAllObjects {
	if (count == 0)
		return;

	AATreeNode *currentNode;
	AATE_NODE *queue	 = NULL;
	AATE_NODE *queueTail = NULL;
	AATE_NODE *tmp;
	
	AATE_ENQUEUE(root);
	while (1) {
		currentNode = AATE_FRONT;
		if (currentNode == NULL)
			break;
		AATE_DEQUEUE();
		if (currentNode->left != NULL)
			AATE_ENQUEUE(currentNode->left);
		if (currentNode->right != NULL)
			AATE_ENQUEUE(currentNode->right);
		[currentNode->object release];
		free(currentNode);
	}
	root = NULL;
	count = 0;
	++mutations;
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	if (root == NULL)
		return nil;
	
	return [[[AATreeEnumerator alloc] initWithRoot:root
                                    traversalOrder:order
                                   mutationPointer:&mutations] autorelease];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(id*)stackbuf
                                    count:(NSUInteger)len
{
	AATreeNode *currentNode;
	AATE_NODE *stack, *tmp; 
	
	// For the first call, start at leftmost node, otherwise start at last saved node
	if (state->state == 0) {
		currentNode = root;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
		stack = NULL;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		currentNode = (AATreeNode*) state->state;
		stack = (AATE_NODE*) state->extra[0];
	}
	
	// Accumulate objects from the tree until we reach all nodes or the maximum limit
	NSUInteger batchCount = 0;
	while ( (currentNode != NULL || stack != NULL) && batchCount < len) {
		while (currentNode != NULL) {
			AATE_PUSH(currentNode);
			currentNode = currentNode->left;
			// TODO: How to not push/pop leaf nodes unnecessarily?
		}
		currentNode = AATE_TOP; // Save top node for return value
		AATE_POP();
		stackbuf[batchCount] = currentNode->object;
		currentNode = currentNode->right;
		batchCount++;
	}
	
	if (currentNode == NULL && stack == NULL)
		state->state = 1; // used as a termination flag
	else {
		state->state = (unsigned long) currentNode;
		state->extra[0] = (unsigned long) stack;
	}
	return batchCount;
}

@end
