//  CHMutableArrayStackTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayStack.h"

@interface CHMutableArrayStackTest : SenTestCase {
	CHMutableArrayStack *stack;
	NSArray *testArray;
}
@end


@implementation CHMutableArrayStackTest

- (void) setUp {
	stack = [[CHMutableArrayStack alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
	[stack release];
}

- (void) testCountAndPushObject {
	STAssertThrows([stack pushObject:nil], @"Should raise nilArgumentException.");
	
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[stack pushObject:object];
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	
	STAssertThrows([stack pushObject:nil], @"Should raise nilArgumentException.");
}

- (void) testTopObjectAndPopObject {
	for (id object in testArray)
		[stack pushObject:object];
	
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"C", @"-topObject is wrong.");
	STAssertEquals([stack count], 3u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 2u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"B", @"-topObject is wrong.");
	STAssertEquals([stack count], 2u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 1u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"A", @"-topObject is wrong.");
	STAssertEquals([stack count], 1u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	STAssertNil([stack topObject], @"-topObject should return nil.");
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
}

@end
