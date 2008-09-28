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

/**
 An NSEnumerator for traversing an UnbalancedTree (or subtree) in a specified order.
 
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
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param root The root node of the (sub)tree whose elements are to be enumerated.
 @param order The traversal order to use for enumerating the given (sub)tree.
 */
- (id) initWithRoot:(AATreeNode *)root traversalOrder:(CHTraversalOrder)order;

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

@implementation AATreeEnumerator

- (id) initWithRoot:(AATreeNode *)root traversalOrder:(CHTraversalOrder)order;
{
	if (![super init] || !isValidTraversalOrder(order)) {
		[self release];
		return nil;
	}
	// TODO: Copy and adapt traversal code from UnbalancedTree.m
	return self;
}

- (id) nextObject
{
	// TODO: Copy and adapt traversal code from UnbalancedTree.m
	return nil;
}

- (NSArray *) allObjects
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [self nextObject]))
		[array addObject:object];
	
	return [array autorelease];
}

@end

#pragma mark -

@implementation AATree

- (id) init
{
	if (![super init]) {
		[self release];
		return nil;
	}
	return self;
}

- (void) dealloc
{
	[self removeAllObjects];
	[super dealloc];
}

- (void) addObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (id) findObject:(id)target {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (id) findMin {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (id) findMax {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (BOOL) containsObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
	return NO;
}

- (void) removeObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (void) removeAllObjects {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (NSEnumerator *) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [self exceptionForUnsupportedOperation:_cmd];
}

@end
