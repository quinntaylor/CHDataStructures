/*
 CHAnderssonTreeTest.m
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
#import "CHAnderssonTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSArray *order, NSArray *correctOrder) {
	return [[[NSString stringWithFormat:@"Should be %@, not %@", correctOrder, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			 stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHAnderssonTreeTest : SenTestCase {
	CHAnderssonTree *tree;
	NSArray *objects;
	NSArray *order, *correct;
}
@end

@implementation CHAnderssonTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
	tree = [[CHAnderssonTree alloc] init];
	objects = [NSArray arrayWithObjects:@"B",@"N",@"C",@"L",@"D",@"J",@"E",
				 @"H",@"K",@"M",@"O",@"G",@"A",@"I",@"F",nil];
	// Creates the tree from: Weiss pg. 645
}

- (void) tearDown {
	[tree release];
}

#pragma mark -

- (void) testNSCoding {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]
			 allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",
			   @"F",@"J",@"M",@"O",@"G",@"I",@"K",nil];
	STAssertEqualObjects(order, correct, @"Wrong ordering before archiving.");
	
	NSString *filePath = @"/tmp/tree.archive";
	[NSKeyedArchiver archiveRootObject:tree toFile:filePath];
	[tree release];
	
	tree = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]
			 allObjects];
	STAssertEqualObjects(order, correct, @"Wrong ordering on reconstruction.");
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
	expected = 1;
	for (NSNumber *object in tree) {
		STAssertEquals([object unsignedIntegerValue], expected++,
		               @"Objects should be enumerated in ascending order.");
		count++;
	}
	STAssertEquals(count, 32u, @"Count of enumerated items is incorrect.");
}

#pragma mark -

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
}

- (void) testContainsObject {
	for (id object in objects)
		[tree addObject:object];
	STAssertTrue([tree containsObject:@"A"], @"-containsObject should be true.");
	STAssertFalse([tree containsObject:@"Z"], @"-containsObject should be true.");
	STAssertFalse([tree containsObject:nil], @"Should not raise an exception.");	
}

- (void) testFindMin {
	STAssertNil([tree findMin], @"-findMin should return nil for empty tree.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findMin], @"A", @"-findMin is incorrect.");
}

- (void) testFindMax {
	STAssertNil([tree findMax], @"-findMax should return nil for empty tree.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findMax], @"O", @"-findMax is incorrect.");
}

- (void) testFindObject {
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

- (void) testTraversalInOrder {
	for (id object in objects)
		[tree addObject:object];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
					@"I",@"J",@"K",@"L",@"M",@"N",@"O",nil];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder] allObjects];	
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalReverseOrder {
	for (id object in objects)
		[tree addObject:object];
	correct = [NSArray arrayWithObjects:@"O",@"N",@"M",@"L",@"K",@"J",@"I",@"H",
					@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder] allObjects];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPreOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"E",@"C",@"A",@"B",@"D",@"L",@"H",@"F",
					@"G",@"J",@"I",@"K",@"N",@"M",@"O",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPostOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"B",@"A",@"D",@"C",@"G",@"F",@"I",@"K",
					@"J",@"H",@"M",@"O",@"N",@"L",@"E",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalLevelOrder {
	for (id object in objects)
		[tree addObject:object];

	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",
					@"F",@"J",@"M",@"O",@"G",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testRemoveObject {
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");

	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeObject:@"Z"]; // doesn't exist, shouldn't change the tree/count
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");

	[tree removeObject:@"J"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"L",@"A",@"D",@"H",@"N",@"B",@"F",
			   @"I",@"M",@"O",@"G",@"K",nil];
	STAssertFalse([order containsObject:@"J"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 14u, @"-count is incorrect.");
	STAssertEquals([tree count],  14u, @"-count is incorrect.");
	
	[tree removeObject:@"N"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"H",@"A",@"D",@"F",@"L",@"B",@"G",
			   @"I",@"M",@"K",@"O",nil];
	STAssertFalse([order containsObject:@"N"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 13u, @"-count is incorrect.");
	STAssertEquals([tree count],  13u, @"-count is incorrect.");
	
	[tree removeObject:@"H"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"I",@"A",@"D",@"F",@"L",@"B",@"G",
			   @"K",@"M",@"O",nil];
	STAssertFalse([order containsObject:@"H"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 12u, @"-count is incorrect.");
	STAssertEquals([tree count],  12u, @"-count is incorrect.");
	
	[tree removeObject:@"D"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"B",@"I",@"A",@"C",@"F",@"L",@"G",@"K",
			   @"M",@"O",nil];
	STAssertFalse([order containsObject:@"D"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 11u, @"-count is incorrect.");
	STAssertEquals([tree count],  11u, @"-count is incorrect.");
	
	[tree removeObject:@"C"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"L",@"A",@"F",@"K",@"M",@"B",@"G",
			   @"O",nil];
	STAssertFalse([order containsObject:@"C"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 10u, @"-count is incorrect.");
	STAssertEquals([tree count],  10u, @"-count is incorrect.");
	
	[tree removeObject:@"K"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"E",@"M",@"A",@"F",@"L",@"O",@"B",@"G",
			   nil];
	STAssertFalse([order containsObject:@"K"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 9u, @"-count is incorrect.");
	STAssertEquals([tree count],  9u, @"-count is incorrect.");
	
	[tree removeObject:@"M"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"A",@"I",@"B",@"F",@"L",@"G",@"O",nil];
	STAssertFalse([order containsObject:@"M"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 8u, @"-count is incorrect.");
	STAssertEquals([tree count],  8u, @"-count is incorrect.");
	
	[tree removeObject:@"B"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"E",@"A",@"I",@"F",@"L",@"G",@"O",nil];
	STAssertFalse([order containsObject:@"B"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 7u, @"-count is incorrect.");
	STAssertEquals([tree count],  7u, @"-count is incorrect.");
	
	[tree removeObject:@"A"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"F",@"E",@"I",@"G",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"A"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 6u, @"-count is incorrect.");
	STAssertEquals([tree count],  6u, @"-count is incorrect.");
	
	[tree removeObject:@"G"];
	correct = [NSArray arrayWithObjects:@"F",@"E",@"L",@"I",@"O",nil];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	STAssertFalse([order containsObject:@"G"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 5u, @"-count is incorrect.");
	STAssertEquals([tree count],  5u, @"-count is incorrect.");
	
	[tree removeObject:@"E"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"F",@"L",@"O",nil];
	STAssertFalse([order containsObject:@"E"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 4u, @"-count is incorrect.");
	STAssertEquals([tree count],  4u, @"-count is incorrect.");
	
	[tree removeObject:@"F"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"L",@"I",@"O",nil];
	STAssertFalse([order containsObject:@"F"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 3u, @"-count is incorrect.");
	STAssertEquals([tree count],  3u, @"-count is incorrect.");
	
	[tree removeObject:@"L"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"O",nil];
	STAssertFalse([order containsObject:@"L"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 2u, @"-count is incorrect.");
	STAssertEquals([tree count],  2u, @"-count is incorrect.");
	
	[tree removeObject:@"I"];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"O",nil];
	STAssertFalse([order containsObject:@"I"], @"Object was not properly removed.");
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
	STAssertEquals([order count], 1u, @"-count is incorrect.");
	STAssertEquals([tree count],  1u, @"-count is incorrect.");
}

@end
