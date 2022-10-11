//
//  CHCircularBufferTest.m
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHCircularBuffer.h>
#import <CHDataStructures/CHUtil.h>
#import "NSObject+TestUtilities.h"

static NSArray *abc;

@interface CHCircularBuffer (Internals)

- (NSUInteger)capacity;
- (NSUInteger)distanceFromHeadToTail;

@end

@implementation CHCircularBuffer (Internals)

- (NSUInteger)capacity {
	return arrayCapacity;
}

- (NSUInteger)distanceFromHeadToTail {
	return (tailIndex - headIndex + arrayCapacity) % arrayCapacity;
}

@end

#pragma mark -

@interface CHCircularBufferTest : XCTestCase
{
	CHCircularBuffer *buffer;
	NSMutableArray *fifteen;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHCircularBufferTest

+ (void)initialize {
	abc = @[@"A",@"B",@"C"];
}

- (void)setUp {
	buffer = [[[CHCircularBuffer alloc] init] autorelease];
	fifteen = [[NSMutableArray alloc] init];
	for (int i = 1; i <= 15; i++) {
		[fifteen addObject:@(i)];
	}
}

// This macro checks tail-head (accounting for wrapping) against the count.
#define checkCountAndDistanceFromHeadToTail(e) \
do { \
	NSUInteger expected = e; \
	XCTAssertEqual([buffer count], expected); \
	XCTAssertEqual([buffer distanceFromHeadToTail], expected); \
} while (0)
	
- (void)testInit {
	XCTAssertEqual([buffer capacity], 16);
	checkCountAndDistanceFromHeadToTail(0);
}

- (void)testInitWithArray {
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 1; i <= 15; i++) {
		[array addObject:@(i)];
	}
	buffer = [[[CHCircularBuffer alloc] initWithArray:array] autorelease];
	XCTAssertEqual([buffer capacity], 16);
	checkCountAndDistanceFromHeadToTail(15);
	
	[array addObject:@(16)];
	buffer = [[[CHCircularBuffer alloc] initWithArray:array] autorelease];
	XCTAssertEqual([buffer capacity], 32);
	checkCountAndDistanceFromHeadToTail(16);
	
	for (int i = 17; i <= 33; i++) {
		[array addObject:@(i)];
	}
	buffer = [[[CHCircularBuffer alloc] initWithArray:array] autorelease];
	XCTAssertEqual([buffer capacity], 64);
	checkCountAndDistanceFromHeadToTail(33);
}

- (void)testInitWithCapacity {
	// Test initializing with valid capacity
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:8] autorelease];
	XCTAssertEqual([buffer capacity], 8);
	checkCountAndDistanceFromHeadToTail(0);
	// Test initializing with invalid capacity
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:0] autorelease];
	XCTAssertTrue([buffer capacity] != 0);
	checkCountAndDistanceFromHeadToTail(0);
}

#pragma mark Insertion

- (void)testAddObject {
	[buffer addObject:@"A"];
	checkCountAndDistanceFromHeadToTail(1);
	[buffer addObject:@"B"];
	checkCountAndDistanceFromHeadToTail(2);
	[buffer addObject:@"C"];
	checkCountAndDistanceFromHeadToTail(3);
	
	// Force expansion of original capacity
	buffer = [[[CHCircularBuffer alloc] init] autorelease];
	for (int i = 1; i <= 16; i++) {
		[buffer addObject:@(i)];
	}
	XCTAssertEqual([buffer capacity], 32);
	for (int i = 17; i <= 33; i++) {
		[buffer addObject:@(i)];
	}
	XCTAssertEqual([buffer capacity], 64);
}

- (void)testInsertObjectAtIndex {
	// Any non-zero index on empty array should raise an exception
	XCTAssertThrows([buffer insertObject:@"Z" atIndex:1]);
	// Insert in the middle of a non-wrapping buffer; tail should get pushed right
	[buffer addObject:@"W"];
	[buffer insertObject:@"Z" atIndex:1];
	[buffer insertObject:@"Y" atIndex:1];
	[buffer insertObject:@"X" atIndex:1];
	XCTAssertEqualObjects(buffer, (@[@"W",@"X",@"Y",@"Z"]));
	[buffer removeAllObjects];
	// Insert some at the front to force the buffer to "wrap around" backwards.
	NSMutableArray *correct = [NSMutableArray arrayWithArray:abc];
	[correct addObject:@"D"];
	e = [abc reverseObjectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer insertObject:anObject atIndex:0];
	}
	[buffer addObject:@"D"];
	XCTAssertEqualObjects(buffer, correct);
	checkCountAndDistanceFromHeadToTail([correct count]);
	// Test inserting in the middle of both halves of a wrapped-around buffer
	[buffer  insertObject:@"X" atIndex:1];
	[correct insertObject:@"X" atIndex:1];
	checkCountAndDistanceFromHeadToTail([correct count]);
	XCTAssertEqualObjects(buffer, correct);
	[buffer  insertObject:@"Y" atIndex:3];
	[correct insertObject:@"Y" atIndex:3];
	checkCountAndDistanceFromHeadToTail([correct count]);
	XCTAssertEqualObjects(buffer, correct);
	[buffer  insertObject:@"Z" atIndex:5];
	[correct insertObject:@"Z" atIndex:5];
	checkCountAndDistanceFromHeadToTail([correct count]);
	XCTAssertEqualObjects(buffer, correct);
}

- (void)testExchangeObjectAtIndexWithObjectAtIndex {
	// When the buffer is empty, calls with any index should raise exception
	XCTAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:0]);
	XCTAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:1]);
	XCTAssertThrows([buffer exchangeObjectAtIndex:1 withObjectAtIndex:0]);
	// When either index exceeds the bounds, an exception should be raised
	[buffer addObjectsFromArray:abc];
	XCTAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:[abc count]]);
	XCTAssertThrows([buffer exchangeObjectAtIndex:[abc count] withObjectAtIndex:0]);
	// Attempting to swap an index with itself should have no effect
	for (NSUInteger i = 0; i < [abc count]; i++) {
		[buffer exchangeObjectAtIndex:i withObjectAtIndex:i];
		XCTAssertEqualObjects([buffer allObjects], abc);
	}
	// Test exchanging objects and verify correctness of swaps
	[buffer exchangeObjectAtIndex:0 withObjectAtIndex:2];
	XCTAssertEqualObjects([buffer firstObject],     @"C");
	XCTAssertEqualObjects([buffer lastObject],      @"A");
	[buffer exchangeObjectAtIndex:0 withObjectAtIndex:1];
	XCTAssertEqualObjects([buffer firstObject],     @"B");
	XCTAssertEqualObjects([buffer objectAtIndex:1], @"C");
	[buffer exchangeObjectAtIndex:2 withObjectAtIndex:1];
	XCTAssertEqualObjects([buffer objectAtIndex:1], @"A");
	XCTAssertEqualObjects([buffer lastObject],      @"C");	
}

#pragma mark Access

- (void)testCount {
	XCTAssertEqual([buffer count], 0);
	[buffer addObjectsFromArray:abc];
	XCTAssertEqual([buffer count], [abc count]);
}

- (void)testAllObjects {
	XCTAssertNotNil([buffer allObjects]);
	XCTAssertEqual([[buffer allObjects] count], 0);
	
	[buffer addObjectsFromArray:abc];
	XCTAssertEqualObjects([buffer allObjects], abc);
	
	// Test -allObjects when the buffer wraps around to the beginning
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer removeFirstObject];
	}
	checkCountAndDistanceFromHeadToTail(0);
	NSMutableArray *objects = [NSMutableArray array];
	for (int i = 1; i < 16; i++) {
		[objects addObject:@(i)];
	}
	[buffer addObjectsFromArray:objects];
	XCTAssertEqual([buffer count], [objects count]);
	XCTAssertEqualObjects([buffer allObjects], objects);
}

- (void)testEnumerator {
	XCTAssertNil([[buffer objectEnumerator] nextObject]);
	XCTAssertNotNil([[buffer objectEnumerator] allObjects]);
	XCTAssertEqual([[[buffer objectEnumerator] allObjects] count], 0);

	XCTAssertNil([[buffer reverseObjectEnumerator] nextObject]);
	XCTAssertNotNil([[buffer reverseObjectEnumerator] allObjects]);
	XCTAssertEqual([[[buffer reverseObjectEnumerator] allObjects] count], 0);
	
	[buffer addObjectsFromArray:abc];
	
	NSArray *allObjects;
	
	// Test forward enumeration
	e = [buffer objectEnumerator];
	allObjects = [e allObjects];
	XCTAssertEqual([allObjects count], [abc count]);
	XCTAssertEqualObjects(allObjects, abc);
	
	e = [buffer objectEnumerator];
	[e nextObject];
	allObjects = [e allObjects];
	XCTAssertEqual([allObjects count], [abc count]-1);
	
	e = [buffer objectEnumerator];
	XCTAssertEqualObjects([e nextObject], @"A");
	XCTAssertEqualObjects([e nextObject], @"B");
	XCTAssertEqualObjects([e nextObject], @"C");
	XCTAssertNil([e nextObject]);
	
	// Cause mutation exception
	[buffer addObject:@"Z"];
	XCTAssertThrows([e nextObject]);
	XCTAssertThrows([e allObjects]);
	[buffer removeLastObject];

	// Test reverse enumeration
	e = [buffer reverseObjectEnumerator];
	allObjects = [e allObjects];
	XCTAssertEqual([allObjects count], [abc count]);
	XCTAssertEqualObjects(allObjects, [[abc reverseObjectEnumerator] allObjects]);
	
	e = [buffer reverseObjectEnumerator];
	[e nextObject];
	allObjects = [e allObjects];
	XCTAssertEqual([allObjects count], [abc count]-1);
	
	e = [buffer reverseObjectEnumerator];
	XCTAssertEqualObjects([e nextObject], @"C");
	XCTAssertEqualObjects([e nextObject], @"B");
	XCTAssertEqualObjects([e nextObject], @"A");
	XCTAssertNil([e nextObject]);

	// Cause mutation exception
	[buffer addObject:@"bogus"];
	XCTAssertThrows([e nextObject]);
	XCTAssertThrows([e allObjects]);
	[buffer removeLastObject];
}

- (void)testDescription {
	XCTAssertEqualObjects([buffer description], [[buffer allObjects] description]);
	[buffer addObjectsFromArray:abc];
	XCTAssertEqualObjects([buffer description], [[buffer allObjects] description]);
}

#pragma mark Search

- (void)testContainsObject {
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertFalse([buffer containsObject:anObject]);
	}
	XCTAssertFalse([buffer containsObject:@"bogus"]);
	[buffer addObjectsFromArray:abc];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertTrue([buffer containsObject:anObject]);
	}
	XCTAssertFalse([buffer containsObject:@"bogus"]);
}

- (void)testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertFalse([buffer containsObjectIdenticalTo:anObject]);
	}
	XCTAssertFalse([buffer containsObjectIdenticalTo:@"bogus"]);
	XCTAssertFalse([buffer containsObjectIdenticalTo:a]);
	[buffer addObjectsFromArray:abc];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertTrue([buffer containsObjectIdenticalTo:anObject]);
	}
	XCTAssertFalse([buffer containsObjectIdenticalTo:@"bogus"]);
	XCTAssertFalse([buffer containsObjectIdenticalTo:a]);
}

- (void)testIndexOfObject {
	XCTAssertEqual([buffer indexOfObject:@"bogus"], NSNotFound);
	// Move the head index to 3 so adding 15 objects will wrap.
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer addObject:anObject];
		[buffer removeFirstObject];
	}
	[buffer addObjectsFromArray:fifteen];
	
	NSUInteger expectedIndex = 0;
	e = [fifteen objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertEqual([buffer indexOfObject:anObject], expectedIndex++);
	}
	XCTAssertEqual([buffer indexOfObject:@"bogus"], NSNotFound);
}

- (void)testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:@"bogus"], NSNotFound);
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:a],        NSNotFound);
	// Move the head index to 3 so adding 15 objects will wrap.
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer addObject:anObject];
		[buffer removeFirstObject];
	}
	[buffer addObjectsFromArray:fifteen];

	NSUInteger expectedIndex = 0;
	e = [fifteen objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertEqual([buffer indexOfObjectIdenticalTo:anObject], expectedIndex++);
	}
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:@"bogus"], NSNotFound);
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:a],        NSNotFound);
}

- (void)testIndexOfObjectInRange {
	XCTAssertThrows([buffer indexOfObject:nil inRange:NSMakeRange(0, 1)]);
	XCTAssertThrows([buffer indexOfObject:nil inRange:NSMakeRange(0, 0)]);
	[buffer addObjectsFromArray:abc];
	NSRange range = NSMakeRange(1, 1);
	XCTAssertEqual([buffer indexOfObject:@"A" inRange:range], NSNotFound);
	XCTAssertEqual([buffer indexOfObject:@"B" inRange:range], 1);
	XCTAssertEqual([buffer indexOfObject:@"C" inRange:range], NSNotFound);
}

- (void)testIndexOfObjectIdenticalToInRange {
	XCTAssertThrows([buffer indexOfObjectIdenticalTo:nil inRange:NSMakeRange(0, 1)]);
	XCTAssertThrows([buffer indexOfObjectIdenticalTo:nil inRange:NSMakeRange(0, 0)]);
	[buffer addObjectsFromArray:abc];
	NSRange range = NSMakeRange(1, 1);
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:@"A" inRange:range],
				   NSNotFound);
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:@"B" inRange:range],
				   1);
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:[NSString stringWithFormat:@"B"] inRange:range],
				   NSNotFound);
	XCTAssertEqual([buffer indexOfObjectIdenticalTo:@"C" inRange:range],
				   NSNotFound);
}

- (void)testObjectAtIndex {
	XCTAssertThrows([buffer objectAtIndex:0]);
	[buffer addObjectsFromArray:abc];
	for (NSUInteger searchIndex = 0; searchIndex < [abc count]; searchIndex++) {
		XCTAssertEqualObjects([buffer objectAtIndex:searchIndex],
							 [abc objectAtIndex:searchIndex]);
	}
	XCTAssertThrows([buffer objectAtIndex:[abc count]+1]);
}

- (void)testObjectsAtIndexes {
	[buffer addObjectsFromArray:abc];
	NSUInteger count = [buffer count];
	NSRange range;
	for (NSUInteger location = 0; location <= count; location++) {
		range.location = location;
		for (NSUInteger length = 0; length <= count - location + 1; length++) {
			range.length = length;
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
			if (location + length > count) {
				XCTAssertThrows([buffer objectsAtIndexes:indexes]);
			} else {
				XCTAssertEqualObjects([buffer objectsAtIndexes:indexes],
									 [abc objectsAtIndexes:indexes]);
			}
		}
	}
	XCTAssertThrows([buffer objectsAtIndexes:nil]);
}

#pragma mark Removal

- (void)testRemoveFirstObject {
	// When empty, removal should have no effect and not raise an exception.
	XCTAssertNoThrow([buffer removeFirstObject]);
	// Test correctness when removing the first object one at a time.
	[buffer addObjectsFromArray:abc];
	NSUInteger expected = [abc count];
	XCTAssertEqualObjects([buffer firstObject], @"A");
	XCTAssertEqual([buffer count], expected--);
	[buffer removeFirstObject];
	XCTAssertEqualObjects([buffer firstObject], @"B");
	XCTAssertEqual([buffer count], expected--);
	[buffer removeFirstObject];
	XCTAssertEqualObjects([buffer firstObject], @"C");
	XCTAssertEqual([buffer count], expected--);
	[buffer removeFirstObject];
	XCTAssertNil([buffer firstObject]);
	XCTAssertEqual([buffer count], expected);
	[buffer removeFirstObject];
	XCTAssertNil([buffer firstObject]);
	XCTAssertEqual([buffer count], expected);
	// Should never raise an exception, even when empty.
	XCTAssertNoThrow([buffer removeLastObject]);
	XCTAssertEqual([buffer count], expected);
}

- (void)testRemoveLastObject {
	// When empty, removal should have no effect and not raise an exception.
	XCTAssertNoThrow([buffer removeLastObject]);
	// Test correctness when removing the last object one at a time.
	[buffer addObjectsFromArray:abc];
	NSUInteger expected = [abc count];
	XCTAssertEqualObjects([buffer lastObject], @"C");
	XCTAssertEqual([buffer count], expected--);
	[buffer removeLastObject];
	XCTAssertEqualObjects([buffer lastObject], @"B");
	XCTAssertEqual([buffer count], expected--);
	[buffer removeLastObject];
	XCTAssertEqualObjects([buffer lastObject], @"A");
	XCTAssertEqual([buffer count], expected--);
	[buffer removeLastObject];
	XCTAssertEqualObjects([buffer lastObject], nil);
	// Should never raise an exception, even when empty.
	XCTAssertNoThrow([buffer removeLastObject]);
	XCTAssertEqual([buffer count], expected);
	// Test removing the last object when the tail index is at slot 0
	// The last object must be in the final slot, with 1+ slots still open.
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:3] autorelease];
	[buffer addObject:@"bogus"]; [buffer removeFirstObject];
	[buffer addObject:@"bogus"]; [buffer removeFirstObject];
	[buffer addObject:@"A"];
	XCTAssertNoThrow([buffer removeLastObject]);
	checkCountAndDistanceFromHeadToTail(0);
}

- (void)testRemoveAllObjects {
	checkCountAndDistanceFromHeadToTail(0);
	[buffer addObjectsFromArray:abc];
	checkCountAndDistanceFromHeadToTail([abc count]);
	[buffer removeAllObjects];
	checkCountAndDistanceFromHeadToTail(0);
	
	// Test whether circular buffer contracts when all objects are removed.
	XCTAssertEqual([buffer capacity], 16);
	// Insert each object 3 times to force array capacity to 64 elements
	[buffer addObjectsFromArray:fifteen];
	[buffer addObjectsFromArray:fifteen];
	[buffer addObjectsFromArray:fifteen];
	// Test capacity and count of resulting buffer
	XCTAssertEqual([buffer count], [fifteen count]*3);
	XCTAssertEqual([buffer capacity], 64);
	// Capacity should be set back to default when removing all objects
	[buffer removeAllObjects];
	XCTAssertEqual([buffer count],    0);
	XCTAssertEqual([buffer capacity], 16);
}

- (void)removeObjectSetup {
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:8] autorelease];
}

- (NSArray *)removeObjectTestArrays {
	return @[
		@[@"X",@"A",@"X",@"B",@"X",@"C"],
		@[@"A",@"X",@"B",@"X",@"C",@"X"],
		@[@"A",@"X",@"X",@"X",@"B",@"C"],
		@[@"A",@"X",@"X",@"B",@"C",@"D"],
		@[@"A",@"B",@"X",@"X",@"C",@"D"],
		@[@"X",@"A",@"X",@"B",@"X",@"C",@"X"],
	];
}

- (void)testRemoveObject {
	XCTAssertNoThrow([buffer removeObject:@"A"]);
	[buffer addObjectsFromArray:abc];
	XCTAssertEqual([buffer count], [abc count]);
	XCTAssertThrows([buffer removeObject:nil]);
	XCTAssertEqual([buffer count], [abc count]);
	
	// Test removing all instances of an object in various scenarios
	[self removeObjectSetup];
	for (NSArray<NSString *> *testArray in [self removeObjectTestArrays]) {
		NSMutableArray *processedArray = [testArray mutableCopy];
		[processedArray removeObject:@"X"];
		for (int i = 0; i <= 1; i++) {
			// Offset the head pointer by 3 to force wrapping
			if (i == 1) {
				for (id anObject in abc) {
					[buffer addObject:anObject];
					[buffer removeFirstObject];
				}				
			}
			[buffer addObjectsFromArray:testArray];
			XCTAssertEqualObjects(buffer, testArray);
			[buffer removeObject:@"bogus"];
			XCTAssertEqualObjects(buffer, testArray);
			[buffer removeObject:@"X"];
			XCTAssertEqualObjects(buffer, processedArray);
			[buffer removeObject:@"X"];
			XCTAssertEqualObjects(buffer, processedArray);
			[buffer removeAllObjects];
		}
	}
}

- (void)testRemoveObjectIdenticalTo {
	XCTAssertNoThrow([buffer removeObject:@"A"]);
	
	NSString *a = [NSString stringWithFormat:@"A"];
	NSString *b = [NSString stringWithFormat:@"B"];
	NSString *x = [NSString stringWithFormat:@"X"];
	
	[buffer addObject:a];
	[buffer addObject:b];
	[buffer addObject:@"C"];
	[buffer addObject:a];
	[buffer addObject:b];
	XCTAssertThrows([buffer removeObjectIdenticalTo:nil]);
	
	XCTAssertEqual([buffer count], 5);
	[buffer removeObjectIdenticalTo:@"A"];
	XCTAssertEqual([buffer count], 5);
	[buffer removeObjectIdenticalTo:@"B"];
	XCTAssertEqual([buffer count], 5);
	[buffer removeObjectIdenticalTo:a];
	XCTAssertEqual([buffer count], 3);
	[buffer removeObjectIdenticalTo:b];
	XCTAssertEqual([buffer count], 1);

	// Test removing all instances of an object in various scenarios
	[self removeObjectSetup];
	for (NSArray<NSString *> *testArray in [self removeObjectTestArrays]) {
		NSMutableArray *processedArray = [testArray mutableCopy];
		[processedArray removeObject:@"X"];
		for (int i = 0; i <= 1; i++) {
			// Offset the head pointer by 3 to force wrapping
			if (i == 1) {
				for (id anObject in abc) {
					[buffer addObject:anObject];
					[buffer removeFirstObject];
				}				
			}
			[buffer addObjectsFromArray:testArray];
			XCTAssertEqualObjects(buffer, testArray);
			[buffer removeObjectIdenticalTo:x];
			XCTAssertEqualObjects(buffer, testArray);
			[buffer removeObjectIdenticalTo:@"X"];
			XCTAssertEqualObjects(buffer, processedArray);
			[buffer removeObjectIdenticalTo:@"X"];
			XCTAssertEqualObjects(buffer, processedArray);
			[buffer removeAllObjects];
		}
	}
}

- (void)testRemoveObjectAtIndex {
	// Any index on empty array should raise exception
	XCTAssertThrows([buffer removeObjectAtIndex:0]);
	XCTAssertThrows([buffer removeObjectAtIndex:1]);
	// Any index beyond the bounds of the receiver should raise exception
	[buffer addObjectsFromArray:abc];
	XCTAssertThrows([buffer removeObjectAtIndex:[abc count]]);
	// Test removing the first object repeatedly
	for (NSUInteger removed = 1; removed <= [abc count]; removed++) {
		XCTAssertNoThrow([buffer removeObjectAtIndex:0]);
		XCTAssertEqual([buffer count], [abc count]-removed);
	}
	[buffer removeAllObjects];
	// Test removing the last object repeatedly
	[buffer addObjectsFromArray:abc];
	for (NSUInteger removed = 1; removed <= [abc count]; removed++) {
		XCTAssertNoThrow([buffer removeObjectAtIndex:[abc count]-removed]);
		XCTAssertEqual([buffer count], [abc count]-removed);
	}
	[buffer removeAllObjects];
	// Test removing objects other than the first and last when the buffer wraps
	// We force creation of a wrapped buffer and remove the proper indexes
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:8] autorelease];
	// Advance head and tail so the gap will fall in the middle of the array
	for (NSUInteger count = 1; count <= 4; count++) {
		[buffer addObject:[NSNull null]];
		[buffer removeFirstObject];
	}
	NSMutableArray *objects = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",nil];
	[buffer addObjectsFromArray:objects];
	// The internal array should now look like the following: EFG_ABCD
	// Remove two objects each from the "left" half, then the "right" half
	// This is the pattern it should follow: EG__ABCD G___ABCD G____ABC G_____AB
	for (NSUInteger index = [objects count] - 2; index > 1; index--) {
		XCTAssertNoThrow([buffer removeObjectAtIndex:index]);
		[objects removeObjectAtIndex:index];
		XCTAssertEqualObjects(buffer, objects);
		XCTAssertEqual([buffer count], [buffer distanceFromHeadToTail]);
	}
	// Remove the last object and cause tail index to wrap
	// This is the pattern it should follow: ______AB ______A_
	XCTAssertNoThrow([buffer removeObjectAtIndex:2]);
	[objects removeObjectAtIndex:2];
	XCTAssertEqualObjects(buffer, objects);
	XCTAssertEqual([buffer count], [buffer distanceFromHeadToTail]);
	XCTAssertNoThrow([buffer removeObjectAtIndex:1]);
	[objects removeObjectAtIndex:1];
	XCTAssertEqualObjects(buffer, objects);
	XCTAssertEqual([buffer count], [buffer distanceFromHeadToTail]);
	// Remove the first object and cause head index to wrap
	[buffer removeFirstObject];
	objects = [NSMutableArray arrayWithArray:abc];
	// This is the pattern it should follow: BC_____A BC______ _C______
	[buffer addObjectsFromArray:objects];
	XCTAssertNoThrow([buffer removeObjectAtIndex:0]);
	[objects removeObjectAtIndex:0];
	XCTAssertEqualObjects(buffer, objects);
	XCTAssertEqual([buffer count], [buffer distanceFromHeadToTail]);
	XCTAssertNoThrow([buffer removeObjectAtIndex:0]);
	[objects removeObjectAtIndex:0];
	XCTAssertEqualObjects(buffer, objects);
	XCTAssertEqual([buffer count], [buffer distanceFromHeadToTail]);
}

- (void)testRemoveObjectsAtIndexes {
	// Test nil and invalid indexes
	XCTAssertThrows([buffer removeObjectsAtIndexes:nil]);
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	XCTAssertThrows([buffer removeObjectsAtIndexes:indexes]);
	
	NSMutableArray *expected = [NSMutableArray array];
	for (NSUInteger location = 0; location < [abc count]; location++) {
		for (NSUInteger length = 0; length <= [abc count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate buffer and expected
			[expected removeAllObjects];
			[expected addObjectsFromArray:abc];
			[expected addObjectsFromArray:abc];
			[buffer removeAllObjects];
			[buffer addObjectsFromArray:expected];
			XCTAssertNoThrow([buffer removeObjectsAtIndexes:indexes]);
			[expected removeObjectsAtIndexes:indexes];
			XCTAssertEqual([buffer count], [expected count]);
			XCTAssertEqualObjects([buffer allObjects], expected);
		}
	}	
	XCTAssertThrows([buffer removeObjectsAtIndexes:nil]);
}

- (void)testReplaceObjectAtIndexWithObject {
	[buffer addObjectsFromArray:abc];
	
	for (NSUInteger i = 0; i < [abc count]; i++) {
		XCTAssertEqualObjects([buffer objectAtIndex:i], [abc objectAtIndex:i]);
		[buffer replaceObjectAtIndex:i withObject:@"Z"];
		XCTAssertEqualObjects([buffer objectAtIndex:i], @"Z");
	}
}

#pragma mark -
#pragma mark <Protocols>

- (void)testNSCoding {
	NSArray *objects = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P"];
	[buffer addObjectsFromArray:objects];
	XCTAssertEqual([buffer count], [objects count]);
	XCTAssertEqual([buffer capacity], 32);
	XCTAssertEqualObjects([buffer allObjects], objects);
	
	buffer = [buffer copyUsingNSCoding];
	
	XCTAssertEqual([buffer count], [objects count]);
	XCTAssertEqual([buffer capacity], 32);
	XCTAssertEqualObjects([buffer allObjects], objects);
}

- (void)testNSCopying {
	NSArray *objects = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P"];
	[buffer addObjectsFromArray:objects];
	id buffer2 = [[buffer copy] autorelease];
	[buffer removeAllObjects];
	XCTAssertNotNil(buffer2);
	XCTAssertEqual([buffer2 count], [objects count]);
	XCTAssertEqualObjects([buffer2 allObjects], objects);
}

- (void)testNSFastEnumeration {
	int number, expected, count;
	for (number = 1; number <= 32; number++) {
		[buffer addObject:@(number)];
	}
	count = 0;
	expected = 1;
	e = [buffer objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertEqual([anObject intValue], expected++);
		++count;
	}
	XCTAssertEqual(count, 32);

	@try {
		for (__unused NSNumber *number in buffer) {
			[buffer addObject:@"bogus"];
		}
		XCTFail(@"Expected an exception for mutating during enumeration.");
	}
	@catch (NSException *exception) {
	}
	
	// Test enumeration when buffer wraps around
	
	[buffer removeAllObjects];
	// Insert and remove 3 elements to make the buffer wrap with 15 elements
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer addObject:anObject];
		[buffer removeFirstObject];
	}
	checkCountAndDistanceFromHeadToTail(0);
	for (number = 1; number < 16; number++) {
		[buffer addObject:@(number)];
	}
	count = 0;
	expected = 1;
	e = [buffer objectEnumerator];
	while (anObject = [e nextObject]) {
		XCTAssertEqual([anObject intValue], expected++);
		++count;
	}
	XCTAssertEqual(count, 15);
}

@end
