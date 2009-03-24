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
#import "CHCircularBufferQueue.h"
#import "CHListQueue.h"
#import "CHMutableArrayQueue.h"

@interface CHQueueTest : SenTestCase {
	CHMutableArrayQueue *queue;
	NSArray *objects, *queueClasses;
}
@end

@implementation CHQueueTest

- (void) setUp {
	queueClasses = [NSArray arrayWithObjects:
					[CHListQueue class],
					[CHMutableArrayQueue class],
					[CHCircularBufferQueue class],
					nil];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) testInitWithArray {
	[queue release];
	queue = [[CHMutableArrayQueue alloc] initWithArray:objects];
	STAssertEquals([queue count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([queue allObjects], objects,
						 @"Bad ordering on -initWithArray:");
}

- (void) testAddObject {
	for (Class aClass in queueClasses) {
		queue = [[aClass alloc] init];
		STAssertThrows([queue addObject:nil],
					   @"Should raise nilArgumentException.");
		STAssertEquals([queue count], (NSUInteger)0, @"Incorrect count.");
		for (id anObject in objects)
			[queue addObject:anObject];
		STAssertEquals([queue count], [objects count], @"Incorrect count.");
		
		STAssertThrows([queue addObject:nil],
					   @"Should raise nilArgumentException.");
		[queue release];
	}
}

- (void) testAddObjectsFromArray {
	for (Class aClass in queueClasses) {
		queue = [[aClass alloc] init];
		STAssertNoThrow([queue addObjectsFromArray:nil],
						@"Should never raise an exception.");
		STAssertEquals([queue count], (NSUInteger)0, @"Incorrect count.");
		[queue addObjectsFromArray:objects];
		STAssertEquals([queue count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([queue allObjects], objects,
							 @"Bad ordering after -[%@ addObjectsFromArray:]",
							 aClass);
		[queue release];
	}
}

- (void) testRemoveFirstObject {
	for (Class aClass in queueClasses) {
		queue = [[aClass alloc] init];
		for (id anObject in objects)
			[queue addObject:anObject];
		
		NSUInteger expected = [objects count];
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertEqualObjects([queue firstObject], @"A", @"Wrong -firstObject.");
		STAssertEquals([queue count], expected, @"Incorrect count.");
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertEqualObjects([queue firstObject], @"B", @"Wrong -firstObject.");
		STAssertEquals([queue count], expected, @"Incorrect count.");
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertEqualObjects([queue firstObject], @"C", @"Wrong -firstObject.");
		STAssertEquals([queue count], expected, @"Incorrect count.");
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertNil([queue firstObject], @"-firstObject should return nil.");
		STAssertEquals([queue count], expected, @"Incorrect count.");
		[queue removeFirstObject];
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertNil([queue firstObject], @"-firstObject should return nil.");
		STAssertEquals([queue count], expected, @"Incorrect count.");

		[queue release];
	}
}


@end
