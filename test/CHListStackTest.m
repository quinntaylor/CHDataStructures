/*
 CHListStackTest.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
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
#import "CHListStack.h"

@interface CHListStackTest : SenTestCase {
	CHListStack *stack;
	NSArray *testArray;
}
@end


@implementation CHListStackTest

- (void) setUp {
	stack = [[CHListStack alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[stack release];
}

- (void) testInitWithArray {
	[stack release];
	stack = [[CHListStack alloc] initWithArray:testArray];
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	NSArray *stackOrder = [NSArray arrayWithObjects:@"C", @"B", @"A", nil];
	STAssertEqualObjects([stack allObjects], stackOrder,
						 @"Bad array ordering on -initWithArray:");
}

- (void) testCountAndPushObject {
	STAssertThrows([stack pushObject:nil], @"Should raise nilArgumentException.");
	
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[stack pushObject:object];
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	
	STAssertThrows([stack pushObject:nil], @"Should raise nilArgumentException.");
}

- (void) testTopObjectAndPopObject {
	for (id object in testArray)
		[stack pushObject:object];
	
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"C", @"-topObject is wrong.");
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"B", @"-topObject is wrong.");
	STAssertEquals([stack count], 2u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"A", @"-topObject is wrong.");
	STAssertEquals([stack count], 1u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	STAssertNil([stack topObject], @"-topObject should return nil.");
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
}

@end
