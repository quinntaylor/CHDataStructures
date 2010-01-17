/*
 CHDataStructures.framework -- CHAbstractCircularBufferCollectionTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractCircularBufferCollection.h"
#import "Util.h"

@interface CHAbstractCircularBufferCollection (Test)

- (NSUInteger) capacity;
- (NSUInteger) distanceFromHeadToTail;
- (void) addObjectsFromArray:(NSArray*)array;

@end

@implementation CHAbstractCircularBufferCollection (Test)

- (NSUInteger) capacity {
	return arrayCapacity;
}

- (NSUInteger) distanceFromHeadToTail {
	return (tailIndex - headIndex + arrayCapacity) % arrayCapacity;
}

- (void) addObjectsFromArray:(NSArray*)otherArray {
	id anObject;
	NSEnumerator *e = [otherArray objectEnumerator];
	while (anObject = [e nextObject])
		[self insertObject:anObject atIndex:count];
}

@end

#pragma mark -

@interface CHAbstractCircularBufferCollectionTest : SenTestCase
{
	CHAbstractCircularBufferCollection *buffer;
	NSArray *abc;
	NSMutableArray *fifteen;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHAbstractCircularBufferCollectionTest

- (void) setUp {
	buffer = [[CHAbstractCircularBufferCollection alloc] init];
	abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	fifteen = [[NSMutableArray alloc] init];
	for (int i = 1; i <= 15; i++)
		[fifteen addObject:[NSNumber numberWithInt:i]];
}

- (void) tearDown {
	[buffer release];
}

// This method checks tail-head (accounting for wrapping) against the count.
// This assumes
- (void) checkCountMatchesDistanceFromHeadToTail:(NSUInteger) expectedValue {
	STAssertEquals([buffer count], expectedValue, @"Wrong count");
	STAssertEquals([buffer distanceFromHeadToTail], expectedValue,
	               @"Wrong distance between head and tail indices.");
}

- (void) testInit {
	STAssertEquals([buffer capacity], (NSUInteger)16, @"Wrong capacity.");
	[self checkCountMatchesDistanceFromHeadToTail:0];
}

- (void) testInitWithArray {
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 1; i <= 15; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer capacity], (NSUInteger)16, @"Wrong capacity");
	[self checkCountMatchesDistanceFromHeadToTail:15];
	
	[array addObject:[NSNumber numberWithInt:16]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Wrong capacity");
	[self checkCountMatchesDistanceFromHeadToTail:16];
	
	for (int i = 17; i <= 33; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer capacity], (NSUInteger)64, @"Wrong capacity");
	[self checkCountMatchesDistanceFromHeadToTail:33];
}

- (void) testInitWithCapacity {
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithCapacity:8];
	STAssertEquals([buffer capacity], (NSUInteger)8, @"Wrong capacity.");
	[self checkCountMatchesDistanceFromHeadToTail:0];
}

#pragma mark Insertion

- (void) testAppendObject {
	[buffer appendObject:@"A"];
	[buffer appendObject:@"B"];
	[buffer appendObject:@"C"];
	[self checkCountMatchesDistanceFromHeadToTail:3];
	
	// Force expansion of original capacity
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] init];
	for (int i = 1; i <= 16; i++)
		[buffer appendObject:[NSNumber numberWithInt:i]];
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Wrong capacity");
	for (int i = 17; i <= 33; i++)
		[buffer appendObject:[NSNumber numberWithInt:i]];
	STAssertEquals([buffer capacity], (NSUInteger)64, @"Wrong capacity");
}

- (void) testPrependObject {
	[buffer prependObject:@"A"];
	[buffer prependObject:@"B"];
	[buffer prependObject:@"C"];
	[self checkCountMatchesDistanceFromHeadToTail:3];
	
	// Force expansion of original capacity
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] init];
	for (int i = 1; i <= 16; i++)
		[buffer prependObject:[NSNumber numberWithInt:i]];
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Wrong capacity");
	for (int i = 17; i <= 33; i++)
		[buffer prependObject:[NSNumber numberWithInt:i]];
	STAssertEquals([buffer capacity], (NSUInteger)64, @"Wrong capacity");
}

- (void) testInsertObjectAtIndex {
	// Test error conditions
	STAssertThrows([buffer insertObject:nil atIndex:0],
				   @"Should raise an exception on nil.");
	STAssertThrows([buffer insertObject:@"Z" atIndex:-1],
				   @"Should raise NSRangeException.");
	STAssertThrows([buffer insertObject:@"Z" atIndex:1],
				   @"Should raise NSRangeException.");
	
	e = [abc reverseObjectEnumerator];
	while (anObject = [e nextObject])
		[buffer prependObject:anObject];
	[buffer appendObject:@"D"];
	[self checkCountMatchesDistanceFromHeadToTail:[abc count]+1];
	
	// Note: Inserting at the front and back are covered by prepend/append tests

	// Try inserting in the middle within both halves of a wraped-around buffer
	[buffer insertObject:@"X" atIndex:1];
	[self checkCountMatchesDistanceFromHeadToTail:[abc count]+2];
	[buffer insertObject:@"Y" atIndex:3];
	[self checkCountMatchesDistanceFromHeadToTail:[abc count]+3];
	[buffer insertObject:@"Z" atIndex:5];
	[self checkCountMatchesDistanceFromHeadToTail:[abc count]+4];
	
	STAssertEqualObjects([buffer objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([buffer objectAtIndex:1], @"X", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([buffer objectAtIndex:2], @"B", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([buffer objectAtIndex:3], @"Y", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([buffer objectAtIndex:4], @"C", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([buffer objectAtIndex:5], @"Z", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([buffer objectAtIndex:6], @"D", @"-objectAtIndex: is wrong.");
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	STAssertThrows([buffer exchangeObjectAtIndex:0 withObjectAtIndex:1],
				   @"Should raise exception, collection is empty.");
	STAssertThrows([buffer exchangeObjectAtIndex:1 withObjectAtIndex:0],
				   @"Should raise exception, collection is empty.");
	
	[buffer addObjectsFromArray:abc];
	
	[buffer exchangeObjectAtIndex:1 withObjectAtIndex:1];
	STAssertEqualObjects([buffer allObjects], abc,
	                     @"Should have no effect.");
	[buffer exchangeObjectAtIndex:0 withObjectAtIndex:2];
	STAssertEqualObjects([buffer allObjects], [[abc reverseObjectEnumerator] allObjects],
	                     @"Should swap first and last element.");
}
		
#pragma mark Access

- (void) testCount {
	STAssertEquals([buffer count], (NSUInteger)0, @"Wrong count");
	[buffer addObjectsFromArray:abc];
	STAssertEquals([buffer count], [abc count], @"Wrong count");
}

- (void) testAllObjects {
	STAssertNotNil([buffer allObjects], @"-allObjects should never return nil");
	STAssertEquals([[buffer allObjects] count], (NSUInteger)0, @"Wrong count");
	
	[buffer addObjectsFromArray:abc];
	STAssertEqualObjects([buffer allObjects], abc, @"Bad result for -allObjects");
	
	// Test -allObjects when the buffer wraps around to the beginning
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[buffer removeFirstObject];
	[self checkCountMatchesDistanceFromHeadToTail:0];
	NSMutableArray *objects = [NSMutableArray array];
	for (int i = 1; i < 16; i++) {
		[objects addObject:[NSNumber numberWithInt:i]];
	}
	[buffer addObjectsFromArray:objects];
	STAssertEquals([buffer count], [objects count], @"Wrong count of objects.");
	STAssertEqualObjects([buffer allObjects], objects, @"Bad result for -allObjects");
}

- (void) testEnumerator {
	STAssertNil([[buffer objectEnumerator] nextObject],
				@"Enumerator should be empty");
	STAssertNotNil([[buffer objectEnumerator] allObjects],
				   @"Should never return nil");
	STAssertEquals([[[buffer objectEnumerator] allObjects] count], (NSUInteger)0,
				   @"Wrong count");

	STAssertNil([[buffer reverseObjectEnumerator] nextObject],
				@"Enumerator should be empty");
	STAssertNotNil([[buffer reverseObjectEnumerator] allObjects],
				   @"Should never return nil");
	STAssertEquals([[[buffer reverseObjectEnumerator] allObjects] count], (NSUInteger)0,
				   @"Wrong count");
	
	[buffer addObjectsFromArray:abc];
	
	NSArray *allObjects;
	
	// Test forward enumeration
	
	e = [buffer objectEnumerator];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count], @"Wrong count");
	STAssertEqualObjects(allObjects, abc, @"Arrays should be equal.");
	
	e = [buffer objectEnumerator];
	[e nextObject];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count]-1, @"Wrong count");
	
	e = [buffer objectEnumerator];
	STAssertEqualObjects([e nextObject], @"A", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"B", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"C", @"Wrong object");
	STAssertNil([e nextObject], @"Bad response, -nextObject should be nil");
	
	// Cause mutation exception
	[buffer appendObject:@"Z"];
	STAssertThrows([e nextObject], @"Should throw exception after mutation.");
	STAssertThrows([e allObjects], @"Should throw exception after mutation.");
	[buffer removeLastObject];

	// Test reverse enumeration
	
	e = [buffer reverseObjectEnumerator];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count], @"Wrong count");
	STAssertEqualObjects(allObjects, [[abc reverseObjectEnumerator] allObjects],
						 @"Arrays should be equal.");
	
	e = [buffer reverseObjectEnumerator];
	[e nextObject];
	allObjects = [e allObjects];
	STAssertEquals([allObjects count], [abc count]-1, @"Wrong count");
	
	e = [buffer reverseObjectEnumerator];
	STAssertEqualObjects([e nextObject], @"C", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"B", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"A", @"Wrong object");
	STAssertNil([e nextObject], @"Bad response, -nextObject should be nil");

	// Cause mutation exception
	[buffer appendObject:@"Z"];
	STAssertThrows([e nextObject], @"Should throw exception after mutation.");
	STAssertThrows([e allObjects], @"Should throw exception after mutation.");
	[buffer removeLastObject];
}

- (void) testDescription {
	STAssertEqualObjects([buffer description], [[buffer allObjects] description],
						 @"Descriptions should be equal");
	[buffer addObjectsFromArray:abc];
	STAssertEqualObjects([buffer description], [[buffer allObjects] description],
						 @"Descriptions should be equal");
}

#pragma mark Search

- (void) testContainsObject {
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertFalse([buffer containsObject:anObject], @"Buffer is empty");
	STAssertFalse([buffer containsObject:@"Z"], @"Buffer is empty");
	[buffer addObjectsFromArray:abc];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertTrue([buffer containsObject:anObject], @"Incorrect result");
	STAssertFalse([buffer containsObject:@"Z"], @"Incorrect result");
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertFalse([buffer containsObjectIdenticalTo:anObject], @"Buffer is empty");
	STAssertFalse([buffer containsObjectIdenticalTo:@"Z"], @"Buffer is empty");
	STAssertFalse([buffer containsObjectIdenticalTo:a], @"Incorrect result");
	[buffer addObjectsFromArray:abc];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		STAssertTrue([buffer containsObjectIdenticalTo:anObject], @"Incorrect result");
	STAssertFalse([buffer containsObjectIdenticalTo:@"Z"], @"Incorrect result");
	STAssertFalse([buffer containsObjectIdenticalTo:a], @"Incorrect result");
}

- (void) testIndexOfObject {
	STAssertEquals([buffer indexOfObject:@"Z"], (NSUInteger)NSNotFound,
				   @"Empty buffer, object should not be found");
	// Move the head index to 3 so adding 15 objects will wrap.
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer appendObject:anObject];
		[buffer removeFirstObject];
	}
	[buffer addObjectsFromArray:fifteen];
	
	NSUInteger expectedIndex = 0;
	e = [fifteen objectEnumerator];
	while (anObject = [e nextObject]) {
		STAssertEquals([buffer indexOfObject:anObject], expectedIndex++,
					   @"Wrong index for object");
	}
	STAssertEquals([buffer indexOfObject:@"Z"], (NSUInteger)NSNotFound,
				   @"Object should not be found in buffer");
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"Z"], (NSUInteger)NSNotFound,
				   @"Empty buffer, object should not be found");
	STAssertEquals([buffer indexOfObjectIdenticalTo:a], (NSUInteger)NSNotFound,
				   @"Empty buffer, object should not be found");
	// Move the head index to 3 so adding 15 objects will wrap.
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer appendObject:anObject];
		[buffer removeFirstObject];
	}
	[buffer addObjectsFromArray:fifteen];

	NSUInteger expectedIndex = 0;
	e = [fifteen objectEnumerator];
	while (anObject = [e nextObject])
		STAssertEquals([buffer indexOfObjectIdenticalTo:anObject], expectedIndex++,
					   @"Wrong index for object");
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"Z"], (NSUInteger)NSNotFound,
				   @"Object should not be found in buffer");
	STAssertEquals([buffer indexOfObjectIdenticalTo:a], (NSUInteger)NSNotFound,
				   @"Object should not be found in buffer");
}

- (void) testIndexOfObjectInRange {
	STAssertThrows([buffer indexOfObject:nil inRange:NSMakeRange(0, 1)],
	               @"Should raise range exception.");
	STAssertNoThrow([buffer indexOfObject:nil inRange:NSMakeRange(0, 0)],
					@"Should raise range exception.");
	[buffer addObjectsFromArray:abc];
	NSRange range = NSMakeRange(1, 1);
	STAssertEquals([buffer indexOfObject:@"A" inRange:range], (NSUInteger)NSNotFound, 
				   @"Value should not appear in specified range.");
	STAssertEquals([buffer indexOfObject:@"B" inRange:range], (NSUInteger)1,
				   @"Value should appear in specified range.");
	STAssertEquals([buffer indexOfObject:@"C" inRange:range], (NSUInteger)NSNotFound,
				   @"Value should not appear in specified range.");
}

- (void) testIndexOfObjectIdenticalToInRange {
	STAssertThrows([buffer indexOfObjectIdenticalTo:nil inRange:NSMakeRange(0, 1)],
	               @"Should raise range exception.");	
	STAssertNoThrow([buffer indexOfObjectIdenticalTo:nil inRange:NSMakeRange(0, 0)],
					@"Should raise range exception.");
	[buffer addObjectsFromArray:abc];
	NSRange range = NSMakeRange(1, 1);
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"A" inRange:range], (NSUInteger)NSNotFound,
				   @"Value should not appear in specified range.");
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"B" inRange:range], (NSUInteger)1,
				   @"Value should appear in specified range.");
	STAssertEquals([buffer indexOfObjectIdenticalTo:[NSString stringWithFormat:@"B"] inRange:range], (NSUInteger)NSNotFound,
				   @"Value should not appear in specified range.");
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"C" inRange:range], (NSUInteger)NSNotFound,
				   @"Value should not appear in specified range.");
}

- (void) testObjectAtIndex {
	STAssertThrows([buffer objectAtIndex:0], @"Range exception.");
	[buffer addObjectsFromArray:abc];
	for (NSUInteger searchIndex = 0; searchIndex < [abc count]; searchIndex++) {
		STAssertEqualObjects([buffer objectAtIndex:searchIndex],
							 [abc objectAtIndex:searchIndex], @"Search mismatch");
	}
	STAssertThrows([buffer objectAtIndex:[abc count]+1], @"Range exception.");
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
				STAssertThrows([buffer objectsAtIndexes:indexes], @"Range exception");
			} else {
				STAssertEqualObjects([buffer objectsAtIndexes:indexes],
									 [abc objectsAtIndexes:indexes],
									 @"Range selections should be equal.");
			}
		}
	}
}

- (void) testObjectsInRange {
	NSRange range = NSMakeRange(1, 1);
	STAssertThrows([buffer objectsInRange:range], @"Range exception");
	[buffer addObjectsFromArray:abc];
	STAssertEqualObjects([buffer objectsInRange:range],
						 [[buffer allObjects] subarrayWithRange:range],
						 @"Range selections should be equal.");
}

#pragma mark Removal

- (void) testRemoveFirstObject {
	[buffer addObjectsFromArray:abc];
	
	NSUInteger expected = [abc count];
	STAssertEqualObjects([buffer firstObject], @"A", @"Wrong -firstObject.");
	STAssertEquals([buffer count], expected, @"Incorrect count.");
	[buffer removeFirstObject];
	--expected;
	STAssertEqualObjects([buffer firstObject], @"B", @"Wrong -firstObject.");
	STAssertEquals([buffer count], expected, @"Incorrect count.");
	[buffer removeFirstObject];
	--expected;
	STAssertEqualObjects([buffer firstObject], @"C", @"Wrong -firstObject.");
	STAssertEquals([buffer count], expected, @"Incorrect count.");
	[buffer removeFirstObject];
	--expected;
	STAssertNil([buffer firstObject], @"-firstObject should return nil.");
	STAssertEquals([buffer count], expected, @"Incorrect count.");
	[buffer removeFirstObject];
	STAssertNil([buffer firstObject], @"-firstObject should return nil.");
	STAssertEquals([buffer count], expected, @"Incorrect count.");

	STAssertNoThrow([buffer removeLastObject],
					@"Should never raise an exception, even when empty.");
}

- (void) testRemoveLastObject {
	[buffer addObjectsFromArray:abc];
	NSUInteger expected = [abc count];
	STAssertEqualObjects([buffer lastObject], @"C", @"Wrong -lastObject.");
	STAssertEquals([buffer count], expected--, @"Incorrect count.");
	[buffer removeLastObject];
	STAssertEqualObjects([buffer lastObject], @"B", @"Wrong -lastObject.");
	STAssertEquals([buffer count], expected--, @"Incorrect count.");
	[buffer removeLastObject];
	STAssertEqualObjects([buffer lastObject], @"A", @"Wrong -lastObject.");
	STAssertEquals([buffer count], expected--, @"Incorrect count.");
	[buffer removeLastObject];
	STAssertEqualObjects([buffer lastObject], nil, @"Wrong -lastObject.");
	STAssertNoThrow([buffer removeLastObject],
					@"Should never raise an exception, even when empty.");
	STAssertEquals([buffer count], expected, @"Incorrect count.");
}

- (void) testRemoveAllObjects {
	STAssertEquals([buffer count], (NSUInteger)0, @"Incorrect count.");
	[buffer addObjectsFromArray:abc];
	[self checkCountMatchesDistanceFromHeadToTail:3];

	[buffer removeAllObjects];
	[self checkCountMatchesDistanceFromHeadToTail:0];
	
	// Test whether circular buffer contracts when all objects are removed.
	STAssertEquals([buffer capacity], (NSUInteger)16, @"Wrong capacity.");
	// Insert each object 3 times to force array capacity to 64 elements
	e = [fifteen objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer appendObject:anObject];
		[buffer appendObject:anObject];
		[buffer appendObject:anObject];
	}
	STAssertEquals([buffer count], [fifteen count]*3, @"Incorrect count.");
	STAssertEquals([buffer capacity], (NSUInteger)64, @"Wrong capacity.");
	[buffer removeAllObjects];
	STAssertEquals([buffer count], (NSUInteger)0, @"Incorrect count.");
	STAssertEquals([buffer capacity], (NSUInteger)16, @"Wrong capacity.");
}

- (void) removeObjectSetup {
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithCapacity:8];
}

- (NSArray*) removeObjectTestArrays {
	NSArray *prefix  = [NSArray arrayWithObjects:@"X",@"A",@"X",@"B",@"X",@"C",nil];
	NSArray *postfix = [NSArray arrayWithObjects:@"A",@"X",@"B",@"X",@"C",@"X",nil];
	NSArray *bothfix = [NSArray arrayWithObjects:@"X",@"A",@"X",@"B",@"X",@"C",@"X",nil];
	return [NSArray arrayWithObjects:prefix, postfix, bothfix, nil];
}

- (void) testRemoveObject {
	STAssertNoThrow([buffer removeObject:@"A"], @"No effect when empty.");
	[buffer addObjectsFromArray:abc];
	STAssertEquals([buffer count], [abc count], @"Incorrect count.");
	STAssertNoThrow([buffer removeObject:nil],  @"No effect with nil object.");
	STAssertEquals([buffer count], [abc count], @"Incorrect count.");
	
	// Test removing all instances of an object in various scenarios
	[self removeObjectSetup];
	NSEnumerator *testArrays = [[self removeObjectTestArrays] objectEnumerator];
	NSArray *testArray;
	while (testArray = [testArrays nextObject]) {
		for (int i = 0; i <= 1; i++) {
			// Offset the head pointer by 3 to force wrapping
			if (i == 1) {
				e = [abc objectEnumerator];
				while (anObject = [e nextObject]) {
					[buffer appendObject:anObject];
					[buffer removeFirstObject];
				}				
			}
			[buffer addObjectsFromArray:testArray];
			STAssertEquals([buffer count], [testArray count], @"Incorrect count.");
			[buffer removeObject:@"Z"];
			STAssertEquals([buffer count], [testArray count], @"Incorrect count.");
			[buffer removeObject:@"X"];
			STAssertEquals([buffer count], [abc count], @"Incorrect count.");
			[buffer removeObject:@"X"];
			STAssertEquals([buffer count], [abc count], @"Incorrect count.");
			[buffer removeAllObjects];
		}
	}
}

- (void) testRemoveObjectIdenticalTo {
	STAssertNoThrow([buffer removeObject:@"A"], @"No effect when empty.");
	
	NSString *a = [NSString stringWithFormat:@"A"];
	NSString *b = [NSString stringWithFormat:@"B"];
	NSString *x = [NSString stringWithFormat:@"X"];
	
	[buffer appendObject:a];
	[buffer appendObject:b];
	[buffer appendObject:@"C"];
	[buffer appendObject:a];
	[buffer appendObject:b];
	STAssertNoThrow([buffer removeObjectIdenticalTo:nil], @"No effect with nil object.");
	
	STAssertEquals([buffer count], (NSUInteger)5, @"Incorrect count.");
	[buffer removeObjectIdenticalTo:@"A"];
	STAssertEquals([buffer count], (NSUInteger)5, @"Incorrect count.");
	[buffer removeObjectIdenticalTo:@"B"];
	STAssertEquals([buffer count], (NSUInteger)5, @"Incorrect count.");
	[buffer removeObjectIdenticalTo:a];
	STAssertEquals([buffer count], (NSUInteger)3, @"Incorrect count.");
	[buffer removeObjectIdenticalTo:b];
	STAssertEquals([buffer count], (NSUInteger)1, @"Incorrect count.");

	// Test removing all instances of an object in various scenarios
	[self removeObjectSetup];
	NSEnumerator *testArrays = [[self removeObjectTestArrays] objectEnumerator];
	NSArray *testArray;
	while (testArray = [testArrays nextObject]) {
		for (int i = 0; i <= 1; i++) {
			// Offset the head pointer by 3 to force wrapping
			if (i == 1) {
				e = [abc objectEnumerator];
							while (anObject = [e nextObject]) {
					[buffer appendObject:anObject];
					[buffer removeFirstObject];
				}				
			}
			[buffer addObjectsFromArray:testArray];
			STAssertEquals([buffer count], [testArray count], @"Incorrect count.");
			[buffer removeObjectIdenticalTo:x];
			STAssertEquals([buffer count], [testArray count], @"Incorrect count.");
			[buffer removeObjectIdenticalTo:@"X"];
			STAssertEquals([buffer count], [abc count], @"Incorrect count.");
			[buffer removeObjectIdenticalTo:@"X"];
			STAssertEquals([buffer count], [abc count], @"Incorrect count.");
			[buffer removeAllObjects];
		}
	}
}

- (void) testRemoveObjectAtIndex {
	STAssertThrows([buffer removeObjectAtIndex:0],
				   @"Should raise NSRangeException.");
	e = [abc reverseObjectEnumerator];
	while (anObject = [e nextObject])
		[buffer prependObject:anObject];
	[buffer appendObject:@"D"];
	STAssertThrows([buffer removeObjectAtIndex:[abc count]+1],
				   @"Should raise NSRangeException.");
	
	STAssertNoThrow([buffer removeObjectAtIndex:2], @"Should be no exception.");
	STAssertEquals([buffer count], [abc count], @"Wrong count.");

	STAssertNoThrow([buffer removeObjectAtIndex:1], @"Should be no exception.");
	STAssertEquals([buffer count], [abc count]-1, @"Wrong count.");

	STAssertNoThrow([buffer removeObjectAtIndex:1], @"Should be no exception.");
	STAssertEquals([buffer count], [abc count]-2, @"Wrong count.");
	
	STAssertNoThrow([buffer removeObjectAtIndex:0], @"Should be no exception.");
	STAssertEquals([buffer count], [abc count]-3, @"Wrong count.");
	
	[buffer addObjectsFromArray:fifteen];
	
	[buffer removeObjectAtIndex:[buffer count] - 1];
	
	[buffer removeObjectAtIndex:0];
}

- (void) testRemoveObjectsAtIndexes {
	STAssertThrows([buffer removeObjectsAtIndexes:nil], @"Index set cannot be nil.");
	NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
	STAssertThrows([buffer removeObjectsAtIndexes:indexes], @"Nonexistent index.");
	
	NSMutableArray* expected = [NSMutableArray array];
	for (NSUInteger location = 0; location < [abc count]; location++) {
		for (NSUInteger length = 0; length < [abc count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate buffer and expected
			[expected removeAllObjects];
			[expected addObjectsFromArray:abc];
			[expected addObjectsFromArray:abc];
			[buffer removeAllObjects];
			[buffer addObjectsFromArray:expected];
			STAssertNoThrow([buffer removeObjectsAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			[expected removeObjectsAtIndexes:indexes];
			STAssertEqualObjects(expected, [buffer allObjects], @"Array content mismatch.");
		}
	}	
}

#pragma mark -
#pragma mark <Protocols>

- (void) testNSCoding {
	NSArray *objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",
						@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil];
	[buffer addObjectsFromArray:objects];
	STAssertEquals([buffer count], [objects count], @"Incorrect count.");
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Incorrect count.");
	STAssertEqualObjects([buffer allObjects], objects, @"Wrong ordering before archiving.");
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:buffer];
	[buffer release];
	buffer = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	
	STAssertEquals([buffer count], [objects count], @"Incorrect count.");
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Incorrect count.");
	STAssertEqualObjects([buffer allObjects], objects, @"Wrong ordering on reconstruction.");
}

- (void) testNSCopying {
	NSArray *objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",
						@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil];
	[buffer addObjectsFromArray:objects];
	id buffer2 = [buffer copy];
	[buffer removeAllObjects];
	STAssertNotNil(buffer2, @"-copy should not return nil for valid collection.");
	STAssertEquals([buffer2 count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([buffer2 allObjects], objects,
						 @"Unequal collections.");
	[buffer2 release];
}

#if OBJC_API_2
- (void) testNSFastEnumeration {
	int number, expected, count;
	for (number = 1; number <= 32; number++)
		[buffer appendObject:[NSNumber numberWithInt:number]];
	count = 0;
	expected = 1;
	e = [buffer objectEnumerator];
	while (anObject = [e nextObject]) {
		STAssertEquals([anObject intValue], expected++,
					   @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, 32, @"Count of enumerated items is wrong.");

	BOOL raisedException = NO;
	@try {
		for (NSNumber *number in buffer)
			[buffer appendObject:@"123"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, @"Should raise mutation exception.");
	
	// Test enumeration when buffer wraps around
	
	[buffer removeAllObjects];
	// Insert and remove 3 elements to make the buffer wrap with 15 elements
	e = [abc objectEnumerator];
	while (anObject = [e nextObject]) {
		[buffer appendObject:anObject];
		[buffer removeFirstObject];
	}
	[self checkCountMatchesDistanceFromHeadToTail:0];
	for (number = 1; number < 16; number++)
		[buffer appendObject:[NSNumber numberWithInt:number]];
	count = 0;
	expected = 1;
	e = [buffer objectEnumerator];
	while (anObject = [e nextObject]) {
		STAssertEquals([anObject intValue], expected++,
					   @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, 15, @"Count of enumerated items is wrong.");
}
#endif

@end
