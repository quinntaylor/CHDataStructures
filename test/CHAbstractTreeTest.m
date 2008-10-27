/*
 CHAbstractTreeTest.m
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

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractTree.h"

@interface CHAbstractTreeTest : SenTestCase
{
	CHAbstractTree *tree;
}

@end

@implementation CHAbstractTreeTest

- (void) setUp {
	tree = [[CHAbstractTree alloc] init];
}

- (void) tearDown {
	[tree release];
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise exception, abstract.");
}

- (void) testAllObjects {
	STAssertThrows([tree allObjects], @"Should raise exception, abstract.");
}

- (void) testContainsObject {
	STAssertThrows([tree containsObject:nil], @"Should raise exception, abstract.");
}

- (void) testFindMin {
	STAssertThrows([tree findMin], @"Should raise exception, abstract.");
}

- (void) testFindMax {
	STAssertThrows([tree findMax], @"Should raise exception, abstract.");
}

- (void) testFindObject {
	STAssertThrows([tree findObject:nil], @"Should raise exception, abstract.");
}

- (void) testObjectEnumeratorWithTraversalOrder {
	STAssertThrows([tree reverseObjectEnumerator], @"Should raise exception, abstract.");
}

- (void) testRemoveObject {
	STAssertThrows([tree removeObject:nil], @"Should raise exception, abstract.");
}

- (void) testRemoveAllObjects {
	STAssertThrows([tree removeAllObjects], @"Should raise exception, abstract.");
}

- (void) testNSFastEnumeration {
	STAssertThrows([tree countByEnumeratingWithState:NULL objects:NULL count:1],
				   @"NSFastEnumeration should raise an exception for abstract.");
}

@end
