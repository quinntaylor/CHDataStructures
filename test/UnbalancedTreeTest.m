//  UnbalancedTreeTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "UnbalancedTree.h"

@interface UnbalancedTreeTest : SenTestCase {
	UnbalancedTree *tree;
	NSArray *testArray;
	NSEnumerator *e;
}
@end


@implementation UnbalancedTreeTest

- (void) setUp {
    tree = [[UnbalancedTree alloc] init];
	testArray = [NSArray arrayWithObjects:
				 @"F", @"B", @"A", @"D", @"C", @"E", @"G", @"I", @"H", nil];
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
    [tree release];
}

- (void) testAddObject {
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
	for (id object in testArray)
		[tree addObject:object];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
}

- (void) testTraversalInOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder];
	
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalReverseOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder];

	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalPreOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder];

	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalPostOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder];

	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}

- (void) testTraversalLevelOrder {
	for (id object in testArray)
		[tree addObject:object];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];

	STAssertEqualObjects([e nextObject], @"F", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"B", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"G", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"A", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"D", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"I", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"C", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"E", @"-nextObject is wrong.");
	STAssertEqualObjects([e nextObject], @"H", @"-nextObject is wrong.");
	STAssertNil([e nextObject], @"-nextObject should return nil.");
}
/*
- (void) testRemoveObject {
	for (id object in testArray)
		[tree addObject:object];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	[tree removeObject:@"A"];
	STAssertEquals([tree count], 8u, @"-count is incorrect.");	
}

- (void) testRemoveAllObjects {
	for (id object in testArray)
		[tree addObject:object];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	[tree removeAllObjects];
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
}
*/
@end
