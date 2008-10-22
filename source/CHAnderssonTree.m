//  CHAnderssonTree.m
//  CHDataStructures.framework

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

#import "CHAnderssonTree.h"

static NSUInteger kCHAnderssonTreeNodeSize = sizeof(CHAnderssonTreeNode);

#pragma mark Enumeration Struct & Macros

// A struct for use by CHAnderssonTreeEnumerator to maintain traversal state.
typedef struct CH_ATE_NODE {
	struct CHAnderssonTreeNode *node;
	struct CH_ATE_NODE *next;
} CH_ATE_NODE;

static NSUInteger kATE_SIZE = sizeof(CH_ATE_NODE);

#pragma mark - Stack Operations

#define ATE_PUSH(o) {tmp=malloc(kATE_SIZE);tmp->node=o;tmp->next=stack;stack=tmp;}
#define ATE_POP()   {if(stack!=NULL){tmp=stack;stack=stack->next;free(tmp);}}
#define ATE_TOP     ((stack!=NULL)?stack->node:NULL)

#pragma mark - Queue Operations

#define ATE_ENQUEUE(o) {tmp=malloc(kATE_SIZE);tmp->node=o;tmp->next=NULL;\
                         if(queue==NULL){queue=tmp;queueTail=tmp;}\
                         queueTail->next=tmp;queueTail=queueTail->next;}
#define ATE_DEQUEUE()  {if(queue!=NULL){tmp=queue;queue=queue->next;free(tmp);}\
                         if(queue==tmp)queue=NULL;if(queueTail==tmp)queueTail=NULL;}
#define ATE_FRONT      ((queue!=NULL)?queue->node:NULL)

#pragma mark -

/**
 An NSEnumerator for traversing an CHAnderssonTree in a specified order.
 
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
@interface CHAnderssonTreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder; /**< Order in which to traverse the tree. */
	@private
	CHAnderssonTree *collection;
	CHAnderssonTreeNode *currentNode; /**< The next node that is to be returned. */
	id tempObject;         /**< Temporary variable, holds the object to be returned.*/
	CH_ATE_NODE *stack;     /**< Pointer to the top of a stack for most traversals. */
	CH_ATE_NODE *queue;     /**< Pointer to the head of a queue for level-order. */
	CH_ATE_NODE *queueTail; /**< Pointer to the tail of a queue for level-order. */
	CH_ATE_NODE *tmp;       /**< Temporary variable for stack and queue operations. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param tree The tree collection that is being enumerated. This collection is to be
             retained while the enumerator has not exhausted all its objects.
 @param root The root node of the (sub)tree whose elements are to be enumerated.
 @param order The traversal order to use for enumerating the given (sub)tree.
 @param mutations A pointer to the collection's count of mutations, for invalidation.
 */
- (id) initWithTree:(CHAnderssonTree*)tree
               root:(CHAnderssonTreeNode*)root
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

@implementation CHAnderssonTreeEnumerator

- (id) initWithTree:(CHAnderssonTree*)tree
               root:(CHAnderssonTreeNode*)root
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order))
		return nil;
	stack = NULL;
	traversalOrder = order;
	collection = (root != NULL) ? collection = [tree retain] : nil;
	if (traversalOrder == CHTraverseLevelOrder) {
		ATE_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		ATE_PUSH(root);
	} else {
		currentNode = root;
	}
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
	while (stack != NULL)
		ATE_POP();
	while (queue != NULL)
		ATE_DEQUEUE();
	[super dealloc];
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [self nextObject]))
		[array addObject:object];
	[collection release];
	collection = nil;
	return [array autorelease];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	switch (traversalOrder) {
		case CHTraversePreOrder:
			currentNode = ATE_TOP;
			ATE_POP();
			if (currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			if (currentNode->right != NULL)
				ATE_PUSH(currentNode->right);
			if (currentNode->left != NULL)
				ATE_PUSH(currentNode->left);
			return currentNode->object;
			
		case CHTraverseInOrder:
			if (stack == NULL && currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (currentNode != NULL) {
				ATE_PUSH(currentNode);
				currentNode = currentNode->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = ATE_TOP; // Save top node for return value
			ATE_POP();
			tempObject = currentNode->object;
			currentNode = currentNode->right;
			return tempObject;
			
		case CHTraverseReverseOrder:
			if (stack == NULL && currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (currentNode != NULL) {
				ATE_PUSH(currentNode);
				currentNode = currentNode->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = ATE_TOP; // Save top node for return value
			ATE_POP();
			tempObject = currentNode->object;
			currentNode = currentNode->left;
			return tempObject;
			
		case CHTraversePostOrder:
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (stack == NULL && currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (1) {
				while (currentNode != NULL) {
					ATE_PUSH(currentNode);
					currentNode = currentNode->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (ATE_TOP != NULL) {
					currentNode = ATE_TOP->right;
					ATE_PUSH(NULL);
					// TODO: explore how to not use null pad for leaf nodes
				}
				else {
					ATE_POP(); // ignore the null pad
					tempObject = ATE_TOP->object;
					ATE_POP();
					return tempObject;
				}				
			}
			
		case CHTraverseLevelOrder:
			currentNode = ATE_FRONT;
			if (currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			ATE_DEQUEUE();
			if (currentNode->left != NULL)
				ATE_ENQUEUE(currentNode->left);
			if (currentNode->right != NULL)
				ATE_ENQUEUE(currentNode->right);
			return currentNode->object;
			
		default:
			return nil;
	}
}

@end

#pragma mark -

@implementation CHAnderssonTree

#pragma mark - Private Functions

/**
 Skew primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
CHAnderssonTreeNode* skew(CHAnderssonTreeNode *node) {
	if (node->left != NULL && node->left->level == node->level) {
		CHAnderssonTreeNode *other = node->left;
		node->left = other->right;
		other->right = node;
		return other;
	}
	return node;
}

/**
 Split primitive for AA-trees.
 @param node The node that roots the sub-tree.
 */
CHAnderssonTreeNode* split(CHAnderssonTreeNode *node) {
	if (node->right != NULL && node->right->right != NULL && node->right->right->level == node->level)
	{
		CHAnderssonTreeNode *other = node->right;
		node->right = other->left;
		other->left = node;
		other->level++;
		return other;
	}
	return node;
}

#pragma mark - Public Methods

- (id) init {
	if ([super init] == nil)
		return nil;
	root = NULL;
	return self;
}

- (void) dealloc {
	[self removeAllObjects];
	[super dealloc];
}

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHAnderssonTreeNode *current = root;
	CHAnderssonTreeNode *previous = NULL;
	CH_ATE_NODE *stack = NULL;
	CH_ATE_NODE *tmp;
	NSComparisonResult comparison;
	
	while (current != NULL) {
		ATE_PUSH(current);
		comparison = [(current->object) compare:anObject];
		if (comparison == NSOrderedAscending)
			current = current->right;
		else if (comparison == NSOrderedDescending)
			current = current->left;
		else if (comparison == 0) {
			// Replace the existing object with the new object.
			[anObject retain];
			[current->object release];
			current->object = anObject;
			return; // no need to 
		}
	}
	
	if (current == NULL) {
		CHAnderssonTreeNode *newNode = malloc(kCHAnderssonTreeNodeSize);
		++count;
		++mutations;
		newNode->object = [anObject retain];
		newNode->left = NULL;
		newNode->right = NULL;
		newNode->level = 1;
		if (root == NULL) {
			root = newNode;
			return;
		}
		current = ATE_TOP;
		if (comparison == NSOrderedAscending)
			current->right = newNode;
		else if (comparison == NSOrderedDescending)
			current->left = newNode;
	}	
	
	while (stack != NULL) {
		current = ATE_TOP;
		ATE_POP();
		if (previous != NULL) {
			if ([(current->object) compare:(previous->object)] < 0)
				current->right = previous;
			else
				current->left = previous;
		}
		current = skew(current);
		current = split(current);
		previous = current;
	}
	root = current;
}

- (id) findObject:(id)target {
	CHAnderssonTreeNode *currentNode = root;
	NSComparisonResult comparison;	
	while (currentNode != NULL) {
		comparison = [(currentNode->object) compare:target];
		if (comparison == NSOrderedAscending)
			currentNode = currentNode->right;
		else if (comparison == NSOrderedDescending)
			currentNode = currentNode->left;
		else if (comparison == NSOrderedSame) {
			return currentNode->object;
		}
	}
	return nil; // object not found
}

- (id) findMin {
	CHAnderssonTreeNode *currentNode = root;
	while (currentNode != NULL) {
		if (currentNode->left != NULL)
			currentNode = currentNode->left;
		else
			return currentNode->object;
	}
	return nil; // empty tree
}

- (id) findMax {
	CHAnderssonTreeNode *currentNode = root;
	while (currentNode != NULL) {
		if(currentNode->right != NULL)
			currentNode = currentNode->left;
		else
			return currentNode->object;
	}	
	return nil; // empty tree
}

- (BOOL) containsObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHAnderssonTreeNode *currentNode = root;
	NSComparisonResult comparison;
	while (currentNode != NULL) {
		comparison = [(currentNode->object) compare:anObject];
		if (comparison == NSOrderedAscending)
			currentNode = currentNode->right;
		else if (comparison == NSOrderedDescending)
			currentNode = currentNode->left;
		else if (comparison == NSOrderedSame)
			return YES;
	}
	return NO;
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHAnderssonTreeNode *current = root;
	CHAnderssonTreeNode *nodeToDelete = NULL;
	CH_ATE_NODE *stack = NULL;
	CH_ATE_NODE *tmp;
	NSComparisonResult comparison;
	
	while (current != NULL) {
		ATE_PUSH(current);
		comparison = [(current->object) compare:anObject];
		if (comparison == NSOrderedDescending)
			current = current->left;
		else  {
			if (comparison == NSOrderedSame)
				nodeToDelete = current;
			current = current->right;
		}
	}
	if (nodeToDelete == NULL) {  // the specified object was not found
		while (stack != NULL)
			ATE_POP(); // deallocate the wrappers for all nodes pushed to the stack
		return;
	}

	current = ATE_TOP;
	ATE_POP();
	nodeToDelete->object = current->object;
	nodeToDelete->level = current->level;
	// TODO: Is this where the malloced struct for the node needs to be freed?
	current = current->right;
			
	CHAnderssonTreeNode *previous = NULL;
	while (stack != NULL)  {
		current = ATE_TOP;
		ATE_POP();
		if (previous != NULL) {
			if ([current->object compare:previous->object] == NSOrderedAscending)
				current->right = previous;
			else
				current->left = previous;
		}
		if ((current->left != NULL && current->left->level < current->level - 1) || 
			(current->right != NULL && current->right->level < current->level - 1)) 
		{
			--(current->level);
			if (current->right->level > current->level)
				current->right->level = current->level;
			current               = skew(current);
			current->right        = skew(current->right);
			current->right->right = skew(current->right->right);
			current               = split(current);
			current->right        = split(current->right);
		}
		previous = current;
	}
	root = current;
	--count;
	++mutations;
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

	CHAnderssonTreeNode *currentNode;
	CH_ATE_NODE *queue = NULL;
	CH_ATE_NODE *queueTail = NULL;
	CH_ATE_NODE *tmp;
	
	ATE_ENQUEUE(root);
	while (1) {
		currentNode = ATE_FRONT;
		if (currentNode == NULL)
			break;
		ATE_DEQUEUE();
		if (currentNode->left != NULL)
			ATE_ENQUEUE(currentNode->left);
		if (currentNode->right != NULL)
			ATE_ENQUEUE(currentNode->right);
		[currentNode->object release];
		free(currentNode);
	}
	root = NULL;
	count = 0;
	++mutations;
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHAnderssonTreeEnumerator alloc] initWithTree:self
                                                       root:root
                                             traversalOrder:order
                                            mutationPointer:&mutations] autorelease];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHAnderssonTreeNode *currentNode;
	CH_ATE_NODE *stack, *tmp; 
	
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
		currentNode = (CHAnderssonTreeNode*) state->state;
		stack = (CH_ATE_NODE*) state->extra[0];
	}
	
	// Accumulate objects from the tree until we reach all nodes or the maximum limit
	NSUInteger batchCount = 0;
	while ( (currentNode != NULL || stack != NULL) && batchCount < len) {
		while (currentNode != NULL) {
			ATE_PUSH(currentNode);
			currentNode = currentNode->left;
			// TODO: How to not push/pop leaf nodes unnecessarily?
		}
		currentNode = ATE_TOP; // Save top node for return value
		ATE_POP();
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
