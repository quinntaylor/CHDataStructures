/*
 CHDataStructures.framework -- CHDequeTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <XCTest/XCTest.h>
#import "CHCircularBufferDeque.h"
#import "CHListDeque.h"

@interface CHDequeTest : XCTestCase {
	id<CHDeque> deque;
	NSArray *objects, *dequeClasses;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHDequeTest

- (void)setUp {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	dequeClasses = [NSArray arrayWithObjects:
					[CHListDeque class],
					[CHCircularBufferDeque class],
					nil];
}

- (void)testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++)
		[moreObjects addObject:[NSNumber numberWithUnsignedInteger:i]];
	
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test initializing with nil and empty array parameters
		deque = [[[aClass alloc] initWithArray:nil] autorelease];
		XCTAssertEqual([deque count], (NSUInteger)0);
		deque = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		XCTAssertEqual([deque count], (NSUInteger)0);
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
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([deque prependObject:nil]);
		
		XCTAssertEqual([deque count], (NSUInteger)0);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque prependObject:anObject];
		XCTAssertEqual([deque count], (NSUInteger)3);
		e = [deque objectEnumerator];
		XCTAssertEqualObjects([e nextObject], @"C");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"A");
	}
}

- (void)testAppendObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([deque appendObject:nil]);
		
		XCTAssertEqual([deque count], (NSUInteger)0);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		XCTAssertEqual([deque count], (NSUInteger)3);
		e = [deque objectEnumerator];
		XCTAssertEqualObjects([e nextObject], @"A");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"C");
	}
}

- (void)testFirstObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertEqualObjects([deque firstObject], nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
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
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyDeques addObject:[[aClass alloc] init]];
		[equalDeques addObject:[[aClass alloc] initWithArray:objects]];
		[reversedDeques addObject:[[aClass alloc] initWithArray:reversedObjects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalDeques addObject:[equalDeques objectAtIndex:0]];
	
	id<CHDeque> deque1, deque2;
	for (NSUInteger i = 0; i < [dequeClasses count]; i++) {
		deque1 = [equalDeques objectAtIndex:i];
		XCTAssertThrowsSpecificNamed([deque1 isEqualToDeque:[NSString string]], NSException, NSInvalidArgumentException);
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
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		XCTAssertEqualObjects([deque lastObject], nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque appendObject:anObject];
			XCTAssertEqualObjects([deque lastObject], anObject);
		}	
	}
}

- (void)testRemoveFirstObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
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
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		XCTAssertEqualObjects([deque lastObject], @"C");
		[deque removeLastObject];
		XCTAssertEqualObjects([deque lastObject], @"B");
		[deque removeLastObject];
		XCTAssertEqualObjects([deque lastObject], @"A");
		[deque removeLastObject];
		XCTAssertNil([deque lastObject]);
		// Test that removal works even with an empty deque
		XCTAssertNoThrow([deque removeLastObject]);
		XCTAssertEqual([deque count], (NSUInteger)0);
	}
}

- (void)testReverseObjectEnumerator {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		e = [deque reverseObjectEnumerator];
		XCTAssertEqualObjects([e nextObject], @"C");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"A");
		XCTAssertEqualObjects([e nextObject], nil);
	}
}

@end
