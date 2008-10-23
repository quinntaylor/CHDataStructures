/*
 CHAbstractTree.h
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

#import <Foundation/Foundation.h>
#import "CHTree.h"

/**
 An abstract CHTree implementation with some default method implementations. Methods
 for insertion, search, removal and order-specific enumeration must be re-implemented
 by child classes so as to conform to their inner workings. The methods defined in
 this abstract class rely on the implementations of such operations, so they cannot
 be implemented here.
 
 Rather than enforcing that this class be abstract, the contract is implied. In any
 case, if this class is actually instantiated, it will be of little use since all the
 methods for insertion, removal, and search are unsupported and raise exceptions.
 */
@interface CHAbstractTree : NSObject <CHTree>
{
	NSUInteger count; /**< A count of how many elements are currently in the tree. */
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
}

@end
