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
	testArray = [NSArray arrayWithObjects:
				 @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", nil];
}

- (void) tearDown {
	[queue release];
}

- (void) testAddObject {
	STAssertThrows([queue addObject:nil], @"-failed to throw nilArgumentException.");
	
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[queue addObject:object];
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	
	STAssertThrows([queue addObject:nil], @"-failed to throw nilArgumentException.");
}

- (void) testNextObjectAndRemoveNextObject {
	for (id object in testArray)
		[queue addObject:object];
	
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 8u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"B", @"-nextObject is wrong.");
	STAssertEquals([queue count], 8u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 7u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"C", @"-nextObject is wrong.");
	STAssertEquals([queue count], 7u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 6u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"D", @"-nextObject is wrong.");
	STAssertEquals([queue count], 6u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 5u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"E", @"-nextObject is wrong.");
	STAssertEquals([queue count], 5u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"E", @"-nextObject is wrong.");
	STAssertEquals([queue count], 5u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 4u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"F", @"-nextObject is wrong.");
	STAssertEquals([queue count], 4u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"G", @"-nextObject is wrong.");
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"H", @"-nextObject is wrong.");
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"I", @"-nextObject is wrong.");
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"I", @"-nextObject is wrong.");
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue nextObject], @"-nextObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	STAssertNil([queue nextObject], @"-nextObject should return nil.");
	STAssertEquals([queue count], 0u, @"-count is incorrect.");
	
	// test it with a differnt order of objects
	for (id object in [testArray reverseObjectEnumerator])
		[queue addObject:object];
	
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"I", @"-nextObject is wrong.");
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"I", @"-nextObject is wrong.");
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"I", @"-nextObject is wrong.");
	STAssertEquals([queue count], 9u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 8u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"H", @"-nextObject is wrong.");
	STAssertEquals([queue count], 8u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 7u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"G", @"-nextObject is wrong.");
	STAssertEquals([queue count], 7u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 6u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"F", @"-nextObject is wrong.");
	STAssertEquals([queue count], 6u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 5u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"E", @"-nextObject is wrong.");
	STAssertEquals([queue count], 5u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"E", @"-nextObject is wrong.");
	STAssertEquals([queue count], 5u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 4u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"D", @"-nextObject is wrong.");
	STAssertEquals([queue count], 4u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"C", @"-nextObject is wrong.");
	STAssertEquals([queue count], 3u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"B", @"-nextObject is wrong.");
	STAssertEquals([queue count], 2u, @"-count is incorrect.");
	[queue removeNextObject];
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
	STAssertEquals([queue count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([queue nextObject], @"A", @"-nextObject is wrong.");
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
