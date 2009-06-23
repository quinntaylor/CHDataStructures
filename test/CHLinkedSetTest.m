/*
 CHDataStructures.framework -- CHLinkedSetTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLinkedSet.h"

@interface CHLinkedSet (Test)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end


@interface CHLinkedSetTest : SenTestCase {
	CHLinkedSet *set;
	NSEnumerator *e;
	id anObject;
}

- (NSArray*) randomNumbers;

@end

@implementation CHLinkedSetTest

- (void) setUp {
	set = [[CHLinkedSet alloc] init];
}

- (void) tearDown {
	[set release];
}

// Provides an array of N unique NSNumber objects.
- (NSArray*) randomNumbers {
	NSMutableArray *array = [NSMutableArray array];
	NSNumber *number;
	for (int count = 1; count <= 20; count++) {
		number = [NSNumber numberWithUnsignedInt:arc4random()];
		if ([array containsObject:number])
			count--;
		else
			[array addObject:number];
	}
	return array;
}

#pragma mark Initialization

- (void) testInitialization {
	STAssertNotNil(set, @"Initialization failed.");
	[set release];
	// This tests -initWithArray: directly, and -initWithCapacity: indirectly.
	NSArray *array = [self randomNumbers];
	set = [[CHLinkedSet alloc] initWithArray:array];
	STAssertEqualObjects([set allObjects], array, @"Incorrect insertion order.");
}

#pragma mark Adding Objects

- (void) testAddObjectsAndOrdering {
	STAssertThrows([set addObject:nil], @"Should raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	STAssertEqualObjects([set allObjects], abc, @"Wrong ordering.");
	STAssertEquals([set count], [abc count], @"Wrong count.");
	
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	STAssertEqualObjects([set allObjects], abc, @"Wrong ordering.");
	STAssertEquals([set count], [abc count], @"Wrong count.");
}

- (void) testAddObjectsFromArray {
	STAssertThrows([set addObjectsFromArray:nil], @"Should raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	STAssertEqualObjects([set allObjects], abc, @"Wrong ordering.");
	STAssertEquals([set count], [abc count], @"Wrong count.");
	
	[set addObjectsFromArray:abc];
	STAssertEqualObjects([set allObjects], abc, @"Wrong ordering.");
	STAssertEquals([set count], [abc count], @"Wrong count.");
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	STAssertThrows([set exchangeObjectAtIndex:0 withObjectAtIndex:1],
				   @"Should raise exception, set is empty.");
	
	NSArray *abc  = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	// Just sanity-check the code, since the implementation is tested elsewhere.
	[set exchangeObjectAtIndex:0 withObjectAtIndex:2];
	STAssertEqualObjects([set objectAtIndex:2], [abc objectAtIndex:0], @"Bad order");
	STAssertEqualObjects([set objectAtIndex:0], [abc objectAtIndex:2], @"Bad order");
}

- (void) testInsertObjectAtIndex {
	NSArray *abc  = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *acb  = [NSArray arrayWithObjects:@"A",@"C",@"B",nil];
	NSArray *dacb  = [NSArray arrayWithObjects:@"D",@"A",@"C",@"B",nil];
	
	STAssertThrows([set insertObject:@"X" atIndex:1], @"Should raise exception");
	
	[set addObjectsFromArray:abc];
	
	[set insertObject:@"C" atIndex:1];
	STAssertEqualObjects([set allObjects], acb, @"Wrong ordering");
	
	[set insertObject:@"D" atIndex:0];
	STAssertEqualObjects([set allObjects], dacb, @"Wrong ordering");
}

- (void) testUnionSet {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSSet *ade = [NSSet setWithObjects:@"A",@"D",@"E",nil];
	NSMutableArray *order;
	
	order = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",nil];
	e = [ade objectEnumerator];
	while (anObject = [e nextObject])
		if (![anObject isEqual:@"A"])
			[order addObject:anObject];
	[set addObjectsFromArray:abc];
	[set unionSet:ade];
	STAssertEqualObjects([set allObjects], order, @"Wrong ordering on union.");
}

#pragma mark Querying Contents

- (void) testAllObjects {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEqualObjects([set allObjects], array, @"Wrong ordering.");

	[set removeAllObjects];
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];
	array = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
	STAssertEqualObjects([set allObjects], array, @"Wrong ordering from -allObjects.");
	
	[set addObject:@"C"];
	[set addObject:@"B"];
	STAssertEqualObjects([set allObjects], array, @"Wrong ordering from -allObjects.");
}

- (void) testAnyObject {
	STAssertNil([set anyObject], @"Should return nil.");
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertNotNil([set anyObject], @"Should not return nil.");
}

- (void) testContainsObject {
	STAssertFalse([set containsObject:@"A"], @"Should not contain object.");
	STAssertFalse([set containsObject:@"Z"], @"Should not contain object.");
	[set addObject:@"A"];
	STAssertTrue([set containsObject:@"A"], @"Should not contain object.");
	STAssertFalse([set containsObject:@"Z"], @"Should not contain object.");
}

- (void) testCount {
	STAssertEquals([set count], (NSUInteger)0, @"Set should be empty.");
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEquals([set count], [array count], @"Set should be empty.");
}

- (void) testDescription {
	STAssertEqualObjects([set description], [[NSArray array] description],
						 @"Wrong description.");

	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEqualObjects([set description], [array description],
						 @"Wrong description.");
}

- (void) testDebugDescription {
	NSString *debugDescription;
	
	NSArray *myArray = [NSArray array];
	NSSet *mySet = [NSSet set];
	
	debugDescription = [NSString stringWithFormat:@"objects = %@,\nordering = %@", [mySet description], [myArray description]];
	
	STAssertEqualObjects([set debugDescription], debugDescription,
						 @"Wrong description.");

	myArray = [NSArray arrayWithObjects:@"B",@"C",@"A",nil];
	mySet = [NSSet setWithArray:myArray];
	[set addObjectsFromArray:myArray];
	
	debugDescription = [NSString stringWithFormat:@"objects = %@,\nordering = %@", [mySet description], [myArray description]];
	
	STAssertEqualObjects([set debugDescription], debugDescription,
						 @"Wrong description.");
}

- (void) testIndexOfObject {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEquals([set indexOfObject:[abc objectAtIndex:i]], i,
					   @"Wrong index for object");
	}
}

- (void) testIntersectsSet {
	NSSet *abc = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	NSSet *cde = [NSSet setWithObjects:@"C",@"D",@"E",nil];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	STAssertFalse([set intersectsSet:abc], @"Should not intersect.");
	[set addObjectsFromArray:[NSArray arrayWithObjects:@"A",@"B",@"C",nil]];
	
	STAssertTrue([set intersectsSet:abc], @"Should intersect.");
	STAssertTrue([set intersectsSet:cde], @"Should intersect.");
	STAssertFalse([set intersectsSet:xyz], @"Should not intersect.");
	
	STAssertFalse([set intersectsSet:nil], @"Should not intersect.");
	STAssertFalse([set intersectsSet:[NSSet set]], @"Should not intersect.");
}

- (void) testIsEqualToSet {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertTrue([set isEqualToSet:[NSSet setWithArray:array]], @"Unequal sets.");
}

- (void) testIsSubsetOfSet {
	NSSet *abc = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[set addObject:@"A"];
	STAssertTrue([set isSubsetOfSet:abc], @"Should be a subset.");
	[set addObject:@"B"];
	STAssertTrue([set isSubsetOfSet:abc], @"Should be a subset.");
	[set addObject:@"C"];
	STAssertTrue([set isSubsetOfSet:abc], @"Should be a subset.");
	[set addObject:@"D"];
	STAssertFalse([set isSubsetOfSet:abc], @"Should not be a subset.");
}

- (void) testMember {
	STAssertNil([set member:@"A"], @"Should not be a member.");
	[set addObject:@"A"];
	STAssertEqualObjects([set member:@"A"], @"A", @"Should be a member.");
	STAssertNil([set member:@"Z"], @"Should not be a member.");
	[set removeAllObjects];
	STAssertNil([set member:@"A"], @"Should not be a member.");
}

- (void) testObjectAtIndex {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEquals([set objectAtIndex:i], [abc objectAtIndex:i],
					   @"Wrong object at index");
	}
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
		STAssertEqualObjects(arrayObject, setObject, @"Error while enumerating.");
	} while (arrayObject && setObject);
}

- (void) testSet {
	STAssertEqualObjects([set set], [NSSet set], @"Set should be empty.");
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEqualObjects([set set], [NSSet setWithArray:array], @"Unequal sets.");
}

#pragma mark Removing Objects

- (void) testIntersectSet {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *cde = [NSArray arrayWithObjects:@"C",@"D",@"E",nil];
	NSArray *def = [NSArray arrayWithObjects:@"D",@"E",@"F",nil];
	NSArray *c = [NSArray arrayWithObjects:@"C",nil];
	NSArray *empty = [NSArray array];
	
	STAssertNoThrow([set intersectSet:nil], @"Should not raise exception");

	// Test intersecting identical sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:abc]];
	STAssertEqualObjects([set allObjects], abc, @"Unexpected ordering.");
	
	// Test intersecting overlapping sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:cde]];
	STAssertEqualObjects([set allObjects], c, @"Unexpected ordering.");
	[set removeAllObjects];
	
	[set addObjectsFromArray:cde];
	[set intersectSet:[NSSet setWithArray:abc]];
	STAssertEqualObjects([set allObjects], c, @"Unexpected ordering.");
	[set removeAllObjects];
	
	// Test intersecting disjoint sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:def]];
	STAssertEqualObjects([set allObjects], empty, @"Unexpected ordering.");
}

- (void) testMinusSet {
	NSArray *axbycz = [NSArray arrayWithObjects:@"A",@"X",@"B",@"Y",@"C",@"Z",nil];
	NSArray *xaybzc = [NSArray arrayWithObjects:@"X",@"A",@"Y",@"B",@"Z",@"C",nil];
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *empty = [NSArray array];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	STAssertNoThrow([set minusSet:nil], @"Should not raise exception");
	STAssertEqualObjects([set allObjects], empty, @"Unexpected ordering.");
	
	[set minusSet:[NSSet set]];
	STAssertEqualObjects([set allObjects], empty, @"Unexpected ordering.");

	[set minusSet:xyz];
	STAssertEqualObjects([set allObjects], empty, @"Unexpected ordering.");
	
	[set addObjectsFromArray:axbycz];
	
	STAssertNoThrow([set minusSet:nil], @"Should not raise exception");
	STAssertEqualObjects([set allObjects], axbycz, @"Unexpected ordering.");

	[set minusSet:[NSSet set]];
	STAssertEqualObjects([set allObjects], axbycz, @"Unexpected ordering.");

	// Test removing even elements
	[set addObjectsFromArray:axbycz];
	STAssertNoThrow([set minusSet:xyz], @"Should not raise exception");
	STAssertEqualObjects([set allObjects], abc, @"Unexpected ordering.");
	[set removeAllObjects];

	// Test removing odd elements
	[set addObjectsFromArray:xaybzc];	
	STAssertNoThrow([set minusSet:xyz], @"Should not raise exception");
	STAssertEqualObjects([set allObjects], abc, @"Unexpected ordering.");
	[set removeAllObjects];
	
	// Test differencing disjoint sets
	[set addObjectsFromArray:abc];
	[set minusSet:xyz];
	STAssertEqualObjects([set allObjects], abc, @"Unexpected ordering.");
	
	// Test differencing identical sets
	[set addObjectsFromArray:abc];
	[set minusSet:[NSSet setWithArray:abc]];
	STAssertEqualObjects([set allObjects], empty, @"Unexpected ordering.");
}

- (void) testRemoveAllObjects {
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertTrue([set count] != 0, @"Count should not be zero.");
	[set removeAllObjects];
	STAssertTrue([set count] == 0, @"Count should be zero.");
}

- (void) testRemoveFirstObject {
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	
	STAssertEqualObjects([set firstObject], @"A", @"Wrong first object.");
	[set removeFirstObject];
	STAssertEqualObjects([set firstObject], @"B", @"Wrong first object.");
	[set removeFirstObject];
	STAssertEqualObjects([set firstObject], @"C", @"Wrong first object.");
	[set removeFirstObject];
	STAssertNil([set firstObject], @"Wrong first object.");
}

- (void) testRemoveLastObject {
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	
	STAssertEqualObjects([set lastObject], @"C", @"Wrong first object.");
	[set removeLastObject];
	STAssertEqualObjects([set lastObject], @"B", @"Wrong first object.");
	[set removeLastObject];
	STAssertEqualObjects([set lastObject], @"A", @"Wrong first object.");
	[set removeLastObject];
	STAssertNil([set lastObject], @"Wrong first object.");
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], @"Should not raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	STAssertTrue([set containsObject:@"A"], @"Should contain object.");
	[set removeObject:@"A"];
	STAssertFalse([set containsObject:@"A"], @"Should not contain object.");
}

- (void) testRemoveObjectAtIndex {
	STAssertThrows([set removeObjectAtIndex:0], @"Should raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	STAssertThrows([set removeObjectAtIndex:[abc count]], @"Should raise exception");
	for (int i = [abc count]-1; i >= 0; i--) {
		STAssertEqualObjects([set lastObject], [abc objectAtIndex:i],
							 @"Wrong object at index before removing at index");
		[set removeObjectAtIndex:i];
	}
}

#pragma mark <Protocols>

- (void) testNSCoding {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEquals([set count], [array count], @"Incorrect count.");
	STAssertEqualObjects([set allObjects], array, @"Wrong ordering before archiving.");
	NSString *filePath = @"/tmp/CHDataStructures-linked-set.plist";
	[NSKeyedArchiver archiveRootObject:set toFile:filePath];

	CHLinkedSet *set2 = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([set2 count], [set count], @"Incorrect count on reconstruction.");
	STAssertEqualObjects([set2 allObjects], [set allObjects], @"Wrong ordering on reconstruction.");
	[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
	[set2 release];
	
}

- (void) testNSCopying {
	[set addObjectsFromArray:[self randomNumbers]];
	CHLinkedSet *copy = [set copy];
	STAssertEquals([set count], [copy count], @"Count mismatch.");
	STAssertEqualObjects([set allObjects], [copy allObjects], @"Wrong ordering.");
}

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (void) testNSFastEnumeration {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *enumerator = [array objectEnumerator];
	for (NSNumber *number in set) {
		STAssertEqualObjects(number, [enumerator nextObject], @"Wrong ordering.");
	}
	STAssertNil([enumerator nextObject], @"Enumerator was not exhausted.");
}
#endif

@end
