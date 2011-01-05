/*
 CHDataStructures.framework -- CHCircularBufferTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHCircularBuffer.h"
#import "Util.h"

static NSArray *abc;

@interface CHCircularBuffer (Internals)

- (NSUInteger) capacity;
- (NSUInteger) distanceFromHeadToTail;

@end

@implementation CHCircularBuffer (Internals)

- (NSUInteger) capacity {
	return arrayCapacity;
}

- (NSUInteger) distanceFromHeadToTail {
	return (tailIndex - headIndex + arrayCapacity) % arrayCapacity;
}

@end

#pragma mark -

@interface CHCircularBufferTest : SenTestCase
{
	CHCircularBuffer *buffer;
	NSMutableArray *fifteen;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHCircularBufferTest

+ (void) initialize {
	abc = [[NSArray arrayWithObjects:@"A",@"B",@"C",nil] retain];
}

- (void) setUp {
	buffer = [[[CHCircularBuffer alloc] init] autorelease];
	fifteen = [[NSMutableArray alloc] init];
	for (int i = 1; i <= 15; i++)
		[fifteen addObject:[NSNumber numberWithInt:i]];
}

// This macro checks tail-head (accounting for wrapping) against the count.
#define checkCountAndDistanceFromHeadToTail(e) \
do { \
	NSUInteger expected = e; \
	STAssertEquals([buffer count], expected, nil); \
	STAssertEquals([buffer distanceFromHeadToTail], expected, nil); \
} while(0)
	
- (void) testInit {
	STAssertEquals([buffer capacity], (NSUInteger)16, nil);
	checkCountAndDistanceFromHeadToTail(0);
}

- (void) testInitWithArray {
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 1; i <= 15; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	buffer = [[[CHCircularBuffer alloc] initWithArray:array] autorelease];
	STAssertEquals([buffer capacity], (NSUInteger)16, nil);
	checkCountAndDistanceFromHeadToTail(15);
	
	[array addObject:[NSNumber numberWithInt:16]];
	buffer = [[[CHCircularBuffer alloc] initWithArray:array] autorelease];
	STAssertEquals([buffer capacity], (NSUInteger)32, nil);
	checkCountAndDistanceFromHeadToTail(16);
	
	for (int i = 17; i <= 33; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	buffer = [[[CHCircularBuffer alloc] initWithArray:array] autorelease];
	STAssertEquals([buffer capacity], (NSUInteger)64, nil);
	checkCountAndDistanceFromHeadToTail(33);
}

- (void) testInitWithCapacity {
	// Test initializing with valid capacity
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:8] autorelease];
	STAssertEquals([buffer capacity], (NSUInteger)8, nil);
	checkCountAndDistanceFromHeadToTail(0);
	// Test initializing with invalid capacity
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:0] autorelease];
	STAssertTrue([buffer capacity] != 0, nil);
	checkCountAndDistanceFromHeadToTail(0);
}

#pragma mark Insertion

- (void) testAddObject {
	[buffer addObject:@"A"];
	checkCountAndDistanceFromHeadToTail(1);
	[buffer addObject:@"B"];
	checkCountAndDistanceFromHeadToTail(2);
	[buffer addObject:@"C"];
	checkCountAndDistanceFromHeadToTail(3);
	
	// Force expansion of original capacity
	buffer = [[[CHCircularBuffer alloc] init] autorelease];
	for (int i = 1; i <= 16; i++)
		[buffer addObject:[NSNumber numberWithInt:i]];
	STAssertEquals([buffer capacity], (NSUInteger)32, nil);
	for (int i = 17; i <= 33; i++)
		[buffer addObject:[NSNumber numberWithInt:i]];
	STAssertEquals([buffer capacity], (NSUInteger)64, nil);
}

- (void) testInsertObjectAtIndex {
	// Inserting a nil object should raise an exception
	STAssertThrows([buffer insertObject:nil  atIndex:0], nil);
	// Any index on empty array should raise an exception
	STAssertThrows([buffer insertObject:@"Z" atIndex:1], nil);
	// Insert in the middle of a non-wrapping buffer; tail should get pushed right
	[buffer addObject:@"W"];
	[buffer insertObject:@"Z" atIndex:1];
	[buffer insertObject:@"Y" atIndex:1];
	[buffer insertObject:@"X" atIndex:1];
	STAssertEqualObjects(buffer, ([NSArray arrayWithObjects:@"W",@"X",@"Y",@"Z",nil]), nil);
	[buffer removeAllObjects];
	// Insert some at the front to force the buffer to "wrap around" backwards.
	NSMutableArray *correct = [NSMutableArray arrayWithArray:abc];
	[correct addObject:@"D"];
	e = [abc reverseObjectEnumerator];
	while (anObject = [e nextObject])
		[buffer insertObject:anObject atIndex:0];
	[buffer addObject:@"D"];
	STAssertEqualObjects(buffer, correct, nil);
	checkCountAndDistanceFromHeadToTail([correct count]);
	// Test inserting in the middle of both halves of a wrapped-around buffer
	[buffer  insertObject:@"X" atIndex:1];
	[correct insertObject:@"X" atIndex:1];
	checkCountAndDistanceFromHeadToTail([correct count]);
	STAssertEqualObjects(buffer, correct, nil);
	[buffer  insertObject:@"Y" atIndex:3];
	[correct insertObject:@"Y" atIndex:3];
	checkCountAndDistanceFromHeadToTail([correct count]);
	STAssertEqualObjects(buffer, correct, nil);
	[buffer  insertObject:@"Z" atIndex:5];
	[correct insertObject:@"Z" atIndex:5];
	checkCountAndDistanceFromHeadToTail([correct count]);
	STAssertEqualObjects(buffer, correct, nil);
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	// When the buffer is empty, calls with any index should raise exception
	STAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:0], nil);
	STAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:1], nil);
	STAssertThrows([buffer exchangeObjectAtIndex:1 withObjectAtIndex:0], nil);
	// When either index exceeds the bounds, an exception should be raised
	[buffer addObjectsFromArray:abc];
	STAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:[abc count]], nil);
	STAssertThrows([buffer exchangeObjectAtIndex:[abc count] withObjectAtIndex:0], nil);
	// Attempting to swap an index with itself should have no effect
	for (NSUInteger i = 0; i < [abc count]; i++) {
		[buffer exchangeObjectAtIndex:i withObjectAtIndex:i];
		STAssertEqualObjects([buffer allObjects], abc, nil);
	}
	// Test exchanging objects and verify correctness of swaps
	[buffer exchangeObjectAtIndex:0 withObjectAtIndex:2];
	STAssertEqualObjects([buffer firstObject],     @"C", nil);
	STAssertEqualObjects([buffer lastObject],      @"A", nil);
	[buffer exchangeObjectAtIndex:0 withObjectAtIndex:1];
	STAssertEqualObjects([buffer firstObject],     @"B", nil);
	STAssertEqualObjects([buffer objectAtIndex:1], @"C", nil);
	[buffer exchangeObjectAtIndex:2 withObjectAtIndex:1];
	STAssertEqualObjects([buffer objectAtIndex:1], @"A", nil);
	STAssertEqualObjects([buffer lastObject],      @"C", nil);	
}
		
#pragma mark Access

- (void) testCount {
	STAssertEquals([buffer count], (NSUInteger)0, nil);
	[buffer addObjectsFromArray:abc];
	STAssertEquals([buffer count], [abc count], nil);
}

- (void) testAllObjects {
	STAssertNotNil([buffer allObjects], nil);
	STAssertEquals([[buffer allObjects] count], (NSUInteger)0, nil);
	
	[buffer addObjectsFromArray:abc];
	STAssertEqualObjects([buffer allObjects], abc, nil);
	
	// Test -allObjects when the buffer wraps around to the beginning
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[buffer removeFirstObject];
	checkCountAndDistanceFromHeadToTail(0);
	NSMutableArray *objects = [NSMutableArray array];
	for (int i = 1; i < 16; i++) {
		[objects addObject:[NSNumber numberWithInt:i]];
	}
	[buffer addObjectsFromArray:objects];
	STAssertEquals([buffer count], [objects count], nil);
	STAssertEqualObjects([buffer allObjects], objects, nil);
}

- (void) testEnumerator {
	STAssertNil([[buffer objectEnumerator] nextObject], nil);
	STAssertNotNil([[buffer objectEnumerator] allObjects], nil);
	STAssertEquals([[[buffer objectEnumerator] allObjects] count], (NSUInteger)0,
				   nil);

	STAssertNil([[buffer reverseObjectEnumerator] nextObject], nil);
	STAssertNotNil([[buffer reverseObjectEnumerator] allObjects], nil);
	STAssertEquals([[[buffer reverseObjectEnumerator] allObjects] count], (NSUInteger)0,
				   nil);
	
	[buffer addObjectsFromArray:abc];
	
	NSArray *allObjects;
	
	// Test forward enumeration
	e = [buffer objectEnumerator];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count], nil);
	STAssertEqualObjects(allObjects, abc, nil);
	
	e = [buffer objectEnumerator];
	[e nextObject];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count]-1, nil);
	
	e = [buffer objectEnumerator];
	STAssertEqualObjects([e nextObject], @"A", nil);
	STAssertEqualObjects([e nextObject], @"B", nil);
	STAssertEqualObjects([e nextObject], @"C", nil);
	STAssertNil([e nextObject], nil);
	
	// Cause mutation exception
	[buffer addObject:@"Z"];
	STAssertThrows([e nextObject], nil);
	STAssertThrows([e allObjects], nil);
	[buffer removeLastObject];

	// Test reverse enumeration
	e = [buffer reverseObjectEnumerator];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count], nil);
	STAssertEqualObjects(allObjects, [[abc reverseObjectEnumerator] allObjects], nil);
	
	e = [buffer reverseObjectEnumerator];
	[e nextObject];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count]-1, nil);
	
	e = [buffer reverseObjectEnumerator];
	STAssertEqualObjects([e nextObject], @"C", nil);
	STAssertEqualObjects([e nextObject], @"B", nil);
	STAssertEqualObjects([e nextObject], @"A", nil);
	STAssertNil([e nextObject], nil);

	// Cause mutation exception
	[buffer addObject:@"bogus"];
	STAssertThrows([e nextObject], nil);
	STAssertThrows([e allObjects], nil);
	[buffer removeLastObject];
}

- (void) testDescription {
	STAssertEqualObjects([buffer description], [[buffer allObjects] description], nil);
	[buffer addObjectsFromArray:abc];
	STAssertEqualObjects([buffer description], [[buffer allObjects] description], nil);
}

#pragma mark Search

- (void) testContainsObject {
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertFalse([buffer containsObject:anObject], nil);
	STAssertFalse([buffer containsObject:@"bogus"], nil);
	[buffer addObjectsFromArray:abc];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertTrue([buffer containsObject:anObject], nil);
	STAssertFalse([buffer containsObject:@"bogus"], nil);
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertFalse([buffer containsObjectIdenticalTo:anObject], nil);
	STAssertFalse([buffer containsObjectIdenticalTo:@"bogus"], nil);
	STAssertFalse([buffer containsObjectIdenticalTo:a], nil);
	[buffer addObjectsFromArray:abc];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertTrue([buffer containsObjectIdenticalTo:anObject], nil);
	STAssertFalse([buffer containsObjectIdenticalTo:@"bogus"], nil);
	STAssertFalse([buffer containsObjectIdenticalTo:a], nil);
}

- (void) testIndexOfObject {
	STAssertEquals([buffer indexOfObject:@"bogus"], (NSUInteger)NSNotFound, nil);
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
		STAssertEquals([buffer indexOfObject:anObject], expectedIndex++, nil);
	}
	STAssertEquals([buffer indexOfObject:@"bogus"], (NSUInteger)NSNotFound, nil);
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"bogus"], (NSUInteger)NSNotFound, nil);
	STAssertEquals([buffer indexOfObjectIdenticalTo:a],        (NSUInteger)NSNotFound, nil);
	// Move the head index to 3 so adding 15 objects will wrap.
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer addObject:anObject];
		[buffer removeFirstObject];
	}
	[buffer addObjectsFromArray:fifteen];

	NSUInteger expectedIndex = 0;
	e = [fifteen objectEnumerator];
	while (anObject = [e nextObject])
		STAssertEquals([buffer indexOfObjectIdenticalTo:anObject], expectedIndex++, nil);
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"bogus"], (NSUInteger)NSNotFound, nil);
	STAssertEquals([buffer indexOfObjectIdenticalTo:a],        (NSUInteger)NSNotFound, nil);
}

- (void) testIndexOfObjectInRange {
	STAssertThrows([buffer indexOfObject:nil inRange:NSMakeRange(0, 1)], nil);
	STAssertNoThrow([buffer indexOfObject:nil inRange:NSMakeRange(0, 0)], nil);
	[buffer addObjectsFromArray:abc];
	NSRange range = NSMakeRange(1, 1);
	STAssertEquals([buffer indexOfObject:@"A" inRange:range], (NSUInteger)NSNotFound, nil);
	STAssertEquals([buffer indexOfObject:@"B" inRange:range], (NSUInteger)1,          nil);
	STAssertEquals([buffer indexOfObject:@"C" inRange:range], (NSUInteger)NSNotFound, nil);
}

- (void) testIndexOfObjectIdenticalToInRange {
	STAssertThrows([buffer indexOfObjectIdenticalTo:nil inRange:NSMakeRange(0, 1)], nil);	
	STAssertNoThrow([buffer indexOfObjectIdenticalTo:nil inRange:NSMakeRange(0, 0)], nil);
	[buffer addObjectsFromArray:abc];
	NSRange range = NSMakeRange(1, 1);
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"A" inRange:range],
				   (NSUInteger)NSNotFound, nil);
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"B" inRange:range],
				   (NSUInteger)1, nil);
	STAssertEquals([buffer indexOfObjectIdenticalTo:[NSString stringWithFormat:@"B"] inRange:range],
				   (NSUInteger)NSNotFound, nil);
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"C" inRange:range],
				   (NSUInteger)NSNotFound, nil);
}

- (void) testObjectAtIndex {
	STAssertThrows([buffer objectAtIndex:0], nil);
	[buffer addObjectsFromArray:abc];
	for (NSUInteger searchIndex = 0; searchIndex < [abc count]; searchIndex++) {
		STAssertEqualObjects([buffer objectAtIndex:searchIndex],
							 [abc objectAtIndex:searchIndex], nil);
	}
	STAssertThrows([buffer objectAtIndex:[abc count]+1], nil);
}

- (void) testObjectsAtIndexes {
	[buffer addObjectsFromArray:abc];
	NSUInteger count = [buffer count];
	NSRange range;
	for (NSUInteger location = 0; location <= count; location++) {
		range.location = location;
		for (NSUInteger length = 0; length <= count - location + 1; length++) {
			range.length = length;
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
			if (location + length > count) {
				STAssertThrows([buffer objectsAtIndexes:indexes], nil);
			} else {
				STAssertEqualObjects([buffer objectsAtIndexes:indexes],
									 [abc objectsAtIndexes:indexes], nil);
			}
		}
	}
	STAssertThrows([buffer objectsAtIndexes:nil], nil);
}

#pragma mark Removal

- (void) testRemoveFirstObject {
	// When empty, removal should have no effect and not raise an exception.
	STAssertNoThrow([buffer removeFirstObject], nil);
	// Test correctness when removing the first object one at a time.
	[buffer addObjectsFromArray:abc];
	NSUInteger expected = [abc count];
	STAssertEqualObjects([buffer firstObject], @"A", nil);
	STAssertEquals([buffer count], expected--, nil);
	[buffer removeFirstObject];
	STAssertEqualObjects([buffer firstObject], @"B", nil);
	STAssertEquals([buffer count], expected--, nil);
	[buffer removeFirstObject];
	STAssertEqualObjects([buffer firstObject], @"C", nil);
	STAssertEquals([buffer count], expected--, nil);
	[buffer removeFirstObject];
	STAssertNil([buffer firstObject], nil);
	STAssertEquals([buffer count], expected, nil);
	[buffer removeFirstObject];
	STAssertNil([buffer firstObject], nil);
	STAssertEquals([buffer count], expected, nil);
	// Should never raise an exception, even when empty.
	STAssertNoThrow([buffer removeLastObject], nil);
	STAssertEquals([buffer count], expected, nil);
}

- (void) testRemoveLastObject {
	// When empty, removal should have no effect and not raise an exception.
	STAssertNoThrow([buffer removeLastObject], nil);
	// Test correctness when removing the last object one at a time.
	[buffer addObjectsFromArray:abc];
	NSUInteger expected = [abc count];
	STAssertEqualObjects([buffer lastObject], @"C", nil);
	STAssertEquals([buffer count], expected--, nil);
	[buffer removeLastObject];
	STAssertEqualObjects([buffer lastObject], @"B", nil);
	STAssertEquals([buffer count], expected--, nil);
	[buffer removeLastObject];
	STAssertEqualObjects([buffer lastObject], @"A", nil);
	STAssertEquals([buffer count], expected--, nil);
	[buffer removeLastObject];
	STAssertEqualObjects([buffer lastObject], nil, nil);
	// Should never raise an exception, even when empty.
	STAssertNoThrow([buffer removeLastObject], nil);
	STAssertEquals([buffer count], expected, nil);
	// Test removing the last object when the tail index is at slot 0
	// The last object must be in the final slot, with 1+ slots still open.
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:3] autorelease];
	[buffer addObject:@"bogus"]; [buffer removeFirstObject];
	[buffer addObject:@"bogus"]; [buffer removeFirstObject];
	[buffer addObject:@"A"];
	STAssertNoThrow([buffer removeLastObject], nil);
	checkCountAndDistanceFromHeadToTail(0);
}

- (void) testRemoveAllObjects {
	checkCountAndDistanceFromHeadToTail(0);
	[buffer addObjectsFromArray:abc];
	checkCountAndDistanceFromHeadToTail([abc count]);
	[buffer removeAllObjects];
	checkCountAndDistanceFromHeadToTail(0);
	
	// Test whether circular buffer contracts when all objects are removed.
	STAssertEquals([buffer capacity], (NSUInteger)16, nil);
	// Insert each object 3 times to force array capacity to 64 elements
	[buffer addObjectsFromArray:fifteen];
	[buffer addObjectsFromArray:fifteen];
	[buffer addObjectsFromArray:fifteen];
	// Test capacity and count of resulting buffer
	STAssertEquals([buffer count], [fifteen count]*3, nil);
	STAssertEquals([buffer capacity], (NSUInteger)64, nil);
	// Capacity should be set back to default when removing all objects
	[buffer removeAllObjects];
	STAssertEquals([buffer count],    (NSUInteger)0,  nil);
	STAssertEquals([buffer capacity], (NSUInteger)16, nil);
}

- (void) removeObjectSetup {
	buffer = [[[CHCircularBuffer alloc] initWithCapacity:8] autorelease];
}

- (NSArray*) removeObjectTestArrays {
	return [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"X",@"A",@"X",@"B",@"X",@"C",nil],
	                                 [NSArray arrayWithObjects:@"A",@"X",@"B",@"X",@"C",@"X",nil],
	                                 [NSArray arrayWithObjects:@"A",@"X",@"X",@"X",@"B",@"C",nil],
	                                 [NSArray arrayWithObjects:@"A",@"X",@"X",@"B",@"C",@"D",nil],
	                                 [NSArray arrayWithObjects:@"A",@"B",@"X",@"X",@"C",@"D",nil],
	                                 [NSArray arrayWithObjects:@"X",@"A",@"X",@"B",@"X",@"C",@"X",nil],
	                                 nil];
}

- (void) testRemoveObject {
	STAssertNoThrow([buffer removeObject:@"A"], nil);
	[buffer addObjectsFromArray:abc];
	STAssertEquals([buffer count], [abc count], nil);
	STAssertNoThrow([buffer removeObject:nil],  nil);
	STAssertEquals([buffer count], [abc count], nil);
	
	// Test removing all instances of an object in various scenarios
	[self removeObjectSetup];
	NSEnumerator *testArrays = [[self removeObjectTestArrays] objectEnumerator];
	NSArray *testArray;
	while (testArray = [testArrays nextObject]) {
		NSMutableArray *processedArray = [testArray mutableCopy];
		[processedArray removeObject:@"X"];
		for (int i = 0; i <= 1; i++) {
			// Offset the head pointer by 3 to force wrapping
			if (i == 1) {
				e = [abc objectEnumerator];
				while (anObject = [e nextObject]) {
					[buffer addObject:anObject];
					[buffer removeFirstObject];
				}				
			}
			[buffer addObjectsFromArray:testArray];
			STAssertEqualObjects(buffer, testArray, nil);
			[buffer removeObject:@"bogus"];
			STAssertEqualObjects(buffer, testArray, @"for array %@", [testArray description]);
			[buffer removeObject:@"X"];
			STAssertEqualObjects(buffer, processedArray, @"for array %@", [testArray description]);
			[buffer removeObject:@"X"];
			STAssertEqualObjects(buffer, processedArray, @"for array %@", [testArray description]);
			[buffer removeAllObjects];
		}
	}
}

- (void) testRemoveObjectIdenticalTo {
	STAssertNoThrow([buffer removeObject:@"A"], nil);
	
	NSString *a = [NSString stringWithFormat:@"A"];
	NSString *b = [NSString stringWithFormat:@"B"];
	NSString *x = [NSString stringWithFormat:@"X"];
	
	[buffer addObject:a];
	[buffer addObject:b];
	[buffer addObject:@"C"];
	[buffer addObject:a];
	[buffer addObject:b];
	STAssertNoThrow([buffer removeObjectIdenticalTo:nil], nil);
	
	STAssertEquals([buffer count], (NSUInteger)5, nil);
	[buffer removeObjectIdenticalTo:@"A"];
	STAssertEquals([buffer count], (NSUInteger)5, nil);
	[buffer removeObjectIdenticalTo:@"B"];
	STAssertEquals([buffer count], (NSUInteger)5, nil);
	[buffer removeObjectIdenticalTo:a];
	STAssertEquals([buffer count], (NSUInteger)3, nil);
	[buffer removeObjectIdenticalTo:b];
	STAssertEquals([buffer count], (NSUInteger)1, nil);

	// Test removing all instances of an object in various scenarios
	[self removeObjectSetup];
	NSEnumerator *testArrays = [[self removeObjectTestArrays] objectEnumerator];
	NSArray *testArray;
	while (testArray = [testArrays nextObject]) {
		NSMutableArray *processedArray = [testArray mutableCopy];
		[processedArray removeObject:@"X"];
		for (int i = 0; i <= 1; i++) {
			// Offset the head pointer by 3 to force wrapping
			if (i == 1) {
				e = [abc objectEnumerator];
							while (anObject = [e nextObject]) {
					[buffer addObject:anObject];
					[buffer removeFirstObject];
				}				
			}
			[buffer addObjectsFromArray:testArray];
			STAssertEqualObjects(buffer, testArray, nil);
			[buffer removeObjectIdenticalTo:x];
			STAssertEqualObjects(buffer, testArray, @"for array %@", [testArray description]);
			[buffer removeObjectIdenticalTo:@"X"];
			STAssertEqualObjects(buffer, processedArray, @"for array %@", [testArray description]);
			[buffer removeObjectIdenticalTo:@"X"];
			STAssertEqualObjects(buffer, processedArray, @"for array %@", [testArray description]);
			[buffer removeAllObjects];
		}
	}
}

- (void) testRemoveObjectAtIndex {
	// Any index on empty array should raise exception
	STAssertThrows([buffer removeObjectAtIndex:0], nil);
	STAssertThrows([buffer removeObjectAtIndex:1], nil);
	// Any index beyond the bounds of the receiver should raise exception
	[buffer addObjectsFromArray:abc];
	STAssertThrows([buffer removeObjectAtIndex:[abc count]], nil);
	// Test removing the first object repeatedly
	for (NSUInteger removed = 1; removed <= [abc count]; removed++) {
		STAssertNoThrow([buffer removeObjectAtIndex:0], nil);
		STAssertEquals([buffer count], [abc count]-removed, nil);
	}
	[buffer removeAllObjects];
	// Test removing the last object repeatedly
	[buffer addObjectsFromArray:abc];
	for (NSUInteger removed = 1; removed <= [abc count]; removed++) {
		STAssertNoThrow([buffer removeObjectAtIndex:[abc count]-removed], nil);
		STAssertEquals([buffer count], [abc count]-removed, nil);
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
		STAssertNoThrow([buffer removeObjectAtIndex:index], nil);
		[objects removeObjectAtIndex:index];
		STAssertEqualObjects(buffer, objects, nil);
		STAssertEquals([buffer count], [buffer distanceFromHeadToTail], nil);
	}
	// Remove the last object and cause tail index to wrap
	// This is the pattern it should follow: ______AB ______A_
	STAssertNoThrow([buffer removeObjectAtIndex:2], nil);
	[objects removeObjectAtIndex:2];
	STAssertEqualObjects(buffer, objects, nil);
	STAssertEquals([buffer count], [buffer distanceFromHeadToTail], nil);
	STAssertNoThrow([buffer removeObjectAtIndex:1], nil);
	[objects removeObjectAtIndex:1];
	STAssertEqualObjects(buffer, objects, nil);
	STAssertEquals([buffer count], [buffer distanceFromHeadToTail], nil);
	// Remove the first object and cause head index to wrap
	[buffer removeFirstObject];
	objects = [NSMutableArray arrayWithArray:abc];
	// This is the pattern it should follow: BC_____A BC______ _C______
	[buffer addObjectsFromArray:objects];
	STAssertNoThrow([buffer removeObjectAtIndex:0], nil);
	[objects removeObjectAtIndex:0];
	STAssertEqualObjects(buffer, objects, nil);
	STAssertEquals([buffer count], [buffer distanceFromHeadToTail], nil);
	STAssertNoThrow([buffer removeObjectAtIndex:0], nil);
	[objects removeObjectAtIndex:0];
	STAssertEqualObjects(buffer, objects, nil);
	STAssertEquals([buffer count], [buffer distanceFromHeadToTail], nil);
}

- (void) testRemoveObjectsAtIndexes {
	// Test nil and invalid indexes
	STAssertThrows([buffer removeObjectsAtIndexes:nil], nil);
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	STAssertThrows([buffer removeObjectsAtIndexes:indexes], nil);
	
	NSMutableArray* expected = [NSMutableArray array];
	for (NSUInteger location = 0; location < [abc count]; location++) {
		for (NSUInteger length = 0; length <= [abc count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate buffer and expected
			[expected removeAllObjects];
			[expected addObjectsFromArray:abc];
			[expected addObjectsFromArray:abc];
			[buffer removeAllObjects];
			[buffer addObjectsFromArray:expected];
			STAssertNoThrow([buffer removeObjectsAtIndexes:indexes], nil);
			[expected removeObjectsAtIndexes:indexes];
			STAssertEquals([buffer count], [expected count], nil);
			STAssertEqualObjects([buffer allObjects], expected, nil);
		}
	}	
	STAssertThrows([buffer removeObjectsAtIndexes:nil], nil);
}

- (void) testReplaceObjectAtIndexWithObject {
	STAssertThrows([buffer replaceObjectAtIndex:0 withObject:nil], nil);
	STAssertThrows([buffer replaceObjectAtIndex:1 withObject:nil], nil);
	
	[buffer addObjectsFromArray:abc];
	
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEqualObjects([buffer objectAtIndex:i], [abc objectAtIndex:i], nil);
		[buffer replaceObjectAtIndex:i withObject:@"Z"];
		STAssertEqualObjects([buffer objectAtIndex:i], @"Z", nil);
	}
}

#pragma mark -
#pragma mark <Protocols>

- (void) testNSCoding {
	NSArray *objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",
						@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil];
	[buffer addObjectsFromArray:objects];
	STAssertEquals([buffer count], [objects count], nil);
	STAssertEquals([buffer capacity], (NSUInteger)32, nil);
	STAssertEqualObjects([buffer allObjects], objects, nil);
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:buffer];
	buffer = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	STAssertEquals([buffer count], [objects count], nil);
	STAssertEquals([buffer capacity], (NSUInteger)32, nil);
	STAssertEqualObjects([buffer allObjects], objects, nil);
}

- (void) testNSCopying {
	NSArray *objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",
						@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil];
	[buffer addObjectsFromArray:objects];
	id buffer2 = [[buffer copy] autorelease];
	[buffer removeAllObjects];
	STAssertNotNil(buffer2, nil);
	STAssertEquals([buffer2 count], [objects count], nil);
	STAssertEqualObjects([buffer2 allObjects], objects, nil);
}

- (void) testNSFastEnumeration {
	int number, expected, count;
	for (number = 1; number <= 32; number++)
		[buffer addObject:[NSNumber numberWithInt:number]];
	count = 0;
	expected = 1;
	e = [buffer objectEnumerator];
	while (anObject = [e nextObject]) {
		STAssertEquals([anObject intValue], expected++, nil);
		++count;
	}
	STAssertEquals(count, 32, nil);

	BOOL raisedException = NO;
	@try {
		for (NSNumber *number in buffer)
			[buffer addObject:@"bogus"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, nil);
	
	// Test enumeration when buffer wraps around
	
	[buffer removeAllObjects];
	// Insert and remove 3 elements to make the buffer wrap with 15 elements
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer addObject:anObject];
		[buffer removeFirstObject];
	}
	checkCountAndDistanceFromHeadToTail(0);
	for (number = 1; number < 16; number++)
		[buffer addObject:[NSNumber numberWithInt:number]];
	count = 0;
	expected = 1;
	e = [buffer objectEnumerator];
	while (anObject = [e nextObject]) {
		STAssertEquals([anObject intValue], expected++, nil);
		++count;
	}
	STAssertEquals(count, 15, nil);
}

@end
