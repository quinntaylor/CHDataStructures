/*
 CHDataStructures.framework -- CHAVLTreeTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAVLTree.h"

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
#if OBJC_API_2
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
	          traversal, correct, order]
	         stringByReplacingOccurrencesOfString:@"\n" withString:@""]
	        stringByReplacingOccurrencesOfString:@"    " withString:@""];
#else
	return [NSString stringWithFormat:@"%@ should be %@, was %@",
	        traversal, correct, order];
#endif
}

#pragma mark -

static BOOL validBalanceFactors;
static NSMutableString *balanceErrors;

@interface CHAVLTree (Test)

- (void) verifyBalanceFactors;
- (NSInteger) heightForSubtreeAtNode:(CHBinaryTreeNode*)node;

@end

@implementation CHAVLTree (Test)

- (void) verifyBalanceFactors {
	validBalanceFactors = YES;
	balanceErrors = [NSMutableString string];
	[self heightForSubtreeAtNode:header->right];
	
	if (!validBalanceFactors) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"Violation of AVL balance factors%@", balanceErrors];
	}
}

- (NSInteger) heightForSubtreeAtNode:(CHBinaryTreeNode*)node {
	if (node == sentinel)
		return 0;
	NSInteger leftHeight  = [self heightForSubtreeAtNode:node->left];
	NSInteger rightHeight = [self heightForSubtreeAtNode:node->right];
	if (node->balance != (rightHeight-leftHeight)) {
		[balanceErrors appendFormat:@". | At \"%@\" should be %ld, was %d",
		 node->object, (rightHeight-leftHeight), node->balance];
		validBalanceFactors = NO;
	}
	return ((leftHeight > rightHeight) ? leftHeight : rightHeight) + 1;
}

@end

#pragma mark -

@interface CHAVLTreeTest : SenTestCase {
	CHAVLTree *tree;
	NSArray *objects, *order, *correct;
	NSEnumerator *e;
	id anObject;
}
@end


@implementation CHAVLTreeTest

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
	
	STAssertEquals([tree count], (NSUInteger)0, @"Incorrect count.");
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[tree addObject:anObject];
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
	STAssertNoThrow([tree removeObject:nil], @"Should not raise an exception.");
	
	e = [objects objectEnumerator];
	while (anObject = [e nextObject])
		[tree addObject:anObject];
	NSEnumerator *enumerator = [objects objectEnumerator];
	
	NSUInteger expectedCount = [objects count];
	STAssertEquals([tree count], expectedCount, @"Incorrect count.");
	[tree removeObject:@"Z"]; // doesn't exist, shouldn't change the tree/count
	STAssertEquals([tree count], expectedCount, @"Incorrect count.");
	
	[tree removeObject:[enumerator nextObject]]; // B
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",
			   @"I",@"L",@"K",@"N",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // N
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"J",@"D",@"C",@"A",@"G",@"E",@"F",@"H",
			   @"I",@"L",@"K",@"O",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // C
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"J",@"G",@"D",@"A",@"E",@"F",@"H",@"I",
			   @"L",@"K",@"O",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // L
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"D",@"A",@"E",@"F",@"J",@"H",@"I",
			   @"M",@"K",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // D
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"J",@"H",@"I",@"M",
			   @"K",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // J
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"E",@"A",@"F",@"K",@"H",@"I",@"M",
			   @"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // E
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"F",@"A",@"K",@"H",@"I",@"M",@"O",
			   nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // H
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"F",@"A",@"K",@"I",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // K
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"F",@"A",@"M",@"I",@"O",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // M
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"F",@"A",@"O",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // O
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",@"F",@"A",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // G
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"A",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // A
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	
	[tree removeObject:[enumerator nextObject]]; // I
	--expectedCount;
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
	STAssertEquals([order count], expectedCount, @"Incorrect count.");
	STAssertEquals([tree count],  expectedCount, @"Incorrect count.");
	STAssertNoThrow([tree verifyBalanceFactors], nil);
}

- (void) testRemoveObjectDoubleLeft {
	objects = [NSArray arrayWithObjects:@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",
			   @"E",@"G",@"I",nil];
	[tree release];
	tree = [[CHAVLTree alloc] initWithArray:objects];
	
	[tree removeObject:@"A"];
	[tree removeObject:@"D"];
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	STAssertEquals([tree count], [objects count] - 2, @"Incorrect count.");	
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"C",@"B",@"E",@"J",@"H",@"G",@"I",
			   @"K",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
}

- (void) testRemoveObjectDoubleRight {
	objects = [NSArray arrayWithObjects:@"F",@"B",@"J",@"A",@"D",@"H",@"K",@"C",
			   @"E",@"G",@"I",nil];
	[tree release];
	tree = [[CHAVLTree alloc] initWithArray:objects];

	[tree removeObject:@"K"];
	[tree removeObject:@"G"];
	STAssertNoThrow([tree verifyBalanceFactors], nil);
	STAssertEquals([tree count], [objects count] - 2, @"Incorrect count.");	
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"I",@"H",
			   @"J",nil];
	STAssertTrue([order isEqualToArray:correct],
				 badOrder(@"Pre-order", order, correct));
}

- (void) testDebugDescriptionForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->balance = 0;
	STAssertEqualObjects([tree debugDescriptionForNode:node],
						 @"[ 0]\t\"A B C\"", nil);
	free(node);
}

- (void) testDotGraphStringForNode {
	CHBinaryTreeNode *node = malloc(sizeof(CHBinaryTreeNode));
	node->object = [NSString stringWithString:@"A B C"];
	node->balance = 0;
	STAssertEqualObjects([tree dotGraphStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n0\"];\n", nil);
	free(node);
}

@end
