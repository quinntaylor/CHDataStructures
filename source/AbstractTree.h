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
#import "Tree.h"
#import "Stack.h"

/**
 An abstract Tree implementation with some default method implementations. Methods
 for insertion, search, removal and order-specific enumeration must be re-implemented
 by child classes so as to conform to their inner workings. The methods defined in
 this abstract class rely on the implementations of such operations, so they cannot
 be implemented here.
 
 Rather than enforcing that this class be abstract, the contract is implied. In any
 case, if this class is actually instantiated, it will be of little use since all the
 methods for insertion, removal, and search are unsupported and raise exceptions.
 */
@interface AbstractTree : NSObject <Tree>
{
	/** A count of how many elements are currently in the tree. */
	NSUInteger count;
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}

#pragma mark Method Implementations

- (id) init;
- (NSSet*) contentsAsSet;
- (NSArray*) contentsAsArrayUsingTraversalOrder:(CHTraversalOrder)traversalOrder;
- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSEnumerator*) reverseObjectEnumerator;

@end
