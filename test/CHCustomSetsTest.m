//
//  CHCustomSetsTest.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHMutableSet.h>
#import <CHDataStructures/CHOrderedSet.h>
#import "NSObject+TestUtilities.h"

static NSArray *abc;

@interface CHMutableSet (Test)

- (NSString *)debugDescription; // Declare here to prevent compiler warnings.

@end

#pragma mark -

@interface CHMutableSetTest : XCTestCase {
	id set;
}

- (void)checkEqualityWithArray:(NSArray *)anArray;

- (NSArray *)randomNumbers;

@end


@implementation CHMutableSetTest

+ (void)initialize {
	abc = @[@"A",@"B",@"C"];
}

- (void)setUp {
	set = [[[CHMutableSet alloc] init] autorelease];
}

- (void)checkEqualityWithArray:(NSArray *)anArray {
	XCTAssertTrue([set isEqualToSet:[NSSet setWithArray:anArray]]);
}

// Provides an array of N unique NSNumber objects.
- (NSArray *)randomNumbers {
	NSMutableArray *array = [NSMutableArray array];
	NSNumber *number;
	for (NSUInteger count = 1; count <= 20; count++) {
		number = @(arc4random());
		if ([array containsObject:number]) {
			count--;
		} else {
			[array addObject:number];
		}
	}
	return array;
}

- (void)testAddObjectsFromArray {
	// Test that adding a nil or empty parameter has no effect
	XCTAssertNoThrow([set addObjectsFromArray:nil]);
	XCTAssertNoThrow([set addObjectsFromArray:@[]]);
	XCTAssertEqual([set count], (NSUInteger)0);
	// Test adding objects
	[set addObjectsFromArray:abc];
	[self checkEqualityWithArray:abc];
	// Test adding the same objects (duplicates discarded)
	[set addObjectsFromArray:abc];
	[self checkEqualityWithArray:abc];
}

- (void)testAllObjects {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	[self checkEqualityWithArray:array];
	
	[set removeAllObjects];
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];
	array = @[@"A",@"B",@"C"];
	[self checkEqualityWithArray:array];
	
	[set addObject:@"C"];
	[set addObject:@"B"];
	[self checkEqualityWithArray:array];
}

- (void)testAnyObject {
	XCTAssertNil([set anyObject]);
	[set addObjectsFromArray:[self randomNumbers]];
	XCTAssertNotNil([set anyObject]);
}

- (void)testCount {
	XCTAssertEqual([set count], (NSUInteger)0);
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	XCTAssertEqual([set count], [array count]);
}

- (void)testContainsObject {
	XCTAssertFalse([set containsObject:@"A"]);
	[set addObject:@"A"];
	XCTAssertTrue([set containsObject:@"A"]);
}

- (void)testDebugDescription {
	XCTAssertNotNil([set debugDescription]);
	[set addObjectsFromArray:[self randomNumbers]];
	XCTAssertNotNil([set debugDescription]);
}

- (void)testHash {
	[set addObjectsFromArray:abc];
	id set2 = [[[[set class] alloc] initWithArray:abc] autorelease];
	XCTAssertEqual([set hash], [set2 hash]);
}

- (void)testIntersectsSet {
	NSSet *abcSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	NSSet *cde = [NSSet setWithObjects:@"C",@"D",@"E",nil];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	XCTAssertFalse([set intersectsSet:abcSet]);
	[set addObjectsFromArray:@[@"A",@"B",@"C"]];
	
	XCTAssertTrue([set intersectsSet:abcSet]);
	XCTAssertTrue([set intersectsSet:cde]);
	XCTAssertFalse([set intersectsSet:xyz]);
	
	XCTAssertFalse([set intersectsSet:nil]);
	XCTAssertFalse([set intersectsSet:[NSSet set]]);
}

- (void)testIsEqualToSet {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	XCTAssertEqualObjects(set, [NSSet setWithArray:array]);
}

- (void)testIntersectSet {
	NSArray *cde = @[@"C",@"D",@"E"];
	NSArray *def = @[@"D",@"E",@"F"];
	NSArray *c = @[@"C"];
	NSArray *empty = @[];
	
	XCTAssertNoThrow([set intersectSet:nil]);
	
	// Test intersecting identical sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:abc]];
	[self checkEqualityWithArray:abc];
	
	// Test intersecting overlapping sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:cde]];
	[self checkEqualityWithArray:c];
	[set removeAllObjects];
	
	[set addObjectsFromArray:cde];
	[set intersectSet:[NSSet setWithArray:abc]];
	[self checkEqualityWithArray:c];
	[set removeAllObjects];
	
	// Test intersecting disjoint sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:def]];
	[self checkEqualityWithArray:empty];
}

- (void)testMinusSet {
	NSArray *axbycz = @[@"A",@"X",@"B",@"Y",@"C",@"Z"];
	NSArray *xaybzc = @[@"X",@"A",@"Y",@"B",@"Z",@"C"];
	NSArray *empty = @[];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	XCTAssertNoThrow([set minusSet:nil]);
	[self checkEqualityWithArray:empty];
	
	[set minusSet:[NSSet set]];
	[self checkEqualityWithArray:empty];
	
	[set minusSet:xyz];
	[self checkEqualityWithArray:empty];
	
	[set addObjectsFromArray:axbycz];
	
	XCTAssertNoThrow([set minusSet:nil]);
	[self checkEqualityWithArray:axbycz];
	
	[set minusSet:[NSSet set]];
	[self checkEqualityWithArray:axbycz];
	
	// Test removing even elements
	[set addObjectsFromArray:axbycz];
	XCTAssertNoThrow([set minusSet:xyz]);
	[self checkEqualityWithArray:abc];
	[set removeAllObjects];
	
	// Test removing odd elements
	[set addObjectsFromArray:xaybzc];	
	XCTAssertNoThrow([set minusSet:xyz]);
	[self checkEqualityWithArray:abc];
	[set removeAllObjects];
	
	// Test differencing disjoint sets
	[set addObjectsFromArray:abc];
	[set minusSet:xyz];
	[self checkEqualityWithArray:abc];
	
	// Test differencing identical sets
	[set addObjectsFromArray:abc];
	[set minusSet:[NSSet setWithArray:abc]];
	[self checkEqualityWithArray:empty];
}

- (void)testIsSubsetOfSet {
	NSSet *abcSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[set addObject:@"A"];
	XCTAssertTrue([set isSubsetOfSet:abcSet]);
	[set addObject:@"B"];
	XCTAssertTrue([set isSubsetOfSet:abcSet]);
	[set addObject:@"C"];
	XCTAssertTrue([set isSubsetOfSet:abcSet]);
	[set addObject:@"D"];
	XCTAssertFalse([set isSubsetOfSet:abcSet]);
}

- (void)testRemoveAllObjects {
	[set addObjectsFromArray:[self randomNumbers]];
	XCTAssertTrue([set count] != 0);
	[set removeAllObjects];
	XCTAssertTrue([set count] == 0);
}

- (void)testMember {
	XCTAssertNil([set member:@"A"]);
	[set addObject:@"A"];
	XCTAssertEqualObjects([set member:@"A"], @"A");
	XCTAssertNil([set member:@"bogus"]);
	[set removeAllObjects];
	XCTAssertNil([set member:@"A"]);
}

- (void)testRemoveObject {
	XCTAssertThrows([set removeObject:nil]);
	XCTAssertNoThrow([set removeObject:@"bogus"]);
	
	[set addObjectsFromArray:abc];
	XCTAssertTrue([set containsObject:@"A"]);
	[set removeObject:@"A"];
	XCTAssertFalse([set containsObject:@"A"]);
}

#pragma mark <Protocols>

- (void)testNSCoding {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	XCTAssertEqual([set count], [array count]);
	[self checkEqualityWithArray:array];
	
	CHOrderedSet *set2 = [set copyUsingNSCoding];
	
	XCTAssertEqual([set2 count], [set count]);
	[self checkEqualityWithArray:[set2 allObjects]];
}

- (void)testNSCopying {
	[set addObjectsFromArray:[self randomNumbers]];
	CHOrderedSet *copy = [set copy];
	XCTAssertEqualObjects([set class], [copy class]);
	XCTAssertEqual([set count], [copy count]);
	[self checkEqualityWithArray:[copy allObjects]];
}

- (void)testNSFastEnumeration {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	// Test fast enumeration on the set and compare with 
	NSUInteger count = 0;
	NSEnumerator *enumerator = [array objectEnumerator];
	BOOL unorderedSet = [set isMemberOfClass:[CHMutableSet class]];
	for (NSNumber *number in set) {
		XCTAssertNotNil(number);
		if (unorderedSet) {
			XCTAssertNotNil([enumerator nextObject]);
		} else {
			XCTAssertEqualObjects(number, [enumerator nextObject]);
		}
		count++;
	}
	XCTAssertEqual(count, [array count]);
	// Test that the enumerator is exhausted after fast enumeration
	XCTAssertNil([enumerator nextObject]);
}

@end

#pragma mark -

@interface CHOrderedSetTest : CHMutableSetTest

@end

@implementation CHOrderedSetTest

- (void)setUp {
	set = [[[CHOrderedSet alloc] init] autorelease];
}

- (void)checkEqualityWithArray:(NSArray *)anArray {
	XCTAssertEqualObjects(anArray, [set allObjects]);
}

#pragma mark Initialization

- (void)testInitialization {
	// This tests -initWithArray: directly, and -initWithCapacity: indirectly.
	NSArray *array = [self randomNumbers];
	set = [[CHOrderedSet alloc] initWithArray:array];
	[self checkEqualityWithArray:array];
}

#pragma mark Adding Objects

- (void)testAddObject {
	XCTAssertThrows([set addObject:nil]);
	
	for (id anObject in abc) {
		[set addObject:anObject];
	}
	[self checkEqualityWithArray:abc];
	
	for (id anObject in abc) {
		[set addObject:anObject];
	}
	[self checkEqualityWithArray:abc];
}

- (void)testExchangeObjectAtIndexWithObjectAtIndex {
	XCTAssertThrows([set exchangeObjectAtIndex:0 withObjectAtIndex:1]);
	
	[set addObjectsFromArray:abc];
	// Just sanity-check the code, since the implementation is tested elsewhere.
	[set exchangeObjectAtIndex:0 withObjectAtIndex:2];
	XCTAssertEqualObjects([set objectAtIndex:2], [abc objectAtIndex:0]);
	XCTAssertEqualObjects([set objectAtIndex:0], [abc objectAtIndex:2]);
}

- (void)testInsertObjectAtIndex {
	NSArray *acb  = @[@"A",@"C",@"B"];
	NSArray *dacb  = @[@"D",@"A",@"C",@"B"];
	
	XCTAssertThrows([set insertObject:@"X" atIndex:1]);
	
	[set addObjectsFromArray:abc];
	
	[set insertObject:@"C" atIndex:1];
	XCTAssertEqualObjects([set allObjects], acb);
	
	[set insertObject:@"D" atIndex:0];
	XCTAssertEqualObjects([set allObjects], dacb);
}

- (void)testUnionSet {
	NSSet *ade = [NSSet setWithObjects:@"A",@"D",@"E",nil];
	NSMutableArray *order;
	
	order = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",nil];
	for (id anObject in ade) {
		if (![anObject isEqual:@"A"]) {
			[order addObject:anObject];
		}
	}
	[set addObjectsFromArray:abc];
	[set unionSet:ade];
	[self checkEqualityWithArray:order];
}

#pragma mark Querying Contents

- (void)testDescription {
	XCTAssertEqualObjects([set description], [@[] description]);

	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	XCTAssertEqualObjects([set description], [array description]);
}

- (void)testIndexOfObject {
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		XCTAssertEqual([set indexOfObject:[abc objectAtIndex:i]], i);
	}
}

- (void)testIsEqualToOrderedSet {
	NSArray *cba = @[@"C",@"B",@"A"];
	NSArray *xyz = @[@"X",@"Y",@"Z"];
	CHOrderedSet *set2;
	[set addObjectsFromArray:abc];
	set2 = [[[CHOrderedSet alloc] initWithArray:abc] autorelease];
	XCTAssertTrue([set isEqualToOrderedSet:set2]);
	set2 = [[[CHOrderedSet alloc] initWithArray:cba] autorelease];
	XCTAssertFalse([set isEqualToOrderedSet:set2]);
	set2 = [[[CHOrderedSet alloc] initWithArray:xyz] autorelease];
	XCTAssertFalse([set isEqualToOrderedSet:set2]);
}

- (void)testObjectAtIndex {
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		XCTAssertEqualObjects([set objectAtIndex:i], [abc objectAtIndex:i],
					   @"Wrong object at index %lu.", i);
	}
}

- (void)testObjectsAtIndexes {
	[set addObjectsFromArray:abc];
	NSUInteger count = [set count];
	NSRange range;
	for (NSUInteger location = 0; location <= count; location++) {
		range.location = location;
		for (NSUInteger length = 0; length <= count - location + 1; length++) {
			range.length = length;
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
			if (location + length > count) {
				XCTAssertThrows([set objectsAtIndexes:indexes]);
			} else {
				XCTAssertEqualObjects([set objectsAtIndexes:indexes],
									 [abc objectsAtIndexes:indexes]);
			}
		}
	}
	XCTAssertThrows([set objectsAtIndexes:nil]);
}

- (void)testObjectEnumerator {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *arrayEnumerator = [array objectEnumerator];
	NSEnumerator *setEnumerator = [set objectEnumerator];
	id arrayObject, setObject;
	do {
		arrayObject = [arrayEnumerator nextObject];
		setObject   = [setEnumerator nextObject];
		XCTAssertEqualObjects(arrayObject, setObject);
	} while (arrayObject && setObject);
}

- (void)testOrderedSetWithObjectsAtIndexes {
	XCTAssertThrows([set orderedSetWithObjectsAtIndexes:nil]);
	NSArray *abcde = @[@"A",@"B",@"C",@"D",@"E"];
	[set addObjectsFromArray:abcde];
	XCTAssertThrows([set orderedSetWithObjectsAtIndexes:nil]);
	
	CHOrderedSet *newSet;
	XCTAssertNoThrow(newSet = [set orderedSetWithObjectsAtIndexes:[NSIndexSet indexSet]]);
	XCTAssertNotNil(newSet);
	XCTAssertEqual([newSet count], (NSUInteger)0);
	
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet *indexes;
	for (NSUInteger location = 0; location < [set count]; location++) {
		for (NSUInteger length = 0; length < [set count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			XCTAssertNoThrow(newSet = [set orderedSetWithObjectsAtIndexes:indexes]);
			XCTAssertEqualObjects([newSet allObjects],
			                     [abcde objectsAtIndexes:indexes]);
		}
	}	
	XCTAssertThrows([set orderedSetWithObjectsAtIndexes:nil]);
}

#pragma mark Removing Objects

- (void)testRemoveFirstObject {
	[set addObjectsFromArray:abc];
	XCTAssertEqualObjects([set firstObject], @"A");
	[set removeFirstObject];
	XCTAssertEqualObjects([set firstObject], @"B");
	[set removeFirstObject];
	XCTAssertEqualObjects([set firstObject], @"C");
	[set removeFirstObject];
	XCTAssertNil([set firstObject]);
}

- (void)testRemoveLastObject {
	[set addObjectsFromArray:abc];
	XCTAssertEqualObjects([set lastObject], @"C");
	[set removeLastObject];
	XCTAssertEqualObjects([set lastObject], @"B");
	[set removeLastObject];
	XCTAssertEqualObjects([set lastObject], @"A");
	[set removeLastObject];
	XCTAssertNil([set lastObject]);
}

- (void)testRemoveObjectAtIndex {
	// Test that removing from an invalid index raises an exception
	XCTAssertThrows([set removeObjectAtIndex:0]);
	XCTAssertThrows([set removeObjectAtIndex:1]);
	// Test removing from valid indexes; should not raise any exceptions
	[set addObjectsFromArray:abc];
	XCTAssertThrows([set removeObjectAtIndex:[abc count]]);
	for (NSInteger i = [abc count]-1; i >= 0; i--) {
		XCTAssertEqualObjects([set lastObject], [abc objectAtIndex:i],
							 @"Wrong object at index %lu before remove.", i);
		[set removeObjectAtIndex:i];
	}
}

- (void)testRemoveObjectsAtIndexes {
	// Test removing with invalid indexes
	XCTAssertThrows([set removeObjectsAtIndexes:nil]);
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	XCTAssertThrows([set removeObjectsAtIndexes:indexes]);
	// Test removing using valid index sets
	NSMutableArray *expected = [NSMutableArray array];
	for (NSUInteger location = 0; location < [abc count]; location++) {
		for (NSUInteger length = 0; length <= [abc count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate set and expected values
			[expected removeAllObjects];
			[expected addObjectsFromArray:abc];
			[set removeAllObjects];
			[set addObjectsFromArray:expected];
			XCTAssertNoThrow([set removeObjectsAtIndexes:indexes]);
			[expected removeObjectsAtIndexes:indexes];
			XCTAssertEqual([set count], [expected count]);
			XCTAssertEqualObjects([set allObjects], expected);
		}
	}	
	XCTAssertThrows([set removeObjectsAtIndexes:nil]);
}

@end
