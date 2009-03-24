/*
 CHDequeTest.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
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

- (void) testPrependObjectsFromArray {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		STAssertNoThrow([deque prependObjectsFromArray:nil],
						@"Should never raise an exception.");
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		[deque prependObjectsFromArray:objects];
		STAssertEquals([deque count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([deque allObjects], objects,
							 @"Bad ordering after -[%@ prependObjectsFromArray:]",
							 aClass);
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

- (void) testAppendObjectsFromArray {
	for (Class aClass in dequeClasses) {
		deque = [[aClass alloc] init];
		STAssertNoThrow([deque appendObjectsFromArray:nil],
						@"Should never raise an exception.");
		STAssertEquals([deque count], (NSUInteger)0, @"Incorrect count.");
		[deque appendObjectsFromArray:objects];
		STAssertEquals([deque count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([deque allObjects], objects,
							 @"Bad ordering after -[%@ appendObjectsFromArray:]",
							 aClass);
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
