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
//
//  UnbalancedTree.m
//  DataStructuresFramework

#import "UnbalancedTree.h"

#pragma mark C Functions for Optimized Operations

//C functions for speed
static struct BinaryNode * _findMaxWithStarter(struct BinaryNode *starter) {
    //see comment in findMinWithStarter for explanation
    struct BinaryNode *bar, *foo = starter;
    while ( (bar = foo->right) != nil )
		foo = bar;
    return foo;    
}

static struct BinaryNode * _findMinWithStarter(struct BinaryNode *starter) {
    struct BinaryNode *bar, *foo = starter;
    
    //a subtle nil test here -- note the terminating semicolon
    //when foo->left points to nil, we return foo because
    //there is nothing more to the left.
    while ( (bar = foo->left) != nil )
		foo = bar;
    return foo;
}

static struct BinaryNode * _removeNode(struct BinaryNode *node, struct BinaryNode *treeRoot)
{
    struct BinaryNode *oldRoot;
    
    if (node == NULL)
		return NULL;
    
    if (node->left == NULL)
    {
        if (node->right == NULL) // both children are NULL
        {
            [node->object release];
            if (node != treeRoot)
				free(node);
            return NULL;
        }
        else // only right exists, so replace current with right subtree
        {
            oldRoot = node;
            node = node->right;
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
        }
    }
    else //left was not nil
    {
        if (node->right == NULL)
        {
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
        }
        else //now of course this is the usual -- both l&r nodes exist
        {
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

@implementation UnbalancedTreeEnumerator

- (id)initWithRoot:(struct BinaryNode *)root traversalOrder:(CHTraversalOrder)order;
{
	if (![super init] || !isValidTraversalOrder(order)) {
		[self release];
		return nil;
	}
    currentNode = _findMinWithStarter(root);
	traversalOrder = order;
    beenLeft = YES;
    beenRight = NO;
    hasStarted = NO;
    return self;
}

- (NSArray *)allObjects
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    id object;
    
    while ((object = [self nextObject]))
        [array addObject:object];
    
    return [array autorelease];
}

// Currently assumes in-order traversal
// TODO: Fix logic to consider traversalOrder for unbalanced trees
- (id)nextObject
{
    if (currentNode == nil)
        return nil;
    
    //special case of the very first time.
    if (hasStarted == NO)
    {
        hasStarted = YES;
        
        if (currentNode->parent == nil) //root, special case
        {
            id tmp = currentNode->object;
            currentNode = currentNode->right;
            return tmp;
        }
        else
        {
            return currentNode->object;
        }
    }
    else if (beenLeft)
    {
        if (beenRight)
        {
            if (currentNode->parent == nil) //root - special case
            {
                beenLeft = NO;
                beenRight = NO;
                currentNode = currentNode->right;
                return currentNode->parent->object;
            }
            else if (currentNode->parent->left == currentNode) 
            {
                beenRight = NO;
                currentNode = currentNode->parent;
                return currentNode->object;
            }
            else 
            {	
                while (currentNode->parent->right == currentNode)
                    currentNode = currentNode->parent;
                beenLeft = YES;
                beenRight = NO;
                currentNode = currentNode->parent;
                return currentNode->object;
            }
        }
        else //else we haven't been right but we've been left
        {
            beenLeft = NO;
            beenRight = NO;
            currentNode = currentNode->right;
            return currentNode->parent->object;
        }
    }
    else //haven't been left
    {
        if (currentNode->left != nil)
        {
            currentNode = _findMinWithStarter(currentNode);
            id tmp = currentNode->object;
            currentNode = currentNode->parent;
            beenLeft = YES;
            beenRight = NO;
            return tmp;
        }
        else
        {
            beenLeft = NO;
            beenRight = NO;
            currentNode = currentNode->right;
            if (currentNode == nil) return nil;
            return currentNode->parent->object;
        }
    }
}

@end

#pragma mark -

@implementation UnbalancedTree

- (id)init
{
    return [self initWithObject:nil];
}

- (id)initWithObject:(id <Comparable>)rootObject
{
    if (![super init]) {
		[self release];
		return nil;
	}
	if (rootObject != nil) {
		root = malloc(bNODESIZE);
		root->object = [rootObject retain];
		root->left = nil;
		root->right = nil;
		root->parent = nil;
		count = 1;
	}
    return self;
}

- (void)dealloc
{
    [self removeAllObjects];
    [super dealloc];
}

- (void) addObject:(id <Comparable>)element
{
    int comparison;
    
    if (element == nil)
		[NSException raise:NSInvalidArgumentException
					format:@"-[UnbalancedTree addObject:] -- Invalid nil argument."];
	
	[element retain];
	
	NSLog(@"Adding object: %@", element);
	
	if (root == NULL) {
		root = malloc(bNODESIZE);
		root->object = element;
		root->left   = NULL;
		root->right  = NULL;
		root->parent = NULL;
		count++;
		return;
	}
    
    struct BinaryNode *parentNode, *currentNode = root;
    while (currentNode != nil) {
        parentNode = currentNode;
        
        comparison = [element compare:currentNode->object];
		
        if (comparison == 0)
            break; // Artificially break the loop to replace the value
        else if (comparison < 0)
            currentNode = currentNode->left;
        else if (comparison > 0)
            currentNode = currentNode->right;
    }
    
    //this is why we used the special case.
    //we see what state got us to this
    //if it's equal, we just replace bar.
    
    //remember we REPLACE (i.e., release the old) elements
    if (comparison == NSOrderedSame) {
        [parentNode->object release];
        parentNode->object = element;
    }
	else {
		count++;
        struct BinaryNode *newNode = malloc(bNODESIZE);
		newNode->object = element;
		newNode->left   = NULL;
		newNode->right  = NULL;
		newNode->parent = parentNode;
		
		if (comparison == NSOrderedAscending)
			parentNode->left = newNode;
		else if (comparison == NSOrderedDescending)
			parentNode->right = newNode;		
	}
}

- (void)addObjectsFromArray:(NSArray *)anArray {
	NSEnumerator *e = [anArray objectEnumerator];
	id object;
	while ((object = [e nextObject]) != nil) {
		[self addObject:object];
	}
}

- (id)findMax
{
    return (_findMaxWithStarter(root))->object;
}

- (id)findMin
{
    return (_findMinWithStarter(root))->object;
}

- (id)findObject:(id <Comparable>)anObject {
	if (anObject == nil)
		[self exceptionForInvalidArgument:_cmd];

    struct BinaryNode *currentNode = root;
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

- (BOOL)containsObject:(id <Comparable>)anObject {
	if (anObject == nil)
		[self exceptionForInvalidArgument:_cmd];
	
    struct BinaryNode *currentNode = root;
    while (currentNode != NULL) {
        short comparison = [anObject compare:currentNode->object];
        if (comparison == NSOrderedAscending)
            currentNode = currentNode->left;
        else if (comparison == NSOrderedDescending)
            currentNode = currentNode->right;
		else if (comparison == NSOrderedSame) {
			return YES;
		}
    }
	return NO;
}

/**
 Removal is guaranteed not to make the tree deeper/taller, since it uses the "min of
 the right subtree" algorithm if the node to be removed has children.
 */
- (void) removeObject:(id <Comparable>)anObject
{
	if (anObject == nil)
		[self exceptionForInvalidArgument:_cmd];

    struct BinaryNode *currentNode = root;
    while (currentNode != NULL) {
        short comparison = [anObject compare:currentNode->object];
        if (comparison == NSOrderedAscending)
            currentNode = currentNode->left;
        else if (comparison == NSOrderedDescending)
            currentNode = currentNode->right;
		else if (comparison == NSOrderedSame) {
            _removeNode(currentNode, root);
			return;
		}
    }
}

/**
 Frees all the nodes in the tree and releases the objects they point to. The pointer
 to the root node remains NULL until an object is added to the tree. Uses a circular
 buffer array to store the objects waiting to be deleted; in a binary tree, no more
 than half of the nodes will be on the queue.
 */
- (void)removeAllObjects
{
	unsigned int bufferSize  = count/2 + 1;
	unsigned int bufferStart = 0;
	unsigned int bufferEnd   = 1;
	struct BinaryNode *deleteBuffer[bufferSize];
	struct BinaryNode *node;
	
	// Place non-null children on a queue, delete starting from the root of the tree.
	// This is in effect a level-order deletion traversal, which avoids recursion and
	// unnecessary patching of holes in the tree as nodes are removed, at the expense
	// of requiring extra storage space for the pointers waiting to be deleted.
	deleteBuffer[bufferStart] = root;
	while ((node = deleteBuffer[bufferStart]) != NULL) {
		if (node->left != NULL) {
			deleteBuffer[bufferEnd++] = node->left;
			bufferEnd %= bufferSize;
		}
		if (node->right != NULL) {
			deleteBuffer[bufferEnd++] = node->right;			
			bufferEnd %= bufferSize;
		}
		NSLog(@"Removing object: %@", node->object);
		[node->object release];
		free(node);
		deleteBuffer[bufferStart++] = NULL;
		bufferStart %= bufferSize;
	}
	root = NULL;
	count = 0;
}

- (BOOL)isEmpty
{
    return (root == NULL);
}

- (NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order
{
    if (root == NULL)
        return nil;
	
    return [[[UnbalancedTreeEnumerator alloc] initWithRoot:root
											traversalOrder:order] autorelease];
}

@end
