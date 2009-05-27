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

	// Rather than creating our own tree insertion, we use CHUnbalancedTree
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
	[insideTree release];
	[outsideTree release];
	[zigzagTree release];
}

- (void) testAllObjects {
	STAssertEqualObjects([emptyTree allObjects], [NSArray array], @"bad order");
	STAssertEqualObjects([outsideTree allObjects], objects, @"bad order");
	STAssertEqualObjects([insideTree allObjects], objects, @"bad order");
	STAssertEqualObjects([zigzagTree allObjects], objects, @"bad order");
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

- (void) testAnyObject {
	STAssertNil([emptyTree anyObject], @"Should return nil");
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertNotNil([tree anyObject], @"Should return a non-nil object");
		[tree removeAllObjects];
		STAssertNil([tree anyObject], @"Should return nil");
	}
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

- (void) testEmptyTree {
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		id<CHSearchTree> tree = [[aClass alloc] init];
		STAssertEquals([tree count], (NSUInteger)0, @"Incorrect count.");
		[tree release];
	}
}

- (void) testFirstObject {
	STAssertNoThrow([emptyTree firstObject], @"Should not raise an exception.");
	STAssertNil([emptyTree firstObject], @"Should return nil for empty tree.");
	
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertNoThrow([tree firstObject], @"Should not raise an exception.");
		STAssertNotNil([tree firstObject], @"Should not be nil for non-empty tree.");
		STAssertEqualObjects([tree firstObject], @"A", @"Incorrect result.");
	}
}

- (void) testLastObject {
	STAssertNoThrow([emptyTree lastObject], @"Should not raise an exception.");
	STAssertNil([emptyTree lastObject], @"Should return nil for empty tree.");
	
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertNoThrow([tree lastObject], @"Should not raise an exception.");
		STAssertNotNil([tree lastObject], @"Should not be nil for non-empty tree.");
		STAssertEqualObjects([tree lastObject], @"E", @"Incorrect result.");
	}
}

- (void) testInitWithArray {
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		id<CHSearchTree> tree = [[aClass alloc] initWithArray:objects];
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		[tree release];
	}
}

- (void) testMember {
	STAssertNoThrow([emptyTree member:nil], @"Should not raise an exception.");
	STAssertNil([emptyTree member:nil], @"Should return nil for empty tree.");	

	STAssertNoThrow([emptyTree member:@"A"], @"Should not raise an exception.");
	STAssertNil([emptyTree member:@"A"], @"Should return nil for empty tree.");	

	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertNil([tree member:nil], @"Should return nil when given nil.");
		e = [objects objectEnumerator];
		while (anObject =[e nextObject])
			STAssertEqualObjects([tree member:anObject], anObject,
								 @"Bad matching object");
		STAssertNoThrow([tree member:@"@"],
						@"Should not raise an exception.");
		STAssertNil([tree member:@"Z"],
					@"Should return nil for value not in tree");
	}
}

- (void) testObjectEnumerator {
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		id<CHSearchTree> tree = [[aClass alloc] init];
	
		// Enumerator shouldn't retain collection if there are no objects
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [tree objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)1, @"Should not retain collection");
		
		// Enumerator should retain collection when it has 1+ objects, release when 0
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[tree addObject:anObject];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [tree objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		// Grab one object from the enumerator
		[e nextObject];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)2, @"Collection should still be retained.");
		// Empty the enumerator of all objects
		[e allObjects];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)1, @"Enumerator should release collection");
		
		// Test that enumerator releases on -dealloc
		NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [tree objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		[pool drain]; // Force deallocation of enumerator
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([tree retainCount], (NSUInteger)1, @"Enumerator should release collection");
		
		// Test mutation in the middle of enumeration
		e = [tree objectEnumerator];
		[tree addObject:@"Z"];
		STAssertThrows([e nextObject], @"Should raise mutation exception.");
		STAssertThrows([e allObjects], @"Should raise mutation exception.");
		
		// Test deallocation in the middle of enumeration
		pool  = [[NSAutoreleasePool alloc] init];
		e = [tree objectEnumerator];
		[e nextObject];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		
		pool  = [[NSAutoreleasePool alloc] init];
		e = [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
	}
}

- (void) testRemoveAllObjects {
	STAssertEquals([emptyTree count], (NSUInteger)0, @"Incorrect count.");
	[emptyTree removeAllObjects];
	STAssertEquals([emptyTree count], (NSUInteger)0, @"Incorrect count.");	
	
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		[tree removeAllObjects];
		STAssertEquals([tree count], (NSUInteger)0, @"Incorrect count.");
	}
}

- (void) testRemoveFirstObject {
	STAssertNoThrow([emptyTree removeFirstObject], @"Should not raise exception.");
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertEqualObjects([tree firstObject], @"A", @"Wrong first object.");
		STAssertNoThrow([tree removeFirstObject], @"Should not raise exception.");
		STAssertEqualObjects([tree firstObject], @"B", @"Wrong first object.");
	}
}

- (void) testRemoveLastObject {
	STAssertNoThrow([emptyTree removeLastObject], @"Should not raise exception.");
	NSEnumerator *trees = [nonEmptyTrees objectEnumerator];
	id<CHSearchTree> tree;
	while (tree = [trees nextObject]) {
		STAssertEqualObjects([tree lastObject], @"E", @"Wrong first object.");
		STAssertNoThrow([tree removeLastObject], @"Should not raise exception.");
		STAssertEqualObjects([tree lastObject], @"D", @"Wrong first object.");
	}
}

- (void) testReverseObjectEnumerator {
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		id<CHSearchTree> tree = [[aClass alloc] initWithArray:objects];
	
		NSEnumerator *reverse = [tree reverseObjectEnumerator];
		e = [[NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil] objectEnumerator];
		while (anObject =[e nextObject]) {
			STAssertEqualObjects([reverse nextObject], anObject, @"Bad ordering.");
		}
	}
}

- (void) testSet {
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	NSSet *set = [NSSet setWithArray:objects];
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		id<CHSearchTree> tree = [[aClass alloc] initWithArray:objects];
		STAssertEqualObjects([tree set], set, @"Unequal sets");
		[tree release];
	}
}

- (void) testSubsetFromObjectToObject {
	objects = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",@"G",nil];
	NSArray *subset, *expected;
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		id<CHSearchTree> tree = [[aClass alloc] initWithArray:objects];

		// Test including all objects (2 nil params, or match first and last)
		subset = [[tree subsetFromObject:nil toObject:nil] allObjects];
		STAssertTrue([subset isEqual:objects], badOrder(@"Subset", objects, subset));
		
		subset = [[tree subsetFromObject:@"A" toObject:@"G"] allObjects];
		STAssertTrue([subset isEqual:objects], badOrder(@"Subset", objects, subset));
		
		// Test excluding elements at the end
		expected = [NSArray arrayWithObjects:@"A",@"C",@"D",@"E",nil];
		
		subset = [[tree subsetFromObject:nil toObject:@"F"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		subset = [[tree subsetFromObject:nil toObject:@"E"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		
		subset = [[tree subsetFromObject:@"A" toObject:@"F"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		subset = [[tree subsetFromObject:@"A" toObject:@"E"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		
		// Test excluding elements at the start
		expected = [NSArray arrayWithObjects:@"C",@"D",@"E",@"G",nil];
		
		subset = [[tree subsetFromObject:@"B" toObject:nil] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		subset = [[tree subsetFromObject:@"C" toObject:nil] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));

		subset = [[tree subsetFromObject:@"B" toObject:@"G"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		subset = [[tree subsetFromObject:@"C" toObject:@"G"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		
		// Test excluding elements in the middle (parameters in reverse order)
		expected = [NSArray arrayWithObjects:@"A",@"C",@"E",@"G",nil];
		
		subset = [[tree subsetFromObject:@"E" toObject:@"C"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		
		expected = [NSArray arrayWithObjects:@"A",@"G",nil];
		
		subset = [[tree subsetFromObject:@"F" toObject:@"B"] allObjects];
		STAssertTrue([subset isEqual:expected], badOrder(@"Subset", expected, subset));
		
		[tree release];
	}
}

#pragma mark -

- (void) testNSCoding {
	id<CHSearchTree> tree;
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	NSArray *before, *after;
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		tree = [[aClass alloc] initWithArray:objects];
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		before = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
		
		NSString *filePath = @"/tmp/CHDataStructures-tree.plist";
		[NSKeyedArchiver archiveRootObject:tree toFile:filePath];
		[tree release];
		
		tree = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		after = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
		if (aClass != [CHTreap class])
		STAssertEqualObjects(before, after,
							 badOrder(@"Bad order after decode", before, after));
		[tree release];
		[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
	}	
}

- (void) testNSCopying {
	id<CHSearchTree> tree, copy;
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		tree = [[aClass alloc] init];
		copy = [tree copyWithZone:nil];
		STAssertNotNil(copy, @"-copy should not return nil for valid tree.");
		STAssertEquals([copy count], (NSUInteger)0, @"Incorrect count.");
		[copy release];

		e = [objects objectEnumerator];
		while (anObject =[e nextObject])
			[tree addObject:anObject];
		copy = [tree copyWithZone:nil];
		STAssertNotNil(copy, @"-copy should not return nil for valid tree.");
		STAssertEquals([copy count], [objects count], @"Incorrect count.");
		if (aClass != [CHTreap class])
		STAssertEqualObjects([tree allObjectsWithTraversalOrder:CHTraverseLevelOrder],
							 [copy allObjectsWithTraversalOrder:CHTraverseLevelOrder],
							 @"Unequal trees.");
		[tree release];
		[copy release];
	}
}

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (void) testNSFastEnumeration {
	id<CHSearchTree> tree;
	int limit = 32; // NSFastEnumeration asks for 16 objects at a time
	NSEnumerator *classes = [treeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		tree = [[aClass alloc] init];
		int number, expected, count = 0;
		for (number = 1; number <= limit; number++)
			[tree addObject:[NSNumber numberWithInt:number]];
		expected = 1;
		for (NSNumber *object in tree) {
			STAssertEquals([object intValue], expected++,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, limit, @"Count of enumerated items is incorrect.");
		
		BOOL raisedException = NO;
		@try {
			for (id object in tree)
				[tree addObject:@"123"];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise mutation exception.");
		
		[tree release];
	}
}
#endif

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

@end
