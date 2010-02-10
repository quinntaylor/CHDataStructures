/*
 CHDataStructures.framework -- CHLinkedListTest.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
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
	abc = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
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
		list = [[aClass alloc] init];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list];
		[list release];
		list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		STAssertEqualObjects([list allObjects], abc,
							 @"Wrong ordering on reconstruction.");
	}
}

- (void) testNSCopying {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		id<CHLinkedList> list2 = [list copyWithZone:nil];
		STAssertNotNil(list2, @"-copy should not return nil for valid list.");
		STAssertEquals([list2 count], [abc count], @"Incorrect count.");
		STAssertEqualObjects([list allObjects], [list2 allObjects], @"Unequal lists.");
		[list2 release];
		[list release];
	}
}

#if OBJC_API_2
- (void) testNSFastEnumeration {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		NSUInteger number, expected = 1, count = 0;
		for (number = 1; number <= 32; number++)
			[list addObject:[NSNumber numberWithUnsignedInteger:number]];
		for (NSNumber *object in list) {
			STAssertEquals([object unsignedIntegerValue], expected++,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, (NSUInteger)32, @"Count of enumerated items is incorrect.");
		
		BOOL raisedException = NO;
		@try {
			for (id object in list)
				[list addObject:@"123"];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise mutation exception.");
		[list release];
	}
}
#endif

#pragma mark -

- (void) testEmptyList {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertNotNil(list, @"list should not be nil");
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], nil, @"-firstObject should be nil.");	
		STAssertEqualObjects([list lastObject], nil, @"-lastObject should be nil.");
		[list release];
	}
}

- (void) testInitWithArray {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] initWithArray:abc];
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		STAssertEqualObjects([list allObjects], abc,
							 @"Bad array ordering on -initWithArray:");
		[list release];
	}
}

- (void) testDescription {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertEqualObjects([list description], [abc description],
							 @"-description uses bad ordering.");
		[list release];
	}
}

#pragma mark Insertion and Access

- (void) testPrependObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertThrows([list prependObject:nil], @"Should raise an exception on nil.");
		
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list prependObject:anObject];
		
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
		[list release];
	}
}

- (void) testAddObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertThrows([list addObject:nil], @"Should raise an exception on nil.");
		
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject], @"C", @"-lastObject is wrong.");
		[list release];
	}
}

- (void) testAddObjectsFromArray {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertNoThrow([list addObjectsFromArray:nil], @"Should not raise exception");
		[list addObjectsFromArray:abc];
		STAssertEqualObjects([list allObjects], abc, @"Unequal contents");
		[list release];
	}
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:1],
		               @"Should raise exception, list is empty.");
		STAssertThrows([list exchangeObjectAtIndex:1 withObjectAtIndex:0],
		               @"Should raise exception, list is empty.");
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		
		[list exchangeObjectAtIndex:1 withObjectAtIndex:1];
		STAssertEqualObjects([list allObjects], abc,
							 @"Should have no effect.");
		[list exchangeObjectAtIndex:0 withObjectAtIndex:2];
		STAssertEqualObjects([list firstObject],     @"C", @"Bad order after swap.");
		STAssertEqualObjects([list lastObject],      @"A", @"Bad order after swap.");
		[list exchangeObjectAtIndex:0 withObjectAtIndex:1];
		STAssertEqualObjects([list firstObject],     @"B", @"Bad order after swap.");
		STAssertEqualObjects([list objectAtIndex:1], @"C", @"Bad order after swap.");
		[list exchangeObjectAtIndex:2 withObjectAtIndex:1];
		STAssertEqualObjects([list objectAtIndex:1], @"A", @"Bad order after swap.");
		STAssertEqualObjects([list lastObject],      @"C", @"Bad order after swap.");
		[list release];
	}
	
}

- (void) testInsertObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertThrows([list insertObject:nil atIndex:-1],
					   @"Should raise an exception on nil.");
		
		STAssertThrows([list insertObject:@"Z" atIndex:-1], @"Should raise NSRangeException.");
		STAssertThrows([list insertObject:@"Z" atIndex:1], @"Should raise NSRangeException.");
		STAssertNoThrow([list insertObject:@"Z" atIndex:0], @"Should not raise exception.");
		[list removeLastObject];
		
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		STAssertThrows([list insertObject:@"Z" atIndex:[abc count]+1], @"Should raise NSRangeException.");
		STAssertNoThrow([list insertObject:@"Z" atIndex:[abc count]], @"Should not raise exception.");
		[list removeLastObject];
		
		// Try inserting in the middle
		[list insertObject:@"D" atIndex:1];
		STAssertEquals([list count], [abc count]+1, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:1], @"D", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:2], @"B", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:3], @"C", @"-objectAtIndex: is wrong.");
		// Try inserting at the beginning
		[list insertObject:@"E" atIndex:0];
		STAssertEquals([list count], [abc count]+2, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"E", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:1], @"A", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:2], @"D", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:3], @"B", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:4], @"C", @"-objectAtIndex: is wrong.");
		// Try inserting at the end
		[list insertObject:@"F" atIndex:5];
		STAssertEquals([list count], [abc count]+3, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:5], @"F", @"-objectAtIndex: is wrong.");
		[list release];
	}
}

- (void) testObjectEnumerator {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		// Enumerator shouldn't retain collection if there are no objects
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [list objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Should not retain collection");
		STAssertNil([e nextObject], @"-nextObject should return nil.");
		
		// Enumerator should retain collection when it has 1+ objects, release when 0
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [list objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Collection should still be retained");
		STAssertNil([e nextObject], @"-nextObject should return nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Enumerator should release collection");
		
		e = [list objectEnumerator];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		NSArray *array = [e allObjects];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Enumerator should release collection");
		STAssertNotNil(array, @"Array should not be nil");
		STAssertEquals([array count], [abc count], @"Incorrect count.");
		STAssertEqualObjects([array objectAtIndex:0], @"A", @"Object order is wrong.");
		STAssertEqualObjects([array lastObject],      @"C", @"Object order is wrong.");
		
		// Test that enumerator releases on -dealloc
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [list objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		[pool drain]; // Force deallocation of enumerator
		if (kCHGarbageCollectionNotEnabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Enumerator should release collection");	
		
		// Test mutation in the middle of enumeration
		e = [list objectEnumerator];
		[list addObject:@"Z"];
		STAssertThrows([e nextObject], @"Should raise mutation exception.");
		STAssertThrows([e allObjects], @"Should raise mutation exception.");

		// Test deallocation in the middle of enumeration
		pool = [[NSAutoreleasePool alloc] init];
		e = [list objectEnumerator];
		[e nextObject];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		
		pool = [[NSAutoreleasePool alloc] init];
		e = [list objectEnumerator];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		[list release];
	}
}

#pragma mark Search

- (void) testContainsObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertFalse([list containsObject:@"A"], @"Should return YES.");
		[list addObject:@"A"];
		STAssertTrue([list containsObject:@"A"], @"Should return YES.");
		STAssertFalse([list containsObject:@"Z"], @"Should return NO.");
		[list release];
	}
}

- (void) testContainsObjectIdenticalTo {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		NSString *a = [NSString stringWithFormat:@"A"];
		STAssertFalse([list containsObjectIdenticalTo:a], @"Should return NO.");
		[list addObject:a];
		STAssertTrue([list containsObjectIdenticalTo:a], @"Should return YES.");
		STAssertFalse([list containsObjectIdenticalTo:@"A"], @"Should return NO.");
		[list release];
	}
}

- (void) testIndexOfObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		[list addObject:@"A"];
		STAssertEquals([list indexOfObject:@"A"], (NSUInteger)0,
					   @"Wrong index for object.");
		STAssertEquals([list indexOfObject:@"Z"], (NSUInteger)NSNotFound,
					   @"Wrong index for object.");
		[list release];
	}
}

- (void) testIndexOfObjectIdenticalTo {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		NSString *a = [NSString stringWithFormat:@"A"];
		[list addObject:a];
		STAssertEquals([list indexOfObjectIdenticalTo:a], (NSUInteger)0,
					   @"Wrong index for object.");
		STAssertEquals([list indexOfObjectIdenticalTo:@"A"], (NSUInteger)NSNotFound,
					   @"Wrong index for object.");
		[list release];
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
		                            NSException, NSInvalidArgumentException,
		                            @"Should raise NSInvalidArgumentException");
		STAssertFalse([list1 isEqual:[NSString string]], @"Should not be equal.");
		STAssertEqualObjects(list1, list1, @"Should be equal to itself.");
		list2 = [emptyLinkedLists objectAtIndex:i];
		STAssertFalse([list1 isEqual:list2], @"Should not be equal.");
		list2 = [equalLinkedLists objectAtIndex:i+1];
		STAssertEqualObjects(list1, list2, @"Should be equal.");
		STAssertEquals([list1 hash], [list2 hash], @"Hashes should match.");
	}
}

- (void) testObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertThrows([list objectAtIndex:-1], @"Should raise NSRangeException.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:1], @"B", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:2], @"C", @"-objectAtIndex: is wrong.");
		STAssertThrows([list objectAtIndex:3], @"Should raise NSRangeException.");
		[list release];
	}
}

- (void) testObjectsAtIndexes {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] initWithArray:abc];
		NSUInteger count = [list count];
		NSRange range;
		for (NSUInteger location = 0; location <= count; location++) {
			range.location = location;
			for (NSUInteger length = 0; length <= count - location + 1; length++) {
				range.length = length;
				NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
				if (location + length > count) {
					STAssertThrows([list objectsAtIndexes:indexes], @"Range exception");
				} else {
					STAssertEqualObjects([list objectsAtIndexes:indexes],
										 [abc objectsAtIndexes:indexes],
										 @"Range selections should be equal.");
				}
			}
		}
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		[indexes addIndex:0];
		[indexes addIndex:2];
		STAssertEqualObjects([list objectsAtIndexes:indexes],
							 [abc objectsAtIndexes:indexes],
							 @"Range selections should be equal.");
		STAssertThrows([list objectsAtIndexes:nil], @"Nil argument.");
		[list release];
	}
}

#pragma mark Removal

- (void) testRemoveAllObjects {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertEquals([list count], [abc count], @"Incorrect count.");
		[list removeAllObjects];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		[list release];
	}
}

- (void) testRemoveFirstObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		
		[list removeFirstObject]; // Should have no effect
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"B", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"Wrong -lastObject.");
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"Wrong -lastObject.");
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		STAssertNil([list firstObject], @"Wrong -firstObject.");
		STAssertNil([list lastObject],  @"Wrong -lastObject.");
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
		[list release];
	}
}

- (void) testRemoveLastObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		
		[list removeLastObject]; // Should have no effect
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"B", @"Wrong -lastObject.");
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
		[list release];
	}
}

- (void) testRemoveObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		[list removeObject:@"Z"]; // Should have no effect
		STAssertNoThrow([list removeObject:nil], @"Should not raise an exception.");
		
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		STAssertNoThrow([list removeObject:nil], @"Should not raise an exception.");
		
		[list removeObject:@"B"];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
		
		[list removeObject:@"A"];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
		
		[list removeObject:@"C"];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		STAssertNil([list firstObject], @"-firstObject should return nil.");
		STAssertNil([list lastObject], @"-lastObject should return nil.");
		
		// Test removing all instances of an object	
		[list addObject:@"A"];
		[list addObject:@"Z"];
		[list addObject:@"B"];
		[list addObject:@"Z"];
		[list addObject:@"Z"];
		[list addObject:@"C"];
		
		STAssertEquals([list count], (NSUInteger)6, @"Incorrect count.");
		[list removeObject:@"Z"];
		STAssertEquals([list count], (NSUInteger)3, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
		[list release];
	}
}

- (void) testRemoveObjectIdenticalTo {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertNoThrow([list removeObjectIdenticalTo:nil], @"Should not raise an exception.");
		
		NSString *a = [NSString stringWithFormat:@"A"];
		[list addObject:a];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		[list removeObjectIdenticalTo:@"A"];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		[list removeObjectIdenticalTo:a];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		
		// Test removing all instances of an object
		[list addObject:@"A"];
		[list addObject:@"Z"];
		[list addObject:@"B"];
		[list addObject:@"Z"];
		[list addObject:@"C"];
		[list addObject:[NSString stringWithFormat:@"Z"]];

		STAssertNoThrow([list removeObjectIdenticalTo:nil], @"Should not raise an exception.");

		STAssertEquals([list count], (NSUInteger)6, @"Incorrect count.");
		[list removeObjectIdenticalTo:@"Z"];
		STAssertEquals([list count], (NSUInteger)4, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
		STAssertEqualObjects([list objectAtIndex:3], @"Z", @"Wrong object at index.");
		[list release];
	}
}

- (void) testRemoveObjectAtIndex {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		
		STAssertThrows([list removeObjectAtIndex:3], @"Should raise NSRangeException.");
		STAssertThrows([list removeObjectAtIndex:-1], @"Should raise NSRangeException.");
		
		[list removeObjectAtIndex:2];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
		
		[list removeObjectAtIndex:0];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"B", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
		
		[list removeObjectAtIndex:0];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		
		// Test removing from an index in the middle
		e = [abc objectEnumerator];
		while (anObject = [e nextObject])
			[list addObject:anObject];
		
		[list removeObjectAtIndex:1];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
		[list release];
	}
}

- (void) testRemoveObjectsAtIndexes {
	NSMutableArray* expected = [NSMutableArray array];
	NSIndexSet* indexes;
	
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] init];
		STAssertThrows([list removeObjectsAtIndexes:nil], @"Index set cannot be nil.");
		indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
		STAssertThrows([list removeObjectsAtIndexes:indexes], @"Nonexistent index.");
		
		[list addObjectsFromArray:abc];
		for (NSUInteger location = 0; location < [abc count]; location++) {
			for (NSUInteger length = 0; length <= [abc count] - location; length++) {
				indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
				// Repopulate list and expected
				[expected removeAllObjects];
				[expected addObjectsFromArray:abc];
				[list removeAllObjects];
				[list addObjectsFromArray:abc];
				STAssertNoThrow([list removeObjectsAtIndexes:indexes],
								@"Should not raise exception, valid index range.");
				[expected removeObjectsAtIndexes:indexes];
				STAssertEquals([list count], [expected count], @"Wrong count");
				STAssertEqualObjects([list allObjects], expected, @"Array content mismatch.");
			}
		}	
		STAssertThrows([list removeObjectsAtIndexes:nil], @"Nil argument.");
	}
}

- (void) testReplaceObjectAtIndexWithObject {
	NSEnumerator *classes = [linkedListClasses objectEnumerator];
	Class aClass;
	while (aClass = [classes nextObject]) {
		list = [[aClass alloc] initWithArray:abc];
		for (NSUInteger i = 0; i < [abc count]; i++) {
			STAssertEqualObjects([list objectAtIndex:i], [abc objectAtIndex:i],
								 @"Incorrect object.");
			[list replaceObjectAtIndex:i withObject:@"Z"];
			STAssertEqualObjects([list objectAtIndex:i], @"Z",
								 @"Incorrect object.");
		}
		[list removeAllObjects];
		STAssertThrows([list replaceObjectAtIndex:0 withObject:nil],
					   @"Should raise index exception.");
		STAssertThrows([list replaceObjectAtIndex:1 withObject:nil],
					   @"Should raise index exception.");
		[list release];
	}
}

@end
