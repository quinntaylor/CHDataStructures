//  SinglyLinkedListTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "SinglyLinkedList.h"

@interface SinglyLinkedListTest : SenTestCase {
	SinglyLinkedList *list;
	NSArray *testArray;
}
@end


@implementation SinglyLinkedListTest

- (void) setUp {
    list = [[SinglyLinkedList alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
    [list release];
}

- (void) testEmptyList {
	STAssertEquals([list count], 0u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], nil, @"-firstObject should be nil.");	
	STAssertEqualObjects([list lastObject], nil, @"-lastObject should be nil.");
}

- (void) testAppendObject {
	[list appendObject:@"A"];
	[list appendObject:@"B"];
	[list appendObject:@"C"];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject], @"C", @"-lastObject is wrong.");
}

- (void) testAppendObjectsFromEnumerator {
	[list appendObjectsFromEnumerator:[testArray objectEnumerator]];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
}

- (void) testPrependObject {
	[list prependObject:@"A"];
	[list prependObject:@"B"];
	[list prependObject:@"C"];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testPrependObjectsFromEnumerator {
	[list prependObjectsFromEnumerator:[testArray objectEnumerator]];
	
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testRemoveFirstLastObject {
	[list appendObjectsFromEnumerator:[testArray objectEnumerator]];
	STAssertEquals([list count], 3u, @"-count is incorrect.");
	
	[list removeFirstObject];
	STAssertEquals([list count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"B", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
	
	[list removeLastObject];
	STAssertEquals([list count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([list firstObject], @"B", @"-firstObject is wrong.");
	STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
}

- (void) testObjectEnumerator {
	NSEnumerator *e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	[list appendObjectsFromEnumerator:[testArray objectEnumerator]];
	
	e = [list objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	NSArray *array = [[list objectEnumerator] allObjects];
	STAssertNotNil(array, @"Array should not be nil");
	STAssertEquals([array count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([array objectAtIndex:0], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([array lastObject],      @"C", @"-lastObject is wrong.");
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

@end
