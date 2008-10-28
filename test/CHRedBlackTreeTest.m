/*
 CHRedBlackTreeTest.m
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
#import "CHRedBlackTree.h"

@interface CHRedBlackTreeTest : SenTestCase {
	CHRedBlackTree *tree;
	NSArray *object;
}
@end


@implementation CHRedBlackTreeTest

- (void) setUp {
	tree = [[CHRedBlackTree alloc] init];
	object = [NSArray arrayWithObjects:
				 @"F", @"B", @"A", @"D", @"C", @"E", @"G", @"I", @"H", nil];
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
	[tree release];
}

- (void) testEmptyTree {
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise exception on nil.");
	
	[tree addObject:@"B"];
	[tree addObject:@"A"];
	[tree addObject:@"C"];
	STAssertEquals([tree count], 3u, @"-count is incorrect.");
	[tree addObject:@"C"];
	STAssertEquals([tree count], 3u, @"-count is incorrect.");
}

- (void) testContainsObject {
	STAssertFalse([tree containsObject:@"A"], @"Should not contain any nodes.");

	[tree addObject:@"B"];
	[tree addObject:@"A"];
	[tree addObject:@"C"];
	STAssertTrue([tree containsObject:@"A"], @"Should contain this value.");
	STAssertFalse([tree containsObject:@"Z"], @"Should NOT contain this value.");
}

- (void) testFindMin {
	STAssertNil([tree findMin], @"Should return nil when empty.");
	[tree addObject:@"B"];
	[tree addObject:@"A"];
	[tree addObject:@"C"];
	STAssertEqualObjects([tree findMin], @"A", @"-findMin is incorrect.");
}

- (void) testFindMax {
	STAssertNil([tree findMax], @"Should return nil when empty.");
	[tree addObject:@"B"];
	[tree addObject:@"A"];
	[tree addObject:@"C"];
	STAssertEqualObjects([tree findMax], @"C", @"-findMax is incorrect.");	
}

- (void) testFindObject {
	STAssertNil([tree findObject:@"A"], @"Should return nil when empty.");
	[tree addObject:@"B"];
	[tree addObject:@"A"];
	[tree addObject:@"C"];
	STAssertEqualObjects([tree findObject:@"A"], @"A", @"-findObject is wrong.");	
	STAssertEqualObjects([tree findObject:@"B"], @"B", @"-findObject is wrong.");	
	STAssertEqualObjects([tree findObject:@"C"], @"C", @"-findObject is wrong.");	
}

@end
