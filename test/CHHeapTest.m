//
//  CHMutableArrayHeapTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHBinaryHeap.h>
#import <CHDataStructures/CHMutableArrayHeap.h>
#import "NSObject+TestUtilities.h"

@interface CHMutableArrayHeap (Test)

- (BOOL)isValid;

@end

@implementation CHMutableArrayHeap (Test)

- (BOOL)isValid {
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

@interface CHBinaryHeap (Debug)

- (NSString *)debugDescription; // Declare here to prevent compiler warnings.

@end

@interface CHBinaryHeap (Test)

- (BOOL)isValid;

@end

@implementation CHBinaryHeap (Test)

- (BOOL)isValid {
	return YES; // We assume that CFBinaryHeap is correct... ;-)
}
@end

#pragma mark -

@interface CHHeapTest : XCTestCase {
	id heap; // Removed protocol type <CHHeap> to prevent warnings for -isValid.
	NSArray *objects, *heapClasses;
}
@end

@implementation CHHeapTest

- (void)setUp {
	heapClasses = @[
		[CHMutableArrayHeap class],
		[CHBinaryHeap class],
	];
	objects = @[@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A"];
}


#pragma mark -

- (void)testNSCoding {
	NSInteger sortOrder = NSOrderedDescending; // Switches to ascending first.
	do {
		sortOrder *= -1;
		for (Class aClass in heapClasses) {
			heap = [[[aClass alloc] initWithOrdering:sortOrder] autorelease];
			for (id anObject in objects) {
				[heap addObject:anObject];
			}
			XCTAssertEqual([heap count], 9);
			XCTAssertTrue([heap isValid]);
			
			heap = [heap copyUsingNSCoding];
			
			XCTAssertEqual([heap count], 9);
			XCTAssertTrue([heap isValid]);
		}
	} while (sortOrder != NSOrderedDescending);
}

- (void)testNSCopying {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		id heap2 = [[heap copy] autorelease];
		XCTAssertNotNil(heap2);
		XCTAssertEqual([heap2 count], 9);
		XCTAssertEqual([heap hash], [heap2 hash]);
		XCTAssertEqualObjects([heap allObjects], [heap2 allObjects]);
	}
}

- (void)testNSFastEnumeration {
	NSUInteger limit = 32;
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		for (NSUInteger number = 1; number <= limit; number++) {
			[heap addObject:@(number)];
		}
		NSUInteger expected = 0, count = 0;
		for (NSNumber *number in heap) {
			XCTAssertEqual([number unsignedIntegerValue], ++expected);
			count++;
		}
		XCTAssertEqual(count, limit);
		
		@try {
			for (NSNumber *number in heap) {
				[heap addObject:number];
			}
			XCTFail(@"Expected an exception for mutating during enumeration.");
		}
		@catch (NSException * e) {
		}
	}
}

#pragma mark -

- (void)testInitWithArray {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] initWithArray:objects] autorelease];
		XCTAssertEqual([heap count], [objects count]);
		XCTAssertEqual([[heap allObjects] count], [objects count]);
	}
}

- (void)testInitWithCapacity {
	for (Class aClass in heapClasses) {
		if ([aClass instancesRespondToSelector:@selector(initWithCapacity:)]) {
			heap = [[[aClass alloc] initWithCapacity:42] autorelease];
			XCTAssertEqual([heap count], 0);
			[heap addObject:@(42)];
			XCTAssertEqual([heap count], 1);
		}
	}
}

- (void)testInvalidInit {
	for (Class aClass in heapClasses) {
		// Test for invalid ordering
		XCTAssertThrows([[aClass alloc] initWithOrdering:0]);
	}
}

- (void)testAddObject {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([heap addObject:nil]);
		XCTAssertEqual([heap count], 0);
		for (id anObject in objects) {
			[heap addObject:anObject];
			XCTAssertTrue([heap isValid]);
		}
		XCTAssertEqual([heap count], [objects count]);
	}
}

- (void)testAddObjectsFromArray {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		XCTAssertNoThrow([heap addObjectsFromArray:nil]);
		XCTAssertNoThrow([heap addObjectsFromArray:@[]]);
		XCTAssertEqual([heap count], 0);
		[heap addObjectsFromArray:objects];
		XCTAssertTrue([heap isValid]);
		XCTAssertEqual([heap count], [objects count]);
	}
}

- (void)testContainsObject {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		for (id anObject in objects) {
			XCTAssertFalse([heap containsObject:anObject]);
		}
		[heap addObjectsFromArray:objects];
		for (id anObject in objects) {
			XCTAssertTrue([heap containsObject:anObject]);
		}
		XCTAssertFalse([heap containsObject:@"bogus"]);
	}
}

- (void)testContainsObjectIdenticalTo {
	for (Class aClass in heapClasses) {
		if (![aClass instancesRespondToSelector:@selector(containsObjectIdenticalTo:)]) {
			continue;
		}
		heap = [[[aClass alloc] initWithArray:objects] autorelease];
		for (id anObject in objects) {
			NSString *clone = [NSString stringWithFormat:@"%@", anObject];
			XCTAssertTrue([heap containsObjectIdenticalTo:anObject]);
			XCTAssertFalse([heap containsObjectIdenticalTo:clone]);
		}
		XCTAssertFalse([heap containsObjectIdenticalTo:@"bogus"]);
	}
}

- (void)testCount {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		XCTAssertEqual([heap count], 0);
		[heap addObject:@"A"];
		XCTAssertEqual([heap count], 1);
	}
}

- (void)testDebugDescription {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		XCTAssertNotNil([heap debugDescription]);
		[heap addObject:@"A"];
		XCTAssertNotNil([heap debugDescription]);
	}
}

- (void)testDescription {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		XCTAssertNotNil([heap description]);
		[heap addObject:@"A"];
		XCTAssertNotNil([heap description]);
	}
}

- (void)testFirstObject {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		XCTAssertEqualObjects([heap firstObject], @"A");
	}
}

- (void)testInsertObjectAtIndex {
	for (Class aClass in heapClasses) {
		if (![aClass instancesRespondToSelector:@selector(insertObject:atIndex:)]) {
			continue;
		}
		heap = [[[aClass alloc] init] autorelease];
		// This is an unsupported operation and always throws.
		XCTAssertThrows([heap insertObject:nil atIndex:0]);
		XCTAssertThrows([heap insertObject:@"A" atIndex:0]);
	}
}

- (void)testIsEqualToHeap {
	NSMutableArray *emptyHeaps = [NSMutableArray array];
	NSMutableArray *equalHeaps = [NSMutableArray array];
	NSMutableArray *reversedHeaps = [NSMutableArray array];
	for (Class aClass in heapClasses) {
		[emptyHeaps addObject:[[[aClass alloc] init] autorelease]];
		[equalHeaps addObject:[[[aClass alloc] initWithOrdering:-1 array:objects] autorelease]];
		[reversedHeaps addObject:[[[aClass alloc] initWithOrdering:1 array:objects] autorelease]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalHeaps addObject:[equalHeaps objectAtIndex:0]];
	
	id<CHHeap> heap1, heap2;
	for (NSUInteger i = 0; i < [heapClasses count]; i++) {
		heap1 = [equalHeaps objectAtIndex:i];
		XCTAssertThrowsSpecificNamed([heap1 isEqualToHeap:(id)[NSString string]], NSException, NSInvalidArgumentException);
		XCTAssertFalse([heap1 isEqual:[NSString string]]);
		XCTAssertEqualObjects(heap1, heap1);
		heap2 = [emptyHeaps objectAtIndex:i];
		XCTAssertFalse([heap1 isEqualToHeap:heap2]);
		heap2 = [reversedHeaps objectAtIndex:i];
		XCTAssertFalse([heap1 isEqualToHeap:heap2]);
		heap2 = [equalHeaps objectAtIndex:i+1];
		XCTAssertEqualObjects(heap1, heap2);
		XCTAssertEqual([heap1 hash], [heap2 hash]);
	}
}

- (void)testRemoveFirstObject {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		
		id lastObject = nil;
		NSUInteger count = [heap count];
		id anObject;
		while ((anObject = [heap firstObject])) {
			if (lastObject) {
				XCTAssertEqual([lastObject compare:anObject], NSOrderedAscending);
			}
			lastObject = anObject;
			[heap removeFirstObject];
			XCTAssertEqual([heap count], --count);	
			XCTAssertTrue([heap isValid]);
		}
		
		XCTAssertNoThrow([heap removeFirstObject]);
	}
}

- (void)testRemoveObject {
	for (Class aClass in heapClasses) {
		if (![aClass instancesRespondToSelector:@selector(removeObject:)]) {
			continue;
		}
		heap = [[[aClass alloc] init] autorelease];
		[heap removeObject:@"bogus"];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		for (id anObject in objects) {
			XCTAssertEqual([heap count], expected);
			[heap removeObject:anObject];
			expected -= 2;
			XCTAssertEqual([heap count], expected);
			XCTAssertTrue([heap isValid]);
		}
	}
}

- (void)testRemoveObjectAtIndex {
	for (Class aClass in heapClasses) {
		if (![aClass instancesRespondToSelector:@selector(removeObjectAtIndex:)]) {
			continue;
		}
		heap = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([heap removeObjectAtIndex:0]);
	}
}

- (void)testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	for (Class aClass in heapClasses) {
		if (![aClass instancesRespondToSelector:@selector(removeObjectIdenticalTo:)]) {
			continue;
		}
		heap = [[[aClass alloc] init] autorelease];
		[heap removeObjectIdenticalTo:@"bogus"];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		XCTAssertEqual([heap count], expected);
		[heap removeObjectIdenticalTo:a];
		XCTAssertEqual([heap count], expected);
		for (id anObject in objects) {
			XCTAssertEqual([heap count], expected);
			[heap removeObjectIdenticalTo:anObject];
			expected -= 2;
			XCTAssertEqual([heap count], expected);
			XCTAssertTrue([heap isValid]);
		}
	}
}

- (void)testRemoveAllObjects {
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		XCTAssertEqual([heap count], 9);
		[heap removeAllObjects];
		XCTAssertEqual([heap count], 0);
	}
}

- (void)testObjectEnumerator {
	NSArray *allObjects;
	
	NSEnumerator *e;
	for (Class aClass in heapClasses) {
		heap = [[[aClass alloc] init] autorelease];
		e = [heap objectEnumerator];
		XCTAssertNotNil(e);
		XCTAssertNil([e nextObject]);
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		XCTAssertNotNil(allObjects);
		XCTAssertEqual([allObjects count], 0);
		
		[heap addObjectsFromArray:objects];
		e = [heap objectEnumerator];
		XCTAssertNotNil(e);
		XCTAssertNotNil([e nextObject]);
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		XCTAssertNotNil(allObjects);
		XCTAssertEqual([allObjects count], [objects count]);
	}
}

@end
