//  CHRedBlackTreeTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHRedBlackTree.h"

@interface CHRedBlackTreeTest : SenTestCase {
	CHRedBlackTree *tree;
	NSArray *testArray;
}
@end


@implementation CHRedBlackTreeTest

- (void) setUp {
	tree = [[CHRedBlackTree alloc] init];
	testArray = [NSArray arrayWithObjects:
				 @"F", @"B", @"A", @"D", @"C", @"E", @"G", @"I", @"H", nil];
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
	[tree release];
}

@end
