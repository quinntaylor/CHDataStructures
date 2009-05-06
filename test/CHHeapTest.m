/*
 CHDataStructures.framework -- CHMutableArrayHeapTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
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
		if (leftChild && [parent compare:leftChild] == -sortOrder) {
			return NO;
		}
		if (rightChild && [parent compare:rightChild] == -sortOrder) {
			return NO;
		}
		++parentIndex;
	}
	return YES;
}

@end

#pragma mark -

@interface CHHeapTest : SenTestCase {
	id heap; // Removed protocol type <CHHeap> to prevent warnings for -isValid.
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
		STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
		STAssertTrue([heap isValid], @"Wrong ordering before archiving.");
		
		NSString *filePath = @"/tmp/CHDataStructures-array-heap.plist";
		[NSKeyedArchiver archiveRootObject:heap toFile:filePath];
		[heap release];
		
		heap = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
		STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
		STAssertTrue([heap isValid], @"Wrong ordering on reconstruction.");
		[heap release];
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	}
}

- (void) testNSCopying {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		for (id anObject in objects)
			[heap addObject:anObject];
		CHAbstractMutableArrayCollection *heap2 = [heap copyWithZone:nil];
		STAssertNotNil(heap2, @"-copy should not return nil for valid heap.");
		STAssertEquals([heap2 count], (NSUInteger)9, @"Incorrect count.");
		STAssertEqualObjects([heap allObjects], [heap2 allObjects], @"Unequal heaps.");
		[heap release];
		[heap2 release];
	}
}

- (void) testNSFastEnumeration {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		NSUInteger number, expected, count = 0;
		for (number = 1; number <= 32; number++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:number]];
		expected = 1;
		for (NSNumber *object in heap) {
			STAssertEquals([object unsignedIntegerValue], expected++,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, (NSUInteger)32, @"Count of enumerated items is incorrect.");
		
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
		
		STAssertEquals([heap count], (NSUInteger)0, @"Incorrect count.");
		for (id anObject in objects) {
			[heap addObject:anObject];
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
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
				STAssertEquals([lastObject compare:object],
							   (NSComparisonResult)NSOrderedAscending,
							   @"Wrong ordering.");
			lastObject = object;
			[heap removeFirstObject];
			STAssertEquals([heap count], --count, @"Incorrect count.");	
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
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		for (id anObject in objects) {
			STAssertEquals([heap count], expected, @"Incorrect count.");
			[heap removeObject:anObject];
			expected -= 2;
			STAssertEquals([heap count], expected, @"Incorrect count.");
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		[heap release];
	}
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		STAssertEquals([heap count], expected, @"Incorrect count.");
		[heap removeObjectIdenticalTo:a];
		STAssertEquals([heap count], expected, @"Incorrect count.");
		for (id anObject in objects) {
			STAssertEquals([heap count], expected, @"Incorrect count.");
			[heap removeObjectIdenticalTo:anObject];
			expected -= 2;
			STAssertEquals([heap count], expected, @"Incorrect count.");
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		[heap release];
	}
}

- (void) testRemoveAllObjects {
	for (Class aClass in heapClasses) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
		[heap removeAllObjects];
		STAssertEquals([heap count], (NSUInteger)0, @"Incorrect count.");
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
		STAssertEquals([allObjects count], (NSUInteger)0, @"Incorrect count.");
		
		[heap addObjectsFromArray:objects];
		e = [heap objectEnumerator];
		STAssertNotNil(e, @"-objectEnumerator should never return nil.");
		STAssertNotNil([e nextObject], @"-nextObject should not return nil.");
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, @"-allObjects should not return nil.");
		STAssertEquals([allObjects count], [objects count], @"Incorrect count.");
		[heap release];
	}
}

@end
