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
}
@end

@implementation CHAbstractCircularBufferCollectionTest

- (void) setUp {
	buffer = [[CHAbstractCircularBufferCollection alloc] init];
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
	
	[array addObject:[NSNumber numberWithInt:16]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer count], (NSUInteger)16, @"Wrong count");
	STAssertEquals([buffer capacity], (NSUInteger)32, @"Wrong capacity");
	
	for (int i = 17; i <= 33; i++)
		[array addObject:[NSNumber numberWithInt:i]];
	[buffer release];
	buffer = [[CHAbstractCircularBufferCollection alloc] initWithArray:array];
	STAssertEquals([buffer count], (NSUInteger)33, @"Wrong count");
	STAssertEquals([buffer capacity], (NSUInteger)64, @"Wrong capacity");
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
}
		
#pragma mark Access

- (void) testCount {
	STFail(@"Unwritten test case");
}

- (void) testAllObjects {
	STFail(@"Unwritten test case");
}

#pragma mark Search

- (void) testContainsObject {
	STFail(@"Unwritten test case");
}

- (void) testContainsObjectIdenticalTo {
	STFail(@"Unwritten test case");
}

- (void) testIndexOfObject {
	STFail(@"Unwritten test case");
}

- (void) testIndexOfObjectIdenticalTo {
	STFail(@"Unwritten test case");
}

- (void) testObjectAtIndex {
	STFail(@"Unwritten test case");
}

#pragma mark Removal

- (void) testRemoveFirstObject {
	STFail(@"Unwritten test case");
}

- (void) testRemoveLastObject {
	STFail(@"Unwritten test case");
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
	STFail(@"Unwritten test case");
}

- (void) testNSCopying {
	STFail(@"Unwritten test case");
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
}

@end
