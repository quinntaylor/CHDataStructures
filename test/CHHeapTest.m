/*
 CHDataStructures.framework -- CHMutableArrayHeapTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHBinaryHeap.h"
#import "CHMutableArrayHeap.h"

@interface CHMutableArrayHeap (Test)

- (BOOL) isValid;

@end

@implementation CHMutableArrayHeap (Test)

- (BOOL) isValid {
	id parent, leftChild, rightChild;
	NSUInteger parentIndex = 0, leftIndex, rightIndex;
	NSUInteger arraySize = [array count];
	// Iterate from 0 to n/2-1 and check that children hold heap's sort order
	while (parentIndex < arraySize / 2) {
		leftIndex = parentIndex * 2 + 1;
		rightIndex = parentIndex * 2 + 2;
		parent = [array objectAtIndex:parentIndex];
		leftChild = (leftIndex < arraySize) ? [array objectAtIndex:leftIndex] : nil;
		rightChild = (rightIndex < arraySize) ? [array objectAtIndex:rightIndex] : nil;
		if (leftChild && [parent compare:leftChild] == -sortOrder) {
			return NO;
		}
		if (rightChild && [parent compare:rightChild] == -sortOrder) {
			return NO;
		}
		++parentIndex;
	}
	return YES;
}

@end

#pragma mark -

@interface CHBinaryHeap (Debug)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end

@interface CHBinaryHeap (Test)

- (BOOL) isValid;

@end

@implementation CHBinaryHeap (Test)

- (BOOL) isValid {
	return YES; // We assume that CFBinaryHeap is correct... ;-)
}
@end

#pragma mark -

@interface CHHeapTest : SenTestCase {
	id heap; // Removed protocol type <CHHeap> to prevent warnings for -isValid.
	NSArray *objects, *heapClasses;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHHeapTest

- (void) setUp {
	heapClasses = [NSArray arrayWithObjects:[CHMutableArrayHeap class],
	                                        [CHBinaryHeap class],
	                                        nil];
	objects = [NSArray arrayWithObjects:
			   @"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
}


#pragma mark -

- (void) testNSCoding {
	NSInteger sortOrder = NSOrderedDescending; // Switches to ascending first.
	do {
		sortOrder *= -1;
		NSEnumerator *classes = [heapClasses objectEnumerator];
		Class aClass;
		while (aClass = [classes nextObject]) {
			heap = [[aClass alloc] initWithOrdering:sortOrder];
			e = [objects objectEnumerator];
			while (anObject = [e nextObject])
				[heap addObject:anObject];
			STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
			STAssertTrue([heap isValid], @"Invalid ordering before archiving.");
			
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:heap];
			[heap release];
			heap = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			
			STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
			STAssertTrue([heap isValid], @"Invalid ordering on reconstruction.");
		}
	} while (sortOrder != NSOrderedDescending);
}

- (void) testNSCopying {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[heap addObject:anObject];
		id heap2 = [heap copy];
		STAssertNotNil(heap2, @"-copy should not return nil for valid heap.");
		STAssertEquals([heap2 count], (NSUInteger)9, @"Incorrect count.");
		STAssertEquals([heap hash], [heap2 hash], @"Hashes should match.");
		STAssertEqualObjects([heap allObjects], [heap2 allObjects], @"Unequal heaps.");
		[heap release];
		[heap2 release];
	}
}

#if OBJC_API_2
- (void) testNSFastEnumeration {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	NSUInteger limit = 32;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		for (NSUInteger number = 1; number <= limit; number++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:number]];
		NSUInteger expected = 0, count = 0;
		for (NSNumber *number in heap) {
			STAssertEquals([number unsignedIntegerValue], ++expected,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, limit, @"Count of enumerated items is incorrect.");
		
		// Check that a mutation exception is raised if the heap is modified
		BOOL raisedException = NO;
		@try {
			for (NSNumber *number in heap)
				[heap addObject:number];
		}
		@catch (NSException * e) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise a mutation exception.");
		[heap release];
	}
}
#endif

#pragma mark -

- (void) testInitWithArray {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] initWithArray:objects];
		STAssertEquals([heap count], [objects count], @"Wrong count");
		STAssertEquals([[heap allObjects] count], [objects count], @"Wrong count");
		[heap release];
	}
}

- (void) testInvalidInit {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject])
		STAssertThrows([[[aClass alloc] autorelease] initWithOrdering:0],
					   @"Invalid ordering not correctly detected.");
}

- (void) testAddObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		STAssertThrows([heap addObject:nil], @"Should raise nilArgumentException.");
		
		STAssertEquals([heap count], (NSUInteger)0, @"Incorrect count.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[heap addObject:anObject];
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
		[heap release];
	}
}

- (void) testAddObjectsFromArray {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertTrue([heap isValid], @"Violation of heap property.");
		[heap release];
	}
}

- (void) testContainsObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] initWithArray:objects];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			STAssertTrue([heap containsObject:anObject], @"Should contain object");
		STAssertFalse([heap containsObject:@"Z"], @"Should NOT contain object");
		[heap release];
	}
}

- (void) testContainsObjectIdenticalTo {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(containsObjectIdenticalTo:)])
			continue;
		heap = [[aClass alloc] initWithArray:objects];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			NSString *copy = [NSString stringWithFormat:@"%@", anObject];
			STAssertTrue([heap containsObjectIdenticalTo:anObject], @"Should contain object");
			STAssertFalse([heap containsObjectIdenticalTo:copy], @"Should NOT contain object");
		}
		STAssertFalse([heap containsObjectIdenticalTo:@"Z"], @"Should NOT contain object");
		[heap release];
	}
}

- (void) testCount {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		STAssertEquals([heap count], (NSUInteger)0, @"Incorrect count.");
		[heap addObject:@"Hello, World!"];
		STAssertEquals([heap count], (NSUInteger)1, @"Incorrect count.");
		[heap release];
	}
}

- (void) testDebugDescription {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		STAssertNotNil([heap debugDescription], @"Description was nil.");
		[heap addObject:@"xyz"];
		STAssertNotNil([heap debugDescription], @"Description was nil.");
		[heap release];
	}
}

- (void) testDescription {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		STAssertNotNil([heap description], @"Description was nil");
		[heap addObject:@"xyz"];
		STAssertNotNil([heap description], @"Description was nil");
		[heap release];
	}
}

- (void) testFirstObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertEqualObjects([heap firstObject], @"A", @"-firstObject returned bad value.");
		[heap release];
	}
}

- (void) testInsertObjectAtIndex {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(insertObject:atIndex:)])
			continue;
		heap = [[aClass alloc] init];
		STAssertThrows([heap insertObject:nil atIndex:0], @"Should raise an exception.");
		[heap release];
	}
}

- (void) testIsEqualToHeap {
	NSMutableArray *emptyHeaps = [NSMutableArray array];
	NSMutableArray *equalHeaps = [NSMutableArray array];
	NSMutableArray *reversedHeaps = [NSMutableArray array];
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyHeaps addObject:[[aClass alloc] init]];
		[equalHeaps addObject:[[aClass alloc] initWithOrdering:-1 array:objects]];
		[reversedHeaps addObject:[[aClass alloc] initWithOrdering:1 array:objects]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalHeaps addObject:[equalHeaps objectAtIndex:0]];
	
	id<CHHeap> heap1, heap2;
	for (NSUInteger i = 0; i < [heapClasses count]; i++) {
		heap1 = [equalHeaps objectAtIndex:i];
		STAssertThrowsSpecificNamed([heap1 isEqualToHeap:[NSString string]],
		                            NSException, NSInvalidArgumentException,
		                            @"Should raise NSInvalidArgumentException");
		STAssertFalse([heap1 isEqual:[NSString string]], @"Should not be equal.");
		STAssertEqualObjects(heap1, heap1, @"Should be equal to itself.");
		heap2 = [emptyHeaps objectAtIndex:i];
		STAssertFalse([heap1 isEqualToHeap:heap2], @"Should not be equal.");
		heap2 = [reversedHeaps objectAtIndex:i];
		STAssertFalse([heap1 isEqualToHeap:heap2], @"Should not be equal.");
		heap2 = [equalHeaps objectAtIndex:i+1];
		STAssertEqualObjects(heap1, heap2, @"Should be equal.");
		STAssertEquals([heap1 hash], [heap2 hash], @"Hashes should match.");
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		
		id lastObject = nil;
		NSUInteger count = [heap count];
		while (anObject = [heap firstObject]) {
			if (lastObject)
				STAssertEquals([lastObject compare:anObject],
							   (NSComparisonResult)NSOrderedAscending,
							   @"Wrong ordering.");
			lastObject = anObject;
			[heap removeFirstObject];
			STAssertEquals([heap count], --count, @"Incorrect count.");	
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		
		STAssertNoThrow([heap removeFirstObject],
						@"Should never raise an exception, even when empty.");
		[heap release];
	}
}

- (void) testRemoveObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(removeObject:)])
			continue;
		heap = [[aClass alloc] init];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			STAssertEquals([heap count], expected, @"Incorrect count.");
			[heap removeObject:anObject];
			expected -= 2;
			STAssertEquals([heap count], expected, @"Incorrect count.");
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		[heap release];
	}
}

- (void) testRemoveObjectAtIndex {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(removeObjectAtIndex:)])
			continue;
		heap = [[aClass alloc] init];
		STAssertThrows([heap removeObjectAtIndex:0], @"Should raise an exception.");
		[heap release];
	}
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(removeObjectIdenticalTo:)])
			continue;
		heap = [[aClass alloc] init];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		STAssertEquals([heap count], expected, @"Incorrect count.");
		[heap removeObjectIdenticalTo:a];
		STAssertEquals([heap count], expected, @"Incorrect count.");
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			STAssertEquals([heap count], expected, @"Incorrect count.");
			[heap removeObjectIdenticalTo:anObject];
			expected -= 2;
			STAssertEquals([heap count], expected, @"Incorrect count.");
			STAssertTrue([heap isValid], @"Violation of heap property.");
		}
		[heap release];
	}
}

- (void) testRemoveAllObjects {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		[heap addObjectsFromArray:objects];
		STAssertEquals([heap count], (NSUInteger)9, @"Incorrect count.");
		[heap removeAllObjects];
		STAssertEquals([heap count], (NSUInteger)0, @"Incorrect count.");
		[heap release];
	}
}

- (void) testObjectEnumerator {
	NSArray *allObjects;
	
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[aClass alloc] init];
		e = [heap objectEnumerator];
		STAssertNotNil(e, @"-objectEnumerator should never return nil.");
		STAssertNil([e nextObject], @"-nextObject should return nil.");
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, @"-allObjects should not return nil.");
		STAssertEquals([allObjects count], (NSUInteger)0, @"Incorrect count.");
		
		[heap addObjectsFromArray:objects];
		e = [heap objectEnumerator];
		STAssertNotNil(e, @"-objectEnumerator should never return nil.");
		STAssertNotNil([e nextObject], @"-nextObject should not return nil.");
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, @"-allObjects should not return nil.");
		STAssertEquals([allObjects count], [objects count], @"Incorrect count.");
		[heap release];
	}
}

@end
