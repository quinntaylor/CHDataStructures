/*
 CHDataStructures.framework -- CHQueueTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
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
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) testInitWithArray {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[aClass alloc] initWithArray:objects];
		STAssertEquals([queue count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([queue allObjects], objects,
							 @"Bad ordering on -initWithArray:");
		[queue release];
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
		                            NSException, NSInvalidArgumentException,
		                            @"Should raise NSInvalidArgumentException");
		STAssertFalse([queue1 isEqual:[NSString string]], @"Should not be equal.");
		STAssertTrue([queue1 isEqual:queue1], @"Should be equal to itself.");
		queue2 = [equalQueues objectAtIndex:i+1];
		STAssertTrue([queue1 isEqual:queue2], @"Should be equal.");
		STAssertEquals([queue1 hash], [queue2 hash], @"Hashes should match.");
		queue2 = [emptyQueues objectAtIndex:i];
		STAssertFalse([queue1 isEqual:queue2], @"Should not be equal.");
		queue2 = [reversedQueues objectAtIndex:i];
		STAssertFalse([queue1 isEqual:queue2], @"Should not be equal.");
	}
}

- (void) testAddObject {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[aClass alloc] init];
		STAssertThrows([queue addObject:nil],
					   @"Should raise nilArgumentException.");
		STAssertEquals([queue count], (NSUInteger)0, @"Incorrect count.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[queue addObject:anObject];
		STAssertEquals([queue count], [objects count], @"Incorrect count.");
		
		STAssertThrows([queue addObject:nil],
					   @"Should raise nilArgumentException.");
		[queue release];
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[aClass alloc] init];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[queue addObject:anObject];
			STAssertEqualObjects([queue lastObject], anObject, @"Wrong -lastObject.");
		}
		NSUInteger expected = [objects count];
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertEqualObjects([queue firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([queue lastObject],  @"C", @"Wrong -lastObject.");
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertEqualObjects([queue firstObject], @"B", @"Wrong -firstObject.");
		STAssertEqualObjects([queue lastObject],  @"C", @"Wrong -lastObject.");
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertEqualObjects([queue firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([queue lastObject],  @"C", @"Wrong -lastObject.");
		[queue removeFirstObject];
		--expected;
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertNil([queue firstObject], @"-firstObject should return nil.");
		STAssertNil([queue lastObject],  @"-lastObject should return nil.");
		STAssertNoThrow([queue removeFirstObject],
						@"Should never raise an exception, even when empty.");
		STAssertEquals([queue count], expected, @"Incorrect count.");
		STAssertNil([queue firstObject], @"-firstObject should return nil.");
		STAssertNil([queue lastObject], @"-lastObject should return nil.");

		[queue release];
	}
}

@end
