/*
 CHMutableArrayQueueTest.m
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
#import "CHMutableArrayQueue.h"

@interface CHMutableArrayQueueTest : SenTestCase {
	CHMutableArrayQueue *queue;
	NSArray *objects;
}
@end


@implementation CHMutableArrayQueueTest

- (void) setUp {
	queue = [[CHMutableArrayQueue alloc] init];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[queue release];
}

- (void) testInitWithArray {
	[queue release];
	queue = [[CHMutableArrayQueue alloc] initWithArray:objects];
	STAssertEquals([queue count], [objects count], @"-count is incorrect.");
	STAssertEqualObjects([queue allObjects], objects,
						 @"Bad ordering on -initWithArray:");
}

- (void) testAddObjectAndCount {
	STAssertThrows([queue addObject:nil], @"Should raise nilArgumentException.");
	
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	for (id anObject in objects)
		[queue addObject:anObject];
	STAssertEquals([queue count], [objects count], @"-count is incorrect.");
	
	STAssertThrows([queue addObject:nil], @"Should raise nilArgumentException.");
}

- (void) testNextObjectAndRemoveNextObject {
	for (id anObject in objects)
		[queue addObject:anObject];
	
	NSUInteger expected = [objects count];
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([queue firstObject], @"A", @"-firstObject is wrong.");
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	[queue removeFirstObject];
	--expected;
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"B", @"-firstObject is wrong.");
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	[queue removeFirstObject];
	--expected;
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"C", @"-firstObject is wrong.");
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	[queue removeFirstObject];
	--expected;
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	STAssertNil([queue firstObject], @"-firstObject should return nil.");
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], expected, @"-count is incorrect.");
	STAssertNil([queue firstObject], @"-firstObject should return nil.");
	STAssertEquals([queue count], expected, @"-count is incorrect.");
}

@end
