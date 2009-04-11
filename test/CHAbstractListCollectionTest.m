/*
 CHDataStructures.framework -- CHAbstractListCollectionTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractListCollection.h"
#import "CHSinglyLinkedList.h"
#import "CHDoublyLinkedList.h"

@interface CHAbstractListCollection (Test)

- (void) addObject:(id)anObject;
- (id<CHLinkedList>) list;

@end

@implementation CHAbstractListCollection (Test)

- (id) init {
	if ([super init] == nil) return nil;
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

- (void) addObject:(id)anObject {
	[list appendObject:anObject];
}

- (id<CHLinkedList>) list {
	return list;
}

@end

#pragma mark -

@interface CHAbstractListCollectionTest : SenTestCase
{
	CHAbstractListCollection *collection;
	NSArray *objects;
}

@end

@implementation CHAbstractListCollectionTest

- (void) setUp {
	collection = [[CHAbstractListCollection alloc] init];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[collection release];
}

#pragma mark -

- (void) testNSCoding {
	for (id object in objects)
		[collection addObject:object];
	STAssertEquals([collection count], [objects count], @"Incorrect count.");
	NSArray *order = [collection allObjects];
	STAssertEqualObjects(order, objects, @"Wrong ordering before archiving.");
	
	NSString *filePath = @"/tmp/CHDataStructures-list-collection.plist";
	[NSKeyedArchiver archiveRootObject:collection toFile:filePath];
	[collection release];
	
	collection = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([collection count], [objects count], @"Incorrect count.");
	order = [collection allObjects];
	STAssertEqualObjects(order, objects, @"Wrong ordering on reconstruction.");
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

- (void) testNSCopying {
	for (id object in objects)
		[collection addObject:object];
	CHAbstractListCollection *collection2 = [collection copy];
	STAssertNotNil(collection2, @"-copy should not return nil for valid collection.");
	STAssertEquals([collection2 count], (NSUInteger)3, @"Incorrect count.");
	STAssertEqualObjects([collection allObjects], [collection2 allObjects],
						 @"Unequal collections.");
	[collection2 release];
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected, count = 0;
	for (number = 1; number <= 32; number++)
		[collection addObject:[NSNumber numberWithUnsignedInteger:number]];
	expected = 1;
	for (NSNumber *object in collection) {
		STAssertEquals([object unsignedIntegerValue], expected++,
					   @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, (NSUInteger)32, @"Count of enumerated items is incorrect.");

	BOOL raisedException = NO;
	@try {
		for (id object in collection)
			[collection addObject:@"123"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, @"Should raise mutation exception.");
}

#pragma mark -

- (void) testInit {
	STAssertNotNil(collection, @"collection should not be nil");
}

- (void) testInitWithArray {
	[collection release];
	collection = [[CHAbstractListCollection alloc] initWithArray:objects];
	STAssertEquals([collection count], (NSUInteger)3, @"Incorrect count.");
	STAssertEqualObjects([collection allObjects], objects,
						 @"Bad array ordering on -initWithArray:");
	
	NSEnumerator *enumerator = [collection objectEnumerator];
	STAssertEqualObjects([enumerator nextObject], @"A", @"Wrong -nextObject.");
	STAssertEqualObjects([enumerator nextObject], @"B", @"Wrong -nextObject.");
	STAssertEqualObjects([enumerator nextObject], @"C", @"Wrong -nextObject.");
	STAssertNil([enumerator nextObject], @"-nextObject should return Nil");
}

- (void) testCount {
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	[collection addObject:@"Hello, World!"];
	STAssertEquals([collection count], (NSUInteger)1, @"Incorrect count.");
}

- (void) testContainsObject {
	for (id object in objects)
		[collection addObject:object];
	STAssertTrue([collection containsObject:@"A"], @"Should contain object");
	STAssertTrue([collection containsObject:@"B"], @"Should contain object");
	STAssertTrue([collection containsObject:@"C"], @"Should contain object");
	STAssertFalse([collection containsObject:@"a"], @"Should NOT contain object");
	STAssertFalse([collection containsObject:@"Z"], @"Should NOT contain object");
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertTrue([collection containsObjectIdenticalTo:a], @"Should return YES.");
	STAssertFalse([collection containsObjectIdenticalTo:@"A"], @"Should return NO.");
	STAssertFalse([collection containsObjectIdenticalTo:@"Z"], @"Should return NO.");
}

- (void) testIndexOfObject {
	for (id object in objects)
		[collection addObject:object];
	STAssertEquals([collection indexOfObject:@"A"], (NSUInteger)0, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"B"], (NSUInteger)1, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"C"], (NSUInteger)2, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"a"], (NSUInteger)CHNotFound,
				   @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"Z"], (NSUInteger)CHNotFound,
				   @"Wrong index for object");
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertEquals([collection indexOfObjectIdenticalTo:a],
				   (NSUInteger)0, @"Wrong index for object");
	STAssertEquals([collection indexOfObjectIdenticalTo:@"A"], (NSUInteger)CHNotFound,
				   @"Wrong index for object");
	STAssertEquals([collection indexOfObjectIdenticalTo:@"Z"], (NSUInteger)CHNotFound,
				   @"Wrong index for object");
}

- (void) testObjectAtIndex {
	for (id object in objects)
		[collection addObject:object];
	STAssertThrows([collection objectAtIndex:-1], @"Bad index should raise exception");
	STAssertEqualObjects([collection objectAtIndex:0], @"A", @"Wrong object at index");
	STAssertEqualObjects([collection objectAtIndex:1], @"B", @"Wrong object at index");
	STAssertEqualObjects([collection objectAtIndex:2], @"C", @"Wrong object at index");
	STAssertThrows([collection objectAtIndex:3], @"Bad index should raise exception");
}

- (void) testAllObjects {
	NSArray *allObjects;
	
	allObjects = [collection allObjects];
	STAssertNotNil(allObjects, @"Array should not be nil");
	STAssertEquals([allObjects count], (NSUInteger)0, @"Incorrect array length.");

	for (id object in objects)
		[collection addObject:object];
	allObjects = [collection allObjects];
	STAssertNotNil(allObjects, @"Array should not be nil");
	STAssertEquals([allObjects count], (NSUInteger)3, @"Incorrect array length.");
}

- (void) testRemoveObject {
	for (id object in objects)
		[collection addObject:object];

	STAssertNoThrow([collection removeObject:nil], @"Should not raise an exception.");

	STAssertEquals([collection count], (NSUInteger)3, @"Incorrect count.");
	[collection removeObject:@"A"];
	STAssertEquals([collection count], (NSUInteger)2, @"Incorrect count.");
	[collection removeObject:@"A"];
	STAssertEquals([collection count], (NSUInteger)2, @"Incorrect count.");
	[collection removeObject:@"Z"];
	STAssertEquals([collection count], (NSUInteger)2, @"Incorrect count.");
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	NSString *b = [NSString stringWithFormat:@"B"];
	[collection addObject:a];
	STAssertEquals([collection count], (NSUInteger)1, @"Incorrect count.");
	[collection removeObjectIdenticalTo:@"A"];
	STAssertEquals([collection count], (NSUInteger)1, @"Incorrect count.");
	[collection removeObjectIdenticalTo:a];
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	[collection removeObjectIdenticalTo:a];
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	
	// Test removing all instances of an object
	[collection addObject:a];
	[collection addObject:b];
	[collection addObject:@"C"];
	[collection addObject:a];
	[collection addObject:b];
	
	STAssertNoThrow([collection removeObjectIdenticalTo:nil], @"Should not raise an exception.");

	STAssertEquals([collection count], (NSUInteger)5, @"Incorrect count.");
	[collection removeObjectIdenticalTo:@"A"];
	STAssertEquals([collection count], (NSUInteger)5, @"Incorrect count.");
	[collection removeObjectIdenticalTo:a];
	STAssertEquals([collection count], (NSUInteger)3, @"Incorrect count.");
	[collection removeObjectIdenticalTo:b];
	STAssertEquals([collection count], (NSUInteger)1, @"Incorrect count.");
}

- (void) testRemoveAllObjects {
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	for (id object in objects)
		[collection addObject:object];
	STAssertEquals([collection count], (NSUInteger)3, @"Incorrect count.");
	[collection removeAllObjects];
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
}

- (void) testObjectEnumerator {
	NSEnumerator *enumerator;
	enumerator = [collection objectEnumerator];
	STAssertNotNil(enumerator, @"-objectEnumerator should NOT return nil.");
	STAssertNil([enumerator nextObject], @"-nextObject should return nil.");
	
	[collection addObject:@"Hello, World!"];
	enumerator = [collection objectEnumerator];
	STAssertNotNil(enumerator, @"-objectEnumerator should NOT return nil.");
	STAssertNotNil([enumerator nextObject], @"-nextObject should NOT return nil.");	
	STAssertNil([enumerator nextObject], @"-nextObject should return nil.");	
}

- (void) testDescription {
	for (id object in objects)
		[collection addObject:object];
	STAssertEqualObjects([collection description], [objects description],
						 @"-description uses bad ordering.");
}

@end
