/*
 CHDataStructures.framework -- CHLinkedListTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLinkedList.h"
#import "CHDoublyLinkedList.h"
#import "CHSinglyLinkedList.h"

@interface CHLinkedListTest : SenTestCase {
	id<CHLinkedList> list;
	NSArray* linkedListClasses;
	NSArray* abc;
	NSEnumerator *e;
	id anObject;
}
@end

@implementation CHLinkedListTest

- (void) setUp {
	abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	linkedListClasses = [NSArray arrayWithObjects:
						 [CHDoublyLinkedList class],
						 [CHSinglyLinkedList class],
						 nil];	
}

#pragma mark -

- (void) testNSCoding {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		STAssertEquals([list count], [abc count], nil);
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list];
		list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		STAssertEquals([list count], [abc count], nil);
		STAssertEqualObjects([list allObjects], abc, nil);
	}
}

- (void) testNSCopying {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		id<CHLinkedList> list2 = [[list copyWithZone:nil] autorelease];
		STAssertNotNil(list2, nil);
		STAssertEquals([list2 count], [abc count], nil);
		STAssertEqualObjects([list allObjects], [list2 allObjects], nil);
	}
}

- (void) testNSFastEnumeration {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		NSUInteger number, expected = 1, count = 0;
		for (number = 1; number <= 32; number++)
			[list addObject:[NSNumber numberWithUnsignedInteger:number]];
		for (NSNumber *object in list) {
			STAssertEquals([object unsignedIntegerValue], expected++, nil);
			count++;
		}
		STAssertEquals(count, (NSUInteger)32, nil);
		
		BOOL raisedException = NO;
		@try {
			for (id object in list)
				[list addObject:@"bogus"];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		// Test that a mutation exception was raised
		STAssertTrue(raisedException, nil);
	}
}

#pragma mark -

- (void) testEmptyList {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		STAssertNotNil(list, nil);
		STAssertEquals([list count], (NSUInteger)0, nil);
		STAssertEqualObjects([list firstObject], nil, nil);	
		STAssertEqualObjects([list lastObject], nil, nil);
	}
}

- (void) testInitWithArray {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		STAssertEquals([list count], [abc count], nil);
		STAssertEqualObjects([list allObjects], abc, nil);
	}
}

- (void) testDescription {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		STAssertEqualObjects([list description], [abc description], nil);
	}
}

#pragma mark Insertion and Access

- (void) testPrependObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// Prepending a nil object should raise an exception
		STAssertThrows([list prependObject:nil], nil);
		// Test prepending valid objects
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list prependObject:anObject];
		// Verify first and last object
		STAssertEquals([list count], [abc count], nil);
		STAssertEqualObjects([list firstObject], @"C", nil);
		STAssertEqualObjects([list lastObject],  @"A", nil);
	}
}

- (void) testAddObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// Appending a nil object should raise an exception
		STAssertThrows([list addObject:nil], nil);
		// Test appending valid objects
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		// Verify first and last object
		STAssertEquals([list count], [abc count], nil);
		STAssertEqualObjects([list firstObject], @"A", nil);
		STAssertEqualObjects([list lastObject],  @"C", nil);
	}
}

- (void) testAddObjectsFromArray {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// Passing a nil argument for the array should have no effect
		STAssertNoThrow([list addObjectsFromArray:nil], nil);
		// Test whether items are added to the list properly
		STAssertNoThrow([list addObjectsFromArray:abc], nil);
		STAssertEqualObjects([list allObjects], abc, nil);
	}
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// When the list is empty, calls with any index should raise exception
		STAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:0], nil);
		STAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:1], nil);
		STAssertThrows([list exchangeObjectAtIndex:1 withObjectAtIndex:0], nil);
		// When either index exceeds the bounds, an exception should be raised
		[list addObjectsFromArray:abc];
		STAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:[abc count]], nil);
		STAssertThrows([list exchangeObjectAtIndex:[abc count] withObjectAtIndex:0], nil);
		// Attempting to swap an index with itself should have no effect
		for (NSUInteger i = 0; i < [abc count]; i++) {
			[list exchangeObjectAtIndex:i withObjectAtIndex:i];
			STAssertEqualObjects([list allObjects], abc, nil);
		}
		// Test exchanging objects and verify correctness of swaps
		[list exchangeObjectAtIndex:0 withObjectAtIndex:2];
		STAssertEqualObjects([list firstObject],     @"C", nil);
		STAssertEqualObjects([list lastObject],      @"A", nil);
		[list exchangeObjectAtIndex:0 withObjectAtIndex:1];
		STAssertEqualObjects([list firstObject],     @"B", nil);
		STAssertEqualObjects([list objectAtIndex:1], @"C", nil);
		[list exchangeObjectAtIndex:2 withObjectAtIndex:1];
		STAssertEqualObjects([list objectAtIndex:1], @"A", nil);
		STAssertEqualObjects([list lastObject],      @"C", nil);
	}
}

- (void) testInsertObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// Test inserting using invalid object and invalid indexes
		STAssertThrows([list insertObject:nil  atIndex:0],  nil);
		STAssertThrows([list insertObject:nil  atIndex:-1], nil);
		STAssertThrows([list insertObject:@"A" atIndex:-1], nil);
		STAssertThrows([list insertObject:@"A" atIndex:1],  nil);
		
		[list addObjectsFromArray:abc];
		STAssertEquals([list count], [abc count], nil);
		STAssertThrows([list insertObject:@"A" atIndex:[abc count]+1], nil);
		STAssertNoThrow([list insertObject:@"A" atIndex:[abc count]], nil);
		[list removeLastObject];
		
		// Try inserting in the middle
		[list insertObject:@"D" atIndex:1];
		STAssertEquals([list count], [abc count]+1, nil);
		STAssertEqualObjects([list objectAtIndex:0], @"A", nil);
		STAssertEqualObjects([list objectAtIndex:1], @"D", nil);
		STAssertEqualObjects([list objectAtIndex:2], @"B", nil);
		STAssertEqualObjects([list objectAtIndex:3], @"C", nil);
		// Try inserting at the beginning
		[list insertObject:@"E" atIndex:0];
		STAssertEquals([list count], [abc count]+2, nil);
		STAssertEqualObjects([list objectAtIndex:0], @"E", nil);
		STAssertEqualObjects([list objectAtIndex:1], @"A", nil);
		STAssertEqualObjects([list objectAtIndex:2], @"D", nil);
		STAssertEqualObjects([list objectAtIndex:3], @"B", nil);
		STAssertEqualObjects([list objectAtIndex:4], @"C", nil);
		// Try inserting at the end
		[list insertObject:@"F" atIndex:5];
		STAssertEquals([list count], [abc count]+3, nil);
		STAssertEqualObjects([list objectAtIndex:5], @"F", nil);
	}
}

- (void) testInsertObjectsAtIndexes {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// Test inserting using invalid objects and invalid indexes
		STAssertThrows([list insertObjects:nil
								 atIndexes:nil], nil);
		STAssertThrows([list insertObjects:[NSArray array]
								 atIndexes:nil], nil);
		STAssertThrows([list insertObjects:[NSArray array]
								 atIndexes:[NSIndexSet indexSetWithIndex:0]], nil);
		STAssertThrows([list insertObjects:[NSArray arrayWithObject:[NSNull null]]
								 atIndexes:[NSIndexSet indexSet]], nil);
		// Test inserting beyond the allowed index range
		STAssertThrows([list insertObjects:[NSArray arrayWithObject:[NSNull null]]
								 atIndexes:[NSIndexSet indexSetWithIndex:1]], nil);
		// Test inserting a single object into an empty list
		STAssertNoThrow([list insertObjects:[NSArray arrayWithObject:@"A"]
								  atIndexes:[NSIndexSet indexSetWithIndex:0]], nil);
		STAssertEquals([list count], (NSUInteger)1, nil);
		STAssertEqualObjects([list objectAtIndex:0], @"A", nil);
		// Test inserting multiple objects into an empty list
		[list removeAllObjects];
		NSIndexSet *firstIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [abc count])];
		STAssertNoThrow([list insertObjects:abc
								  atIndexes:firstIndexes], nil);
		STAssertEquals([list count], [abc count], nil);
		// Test inserting objects on both sides of existing objects
		NSMutableArray *objects = [NSMutableArray array];
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		for (NSUInteger i = 0; i <= [abc count]; i++) {
			[objects addObject:[NSNumber numberWithUnsignedInteger:i+1]];
			[indexes addIndex:i*2];
		}
		NSMutableArray *expected = [NSMutableArray arrayWithArray:abc];
		[expected insertObjects:objects atIndexes:indexes];
		[list insertObjects:objects atIndexes:indexes];
		STAssertEquals([list count], [expected count], nil);
		STAssertEqualObjects([list allObjects], expected, nil);
		// Test inserting objects at the front of the list
		[expected insertObjects:abc atIndexes:firstIndexes];
		[list insertObjects:abc atIndexes:firstIndexes];
		STAssertEquals([list count], [expected count], nil);
		STAssertEqualObjects([list allObjects], expected, nil);
	}		
}

// Shortcut macro for determining whether garbage collection is not enabled
#define if_rr if(kCHGarbageCollectionNotEnabled)

- (void) testObjectEnumerator {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		// Enumerator shouldn't retain collection if there are no objects
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
		e = [list objectEnumerator];
		STAssertNotNil(e, nil);
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
		STAssertNil([e nextObject], nil);
		
		// Enumerator should retain collection when it has 1+ objects
		[list addObjectsFromArray:abc];
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
		e = [list objectEnumerator];
		STAssertNotNil(e, nil);
		if_rr STAssertEquals([list retainCount], (NSUInteger)2, nil);
		
		// Enumerator should release collection when all objects are exhausted
		STAssertEqualObjects([e nextObject], @"A", nil);
		STAssertEqualObjects([e nextObject], @"B", nil);
		STAssertEqualObjects([e nextObject], @"C", nil);
		
		if_rr STAssertEquals([list retainCount], (NSUInteger)2, nil);
		STAssertNil([e nextObject], nil);
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
		
		e = [list objectEnumerator];
		if_rr STAssertEquals([list retainCount], (NSUInteger)2, nil);
		NSArray *allObjects = [e allObjects];
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
		STAssertNotNil(allObjects, nil);
		STAssertEqualObjects(allObjects, abc, nil);
		STAssertEqualObjects([allObjects objectAtIndex:0], @"A", nil);
		STAssertEqualObjects([allObjects lastObject],      @"C", nil);
		
		// Enumerator should release collection on -dealloc
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
		e = [list objectEnumerator];
		STAssertNotNil(e, nil);
		if_rr STAssertEquals([list retainCount], (NSUInteger)2, nil);
		// Force deallocation of enumerator by draining autorelease pool
		[pool drain];
		if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);	
		
		// For doubly-linked list, test reverse enumeration order as well
		if (aClass == [CHDoublyLinkedList class]) {
			e = [(CHDoublyLinkedList*)list reverseObjectEnumerator];
			STAssertEqualObjects([e nextObject], @"C", nil);
			STAssertEqualObjects([e nextObject], @"B", nil);
			STAssertEqualObjects([e nextObject], @"A", nil);
			
			if_rr STAssertEquals([list retainCount], (NSUInteger)2, nil);
			STAssertNil([e nextObject], nil);
			if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
			
			e = [(CHDoublyLinkedList*)list reverseObjectEnumerator];
			if_rr STAssertEquals([list retainCount], (NSUInteger)2, nil);
			allObjects = [e allObjects];
			if_rr STAssertEquals([list retainCount], (NSUInteger)1, nil);
			STAssertNotNil(allObjects, nil);
			NSArray *cba = [NSArray arrayWithObjects:@"C",@"B",@"A",nil];
			STAssertEqualObjects(allObjects, cba, nil);
			STAssertEqualObjects([allObjects objectAtIndex:0], @"C", nil);
			STAssertEqualObjects([allObjects lastObject],      @"A", nil);			
		}
		
		// Test for mutation exception in the middle of enumeration
		e = [list objectEnumerator];
		STAssertNoThrow([e nextObject], nil);
		[list addObject:@"bogus"];
		STAssertThrows([e nextObject], nil);
		STAssertThrows([e allObjects], nil);
	}
}

#pragma mark Search

- (void) testContainsObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		NSString *a = [NSString stringWithFormat:@"A"];
		STAssertFalse([list containsObject:@"A"], nil);
		[list addObject:@"A"];
		STAssertTrue([list containsObject:@"A"], nil);
		STAssertTrue([list containsObject:a], nil);
		STAssertFalse([list containsObject:@"bogus"], nil);
	}
}

- (void) testContainsObjectIdenticalTo {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		NSString *a = [NSString stringWithFormat:@"A"];
		STAssertFalse([list containsObjectIdenticalTo:a], nil);
		[list addObject:a];
		STAssertTrue([list containsObjectIdenticalTo:a], nil);
		STAssertFalse([list containsObjectIdenticalTo:@"A"], nil);
	}
}

- (void) testIndexOfObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		STAssertEquals([list indexOfObject:@"A"], (NSUInteger)NSNotFound, nil);
		[list addObjectsFromArray:abc];
		for (NSUInteger i = 0; i < [abc count]; i++) {
			STAssertEquals([list indexOfObject:[abc objectAtIndex:i]], i, nil);
		}
		STAssertEquals([list indexOfObject:@"Z"], (NSUInteger)NSNotFound, nil);
	}
}

- (void) testIndexOfObjectIdenticalTo {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		STAssertEquals([list indexOfObjectIdenticalTo:@"A"], (NSUInteger)NSNotFound, nil);
		[list addObjectsFromArray:abc];
		// Test with the actual string, then a copy made from the string.
		for (NSUInteger i = 0; i < [abc count]; i++) {
			NSString *string = [abc objectAtIndex:i];
			STAssertEquals([list indexOfObjectIdenticalTo:string], (NSUInteger)i, nil);
			string = [NSString stringWithFormat:@"%@", string];
			STAssertEquals([list indexOfObjectIdenticalTo:string], (NSUInteger)NSNotFound, nil);
		}
	}
}

- (void) testIsEqualToLinkedList {
	NSMutableArray *emptyLinkedLists = [NSMutableArray array];
	NSMutableArray *equalLinkedLists = [NSMutableArray array];
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		[emptyLinkedLists addObject:[[aClass alloc] init]];
		[equalLinkedLists addObject:[[aClass alloc] initWithArray:abc]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalLinkedLists addObject:[equalLinkedLists objectAtIndex:0]];
	
	id<CHLinkedList> list1, list2;
	for (NSUInteger i = 0; i < [linkedListClasses count]; i++) {
		list1 = [equalLinkedLists objectAtIndex:i];
		STAssertThrowsSpecificNamed([list1 isEqualToLinkedList:[NSString string]],
		                            NSException, NSInvalidArgumentException, nil);
		STAssertFalse([list1 isEqual:[NSString string]], nil);
		STAssertEqualObjects(list1, list1, nil);
		list2 = [emptyLinkedLists objectAtIndex:i];
		STAssertFalse([list1 isEqual:list2], nil);
		list2 = [equalLinkedLists objectAtIndex:i+1];
		STAssertEqualObjects(list1, list2, nil);
		STAssertEquals([list1 hash], [list2 hash], nil);
	}
}

- (void) testObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertThrows([list objectAtIndex:-1], nil);
		STAssertEqualObjects([list objectAtIndex:0], @"A", nil);
		STAssertEqualObjects([list objectAtIndex:1], @"B", nil);
		STAssertEqualObjects([list objectAtIndex:2], @"C", nil);
		STAssertThrows([list objectAtIndex:3], nil);
	}
}

- (void) testObjectsAtIndexes {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		NSUInteger count = [list count];
		NSRange range;
		for (NSUInteger location = 0; location <= count; location++) {
			range.location = location;
			for (NSUInteger length = 0; length <= count - location + 1; length++) {
				range.length = length;
				NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
				if (location + length > count) {
					STAssertThrows([list objectsAtIndexes:indexes], nil);
				} else {
					STAssertEqualObjects([list objectsAtIndexes:indexes],
										 [abc objectsAtIndexes:indexes], nil);
				}
			}
		}
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		[indexes addIndex:0];
		[indexes addIndex:2];
		STAssertEqualObjects([list objectsAtIndexes:indexes],
							 [abc objectsAtIndexes:indexes], nil);
		STAssertThrows([list objectsAtIndexes:nil], nil);
	}
}

#pragma mark Removal

- (void) testRemoveAllObjects {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertEquals([list count], [abc count], nil);
		[list removeAllObjects];
		STAssertEquals([list count], (NSUInteger)0, nil);
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		
		STAssertNoThrow([list removeFirstObject], nil);
		[list addObjectsFromArray:abc];
		
		STAssertNoThrow([list removeFirstObject], nil);
		STAssertEquals([list count], (NSUInteger)2, nil);
		STAssertEqualObjects([list firstObject], @"B", nil);
		STAssertEqualObjects([list lastObject],  @"C", nil);
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)1, nil);
		STAssertEqualObjects([list firstObject], @"C", nil);
		STAssertEqualObjects([list lastObject],  @"C", nil);
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)0, nil);
		STAssertNil([list firstObject], nil);
		STAssertNil([list lastObject],  nil);
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
	}
}

- (void) testRemoveLastObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		
		[list removeLastObject]; // Should have no effect
		[list addObjectsFromArray:abc];
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)2, nil);
		STAssertEqualObjects([list firstObject], @"A", nil);
		STAssertEqualObjects([list lastObject],  @"B", nil);
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)1, nil);
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)0, nil);
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
	}
}

- (void) testRemoveObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		[list removeObject:@"bogus"]; // Should have no effect
		STAssertNoThrow([list removeObject:nil], nil);
		
		[list addObjectsFromArray:abc];
		STAssertNoThrow([list removeObject:nil], nil);
		
		[list removeObject:@"B"];
		STAssertEquals([list count], (NSUInteger)2, nil);
		STAssertEqualObjects([list firstObject], @"A", nil);
		STAssertEqualObjects([list lastObject],  @"C", nil);
		
		[list removeObject:@"A"];
		STAssertEquals([list count], (NSUInteger)1, nil);
		STAssertEqualObjects([list firstObject], @"C", nil);
		STAssertEqualObjects([list lastObject],  @"C", nil);
		
		[list removeObject:@"C"];
		STAssertEquals([list count], (NSUInteger)0, nil);
		STAssertNil([list firstObject], nil);
		STAssertNil([list lastObject], nil);
		
		// Test removing all instances of an object	
		[list addObject:@"A"];
		[list addObject:@"Z"];
		[list addObject:@"B"];
		[list addObject:@"Z"];
		[list addObject:@"Z"];
		[list addObject:@"C"];
		
		STAssertEquals([list count], (NSUInteger)6, nil);
		[list removeObject:@"Z"];
		STAssertEquals([list count], (NSUInteger)3, nil);
		STAssertEqualObjects([list objectAtIndex:0], @"A", nil);
		STAssertEqualObjects([list objectAtIndex:1], @"B", nil);
		STAssertEqualObjects([list objectAtIndex:2], @"C", nil);	
	}
}

- (void) testRemoveObjectIdenticalTo {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] init] autorelease];
		STAssertNoThrow([list removeObjectIdenticalTo:nil], nil);
		
		NSString *a = [NSString stringWithFormat:@"A"];
		[list addObject:a];
		STAssertEquals([list count], (NSUInteger)1, nil);
		[list removeObjectIdenticalTo:@"A"];
		STAssertEquals([list count], (NSUInteger)1, nil);
		[list removeObjectIdenticalTo:a];
		STAssertEquals([list count], (NSUInteger)0, nil);
		
		// Test removing all instances of an object
		[list addObject:@"A"];
		[list addObject:@"Z"];
		[list addObject:@"B"];
		[list addObject:@"Z"];
		[list addObject:@"C"];
		[list addObject:[NSString stringWithFormat:@"Z"]];

		STAssertNoThrow([list removeObjectIdenticalTo:nil], nil);

		STAssertEquals([list count], (NSUInteger)6, nil);
		[list removeObjectIdenticalTo:@"Z"];
		STAssertEquals([list count], (NSUInteger)4, nil);
		STAssertEqualObjects([list objectAtIndex:0], @"A", nil);
		STAssertEqualObjects([list objectAtIndex:1], @"B", nil);
		STAssertEqualObjects([list objectAtIndex:2], @"C", nil);	
		STAssertEqualObjects([list objectAtIndex:3], @"Z", nil);
	}
}

- (void) testRemoveObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		
		STAssertThrows([list removeObjectAtIndex:3], nil);
		STAssertThrows([list removeObjectAtIndex:-1], nil);
		
		[list removeObjectAtIndex:2];
		STAssertEquals([list count], (NSUInteger)2, nil);
		STAssertEqualObjects([list firstObject], @"A", nil);
		STAssertEqualObjects([list lastObject],  @"B", nil);
		
		[list removeObjectAtIndex:0];
		STAssertEquals([list count], (NSUInteger)1, nil);
		STAssertEqualObjects([list firstObject], @"B", nil);
		STAssertEqualObjects([list lastObject],  @"B", nil);
		
		[list removeObjectAtIndex:0];
		STAssertEquals([list count], (NSUInteger)0, nil);
		
		[list addObjectsFromArray:abc];
		// Test removing from an index in the middle
		[list removeObjectAtIndex:1];
		STAssertEquals([list count], (NSUInteger)2, nil);
		STAssertEqualObjects([list firstObject], @"A", nil);
		STAssertEqualObjects([list lastObject],  @"C", nil);
	}
}

- (void) testRemoveObjectsAtIndexes {
	NSMutableArray* expected = [NSMutableArray array];
	NSIndexSet* indexes;
	
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		// Test removing with invalid indexes
		STAssertThrows([list removeObjectsAtIndexes:nil], nil);
		indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
		STAssertThrows([list removeObjectsAtIndexes:indexes], nil);
		
		[list addObjectsFromArray:abc];
		for (NSUInteger location = 0; location < [abc count]; location++) {
			for (NSUInteger length = 0; length <= [abc count] - location; length++) {
				indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
				// Repopulate list and expected
				[expected removeAllObjects];
				[expected addObjectsFromArray:abc];
				[list removeAllObjects];
				[list addObjectsFromArray:abc];
				STAssertNoThrow([list removeObjectsAtIndexes:indexes], nil);
				[expected removeObjectsAtIndexes:indexes];
				STAssertEquals([list count], [expected count], nil);
				STAssertEqualObjects([list allObjects], expected, nil);
			}
		}	
		STAssertThrows([list removeObjectsAtIndexes:nil], nil);
	}
}

- (void) testReplaceObjectAtIndexWithObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		for (NSUInteger i = 0; i < [abc count]; i++) {
			STAssertEqualObjects([list objectAtIndex:i], [abc objectAtIndex:i], nil);
			[list replaceObjectAtIndex:i withObject:@"Z"];
			STAssertEqualObjects([list objectAtIndex:i], @"Z", nil);
		}
		[list removeAllObjects];
		STAssertThrows([list replaceObjectAtIndex:0 withObject:nil], nil);
		STAssertThrows([list replaceObjectAtIndex:1 withObject:nil], nil);
	}
}

@end
