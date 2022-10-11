//
//  CHStackTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHStack.h>
#import <CHDataStructures/CHListStack.h>
#import <CHDataStructures/CHCircularBufferStack.h>

@interface CHStackTest : XCTestCase {
	id<CHStack> stack;
	NSArray *objects, *stackOrder, *stackClasses;
}
@end

@implementation CHStackTest

- (void)setUp {
	stackClasses = @[
		[CHListStack class],
		[CHCircularBufferStack class],
	];
	objects    = @[@"A", @"B", @"C"];
	stackOrder = @[@"C", @"B", @"A"];
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
	for (NSUInteger i = 0; i < 32; i++) {
		[moreObjects addObject:@(i)];
	}
	for (Class aClass in stackClasses) {
		// Test initializing with nil and empty array parameters
		stack = nil;
		XCTAssertThrows([[[aClass alloc] initWithArray:nil] autorelease]);
		XCTAssertEqual([stack count], 0);
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
	for (Class aClass in stackClasses) {
		[emptyStacks addObject:[[aClass alloc] init]];
		[equalStacks addObject:[[aClass alloc] initWithArray:objects]];
		[reversedStacks addObject:[[aClass alloc] initWithArray:reversedObjects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalStacks addObject:[equalStacks objectAtIndex:0]];
	
	id<CHStack> stack1, stack2;
	for (NSUInteger i = 0; i < [stackClasses count]; i++) {
		stack1 = [equalStacks objectAtIndex:i];
		XCTAssertThrowsSpecificNamed([stack1 isEqualToStack:(id)[NSString string]],
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
	for (Class aClass in stackClasses) {
		stack = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([stack pushObject:nil]);
		
		XCTAssertEqual([stack count], 0);
		for (id anObject in objects) {
			[stack pushObject:anObject];
		}
		XCTAssertEqual([stack count], [objects count]);
	}
}

- (void)testTopObjectAndPopObject {
	for (Class aClass in stackClasses) {
		stack = [[[aClass alloc] init] autorelease];
		// Test that the top object starts out as nil
		XCTAssertNil([stack topObject]);
		// Test that the top object is correct as objects are pushed
		for (id anObject in objects) {
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
