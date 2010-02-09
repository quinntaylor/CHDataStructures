/*
 CHDataStructures.framework -- CHStackTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
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
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
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
		stack = [[[aClass alloc] initWithArray:[NSArray array]] autorelease];
		STAssertEquals([stack count], (NSUInteger)0, @"Incorrect count.");
		STAssertNoThrow([stack pushObject:@"A"], @"Should not raise exception");
		STAssertEqualObjects([stack topObject], @"A", @"Wrong first object");

		stack = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([stack count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([stack allObjects], stackOrder,
							 @"Bad ordering on -[%@ initWithArray:]", aClass);

		stack = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		STAssertEquals([stack count], [moreObjects count], @"Incorrect count.");
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
		                            NSException, NSInvalidArgumentException,
		                            @"Should raise NSInvalidArgumentException");
		STAssertFalse([stack1 isEqual:[NSString string]], @"Should not be equal.");
		STAssertTrue([stack1 isEqual:stack1], @"Should be equal to itself.");
		stack2 = [equalStacks objectAtIndex:i+1];
		STAssertTrue([stack1 isEqual:stack2], @"Should be equal.");
		STAssertEquals([stack1 hash], [stack2 hash], @"Hashes should match.");
		stack2 = [emptyStacks objectAtIndex:i];
		STAssertFalse([stack1 isEqual:stack2], @"Should not be equal.");
		stack2 = [reversedStacks objectAtIndex:i];
		STAssertFalse([stack1 isEqual:stack2], @"Should not be equal.");
	}
}

- (void) testPushObject {
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		stack = [[[aClass alloc] init] autorelease];
		STAssertThrows([stack pushObject:nil],
					   @"Should raise nilArgumentException.");
		
		STAssertEquals([stack count], (NSUInteger)0, @"Incorrect count.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[stack pushObject:anObject];
		STAssertEquals([stack count], [objects count], @"Incorrect count.");
	}
}

- (void) testTopObjectAndPopObject {
	NSEnumerator *classes = [stackClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		stack = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[stack pushObject:anObject];
			STAssertEqualObjects([stack topObject], anObject, @"-topObject is wrong.");
		}
		NSUInteger expected = [objects count];
		STAssertEquals([stack count], expected, @"Incorrect count.");
		STAssertEqualObjects([stack topObject], @"C", @"-topObject is wrong.");
		STAssertEquals([stack count], expected, @"Incorrect count.");
		[stack popObject];
		--expected;
		STAssertEquals([stack count], expected, @"Incorrect count.");
		STAssertEqualObjects([stack topObject], @"B", @"-topObject is wrong.");
		STAssertEquals([stack count], expected, @"Incorrect count.");
		[stack popObject];
		--expected;
		STAssertEquals([stack count], expected, @"Incorrect count.");
		STAssertEqualObjects([stack topObject], @"A", @"-topObject is wrong.");
		STAssertEquals([stack count], expected, @"Incorrect count.");
		[stack popObject];
		--expected;
		STAssertEquals([stack count], expected, @"Incorrect count.");
		STAssertNil([stack topObject], @"-topObject should return nil.");
		STAssertEquals([stack count], expected, @"Incorrect count.");
		[stack popObject];
		STAssertEquals([stack count], expected, @"Incorrect count.");
	}
}

@end
