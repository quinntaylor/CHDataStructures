/*
 CHDataStructures.framework -- CHStackTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <XCTest/XCTest.h>
#import "CHStack.h"
#import "CHListStack.h"
#import "CHCircularBufferStack.h"

@interface CHStackTest : XCTestCase {
	id<CHStack> stack;
	NSArray *objects, *stackOrder, *stackClasses;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHStackTest

- (void)setUp {
	stackClasses = [NSArray arrayWithObjects:
					[CHListStack class],
					[CHCircularBufferStack class],
					nil];
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	stackOrder = [NSArray arrayWithObjects:@"C", @"B", @"A", nil];
}

/*
 NOTE: Several methods in CHStack are tested in the abstract parent classes.
 -init
 -containsObject:
 -containsObjectIdenticalTo:
 -removeObject:
 -removeAllObjects
 -allObjects
 -count
 -objectEnumerator
 */

- (void)testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++)
		[moreObjects addObject:[NSNumber numberWithUnsignedInteger:i]];
	
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test initializing with nil and empty array parameters
		stack = [[[aClass alloc] initWithArray:nil] autorelease];
		XCTAssertEqual([stack count], (NSUInteger)0);
		stack = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		XCTAssertEqual([stack count], (NSUInteger)0);
		// Test initializing with a valid, non-empty array
		stack = [[[aClass alloc] initWithArray:objects] autorelease];
		XCTAssertEqual([stack count], [objects count]);
		XCTAssertEqualObjects([stack allObjects], stackOrder);
		// Test initializing with an array larger than the default capacity
		stack = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		XCTAssertEqual([stack count], [moreObjects count]);
	}
}

- (void)testIsEqualToStack {
	NSMutableArray *emptyStacks = [NSMutableArray array];
	NSMutableArray *equalStacks = [NSMutableArray array];
	NSMutableArray *reversedStacks = [NSMutableArray array];
	NSArray *reversedObjects = [[objects reverseObjectEnumerator] allObjects];
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyStacks addObject:[[aClass alloc] init]];
		[equalStacks addObject:[[aClass alloc] initWithArray:objects]];
		[reversedStacks addObject:[[aClass alloc] initWithArray:reversedObjects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalStacks addObject:[equalStacks objectAtIndex:0]];
	
	id<CHStack> stack1, stack2;
	for (NSUInteger i = 0; i < [stackClasses count]; i++) {
		stack1 = [equalStacks objectAtIndex:i];
		XCTAssertThrowsSpecificNamed([stack1 isEqualToStack:[NSString string]],
		                            NSException, NSInvalidArgumentException);
		XCTAssertFalse([stack1 isEqual:[NSString string]]);
		XCTAssertEqualObjects(stack1, stack1);
		stack2 = [equalStacks objectAtIndex:i+1];
		XCTAssertEqualObjects(stack1, stack2);
		XCTAssertEqual([stack1 hash], [stack2 hash]);
		stack2 = [emptyStacks objectAtIndex:i];
		XCTAssertFalse([stack1 isEqual:stack2]);
		stack2 = [reversedStacks objectAtIndex:i];
		XCTAssertFalse([stack1 isEqual:stack2]);
	}
}

- (void)testPushObject {
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		stack = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([stack pushObject:nil]);
		
		XCTAssertEqual([stack count], (NSUInteger)0);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[stack pushObject:anObject];
		XCTAssertEqual([stack count], [objects count]);
	}
}

- (void)testTopObjectAndPopObject {
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		stack = [[[aClass alloc] init] autorelease];
		// Test that the top object starts out as nil
		XCTAssertNil([stack topObject]);
		// Test that the top object is correct as objects are pushed
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[stack pushObject:anObject];
			XCTAssertEqualObjects([stack topObject], anObject);
		}
		// Test that objects are popped in the correct order and count is right.
		NSUInteger expected = [objects count];
		XCTAssertEqualObjects([stack topObject], @"C");
		XCTAssertEqual([stack count], expected);
		[stack popObject];
		--expected;
		XCTAssertEqualObjects([stack topObject], @"B");
		XCTAssertEqual([stack count], expected);
		[stack popObject];
		--expected;
		XCTAssertEqualObjects([stack topObject], @"A");
		XCTAssertEqual([stack count], expected);
		[stack popObject];
		--expected;
		XCTAssertNil([stack topObject]);
		XCTAssertEqual([stack count], expected);
		// Test that popping an empty stack has no effect
		[stack popObject];
		XCTAssertEqual([stack count], expected);
	}
}

@end
