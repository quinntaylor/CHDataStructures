//  CHDoublyLinkedListTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHDoublyLinkedList.h"

static BOOL gcDisabled;

@interface CHDoublyLinkedListTest : SenTestCase {
	CHDoublyLinkedList *list;
	NSArray *testArray;
	NSEnumerator *e;
}
@end

@implementation CHDoublyLinkedListTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
    list = [[CHDoublyLinkedList alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
    [list release];
}

- (void) testEmptyList {
	STAssertNotNil(list, @"list should not be nil");
	STAssertEquals([list count], 0u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], nil, @"-firstObject should be nil.");	
	STAssertEqualObjects([list lastObject], nil, @"-lastObject should be nil.");
}

#pragma mark Insertion and Access

- (void) testAppendObject {
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject], @"C", @"-lastObject is wrong.");
}

- (void) testPrependObject {
	for (id anObject in testArray)
		[list prependObject:anObject];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testInsertObjectAtIndex {
	STAssertThrows([list insertObject:@"D" atIndex:-1], @"Should raise NSRangeException.");
	STAssertThrows([list insertObject:@"D" atIndex:0], @"Should raise NSRangeException.");
	
	for (id anObject in testArray)
		[list appendObject:anObject];
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertThrows([list insertObject:@"D" atIndex:3], @"Should raise NSRangeException.");
	[list insertObject:@"D" atIndex:1];
	STAssertEquals([list count], 4u, @"-count is incorrect.");
	STAssertEqualObjects([list objectAtIndex:1], @"D", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:2], @"B", @"-objectAtIndex: is wrong.");
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
	for (id anObject in testArray)
		[list appendObject:anObject];
	if (gcDisabled)
		STAssertEquals([list retainCount], 1u, @"Wrong retain count");
	e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([list retainCount], 2u, @"Enumerator should retain collection");
	
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	
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
	STAssertEquals([array count], 3u, @"-count is incorrect.");
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
}

- (void) testFastEnumeration {
	for (id anObject in testArray)
		[list appendObject:anObject];
	NSUInteger count = 0;
	for (id anObject in list) {
		STAssertNotNil(anObject, @"Object should not be nil.");
		count++;
	}
	STAssertEquals(count, 3u, @"Count of enumerated items is incorrect.");
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
	for (id anObject in testArray)
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
	
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	[list removeFirstObject];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"B", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
}

- (void) testRemoveLastObject {
	[list removeLastObject]; // Should have no effect
	
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	[list removeLastObject];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
}

- (void) testRemoveObject {
	[list removeObject:@"Z"]; // Should have no effect
	
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	[list removeObject:@"B"];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeObject:@"A"];
	STAssertEquals([list count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeObject:@"C"];
	STAssertEquals([list count], 0u, @"-count is incorrect.");
	STAssertNil([list firstObject], @"-firstObject should return nil.");
	STAssertNil([list lastObject], @"-lastObject should return nil.");
	
	// Test removing all instances of an object	
	[list appendObject:@"A"];
	[list appendObject:@"Z"];
	[list appendObject:@"B"];
	[list appendObject:@"Z"];
	[list appendObject:@"Z"];
	[list appendObject:@"C"];
	
	STAssertEquals([list count], 6u, @"-count is incorrect.");
	[list removeObject:@"Z"];
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
}

- (void) testRemoveObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[list appendObject:a];
	STAssertEquals([list count], 1u, @"-count is incorrect.");
	[list removeObjectIdenticalTo:@"A"];
	STAssertEquals([list count], 1u, @"-count is incorrect.");
	[list removeObjectIdenticalTo:a];
	STAssertEquals([list count], 0u, @"-count is incorrect.");
	
	// Test removing all instances of an object
	[list appendObject:@"A"];
	[list appendObject:@"Z"];
	[list appendObject:@"B"];
	[list appendObject:@"Z"];
	[list appendObject:@"C"];
	[list appendObject:[NSString stringWithFormat:@"Z"]];
	
	STAssertEquals([list count], 6u, @"-count is incorrect.");
	[list removeObjectIdenticalTo:@"Z"];
	STAssertEquals([list count], 4u, @"-count is incorrect.");
	STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
	STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
	STAssertEqualObjects([list objectAtIndex:3], @"Z", @"Wrong object at index.");
}

- (void) testRemoveObjectAtIndex {
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	STAssertThrows([list removeObjectAtIndex:3], @"Should raise NSRangeException.");
	STAssertThrows([list removeObjectAtIndex:-1], @"Should raise NSRangeException.");
	
	[list removeObjectAtIndex:2];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
	
	[list removeObjectAtIndex:0];
	STAssertEquals([list count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"B", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
	
	[list removeObjectAtIndex:0];
	STAssertEquals([list count], 0u, @"-count is incorrect.");
	
	// Test removing from an index in the middle
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	[list removeObjectAtIndex:1];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
}

- (void) testRemoveAllObjects {
	for (id anObject in testArray)
		[list appendObject:anObject];
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	[list removeAllObjects];
	STAssertEquals([list count], 0u, @"-count is incorrect.");
}

@end
