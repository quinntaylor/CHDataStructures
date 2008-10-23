/*
 CHRedBlackTree.m
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

#import "CHRedBlackTree.h"

@implementation CHRedBlackTreeNode

- (id) init {
	return [self initWithObject:nil withLeft:nil withRight:nil];
}

- (id) initWithObject:(id)theObject {
	return [self initWithObject:theObject withLeft:nil withRight:nil];
}

- (id) initWithObject:(id)theObject
            withLeft:(CHRedBlackTreeNode*)theLeft
           withRight:(CHRedBlackTreeNode*)theRight
{
	if ([super init] == nil)
		return nil;
	color = nBLACK;
	object = [theObject retain];
	left = [theLeft retain];
	right = [theRight retain];
	return self;
}

- (void) dealloc {
	[left release];
	[right release];
	[object release];
	[super dealloc];
}

- (CHRedBlackTreeNode*) left {
	return left;
}

- (CHRedBlackTreeNode*) right {
	return right;
}

- (id) object {
	return object;
}

- (BOOL) color {
	return color;
}

- (void) setColor:(BOOL)newColor {
	color = newColor;
}

- (void) setLeft:(CHRedBlackTreeNode*)newLeft {
	[newLeft retain];
	[left release];
	left = newLeft;
}

- (void) setRight:(CHRedBlackTreeNode*)newRight {
	[newRight retain];
	[right release];
	right = newRight;
}

- (void) setObject:(id)newObject {
	[newObject retain];
	[object release];
	object = newObject;
}

@end

#pragma mark -

/**
 An NSEnumerator for traversing a CHRedBlackTree in a specified order.
 
 NOTE: Tree enumerators are tricky to do without recursion.
 Consider using a stack to store path so far?
 */
@interface CHRedBlackTreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder;
	@private
	CHRedBlackTree *collection;
	struct RBNode *currentNode;
	BOOL hasStarted;
	BOOL beenLeft;
	BOOL beenRight;
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
- (id) initWithTree:(CHRedBlackTree*)tree
               root:(CHRedBlackTreeNode*)root
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

@implementation CHRedBlackTreeEnumerator

- (id) initWithTree:(CHRedBlackTree*)tree
               root:(CHRedBlackTreeNode*)root
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order))
		return nil;
	collection = (root != NULL) ? collection = [tree retain] : nil;
//	currentNode = ___;
	traversalOrder = order;
	beenLeft = YES;
	beenRight = NO;
	hasStarted = NO;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
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

/**
 @see UnbalancedTreeEnumerator#nextObject
 */
- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	// TODO: Copy enumeration logic from UnbalancedTree
	return nil;
}

@end

#pragma mark -

#pragma mark C Functions for Optimized Operations

static CHRedBlackTreeNode * _rotateWithLeftChild(CHRedBlackTreeNode *leftChild) {
	CHRedBlackTreeNode *l1 = [leftChild left];
	[leftChild setLeft: [l1 right]];
	[l1 setRight:leftChild];
	return l1;
}

static CHRedBlackTreeNode * _rotateWithRightChild(CHRedBlackTreeNode *rightChild) {
	CHRedBlackTreeNode *r1 = [rightChild right];
	[rightChild setRight: [r1 left]];
	[r1 setLeft:rightChild];
	return r1;
}

#pragma mark -

@implementation CHRedBlackTree

#pragma mark - Private Methods

/**
 * This method deals simply with our header on every comparison.
 */
- (int) _compare:(id)x withNode:(CHRedBlackTreeNode*)node {
	if (node == header)
		return 1;
	else
		return [x compare:[node object]];
}

- (CHRedBlackTreeNode*) _findNode:(id)target {
	//we make the sentinel's object == target ... so we will eventually find it no matter what
	[sentinel setObject:target];
	current = [header right];
	
	while(1)
	{
		if ([target compare:[current object]] < 0)
			current = [current left];
		else if ([target compare:[current object]] > 0)
			current = [current right];
		else if (current != sentinel)
			return current;
		else
			return nil;
	}
}

- (CHRedBlackTreeNode*) _rotate:(id)x onAncestor:(CHRedBlackTreeNode*)ancestor {
	if ([self _compare:x withNode:ancestor] < 0) 	{
		[ancestor setLeft:(
						   [self _compare:x withNode:[ancestor left]] < 0 ?
						   (_rotateWithLeftChild([ancestor left])) : 
						   (_rotateWithRightChild([ancestor left]))
						  )];
		
		return [ancestor left];
	}
	else 	{
		[ancestor setRight:(
							[self _compare:x withNode:[ancestor right]] < 0 ?
							(_rotateWithLeftChild([ancestor right])) : 
							(_rotateWithRightChild([ancestor right]))
							)];
		
		return [ancestor right];
	}
}

- (void) _reorient:(id)x {
	[current setColor: nRED];
	[[current left] setColor: nBLACK];
	[[current right] setColor: nBLACK];
	
	if ([parent color] == nRED) 	{
		[grandparent setColor: nRED];
		
		if (([self _compare:x withNode:grandparent] < 0) !=
			([self _compare:x withNode:parent] < 0))
		{
			parent = [self _rotate:x onAncestor:grandparent];
		}
		
		current = [self _rotate:x onAncestor:greatgrandparent];
		
		[current setColor: nBLACK];
	}
	
	//always reset root to black
	[[header right] setColor: nBLACK];
}

#pragma mark - Public Methods

- (id) init {
	if ([super init] == nil)
		return nil;
	sentinel = [[CHRedBlackTreeNode alloc] init];
	[sentinel setLeft:sentinel];
	[sentinel setRight:sentinel];
	header = [[CHRedBlackTreeNode alloc] init];
	[header setLeft:sentinel];
	[header setRight:sentinel];
	return self;
}

- (void) dealloc {
	[header release];
	[sentinel release];
	[super dealloc];
}

- (void) addObject:(id)object {
	/*
	 Basically, as you walk down the tree to insert, if the present node has two red
	 children, you color it red and change the two children to black. If its parent is
	 red, you'll have to rotate the tree. (Just change the root's color back to black if
	 you changed it). Returns NO only when a compare: == 0 object already exists in the tree
	 */

	// TODO: Send -retain to the object when added

	current = parent = grandparent = header;
	[sentinel setObject:object];
	
	while ([self _compare:object withNode:current] != 0) 	{
		greatgrandparent = grandparent; grandparent = parent; parent = current;
		current = [self _compare:object withNode:current] < 0 ? [current left] : [current right];
		
		// this is where we check for the bad case of red parent and red sibling of parent
		if ([[current left] color] == nRED && [[current right] color] == nRED)
			[self _reorient:object];
	}
	
	// return if a sentinel didn't result (i.e., we didn't get to nil)
	if (current != sentinel)
		return;
	
	current = [[CHRedBlackTreeNode alloc] initWithObject:object 
									withLeft:sentinel 
								   withRight:sentinel ];
	
	if ([self _compare:object withNode:parent] < 0)
		[parent setLeft:current];
	else
		[parent setRight:current];
	
	// one last reorientation check...
	[self _reorient:object];
	return;
}

- (BOOL) containsObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
	return NO;
}

- (id) findMax {
	parent = nil;
	current = [header right];
	
	while(current != sentinel) {
		parent = current;
		current = [current right];
	}
	
	return [parent object];
}

- (id) findMin {
	parent = nil;
	current = [header right];
	
	while (current != sentinel) {
		parent = current;
		current = [current left];
	}
	return [parent object];
}

- (id) findObject:(id)target {
	return [[self _findNode: target] object];
}

/**
 @param anObject The object to be removed from the tree if present.
 
 @todo Implement <code>-removeObject:</code> method, including rebalancing.
 */
- (void) removeObject:(id)anObject {
	CHUnsupportedOperationException([self class], _cmd);
	// TODO: Next release, very difficult, my fu is no match for it right this minute.
}

- (void) removeAllObjects {
	CHUnsupportedOperationException([self class], _cmd);
	// TODO: Re-purpose this code from UnbalancedTree
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	CHRedBlackTreeNode *root = [header right];
	if (root == sentinel)
		return nil;
	return [[[CHRedBlackTreeEnumerator alloc] initWithTree:self
                                                      root:root
                                            traversalOrder:order
                                           mutationPointer:&mutations] autorelease];
}

@end
