/*
 CHListQueueTest.m
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
#import "CHListQueue.h"

@interface CHListQueueTest : SenTestCase {
	CHListQueue *queue;
	NSArray *testArray;
}
@end


@implementation CHListQueueTest

- (void) setUp {
	queue = [[CHListQueue alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[queue release];
}

- (void) testAddObjectAndCount {
	STAssertThrows([queue addObject:nil], @"Should raise nilArgumentException.");
	
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[queue addObject:object];
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	
	STAssertThrows([queue addObject:nil], @"Should raise nilArgumentException.");
}

- (void) testNextObjectAndRemoveNextObject {
	for (id object in testArray)
		[queue addObject:object];
	
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([queue firstObject], @"A", @"-firstObject is wrong.");
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"B", @"-firstObject is wrong.");
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"C", @"-firstObject is wrong.");
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue firstObject], @"-firstObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue firstObject], @"-firstObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
}

@end
