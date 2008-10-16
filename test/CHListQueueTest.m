//  CHListQueueTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHListQueue.h"

@interface CHListQueueTest : SenTestCase {
	CHListQueue *queue;
	NSArray *testArray;
}
@end


@implementation CHListQueueTest

- (void) setUp {
	queue = [[CHListQueue alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[queue release];
}

- (void) testAddObjectAndCount {
	STAssertThrows([queue addObject:nil], @"Should raise nilArgumentException.");
	
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[queue addObject:object];
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	
	STAssertThrows([queue addObject:nil], @"Should raise nilArgumentException.");
}

- (void) testNextObjectAndRemoveNextObject {
	for (id object in testArray)
		[queue addObject:object];
	
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"A", @"-firstObject is wrong.");
	STAssertEqualObjects([queue firstObject], @"A", @"-firstObject is wrong.");
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"B", @"-firstObject is wrong.");
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue firstObject], @"C", @"-firstObject is wrong.");
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue firstObject], @"-firstObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	[queue removeFirstObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue firstObject], @"-firstObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
}

@end
