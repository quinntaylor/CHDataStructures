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

static BOOL gcDisabled;

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHRedBlackTreeTest : SenTestCase {
	CHRedBlackTree *tree;
	NSArray *objects, *order, *correct;
}
@end

@implementation CHRedBlackTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
	tree = [[CHRedBlackTree alloc] init];
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 631 
}

- (void) tearDown {
	[tree release];
}

#pragma mark -
/*
- (void) testNSCoding {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]
			 allObjects];
	STAssertEqualObjects(order, objects, @"Wrong ordering before archiving.");
	
	NSString *filePath = @"/tmp/tree.archive";
	[NSKeyedArchiver archiveRootObject:tree toFile:filePath];
	[tree release];
	
	tree = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]
			 allObjects];
	STAssertEqualObjects(order, objects, @"Wrong ordering on reconstruction.");
}

- (void) testNSCopying {
	for (id object in objects)
		[tree addObject:object];
	id<CHTree> tree2 = [tree copy];
	STAssertNotNil(tree2, @"-copy should not return nil for valid tree.");
	STAssertEquals([tree2 count], [objects count], @"-count is incorrect.");
	STAssertEqualObjects([tree allObjects], [tree2 allObjects], @"Unequal trees.");
	[tree2 release];
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected, count = 0;
	for (number = 1; number <= 32; number++)
		[tree addObject:[NSNumber numberWithUnsignedInteger:number]];
	STAssertEquals([tree count], 32u, @"-count is incorrect.");
	expected = 1;
	for (NSNumber *object in tree) {
		STAssertEquals([object unsignedIntegerValue], expected++,
		               @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, 32u, @"Count of enumerated items is incorrect.");
}

#pragma mark -
*/
- (void) testEmptyTree {
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];

	NSEnumerator *e = [objects objectEnumerator];
	NSUInteger count = 0;
	STAssertEquals([tree count], count, @"-count is incorrect.");
	
	[tree addObject:[e nextObject]]; // B
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"B",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // M
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"B",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // C
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // K
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"M",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // D
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // I
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // E
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"K",@"E",@"M",@"D",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // G
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // J
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	
	[tree addObject:[e nextObject]]; // L
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",@"L",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // N
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",@"L",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // F
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",@"L",@"N",@"F",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // A
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",
			   @"G",@"J",@"L",@"N",@"F",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	[tree addObject:[e nextObject]]; // H
	STAssertEquals([tree count], ++count, @"-count is incorrect.");
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",
			   @"G",@"J",@"L",@"N",@"F",@"H",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
}

- (void) testAddObjectsAscending {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",nil];
	for (id anObject in objects)
		[tree addObject:anObject];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"H",@"D",@"L",@"B",@"F",@"J",@"N",@"A",
			   @"C",@"E",@"G",@"I",@"K",@"M",@"P",@"O",@"Q",@"R",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
}

- (void) testAddObjectsDescending {
	objects = [NSArray arrayWithObjects:@"R",@"Q",@"P",@"O",@"N",@"M",@"L",@"K",
			   @"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	for (id anObject in objects)
		[tree addObject:anObject];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"K",@"G",@"O",@"E",@"I",@"M",@"Q",@"C",
			   @"F",@"H",@"J",@"L",@"N",@"P",@"R",@"B",@"D",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
}

- (void) testContainsObject {
	STAssertFalse([tree containsObject:@"A"], @"Should not contain any nodes.");
	for (id anObject in objects)
		[tree addObject:anObject];
	STAssertTrue([tree containsObject:@"A"], @"-containsObject should be true.");
	STAssertFalse([tree containsObject:@"Z"], @"-containsObject should be false.");
	STAssertNoThrow([tree containsObject:nil], @"Should not raise an exception.");
	STAssertFalse([tree containsObject:nil], @"-containsObject should be false.");	
}

- (void) testContentsAsArrayUsingTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseInOrder];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"CHTraverseInOrder", order, correct));
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseReverseOrder];
	correct = [NSArray arrayWithObjects:@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",
			   @"F",@"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"CHTraverseReverseOrder", order, correct));
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"B",@"A",@"D",@"K",@"I",@"G",
			   @"F",@"H",@"J",@"M",@"L",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"CHTraversePreOrder", order, correct));
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraversePostOrder];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"D",@"C",@"F",@"H",@"G",@"J",
			   @"I",@"L",@"N",@"M",@"K",@"E",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"CHTraversePostOrder", order, correct));
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",
			   @"G",@"J",@"L",@"N",@"F",@"H",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
}

- (void) testContentsAsSet {
	for (id object in objects)
		[tree addObject:object];
	NSSet *set = [tree contentsAsSet];
	STAssertEquals([set count], [objects count], @"-[NSSet count] is incorrect.");
	for (id anObject in objects)
		STAssertTrue([set containsObject:anObject], @"Should contain object.");
}

- (void) testFindMin {
	STAssertNoThrow([tree findMin], @"Should not raise an exception.");
	STAssertNil([tree findMin], @"-findMin should return nil for empty tree.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findMin], @"A", @"-findMin is incorrect.");
}

- (void) testFindMax {
	STAssertNoThrow([tree findMax], @"Should not raise an exception.");
	STAssertNil([tree findMax], @"-findMax should return nil for empty tree.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findMax], @"N", @"-findMax is incorrect.");	
}

- (void) testFindObject {
	STAssertNil([tree findObject:nil], @"Should return nil when given nil.");	
	STAssertNoThrow([tree findObject:@"A"], @"Should not raise an exception.");
	STAssertNil([tree findObject:@"A"], @"Should return nil when empty.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findObject:@"A"], @"A", @"Should exist and match.");
	STAssertNil([tree findObject:@"Z"], @"Should not be found in tree.");
}

- (void) testObjectEnumerator {
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

- (void) testRemoveObject {
	for (id object in objects)
		[tree addObject:object];

	// Test removing nil
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");
	
	// Test removing a node which doesn't occur in the tree
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
}

- (void) testRemoveAllObjects {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeAllObjects];
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
}

@end
