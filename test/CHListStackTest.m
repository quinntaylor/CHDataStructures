//  CHListStackTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHListStack.h"

@interface CHListStackTest : SenTestCase {
	CHListStack *stack;
	NSArray *testArray;
}
@end


@implementation CHListStackTest

- (void) setUp {
	stack = [[CHListStack alloc] init];
	testArray = [NSArray arrayWithObjects:
				 @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", nil];
}

- (void) tearDown {
	[stack release];
}

- (void) testPushObject {
	STAssertThrows([stack pushObject:nil], @"-failed to throw nilArgumentException.");
	
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[stack pushObject:object];
	STAssertEquals([stack count], 9u, @"-count is incorrect.");
	
	STAssertThrows([stack pushObject:nil], @"-failed to throw nilArgumentException.");	
}

- (void) testTopObjectAndPopObject {
	// this will be a very thorough first pass
	for (id object in testArray)
		[stack pushObject:object];
	
	STAssertEquals([stack count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"I", @"-topObject is wrong.");
	STAssertEqualObjects([stack topObject], @"I", @"-topObject is wrong.");
	STAssertEqualObjects([stack topObject], @"I", @"-topObject is wrong.");
	STAssertEquals([stack count], 9u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 8u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"H", @"-topObject is wrong.");
	STAssertEquals([stack count], 8u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 7u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"G", @"-topObject is wrong.");
	STAssertEquals([stack count], 7u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 6u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"F", @"-topObject is wrong.");
	STAssertEquals([stack count], 6u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 5u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"E", @"-topObject is wrong.");
	STAssertEqualObjects([stack topObject], @"E", @"-topObject is wrong.");
	STAssertEquals([stack count], 5u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 4u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"D", @"-topObject is wrong.");
	STAssertEquals([stack count], 4u, @"-count is incorrect.");
	[stack popObject];
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
	STAssertEqualObjects([stack topObject], @"A", @"-topObject is wrong.");
	STAssertEquals([stack count], 1u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	STAssertNil([stack topObject], @"-topObject should return nil.");
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	[stack popObject];
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	STAssertNil([stack topObject], @"-topObject should return nil.");
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
	
	// now test it with a different order of objects
	for (id object in [testArray reverseObjectEnumerator])
		[stack pushObject:object];
	
	STAssertEquals([stack count], 9u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"A", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"B", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"C", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"D", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"E", @"-topObject is wrong.");
	[stack popObject];
	STAssertEquals([stack count], 4u, @"-count is incorrect.");
	
	// throw some in the middle
	for (id object in testArray)
		[stack pushObject:object];
	
	STAssertEquals([stack count], 13u, @"-count is incorrect.");
	STAssertEqualObjects([stack topObject], @"I", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"H", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"G", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"F", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"E", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"D", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"C", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"B", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"A", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"F", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"G", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"H", @"-topObject is wrong.");
	[stack popObject];
	STAssertEqualObjects([stack topObject], @"I", @"-topObject is wrong.");
	[stack popObject];
	STAssertNil([stack topObject], @"-topObject should return nil.");
	STAssertEquals([stack count], 0u, @"-count is incorrect.");
}

@end
