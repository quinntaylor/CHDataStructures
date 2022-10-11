//
//  CHDequeTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHCircularBufferDeque.h>
#import <CHDataStructures/CHListDeque.h>

@interface CHDequeTest : XCTestCase {
	id<CHDeque> deque;
	NSArray *objects, *dequeClasses;
}
@end

@implementation CHDequeTest

- (void)setUp {
	objects = @[@"A",@"B",@"C"];
	dequeClasses = @[
		[CHListDeque class],
		[CHCircularBufferDeque class],
	];
}

- (void)testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++) {
		[moreObjects addObject:@(i)];
	}
	
	for (Class aClass in dequeClasses) {
		// Test initializing with nil and empty array parameters
		deque = nil;
		XCTAssertThrows([[[aClass alloc] initWithArray:nil] autorelease]);
		XCTAssertEqual([deque count], 0);
		deque = [[[aClass alloc] initWithArray:@[]] autorelease];
		XCTAssertEqual([deque count], 0);
		// Test initializing with a valid, non-empty array
		deque = [[[aClass alloc] initWithArray:objects] autorelease];
		XCTAssertEqual([deque count], [objects count]);
		XCTAssertEqualObjects([deque allObjects], objects);
		// Test initializing with an array larger than the default capacity
		deque = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		XCTAssertEqual([deque count], [moreObjects count]);
		XCTAssertEqualObjects([deque allObjects], moreObjects);
	}
}

- (void)testPrependObject {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([deque prependObject:nil]);
		
		XCTAssertEqual([deque count], 0);
		for (id anObject in objects) {
			[deque prependObject:anObject];
		}
		XCTAssertEqual([deque count], 3);
		NSEnumerator *e = [deque objectEnumerator];
		XCTAssertEqualObjects([e nextObject], @"C");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"A");
	}
}

- (void)testAppendObject {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([deque appendObject:nil]);
		
		XCTAssertEqual([deque count], 0);
		for (id anObject in objects) {
			[deque appendObject:anObject];
		}
		XCTAssertEqual([deque count], 3);
		NSEnumerator *e = [deque objectEnumerator];
		XCTAssertEqualObjects([e nextObject], @"A");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"C");
	}
}

- (void)testFirstObject {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertEqualObjects([deque firstObject], nil);
		for (id anObject in objects) {
			[deque prependObject:anObject];
			XCTAssertEqualObjects([deque firstObject], anObject);
		}
	}
}

- (void)testIsEqualToDeque {
	NSMutableArray *emptyDeques = [NSMutableArray array];
	NSMutableArray *equalDeques = [NSMutableArray array];
	NSMutableArray *reversedDeques = [NSMutableArray array];
	NSArray *reversedObjects = [[objects reverseObjectEnumerator] allObjects];
	for (Class aClass in dequeClasses) {
		[emptyDeques addObject:[[aClass alloc] init]];
		[equalDeques addObject:[[aClass alloc] initWithArray:objects]];
		[reversedDeques addObject:[[aClass alloc] initWithArray:reversedObjects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalDeques addObject:[equalDeques objectAtIndex:0]];
	
	id<CHDeque> deque1, deque2;
	for (NSUInteger i = 0; i < [dequeClasses count]; i++) {
		deque1 = [equalDeques objectAtIndex:i];
		XCTAssertThrowsSpecificNamed([deque1 isEqualToDeque:(id)[NSString string]], NSException, NSInvalidArgumentException);
		XCTAssertFalse([deque1 isEqual:[NSString string]]);
		XCTAssertEqualObjects(deque1, deque1);
		deque2 = [equalDeques objectAtIndex:i+1];
		XCTAssertEqualObjects(deque1, deque2);
		XCTAssertEqual([deque1 hash], [deque2 hash]);
		deque2 = [emptyDeques objectAtIndex:i];
		XCTAssertFalse([deque1 isEqual:deque2]);
		deque2 = [reversedDeques objectAtIndex:i];
		XCTAssertFalse([deque1 isEqual:deque2]);
	}
}

- (void)testLastObject {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertEqualObjects([deque lastObject], nil);
		for (id anObject in objects) {
			[deque appendObject:anObject];
			XCTAssertEqualObjects([deque lastObject], anObject);
		}	
	}
}

- (void)testRemoveFirstObject {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		for (id anObject in objects) {
			[deque appendObject:anObject];
			XCTAssertEqualObjects([deque lastObject], anObject);
		}
		NSUInteger expected = [objects count];
		XCTAssertEqual([deque count], expected);
		XCTAssertEqualObjects([deque firstObject], @"A");
		XCTAssertEqualObjects([deque lastObject],  @"C");
		[deque removeFirstObject];
		--expected;
		XCTAssertEqual([deque count], expected);
		XCTAssertEqualObjects([deque firstObject], @"B");
		XCTAssertEqualObjects([deque lastObject],  @"C");
		[deque removeFirstObject];
		--expected;
		XCTAssertEqual([deque count], expected);
		XCTAssertEqualObjects([deque firstObject], @"C");
		XCTAssertEqualObjects([deque lastObject],  @"C");
		[deque removeFirstObject];
		--expected;
		XCTAssertEqual([deque count], expected);
		XCTAssertNil([deque firstObject]);
		XCTAssertNil([deque lastObject]);
		// Test that removal works even with an empty deque
		XCTAssertNoThrow([deque removeFirstObject]);
		XCTAssertEqual([deque count], expected);
	}
}

- (void)testRemoveLastObject {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		for (id anObject in objects) {
			[deque appendObject:anObject];
		}
		XCTAssertEqualObjects([deque lastObject], @"C");
		[deque removeLastObject];
		XCTAssertEqualObjects([deque lastObject], @"B");
		[deque removeLastObject];
		XCTAssertEqualObjects([deque lastObject], @"A");
		[deque removeLastObject];
		XCTAssertNil([deque lastObject]);
		// Test that removal works even with an empty deque
		XCTAssertNoThrow([deque removeLastObject]);
		XCTAssertEqual([deque count], 0);
	}
}

- (void)testReverseObjectEnumerator {
	for (Class aClass in dequeClasses) {
		deque = [[[aClass alloc] init] autorelease];
		for (id anObject in objects) {
			[deque appendObject:anObject];
		}
		NSEnumerator *e = [deque reverseObjectEnumerator];
		XCTAssertEqualObjects([e nextObject], @"C");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"A");
		XCTAssertEqualObjects([e nextObject], nil);
	}
}

@end
