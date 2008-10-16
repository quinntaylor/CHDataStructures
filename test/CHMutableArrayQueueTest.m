//  CHMutableArrayQueueTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayQueue.h"

@interface CHMutableArrayQueueTest : SenTestCase {
	CHMutableArrayQueue *queue;
	NSArray *testArray;
}
@end


@implementation CHMutableArrayQueueTest

- (void) setUp {
	queue = [[CHMutableArrayQueue alloc] init];
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
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"B", @"-nextObject is wrong.");
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"C", @"-nextObject is wrong.");
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue nextObject], @"-nextObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue nextObject], @"-nextObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
}

@end
