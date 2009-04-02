/*
 CHAbstractCircularBufferCollectionTest.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2009, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractCircularBufferCollection.h"
#import "Util.h"

@interface CHAbstractCircularBufferCollection (Test)

- (NSUInteger) capacity;
- (NSUInteger) headIndex;
- (NSUInteger) tailIndex;

@end

@implementation CHAbstractCircularBufferCollection (Test)

- (NSUInteger) capacity {
	return arrayCapacity;
}

- (NSUInteger) headIndex {
	return headIndex;
}

- (NSUInteger) tailIndex {
	return tailIndex;
}

@end

#pragma mark -

@interface CHAbstractCircularBufferCollectionTest : SenTestCase
{
	CHAbstractCircularBufferCollection *buffer;
	NSArray *abc;
}
@end

@implementation CHAbstractCircularBufferCollectionTest

- (void) setUp {
	buffer = [[CHAbstractCircularBufferCollection alloc] init];
	abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
}

- (void) tearDown {
	[buffer release];
}

- (void) testInit {
	STAssertEquals([buffer capacity],  (NSUInteger)16, @"Wrong capacity.");
	STAssertEquals([buffer headIndex], (NSUInteger)0, @"Wrong head index.");
	STAssertEquals([buffer tailIndex], (NSUInteger)0, @"Wrong tail index.");
	STAssertEquals([buffer count],     (NSUInteger)0, @"Wrong count");
}

- (void) testInitWithArray {
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 1; i <= 15; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer count], (NSUInteger)15, @"Wrong count");
	STAssertEquals([buffer capacity], (NSUInteger)16, @"Wrong capacity");
	STAssertEquals([buffer headIndex], (NSUInteger)0, @"Wrong head index.");
	STAssertEquals([buffer tailIndex], (NSUInteger)15, @"Wrong tail index.");
	
	[array addObject:[NSNumber numberWithInt:16]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer count], (NSUInteger)16, @"Wrong count");
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Wrong capacity");
	STAssertEquals([buffer headIndex], (NSUInteger)0, @"Wrong head index.");
	STAssertEquals([buffer tailIndex], (NSUInteger)16, @"Wrong tail index.");
	
	for (int i = 17; i <= 33; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer count], (NSUInteger)33, @"Wrong count");
	STAssertEquals([buffer capacity], (NSUInteger)64, @"Wrong capacity");
	STAssertEquals([buffer headIndex], (NSUInteger)0, @"Wrong head index.");
	STAssertEquals([buffer tailIndex], (NSUInteger)33, @"Wrong tail index.");
}

- (void) testInitWithCapacity {
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithCapacity:8];
	STAssertEquals([buffer capacity],  (NSUInteger)8, @"Wrong capacity.");
	STAssertEquals([buffer headIndex], (NSUInteger)0, @"Wrong head index.");
	STAssertEquals([buffer tailIndex], (NSUInteger)0, @"Wrong tail index.");
	STAssertEquals([buffer count],     (NSUInteger)0, @"Wrong count");
}

#pragma mark Insertion

- (void) testAppendObject {
	[buffer appendObject:@"A"];
	[buffer appendObject:@"B"];
	[buffer appendObject:@"C"];
	STAssertEquals([buffer count], (NSUInteger)3, @"Wrong object count");
	STAssertEquals([buffer headIndex], (NSUInteger)0,
				   @"Wrong position for head index");
	STAssertEquals([buffer tailIndex], (NSUInteger)3,
				   @"Wrong position for tail index");
	
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
	STAssertEquals([buffer count], (NSUInteger)3, @"Wrong object count");
	STAssertEquals([buffer headIndex], [buffer capacity] - 3,
				   @"Wrong position for head index");
	STAssertEquals([buffer tailIndex], (NSUInteger)0,
				   @"Wrong position for tail index");
	
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
		
#pragma mark Access

- (void) testCount {
	STAssertEquals([buffer count], (NSUInteger)0, @"Wrong count");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	STAssertEquals([buffer count], [abc count], @"Wrong count");
}

- (void) testAllObjects {
	STAssertNotNil([buffer allObjects], @"-allObjects should never return nil");
	STAssertEquals([[buffer allObjects] count], (NSUInteger)0, @"Wrong count");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	STAssertEqualObjects([buffer allObjects], abc, @"Bad result for -allObjects");
}

- (void) testEnumerator {
	NSEnumerator *e;
	
	
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
	
	for (id anObject in abc)
		[buffer appendObject:anObject];
	
	// Test forward enumeration
	
	e = [buffer objectEnumerator];
	STAssertEquals([[e allObjects] count], [abc count], @"Wrong count");
	
	e = [buffer objectEnumerator];
	[e nextObject];
	STAssertEquals([[e allObjects] count], [abc count]-1, @"Wrong count");
	
	e = [buffer objectEnumerator];
	STAssertEqualObjects([e nextObject], @"A", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"B", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"C", @"Wrong object");
	STAssertNil([e nextObject], @"Bad response, -nextObject should be nil");

	// Test reverse enumeration
	
	e = [buffer reverseObjectEnumerator];
	STAssertEquals([[e allObjects] count], [abc count], @"Wrong count");
	
	e = [buffer reverseObjectEnumerator];
	[e nextObject];
	STAssertEquals([[e allObjects] count], [abc count]-1, @"Wrong count");
	
	e = [buffer reverseObjectEnumerator];
	STAssertEqualObjects([e nextObject], @"C", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"B", @"Wrong object");
	STAssertEqualObjects([e nextObject], @"A", @"Wrong object");
	STAssertNil([e nextObject], @"Bad response, -nextObject should be nil");
}

- (void) testDescription {
	STAssertEqualObjects([buffer description], [[buffer allObjects] description],
						 @"Descriptions should be equal");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	STAssertEqualObjects([buffer description], [[buffer allObjects] description],
						 @"Descriptions should be equal");
}

#pragma mark Search

- (void) testContainsObject {
	for (id anObject in abc)
		STAssertFalse([buffer containsObject:anObject], @"Buffer is empty");
	STAssertFalse([buffer containsObject:@"Z"], @"Buffer is empty");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	for (id anObject in abc)
		STAssertTrue([buffer containsObject:anObject], @"Incorrect result");
	STAssertFalse([buffer containsObject:@"Z"], @"Incorrect result");
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	for (id anObject in abc)
		STAssertFalse([buffer containsObjectIdenticalTo:anObject], @"Buffer is empty");
	STAssertFalse([buffer containsObjectIdenticalTo:@"Z"], @"Buffer is empty");
	STAssertFalse([buffer containsObjectIdenticalTo:a], @"Incorrect result");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	for (id anObject in abc)
		STAssertTrue([buffer containsObjectIdenticalTo:anObject], @"Incorrect result");
	STAssertFalse([buffer containsObjectIdenticalTo:@"Z"], @"Incorrect result");
	STAssertFalse([buffer containsObjectIdenticalTo:a], @"Incorrect result");
}

- (void) testIndexOfObject {
	STAssertEquals([buffer indexOfObject:@"Z"], (NSUInteger)CHNotFound,
				   @"Empty buffer, object should not be found");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	for (id anObject in abc)
		[buffer appendObject:anObject];
	NSUInteger expectedIndex = 0;
	for (id anObject in abc)
		STAssertEquals([buffer indexOfObject:anObject], expectedIndex++,
					   @"Wrong index for object");
	STAssertEquals([buffer indexOfObject:@"Z"], (NSUInteger)CHNotFound,
				   @"Object should not be found in buffer");
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"Z"], (NSUInteger)CHNotFound,
				   @"Empty buffer, object should not be found");
	STAssertEquals([buffer indexOfObjectIdenticalTo:a], (NSUInteger)CHNotFound,
				   @"Empty buffer, object should not be found");
	for (id anObject in abc)
		[buffer appendObject:anObject];
	for (id anObject in abc)
		[buffer appendObject:anObject];
	NSUInteger expectedIndex = 0;
	for (id anObject in abc)
		STAssertEquals([buffer indexOfObjectIdenticalTo:anObject], expectedIndex++,
					   @"Wrong index for object");
	STAssertEquals([buffer indexOfObjectIdenticalTo:@"Z"], (NSUInteger)CHNotFound,
				   @"Object should not be found in buffer");
	STAssertEquals([buffer indexOfObjectIdenticalTo:a], (NSUInteger)CHNotFound,
				   @"Object should not be found in buffer");
}

- (void) testObjectAtIndex {
	STAssertThrows([buffer objectAtIndex:0], @"Range exception.");
	STAssertThrows([buffer objectAtIndex:[abc count]+1], @"Range exception.");
	
	for (id anObject in abc)
		[buffer appendObject:anObject];
	for (NSUInteger searchIndex = 0; searchIndex < [abc count]; searchIndex++) {
		STAssertEqualObjects([buffer objectAtIndex:searchIndex],
							 [abc objectAtIndex:searchIndex], @"Search mismatch");
	}
	STAssertThrows([buffer objectAtIndex:[abc count]+1], @"Range exception.");
}

#pragma mark Removal

- (void) testRemoveFirstObject {
	for (id anObject in abc)
		[buffer appendObject:anObject];
	
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
	for (id anObject in abc)
		[buffer appendObject:anObject];
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

- (void) testRemoveObject {
	STAssertThrows([buffer removeObject:self],
				   @"Should raise exception, unsupported.");
}

- (void) testRemoveObjectIdenticalTo {
	STAssertThrows([buffer removeObjectIdenticalTo:self],
				   @"Should raise exception, unsupported.");
}

- (void) testRemoveObjectAtIndex {
	STAssertThrows([buffer removeObjectAtIndex:0],
				   @"Should raise exception, unsupported.");
}

#pragma mark -
#pragma mark <Protocols>

- (void) testNSCoding {
	NSArray *objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",
						@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil];
	for (id object in objects)
		[buffer appendObject:object];
	STAssertEquals([buffer count], [objects count], @"Incorrect count.");
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Incorrect count.");
	STAssertEqualObjects([buffer allObjects], objects, @"Wrong ordering before archiving.");
	
	NSString *filePath = @"/tmp/CHDataStructures-buffer-collection.plist";
	[NSKeyedArchiver archiveRootObject:buffer toFile:filePath];
	[buffer release];
	
	buffer = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([buffer count], [objects count], @"Incorrect count.");
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Incorrect count.");
	STAssertEqualObjects([buffer allObjects], objects, @"Wrong ordering on reconstruction.");
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

- (void) testNSCopying {
	NSArray *objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",
						@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",nil];
	for (id object in objects)
		[buffer appendObject:object];
	id buffer2 = [buffer copy];
	[buffer removeAllObjects];
	STAssertNotNil(buffer2, @"-copy should not return nil for valid collection.");
	STAssertEquals([buffer2 count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([buffer2 allObjects], objects,
						 @"Unequal collections.");
	[buffer2 release];
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected, count = 0;
	for (number = 1; number <= 32; number++)
		[buffer appendObject:[NSNumber numberWithUnsignedInteger:number]];
	expected = 1;
	for (NSNumber *object in buffer) {
		STAssertEquals([object unsignedIntegerValue], expected++,
					   @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, (NSUInteger)32, @"Count of enumerated items is incorrect.");

	BOOL raisedException = NO;
	@try {
		for (id object in buffer)
			[buffer appendObject:@"123"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, @"Should raise mutation exception.");
}

@end
