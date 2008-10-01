//  UnbalancedTreeTest.m
//  DataStructures.framework

#import "UnbalancedTreeTest.h"

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

- (void) testAddObjectsFromEnumerator {
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
	[tree addObjectsFromEnumerator:[testArray objectEnumerator]];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
}

- (void) testTraversalInOrder {
	[tree addObjectsFromEnumerator:[testArray objectEnumerator]];
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
	[tree addObjectsFromEnumerator:[testArray objectEnumerator]];
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
	[tree addObjectsFromEnumerator:[testArray objectEnumerator]];
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
	[tree addObjectsFromEnumerator:[testArray objectEnumerator]];
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
	[tree addObjectsFromEnumerator:[testArray objectEnumerator]];
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

@end
