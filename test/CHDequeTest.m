/*
 CHDataStructures.framework -- CHDequeTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHCircularBufferDeque.h"
#import "CHListDeque.h"
#import "CHMutableArrayDeque.h"

@interface CHDequeTest : SenTestCase {
	CHListDeque *deque;
	NSArray *objects, *dequeClasses;
}
@end


@implementation CHDequeTest

- (void) setUp {
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
	dequeClasses = [NSArray arrayWithObjects:
					[CHListDeque class],
					[CHMutableArrayDeque class],
					[CHCircularBufferDeque class],
					nil];
}

- (void) testPrependObject {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		STAssertThrows([deque prependObject:nil],
					   @"Should raise nilArgumentException.");
		
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		for (id anObject in objects)
			[deque prependObject:anObject];
		STAssertEquals([deque count], (NSUInteger)3, @"Incorrect count.");
		NSEnumerator *e = [deque objectEnumerator];
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		[deque release];
	}
}

- (void) testAppendObject {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		STAssertThrows([deque appendObject:nil],
					   @"Should raise nilArgumentException.");
		
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		for (id anObject in objects)
			[deque appendObject:anObject];
		STAssertEquals([deque count], (NSUInteger)3, @"Incorrect count.");
		NSEnumerator *e = [deque objectEnumerator];
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		[deque release];
	}
}

- (void) testFirstObject {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		STAssertEqualObjects([deque firstObject], nil,
							 @"Wrong -firstObject.");
		for (id anObject in objects) {
			[deque prependObject:anObject];
			STAssertEqualObjects([deque firstObject], anObject,
								 @"Wrong -firstObject.");
		}
		[deque release];
	}
}

- (void) testLastObject {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		STAssertEqualObjects([deque lastObject], nil,
							 @"-lastObject is wrong.");
		for (id anObject in objects) {
			[deque appendObject:anObject];
			STAssertEqualObjects([deque lastObject], anObject,
								 @"-lastObject is wrong.");
		}	
		[deque release];
	}
}

- (void) testRemoveFirstObject {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		for (id anObject in objects)
			[deque appendObject:anObject];
		STAssertEqualObjects([deque firstObject], @"A", @"Wrong -firstObject.");
		[deque removeFirstObject];
		STAssertEqualObjects([deque firstObject], @"B", @"Wrong -firstObject.");
		[deque removeFirstObject];
		STAssertEqualObjects([deque firstObject], @"C", @"Wrong -firstObject.");
		[deque removeFirstObject];
		STAssertEqualObjects([deque firstObject], nil,  @"Wrong -firstObject.");
		STAssertNoThrow([deque removeFirstObject],
						@"Should never raise an exception, even when empty.");
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		[deque release];
	}
}

- (void) testRemoveLastObject {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		for (id anObject in objects)
			[deque appendObject:anObject];
		STAssertEqualObjects([deque lastObject], @"C", @"Wrong -lastObject.");
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], @"B", @"Wrong -lastObject.");
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], @"A", @"Wrong -lastObject.");
		[deque removeLastObject];
		STAssertEqualObjects([deque lastObject], nil, @"Wrong -lastObject.");
		STAssertNoThrow([deque removeLastObject],
						@"Should never raise an exception, even when empty.");
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		[deque release];
	}
}

- (void) testReverseObjectEnumerator {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		for (id anObject in objects)
			[deque appendObject:anObject];
		NSEnumerator *e = [deque reverseObjectEnumerator];
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], nil,  @"Wrong -nextObject.");
		[deque release];
	}
}

@end
