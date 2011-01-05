/*
 CHDataStructures.framework -- CHAbstractListCollectionTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractListCollection.h"
#import "CHSinglyLinkedList.h"
#import "CHDoublyLinkedList.h"

@interface CHAbstractListCollection (Test)

- (void) addObject:(id)anObject;
- (void) addObjectsFromArray:(NSArray*)anArray;
- (id<CHLinkedList>) list;

@end

@implementation CHAbstractListCollection (Test)

- (id) init {
	if ((self = [super init]) == nil) return nil;
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

- (void) addObject:(id)anObject {
	[list addObject:anObject];
}

- (void) addObjectsFromArray:(NSArray*)anArray {
	[list addObjectsFromArray:anArray];
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
	collection = [[[CHAbstractListCollection alloc] init] autorelease];
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
}

#pragma mark -

- (void) testNSCoding {
	[collection addObjectsFromArray:objects];
	STAssertEquals([collection count], [objects count], nil);
	STAssertEqualObjects([collection allObjects], objects, nil);
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:collection];
	collection = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	STAssertEquals([collection count], [objects count], nil);
	STAssertEqualObjects([collection allObjects], objects, nil);
}

- (void) testNSCopying {
	[collection addObjectsFromArray:objects];
	CHAbstractListCollection *collection2 = [[collection copy] autorelease];
	STAssertNotNil(collection2, nil);
	STAssertEquals([collection2 count], (NSUInteger)3, nil);
	STAssertEqualObjects([collection allObjects], [collection2 allObjects], nil);
}

- (void) testNSFastEnumeration {
	NSUInteger limit = 32;
	for (NSUInteger number = 1; number <= limit; number++)
		[collection addObject:[NSNumber numberWithUnsignedInteger:number]];
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in collection) {
		STAssertEquals([object unsignedIntegerValue], expected++, nil);
		++count;
	}
	STAssertEquals(count, limit, nil);

	BOOL raisedException = NO;
	@try {
		for (id object in collection)
			[collection addObject:@"bogus"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, nil);
}

#pragma mark -

- (void) testInit {
	STAssertNotNil(collection, nil);
}

- (void) testInitWithArray {
	collection = [[CHAbstractListCollection alloc] initWithArray:objects];
	STAssertEquals([collection count], [objects count], nil);
	STAssertEqualObjects([collection allObjects], objects, nil);
}

- (void) testAllObjects {
	// An empty collection should return an empty (but non-nil) object array
	STAssertNotNil([collection allObjects], nil);
	STAssertEquals([[collection allObjects] count], (NSUInteger)0, nil);
	// Test that a non-empty collection returns all objects properly
	[collection addObjectsFromArray:objects];
	STAssertEqualObjects([collection allObjects], objects, nil);
}

- (void) testCount {
	STAssertEquals([collection count], (NSUInteger)0, nil);
	[collection addObject:@"Hello, World!"];
	STAssertEquals([collection count], (NSUInteger)1, nil);
}

- (void) testContainsObject {
	// An empty collection should not contain any objects we test for
	for (NSUInteger i = 0; i < [objects count]; i++)
		STAssertFalse([collection containsObject:[objects objectAtIndex:i]], nil);
	STAssertFalse([collection containsObject:@"bogus"], nil);
	// Add objects and test for inclusion of each, plus non-member object
	[collection addObjectsFromArray:objects];
	for (NSUInteger i = 0; i < [objects count]; i++)
		STAssertTrue([collection containsObject:[objects objectAtIndex:i]], nil);
	STAssertFalse([collection containsObject:@"bogus"], nil);
}

- (void) testDescription {
	[collection addObjectsFromArray:objects];
	STAssertEqualObjects([collection description], [objects description], nil);
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	// When the list is empty, calls with any index should raise exception
	STAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:0], nil);
	// When either index exceeds the bounds, an exception should be raised
	STAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:1], nil);
	STAssertThrows([collection exchangeObjectAtIndex:1 withObjectAtIndex:0], nil);
	[collection addObjectsFromArray:objects];
	NSUInteger count = [objects count];
	STAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:count], nil);
	STAssertThrows([collection exchangeObjectAtIndex:count withObjectAtIndex:0], nil);
	// Attempting to swap an index with itself should have no effect
	for (NSUInteger i = 0; i < count; i++) {
		STAssertNoThrow([collection exchangeObjectAtIndex:i withObjectAtIndex:i], nil);
		STAssertEqualObjects([collection allObjects], objects, nil);
	}
	// Swap first and last elements
	STAssertNoThrow([collection exchangeObjectAtIndex:0 withObjectAtIndex:2], nil);
	STAssertEqualObjects([collection allObjects], [[objects reverseObjectEnumerator] allObjects], nil);
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertTrue([collection containsObjectIdenticalTo:a], nil);
	STAssertFalse([collection containsObjectIdenticalTo:@"A"], nil);
	STAssertFalse([collection containsObjectIdenticalTo:@"bogus"], nil);
}

- (void) testIndexOfObject {
	// An empty collection should return NSNotFound any objects we test for
	for (NSUInteger i = 0; i < [objects count]; i++)
		STAssertEquals([collection indexOfObject:[objects objectAtIndex:i]],
					   (NSUInteger)NSNotFound, nil);
	STAssertEquals([collection indexOfObject:@"Z"], (NSUInteger)NSNotFound, nil);
	// Add objects and test index of each, plus non-member object
	[collection addObjectsFromArray:objects];
	for (NSUInteger i = 0; i < [objects count]; i++)
		STAssertEquals([collection indexOfObject:[objects objectAtIndex:i]], i, nil);
	STAssertEquals([collection indexOfObject:@"Z"], (NSUInteger)NSNotFound, nil);
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertEquals([collection indexOfObjectIdenticalTo:a], (NSUInteger)0, nil);
	STAssertEquals([collection indexOfObjectIdenticalTo:@"A"], (NSUInteger)NSNotFound, nil);
	STAssertEquals([collection indexOfObjectIdenticalTo:@"Z"], (NSUInteger)NSNotFound, nil);
}

- (void) testObjectAtIndex {
	[collection addObjectsFromArray:objects];
	// Test all three valid indexes and the boundary conditions
	STAssertThrows([collection objectAtIndex:-1], nil);
	STAssertEqualObjects([collection objectAtIndex:0], @"A", nil);
	STAssertEqualObjects([collection objectAtIndex:1], @"B", nil);
	STAssertEqualObjects([collection objectAtIndex:2], @"C", nil);
	STAssertThrows([collection objectAtIndex:3], nil);
}

- (void) testObjectEnumerator {
	NSEnumerator *enumerator;
	enumerator = [collection objectEnumerator];
	STAssertNotNil(enumerator, nil);
	STAssertNil([enumerator nextObject], nil);
	
	[collection addObject:@"Hello, World!"];
	enumerator = [collection objectEnumerator];
	STAssertNotNil(enumerator, nil);
	STAssertNotNil([enumerator nextObject], nil);	
	STAssertNil([enumerator nextObject], nil);	
}

- (void) testObjectsAtIndexes {
	[collection addObjectsFromArray:objects];
	NSUInteger count = [collection count];
	NSRange range;
	for (NSUInteger location = 0; location <= count; location++) {
		range.location = location;
		for (NSUInteger length = 0; length <= count - location + 1; length++) {
			range.length = length;
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
			if (location + length > count) {
				STAssertThrows([collection objectsAtIndexes:indexes], nil);
			} else {
				STAssertEqualObjects([collection objectsAtIndexes:indexes],
									 [objects objectsAtIndexes:indexes], nil);
			}
		}
	}
	STAssertThrows([collection objectsAtIndexes:nil], nil);
}

- (void) testRemoveAllObjects {
	STAssertEquals([collection count], (NSUInteger)0, nil);
	[collection addObjectsFromArray:objects];
	STAssertEquals([collection count], (NSUInteger)3, nil);
	[collection removeAllObjects];
	STAssertEquals([collection count], (NSUInteger)0, nil);
}

- (void) testRemoveObject {
	[collection addObjectsFromArray:objects];

	STAssertNoThrow([collection removeObject:nil], nil);

	STAssertEquals([collection count], (NSUInteger)3, nil);
	[collection removeObject:@"A"];
	STAssertEquals([collection count], (NSUInteger)2, nil);
	[collection removeObject:@"A"];
	STAssertEquals([collection count], (NSUInteger)2, nil);
	[collection removeObject:@"Z"];
	STAssertEquals([collection count], (NSUInteger)2, nil);
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	NSString *b = [NSString stringWithFormat:@"B"];
	[collection addObject:a];
	STAssertEquals([collection count], (NSUInteger)1, nil);
	[collection removeObjectIdenticalTo:@"A"];
	STAssertEquals([collection count], (NSUInteger)1, nil);
	[collection removeObjectIdenticalTo:a];
	STAssertEquals([collection count], (NSUInteger)0, nil);
	[collection removeObjectIdenticalTo:a];
	STAssertEquals([collection count], (NSUInteger)0, nil);
	
	// Test removing all instances of an object
	[collection addObject:a];
	[collection addObject:b];
	[collection addObject:@"C"];
	[collection addObject:a];
	[collection addObject:b];
	
	STAssertNoThrow([collection removeObjectIdenticalTo:nil], nil);

	STAssertEquals([collection count], (NSUInteger)5, nil);
	[collection removeObjectIdenticalTo:@"A"];
	STAssertEquals([collection count], (NSUInteger)5, nil);
	[collection removeObjectIdenticalTo:a];
	STAssertEquals([collection count], (NSUInteger)3, nil);
	[collection removeObjectIdenticalTo:b];
	STAssertEquals([collection count], (NSUInteger)1, nil);
}

- (void) testRemoveObjectAtIndex {
	// Test removing from any index in an empty collection
	STAssertThrows([collection removeObjectAtIndex:0], nil);
	STAssertThrows([collection removeObjectAtIndex:NSNotFound], nil);
	// Add objects and test removing from an index out of the reciever's bounds
	[collection addObjectsFromArray:objects];
	STAssertThrows([collection removeObjectAtIndex:3], nil);
	STAssertThrows([collection removeObjectAtIndex:-1], nil);
	// Test removing from valid indexes and verify results
	[collection removeObjectAtIndex:2];
	STAssertEquals([collection count], (NSUInteger)2, nil);
	STAssertEqualObjects([collection objectAtIndex:0], @"A", nil);
	STAssertEqualObjects([collection objectAtIndex:1], @"B", nil);
	[collection removeObjectAtIndex:0];
	STAssertEquals([collection count], (NSUInteger)1, nil);
	STAssertEqualObjects([collection objectAtIndex:0], @"B", nil);
	[collection removeObjectAtIndex:0];
	STAssertEquals([collection count], (NSUInteger)0, nil);
	// Test removing from an index in the middle of the collection
	[collection addObjectsFromArray:objects];
	[collection removeObjectAtIndex:1];
	STAssertEquals([collection count], (NSUInteger)2, nil);
	STAssertEqualObjects([collection objectAtIndex:0], @"A", nil);
	STAssertEqualObjects([collection objectAtIndex:1], @"C", nil);
}

- (void) testRemoveObjectsAtIndexes {
	// Test removing with invalid indexes
	STAssertThrows([collection removeObjectsAtIndexes:nil], nil);
	NSMutableIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	STAssertThrows([collection removeObjectsAtIndexes:indexes], nil);
	
	NSMutableArray* expected = [NSMutableArray array];
	[collection addObjectsFromArray:objects];
	for (NSUInteger location = 0; location < [objects count]; location++) {
		for (NSUInteger length = 0; length <= [objects count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate list and expected
			[expected removeAllObjects];
			[expected addObjectsFromArray:objects];
			[expected removeObjectsAtIndexes:indexes];
			[collection removeAllObjects];
			[collection addObjectsFromArray:objects];
			STAssertNoThrow([collection removeObjectsAtIndexes:indexes], nil);
			STAssertEquals([collection count], [expected count], nil);
			STAssertEqualObjects([collection allObjects], expected, nil);
		}
	}	
	STAssertThrows([collection removeObjectsAtIndexes:nil], nil);
	// Try removing first and last elements, leaving middle element
	indexes = [NSMutableIndexSet indexSet];
	[indexes addIndex:0];
	[indexes addIndex:2];
	[expected removeAllObjects];
	[expected addObjectsFromArray:objects];
	[expected removeObjectsAtIndexes:indexes];
	[collection removeAllObjects];
	[collection addObjectsFromArray:objects];
	STAssertNoThrow([collection removeObjectsAtIndexes:indexes], nil);
	STAssertEquals([collection count], [expected count], nil);
	STAssertEqualObjects([collection allObjects], expected, nil);
}

- (void) testReplaceObjectAtIndexWithObject {
	// Test replacing objects at invalid indexes
	STAssertThrows([collection replaceObjectAtIndex:0 withObject:nil], nil);
	STAssertThrows([collection replaceObjectAtIndex:NSNotFound withObject:nil], nil);
	// Test replacing objects at valid indexes and verify results
	[collection addObjectsFromArray:objects];
	for (NSUInteger i = 0; i < [objects count]; i++) {
		STAssertEqualObjects([collection objectAtIndex:i], [objects objectAtIndex:i], nil);
		STAssertNoThrow([collection replaceObjectAtIndex:i withObject:@"Z"], nil);
		STAssertEqualObjects([collection objectAtIndex:i], @"Z", nil);
	}
}

@end
