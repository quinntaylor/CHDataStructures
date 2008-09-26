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

//  AbstractTree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Comparable.h"
#import "Tree.h"
#import "Stack.h"

/**
 An abstract implementation of the Tree protocol with several convenience methods.
 Child classes must re-implement protocol methods according to their inner workings.
 */
@interface AbstractTree : NSObject <Tree>
{
	/** A count of how many elements are currently in the tree. */
	unsigned int count;
}

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

#pragma mark Inherited Methods

- (void) addObjectsFromArray:(NSArray *)anArray;
- (unsigned int) count;

- (NSSet *) contentsAsSet;
- (NSArray *) contentsAsArrayWithOrder:(CHTraversalOrder)traversalOrder;
- (id <Stack>) contentsAsStackWithInsertionOrder:(CHTraversalOrder)traversalOrder;
- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;

@end
