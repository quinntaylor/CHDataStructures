//  SinglyLinkedListTest.m
//  DataStructures.framework

#import "SinglyLinkedListTest.h"

@implementation SinglyLinkedListTest

- (void) setUp {
    slist = [[SinglyLinkedList alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
    [slist release];
}

- (void) testEmptyList {
	STAssertEquals([slist count], 0u, @"-count is incorrect.");
	STAssertEqualObjects([slist firstObject], nil, @"-firstObject should be nil.");	
	STAssertEqualObjects([slist lastObject], nil, @"-lastObject should be nil.");
}

- (void) testAppendObject {
	[slist appendObject:@"A"];
	[slist appendObject:@"B"];
	[slist appendObject:@"C"];
	
	STAssertEquals([slist count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([slist firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([slist lastObject], @"C", @"-lastObject is wrong.");
}

- (void) testAppendObjectsFromEnumerator {
	[slist appendObjectsFromEnumerator:[testArray objectEnumerator]];
	
	STAssertEquals([slist count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([slist firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([slist lastObject],  @"C", @"-lastObject is wrong.");
}

- (void) testPrependObject {
	[slist prependObject:@"A"];
	[slist prependObject:@"B"];
	[slist prependObject:@"C"];
	
	STAssertEquals([slist count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([slist firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([slist lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testPrependObjectsFromEnumerator {
	[slist prependObjectsFromEnumerator:[testArray objectEnumerator]];
	
	STAssertEquals([slist count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([slist firstObject], @"C", @"-firstObject is wrong.");
	STAssertEqualObjects([slist lastObject],  @"A", @"-lastObject is wrong.");
}

- (void) testObjectEnumerator {
	NSEnumerator *e = [slist objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	[slist appendObjectsFromEnumerator:[testArray objectEnumerator]];
	
	e = [slist objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
	
	NSArray *array = [[slist objectEnumerator] allObjects];
	STAssertNotNil(array, @"Array should not be nil");
	STAssertEquals([array count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([array objectAtIndex:0], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([array lastObject],      @"C", @"-lastObject is wrong.");
}

@end
