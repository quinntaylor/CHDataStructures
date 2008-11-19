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
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",@"H",
			   @"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
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
	NSUInteger expectedCount = [objects count];
	STAssertEquals([tree count], expectedCount, @"Incorrect count.");
	[tree removeObject:@"Z"]; // doesn't exist, shouldn't change the tree/count
	STAssertEquals([tree count], expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"J"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"K",@"D",@"B",@"A",@"C",@"G",@"E",@"F",
			   @"H",@"I",@"N",@"L",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"N"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"D",@"B",@"A",@"C",@"E",@"F",@"K",
			   @"H",@"I",@"M",@"L",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"H"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"D",@"B",@"A",@"C",@"E",@"F",@"K",
			   @"I",@"M",@"L",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"D"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"B",@"A",@"C",@"F",@"K",@"I",
			   @"M",@"L",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"C"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"B",@"A",@"F",@"K",@"I",@"M",
			   @"L",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"K"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"B",@"A",@"F",@"L",@"I",@"M",
			   @"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"M"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"B",@"A",@"F",@"L",@"I",@"O",
			   nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"B"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"L",@"I",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"A"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"F",@"L",@"I",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"E"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"F",@"L",@"I",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"F"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"L",@"G",@"I",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"G"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"L",@"I",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"L"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"O",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	
	[tree removeObject:@"O"];
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
}

- (void) testDebugDescriptionForNode {
	CHTreeNode *sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->left = sentinel->right = sentinel;
	CHTreeNode *node = malloc(kCHTreeNodeSize);
	node->object = [NSString stringWithString:@"A B C"];
	node->left = node->right = sentinel;
	node->balance = 0;
	
	STAssertEqualObjects([tree debugDescriptionForNode:node],
						 @"	[ 0]\t\"A B C\" -> \"(null)\" and \"(null)\"\n", nil);
}

- (void) testDotStringForNode {
	CHTreeNode *sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->left = sentinel->right = sentinel;
	CHTreeNode *node = malloc(kCHTreeNodeSize);
	node->object = [NSString stringWithString:@"A B C"];
	node->left = node->right = sentinel;
	node->balance = 0;
	
	STAssertEqualObjects([tree dotStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n0\"];\n", nil);
}

@end
