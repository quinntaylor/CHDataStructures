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

//  RedBlackTree.m
//  DataStructuresFramework

#import "RedBlackTree.h"

#pragma mark C Functions for Optimized Operations

static RedBlackNode * _rotateWithLeftChild(RedBlackNode *leftChild)
{
    RedBlackNode *l1 = [leftChild left];
    [leftChild setLeft: [l1 right]];
    [l1 setRight:leftChild];
    return l1;
}

static RedBlackNode * _rotateWithRightChild(RedBlackNode *rightChild)
{
    RedBlackNode *r1 = [rightChild right];
    [rightChild setRight: [r1 left]];
    [r1 setLeft:rightChild];
    return r1;
}

#pragma mark -

@implementation RedBlackNode

-(id)init
{
    return [self initWithObject:nil];
}

-(id)initWithObject:(id <Comparable>)theObject
{
    return [self initWithObject:theObject withLeft:nil withRight:nil];
}

-(id)initWithObject:(id <Comparable>)theObject
		   withLeft:(RedBlackNode *)theLeft
		  withRight:(RedBlackNode *)theRight
{
	if (![super init]) {
		[self release];
		return nil;
	}
    
    color = nBLACK;
    object = [theObject retain];
    left = [theLeft retain];
    right = [theRight retain];
    
    return self;
}

- (void)dealloc
{
    [left release];
    [right release];
    [object release];
	
    [super dealloc];
}

- (RedBlackNode *)left
{
    return left;
}

- (RedBlackNode *)right
{
    return right;
}

- (id) object
{
    return object;
}

- (short int)color
{
    return color;
}

- (void)setColor:(short int)newColor
{
    color = newColor;
}

- (void)setLeft:(RedBlackNode *)newLeft
{
    RedBlackNode *old;
    old = left;
    left = [newLeft retain];
    [old release];
}

- (void)setRight:(RedBlackNode *)newRight
{
    RedBlackNode *old;
    old = right;
    right = [newRight retain];
    [old release];
}

- (void)setObject:(id <Comparable>)newObject
{
    id old;
    old = object;
    object = [newObject retain];
    [old release];
}

@end

#pragma mark -

/**
 An NSEnumerator for traversing a RedBlackTree subtree in a specified order.
 
 NOTE: Tree enumerators are tricky to do without recursion.
 Consider using a stack to store path so far?
 */
@interface RedBlackTreeEnumerator : NSEnumerator
{
    struct RBNode *currentNode;
	CHTraversalOrder traversalOrder;
    BOOL hasStarted;
    BOOL beenLeft;
    BOOL beenRight;
}

/** Create an enumerator which traverses a given subtree in the specified order. */
- (id)initWithRoot:(RedBlackNode *)root traversalOrder:(CHTraversalOrder)order;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray *) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or <code>nil</code>
 when all objects have been enumerated.
 */
- (id) nextObject;

@end

#pragma mark -

@implementation RedBlackTreeEnumerator

- (id)initWithRoot:(RedBlackNode *)root traversalOrder:(CHTraversalOrder)order;
{
	if (![super init] || order < CHTraverseInOrder || order > CHTraverseLevelOrder) {
		[self release];
		return nil;
	}
//    currentNode = ___;
	traversalOrder = order;
    beenLeft = YES;
    beenRight = NO;
    hasStarted = NO;
    return self;
}

- (NSArray *)allObjects
{
    id object;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    while ((object = [self nextObject]))
        [array addObject:object];
    
    return [array autorelease];
}

- (id)nextObject
{
	// TODO: Create logic to consider traversalOrder for unbalanced trees
	return nil;
}

@end


#pragma mark -

@implementation RedBlackTree

/**
 * This method deals simply with our header on every comparison.
 */
- (int) _compare:(id <Comparable>)x
        withNode:(RedBlackNode *)node
{
    if ( node == header )
        return 1;
    else
        return [x compare:[node object]];
}

- (RedBlackNode *) _rotate:( id <Comparable>)x
	      onAncestor:(RedBlackNode *)ancestor
{
    if ( [self _compare:x withNode:ancestor] < 0 )
    {
        [ancestor setLeft:(
						   [self _compare:x withNode:[ancestor left]] < 0 ?
						   (_rotateWithLeftChild([ancestor left])) : 
						   (_rotateWithRightChild([ancestor left]))
						   )];
        
        return [ancestor left];
    }
    else
    {
        [ancestor setRight:(
							[self _compare:x withNode:[ancestor right]] < 0 ?
							(_rotateWithLeftChild([ancestor right])) : 
							(_rotateWithRightChild([ancestor right]))
							)];
        
        return [ancestor right];
    }
}

- (void) _reorient:(id <Comparable>)x
{
    [current setColor: nRED];
    [[current left] setColor: nBLACK];
    [[current right] setColor: nBLACK];
    
    if ( [parent color] == nRED )
    {
        [grandparent setColor: nRED];
		
        if ( 
			([self _compare:x withNode:grandparent] < 0) !=
			([self _compare:x withNode:parent] < 0)
			
			)
        {
            parent = [self _rotate:x onAncestor:grandparent];
        }
        
        current = [self _rotate:x onAncestor:greatgrandparent];
        
        [current setColor: nBLACK];
    }
    
    //always reset root to black
    [[header right] setColor: nBLACK];
}


- (id)init
{
	if (![super init]) {
		[self release];
		return nil;
	}
    
    sentinel = [[RedBlackNode alloc] init];
    [sentinel setLeft:sentinel];
    [sentinel setRight:sentinel];
    
    header = [[RedBlackNode alloc] init];
    [header setLeft:sentinel];
    [header setRight:sentinel];
    
    return self;
}

- (void)dealloc
{
    [header release];
    [sentinel release];
    [super dealloc];
}

/**
 Basically, as you walk down the tree to insert, if the present node has two red
 children, you color it red and change the two children to black. If its parent is
 red, you'll have to rotate the tree. (Just change the root's color back to black if
 you changed it). Returns NO only when a compare: == 0 object already exists in the tree
 */
- (void)addObject:(id <Comparable>)object
{
	// TODO: Send -retain to the object when added

    current = parent = grandparent = header;
    [sentinel setObject:object];
    
    while ( [self _compare:object withNode:current] != 0 )
    {
        greatgrandparent = grandparent; grandparent = parent; parent = current;
        current = [self _compare:object withNode:current] < 0 ? [current left] : [current right];
        
        // this is where we check for the bad case of red parent and red sibling of parent
        if ( [[current left] color] == nRED && [[current right] color] == nRED )
            [self _reorient:object];
    }
    
    // return if a sentinel didn't result (i.e., we didn't get to nil)
    if ( current != sentinel )
        return;
	
    current = [[RedBlackNode alloc] initWithObject:object 
                                    withLeft:sentinel 
                                   withRight:sentinel ];
	
    if ( [self _compare:object withNode:parent] < 0 )
        [parent setLeft:current];
    else
        [parent setRight:current];
    
    // one last reorientation check...
    [self _reorient:object];
    return;
}

-(RedBlackNode *)_findNode:(id <Comparable>)target
{
    //we make the sentinel's object == target ... so we will eventually find it no matter what
    [sentinel setObject:target];
    current = [header right];
    
    while(1)
    {
        if ( [target compare:[current object]] < 0 )
            current = [current left];
        else if ( [target compare:[current object]] > 0 )
            current = [current right];
        else if ( current != sentinel )
            return current;
        else
            return nil;
    }
}

- (id)findObject:(id <Comparable>)target
{
    id retval = [[self _findNode: target] object];
    
    if (retval)
        return retval;
    else
        return nil;
}

- (id)findMin
{
    parent = nil;
    current = [header right];
    
    while(current != sentinel)
    {
        parent = current;
        current = [current left];
    }
    
    return [parent object];
}

- (id)findMax
{
    parent = nil;
    current = [header right];
    
    while(current != sentinel)
    {
        parent = current;
        current = [current right];
    }
    
    return [parent object];
}

// TODO: NEXT RELEASE

// Not in this version! Very difficult -- my fu is no match for it right this minute.
- (void)removeObject:(id <Comparable>)object {
}

- (void)removeAllObjects {
}

-(NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)traversalOrder
{
    RedBlackNode *root = [header right];
    
    if (root == sentinel)
        return nil;
	
	return [[[RedBlackTreeEnumerator alloc] initWithRoot:root
										  traversalOrder:traversalOrder] autorelease];
}

@end
