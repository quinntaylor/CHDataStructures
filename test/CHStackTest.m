/*
 CHDataStructures.framework -- CHStackTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHStack.h"
#import "CHListStack.h"
#import "CHMutableArrayStack.h"
#import "CHCircularBufferStack.h"

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
		[moreObjects addObject:[NSNumber numberWithUnsignedInt:i]];
	
	for (Class aClass in stackClasses) {
		stack = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([stack count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([stack allObjects], stackOrder,
							 @"Bad ordering on -[%@ initWithArray:]", aClass);

		stack = [[[aClass alloc] initWithArray:moreObjects] autorelease];
		STAssertEquals([stack count], [moreObjects count], @"Incorrect count.");
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
		for (id anObject in objects) {
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
