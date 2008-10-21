//  CHUnbalancedTree.m
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

#import "CHUnbalancedTree.h"

static NSUInteger kUnbalancedTreeNodeSize = sizeof(CHUnbalancedTreeNode);

#pragma mark Enumeration Struct & Macros

// A struct for use by CHUnbalancedTreeEnumerator to maintain traversal state.
typedef struct CH_UTE_NODE {
	struct CHUnbalancedTreeNode *node;
	struct CH_UTE_NODE *next;
} CH_UTE_NODE;

static NSUInteger kUTE_SIZE = sizeof(CH_UTE_NODE);

#pragma mark - Stack Operations

#define UTE_PUSH(o) {tmp=malloc(kUTE_SIZE);tmp->node=o;tmp->next=stack;stack=tmp;}
#define UTE_POP()   {if(stack!=NULL){tmp=stack;stack=stack->next;free(tmp);}}
#define UTE_TOP     ((stack!=NULL)?stack->node:NULL)

#pragma mark - Queue Operations

#define UTE_ENQUEUE(o) {tmp=malloc(kUTE_SIZE);tmp->node=o;tmp->next=NULL;\
                        if(queue==NULL){queue=tmp;queueTail=tmp;}\
                        queueTail->next=tmp;queueTail=queueTail->next;}
#define UTE_DEQUEUE()  {if(queue!=NULL){tmp=queue;queue=queue->next;free(tmp);}\
                        if(queue==tmp)queue=NULL;if(queueTail==tmp)queueTail=NULL;}
#define UTE_FRONT      ((queue!=NULL)?queue->node:NULL)

#pragma mark -

/**
 An NSEnumerator for traversing an CHUnbalancedTree in a specified order.
 
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
@interface CHUnbalancedTreeEnumerator : NSEnumerator {
	CHTraversalOrder traversalOrder; /**< Order in which to traverse the tree. */
	@private
	CHUnbalancedTree *collection;
	CHUnbalancedTreeNode *currentNode; /**< The next node that is to be returned. */
	id tempObject;       /**< Temporary variable, holds the object to be returned.*/
	CH_UTE_NODE *stack;     /**< Pointer to the top of a stack for most traversals. */
	CH_UTE_NODE *queue;     /**< Pointer to the head of a queue for level-order. */
	CH_UTE_NODE *queueTail; /**< Pointer to the tail of a queue for level-order. */
	CH_UTE_NODE *tmp;       /**< Temporary variable for stack and queue operations. */
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
- (id) initWithTree:(CHUnbalancedTree*)tree
               root:(CHUnbalancedTreeNode*)root
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

@implementation CHUnbalancedTreeEnumerator

- (id) initWithTree:(CHUnbalancedTree*)tree
               root:(CHUnbalancedTreeNode*)root
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order))
		return nil;
	stack = NULL;
	traversalOrder = order;
	collection = (root != NULL) ? collection = [tree retain] : nil;
	if (traversalOrder == CHTraverseLevelOrder) {
		UTE_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		UTE_PUSH(root);
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
		UTE_POP();
	while (queue != NULL)
		UTE_DEQUEUE();
	[super dealloc];
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		mutatedCollectionException([self class], _cmd);
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
		mutatedCollectionException([self class], _cmd);
	switch (traversalOrder) {
		case CHTraversePreOrder:
			currentNode = UTE_TOP;
			UTE_POP();
			if (currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			if (currentNode->right != NULL)
				UTE_PUSH(currentNode->right);
			if (currentNode->left != NULL)
				UTE_PUSH(currentNode->left);
			return currentNode->object;
			
		case CHTraverseInOrder:
			if (stack == NULL && currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (currentNode != NULL) {
				UTE_PUSH(currentNode);
				currentNode = currentNode->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = UTE_TOP; // Save top node for return value
			UTE_POP();
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
				UTE_PUSH(currentNode);
				currentNode = currentNode->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = UTE_TOP; // Save top node for return value
			UTE_POP();
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
					UTE_PUSH(currentNode);
					currentNode = currentNode->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (UTE_TOP != NULL) {
					currentNode = UTE_TOP->right;
					UTE_PUSH(NULL);
					// TODO: explore how to not use null pad for leaf nodes
				}
				else {
					UTE_POP(); // ignore the null pad
					tempObject = UTE_TOP->object;
					UTE_POP();
					return tempObject;
				}				
			}
			
		case CHTraverseLevelOrder:
			currentNode = UTE_FRONT;
			if (currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			UTE_DEQUEUE();
			if (currentNode->left != NULL)
				UTE_ENQUEUE(currentNode->left);
			if (currentNode->right != NULL)
				UTE_ENQUEUE(currentNode->right);
			return currentNode->object;
			
		default:
			return nil;
	}
}

@end

#pragma mark -

#pragma mark C Functions for Optimized Operations

static struct CHUnbalancedTreeNode * _findMaxWithStarter(struct CHUnbalancedTreeNode *starter) {
	//see comment in findMinWithStarter for explanation
	struct CHUnbalancedTreeNode *bar, *foo = starter;
	while ((bar = foo->right) != nil)
		foo = bar;
	return foo;	
}

static struct CHUnbalancedTreeNode * _findMinWithStarter(struct CHUnbalancedTreeNode *starter) {
	struct CHUnbalancedTreeNode *bar, *foo = starter;
	
	//a subtle nil test here -- note the terminating semicolon
	//when foo->left points to nil, we return foo because
	//there is nothing more to the left.
	while ((bar = foo->left) != nil)
		foo = bar;
	return foo;
}

// TODO: C function to locate a node; use for contains/find/remove a single object.

static struct CHUnbalancedTreeNode * _removeNode(struct CHUnbalancedTreeNode *node,
											   struct CHUnbalancedTreeNode *treeRoot) {
	if (node == NULL)
		return NULL;
	
	struct CHUnbalancedTreeNode *oldRoot;
	
	if (node->left == NULL) {
		if (node->right == NULL) { // both children are NULL
			// Remove reference to this node from parent
			if (node->parent->left == node)
				node->parent->left = NULL;
			else
				node->parent->right = NULL;
			// Release resources associated with this node
			[node->object release];
			if (node != treeRoot)
				free(node);
			return NULL;
		}
		else { // only right exists, so replace current with right subtree
			oldRoot = node;
			node = node->right;
			node->parent = oldRoot->parent;
			
			//fix the parent's pointers.
			if (node->parent != NULL) {
				if (node->parent->left == oldRoot) 
					node->parent->left = node;
				else if (node->parent->right == oldRoot)
					node->parent->right = node; 
			}
			
			[oldRoot->object release];
			free(oldRoot);
			return node;
		}
	} else { //left was not nil
		if (node->right == NULL) {
			oldRoot = node;
			node = node->left;
			node->parent = oldRoot->parent;
			
			//fix the parent's pointers.
			if (node->parent != NULL)
			{
				if (node->parent->left == oldRoot) 
					node->parent->left = node;
				else if (node->parent->right == oldRoot)
					node->parent->right = node; 
			}
			
			[oldRoot->object release];
			free(oldRoot);
			return node;
		} else {
			//now of course this is the usual -- both L & R nodes exist
		
			//replace our node with the node at the leftmost of its right subtree.
			//1. release our present node's object
			//2. find the node we will destroy after plucking its object
			//3. set our present node's object pointer to the replacement object
			//4. fix the parent pointer of the to-be-freed node
			[node->object release];
			oldRoot = _findMinWithStarter(node->right);
			node->object = oldRoot->object;
			oldRoot->parent->left = NULL;
			free(oldRoot);
			return node;
		}
	}
}

#pragma mark -

@implementation CHUnbalancedTree

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
		nilArgumentException([self class], _cmd);
	
	[anObject retain];
	++mutations;
	
	if (root == NULL) {
		root = malloc(kUnbalancedTreeNodeSize);
		root->object = anObject;
		root->left   = NULL;
		root->right  = NULL;
		root->parent = NULL;
		count++;
		return;
	}
	
	// TODO: Simplify object insertion
	
	NSComparisonResult comparison;
	
	struct CHUnbalancedTreeNode *parentNode, *currentNode = root;
	while (currentNode != nil) {
		parentNode = currentNode;
		
		comparison = [anObject compare:currentNode->object];
		
		if (comparison == 0)
			break; // Artificially break the loop to replace the value
		else if (comparison < 0)
			currentNode = currentNode->left;
		else if (comparison > 0)
			currentNode = currentNode->right;
	}
	
	// this is why we used the special case.
	// we see what state got us to this
	// if it's equal, we just replace bar.
	
	// Remember, we REPLACE (i.e., release the old) elements
	if (comparison == NSOrderedSame) {
		[parentNode->object release];
		parentNode->object = anObject;
	}
	else {
		count++;
		CHUnbalancedTreeNode *newNode = malloc(kUnbalancedTreeNodeSize);
		newNode->object = anObject;
		newNode->left   = NULL;
		newNode->right  = NULL;
		newNode->parent = parentNode;
		
		if (comparison == NSOrderedAscending)
			parentNode->left = newNode;
		else if (comparison == NSOrderedDescending)
			parentNode->right = newNode;		
	}
}

- (BOOL) containsObject:(id)anObject {
	if (anObject == nil)
		return NO;
	
	struct CHUnbalancedTreeNode *currentNode = root;
	while (currentNode != NULL) {
		if ([anObject isEqual:currentNode->object])
			return YES;
		short comparison = [anObject compare:currentNode->object];
		if (comparison == NSOrderedAscending)
			currentNode = currentNode->left;
		else
			currentNode = currentNode->right;
	}
	return NO;
}

- (id) findMax {
	return (_findMaxWithStarter(root))->object;
}

- (id) findMin {
	return (_findMinWithStarter(root))->object;
}

- (id) findObject:(id)anObject {
	if (anObject == nil)
		return nil;
	
	struct CHUnbalancedTreeNode *currentNode = root;
	while (currentNode != NULL) {
		short comparison = [anObject compare:(currentNode->object)];
		if (comparison == NSOrderedAscending)
			currentNode = currentNode->left;
		else if (comparison == NSOrderedDescending)
			currentNode = currentNode->right;
		else if (comparison == NSOrderedSame) {
			return currentNode->object;
		}
	}
	return nil;	
}

/**
 Removal is guaranteed not to make the tree deeper/taller, since it uses the "min of
 the right subtree" algorithm if the node to be removed has children.
 */
- (void) removeObject:(id)anObject {
	if (anObject == nil)
		nilArgumentException([self class], _cmd);
	
	struct CHUnbalancedTreeNode *currentNode = root;
	while (currentNode != NULL) {
		short comparison = [anObject compare:currentNode->object];
		if (comparison == NSOrderedAscending)
			currentNode = currentNode->left;
		else if (comparison == NSOrderedDescending)
			currentNode = currentNode->right;
		else if (comparison == NSOrderedSame) {
			++mutations;
			_removeNode(currentNode, root);
			--count;
			return;
		}
	}
}

/**
 Frees all the nodes in the tree and releases the objects they point to. The pointer
 to the root node remains NULL until an object is added to the tree. Uses a linked
 list to store the objects waiting to be deleted; in a binary tree, no more than half
 of the nodes will be on the queue.
 */
- (void) removeAllObjects {
	if (root == NULL)
		return;
	
	CHUnbalancedTreeNode *currentNode;
	CH_UTE_NODE *queue	 = NULL;
	CH_UTE_NODE *queueTail = NULL;
	CH_UTE_NODE *tmp;
	
	UTE_ENQUEUE(root);
	while (1) {
		currentNode = UTE_FRONT;
		if (currentNode == NULL)
			break;
		UTE_DEQUEUE();
		if (currentNode->left != NULL)
			UTE_ENQUEUE(currentNode->left);
		if (currentNode->right != NULL)
			UTE_ENQUEUE(currentNode->right);
		[currentNode->object release];
		free(currentNode);
	}
	root = NULL;
	count = 0;
	++mutations;
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHUnbalancedTreeEnumerator alloc] initWithTree:self
	                                                    root:root
	                                          traversalOrder:order
	                                         mutationPointer:&mutations] autorelease];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHUnbalancedTreeNode *currentNode;
	CH_UTE_NODE *stack, *tmp; 
	
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
		currentNode = (CHUnbalancedTreeNode*) state->state;
		stack = (CH_UTE_NODE*) state->extra[0];
	}

	// Accumulate objects from the tree until we reach all nodes or the maximum limit
	NSUInteger batchCount = 0;
	while ( (currentNode != NULL || stack != NULL) && batchCount < len) {
		while (currentNode != NULL) {
			UTE_PUSH(currentNode);
			currentNode = currentNode->left;
			// TODO: How to not push/pop leaf nodes unnecessarily?
		}
		currentNode = UTE_TOP; // Save top node for return value
		UTE_POP();
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
