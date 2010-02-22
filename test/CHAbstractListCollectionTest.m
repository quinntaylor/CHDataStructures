/*
 CHDataStructures.framework -- CHAbstractListCollectionTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
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
	collection = [[CHAbstractListCollection alloc] init];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[collection release];
}

#pragma mark -

- (void) testNSCoding {
	[collection addObjectsFromArray:objects];
	STAssertEquals([collection count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([collection allObjects], objects, @"Wrong ordering before archiving.");
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:collection];
	[collection release];
	collection = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	STAssertEquals([collection count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([collection allObjects], objects, @"Wrong ordering on reconstruction.");
}

- (void) testNSCopying {
	[collection addObjectsFromArray:objects];
	CHAbstractListCollection *collection2 = [collection copy];
	STAssertNotNil(collection2, @"-copy should not return nil for valid collection.");
	STAssertEquals([collection2 count], (NSUInteger)3, @"Incorrect count.");
	STAssertEqualObjects([collection allObjects], [collection2 allObjects],
						 @"Unequal collections.");
	[collection2 release];
}

#if OBJC_API_2
- (void) testNSFastEnumeration {
	NSUInteger limit = 32;
	for (NSUInteger number = 1; number <= limit; number++)
		[collection addObject:[NSNumber numberWithUnsignedInteger:number]];
	NSUInteger expected = 1, count = 0;
	for (NSNumber *object in collection) {
		STAssertEquals([object unsignedIntegerValue], expected++,
					   @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, limit, @"Count of enumerated items is incorrect.");

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
#endif

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

- (void) testAllObjects {
	NSArray *allObjects;
	
	allObjects = [collection allObjects];
	STAssertNotNil(allObjects, @"Array should not be nil");
	STAssertEquals([allObjects count], (NSUInteger)0, @"Incorrect array length.");
	
	[collection addObjectsFromArray:objects];
	allObjects = [collection allObjects];
	STAssertNotNil(allObjects, @"Array should not be nil");
	STAssertEquals([allObjects count], (NSUInteger)3, @"Incorrect array length.");
}

- (void) testCount {
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	[collection addObject:@"Hello, World!"];
	STAssertEquals([collection count], (NSUInteger)1, @"Incorrect count.");
}

- (void) testContainsObject {
	[collection addObjectsFromArray:objects];
	STAssertTrue([collection containsObject:@"A"], @"Should contain object");
	STAssertTrue([collection containsObject:@"B"], @"Should contain object");
	STAssertTrue([collection containsObject:@"C"], @"Should contain object");
	STAssertFalse([collection containsObject:@"a"], @"Should NOT contain object");
	STAssertFalse([collection containsObject:@"Z"], @"Should NOT contain object");
}

- (void) testDescription {
	[collection addObjectsFromArray:objects];
	STAssertEqualObjects([collection description], [objects description],
						 @"-description uses bad ordering.");
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	STAssertThrows([collection exchangeObjectAtIndex:0 withObjectAtIndex:1],
				   @"Should raise exception, collection is empty.");
	STAssertThrows([collection exchangeObjectAtIndex:1 withObjectAtIndex:0],
				   @"Should raise exception, collection is empty.");
	
	[collection addObjectsFromArray:objects];
	
	[collection exchangeObjectAtIndex:1 withObjectAtIndex:1];
	STAssertEqualObjects([collection allObjects], objects,
	                     @"Should have no effect.");
	[collection exchangeObjectAtIndex:0 withObjectAtIndex:2];
	STAssertEqualObjects([collection allObjects], [[objects reverseObjectEnumerator] allObjects],
	                     @"Should swap first and last element.");
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertTrue([collection containsObjectIdenticalTo:a], @"Should return YES.");
	STAssertFalse([collection containsObjectIdenticalTo:@"A"], @"Should return NO.");
	STAssertFalse([collection containsObjectIdenticalTo:@"Z"], @"Should return NO.");
}

- (void) testIndexOfObject {
	[collection addObjectsFromArray:objects];
	STAssertEquals([collection indexOfObject:@"A"], (NSUInteger)0, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"B"], (NSUInteger)1, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"C"], (NSUInteger)2, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"a"], (NSUInteger)NSNotFound,
				   @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"Z"], (NSUInteger)NSNotFound,
				   @"Wrong index for object");
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertEquals([collection indexOfObjectIdenticalTo:a],
				   (NSUInteger)0, @"Wrong index for object");
	STAssertEquals([collection indexOfObjectIdenticalTo:@"A"], (NSUInteger)NSNotFound,
				   @"Wrong index for object");
	STAssertEquals([collection indexOfObjectIdenticalTo:@"Z"], (NSUInteger)NSNotFound,
				   @"Wrong index for object");
}

- (void) testObjectAtIndex {
	[collection addObjectsFromArray:objects];
	STAssertThrows([collection objectAtIndex:-1], @"Bad index should raise exception");
	STAssertEqualObjects([collection objectAtIndex:0], @"A", @"Wrong object at index");
	STAssertEqualObjects([collection objectAtIndex:1], @"B", @"Wrong object at index");
	STAssertEqualObjects([collection objectAtIndex:2], @"C", @"Wrong object at index");
	STAssertThrows([collection objectAtIndex:3], @"Bad index should raise exception");
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
				STAssertThrows([collection objectsAtIndexes:indexes], @"Range exception");
			} else {
				STAssertEqualObjects([collection objectsAtIndexes:indexes],
									 [objects objectsAtIndexes:indexes],
									 @"Range selections should be equal.");
			}
		}
	}
	STAssertThrows([collection objectsAtIndexes:nil], @"Nil argument.");
}

- (void) testRemoveAllObjects {
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	[collection addObjectsFromArray:objects];
	STAssertEquals([collection count], (NSUInteger)3, @"Incorrect count.");
	[collection removeAllObjects];
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
}

- (void) testRemoveObject {
	[collection addObjectsFromArray:objects];

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

- (void) testRemoveObjectAtIndex {
	[collection addObjectsFromArray:objects];
	
	STAssertThrows([collection removeObjectAtIndex:3], @"Should raise NSRangeException.");
	STAssertThrows([collection removeObjectAtIndex:-1], @"Should raise NSRangeException.");
	
	[collection removeObjectAtIndex:2];
	STAssertEquals([collection count], (NSUInteger)2, @"Incorrect count.");
	STAssertEqualObjects([collection objectAtIndex:0], @"A", @"Wrong first object.");
	STAssertEqualObjects([collection objectAtIndex:1], @"B", @"Wrong last object.");
	
	[collection removeObjectAtIndex:0];
	STAssertEquals([collection count], (NSUInteger)1, @"Incorrect count.");
	STAssertEqualObjects([collection objectAtIndex:0], @"B", @"Wrong first object.");
	
	[collection removeObjectAtIndex:0];
	STAssertEquals([collection count], (NSUInteger)0, @"Incorrect count.");
	
	// Test removing from an index in the middle
	[collection addObjectsFromArray:objects];
	
	[collection removeObjectAtIndex:1];
	STAssertEquals([collection count], (NSUInteger)2, @"Incorrect count.");
	STAssertEqualObjects([collection objectAtIndex:0], @"A", @"Wrong first object.");
	STAssertEqualObjects([collection objectAtIndex:1], @"C", @"Wrong last object.");
}

- (void) testRemoveObjectsAtIndexes {
	STAssertThrows([collection removeObjectsAtIndexes:nil], @"Index set cannot be nil.");
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	STAssertThrows([collection removeObjectsAtIndexes:indexes], @"Nonexistent index.");
	
	NSMutableArray* expected = [NSMutableArray array];
	[collection addObjectsFromArray:objects];
	for (NSUInteger location = 0; location < [objects count]; location++) {
		for (NSUInteger length = 0; length <= [objects count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate list and expected
			[expected removeAllObjects];
			[expected addObjectsFromArray:objects];
			[collection removeAllObjects];
			[collection addObjectsFromArray:objects];
			STAssertNoThrow([collection removeObjectsAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			[expected removeObjectsAtIndexes:indexes];
			STAssertEquals([collection count], [expected count], @"Wrong count");
			STAssertEqualObjects([collection allObjects], expected, @"Array content mismatch.");
		}
	}	
	STAssertThrows([collection removeObjectsAtIndexes:nil], @"Nil argument.");
}

- (void) testReplaceObjectAtIndexWithObject {
	STAssertThrows([collection replaceObjectAtIndex:0 withObject:nil],
	               @"Should raise index exception.");
	STAssertThrows([collection replaceObjectAtIndex:1 withObject:nil],
	               @"Should raise index exception.");
	
	[collection addObjectsFromArray:objects];
	
	for (NSUInteger i = 0; i < [objects count]; i++) {
		STAssertEqualObjects([collection objectAtIndex:i], [objects objectAtIndex:i],
		                     @"Incorrect object.");
		[collection replaceObjectAtIndex:i withObject:@"Z"];
		STAssertEqualObjects([collection objectAtIndex:i], @"Z",
		                     @"Incorrect object.");
	}
}

@end
