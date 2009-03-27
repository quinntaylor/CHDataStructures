/*
 CHStackTest.m
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
#import "CHStack.h"
#import "CHListStack.h"
#import "CHMutableArrayStack.h"

@interface CHStackTest : SenTestCase {
	id<CHStack> stack;
	NSArray *objects, *stackOrder, *stackClasses;
}
@end

@implementation CHStackTest

- (void) setUp {
	stackClasses = [NSArray arrayWithObjects:
					[CHListStack class],
					[CHMutableArrayStack class],
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
	for (Class aClass in stackClasses) {
		stack = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([stack count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([stack allObjects], stackOrder,
							 @"Bad ordering on -[%@ initWithArray:]", aClass);
	}
}

- (void) testPushObject {
	for (Class aClass in stackClasses) {
		stack = [[[aClass alloc] init] autorelease];
		STAssertThrows([stack pushObject:nil],
					   @"Should raise nilArgumentException.");
		
		STAssertEquals([stack count], (NSUInteger)0, @"Incorrect count.");
		for (id anObject in objects)
			[stack pushObject:anObject];
		STAssertEquals([stack count], [objects count], @"Incorrect count.");
	}
}

- (void) testTopObjectAndPopObject {
	for (Class aClass in stackClasses) {
		stack = [[[aClass alloc] init] autorelease];
		for (id anObject in objects)
			[stack pushObject:anObject];
		
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

#pragma mark -

@interface CHMutableArrayStackTest : SenTestCase {
	CHMutableArrayStack *stack;
	NSArray *objects, *stackOrder;
}
@end

@implementation CHMutableArrayStackTest

- (void) setUp {
	stack = [[CHMutableArrayStack alloc] init];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
	stackOrder = [NSArray arrayWithObjects:@"C", @"B", @"A", nil];
}

- (void) tearDown {
	[stack release];
}

/*
 NOTE: These methods are tested because they're different only for this subclass
 */

- (void) testAllObjects {
	for (id object in objects)
		[stack pushObject:object];
	
	NSArray *allObjects = [stack allObjects];
	STAssertEquals([allObjects count], [objects count], @"Incorrect count.");
	STAssertEqualObjects(allObjects, stackOrder,
						 @"Bad ordering from -allObjects.");
}

- (void) testObjectEnumerator {
	for (id object in objects)
		[stack pushObject:object];
	
	STAssertEqualObjects([[stack objectEnumerator] allObjects], stackOrder,
						 @"Bad ordering from -objectEnumerator.");
	NSUInteger count = 0;
	NSEnumerator *e = [stack objectEnumerator];
	while ([e nextObject])
		count++;
	STAssertEquals(count, [objects count], @"-objectEnumerator had wrong count.");
}

- (void) testReverseObjectEnumerator {
	for (id object in objects)
		[stack pushObject:object];
	
	STAssertEqualObjects([[stack reverseObjectEnumerator] allObjects], objects,
						 @"Bad ordering from -reverseObjectEnumerator.");
	NSUInteger count = 0;
	NSEnumerator *e = [stack reverseObjectEnumerator];
	while ([e nextObject])
		count++;
	STAssertEquals(count, [objects count], @"-reverseObjectEnumerator had wrong count.");
}

- (void) testDescription {
	for (id object in objects)
		[stack pushObject:object];
	
	STAssertEqualObjects([stack description], [stackOrder description],
						 @"-description uses bad ordering.");
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected = 32, count = 0;
	for (number = 1; number <= expected; number++)
		[stack pushObject:[NSNumber numberWithUnsignedInteger:number]];
	for (NSNumber *object in stack) {
		STAssertEquals([object unsignedIntegerValue], expected--,
		               @"Objects should be enumerated in descending order.");
		++count;
	}
	STAssertEquals(count, (NSUInteger)32, @"Count of enumerated items is incorrect.");
	
	BOOL raisedException = NO;
	@try {
		for (id object in stack)
			[stack pushObject:@"123"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, @"Should raise mutation exception.");	
}

@end

