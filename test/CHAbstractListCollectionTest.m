//
//  CHAbstractListCollectionTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHAbstractListCollection.h>
#import <CHDataStructures/CHListDeque.h>
#import "NSObject+TestUtilities.h"

@implementation CHAbstractListCollection (Test)

- (void)addObject:(id)anObject {
	[list addObject:anObject];
}

- (void)addObjectsFromArray:(NSArray *)anArray {
	[list addObjectsFromArray:anArray];
}

@end

#pragma mark -

@interface CHAbstractListCollectionTest : XCTestCase
{
	CHAbstractListCollection *collection;
	NSArray *objects;
}

@end

@implementation CHAbstractListCollectionTest

- (void)setUp {
	collection = [[CHListDeque alloc] init]; // Pick a concrete subclass to initialize
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
}

#pragma mark -

- (void)testNSCoding {
	[collection addObjectsFromArray:objects];
	XCTAssertEqual([collection count], [objects count]);
	XCTAssertEqualObjects([collection allObjects], objects);
	
	collection = [collection copyUsingNSCoding];
	
	XCTAssertEqual([collection count], [objects count]);
	XCTAssertEqualObjects([collection allObjects], objects);
}

- (void)testNSCopying {
	[collection addObjectsFromArray:objects];
	CHAbstractListCollection *collection2 = [[collection copy] autorelease];
	XCTAssertNotNil(collection2);
	XCTAssertEqual([collection2 count], (NSUInteger)3);
	XCTAssertEqualObjects([collection allObjects], [collection2 allObjects]);
}

- (void)testNSFastEnumeration {
	NSUInteger limit = 32;
	for (NSUInteger number = 1; number <= limit; number++) {
		[collection addObject:[NSNumber numberWithUnsignedInteger:number]];
	}
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in collection) {
		XCTAssertEqual([object unsignedIntegerValue], expected++);
		++count;
	}
	XCTAssertEqual(count, limit);

	BOOL raisedException = NO;
	@try {
		for (__unused id object in collection) {
			[collection addObject:@"bogus"];
		}
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	XCTAssertTrue(raisedException);
}

#pragma mark -

- (void)testInit {
	XCTAssertNotNil(collection);
}

- (void)testAbstractInit {
	XCTAssertThrows([[CHAbstractListCollection alloc] init]);
}

- (void)testAbstractInitWithArray {
	XCTAssertThrows([[CHAbstractListCollection alloc] initWithArray:objects]);
}

- (void)testAllObjects {
	// An empty collection should return an empty (but non-nil) object array
	XCTAssertNotNil([collection allObjects]);
	XCTAssertEqual([[collection allObjects] count], (NSUInteger)0);
	// Test that a non-empty collection returns all objects properly
	[collection addObjectsFromArray:objects];
	XCTAssertEqualObjects([collection allObjects], objects);
}

- (void)testCount {
	XCTAssertEqual([collection count], (NSUInteger)0);
	[collection addObject:@"Hello, World!"];
	XCTAssertEqual([collection count], (NSUInteger)1);
}

- (void)testContainsObject {
	// An empty collection should not contain any objects we test for
	for (NSUInteger i = 0; i < [objects count]; i++) {
		XCTAssertFalse([collection containsObject:[objects objectAtIndex:i]]);
	}
	XCTAssertFalse([collection containsObject:@"bogus"]);
	// Add objects and test for inclusion of each, plus non-member object
	[collection addObjectsFromArray:objects];
	for (NSUInteger i = 0; i < [objects count]; i++) {
		XCTAssertTrue([collection containsObject:[objects objectAtIndex:i]]);
	}
	XCTAssertFalse([collection containsObject:@"bogus"]);
}

- (void)testDescription {
	[collection addObjectsFromArray:objects];
	XCTAssertEqualObjects([collection description], [objects description]);
}

- (void)testExchangeObjectAtIndexWithObjectAtIndex {
	// When the list is empty, calls with any index should raise exception
	XCTAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:0]);
	// When either index exceeds the bounds, an exception should be raised
	XCTAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:1]);
	XCTAssertThrows([collection exchangeObjectAtIndex:1 withObjectAtIndex:0]);
	[collection addObjectsFromArray:objects];
	NSUInteger count = [objects count];
	XCTAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:count]);
	XCTAssertThrows([collection exchangeObjectAtIndex:count withObjectAtIndex:0]);
	// Attempting to swap an index with itself should have no effect
	for (NSUInteger i = 0; i < count; i++) {
		XCTAssertNoThrow([collection exchangeObjectAtIndex:i withObjectAtIndex:i]);
		XCTAssertEqualObjects([collection allObjects], objects);
	}
	// Swap first and last elements
	XCTAssertNoThrow([collection exchangeObjectAtIndex:0 withObjectAtIndex:2]);
	XCTAssertEqualObjects([collection allObjects], [[objects reverseObjectEnumerator] allObjects]);
}

- (void)testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	XCTAssertTrue([collection containsObjectIdenticalTo:a]);
	XCTAssertFalse([collection containsObjectIdenticalTo:@"A"]);
	XCTAssertFalse([collection containsObjectIdenticalTo:@"bogus"]);
}

- (void)testIndexOfObject {
	// An empty collection should return NSNotFound any objects we test for
	for (NSUInteger i = 0; i < [objects count]; i++) {
		XCTAssertEqual([collection indexOfObject:[objects objectAtIndex:i]],
					   (NSUInteger)NSNotFound);
	}
	XCTAssertEqual([collection indexOfObject:@"Z"], (NSUInteger)NSNotFound);
	// Add objects and test index of each, plus non-member object
	[collection addObjectsFromArray:objects];
	for (NSUInteger i = 0; i < [objects count]; i++) {
		XCTAssertEqual([collection indexOfObject:[objects objectAtIndex:i]], i);
	}
	XCTAssertEqual([collection indexOfObject:@"Z"], (NSUInteger)NSNotFound);
}

- (void)testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	XCTAssertEqual([collection indexOfObjectIdenticalTo:a], (NSUInteger)0);
	XCTAssertEqual([collection indexOfObjectIdenticalTo:@"A"], (NSUInteger)NSNotFound);
	XCTAssertEqual([collection indexOfObjectIdenticalTo:@"Z"], (NSUInteger)NSNotFound);
}

- (void)testObjectAtIndex {
	[collection addObjectsFromArray:objects];
	// Test all three valid indexes and the boundary conditions
	XCTAssertThrows([collection objectAtIndex:-1]);
	XCTAssertEqualObjects([collection objectAtIndex:0], @"A");
	XCTAssertEqualObjects([collection objectAtIndex:1], @"B");
	XCTAssertEqualObjects([collection objectAtIndex:2], @"C");
	XCTAssertThrows([collection objectAtIndex:3]);
}

- (void)testObjectEnumerator {
	NSEnumerator *enumerator;
	enumerator = [collection objectEnumerator];
	XCTAssertNotNil(enumerator);
	XCTAssertNil([enumerator nextObject]);
	
	[collection addObject:@"Hello, World!"];
	enumerator = [collection objectEnumerator];
	XCTAssertNotNil(enumerator);
	XCTAssertNotNil([enumerator nextObject]);
	XCTAssertNil([enumerator nextObject]);
}

- (void)testObjectsAtIndexes {
	[collection addObjectsFromArray:objects];
	NSUInteger count = [collection count];
	NSRange range;
	for (NSUInteger location = 0; location <= count; location++) {
		range.location = location;
		for (NSUInteger length = 0; length <= count - location + 1; length++) {
			range.length = length;
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
			if (location + length > count) {
				XCTAssertThrows([collection objectsAtIndexes:indexes]);
			} else {
				XCTAssertEqualObjects([collection objectsAtIndexes:indexes], [objects objectsAtIndexes:indexes]);
			}
		}
	}
	XCTAssertThrows([collection objectsAtIndexes:nil]);
}

- (void)testRemoveAllObjects {
	XCTAssertEqual([collection count], (NSUInteger)0);
	[collection addObjectsFromArray:objects];
	XCTAssertEqual([collection count], (NSUInteger)3);
	[collection removeAllObjects];
	XCTAssertEqual([collection count], (NSUInteger)0);
}

- (void)testRemoveObject {
	[collection addObjectsFromArray:objects];

	XCTAssertThrows([collection removeObject:nil]);

	XCTAssertEqual([collection count], (NSUInteger)3);
	[collection removeObject:@"A"];
	XCTAssertEqual([collection count], (NSUInteger)2);
	[collection removeObject:@"A"];
	XCTAssertEqual([collection count], (NSUInteger)2);
	[collection removeObject:@"Z"];
	XCTAssertEqual([collection count], (NSUInteger)2);
}

- (void)testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	NSString *b = [NSString stringWithFormat:@"B"];
	[collection addObject:a];
	XCTAssertEqual([collection count], (NSUInteger)1);
	[collection removeObjectIdenticalTo:@"A"];
	XCTAssertEqual([collection count], (NSUInteger)1);
	[collection removeObjectIdenticalTo:a];
	XCTAssertEqual([collection count], (NSUInteger)0);
	[collection removeObjectIdenticalTo:a];
	XCTAssertEqual([collection count], (NSUInteger)0);
	
	// Test removing all instances of an object
	[collection addObject:a];
	[collection addObject:b];
	[collection addObject:@"C"];
	[collection addObject:a];
	[collection addObject:b];
	
	XCTAssertThrows([collection removeObjectIdenticalTo:nil]);

	XCTAssertEqual([collection count], (NSUInteger)5);
	[collection removeObjectIdenticalTo:@"A"];
	XCTAssertEqual([collection count], (NSUInteger)5);
	[collection removeObjectIdenticalTo:a];
	XCTAssertEqual([collection count], (NSUInteger)3);
	[collection removeObjectIdenticalTo:b];
	XCTAssertEqual([collection count], (NSUInteger)1);
}

- (void)testRemoveObjectAtIndex {
	// Test removing from any index in an empty collection
	XCTAssertThrows([collection removeObjectAtIndex:0]);
	XCTAssertThrows([collection removeObjectAtIndex:NSNotFound]);
	// Add objects and test removing from an index out of the reciever's bounds
	[collection addObjectsFromArray:objects];
	XCTAssertThrows([collection removeObjectAtIndex:3]);
	XCTAssertThrows([collection removeObjectAtIndex:-1]);
	// Test removing from valid indexes and verify results
	[collection removeObjectAtIndex:2];
	XCTAssertEqual([collection count], (NSUInteger)2);
	XCTAssertEqualObjects([collection objectAtIndex:0], @"A");
	XCTAssertEqualObjects([collection objectAtIndex:1], @"B");
	[collection removeObjectAtIndex:0];
	XCTAssertEqual([collection count], (NSUInteger)1);
	XCTAssertEqualObjects([collection objectAtIndex:0], @"B");
	[collection removeObjectAtIndex:0];
	XCTAssertEqual([collection count], (NSUInteger)0);
	// Test removing from an index in the middle of the collection
	[collection addObjectsFromArray:objects];
	[collection removeObjectAtIndex:1];
	XCTAssertEqual([collection count], (NSUInteger)2);
	XCTAssertEqualObjects([collection objectAtIndex:0], @"A");
	XCTAssertEqualObjects([collection objectAtIndex:1], @"C");
}

- (void)testRemoveObjectsAtIndexes {
	// Test removing with invalid indexes
	XCTAssertThrows([collection removeObjectsAtIndexes:nil]);
	XCTAssertThrows([collection removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:[collection count]]]);
	XCTAssertNoThrow([collection removeObjectsAtIndexes:[NSIndexSet indexSet]]);
	
	NSMutableArray *expected = [NSMutableArray array];
	[collection addObjectsFromArray:objects];
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	NSRange range;
	NSUInteger count = [collection count];
	for (range.location = 0; range.location < count; range.location++) {
		[indexes removeAllIndexes];
		for (range.length = 0; range.length <= count - range.location; range.length++) {
			[indexes addIndexesInRange:range];
			// Repopulate list and expected
			[expected removeAllObjects];
			[expected addObjectsFromArray:objects];
			[expected removeObjectsAtIndexes:indexes];
			[collection removeAllObjects];
			[collection addObjectsFromArray:objects];
			XCTAssertNoThrow([collection removeObjectsAtIndexes:indexes]);
			XCTAssertEqual([collection count], [expected count]);
			XCTAssertEqualObjects([collection allObjects], expected);
		}
	}
	XCTAssertThrows([collection removeObjectsAtIndexes:nil]);
	// Try removing first and last elements, leaving middle element
	[indexes removeAllIndexes];
	[indexes addIndex:0];
	[indexes addIndex:2];
	[expected removeAllObjects];
	[expected addObjectsFromArray:objects];
	[expected removeObjectsAtIndexes:indexes];
	[collection removeAllObjects];
	[collection addObjectsFromArray:objects];
	XCTAssertNoThrow([collection removeObjectsAtIndexes:indexes]);
	XCTAssertEqual([collection count], [expected count]);
	XCTAssertEqualObjects([collection allObjects], expected);
}

- (void)testReplaceObjectAtIndexWithObject {
	// Test replacing objects at invalid indexes
	XCTAssertThrows([collection replaceObjectAtIndex:0 withObject:nil]);
	XCTAssertThrows([collection replaceObjectAtIndex:NSNotFound withObject:nil]);
	// Test replacing objects at valid indexes and verify results
	[collection addObjectsFromArray:objects];
	for (NSUInteger i = 0; i < [objects count]; i++) {
		XCTAssertEqualObjects([collection objectAtIndex:i], [objects objectAtIndex:i]);
		XCTAssertNoThrow([collection replaceObjectAtIndex:i withObject:@"Z"]);
		XCTAssertEqualObjects([collection objectAtIndex:i], @"Z");
	}
}

@end
