/*
 CHDataStructures.framework -- CHLinkedSetTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLinkedSet.h"

@interface CHLinkedSetTest : SenTestCase {
	CHLinkedSet *set;
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
		number = [NSNumber numberWithUnsignedInteger:arc4random()];
		if ([array containsObject:number])
			count--;
		else
			[array addObject:[NSNumber numberWithUnsignedInteger:arc4random()]];
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

- (void) testAddObject {
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];

	[set removeAllObjects];
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];
}

- (void) testAddObjectsFromArray {
}

- (void) testUnionSet {
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
	
	[set removeAllObjects];
	STAssertFalse([set repeatObjectsMoveToBack], @"Should be false by default.");
	[set setRepeatObjectsMoveToBack:YES];
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];
	array = [NSArray arrayWithObjects:@"B",@"C",@"A",nil];
	STAssertEqualObjects([set allObjects], array, @"Wrong ordering from -allObjects.");

	[set addObject:@"C"];
	[set addObject:@"B"];
	array = [NSArray arrayWithObjects:@"A",@"C",@"B",nil];
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
}

- (void) testDebugDescription {
}

- (void) testFirstObjectAndLastObject {
	[set setRepeatObjectsMoveToBack:YES];
	STAssertNil([set firstObject], @"Should be nil.");
	STAssertNil([set lastObject],  @"Should be nil.");
	[set addObject:@"A"];
	STAssertEqualObjects([set firstObject], @"A", @"Incorrect first object.");
	STAssertEqualObjects([set lastObject],  @"A", @"Incorrect first object.");
	[set addObject:@"B"];
	STAssertEqualObjects([set firstObject], @"A", @"Incorrect first object.");
	STAssertEqualObjects([set lastObject],  @"B", @"Incorrect first object.");
	[set addObject:@"C"];
	STAssertEqualObjects([set firstObject], @"A", @"Incorrect first object.");
	STAssertEqualObjects([set lastObject],  @"C", @"Incorrect first object.");
	[set addObject:@"A"];
	STAssertEqualObjects([set firstObject], @"B", @"Incorrect first object.");
	STAssertEqualObjects([set lastObject],  @"A", @"Incorrect first object.");
	[set removeObject:@"A"];
	STAssertEqualObjects([set firstObject], @"B", @"Incorrect first object.");
	STAssertEqualObjects([set lastObject],  @"C", @"Incorrect first object.");
}

- (void) testIntersectsSet {
}

- (void) testIsEqualToSet {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertTrue([set isEqualToSet:[NSSet setWithArray:array]], @"Unequal sets.");
}

- (void) testIsSubsetOfSet {
	NSSet *test = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[set addObject:@"A"];
	STAssertTrue([set isSubsetOfSet:test], @"Should be a subset.");
	[set addObject:@"B"];
	STAssertTrue([set isSubsetOfSet:test], @"Should be a subset.");
	[set addObject:@"C"];
	STAssertTrue([set isSubsetOfSet:test], @"Should be a subset.");
	[set addObject:@"D"];
	STAssertFalse([set isSubsetOfSet:test], @"Should not be a subset.");
}

- (void) testMember {
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
}

- (void) testMinusSet {
}

- (void) testRemoveAllObjects {
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertTrue([set count] != 0, @"Count should not be zero.");
	[set removeAllObjects];
	STAssertTrue([set count] == 0, @"Count should be zero.");
}

- (void) testRemoveFirstObject {
}

- (void) testRemoveLastObject {
}

- (void) testRemoveObject {
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
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	[set2 release];
	
}

- (void) testNSCopying {
	[set addObjectsFromArray:[self randomNumbers]];
	CHLinkedSet *copy = [set copy];
	STAssertEquals([set count], [copy count], @"Count mismatch.");
	STAssertEqualObjects([set allObjects], [copy allObjects], @"Wrong ordering.");
}

- (void) testNSFastEnumeration {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *enumerator = [array objectEnumerator];
	for (NSNumber *number in set) {
		STAssertEqualObjects(number, [enumerator nextObject], @"Wrong ordering.");
	}
	STAssertNil([enumerator nextObject], @"Enumerator was not exhausted.");
}

@end
