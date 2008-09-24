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
/*
 *  AbstractTree.h
 *  DataStructuresFramework
 */

#import <Foundation/Foundation.h>
#import "Comparable.h"
#import "Tree.h"
#import "Stack.h"

/**
 This is to be treated as an abstract class, and concrete child classes must
 implement all methods in the Tree protocol.
 */
@interface AbstractTree : NSObject <Tree>
{
	/** A count of how many elements are currently in the tree. */
	unsigned long count;
}

/**
 Creates an NSSet which contains the objects from this binary tree. Uses a pre-order
 traversal since it requires less space, is extremely fast, and sets are unordered.
 */
- (NSSet *) contentsAsSet;

/**
 Creates an NSArray which contains the objects from the specified binary tree.
 The tree traversal ordering (in-order, pre-order, post-order) must be specified.
 The object traversed last will be at the end of the array.
 */
- (NSArray *) contentsAsArrayWithOrder:(CHTraversalOrder)traversalOrder;

/**
 Creates a Stack which contains Comparable objects from a binary tree.
 The tree traversal ordering (in-order, pre-order, post-order) must be specified.
 The object traversed last will be on the top of the stack.
 */
- (id <Stack>) contentsAsStackWithInsertionOrder:(CHTraversalOrder)traversalOrder;

/**
 Create an enumerator which performs a in-order traversal. Although this has greater
 space complexity than pre-order (depth-first) traversal, it is a sensible default
 since it returns values according to their natural ordering based on compare:.
 */
- (NSEnumerator *)objectEnumerator;

/**
 Convenience method for raising an NSException for an unsupported class operation.
 */
+ (id)exceptionForUnsupportedOperation:(SEL)operation;

/**
 Convenience method for raising an NSException for an unsupported operation.
 */
- (id)exceptionForUnsupportedOperation:(SEL)operation;

/**
 Convenience method for raising an NSException for an invalid (nil) argument.
 */
- (id)exceptionForInvalidArgument:(SEL)operation;

@end
