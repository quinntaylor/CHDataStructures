/*
 CHAVLTreeTest.m
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
#import "CHAVLTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHAVLTreeTest : SenTestCase {
	CHAVLTree *tree;
	NSArray *objects, *order, *correct;
}
@end


@implementation CHAVLTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
	tree = [[CHAVLTree alloc] init];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",
			   @"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
}

- (void) tearDown {
	[tree release];
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	STAssertEquals([tree count], 0u, @"Incorrect count.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
}

- (void) testAddObjectOneAtATime {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	[tree addObject:@"B"];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"B",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:@"N"];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"B",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:@"C"];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:@"L"];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"N",@"L",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:@"D"];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"L",@"D",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:@"J"];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"D",@"C",@"B",@"L",@"J",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	// Test adding identical object--should be replaced, and count stay the same
	//[tree addObject:@"A"];
	//STAssertEquals([tree count], [objects count], @"Incorrect count.");
}


- (void) testAllObjectsWithTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Ascending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
	correct = [NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",
			   @"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Descending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"J",@"D",@"B",@"A",@"C",@"G",@"E",@"F",
			   @"H",@"I",@"L",@"K",@"N",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePostOrder];
	correct = [NSArray arrayWithObjects:@"A",@"C",@"B",@"F",@"E",@"I",@"H",@"G",
			   @"D",@"K",@"M",@"O",@"N",@"L",@"J",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Post-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"J",@"D",@"L",@"B",@"G",@"K",@"N",@"A",
			   @"C",@"E",@"H",@"M",@"O",@"F",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level-order", order, correct));
}

- (void) testRemoveObject {
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");
	
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree removeObject:@"Z"]; // doesn't exist, shouldn't change the tree/count
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	[tree removeObject:@"J"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"K",@"D",@"N",@"B",@"G",@"L",@"O",@"A",@"C",
			   @"E",@"H",@"M",@"F",@"I",nil];
	STAssertFalse([order containsObject:@"J"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 14u, @"Incorrect count.");
	STAssertEquals([tree count],  14u, @"Incorrect count.");
	
	[tree removeObject:@"N"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"D",@"K",@"B",@"E",@"H",@"M",@"A",@"C",
			   @"F",@"I",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"N"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 13u, @"Incorrect count.");
	STAssertEquals([tree count],  13u, @"Incorrect count.");
	
	[tree removeObject:@"H"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"D",@"K",@"B",@"E",@"I",@"M",@"A",@"C",
			   @"F",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"H"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 12u, @"Incorrect count.");
	STAssertEquals([tree count],  12u, @"Incorrect count.");
	
	[tree removeObject:@"D"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"K",@"B",@"F",@"I",@"M",@"A",@"C",
			   @"L",@"O",nil];
	STAssertFalse([order containsObject:@"D"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 11u, @"Incorrect count.");
	STAssertEquals([tree count],  11u, @"Incorrect count.");
	
	[tree removeObject:@"C"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"K",@"B",@"F",@"I",@"M",@"A",@"L",
			   @"O",nil];
	STAssertFalse([order containsObject:@"C"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 10u, @"Incorrect count.");
	STAssertEquals([tree count],  10u, @"Incorrect count.");
	
	[tree removeObject:@"K"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"L",@"B",@"F",@"I",@"M",@"A",@"O",
			   nil];
	STAssertFalse([order containsObject:@"K"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 9u, @"Incorrect count.");
	STAssertEquals([tree count],  9u, @"Incorrect count.");
	
	[tree removeObject:@"M"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"L",@"B",@"F",@"I",@"O",@"A",nil];
	STAssertFalse([order containsObject:@"M"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 8u, @"Incorrect count.");
	STAssertEquals([tree count],  8u, @"Incorrect count.");
	
	[tree removeObject:@"B"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"L",@"A",@"F",@"I",@"O",nil];
	STAssertFalse([order containsObject:@"B"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 7u, @"Incorrect count.");
	STAssertEquals([tree count],  7u, @"Incorrect count.");
	
	[tree removeObject:@"A"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"L",@"F",@"I",@"O",nil];
	STAssertFalse([order containsObject:@"A"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 6u, @"Incorrect count.");
	STAssertEquals([tree count],  6u, @"Incorrect count.");
	
	[tree removeObject:@"G"];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"L",@"F",@"O",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	STAssertFalse([order containsObject:@"G"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 5u, @"Incorrect count.");
	STAssertEquals([tree count],  5u, @"Incorrect count.");
	
	[tree removeObject:@"E"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"I",@"F",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"E"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 4u, @"Incorrect count.");
	STAssertEquals([tree count],  4u, @"Incorrect count.");
	
	[tree removeObject:@"F"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"L",@"I",@"O",nil];
	STAssertFalse([order containsObject:@"F"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 3u, @"Incorrect count.");
	STAssertEquals([tree count],  3u, @"Incorrect count.");
	
	[tree removeObject:@"L"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"I",@"I",nil];
	STAssertFalse([order containsObject:@"L"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 2u, @"Incorrect count.");
	STAssertEquals([tree count],  2u, @"Incorrect count.");
	
	[tree removeObject:@"I"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"O",nil];
	STAssertFalse([order containsObject:@"I"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], 1u, @"Incorrect count.");
	STAssertEquals([tree count],  1u, @"Incorrect count.");
}


@end
