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

static RBNode * _rotateWithLeftChild(RBNode *leftChild)
{
    RBNode *l1 = [leftChild left];
    [leftChild setLeft: [l1 right]];
    [l1 setRight:leftChild];
    return l1;
}

static RBNode * _rotateWithRightChild(RBNode *rightChild)
{
    RBNode *r1 = [rightChild right];
    [rightChild setRight: [r1 left]];
    [r1 setLeft:rightChild];
    return r1;
}

#pragma mark -

/**
 Enumerators are tricky to do without recursion.
 Consider using a stack to store path so far?
 */
@implementation RedBlackTreeEnumerator

- (id)initWithRoot:(RBNode *)root traversalOrder:(CHTraversalOrder)order;
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


/*
 @interface RedBlackTree
 {
 RBNode *header; //links to the root -- eliminates special cases
 RBNode *sentinel; //always black, stands in for nil
 
 RBNode *current;
 RBNode *parent;
 RBNode *grandparent;
 RBNode *greatgrandparent;
 }
 */

#pragma mark -

@implementation RedBlackTree

/**
 * This method deals simply with our header on every comparison.
 */
- (int) _compare:(id <Comparable>)x
        withNode:(RBNode *)node
{
    if ( node == header )
        return 1;
    else
        return [x compare:[node object]];
}

- (RBNode *) _rotate:( id <Comparable>)x
	      onAncestor:(RBNode *)ancestor
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
    
    sentinel = [[RBNode alloc] init];
    [sentinel setLeft:sentinel];
    [sentinel setRight:sentinel];
    
    header = [[RBNode alloc] init];
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
	
    current = [[RBNode alloc] initWithObject:object 
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

-(RBNode *)_findNode:(id <Comparable>)target
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

- (BOOL)isEmpty
{
    return ( [header right] == sentinel || [header right] == nil );
}

// TODO: NEXT RELEASE

// Not in this version! Very difficult -- my fu is no match for it right this minute.
- (void)removeObject:(id <Comparable>)object {
}

-(NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)traversalOrder;
{
    RBNode *root = [header right];
    
    if (root == sentinel)
        return nil;
	
	return [[[RedBlackTreeEnumerator alloc] initWithRoot:root
										  traversalOrder:traversalOrder] autorelease];
}

@end
