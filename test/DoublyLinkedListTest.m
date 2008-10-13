//  DoublyLinkedListTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "DoublyLinkedList.h"

@interface DoublyLinkedListTest : SenTestCase {
	DoublyLinkedList *list;
	NSArray *testArray;
}
@end


@implementation DoublyLinkedListTest

- (void) setUp {
    list = [[DoublyLinkedList alloc] init];
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

- (void) testAppendObject {
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
}

- (void) testPrependObject {
	for (id anObject in testArray)
		[list prependObject:anObject];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testRemoveFirstLastObject {
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	[list removeFirstObject];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"B", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeLastObject];
	STAssertEquals([list count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"B", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
}

- (void) testRemoveAllObjects {
	for (id anObject in testArray)
		[list appendObject:anObject];
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	[list appendObject:@"Hello, World!"];
	STAssertEquals([list count], 4u, @"-count is incorrect.");
	
	[list removeAllObjects];
	STAssertEquals([list count], 0u, @"-count is incorrect.");
}

- (void) testObjectEnumerator {
	NSEnumerator *e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	NSArray *array = [[list objectEnumerator] allObjects];
	STAssertNotNil(array, @"Array should not be nil");
	STAssertEquals([array count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([array objectAtIndex:0], @"A", @"Object order is wrong.");
	STAssertEqualObjects([array lastObject],      @"C", @"Object order is wrong.");
}

- (void) testReverseObjectEnumerator {
	NSEnumerator *e = [list reverseObjectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	e = [list reverseObjectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	NSArray *array = [[list reverseObjectEnumerator] allObjects];
	STAssertNotNil(array, @"Array should not be nil");
	STAssertEquals([array count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([array objectAtIndex:0], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([array lastObject],      @"A", @"-lastObject is wrong.");
}

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

- (void) testObjectAtIndex {
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	STAssertThrows([list objectAtIndex:-1], @"Should raise NSRangeException.");
	STAssertEqualObjects([list objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:1], @"B", @"-objectAtIndex: is wrong.");
	STAssertEqualObjects([list objectAtIndex:2], @"C", @"-objectAtIndex: is wrong.");
	STAssertThrows([list objectAtIndex:3], @"Should raise NSRangeException.");
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
}

- (void) testRemoveObjectAtIndexMiddle {
	for (id anObject in testArray)
		[list appendObject:anObject];
	
	[list removeObjectAtIndex:1];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
}

@end
