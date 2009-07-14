/*
 CHDataStructures.framework -- CHAbstractBinarySearchTreeTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractBinarySearchTree.h"

#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHRedBlackTree.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

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

@interface CHAbstractBinarySearchTree (Test)

- (id) headerObject;

@end

@implementation CHAbstractBinarySearchTree (Test)

- (id) headerObject {
	return header->object;
}

@end

#pragma mark -

@interface CHAbstractBinarySearchTreeTest : SenTestCase
{
	CHAbstractBinarySearchTree *emptyTree, *insideTree, *outsideTree, *zigzagTree;
	NSArray *nonEmptyTrees, *objects, *correct, *actual, *treeClasses;
	NSEnumerator *e;
	id anObject;
}

@end

@implementation CHAbstractBinarySearchTreeTest

- (void) setUp {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil];

	// Rather than creating our own -addObject: method, we use CHUnbalancedTree.
	emptyTree = [[CHUnbalancedTree alloc] init];
	outsideTree = [[CHUnbalancedTree alloc] initWithArray:
				   [NSArray arrayWithObjects:@"C",@"B",@"A",@"D",@"E",nil]];
	insideTree = [[CHUnbalancedTree alloc] initWithArray:
				  [NSArray arrayWithObjects:@"C",@"A",@"B",@"E",@"D",nil]];
	zigzagTree = [[CHUnbalancedTree alloc] initWithArray:
				  [NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil]];
	nonEmptyTrees = [[NSArray alloc] initWithObjects:outsideTree, insideTree,
					 zigzagTree, nil];
	treeClasses = [NSArray arrayWithObjects:
				   [CHAnderssonTree class],
				   [CHAVLTree class],
				   [CHRedBlackTree class],
				   [CHTreap class],
				   [CHUnbalancedTree class],
				   nil];
}

- (void) tearDown {
	[emptyTree release];
	[nonEmptyTrees release];
}

- (void) testAllObjectsWithTraversalOrder {
	// Also tests -objectEnumeratorWithTraversalOrder:
	
	// Test forward ordering for all arrays
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		actual = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
		STAssertTrue([actual isEqualToArray:correct],
					 badOrder(@"Ascending order", actual, correct));
	}
	
	// Test reverse ordering for all arrays
	correct = [NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil];
	trees = [nonEmptyTrees objectEnumerator];
	while (tree = [trees nextObject]) {
		actual = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
		STAssertTrue([actual isEqualToArray:correct],
					 badOrder(@"Descending order", actual, correct));
	}	
	
	// Test pre-order by individual tree
	correct = [NSArray arrayWithObjects:@"C",@"B",@"A",@"D",@"E",nil];
	actual = [outsideTree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Pre-order", actual, correct));
	correct = [NSArray arrayWithObjects:@"C",@"A",@"B",@"E",@"D",nil];
	actual = [insideTree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Pre-order", actual, correct));
	correct = [NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil];
	actual = [zigzagTree allObjectsWithTraversalOrder:CHTraversePreOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Pre-order", actual, correct));
	
	// Test post-order by individual tree
	correct = [NSArray arrayWithObjects:@"A",@"B",@"E",@"D",@"C",nil];
	actual = [outsideTree allObjectsWithTraversalOrder:CHTraversePostOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Post-order", actual, correct));
	correct = [NSArray arrayWithObjects:@"B",@"A",@"D",@"E",@"C",nil];
	actual = [insideTree allObjectsWithTraversalOrder:CHTraversePostOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Post-order", actual, correct));
	correct = [NSArray arrayWithObjects:@"C",@"D",@"B",@"E",@"A",nil];
	actual = [zigzagTree allObjectsWithTraversalOrder:CHTraversePostOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Post-order", actual, correct));
	
	// Test level-order by individual tree
	correct = [NSArray arrayWithObjects:@"C",@"B",@"D",@"A",@"E",nil];
	actual = [outsideTree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Level-order", actual, correct));
	correct = [NSArray arrayWithObjects:@"C",@"A",@"E",@"B",@"D",nil];
	actual = [insideTree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Level-order", actual, correct));
	correct = [NSArray arrayWithObjects:@"A",@"E",@"B",@"D",@"C",nil];
	actual = [zigzagTree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	STAssertTrue([actual isEqualToArray:correct],
	             badOrder(@"Level-order", actual, correct));
}

- (void) testContainsObject {
	STAssertNoThrow([emptyTree containsObject:nil], @"Should not raise exception.");
	STAssertFalse([emptyTree containsObject:nil], @"Should return NO for nil.");
	e = [objects objectEnumerator];
	while (anObject =[e nextObject])
		STAssertFalse([emptyTree containsObject:anObject], @"Should return NO.");
	STAssertNoThrow([emptyTree containsObject:@"Z"],
					@"Should not raise an exception.");
	STAssertFalse([emptyTree containsObject:@"Z"], @"Should return NO");
	
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertNoThrow([tree containsObject:nil], @"Should not raise exception.");	
		STAssertFalse([tree containsObject:nil], @"Should return NO for nil.");
		e = [correct objectEnumerator];
		while (anObject = [e nextObject])
			STAssertTrue([tree containsObject:anObject], @"Should return YES");
		STAssertNoThrow([tree containsObject:@"Z"],
						@"Should not raise an exception.");
		STAssertFalse([tree containsObject:@"Z"], @"Should return NO");
	}
}

- (void) testDescription {
	STAssertEqualObjects([zigzagTree description],
						 [[zigzagTree allObjects] description],
						 @"-description returns incorrect string.");
}

- (void) testDebugDescription {
	NSMutableString *expected = [NSMutableString string];
	[expected appendFormat:@"<CHUnbalancedTree: 0x%x> = {\n", zigzagTree];
	[expected appendString:@"\t\"A\" -> \"(null)\" and \"E\"\n"];
	[expected appendString:@"\t\"E\" -> \"B\" and \"(null)\"\n"];
	[expected appendString:@"\t\"B\" -> \"(null)\" and \"D\"\n"];
	[expected appendString:@"\t\"D\" -> \"C\" and \"(null)\"\n"];
	[expected appendString:@"\t\"C\" -> \"(null)\" and \"(null)\"\n"];
	[expected appendString:@"}"];
	
	STAssertEqualObjects([zigzagTree debugDescription], expected,
						 @"Wrong string from -debugDescription.");
}

- (void) testDotGraphString {
	NSMutableString *expected = [NSMutableString string];
	[expected appendString:@"digraph CHUnbalancedTree\n{\n"];
	[expected appendFormat:@"  \"A\";\n  \"A\" -> {nil1;\"E\"};\n"];
	[expected appendFormat:@"  \"E\";\n  \"E\" -> {\"B\";nil2};\n"];
	[expected appendFormat:@"  \"B\";\n  \"B\" -> {nil3;\"D\"};\n"];
	[expected appendFormat:@"  \"D\";\n  \"D\" -> {\"C\";nil4};\n"];
	[expected appendFormat:@"  \"C\";\n  \"C\" -> {nil5;nil6};\n"];
	for (int i = 1; i <= 6; i++)
		[expected appendFormat:@"  nil%d [shape=point,fillcolor=black];\n", i];
	[expected appendFormat:@"}\n"];
	
	STAssertEqualObjects([zigzagTree dotGraphString], expected,
						 @"Incorrect DOT graph string for tree.");
	
	// Test for empty tree
	CHUnbalancedTree *tree = [[CHUnbalancedTree alloc] init];
	STAssertEqualObjects([tree dotGraphString],
						 @"digraph CHUnbalancedTree\n{\n  nil;\n}\n",
						 @"Incorrect DOT graph string for empty tree.");
}

- (void) testIsEqualToSearchTree {
	NSMutableArray *emptyTrees = [NSMutableArray array];
	NSMutableArray *equalTrees = [NSMutableArray array];
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyTrees addObject:[[aClass alloc] init]];
		[equalTrees addObject:[[aClass alloc] initWithArray:objects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalTrees addObject:[equalTrees objectAtIndex:0]];
	
	id<CHSearchTree> tree1, tree2;
	for (NSUInteger i = 0; i < [treeClasses count]; i++) {
		tree1 = [equalTrees objectAtIndex:i];
		tree2 = [emptyTrees objectAtIndex:i];
		STAssertFalse([tree1 isEqualToSearchTree:tree2], @"Should not be equal.");
		tree2 = [equalTrees objectAtIndex:i+1];
		STAssertTrue([tree1 isEqualToSearchTree:tree2],       @"Should be equal.");
		STAssertTrue([tree1 isEqualToSearchTree:insideTree],  @"Should be equal.");
		STAssertTrue([tree1 isEqualToSearchTree:outsideTree], @"Should be equal.");
		STAssertTrue([tree1 isEqualToSearchTree:zigzagTree],  @"Should be equal.");
		STAssertEquals([tree1 hash], [tree2 hash],       @"Hashes should match.");
		STAssertEquals([tree1 hash], [insideTree hash],  @"Hashes should match.");
		STAssertEquals([tree1 hash], [outsideTree hash], @"Hashes should match.");
		STAssertEquals([tree1 hash], [zigzagTree hash],  @"Hashes should match.");
	}
	STAssertFalse([tree1 isEqualToSearchTree:[NSArray array]], @"Should not be equal.");
	STAssertThrows([tree1 isEqualToSearchTree:[NSString string]], @"Should raise exception.");
}

#pragma mark -

- (void) testAddObject {
	id<CHSearchTree> tree = [[CHAbstractBinarySearchTree alloc] init];
	STAssertThrows([tree addObject:nil],
				   @"Should raise exception, abstract.");
}

- (void) testRemoveObject {
	id<CHSearchTree> tree = [[CHAbstractBinarySearchTree alloc] init];
	STAssertThrows([tree removeObject:nil],
				   @"Should raise exception, abstract.");
}

- (void) testHeaderObject {
	id tree = [[[CHAbstractBinarySearchTree alloc] init] autorelease];
	id headerObject = [tree headerObject];
	STAssertNotNil(headerObject, @"Header object should not be nil.");
	if (kCHGarbageCollectionNotEnabled) {
		STAssertThrows([headerObject retain],
					   @"Should raise exception, unsupported.");
		STAssertThrows([headerObject release],
					   @"Should raise exception, unsupported.");
		STAssertThrows([headerObject autorelease],
					   @"Should raise exception, unsupported.");
			
	}
}

@end
