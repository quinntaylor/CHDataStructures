/*
 CHDataStructures.framework -- CHAnderssonTreeTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAnderssonTree.h"

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
#if MAC_OS_X_VERSION_10_5_AND_LATER
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
	          traversal, correct, order]
	         stringByReplacingOccurrencesOfString:@"\n" withString:@""]
	        stringByReplacingOccurrencesOfString:@"    " withString:@""];
#else
	return [NSString stringWithFormat:@"%@ should be %@, was %@",
	        traversal, correct, order];
#endif
}

@interface CHAnderssonTreeTest : SenTestCase {
	CHAnderssonTree *tree;
	NSArray *objects, *order, *correct;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHAnderssonTreeTest

- (void) setUp {
	tree = [[CHAnderssonTree alloc] init];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",
				 @"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 645
}

- (void) tearDown {
	[tree release];
}

#pragma mark -

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	STAssertEquals([tree count], (NSUInteger)0, @"Incorrect count.");
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[tree addObject:anObject];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
}

- (void) testAllObjectsWithTraversalOrder {
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[tree addObject:anObject];
	
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
	correct = [NSArray arrayWithObjects:@"E",@"C",@"A",@"B",@"D",@"L",@"H",@"F",
			   @"G",@"J",@"I",@"K",@"N",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePostOrder];
	correct = [NSArray arrayWithObjects:@"B",@"A",@"D",@"C",@"G",@"F",@"I",@"K",
			   @"J",@"H",@"M",@"O",@"N",@"L",@"E",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Post-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",
			   @"F",@"J",@"M",@"O",@"G",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level-order", order, correct));
}

- (void) testRemoveObject {
	STAssertNoThrow([tree removeObject:nil], @"Should not raise an exception.");

	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[tree addObject:anObject];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree removeObject:@"Z"]; // doesn't exist, shouldn't change the tree/count
	STAssertEquals([tree count], [objects count], @"Incorrect count.");

	[tree removeObject:@"J"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",
			   @"I",@"M",@"O",@"G",@"K",nil];
	STAssertFalse([order containsObject:@"J"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)14, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)14, @"Incorrect count.");
	
	[tree removeObject:@"N"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"H",@"A",@"D",@"F",@"L",@"B",@"G",
			   @"I",@"M",@"K",@"O",nil];
	STAssertFalse([order containsObject:@"N"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)13, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)13, @"Incorrect count.");
	
	[tree removeObject:@"H"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"I",@"A",@"D",@"F",@"L",@"B",@"G",
			   @"K",@"M",@"O",nil];
	STAssertFalse([order containsObject:@"H"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)12, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)12, @"Incorrect count.");
	
	[tree removeObject:@"D"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"B",@"I",@"A",@"C",@"F",@"L",@"G",@"K",
			   @"M",@"O",nil];
	STAssertFalse([order containsObject:@"D"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)11, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)11, @"Incorrect count.");
	
	[tree removeObject:@"C"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"L",@"A",@"F",@"K",@"M",@"B",@"G",
			   @"O",nil];
	STAssertFalse([order containsObject:@"C"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)10, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)10, @"Incorrect count.");
	
	[tree removeObject:@"K"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"M",@"A",@"F",@"L",@"O",@"B",@"G",
			   nil];
	STAssertFalse([order containsObject:@"K"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)9, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)9, @"Incorrect count.");
	
	[tree removeObject:@"M"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"A",@"I",@"B",@"F",@"L",@"G",@"O",nil];
	STAssertFalse([order containsObject:@"M"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)8, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)8, @"Incorrect count.");
	
	[tree removeObject:@"B"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"A",@"I",@"F",@"L",@"G",@"O",nil];
	STAssertFalse([order containsObject:@"B"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)7, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)7, @"Incorrect count.");
	
	[tree removeObject:@"A"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"F",@"E",@"I",@"G",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"A"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)6, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)6, @"Incorrect count.");
	
	[tree removeObject:@"G"];
	correct = [NSArray arrayWithObjects:@"F",@"E",@"L",@"I",@"O",nil];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	STAssertFalse([order containsObject:@"G"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)5, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)5, @"Incorrect count.");
	
	[tree removeObject:@"E"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"I",@"F",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"E"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)4, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)4, @"Incorrect count.");
	
	[tree removeObject:@"F"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"L",@"I",@"O",nil];
	STAssertFalse([order containsObject:@"F"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)3, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)3, @"Incorrect count.");
	
	[tree removeObject:@"L"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"I",@"O",nil];
	STAssertFalse([order containsObject:@"L"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)2, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)2, @"Incorrect count.");
	
	[tree removeObject:@"I"];
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"O",nil];
	STAssertFalse([order containsObject:@"I"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(@"Level order", order, correct));
	STAssertEquals([order count], (NSUInteger)1, @"Incorrect count.");
	STAssertEquals([tree count],  (NSUInteger)1, @"Incorrect count.");
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->level = 1;
	STAssertEqualObjects([tree debugDescriptionForNode:node],
						 @"[1]\t\"A B C\"", nil);
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->level = 1;
	STAssertEqualObjects([tree dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n1\"];\n", nil);
	free(node);
}

@end
