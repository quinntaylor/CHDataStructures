/*
 CHMutableArrayDequeTest.m
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
#import "CHMutableArrayDeque.h"

@interface CHMutableArrayDequeTest : SenTestCase {
	CHMutableArrayDeque *deque;
	NSArray *objects;
}
@end


@implementation CHMutableArrayDequeTest

- (void) setUp {
	deque = [[CHMutableArrayDeque alloc] init];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[deque release];
}

- (void) testPrependObject {
	STAssertThrows([deque prependObject:nil], @"Should raise nilArgumentException.");

	STAssertEquals([deque count], 0u, @"-count is incorrect.");
	for (id anObject in objects)
		[deque prependObject:anObject];
	STAssertEquals([deque count], 3u, @"-count is incorrect.");
	NSEnumerator *e = [deque objectEnumerator];
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
}

- (void) testAppendObject {
	STAssertThrows([deque appendObject:nil], @"Should raise nilArgumentException.");

	STAssertEquals([deque count], 0u, @"-count is incorrect.");
	for (id anObject in objects)
		[deque appendObject:anObject];
	STAssertEquals([deque count], 3u, @"-count is incorrect.");
	NSEnumerator *e = [deque objectEnumerator];
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
}

- (void) testFirstObject {
	STAssertEqualObjects([deque firstObject], nil, @"-firstObject is wrong.");
	for (id anObject in objects) {
		[deque prependObject:anObject];
		STAssertEqualObjects([deque firstObject], anObject, @"-firstObject is wrong.");
	}
}

- (void) testLastObject {
	STAssertEqualObjects([deque lastObject], nil, @"-lastObject is wrong.");
	for (id anObject in objects) {
		[deque appendObject:anObject];
		STAssertEqualObjects([deque lastObject], anObject, @"-lastObject is wrong.");
	}	
}

- (void) testRemoveFirstObject {
	for (id anObject in objects)
		[deque appendObject:anObject];
	STAssertEqualObjects([deque firstObject], @"A", @"-firstObject is wrong.");
	[deque removeFirstObject];
	STAssertEqualObjects([deque firstObject], @"B", @"-firstObject is wrong.");
	[deque removeFirstObject];
	STAssertEqualObjects([deque firstObject], @"C", @"-firstObject is wrong.");
	[deque removeFirstObject];
	STAssertEqualObjects([deque firstObject], nil, @"-firstObject is wrong.");
	STAssertNoThrow([deque removeFirstObject],
					@"Should never raise an exception, even when empty.");
	STAssertEquals([deque count], 0u, @"-count is incorrect.");
}

- (void) testRemoveLastObject {
	for (id anObject in objects)
		[deque appendObject:anObject];
	STAssertEqualObjects([deque lastObject], @"C", @"-lastObject is wrong.");
	[deque removeLastObject];
	STAssertEqualObjects([deque lastObject], @"B", @"-lastObject is wrong.");
	[deque removeLastObject];
	STAssertEqualObjects([deque lastObject], @"A", @"-lastObject is wrong.");
	[deque removeLastObject];
	STAssertEqualObjects([deque lastObject], nil, @"-removeLastObject is wrong.");
	STAssertNoThrow([deque removeLastObject],
					@"Should never raise an exception, even when empty.");
	STAssertEquals([deque count], 0u, @"-count is incorrect.");
}

- (void) testReverseObjectEnumerator {
	for (id anObject in objects)
		[deque appendObject:anObject];
	NSEnumerator *e = [deque reverseObjectEnumerator];
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], nil, @"-nextObject is wrong.");
}

@end
