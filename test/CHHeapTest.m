/*
 CHDataStructures.framework -- CHMutableArrayHeapTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
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
			heap = [[[aClass alloc] initWithOrdering:sortOrder] autorelease];
			e = [objects objectEnumerator];
			while (anObject = [e nextObject])
				[heap addObject:anObject];
			STAssertEquals([heap count], (NSUInteger)9, nil);
			STAssertTrue([heap isValid], nil);
			
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:heap];
			heap = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			
			STAssertEquals([heap count], (NSUInteger)9, nil);
			STAssertTrue([heap isValid], nil);
		}
	} while (sortOrder != NSOrderedDescending);
}

- (void) testNSCopying {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			[heap addObject:anObject];
		id heap2 = [[heap copy] autorelease];
		STAssertNotNil(heap2, nil);
		STAssertEquals([heap2 count], (NSUInteger)9, nil);
		STAssertEquals([heap hash], [heap2 hash], nil);
		STAssertEqualObjects([heap allObjects], [heap2 allObjects], nil);
	}
}

- (void) testNSFastEnumeration {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	NSUInteger limit = 32;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		for (NSUInteger number = 1; number <= limit; number++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:number]];
		NSUInteger expected = 0, count = 0;
		for (NSNumber *number in heap) {
			STAssertEquals([number unsignedIntegerValue], ++expected, nil);
			count++;
		}
		STAssertEquals(count, limit, nil);
		
		// Check that a mutation exception is raised if the heap is modified
		BOOL raisedException = NO;
		@try {
			for (NSNumber *number in heap)
				[heap addObject:number];
		}
		@catch (NSException * e) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, nil);
	}
}

#pragma mark -

- (void) testInitWithArray {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] initWithArray:objects] autorelease];
		STAssertEquals([heap count], [objects count], nil);
		STAssertEquals([[heap allObjects] count], [objects count], nil);
	}
}

- (void) testInvalidInit {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		// Test for invalid ordering
		STAssertThrows([[aClass alloc] initWithOrdering:0], nil);
	}
}

- (void) testAddObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		STAssertThrows([heap addObject:nil], nil);
		STAssertEquals([heap count], (NSUInteger)0, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			[heap addObject:anObject];
			STAssertTrue([heap isValid], nil);
		}
		STAssertEquals([heap count], [objects count], nil);
	}
}

- (void) testAddObjectsFromArray {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		STAssertNoThrow([heap addObjectsFromArray:nil], nil);
		STAssertEquals([heap count], (NSUInteger)0, nil);
		[heap addObjectsFromArray:objects];
		STAssertTrue([heap isValid], nil);
		STAssertEquals([heap count], [objects count], nil);
	}
}

- (void) testContainsObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			STAssertFalse([heap containsObject:anObject], nil);
		[heap addObjectsFromArray:objects];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject])
			STAssertTrue([heap containsObject:anObject], nil);
		STAssertFalse([heap containsObject:@"bogus"], nil);
	}
}

- (void) testContainsObjectIdenticalTo {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(containsObjectIdenticalTo:)])
			continue;
		heap = [[[aClass alloc] initWithArray:objects] autorelease];
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			NSString *clone = [NSString stringWithFormat:@"%@", anObject];
			STAssertTrue([heap containsObjectIdenticalTo:anObject], nil);
			STAssertFalse([heap containsObjectIdenticalTo:clone], nil);
		}
		STAssertFalse([heap containsObjectIdenticalTo:@"bogus"], nil);
	}
}

- (void) testCount {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		STAssertEquals([heap count], (NSUInteger)0, nil);
		[heap addObject:@"A"];
		STAssertEquals([heap count], (NSUInteger)1, nil);
	}
}

- (void) testDebugDescription {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		STAssertNotNil([heap debugDescription], nil);
		[heap addObject:@"A"];
		STAssertNotNil([heap debugDescription], nil);
	}
}

- (void) testDescription {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		STAssertNotNil([heap description], nil);
		[heap addObject:@"A"];
		STAssertNotNil([heap description], nil);
	}
}

- (void) testFirstObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		STAssertEqualObjects([heap firstObject], @"A", nil);
	}
}

- (void) testInsertObjectAtIndex {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(insertObject:atIndex:)])
			continue;
		heap = [[[aClass alloc] init] autorelease];
		STAssertThrows([heap insertObject:nil atIndex:0], nil);
	}
}

- (void) testIsEqualToHeap {
	NSMutableArray *emptyHeaps = [NSMutableArray array];
	NSMutableArray *equalHeaps = [NSMutableArray array];
	NSMutableArray *reversedHeaps = [NSMutableArray array];
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyHeaps addObject:[[[aClass alloc] init] autorelease]];
		[equalHeaps addObject:[[[aClass alloc] initWithOrdering:-1 array:objects] autorelease]];
		[reversedHeaps addObject:[[[aClass alloc] initWithOrdering:1 array:objects] autorelease]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalHeaps addObject:[equalHeaps objectAtIndex:0]];
	
	id<CHHeap> heap1, heap2;
	for (NSUInteger i = 0; i < [heapClasses count]; i++) {
		heap1 = [equalHeaps objectAtIndex:i];
		STAssertThrowsSpecificNamed([heap1 isEqualToHeap:[NSString string]],
		                            NSException, NSInvalidArgumentException, nil);
		STAssertFalse([heap1 isEqual:[NSString string]], nil);
		STAssertEqualObjects(heap1, heap1, nil);
		heap2 = [emptyHeaps objectAtIndex:i];
		STAssertFalse([heap1 isEqualToHeap:heap2], nil);
		heap2 = [reversedHeaps objectAtIndex:i];
		STAssertFalse([heap1 isEqualToHeap:heap2], nil);
		heap2 = [equalHeaps objectAtIndex:i+1];
		STAssertEqualObjects(heap1, heap2, nil);
		STAssertEquals([heap1 hash], [heap2 hash], nil);
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		
		id lastObject = nil;
		NSUInteger count = [heap count];
		while (anObject = [heap firstObject]) {
			if (lastObject)
				STAssertEquals([lastObject compare:anObject],
							   (NSComparisonResult)NSOrderedAscending, nil);
			lastObject = anObject;
			[heap removeFirstObject];
			STAssertEquals([heap count], --count, nil);	
			STAssertTrue([heap isValid], nil);
		}
		
		STAssertNoThrow([heap removeFirstObject], nil);
	}
}

- (void) testRemoveObject {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(removeObject:)])
			continue;
		heap = [[[aClass alloc] init] autorelease];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			STAssertEquals([heap count], expected, nil);
			[heap removeObject:anObject];
			expected -= 2;
			STAssertEquals([heap count], expected, nil);
			STAssertTrue([heap isValid], nil);
		}
	}
}

- (void) testRemoveObjectAtIndex {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(removeObjectAtIndex:)])
			continue;
		heap = [[[aClass alloc] init] autorelease];
		STAssertThrows([heap removeObjectAtIndex:0], nil);
	}
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		if (![aClass instancesRespondToSelector:@selector(removeObjectIdenticalTo:)])
			continue;
		heap = [[[aClass alloc] init] autorelease];
		// Add objects twice in order
		[heap addObjectsFromArray:objects];
		[heap addObjectsFromArray:objects];
		
		NSUInteger expected = [objects count] * 2;
		STAssertEquals([heap count], expected, nil);
		[heap removeObjectIdenticalTo:a];
		STAssertEquals([heap count], expected, nil);
		e = [objects objectEnumerator];
		while (anObject = [e nextObject]) {
			STAssertEquals([heap count], expected, nil);
			[heap removeObjectIdenticalTo:anObject];
			expected -= 2;
			STAssertEquals([heap count], expected, nil);
			STAssertTrue([heap isValid], nil);
		}
	}
}

- (void) testRemoveAllObjects {
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		[heap addObjectsFromArray:objects];
		STAssertEquals([heap count], (NSUInteger)9, nil);
		[heap removeAllObjects];
		STAssertEquals([heap count], (NSUInteger)0, nil);
	}
}

- (void) testObjectEnumerator {
	NSArray *allObjects;
	
	NSEnumerator *classes = [heapClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		heap = [[[aClass alloc] init] autorelease];
		e = [heap objectEnumerator];
		STAssertNotNil(e, nil);
		STAssertNil([e nextObject], nil);
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, nil);
		STAssertEquals([allObjects count], (NSUInteger)0, nil);
		
		[heap addObjectsFromArray:objects];
		e = [heap objectEnumerator];
		STAssertNotNil(e, nil);
		STAssertNotNil([e nextObject], nil);
		e = [heap objectEnumerator];
		allObjects = [e allObjects];
		STAssertNotNil(allObjects, nil);
		STAssertEquals([allObjects count], [objects count], nil);
	}
}

@end
