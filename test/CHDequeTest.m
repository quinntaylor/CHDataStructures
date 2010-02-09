/*
 CHDataStructures.framework -- CHDequeTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
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
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
	dequeClasses = [NSArray arrayWithObjects:
					[CHListDeque class],
					[CHCircularBufferDeque class],
					nil];
}

- (void) testPrependObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		STAssertThrows([deque prependObject:nil],
					   @"Should raise nilArgumentException.");
		
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque prependObject:anObject];
		STAssertEquals([deque count], (NSUInteger)3, @"Incorrect count.");
		e = [deque objectEnumerator];
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		[deque release];
	}
}

- (void) testAppendObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		STAssertThrows([deque appendObject:nil],
					   @"Should raise nilArgumentException.");
		
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		STAssertEquals([deque count], (NSUInteger)3, @"Incorrect count.");
		e = [deque objectEnumerator];
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		[deque release];
	}
}

- (void) testFirstObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		STAssertEqualObjects([deque firstObject], nil,
							 @"Wrong -firstObject.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque prependObject:anObject];
			STAssertEqualObjects([deque firstObject], anObject,
								 @"Wrong -firstObject.");
		}
		[deque release];
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
		                            NSException, NSInvalidArgumentException,
		                            @"Should raise NSInvalidArgumentException");
		STAssertFalse([deque1 isEqual:[NSString string]], @"Should not be equal.");
		STAssertEqualObjects(deque1, deque1, @"Should be equal to itself.");
		deque2 = [equalDeques objectAtIndex:i+1];
		STAssertEqualObjects(deque1, deque2, @"Should be equal.");
		STAssertEquals([deque1 hash], [deque2 hash], @"Hashes should match.");
		deque2 = [emptyDeques objectAtIndex:i];
		STAssertFalse([deque1 isEqual:deque2], @"Should not be equal.");
		deque2 = [reversedDeques objectAtIndex:i];
		STAssertFalse([deque1 isEqual:deque2], @"Should not be equal.");
	}
}

- (void) testLastObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		STAssertEqualObjects([deque lastObject], nil,
							 @"-lastObject is wrong.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque appendObject:anObject];
			STAssertEqualObjects([deque lastObject], anObject,
								 @"-lastObject is wrong.");
		}	
		[deque release];
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[deque appendObject:anObject];
			STAssertEqualObjects([deque lastObject], anObject, @"Wrong -lastObject.");
		}
		NSUInteger expected = [objects count];
		STAssertEquals([deque count], expected, @"Incorrect count.");
		STAssertEqualObjects([deque firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([deque lastObject],  @"C", @"Wrong -lastObject.");
		[deque removeFirstObject];
		--expected;
		STAssertEquals([deque count], expected, @"Incorrect count.");
		STAssertEqualObjects([deque firstObject], @"B", @"Wrong -firstObject.");
		STAssertEqualObjects([deque lastObject],  @"C", @"Wrong -lastObject.");
		[deque removeFirstObject];
		--expected;
		STAssertEquals([deque count], expected, @"Incorrect count.");
		STAssertEqualObjects([deque firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([deque lastObject],  @"C", @"Wrong -lastObject.");
		[deque removeFirstObject];
		--expected;
		STAssertEquals([deque count], expected, @"Incorrect count.");
		STAssertNil([deque firstObject], @"-firstObject should return nil.");
		STAssertNil([deque lastObject],  @"-lastObject should return nil.");
		STAssertNoThrow([deque removeFirstObject],
						@"Should never raise an exception, even when empty.");
		STAssertEquals([deque count], expected, @"Incorrect count.");
		[deque release];
	}
}

- (void) testRemoveLastObject {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		STAssertEqualObjects([deque lastObject], @"C", @"Wrong -lastObject.");
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], @"B", @"Wrong -lastObject.");
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], @"A", @"Wrong -lastObject.");
		[deque removeLastObject];
		STAssertNil([deque lastObject], @"-lastObject should return nil.");
		STAssertNoThrow([deque removeLastObject],
						@"Should never raise an exception, even when empty.");
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		[deque release];
	}
}

- (void) testReverseObjectEnumerator {
	NSEnumerator *classes = [dequeClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		deque = [[aClass alloc] init];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[deque appendObject:anObject];
		e = [deque reverseObjectEnumerator];
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], nil,  @"Wrong -nextObject.");
		[deque release];
	}
}

@end
