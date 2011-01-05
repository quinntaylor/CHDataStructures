/*
 CHDataStructures.framework -- CHQueueTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHCircularBufferQueue.h"
#import "CHListQueue.h"

@interface CHQueueTest : SenTestCase {
	id<CHQueue> queue;
	NSArray *objects, *queueClasses;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHQueueTest

- (void) setUp {
	queueClasses = [NSArray arrayWithObjects:
					[CHListQueue class],
					[CHCircularBufferQueue class],
					nil];
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
}

- (void) testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++)
		[moreObjects addObject:[NSNumber numberWithUnsignedInteger:i]];
	
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test initializing with nil and empty array parameters
		queue = [[[aClass alloc] initWithArray:nil] autorelease];
		STAssertEquals([queue count], (NSUInteger)0, nil);
		queue = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		STAssertEquals([queue count], (NSUInteger)0, nil);
		// Test initializing with a valid, non-empty array
		queue = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([queue count], [objects count], nil);
		STAssertEqualObjects([queue allObjects], objects, nil);
		// Test initializing with an array larger than the default capacity
		queue = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		STAssertEquals([queue count], [moreObjects count], nil);
		STAssertEqualObjects([queue allObjects], moreObjects, nil);
	}
}

- (void) testIsEqualToQueue {
	NSMutableArray *emptyQueues = [NSMutableArray array];
	NSMutableArray *equalQueues = [NSMutableArray array];
	NSMutableArray *reversedQueues = [NSMutableArray array];
	NSArray *reversedObjects = [[objects reverseObjectEnumerator] allObjects];
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyQueues addObject:[[aClass alloc] init]];
		[equalQueues addObject:[[aClass alloc] initWithArray:objects]];
		[reversedQueues addObject:[[aClass alloc] initWithArray:reversedObjects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalQueues addObject:[equalQueues objectAtIndex:0]];
	
	id<CHQueue> queue1, queue2;
	for (NSUInteger i = 0; i < [queueClasses count]; i++) {
		queue1 = [equalQueues objectAtIndex:i];
		STAssertThrowsSpecificNamed([queue1 isEqualToQueue:[NSString string]],
		                            NSException, NSInvalidArgumentException, nil);
		STAssertFalse([queue1 isEqual:[NSString string]], nil);
		STAssertEqualObjects(queue1, queue1, nil);
		queue2 = [equalQueues objectAtIndex:i+1];
		STAssertEqualObjects(queue1, queue2, nil);
		STAssertEquals([queue1 hash], [queue2 hash], nil);
		queue2 = [emptyQueues objectAtIndex:i];
		STAssertFalse([queue1 isEqual:queue2], nil);
		queue2 = [reversedQueues objectAtIndex:i];
		STAssertFalse([queue1 isEqual:queue2], nil);
	}
}

- (void) testAddObject {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[[aClass alloc] init] autorelease];
		// Test that adding a nil parameter raises an exception
		STAssertThrows([queue addObject:nil], nil);
		STAssertEquals([queue count], (NSUInteger)0, nil);
		// Test adding objects one by one and verify count and ordering
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[queue addObject:anObject];
		STAssertEquals([queue count], [objects count], nil);
		STAssertEqualObjects([queue allObjects], objects, nil);
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[queue addObject:anObject];
			STAssertEqualObjects([queue lastObject], anObject, nil);
		}
		NSUInteger expected = [objects count];
		STAssertEquals([queue count], expected, nil);
		STAssertEqualObjects([queue firstObject], @"A", nil);
		STAssertEqualObjects([queue lastObject],  @"C", nil);
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, nil);
		STAssertEqualObjects([queue firstObject], @"B", nil);
		STAssertEqualObjects([queue lastObject],  @"C", nil);
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, nil);
		STAssertEqualObjects([queue firstObject], @"C", nil);
		STAssertEqualObjects([queue lastObject],  @"C", nil);
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, nil);
		STAssertNil([queue firstObject], nil);
		STAssertNil([queue lastObject], nil);
		STAssertNoThrow([queue removeFirstObject], nil);
		STAssertEquals([queue count], expected, nil);
		STAssertNil([queue firstObject], nil);
		STAssertNil([queue lastObject], nil);
	}
}

@end
