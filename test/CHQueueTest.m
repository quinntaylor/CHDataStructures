//
//  CHQueueTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHCircularBufferQueue.h>
#import <CHDataStructures/CHListQueue.h>

@interface CHQueueTest : XCTestCase {
	id<CHQueue> queue;
	NSArray *objects, *queueClasses;
}
@end

@implementation CHQueueTest

- (void)setUp {
	queueClasses = [NSArray arrayWithObjects:
					[CHListQueue class],
					[CHCircularBufferQueue class],
					nil];
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
}

- (void)testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++) {
		[moreObjects addObject:[NSNumber numberWithUnsignedInteger:i]];
	}
	
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test initializing with nil and empty array parameters
		queue = nil;
		XCTAssertThrows(queue = [[[aClass alloc] initWithArray:nil] autorelease], @"%@", aClass);
		XCTAssertEqual([queue count], (NSUInteger)0);
		queue = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		XCTAssertEqual([queue count], (NSUInteger)0);
		// Test initializing with a valid, non-empty array
		queue = [[[aClass alloc] initWithArray:objects] autorelease];
		XCTAssertEqual([queue count], [objects count]);
		XCTAssertEqualObjects([queue allObjects], objects);
		// Test initializing with an array larger than the default capacity
		queue = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		XCTAssertEqual([queue count], [moreObjects count]);
		XCTAssertEqualObjects([queue allObjects], moreObjects);
	}
}

- (void)testIsEqualToQueue {
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
		XCTAssertThrowsSpecificNamed([queue1 isEqualToQueue:(id)[NSString string]], NSException, NSInvalidArgumentException);
		XCTAssertFalse([queue1 isEqual:[NSString string]]);
		XCTAssertEqualObjects(queue1, queue1);
		queue2 = [equalQueues objectAtIndex:i+1];
		XCTAssertEqualObjects(queue1, queue2);
		XCTAssertEqual([queue1 hash], [queue2 hash]);
		queue2 = [emptyQueues objectAtIndex:i];
		XCTAssertFalse([queue1 isEqual:queue2]);
		queue2 = [reversedQueues objectAtIndex:i];
		XCTAssertFalse([queue1 isEqual:queue2]);
	}
}

- (void)testAddObject {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[[aClass alloc] init] autorelease];
		// Test that adding a nil parameter raises an exception
		XCTAssertThrows([queue addObject:nil]);
		XCTAssertEqual([queue count], (NSUInteger)0);
		// Test adding objects one by one and verify count and ordering
		for (id anObject in objects) {
			[queue addObject:anObject];
		}
		XCTAssertEqual([queue count], [objects count]);
		XCTAssertEqualObjects([queue allObjects], objects);
	}
}

- (void)testRemoveFirstObject {
	NSEnumerator *classes = [queueClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		queue = [[[aClass alloc] init] autorelease];
		for (id anObject in objects) {
			[queue addObject:anObject];
			XCTAssertEqualObjects([queue lastObject], anObject);
		}
		NSUInteger expected = [objects count];
		XCTAssertEqual([queue count], expected);
		XCTAssertEqualObjects([queue firstObject], @"A");
		XCTAssertEqualObjects([queue lastObject],  @"C");
		[queue removeFirstObject];
		--expected;
		XCTAssertEqual([queue count], expected);
		XCTAssertEqualObjects([queue firstObject], @"B");
		XCTAssertEqualObjects([queue lastObject],  @"C");
		[queue removeFirstObject];
		--expected;
		XCTAssertEqual([queue count], expected);
		XCTAssertEqualObjects([queue firstObject], @"C");
		XCTAssertEqualObjects([queue lastObject],  @"C");
		[queue removeFirstObject];
		--expected;
		XCTAssertEqual([queue count], expected);
		XCTAssertNil([queue firstObject]);
		XCTAssertNil([queue lastObject]);
		XCTAssertNoThrow([queue removeFirstObject]);
		XCTAssertEqual([queue count], expected);
		XCTAssertNil([queue firstObject]);
		XCTAssertNil([queue lastObject]);
	}
}

@end
