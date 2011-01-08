/*
 CHDataStructures.framework -- CHCustomSetsTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableSet.h"
#import "CHOrderedSet.h"

static NSArray *abc;

@interface CHMutableSet (Test)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end

#pragma mark -

@interface CHMutableSetTest : SenTestCase {
	id set;
	NSEnumerator *e;
	id anObject;
}

- (void) checkEqualityWithArray:(NSArray*)anArray;

- (NSArray*) randomNumbers;

@end


@implementation CHMutableSetTest

+ (void) initialize {
	abc = [[NSArray arrayWithObjects:@"A",@"B",@"C",nil] retain];
}

- (void) setUp {
	set = [[[CHMutableSet alloc] init] autorelease];
}

- (void) checkEqualityWithArray:(NSArray*)anArray {
	STAssertTrue([set isEqualToSet:[NSSet setWithArray:anArray]], nil);
}

// Provides an array of N unique NSNumber objects.
- (NSArray*) randomNumbers {
	NSMutableArray *array = [NSMutableArray array];
	NSNumber *number;
	for (NSUInteger count = 1; count <= 20; count++) {
		number = [NSNumber numberWithUnsignedInt:arc4random()];
		if ([array containsObject:number])
			count--;
		else
			[array addObject:number];
	}
	return array;
}

- (void) testAddObjectsFromArray {
	// Test that adding a nil or empty parameter has no effect
	STAssertNoThrow([set addObjectsFromArray:nil], nil);
	STAssertNoThrow([set addObjectsFromArray:[NSArray array]], nil);
	STAssertEquals([set count], (NSUInteger)0, nil);
	// Test adding objects
	[set addObjectsFromArray:abc];
	[self checkEqualityWithArray:abc];
	// Test adding the same objects (duplicates discarded)
	[set addObjectsFromArray:abc];
	[self checkEqualityWithArray:abc];
}

- (void) testAllObjects {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	[self checkEqualityWithArray:array];
	
	[set removeAllObjects];
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];
	array = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[self checkEqualityWithArray:array];
	
	[set addObject:@"C"];
	[set addObject:@"B"];
	[self checkEqualityWithArray:array];
}

- (void) testAnyObject {
	STAssertNil([set anyObject], nil);
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertNotNil([set anyObject], nil);
}

- (void) testCount {
	STAssertEquals([set count], (NSUInteger)0, nil);
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEquals([set count], [array count], nil);
}

- (void) testContainsObject {
	STAssertFalse([set containsObject:@"A"], nil);
	[set addObject:@"A"];
	STAssertTrue([set containsObject:@"A"], nil);
}

- (void) testDebugDescription {
	STAssertNotNil([set debugDescription], nil);
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertNotNil([set debugDescription], nil);
}

- (void) testHash {
	[set addObjectsFromArray:abc];
	id set2 = [[[[set class] alloc] initWithArray:abc] autorelease];
	STAssertEquals([set hash], [set2 hash], nil);
}

- (void) testIntersectsSet {
	NSSet *abcSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	NSSet *cde = [NSSet setWithObjects:@"C",@"D",@"E",nil];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	STAssertFalse([set intersectsSet:abcSet], nil);
	[set addObjectsFromArray:[NSArray arrayWithObjects:@"A",@"B",@"C",nil]];
	
	STAssertTrue([set intersectsSet:abcSet], nil);
	STAssertTrue([set intersectsSet:cde], nil);
	STAssertFalse([set intersectsSet:xyz], nil);
	
	STAssertFalse([set intersectsSet:nil], nil);
	STAssertFalse([set intersectsSet:[NSSet set]], nil);
}

- (void) testIsEqualToSet {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEqualObjects(set, [NSSet setWithArray:array], nil);
}

- (void) testIntersectSet {
	NSArray *cde = [NSArray arrayWithObjects:@"C",@"D",@"E",nil];
	NSArray *def = [NSArray arrayWithObjects:@"D",@"E",@"F",nil];
	NSArray *c = [NSArray arrayWithObjects:@"C",nil];
	NSArray *empty = [NSArray array];
	
	STAssertNoThrow([set intersectSet:nil], nil);
	
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

- (void) testMinusSet {
	NSArray *axbycz = [NSArray arrayWithObjects:@"A",@"X",@"B",@"Y",@"C",@"Z",nil];
	NSArray *xaybzc = [NSArray arrayWithObjects:@"X",@"A",@"Y",@"B",@"Z",@"C",nil];
	NSArray *empty = [NSArray array];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	STAssertNoThrow([set minusSet:nil], nil);
	[self checkEqualityWithArray:empty];
	
	[set minusSet:[NSSet set]];
	[self checkEqualityWithArray:empty];
	
	[set minusSet:xyz];
	[self checkEqualityWithArray:empty];
	
	[set addObjectsFromArray:axbycz];
	
	STAssertNoThrow([set minusSet:nil], nil);
	[self checkEqualityWithArray:axbycz];
	
	[set minusSet:[NSSet set]];
	[self checkEqualityWithArray:axbycz];
	
	// Test removing even elements
	[set addObjectsFromArray:axbycz];
	STAssertNoThrow([set minusSet:xyz], nil);
	[self checkEqualityWithArray:abc];
	[set removeAllObjects];
	
	// Test removing odd elements
	[set addObjectsFromArray:xaybzc];	
	STAssertNoThrow([set minusSet:xyz], nil);
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

- (void) testIsSubsetOfSet {
	NSSet *abcSet = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[set addObject:@"A"];
	STAssertTrue([set isSubsetOfSet:abcSet], nil);
	[set addObject:@"B"];
	STAssertTrue([set isSubsetOfSet:abcSet], nil);
	[set addObject:@"C"];
	STAssertTrue([set isSubsetOfSet:abcSet], nil);
	[set addObject:@"D"];
	STAssertFalse([set isSubsetOfSet:abcSet], nil);
}

- (void) testRemoveAllObjects {
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertTrue([set count] != 0, nil);
	[set removeAllObjects];
	STAssertTrue([set count] == 0, nil);
}

- (void) testMember {
	STAssertNil([set member:@"A"], nil);
	[set addObject:@"A"];
	STAssertEqualObjects([set member:@"A"], @"A", nil);
	STAssertNil([set member:@"bogus"], nil);
	[set removeAllObjects];
	STAssertNil([set member:@"A"], nil);
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], nil);
	
	[set addObjectsFromArray:abc];
	STAssertTrue([set containsObject:@"A"], nil);
	[set removeObject:@"A"];
	STAssertFalse([set containsObject:@"A"], nil);
}

#pragma mark <Protocols>

- (void) testNSCoding {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEquals([set count], [array count], nil);
	[self checkEqualityWithArray:array];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:set];
	CHOrderedSet *set2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	STAssertEquals([set2 count], [set count], nil);
	[self checkEqualityWithArray:[set2 allObjects]];
}

- (void) testNSCopying {
	[set addObjectsFromArray:[self randomNumbers]];
	CHOrderedSet *copy = [set copy];
	STAssertEqualObjects([set class], [copy class], nil);
	STAssertEquals([set count], [copy count], nil);
	[self checkEqualityWithArray:[copy allObjects]];
}

- (void) testNSFastEnumeration {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	// Test fast enumeration on the set and compare with 
	NSUInteger count = 0;
	NSEnumerator *enumerator = [array objectEnumerator];
	BOOL unorderedSet = [set isMemberOfClass:[CHMutableSet class]];
	for (NSNumber *number in set) {
		STAssertNotNil(number, nil);
		if (unorderedSet)
			STAssertNotNil([enumerator nextObject], nil);
		else
			STAssertEqualObjects(number, [enumerator nextObject], nil);
		count++;
	}
	STAssertEquals(count, [array count], nil);
	// Test that the enumerator is exhausted after fast enumeration
	STAssertNil([enumerator nextObject], nil);
}

@end

#pragma mark -

@interface CHOrderedSetTest : CHMutableSetTest

@end

@implementation CHOrderedSetTest

- (void) setUp {
	set = [[[CHOrderedSet alloc] init] autorelease];
}

- (void) checkEqualityWithArray:(NSArray*)anArray {
	STAssertEqualObjects(anArray, [set allObjects], nil);
}

#pragma mark Initialization

- (void) testInitialization {
	// This tests -initWithArray: directly, and -initWithCapacity: indirectly.
	NSArray *array = [self randomNumbers];
	set = [[CHOrderedSet alloc] initWithArray:array];
	[self checkEqualityWithArray:array];
}

#pragma mark Adding Objects

- (void) testAddObject {
	STAssertThrows([set addObject:nil], nil);
	
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	[self checkEqualityWithArray:abc];
	
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	[self checkEqualityWithArray:abc];
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	STAssertThrows([set exchangeObjectAtIndex:0 withObjectAtIndex:1], nil);
	
	[set addObjectsFromArray:abc];
	// Just sanity-check the code, since the implementation is tested elsewhere.
	[set exchangeObjectAtIndex:0 withObjectAtIndex:2];
	STAssertEqualObjects([set objectAtIndex:2], [abc objectAtIndex:0], nil);
	STAssertEqualObjects([set objectAtIndex:0], [abc objectAtIndex:2], nil);
}

- (void) testInsertObjectAtIndex {
	NSArray *acb  = [NSArray arrayWithObjects:@"A",@"C",@"B",nil];
	NSArray *dacb  = [NSArray arrayWithObjects:@"D",@"A",@"C",@"B",nil];
	
	STAssertThrows([set insertObject:@"X" atIndex:1], nil);
	
	[set addObjectsFromArray:abc];
	
	[set insertObject:@"C" atIndex:1];
	STAssertEqualObjects([set allObjects], acb, nil);
	
	[set insertObject:@"D" atIndex:0];
	STAssertEqualObjects([set allObjects], dacb, nil);
}

- (void) testUnionSet {
	NSSet *ade = [NSSet setWithObjects:@"A",@"D",@"E",nil];
	NSMutableArray *order;
	
	order = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",nil];
	e = [ade objectEnumerator];
	while (anObject = [e nextObject])
		if (![anObject isEqual:@"A"])
			[order addObject:anObject];
	[set addObjectsFromArray:abc];
	[set unionSet:ade];
	[self checkEqualityWithArray:order];
}

#pragma mark Querying Contents

- (void) testDescription {
	STAssertEqualObjects([set description], [[NSArray array] description], nil);

	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEqualObjects([set description], [array description], nil);
}

- (void) testIndexOfObject {
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEquals([set indexOfObject:[abc objectAtIndex:i]], i, nil);
	}
}

- (void) testIsEqualToOrderedSet {
	NSArray *cba = [NSArray arrayWithObjects:@"C",@"B",@"A",nil];
	NSArray *xyz = [NSArray arrayWithObjects:@"X",@"Y",@"Z",nil];
	CHOrderedSet* set2;
	[set addObjectsFromArray:abc];
	set2 = [[[CHOrderedSet alloc] initWithArray:abc] autorelease];
	STAssertTrue([set isEqualToOrderedSet:set2], nil);
	set2 = [[[CHOrderedSet alloc] initWithArray:cba] autorelease];
	STAssertFalse([set isEqualToOrderedSet:set2], nil);
	set2 = [[[CHOrderedSet alloc] initWithArray:xyz] autorelease];
	STAssertFalse([set isEqualToOrderedSet:set2], nil);
}

- (void) testObjectAtIndex {
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEqualObjects([set objectAtIndex:i], [abc objectAtIndex:i],
					   @"Wrong object at index %d.", i);
	}
}

- (void) testObjectsAtIndexes {
	[set addObjectsFromArray:abc];
	NSUInteger count = [set count];
	NSRange range;
	for (NSUInteger location = 0; location <= count; location++) {
		range.location = location;
		for (NSUInteger length = 0; length <= count - location + 1; length++) {
			range.length = length;
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
			if (location + length > count) {
				STAssertThrows([set objectsAtIndexes:indexes], nil);
			} else {
				STAssertEqualObjects([set objectsAtIndexes:indexes],
									 [abc objectsAtIndexes:indexes], nil);
			}
		}
	}
	STAssertThrows([set objectsAtIndexes:nil], nil);
}

- (void) testObjectEnumerator {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *arrayEnumerator = [array objectEnumerator];
	NSEnumerator *setEnumerator = [set objectEnumerator];
	id arrayObject, setObject;
	do {
		arrayObject = [arrayEnumerator nextObject];
		setObject   = [setEnumerator nextObject];
		STAssertEqualObjects(arrayObject, setObject, nil);
	} while (arrayObject && setObject);
}

- (void) testOrderedSetWithObjectsAtIndexes {
	STAssertThrows([set orderedSetWithObjectsAtIndexes:nil], nil);
	NSArray* abcde = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",nil];
	[set addObjectsFromArray:abcde];
	STAssertThrows([set orderedSetWithObjectsAtIndexes:nil], nil);
	
	CHOrderedSet* newSet;
	STAssertNoThrow(newSet = [set orderedSetWithObjectsAtIndexes:[NSIndexSet indexSet]], nil);
	STAssertNotNil(newSet, nil);
	STAssertEquals([newSet count], (NSUInteger)0, nil);
	
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [set count]; location++) {
		for (NSUInteger length = 0; length < [set count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow(newSet = [set orderedSetWithObjectsAtIndexes:indexes], nil);
			STAssertEqualObjects([newSet allObjects],
			                     [abcde objectsAtIndexes:indexes], nil);
		}
	}	
	STAssertThrows([set orderedSetWithObjectsAtIndexes:nil], nil);
}

#pragma mark Removing Objects

- (void) testRemoveFirstObject {
	[set addObjectsFromArray:abc];
	STAssertEqualObjects([set firstObject], @"A", nil);
	[set removeFirstObject];
	STAssertEqualObjects([set firstObject], @"B", nil);
	[set removeFirstObject];
	STAssertEqualObjects([set firstObject], @"C", nil);
	[set removeFirstObject];
	STAssertNil([set firstObject], nil);
}

- (void) testRemoveLastObject {
	[set addObjectsFromArray:abc];
	STAssertEqualObjects([set lastObject], @"C", nil);
	[set removeLastObject];
	STAssertEqualObjects([set lastObject], @"B", nil);
	[set removeLastObject];
	STAssertEqualObjects([set lastObject], @"A", nil);
	[set removeLastObject];
	STAssertNil([set lastObject], nil);
}

- (void) testRemoveObjectAtIndex {
	// Test that removing from an invalid index raises an exception
	STAssertThrows([set removeObjectAtIndex:0], nil);
	STAssertThrows([set removeObjectAtIndex:1], nil);
	// Test removing from valid indexes; should not raise any exceptions
	[set addObjectsFromArray:abc];
	STAssertThrows([set removeObjectAtIndex:[abc count]], nil);
	for (NSInteger i = [abc count]-1; i >= 0; i--) {
		STAssertEqualObjects([set lastObject], [abc objectAtIndex:i],
							 @"Wrong object at index %d before remove.", i);
		[set removeObjectAtIndex:i];
	}
}

- (void) testRemoveObjectsAtIndexes {
	// Test removing with invalid indexes
	STAssertThrows([set removeObjectsAtIndexes:nil], nil);
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	STAssertThrows([set removeObjectsAtIndexes:indexes], nil);
	// Test removing using valid index sets
	NSMutableArray* expected = [NSMutableArray array];
	for (NSUInteger location = 0; location < [abc count]; location++) {
		for (NSUInteger length = 0; length <= [abc count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate set and expected values
			[expected removeAllObjects];
			[expected addObjectsFromArray:abc];
			[set removeAllObjects];
			[set addObjectsFromArray:expected];
			STAssertNoThrow([set removeObjectsAtIndexes:indexes], nil);
			[expected removeObjectsAtIndexes:indexes];
			STAssertEquals([set count], [expected count], nil);
			STAssertEqualObjects([set allObjects], expected, nil);
		}
	}	
	STAssertThrows([set removeObjectsAtIndexes:nil], nil);
}

@end
