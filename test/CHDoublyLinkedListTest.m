/*
 CHDoublyLinkedListTest.m
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
#import "CHDoublyLinkedList.h"

static BOOL gcDisabled;

@interface CHDoublyLinkedList (Test)

- (CHDoublyLinkedListNode*) head;
- (CHDoublyLinkedListNode*) tail;

@end

@implementation CHDoublyLinkedList (Test)

- (CHDoublyLinkedListNode*) head {
	return head;
}

- (CHDoublyLinkedListNode*) tail {
	return tail;
}

@end

#pragma mark -

@interface CHDoublyLinkedListTest : SenTestCase {
	CHDoublyLinkedList *list;
	NSArray *objects;
	NSEnumerator *e;
}
@end

@implementation CHDoublyLinkedListTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
    list = [[CHDoublyLinkedList alloc] init];
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
    [list release];
}

#pragma mark -

- (void) testNSCoding {
	for (id anObject in objects)
		[list appendObject:anObject];
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	
	NSString *filePath = @"/tmp/list.archive";
	[NSKeyedArchiver archiveRootObject:list toFile:filePath];
	[list release];
	
	list = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([list allObjects], objects,
	                     @"Wrong ordering on reconstruction.");
}

- (void) testNSCopying {
	for (id anObject in objects)
		[list appendObject:anObject];
	CHDoublyLinkedList *list2 = [list copy];
	STAssertNotNil(list2, @"-copy should not return nil for valid list.");
	STAssertEquals([list2 count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([list allObjects], [list2 allObjects], @"Unequal lists.");
	[list2 release];
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected = 1, count = 0;
	for (number = 1; number <= 32; number++)
		[list appendObject:[NSNumber numberWithUnsignedInteger:number]];
	for (NSNumber *object in list) {
		STAssertEquals([object unsignedIntegerValue], expected++,
		               @"Objects should be enumerated in ascending order.");
		count++;
	}
	STAssertEquals(count, 32u, @"Count of enumerated items is incorrect.");
}

#pragma mark -

- (void) testEmptyList {
	STAssertNotNil(list, @"list should not be nil");
	STAssertEquals([list count], 0u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], nil, @"-firstObject should be nil.");	
	STAssertEqualObjects([list lastObject], nil, @"-lastObject should be nil.");
}

- (void) testInitWithArray {
	[list release];
    list = [[CHDoublyLinkedList alloc] initWithArray:objects];
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([list allObjects], objects,
						 @"Bad array ordering on -initWithArray:");
}

- (void) testDescription {
	for (id anObject in objects)
		[list appendObject:anObject];
	STAssertEqualObjects([list description], [objects description],
						 @"-description uses bad ordering.");
}

#pragma mark Insertion and Access

- (void) testAppendObject {
	STAssertThrows([list appendObject:nil], @"Should raise an exception on nil.");
	
	for (id anObject in objects)
		[list appendObject:anObject];
	
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject], @"C", @"-lastObject is wrong.");
}

- (void) testPrependObject {
	STAssertThrows([list prependObject:nil], @"Should raise an exception on nil.");
	
	for (id anObject in objects)
		[list prependObject:anObject];
	
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testInsertObjectAtIndex {
	STAssertThrows([list insertObject:nil atIndex:-1],
	               @"Should raise an exception on nil.");
	
	STAssertThrows([list insertObject:@"D" atIndex:-1], @"Should raise NSRangeException.");
	STAssertThrows([list insertObject:@"D" atIndex:1], @"Should raise NSRangeException.");
	
	for (id anObject in objects)
		[list appendObject:anObject];
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	STAssertThrows([list insertObject:@"D" atIndex:4], @"Should raise NSRangeException.");
	// Try inserting in the middle
	[list insertObject:@"D" atIndex:1];
	STAssertEquals([list count], [objects count]+1, @"Incorrect count.");
	STAssertEqualObjects([list objectAtIndex:1], @"D", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:2], @"B", @"-objectAtIndex: is wrong.");
	// Try inserting at the beginning
	[list insertObject:@"E" atIndex:0];
	STAssertEquals([list count], [objects count]+2, @"Incorrect count.");
	STAssertEqualObjects([list objectAtIndex:0], @"E", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:1], @"A", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:2], @"D", @"-objectAtIndex: is wrong.");
}

- (void) testObjectEnumerator {
	// Enumerator shouldn't retain collection if there are no objects
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Wrong retain count");
	e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Should not retain collection");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	// Enumerator should retain collection when it has 1+ objects, release when 0
	for (id anObject in objects)
		[list appendObject:anObject];
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Wrong retain count");
	e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([list retainCount], 2u, @"Enumerator should retain collection");
	
	STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
	STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
	STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
	
	if (gcDisabled)
		STAssertEquals([list retainCount], 2u, @"Collection should still be retained");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Enumerator should release collection");
	
	e = [list objectEnumerator];
	if (gcDisabled)
		STAssertEquals([list retainCount], 2u, @"Enumerator should retain collection");
	NSArray *array = [e allObjects];
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Enumerator should release collection");
	STAssertNotNil(array, @"Array should not be nil");
	STAssertEquals([array count], [objects count], @"Incorrect count.");
	STAssertEqualObjects([array objectAtIndex:0], @"A", @"Object order is wrong.");
	STAssertEqualObjects([array lastObject],      @"C", @"Object order is wrong.");
	
	// Test that enumerator releases on -dealloc
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Wrong retain count");
	e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([list retainCount], 2u, @"Enumerator should retain collection");
	[pool drain]; // Force deallocation of enumerator
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Enumerator should release collection");	
	
	// Test mutation in the middle of enumeration
	e = [list objectEnumerator];
	[list appendObject:@"Z"];
	STAssertThrows([e nextObject], @"Should raise mutation exception.");
	STAssertThrows([e allObjects], @"Should raise mutation exception.");
	BOOL raisedException = NO;
	@try {
		for (id object in list)
			[list appendObject:@"123"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, @"Should raise mutation exception.");
	
	// Test deallocation in the middle of enumeration
	pool  = [[NSAutoreleasePool alloc] init];
	e = [list objectEnumerator];
	[e nextObject];
	[e nextObject];
	e = nil;
	[pool drain]; // Will cause enumerator to be deallocated
	
	pool  = [[NSAutoreleasePool alloc] init];
	e = [list objectEnumerator];
	[e nextObject];
	e = nil;
	[pool drain]; // Will cause enumerator to be deallocated
}

#pragma mark Search

- (void) testContainsObject {
	[list appendObject:@"A"];
	STAssertTrue([list containsObject:@"A"], @"Should return YES.");
	STAssertFalse([list containsObject:@"Z"], @"Should return NO.");
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[list appendObject:a];
	STAssertTrue([list containsObjectIdenticalTo:a], @"Should return YES.");
	STAssertFalse([list containsObjectIdenticalTo:@"A"], @"Should return NO.");
}

- (void) testIndexOfObject {
	[list appendObject:@"A"];
	STAssertEquals([list indexOfObject:@"A"], 0u, @"Should return 0.");
	STAssertEquals([list indexOfObject:@"Z"], (unsigned) NSNotFound,
				   @"Should return NSNotFound.");
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[list appendObject:a];
	STAssertEquals([list indexOfObjectIdenticalTo:a], 0u, @"Should return 0.");
	STAssertEquals([list indexOfObjectIdenticalTo:@"A"], (unsigned) NSNotFound,
				   @"Should return NSNotFound.");
}

- (void) testObjectAtIndex {
	for (id anObject in objects)
		[list appendObject:anObject];
	
	STAssertThrows([list objectAtIndex:-1], @"Should raise NSRangeException.");
	STAssertEqualObjects([list objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:1], @"B", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:2], @"C", @"-objectAtIndex: is wrong.");
	STAssertThrows([list objectAtIndex:3], @"Should raise NSRangeException.");
}

#pragma mark Removal

- (void) testRemoveFirstObject {
	[list removeFirstObject]; // Should have no effect
	
	for (id anObject in objects)
		[list appendObject:anObject];
	
	[list removeFirstObject];
	STAssertEquals([list count], 2u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"B", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeFirstObject];
	STAssertEquals([list count], 1u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	STAssertEquals([list head]->next, [list tail]->prev,
				   @"head and tail should point to the same object.");
	
	[list removeFirstObject];
	STAssertEquals([list count], 0u, @"Incorrect count.");
	STAssertTrue([list head]->next == [list tail], @"head should point to tail.");
	STAssertTrue([list tail]->prev == [list head], @"tail should point to head.");
}

- (void) testRemoveLastObject {
	[list removeLastObject]; // Should have no effect
	
	for (id anObject in objects)
		[list appendObject:anObject];
	
	[list removeLastObject];
	STAssertEquals([list count], 2u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");

	[list removeLastObject];
	STAssertEquals([list count], 1u, @"Incorrect count.");
	STAssertEquals([list head]->next, [list tail]->prev,
				   @"head and tail should point to the same object.");
	
	[list removeLastObject];
	STAssertEquals([list count], 0u, @"Incorrect count.");
	STAssertTrue([list head]->next == [list tail], @"head should point to tail.");
	STAssertTrue([list tail]->prev == [list head], @"tail should point to head.");
}

- (void) testRemoveObject {
	[list removeObject:@"Z"]; // Should have no effect
	
	for (id anObject in objects)
		[list appendObject:anObject];
	
	[list removeObject:@"B"];
	STAssertEquals([list count], 2u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeObject:@"A"];
	STAssertEquals([list count], 1u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeObject:@"C"];
	STAssertEquals([list count], 0u, @"Incorrect count.");
	STAssertNil([list firstObject], @"-firstObject should return nil.");
	STAssertNil([list lastObject], @"-lastObject should return nil.");
	
	// Test removing all instances of an object	
	[list appendObject:@"A"];
	[list appendObject:@"Z"];
	[list appendObject:@"B"];
	[list appendObject:@"Z"];
	[list appendObject:@"Z"];
	[list appendObject:@"C"];
	
	STAssertEquals([list count], 6u, @"Incorrect count.");
	[list removeObject:@"Z"];
	STAssertEquals([list count], 3u, @"Incorrect count.");
	STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[list appendObject:a];
	STAssertEquals([list count], 1u, @"Incorrect count.");
	[list removeObjectIdenticalTo:@"A"];
	STAssertEquals([list count], 1u, @"Incorrect count.");
	[list removeObjectIdenticalTo:a];
	STAssertEquals([list count], 0u, @"Incorrect count.");
	
	// Test removing all instances of an object
	[list appendObject:@"A"];
	[list appendObject:@"Z"];
	[list appendObject:@"B"];
	[list appendObject:@"Z"];
	[list appendObject:@"C"];
	[list appendObject:[NSString stringWithFormat:@"Z"]];
	
	STAssertEquals([list count], 6u, @"Incorrect count.");
	[list removeObjectIdenticalTo:@"Z"];
	STAssertEquals([list count], 4u, @"Incorrect count.");
	STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
	STAssertEqualObjects([list objectAtIndex:3], @"Z", @"Wrong object at index.");
}

- (void) testRemoveObjectAtIndex {
	for (id anObject in objects)
		[list appendObject:anObject];
	
	STAssertThrows([list removeObjectAtIndex:3], @"Should raise NSRangeException.");
	STAssertThrows([list removeObjectAtIndex:-1], @"Should raise NSRangeException.");
	
	[list removeObjectAtIndex:2];
	STAssertEquals([list count], 2u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
	
	[list removeObjectAtIndex:0];
	STAssertEquals([list count], 1u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"B", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
	
	[list removeObjectAtIndex:0];
	STAssertEquals([list count], 0u, @"Incorrect count.");
	
	// Test removing from an index in the middle
	for (id anObject in objects)
		[list appendObject:anObject];
	
	[list removeObjectAtIndex:1];
	STAssertEquals([list count], 2u, @"Incorrect count.");
	STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
}

- (void) testRemoveAllObjects {
	for (id anObject in objects)
		[list appendObject:anObject];
	STAssertEquals([list count], [objects count], @"Incorrect count.");
	[list removeAllObjects];
	STAssertEquals([list count], 0u, @"Incorrect count.");
}

@end
