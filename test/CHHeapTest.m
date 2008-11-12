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

- (BOOL) isValid;

@end

@implementation CHMutableArrayHeap (Test)

- (BOOL) isValid {
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
		if (leftChild && [parent compare:leftChild] != NSOrderedAscending)
			return NO;
		if (rightChild && [parent compare:rightChild] != NSOrderedAscending)
			return NO;
		++parentIndex;
	}
	return YES;
}

@end

#pragma mark -

@interface CHHeapTest : SenTestCase {
	id<CHHeap> heap;
	NSArray *objects, *heapClasses;
}
@end

@implementation CHHeapTest

- (void) setUp {
	heapClasses = [NSArray arrayWithObjects:[CHMutableArrayHeap class], nil];
	objects = [NSArray arrayWithObjects:
			   @"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
}


#pragma mark -

- (void) testNSCoding {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		for (id anObject in objects)
			[heap addObject:anObject];
		STAssertEquals([heap count], 9u, @"-count is incorrect.");
		STAssertTrue([heap isValid], @"Wrong ordering before archiving.");
		
		NSString *filePath = @"/tmp/array-heap.archive";
		[NSKeyedArchiver archiveRootObject:heap toFile:filePath];
		[heap release];
		
		heap = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
		STAssertEquals([heap count], 9u, @"-count is incorrect.");
		STAssertTrue([heap isValid], @"Wrong ordering on reconstruction.");
		[heap release];
	}
}

- (void) testNSCopying {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		for (id anObject in objects)
			[heap addObject:anObject];
		CHAbstractMutableArrayCollection *heap2 = [heap copyWithZone:nil];
		STAssertNotNil(heap2, @"-copy should not return nil for valid heap.");
		STAssertEquals([heap2 count], 9u, @"-count is incorrect.");
		STAssertEqualObjects([heap allObjects], [heap2 allObjects], @"Unequal heaps.");
		[heap release];
		[heap2 release];
	}
}

- (void) testNSFastEnumeration {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		NSUInteger number, expected;
		for (number = 1; number <= 32; number++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:number]];
		expected = 1;
		for (NSNumber *object in heap)
			STAssertEquals([object unsignedIntegerValue], expected++,
						   @"Objects should be enumerated in ascending order.");
		// Check that a mutation exception is raised if the heap is modified
		BOOL raisedException = NO;
		@try {
			for (NSNumber *object in heap)
				[heap addObject:[NSNumber numberWithUnsignedInteger:NSUIntegerMax]];
		}
		@catch (NSException * e) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise a mutation exception.");
		[heap release];
	}
}

#pragma mark -

- (void) testInitWithArray {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] initWithArray:objects];
		// TODO: Test count, etc.
		[heap release];
	}
}

- (void) testInvalidInit {
	for (Class aClass in heapClasses)
		STAssertThrows([[[aClass alloc] autorelease] initWithOrdering:0],
					   @"Invalid ordering not correctly detected.");
}

- (void) testAddObject {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		STAssertThrows([heap addObject:nil], @"Should raise nilArgumentException.");
		
		STAssertEquals([heap count], 0u, @"-count is incorrect.");
		for (id anObject in objects) {
			[heap addObject:anObject];
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		STAssertEquals([heap count], 9u, @"-count is incorrect.");
		[heap release];
	}
}

- (void) testAddObjectsFromArray {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertTrue([heap isValid], @"Violation of heap property.");
		[heap release];
	}
}

- (void) testFirstObject {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertEqualObjects([heap firstObject], @"A", @"-firstObject returned bad value.");
		[heap release];
	}
}

- (void) testRemoveFirstObject {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		
		id object, lastObject = nil;
		NSUInteger count = [heap count];
		while (object = [heap firstObject]) {
			if (lastObject)
				STAssertEquals([lastObject compare:object], NSOrderedAscending,  @"Wrong ordering.");
			lastObject = object;
			[heap removeFirstObject];
			STAssertEquals([heap count], --count, @"-count is incorrect.");	
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		
		STAssertNoThrow([heap removeFirstObject],
						@"Should never raise an exception, even when empty.");
		[heap release];
	}
}

- (void) testRemoveObject {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		
		STAssertEquals([heap count], 9u, @"-count is incorrect.");
		[heap removeObject:@"F"];
		STAssertEquals([heap count], 8u, @"-count is incorrect.");
		STAssertTrue([heap isValid], @"Violation of heap property.");
		[heap release];
	}
}

- (void) testRemoveAllObjects {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertEquals([heap count], 9u, @"-count is incorrect.");
		[heap removeAllObjects];
		STAssertEquals([heap count], 0u, @"-count is incorrect.");
		[heap release];
	}
}

- (void) testObjectEnumerator {
	NSEnumerator *e;
	NSArray *allObjects;
	
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		e = [heap objectEnumerator];
		STAssertNotNil(e, @"-objectEnumerator should never return nil.");
		STAssertNil([e nextObject], @"-nextObject should return nil.");
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, @"-allObjects should not return nil.");
		STAssertEquals([allObjects count], 0u, @"-count is incorrect.");
		
		[heap addObjectsFromArray:objects];
		e = [heap objectEnumerator];
		STAssertNotNil(e, @"-objectEnumerator should never return nil.");
		STAssertNotNil([e nextObject], @"-nextObject should not return nil.");
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, @"-allObjects should not return nil.");
		STAssertEquals([allObjects count], [objects count], @"-count is incorrect.");
		[heap release];
	}
}

@end
