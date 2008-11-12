/*
 CHUnbalancedTreeTest.m
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
#import "CHUnbalancedTree.h"

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHUnbalancedTreeTest : SenTestCase {
	CHUnbalancedTree *tree;
	NSArray *objects, *order, *correct;
}
@end

@implementation CHUnbalancedTreeTest

- (void) setUp {
    tree = [[CHUnbalancedTree alloc] init];
	objects = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",
			   @"H",nil]; // Specified using level-order travesal
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
	correct = objects; // Since it's unbalanced, the final ordering is the same.
}

- (void) tearDown {
    [tree release];
}

#pragma mark -

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	STAssertEquals([tree count], 0u, @"Incorrect count.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	STAssertTrue([order isEqualToArray:objects],
				 badOrder(@"After construction, level order", order, objects));
}

- (void) testAllObjectsWithTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Ascending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
	correct = [NSArray arrayWithObjects:@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",
			   @"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Descending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",
			   @"H",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePostOrder];
	correct = [NSArray arrayWithObjects:@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",
			   @"F",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Post-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",
			   @"H",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level-order", order, correct));
}

- (void) testRemoveObject {
	// Test remove and subsequent pre-order of nodes for 4 broad possible cases
	objects = [NSArray arrayWithObjects:
			   @"F",@"B",@"A",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil];
	for (id object in objects)
		[tree addObject:object];
	
	// Test removing nil
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");

	// Test removing a node which doesn't occur in the tree
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");

	// Test remove and subsequent pre-order of nodes for 4 broad possible cases
	
	// 1 - Remove a node with no children
	[tree removeObject:@"A"];
	STAssertEquals([tree count], [objects count]-1, @"Incorrect count.");
	correct = [NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));
	
	[tree removeObject:@"K"];
	STAssertEquals([tree count], [objects count]-2, @"Incorrect count.");
	correct = [NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));

	// 2 - Remove a node with only a right child
	[tree removeObject:@"C"];
	STAssertEquals([tree count], [objects count]-3, @"Incorrect count.");
	correct = [NSArray arrayWithObjects:@"F",@"B",@"E",@"D",@"J",@"I",@"G",@"H",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));
	
	[tree removeObject:@"B"];
	STAssertEquals([tree count], [objects count]-4, @"Incorrect count.");
	correct = [NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"I",@"G",@"H",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));
	
	// 3 - Remove a node with only a left child
	[tree removeObject:@"I"];
	STAssertEquals([tree count], [objects count]-5, @"Incorrect count.");
	correct = [NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"G",@"H",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));

	[tree removeObject:@"J"];
	STAssertEquals([tree count], [objects count]-6, @"Incorrect count.");
	correct = [NSArray arrayWithObjects:@"F",@"E",@"D",@"G",@"H",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));
	
	// 4 - Remove a node with two children
	[tree release];
	objects = [NSArray arrayWithObjects: @"B",@"A",@"E",@"C",@"D",@"F",nil];
	tree = [[CHUnbalancedTree alloc] initWithArray:objects];

	[tree removeObject:@"B"];
	STAssertEquals([tree count], [objects count]-1, @"Incorrect count.");
	correct = [NSArray arrayWithObjects: @"C",@"A",@"E",@"D",@"F",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));

	[tree removeObject:@"C"];
	STAssertEquals([tree count], [objects count]-2, @"Incorrect count.");
	correct = [NSArray arrayWithObjects: @"D",@"A",@"E",@"F",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));

	[tree removeObject:@"D"];
	STAssertEquals([tree count], [objects count]-3, @"Incorrect count.");
	correct = [NSArray arrayWithObjects: @"E",@"A",@"F",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));

	[tree removeObject:@"E"];
	STAssertEquals([tree count], [objects count]-4, @"Incorrect count.");
	correct = [NSArray arrayWithObjects: @"F",@"A",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Pre-order", order, correct));
}

@end
