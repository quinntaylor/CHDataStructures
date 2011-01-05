/*
 CHDataStructures.framework -- CHDequeTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHCircularBufferDeque.h"
#import "CHListDeque.h"

@interface CHDequeTest : SenTestCase {
	id<CHDeque> deque;
	NSArray *objects, *dequeClasses;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHDequeTest

- (void) setUp {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	dequeClasses = [NSArray arrayWithObjects:
					[CHListDeque class],
					[CHCircularBufferDeque class],
					nil];
}

- (void) testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++)
		[moreObjects addObject:[NSNumber numberWithUnsignedInteger:i]];
	
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test initializing with nil and empty array parameters
		deque = [[[aClass alloc] initWithArray:nil] autorelease];
		STAssertEquals([deque count], (NSUInteger)0, nil);
		deque = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		STAssertEquals([deque count], (NSUInteger)0, nil);
		// Test initializing with a valid, non-empty array
		deque = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([deque count], [objects count], nil);
		STAssertEqualObjects([deque allObjects], objects, nil);
		// Test initializing with an array larger than the default capacity
		deque = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		STAssertEquals([deque count], [moreObjects count], nil);
		STAssertEqualObjects([deque allObjects], moreObjects, nil);
	}
}

- (void) testPrependObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		STAssertThrows([deque prependObject:nil], nil);
		
		STAssertEquals([deque count], (NSUInteger)0, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque prependObject:anObject];
		STAssertEquals([deque count], (NSUInteger)3, nil);
		e = [deque objectEnumerator];
		STAssertEqualObjects([e nextObject], @"C", nil);
		STAssertEqualObjects([e nextObject], @"B", nil);
		STAssertEqualObjects([e nextObject], @"A", nil);
	}
}

- (void) testAppendObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		STAssertThrows([deque appendObject:nil], nil);
		
		STAssertEquals([deque count], (NSUInteger)0, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		STAssertEquals([deque count], (NSUInteger)3, nil);
		e = [deque objectEnumerator];
		STAssertEqualObjects([e nextObject], @"A", nil);
		STAssertEqualObjects([e nextObject], @"B", nil);
		STAssertEqualObjects([e nextObject], @"C", nil);
	}
}

- (void) testFirstObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		STAssertEqualObjects([deque firstObject], nil, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque prependObject:anObject];
			STAssertEqualObjects([deque firstObject], anObject, nil);
		}
	}
}

- (void) testIsEqualToDeque {
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
		STAssertThrowsSpecificNamed([deque1 isEqualToDeque:[NSString string]],
		                            NSException, NSInvalidArgumentException, nil);
		STAssertFalse([deque1 isEqual:[NSString string]], nil);
		STAssertEqualObjects(deque1, deque1, nil);
		deque2 = [equalDeques objectAtIndex:i+1];
		STAssertEqualObjects(deque1, deque2, nil);
		STAssertEquals([deque1 hash], [deque2 hash], nil);
		deque2 = [emptyDeques objectAtIndex:i];
		STAssertFalse([deque1 isEqual:deque2], nil);
		deque2 = [reversedDeques objectAtIndex:i];
		STAssertFalse([deque1 isEqual:deque2], nil);
	}
}

- (void) testLastObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		STAssertEqualObjects([deque lastObject], nil, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque appendObject:anObject];
			STAssertEqualObjects([deque lastObject], anObject, nil);
		}	
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque appendObject:anObject];
			STAssertEqualObjects([deque lastObject], anObject, nil);
		}
		NSUInteger expected = [objects count];
		STAssertEquals([deque count], expected, nil);
		STAssertEqualObjects([deque firstObject], @"A", nil);
		STAssertEqualObjects([deque lastObject],  @"C", nil);
		[deque removeFirstObject];
		--expected;
		STAssertEquals([deque count], expected, nil);
		STAssertEqualObjects([deque firstObject], @"B", nil);
		STAssertEqualObjects([deque lastObject],  @"C", nil);
		[deque removeFirstObject];
		--expected;
		STAssertEquals([deque count], expected, nil);
		STAssertEqualObjects([deque firstObject], @"C", nil);
		STAssertEqualObjects([deque lastObject],  @"C", nil);
		[deque removeFirstObject];
		--expected;
		STAssertEquals([deque count], expected, nil);
		STAssertNil([deque firstObject], nil);
		STAssertNil([deque lastObject], nil);
		// Test that removal works even with an empty deque
		STAssertNoThrow([deque removeFirstObject], nil);
		STAssertEquals([deque count], expected, nil);
	}
}

- (void) testRemoveLastObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		STAssertEqualObjects([deque lastObject], @"C", nil);
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], @"B", nil);
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], @"A", nil);
		[deque removeLastObject];
		STAssertNil([deque lastObject], nil);
		// Test that removal works even with an empty deque
		STAssertNoThrow([deque removeLastObject], nil);
		STAssertEquals([deque count], (NSUInteger)0, nil);
	}
}

- (void) testReverseObjectEnumerator {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		e = [deque reverseObjectEnumerator];
		STAssertEqualObjects([e nextObject], @"C", nil);
		STAssertEqualObjects([e nextObject], @"B", nil);
		STAssertEqualObjects([e nextObject], @"A", nil);
		STAssertEqualObjects([e nextObject], nil,  nil);
	}
}

@end
