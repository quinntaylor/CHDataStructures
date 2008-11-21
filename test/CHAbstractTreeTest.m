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

#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHRedBlackTree.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

#pragma mark -

@interface CHAbstractTreeTest : SenTestCase
{
	CHAbstractTree *emptyTree, *insideTree, *outsideTree, *zigzagTree;
	NSArray *nonEmptyTrees, *objects, *correct, *actual, *treeClasses;
}

@end

@implementation CHAbstractTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

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
	for (id tree in nonEmptyTrees) {
		actual = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
		STAssertTrue([actual isEqualToArray:correct],
					 badOrder(@"Ascending order", actual, correct));
	}
	
	// Test reverse ordering for all arrays
	correct = [NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil];
	for (id tree in nonEmptyTrees) {
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
	STAssertFalse([emptyTree containsObject:nil], @"Should return NO for nil.");
	STAssertNoThrow([emptyTree containsObject:nil], @"Should not raise exception.");
	for (id anObject in objects)
		STAssertFalse([emptyTree containsObject:anObject], @"Should return NO.");
	STAssertNoThrow([emptyTree containsObject:@"Z"],
					@"Should not raise an exception.");
	STAssertFalse([emptyTree containsObject:@"Z"], @"Should return NO");
	
	for (id<CHTree> tree in nonEmptyTrees) {
		STAssertFalse([tree containsObject:nil], @"Should return NO for nil.");
		STAssertNoThrow([tree containsObject:nil], @"Should not raise exception.");	
		for (id anObject in correct)
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
	[expected appendFormat:@"  \"C\";\n  \"C\" -> {nil6;nil5};\n"];
	for (int i = 1; i <= 6; i++)
		[expected appendFormat:@"  nil%d [shape=point,color=red];\n", i];
	[expected appendFormat:@"}\n"];
	
	STAssertEqualObjects([zigzagTree dotGraphString], expected,
						 @"Incorrect DOT graph string for tree.");
}

- (void) testEmptyTree {
	for (Class aClass in treeClasses) {
		id<CHTree> tree = [[aClass alloc] init];
		STAssertEquals([tree count], 0u, @"Incorrect count.");
		[tree release];
	}
}

- (void) testFindMin {
	STAssertNoThrow([emptyTree findMin], @"Should not raise an exception.");
	STAssertNil([emptyTree findMin], @"Should return nil for empty tree.");
	
	for (id<CHTree> tree in nonEmptyTrees) {
		STAssertNoThrow([tree findMin], @"Should not raise an exception.");
		STAssertNotNil([tree findMin], @"Should not be nil for non-empty tree.");
		STAssertEqualObjects([tree findMin], @"A", @"Incorrect result.");
	}
}

- (void) testFindMax {
	STAssertNoThrow([emptyTree findMax], @"Should not raise an exception.");
	STAssertNil([emptyTree findMax], @"Should return nil for empty tree.");
	
	for (id<CHTree> tree in nonEmptyTrees) {
		STAssertNoThrow([tree findMax], @"Should not raise an exception.");
		STAssertNotNil([tree findMax], @"Should not be nil for non-empty tree.");
		STAssertEqualObjects([tree findMax], @"E", @"Incorrect result.");
	}
}

- (void) testFindObject {
	STAssertNoThrow([emptyTree findObject:nil], @"Should not raise an exception.");
	STAssertNil([emptyTree findObject:nil], @"Should return nil for empty tree.");	

	STAssertNoThrow([emptyTree findObject:@"A"], @"Should not raise an exception.");
	STAssertNil([emptyTree findObject:@"A"], @"Should return nil for empty tree.");	

	for (id<CHTree> tree in nonEmptyTrees) {
		STAssertNil([tree findObject:nil], @"Should return nil when given nil.");
		for (id anObject in objects)
			STAssertEqualObjects([tree findObject:anObject], anObject,
								 @"Bad matching object");
		STAssertNoThrow([tree findObject:@"@"],
						@"Should not raise an exception.");
		STAssertNil([tree findObject:@"Z"],
					@"Should return nil for value not in tree");
	}
}

- (void) testInitWithArray {
	for (Class aClass in treeClasses) {
		id<CHTree> tree = [[aClass alloc] initWithArray:objects];
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		[tree release];
	}
}

- (void) testObjectEnumerator {
	for (Class aClass in treeClasses) {
		id<CHTree> tree = [[aClass alloc] init];
	
		// Enumerator shouldn't retain collection if there are no objects
		if (gcDisabled)
			STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
		NSEnumerator *e = [tree objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (gcDisabled)
			STAssertEquals([tree retainCount], 1u, @"Should not retain collection");
		
		// Enumerator should retain collection when it has 1+ objects, release when 0
		for (id object in objects)
			[tree addObject:object];
		if (gcDisabled)
			STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
		e = [tree objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (gcDisabled)
			STAssertEquals([tree retainCount], 2u, @"Enumerator should retain collection");
		// Grab one object from the enumerator
		[e nextObject];
		if (gcDisabled)
			STAssertEquals([tree retainCount], 2u, @"Collection should still be retained.");
		// Empty the enumerator of all objects
		[e allObjects];
		if (gcDisabled)
			STAssertEquals([tree retainCount], 1u, @"Enumerator should release collection");
		
		// Test that enumerator releases on -dealloc
		NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
		if (gcDisabled)
			STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
		e = [tree objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (gcDisabled)
			STAssertEquals([tree retainCount], 2u, @"Enumerator should retain collection");
		[pool drain]; // Force deallocation of enumerator
		if (gcDisabled)
			STAssertEquals([tree retainCount], 1u, @"Enumerator should release collection");
		
		// Test mutation in the middle of enumeration
		e = [tree objectEnumerator];
		[tree addObject:@"Z"];
		STAssertThrows([e nextObject], @"Should raise mutation exception.");
		STAssertThrows([e allObjects], @"Should raise mutation exception.");
		BOOL raisedException = NO;
		@try {
			for (id object in tree)
				[tree addObject:@"123"];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise mutation exception.");
		
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

- (void) testReverseObjectEnumerator {
	for (Class aClass in treeClasses) {
		id<CHTree> tree = [[aClass alloc] initWithArray:objects];
	
		NSEnumerator *e = [tree reverseObjectEnumerator];
		for (id anObject in [NSArray arrayWithObjects:@"E",@"D",@"C",@"B",@"A",nil]) {
			STAssertEqualObjects([e nextObject], anObject, @"Bad ordering.");
		}
	}
}

- (void) testRemoveAllObjects {
	STAssertEquals([emptyTree count], 0u, @"Incorrect count.");
	[emptyTree removeAllObjects];
	STAssertEquals([emptyTree count], 0u, @"Incorrect count.");	
	
	for (id<CHTree> tree in nonEmptyTrees) {
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		[tree removeAllObjects];
		STAssertEquals([tree count], 0u, @"Incorrect count.");
	}
}

#pragma mark -

- (void) testNSCoding {
	id<CHTree> tree;
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	NSArray *before, *after;
	for (Class aClass in treeClasses) {
		tree = [[aClass alloc] initWithArray:objects];
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		before = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
		
		NSString *filePath = @"/tmp/tree.archive";
		[NSKeyedArchiver archiveRootObject:tree toFile:filePath];
		[tree release];
		
		tree = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
		STAssertEquals([tree count], [objects count], @"Incorrect count.");
		after = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
		if (aClass != [CHTreap class])
		STAssertEqualObjects(before, after,
							 badOrder(@"Bad order after decode", before, after));
		[tree release];
	}	
}

- (void) testNSCopying {
	id<CHTree> tree, copy;
	for (Class aClass in treeClasses) {
		tree = [[aClass alloc] init];
		copy = [tree copyWithZone:nil];
		STAssertNotNil(copy, @"-copy should not return nil for valid tree.");
		STAssertEquals([copy count], 0u, @"Incorrect count.");
		[copy release];

		for (id anObject in objects)
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

- (void) testNSFastEnumeration {
	id<CHTree> tree;
	NSUInteger limit = 32; // NSFastEnumeration asks for 16 objects at a time
	for (Class aClass in treeClasses) {
		tree = [[aClass alloc] init];
		NSUInteger number, expected, count = 0;
		for (number = 1; number <= limit; number++)
			[tree addObject:[NSNumber numberWithUnsignedInteger:number]];
		expected = 1;
		for (NSNumber *object in tree) {
			STAssertEquals([object unsignedIntegerValue], expected++,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, limit, @"Count of enumerated items is incorrect.");
		[tree release];
	}
}

#pragma mark -

- (void) testAddObject {
	id<CHTree> tree = [[CHAbstractTree alloc] init];
	STAssertThrows([tree addObject:nil],
				   @"Should raise exception, abstract.");
}

- (void) testRemoveObject {
	id<CHTree> tree = [[CHAbstractTree alloc] init];
	STAssertThrows([tree removeObject:nil],
				   @"Should raise exception, abstract.");
}

@end
