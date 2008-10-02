//  RedBlackTreeTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "RedBlackTree.h"

@interface RedBlackTreeTest : SenTestCase {
	RedBlackTree *tree;
	NSArray *testArray;
}
@end


@implementation RedBlackTreeTest

- (void) setUp {
	tree = [[RedBlackTree alloc] init];
	testArray = [NSArray arrayWithObjects:
				 @"F", @"B", @"A", @"D", @"C", @"E", @"G", @"I", @"H", nil];
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
	[tree release];
}

@end
