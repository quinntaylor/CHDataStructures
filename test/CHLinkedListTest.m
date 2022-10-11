//
//  CHLinkedListTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHLinkedList.h>
#import <CHDataStructures/CHDoublyLinkedList.h>
#import <CHDataStructures/CHSinglyLinkedList.h>
#import "NSObject+TestUtilities.h"

@interface CHLinkedListTest : XCTestCase {
	NSObject<CHLinkedList> *list;
	NSArray *linkedListClasses;
	NSArray *abc;
}
@end

@implementation CHLinkedListTest

- (void)setUp {
	abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	linkedListClasses = [NSArray arrayWithObjects:
						 [CHDoublyLinkedList class],
						 [CHSinglyLinkedList class],
						 nil];	
}

#pragma mark -

- (void)testNSCoding {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		XCTAssertEqual([list count], [abc count]);
		
		list = [list copyUsingNSCoding];
		
		XCTAssertEqual([list count], [abc count]);
		XCTAssertEqualObjects([list allObjects], abc);
	}
}

- (void)testNSCopying {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		id<CHLinkedList> list2 = [[list copyWithZone:nil] autorelease];
		XCTAssertNotNil(list2);
		XCTAssertEqual([list2 count], [abc count]);
		XCTAssertEqualObjects([list allObjects], [list2 allObjects]);
	}
}

- (void)testNSFastEnumeration {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		NSUInteger number, expected = 1, count = 0;
		for (number = 1; number <= 32; number++) {
			[list addObject:[NSNumber numberWithUnsignedInteger:number]];
		}
		for (NSNumber *object in list) {
			XCTAssertEqual([object unsignedIntegerValue], expected++);
			count++;
		}
		XCTAssertEqual(count, (NSUInteger)32);
		
		@try {
			for (__unused id object in list) {
				[list addObject:@"bogus"];
			}
			XCTFail(@"Expected an exception for mutating during enumeration.");
		}
		@catch (NSException *exception) {
		}
	}
}

#pragma mark -

- (void)testEmptyList {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		XCTAssertNotNil(list);
		XCTAssertEqual([list count], (NSUInteger)0);
		XCTAssertEqualObjects([list firstObject], nil);	
		XCTAssertEqualObjects([list lastObject], nil);
	}
}

- (void)testInitWithArray {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		XCTAssertEqual([list count], [abc count]);
		XCTAssertEqualObjects([list allObjects], abc);
	}
}

- (void)testDescription {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		XCTAssertEqualObjects([list description], [abc description]);
	}
}

#pragma mark Insertion and Access

- (void)testPrependObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// Prepending a nil object should raise an exception
		XCTAssertThrows([list prependObject:nil]);
		// Test prepending valid objects
		for (id anObject in abc) {
			[list prependObject:anObject];
		}
		// Verify first and last object
		XCTAssertEqual([list count], [abc count]);
		XCTAssertEqualObjects([list firstObject], @"C");
		XCTAssertEqualObjects([list lastObject],  @"A");
	}
}

- (void)testAddObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// Appending a nil object should raise an exception
		XCTAssertThrows([list addObject:nil]);
		// Test appending valid objects
		for (id anObject in abc) {
			[list addObject:anObject];
		}
		// Verify first and last object
		XCTAssertEqual([list count], [abc count]);
		XCTAssertEqualObjects([list firstObject], @"A");
		XCTAssertEqualObjects([list lastObject],  @"C");
	}
}

- (void)testAddObjectsFromArray {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// Passing a nil argument for the array should have no effect
		XCTAssertNoThrow([list addObjectsFromArray:nil]);
		// Test whether items are added to the list properly
		XCTAssertNoThrow([list addObjectsFromArray:abc]);
		XCTAssertEqualObjects([list allObjects], abc);
	}
}

- (void)testExchangeObjectAtIndexWithObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// When the list is empty, calls with any index should raise exception
		XCTAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:0]);
		XCTAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:1]);
		XCTAssertThrows([list exchangeObjectAtIndex:1 withObjectAtIndex:0]);
		// When either index exceeds the bounds, an exception should be raised
		[list addObjectsFromArray:abc];
		XCTAssertThrows([list exchangeObjectAtIndex:0 withObjectAtIndex:[abc count]]);
		XCTAssertThrows([list exchangeObjectAtIndex:[abc count] withObjectAtIndex:0]);
		// Attempting to swap an index with itself should have no effect
		for (NSUInteger i = 0; i < [abc count]; i++) {
			[list exchangeObjectAtIndex:i withObjectAtIndex:i];
			XCTAssertEqualObjects([list allObjects], abc);
		}
		// Test exchanging objects and verify correctness of swaps
		[list exchangeObjectAtIndex:0 withObjectAtIndex:2];
		XCTAssertEqualObjects([list firstObject],     @"C");
		XCTAssertEqualObjects([list lastObject],      @"A");
		[list exchangeObjectAtIndex:0 withObjectAtIndex:1];
		XCTAssertEqualObjects([list firstObject],     @"B");
		XCTAssertEqualObjects([list objectAtIndex:1], @"C");
		[list exchangeObjectAtIndex:2 withObjectAtIndex:1];
		XCTAssertEqualObjects([list objectAtIndex:1], @"A");
		XCTAssertEqualObjects([list lastObject],      @"C");
	}
}

- (void)testInsertObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// Test inserting using invalid object and invalid indexes
		XCTAssertThrows([list insertObject:nil  atIndex:0]);
		XCTAssertThrows([list insertObject:nil  atIndex:-1]);
		XCTAssertThrows([list insertObject:@"A" atIndex:-1]);
		XCTAssertThrows([list insertObject:@"A" atIndex:1]);
		
		[list addObjectsFromArray:abc];
		XCTAssertEqual([list count], [abc count]);
		XCTAssertThrows([list insertObject:@"A" atIndex:[abc count]+1]);
		XCTAssertNoThrow([list insertObject:@"A" atIndex:[abc count]]);
		[list removeLastObject];
		
		// Try inserting in the middle
		[list insertObject:@"D" atIndex:1];
		XCTAssertEqual([list count], [abc count]+1);
		XCTAssertEqualObjects([list objectAtIndex:0], @"A");
		XCTAssertEqualObjects([list objectAtIndex:1], @"D");
		XCTAssertEqualObjects([list objectAtIndex:2], @"B");
		XCTAssertEqualObjects([list objectAtIndex:3], @"C");
		// Try inserting at the beginning
		[list insertObject:@"E" atIndex:0];
		XCTAssertEqual([list count], [abc count]+2);
		XCTAssertEqualObjects([list objectAtIndex:0], @"E");
		XCTAssertEqualObjects([list objectAtIndex:1], @"A");
		XCTAssertEqualObjects([list objectAtIndex:2], @"D");
		XCTAssertEqualObjects([list objectAtIndex:3], @"B");
		XCTAssertEqualObjects([list objectAtIndex:4], @"C");
		// Try inserting at the end
		[list insertObject:@"F" atIndex:5];
		XCTAssertEqual([list count], [abc count]+3);
		XCTAssertEqualObjects([list objectAtIndex:5], @"F");
	}
}

- (void)testInsertObjectsAtIndexes {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// Test inserting using invalid objects and invalid indexes
		XCTAssertThrows([list insertObjects:nil
								 atIndexes:nil]);
		XCTAssertThrows([list insertObjects:[NSArray array]
								 atIndexes:nil]);
		XCTAssertThrows([list insertObjects:[NSArray array]
								 atIndexes:[NSIndexSet indexSetWithIndex:0]]);
		XCTAssertThrows([list insertObjects:[NSArray arrayWithObject:[NSNull null]]
								 atIndexes:[NSIndexSet indexSet]]);
		// Test inserting beyond the allowed index range
		XCTAssertThrows([list insertObjects:[NSArray arrayWithObject:[NSNull null]]
								 atIndexes:[NSIndexSet indexSetWithIndex:1]]);
		// Test inserting a single object into an empty list
		XCTAssertNoThrow([list insertObjects:[NSArray arrayWithObject:@"A"]
								  atIndexes:[NSIndexSet indexSetWithIndex:0]]);
		XCTAssertEqual([list count], (NSUInteger)1);
		XCTAssertEqualObjects([list objectAtIndex:0], @"A");
		// Test inserting multiple objects into an empty list
		[list removeAllObjects];
		NSIndexSet *firstIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [abc count])];
		XCTAssertNoThrow([list insertObjects:abc
								  atIndexes:firstIndexes]);
		XCTAssertEqual([list count], [abc count]);
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
		XCTAssertEqual([list count], [expected count]);
		XCTAssertEqualObjects([list allObjects], expected);
		// Test inserting objects at the front of the list
		[expected insertObjects:abc atIndexes:firstIndexes];
		[list insertObjects:abc atIndexes:firstIndexes];
		XCTAssertEqual([list count], [expected count]);
		XCTAssertEqualObjects([list allObjects], expected);
	}		
}

- (void)testObjectEnumerator {
	NSEnumerator *e;
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		// Enumerator shouldn't retain collection if there are no objects
		XCTAssertEqual([list retainCount], (NSUInteger)1);
		e = [list objectEnumerator];
		XCTAssertNotNil(e);
		XCTAssertEqual([list retainCount], (NSUInteger)1);
		XCTAssertNil([e nextObject]);
		
		// Enumerator should retain collection when it has 1+ objects
		[list addObjectsFromArray:abc];
		XCTAssertEqual([list retainCount], (NSUInteger)1);
		e = [list objectEnumerator];
		XCTAssertNotNil(e);
		XCTAssertEqual([list retainCount], (NSUInteger)2);
		
		// Enumerator should release collection when all objects are exhausted
		XCTAssertEqualObjects([e nextObject], @"A");
		XCTAssertEqualObjects([e nextObject], @"B");
		XCTAssertEqualObjects([e nextObject], @"C");
		
		XCTAssertEqual([list retainCount], (NSUInteger)2);
		XCTAssertNil([e nextObject]);
		XCTAssertEqual([list retainCount], (NSUInteger)1);
		
		e = [list objectEnumerator];
		XCTAssertEqual([list retainCount], (NSUInteger)2);
		NSArray *allObjects = [e allObjects];
		XCTAssertEqual([list retainCount], (NSUInteger)1);
		XCTAssertNotNil(allObjects);
		XCTAssertEqualObjects(allObjects, abc);
		XCTAssertEqualObjects([allObjects objectAtIndex:0], @"A");
		XCTAssertEqualObjects([allObjects lastObject],      @"C");
		
		// Enumerator should release collection on -dealloc
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		XCTAssertEqual([list retainCount], (NSUInteger)1);
		e = [list objectEnumerator];
		XCTAssertNotNil(e);
		XCTAssertEqual([list retainCount], (NSUInteger)2);
		// Force deallocation of enumerator by draining autorelease pool
		[pool drain];
		XCTAssertEqual([list retainCount], (NSUInteger)1);	
		
		// For doubly-linked list, test reverse enumeration order as well
		if (aClass == [CHDoublyLinkedList class]) {
			e = [(CHDoublyLinkedList *)list reverseObjectEnumerator];
			XCTAssertEqualObjects([e nextObject], @"C");
			XCTAssertEqualObjects([e nextObject], @"B");
			XCTAssertEqualObjects([e nextObject], @"A");
			
			XCTAssertEqual([list retainCount], (NSUInteger)2);
			XCTAssertNil([e nextObject]);
			XCTAssertEqual([list retainCount], (NSUInteger)1);
			
			e = [(CHDoublyLinkedList *)list reverseObjectEnumerator];
			XCTAssertEqual([list retainCount], (NSUInteger)2);
			allObjects = [e allObjects];
			XCTAssertEqual([list retainCount], (NSUInteger)1);
			XCTAssertNotNil(allObjects);
			NSArray *cba = [NSArray arrayWithObjects:@"C",@"B",@"A",nil];
			XCTAssertEqualObjects(allObjects, cba);
			XCTAssertEqualObjects([allObjects objectAtIndex:0], @"C");
			XCTAssertEqualObjects([allObjects lastObject],      @"A");			
		}
		
		// Test for mutation exception in the middle of enumeration
		e = [list objectEnumerator];
		XCTAssertNoThrow([e nextObject]);
		[list addObject:@"bogus"];
		XCTAssertThrows([e nextObject]);
		XCTAssertThrows([e allObjects]);
	}
}

#pragma mark Search

- (void)testContainsObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		NSString *a = [NSString stringWithFormat:@"A"];
		XCTAssertFalse([list containsObject:@"A"]);
		[list addObject:@"A"];
		XCTAssertTrue([list containsObject:@"A"]);
		XCTAssertTrue([list containsObject:a]);
		XCTAssertFalse([list containsObject:@"bogus"]);
	}
}

- (void)testContainsObjectIdenticalTo {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		NSString *a = [NSString stringWithFormat:@"A"];
		XCTAssertFalse([list containsObjectIdenticalTo:a]);
		[list addObject:a];
		XCTAssertTrue([list containsObjectIdenticalTo:a]);
		XCTAssertFalse([list containsObjectIdenticalTo:@"A"]);
	}
}

- (void)testIndexOfObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		XCTAssertEqual([list indexOfObject:@"A"], (NSUInteger)NSNotFound);
		[list addObjectsFromArray:abc];
		for (NSUInteger i = 0; i < [abc count]; i++) {
			XCTAssertEqual([list indexOfObject:[abc objectAtIndex:i]], i);
		}
		XCTAssertEqual([list indexOfObject:@"Z"], (NSUInteger)NSNotFound);
	}
}

- (void)testIndexOfObjectIdenticalTo {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		XCTAssertEqual([list indexOfObjectIdenticalTo:@"A"], (NSUInteger)NSNotFound);
		[list addObjectsFromArray:abc];
		// Test with the actual string, then a copy made from the string.
		for (NSUInteger i = 0; i < [abc count]; i++) {
			NSString *string = [abc objectAtIndex:i];
			XCTAssertEqual([list indexOfObjectIdenticalTo:string], (NSUInteger)i);
			string = [NSString stringWithFormat:@"%@", string];
			XCTAssertEqual([list indexOfObjectIdenticalTo:string], (NSUInteger)NSNotFound);
		}
	}
}

- (void)testIsEqualToLinkedList {
	NSMutableArray *emptyLinkedLists = [NSMutableArray array];
	NSMutableArray *equalLinkedLists = [NSMutableArray array];
	for (Class aClass in linkedListClasses) {
		[emptyLinkedLists addObject:[[aClass alloc] init]];
		[equalLinkedLists addObject:[[aClass alloc] initWithArray:abc]];
	}
	// Add a repeat of the first class to avoid wrapping.
	[equalLinkedLists addObject:[equalLinkedLists objectAtIndex:0]];
	
	id<CHLinkedList> list1, list2;
	for (NSUInteger i = 0; i < [linkedListClasses count]; i++) {
		list1 = [equalLinkedLists objectAtIndex:i];
		XCTAssertThrowsSpecificNamed([list1 isEqualToLinkedList:(id)[NSString string]], NSException, NSInvalidArgumentException);
		XCTAssertFalse([list1 isEqual:[NSString string]]);
		XCTAssertEqualObjects(list1, list1);
		list2 = [emptyLinkedLists objectAtIndex:i];
		XCTAssertFalse([list1 isEqual:list2]);
		list2 = [equalLinkedLists objectAtIndex:i+1];
		XCTAssertEqualObjects(list1, list2);
		XCTAssertEqual([list1 hash], [list2 hash]);
	}
}

- (void)testObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		[list addObjectsFromArray:abc];
		XCTAssertThrows([list objectAtIndex:-1]);
		XCTAssertEqualObjects([list objectAtIndex:0], @"A");
		XCTAssertEqualObjects([list objectAtIndex:1], @"B");
		XCTAssertEqualObjects([list objectAtIndex:2], @"C");
		XCTAssertThrows([list objectAtIndex:3]);
	}
}

- (void)testObjectsAtIndexes {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		NSUInteger count = [list count];
		NSRange range;
		for (NSUInteger location = 0; location <= count; location++) {
			range.location = location;
			for (NSUInteger length = 0; length <= count - location + 1; length++) {
				range.length = length;
				NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
				if (location + length > count) {
					XCTAssertThrows([list objectsAtIndexes:indexes]);
				} else {
					XCTAssertEqualObjects([list objectsAtIndexes:indexes],
										 [abc objectsAtIndexes:indexes]);
				}
			}
		}
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		[indexes addIndex:0];
		[indexes addIndex:2];
		XCTAssertEqualObjects([list objectsAtIndexes:indexes],
							 [abc objectsAtIndexes:indexes]);
		XCTAssertThrows([list objectsAtIndexes:nil]);
	}
}

#pragma mark Removal

- (void)testRemoveAllObjects {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		[list addObjectsFromArray:abc];
		XCTAssertEqual([list count], [abc count]);
		[list removeAllObjects];
		XCTAssertEqual([list count], (NSUInteger)0);
	}
}

- (void)testRemoveFirstObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		
		XCTAssertNoThrow([list removeFirstObject]);
		[list addObjectsFromArray:abc];
		
		XCTAssertNoThrow([list removeFirstObject]);
		XCTAssertEqual([list count], (NSUInteger)2);
		XCTAssertEqualObjects([list firstObject], @"B");
		XCTAssertEqualObjects([list lastObject],  @"C");
		
		[list removeFirstObject];
		XCTAssertEqual([list count], (NSUInteger)1);
		XCTAssertEqualObjects([list firstObject], @"C");
		XCTAssertEqualObjects([list lastObject],  @"C");
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeFirstObject];
		XCTAssertEqual([list count], (NSUInteger)0);
		XCTAssertNil([list firstObject]);
		XCTAssertNil([list lastObject]);
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
	}
}

- (void)testRemoveLastObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		
		[list removeLastObject]; // Should have no effect
		[list addObjectsFromArray:abc];
		
		[list removeLastObject];
		XCTAssertEqual([list count], (NSUInteger)2);
		XCTAssertEqualObjects([list firstObject], @"A");
		XCTAssertEqualObjects([list lastObject],  @"B");
		
		[list removeLastObject];
		XCTAssertEqual([list count], (NSUInteger)1);
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeLastObject];
		XCTAssertEqual([list count], (NSUInteger)0);
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
	}
}

- (void)testRemoveObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		[list removeObject:@"bogus"]; // Should have no effect
		XCTAssertThrows([list removeObject:nil]);
		
		[list addObjectsFromArray:abc];
		
		[list removeObject:@"B"];
		XCTAssertEqual([list count], (NSUInteger)2);
		XCTAssertEqualObjects([list firstObject], @"A");
		XCTAssertEqualObjects([list lastObject],  @"C");
		
		[list removeObject:@"A"];
		XCTAssertEqual([list count], (NSUInteger)1);
		XCTAssertEqualObjects([list firstObject], @"C");
		XCTAssertEqualObjects([list lastObject],  @"C");
		
		[list removeObject:@"C"];
		XCTAssertEqual([list count], (NSUInteger)0);
		XCTAssertNil([list firstObject]);
		XCTAssertNil([list lastObject]);
		
		// Test removing all instances of an object	
		[list addObject:@"A"];
		[list addObject:@"Z"];
		[list addObject:@"B"];
		[list addObject:@"Z"];
		[list addObject:@"Z"];
		[list addObject:@"C"];
		
		XCTAssertEqual([list count], (NSUInteger)6);
		[list removeObject:@"Z"];
		XCTAssertEqual([list count], (NSUInteger)3);
		XCTAssertEqualObjects([list objectAtIndex:0], @"A");
		XCTAssertEqualObjects([list objectAtIndex:1], @"B");
		XCTAssertEqualObjects([list objectAtIndex:2], @"C");	
	}
}

- (void)testRemoveObjectIdenticalTo {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] init] autorelease];
		XCTAssertThrows([list removeObjectIdenticalTo:nil]);
		
		NSString *a = [NSString stringWithFormat:@"A"];
		[list addObject:a];
		XCTAssertEqual([list count], (NSUInteger)1);
		[list removeObjectIdenticalTo:@"A"];
		XCTAssertEqual([list count], (NSUInteger)1);
		[list removeObjectIdenticalTo:a];
		XCTAssertEqual([list count], (NSUInteger)0);
		
		// Test removing all instances of an object
		[list addObject:@"A"];
		[list addObject:@"Z"];
		[list addObject:@"B"];
		[list addObject:@"Z"];
		[list addObject:@"C"];
		[list addObject:[NSString stringWithFormat:@"Z"]];

		XCTAssertThrows([list removeObjectIdenticalTo:nil]);

		XCTAssertEqual([list count], (NSUInteger)6);
		[list removeObjectIdenticalTo:@"Z"];
		XCTAssertEqual([list count], (NSUInteger)4);
		XCTAssertEqualObjects([list objectAtIndex:0], @"A");
		XCTAssertEqualObjects([list objectAtIndex:1], @"B");
		XCTAssertEqualObjects([list objectAtIndex:2], @"C");	
		XCTAssertEqualObjects([list objectAtIndex:3], @"Z");
	}
}

- (void)testRemoveObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		
		XCTAssertThrows([list removeObjectAtIndex:3]);
		XCTAssertThrows([list removeObjectAtIndex:-1]);
		
		[list removeObjectAtIndex:2];
		XCTAssertEqual([list count], (NSUInteger)2);
		XCTAssertEqualObjects([list firstObject], @"A");
		XCTAssertEqualObjects([list lastObject],  @"B");
		
		[list removeObjectAtIndex:0];
		XCTAssertEqual([list count], (NSUInteger)1);
		XCTAssertEqualObjects([list firstObject], @"B");
		XCTAssertEqualObjects([list lastObject],  @"B");
		
		[list removeObjectAtIndex:0];
		XCTAssertEqual([list count], (NSUInteger)0);
		
		[list addObjectsFromArray:abc];
		// Test removing from an index in the middle
		[list removeObjectAtIndex:1];
		XCTAssertEqual([list count], (NSUInteger)2);
		XCTAssertEqualObjects([list firstObject], @"A");
		XCTAssertEqualObjects([list lastObject],  @"C");
	}
}

- (void)testRemoveObjectsAtIndexes {
	NSIndexSet *indexes;
	
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		// Test removing with invalid indexes
		XCTAssertThrows([list removeObjectsAtIndexes:nil]);
		indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
		XCTAssertThrows([list removeObjectsAtIndexes:indexes]);
		
		// Test removing contiguous ranges
		for (NSUInteger location = 0; location < [abc count]; location++) {
			for (NSUInteger length = 0; length <= [abc count] - location; length++) {
				indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
				[self _testRemoveObjectsAtIndexes:indexes initialObjects:abc];
			}
		}
		// Test removing discontiguous ranges
		NSMutableIndexSet *mutableIndexes = [NSMutableIndexSet indexSet];
		[mutableIndexes addIndex:0];
		[mutableIndexes addIndex:2];
		[self _testRemoveObjectsAtIndexes:mutableIndexes initialObjects:abc];
	}
}

- (void)_testRemoveObjectsAtIndexes:(NSIndexSet *)indexes initialObjects:(NSArray *)array {
	[list removeAllObjects];
	[list addObjectsFromArray:array];
	XCTAssertNoThrow([list removeObjectsAtIndexes:indexes]);
	NSMutableArray *expected = [array mutableCopy];
	[expected removeObjectsAtIndexes:indexes];
	XCTAssertEqual([list count], [expected count]);
	XCTAssertEqualObjects([list allObjects], expected);
}

- (void)testReplaceObjectAtIndexWithObject {
	for (Class aClass in linkedListClasses) {
		list = [[[aClass alloc] initWithArray:abc] autorelease];
		for (NSUInteger i = 0; i < [abc count]; i++) {
			XCTAssertEqualObjects([list objectAtIndex:i], [abc objectAtIndex:i]);
			[list replaceObjectAtIndex:i withObject:@"Z"];
			XCTAssertEqualObjects([list objectAtIndex:i], @"Z");
		}
		[list removeAllObjects];
		XCTAssertThrows([list replaceObjectAtIndex:0 withObject:nil]);
		XCTAssertThrows([list replaceObjectAtIndex:1 withObject:nil]);
	}
}

@end
