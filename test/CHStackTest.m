/*
 CHDataStructures.framework -- CHStackTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHStack.h"
#import "CHListStack.h"
#import "CHCircularBufferStack.h"

@interface CHStackTest : SenTestCase {
	id<CHStack> stack;
	NSArray *objects, *stackOrder, *stackClasses;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHStackTest

- (void) setUp {
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

- (void) testInitWithArray {
	NSMutableArray *moreObjects = [NSMutableArray array];
	for (NSUInteger i = 0; i < 32; i++)
		[moreObjects addObject:[NSNumber numberWithUnsignedInteger:i]];
	
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test initializing with nil and empty array parameters
		stack = [[[aClass alloc] initWithArray:nil] autorelease];
		STAssertEquals([stack count], (NSUInteger)0, nil);
		stack = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		STAssertEquals([stack count], (NSUInteger)0, nil);
		// Test initializing with a valid, non-empty array
		stack = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([stack count], [objects count], nil);
		STAssertEqualObjects([stack allObjects], stackOrder, nil);
		// Test initializing with an array larger than the default capacity
		stack = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		STAssertEquals([stack count], [moreObjects count], nil);
	}
}

- (void) testIsEqualToStack {
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
		STAssertThrowsSpecificNamed([stack1 isEqualToStack:[NSString string]],
		                            NSException, NSInvalidArgumentException, nil);
		STAssertFalse([stack1 isEqual:[NSString string]], nil);
		STAssertEqualObjects(stack1, stack1, nil);
		stack2 = [equalStacks objectAtIndex:i+1];
		STAssertEqualObjects(stack1, stack2, nil);
		STAssertEquals([stack1 hash], [stack2 hash], nil);
		stack2 = [emptyStacks objectAtIndex:i];
		STAssertFalse([stack1 isEqual:stack2], nil);
		stack2 = [reversedStacks objectAtIndex:i];
		STAssertFalse([stack1 isEqual:stack2], nil);
	}
}

- (void) testPushObject {
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		stack = [[[aClass alloc] init] autorelease];
		STAssertThrows([stack pushObject:nil], nil);
		
		STAssertEquals([stack count], (NSUInteger)0, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[stack pushObject:anObject];
		STAssertEquals([stack count], [objects count], nil);
	}
}

- (void) testTopObjectAndPopObject {
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		stack = [[[aClass alloc] init] autorelease];
		// Test that the top object starts out as nil
		STAssertNil([stack topObject], nil);
		// Test that the top object is correct as objects are pushed
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[stack pushObject:anObject];
			STAssertEqualObjects([stack topObject], anObject, nil);
		}
		// Test that objects are popped in the correct order and count is right.
		NSUInteger expected = [objects count];
		STAssertEqualObjects([stack topObject], @"C", nil);
		STAssertEquals([stack count], expected, nil);
		[stack popObject];
		--expected;
		STAssertEqualObjects([stack topObject], @"B", nil);
		STAssertEquals([stack count], expected, nil);
		[stack popObject];
		--expected;
		STAssertEqualObjects([stack topObject], @"A", nil);
		STAssertEquals([stack count], expected, nil);
		[stack popObject];
		--expected;
		STAssertNil([stack topObject], nil);
		STAssertEquals([stack count], expected, nil);
		// Test that popping an empty stack has no effect
		[stack popObject];
		STAssertEquals([stack count], expected, nil);
	}
}

@end
