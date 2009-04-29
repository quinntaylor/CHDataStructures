/*
 CHDataStructures.framework -- CHMutableArrayQueueTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
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
	for (Class aClass in queueClasses) {
		queue = [[CHMutableArrayQueue alloc] initWithArray:objects];
		STAssertEquals([queue count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([queue allObjects], objects,
							 @"Bad ordering on -initWithArray:");
		[queue release];
	}
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

- (void) testRemoveFirstObject {
	for (Class aClass in queueClasses) {
		queue = [[aClass alloc] init];
		for (id anObject in objects) {
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
