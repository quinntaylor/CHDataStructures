/*
 CHMutableArrayHeapTest.m
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
#import "CHMutableArrayHeap.h"

@interface CHMutableArrayHeap (Test)

- (NSArray*) array;
- (unsigned long) mutations;
- (NSComparisonResult) sortOrder;

@end

@implementation CHMutableArrayHeap (Test)

- (NSArray*) array {
	return array;
}

- (unsigned long) mutations {
	return mutations;
}

- (NSComparisonResult) sortOrder {
	return sortOrder;
}

@end

#pragma mark -

@interface CHMutableArrayHeapTest : SenTestCase {
	CHMutableArrayHeap *heap;
	NSArray *testArray;
}
@end

@implementation CHMutableArrayHeapTest

- (void) setUp {
	heap = [[CHMutableArrayHeap alloc] init];
	testArray = [NSArray arrayWithObjects:
						  @"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
}

- (void) tearDown {
	[heap release];
}

#pragma mark -

- (void) testNSCoding {
	for (id object in testArray)
		[heap addObject:object];
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
	NSArray *order = [heap array];
	NSArray *correct = [NSArray arrayWithObjects:
						@"A",@"B",@"D",@"C",@"G",@"H",@"E",@"I",@"F",nil];
	STAssertEqualObjects(order, correct, @"Wrong ordering before archiving.");
	
	NSString *filePath = @"/tmp/array-heap.archive";
	[NSKeyedArchiver archiveRootObject:heap toFile:filePath];
	[heap release];
	
	heap = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
	order = [heap array];
	STAssertEqualObjects(order, correct, @"Wrong ordering on reconstruction.");
}

- (void) testNSCopying {
	for (id object in testArray)
		[heap addObject:object];
	CHAbstractMutableArrayCollection *heap2 = [heap copy];
	STAssertNotNil(heap2, @"-copy should not return nil for valid heap.");
	STAssertEquals([heap2 count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([heap allObjects], [heap2 allObjects], @"Unequal heaps.");
	[heap2 release];
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected;
	for (number = 1; number <= 32; number++)
		[heap addObject:[NSNumber numberWithUnsignedInteger:number]];
	expected = 1;
	for (NSNumber *object in heap)
		STAssertEquals([object unsignedIntegerValue], expected++,
					   @"Objects should be enumerated in ascending order.");
}

#pragma mark -

- (void) verifyHeapProperty {
	NSArray *array = [heap array];
	NSComparisonResult order = [heap sortOrder];
	id parent, leftChild, rightChild;
	NSUInteger parentIndex = 0, leftIndex, rightIndex;
	NSUInteger arraySize = [array count];
	// Iterate from 0 to n/2-1 and check that children hold heap's sort order
	while (parentIndex < arraySize / 2) {
		leftIndex = parentIndex * 2 + 1;
		rightIndex = parentIndex * 2 + 2;
		parent = [array objectAtIndex:parentIndex];
		leftChild = (leftIndex < arraySize) ? [array objectAtIndex:leftIndex] : nil;
		rightChild = (rightIndex < arraySize) ? [array objectAtIndex:rightIndex] : nil;
		if (leftChild != nil)
			STAssertEquals([parent compare:leftChild], order,  @"Wrong ordering.");
		if (rightChild != nil)
			STAssertEquals([parent compare:rightChild], order,  @"Wrong ordering.");
		++parentIndex;
	}
}

#pragma mark -

- (void) testInit {
	[heap release];
	heap = [[CHMutableArrayHeap alloc] initWithArray:testArray];
}

- (void) testInvalidInit {
	STAssertThrows([[CHMutableArrayHeap alloc]
					initWithOrdering:0], @"Invalid ordering not detected.");
}

- (void) testAddObject {
	STAssertThrows([heap addObject:nil], @"Should raise nilArgumentException.");
	
	STAssertEquals([heap count], 0u, @"-count is incorrect.");
	for (id anObject in testArray) {
		[heap addObject:anObject];
		[self verifyHeapProperty];
	}
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
}

- (void) testAddObjectsFromArray {
	[heap addObjectsFromArray:testArray];
	[self verifyHeapProperty];
}

- (void) testFirstObject {
	[heap addObjectsFromArray:testArray];
	STAssertEqualObjects([heap firstObject], @"A", @"-firstObject returned bad value.");
}

- (void) testRemoveFirstObject {
	[heap addObjectsFromArray:testArray];

	NSComparisonResult order = [heap sortOrder];
	id object, lastObject = nil;
	NSUInteger count = [heap count];
	while (object = [heap firstObject]) {
		if (lastObject)
			STAssertEquals([lastObject compare:object], order,  @"Wrong ordering.");
		lastObject = object;
		[heap removeFirstObject];
		STAssertEquals([heap count], --count, @"-count is incorrect.");	
		[self verifyHeapProperty];
	}
	
	STAssertNoThrow([heap removeFirstObject],
					@"Should never raise an exception, even when empty.");
}

- (void) testRemoveObject {
	[heap addObjectsFromArray:testArray];
	
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
	[heap removeObject:@"F"];
	STAssertEquals([heap count], 8u, @"-count is incorrect.");
	[self verifyHeapProperty];
}

- (void) testRemoveAllObjects {
	[heap addObjectsFromArray:testArray];
	unsigned long mutations = [heap mutations];
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
	[heap removeAllObjects];
	STAssertEquals([heap count], 0u, @"-count is incorrect.");
	STAssertEquals([heap mutations], mutations+1, @"Mutations should increase.");
}

@end
