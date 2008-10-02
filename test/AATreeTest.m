//  AATreeTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "AATree.h"

@interface AATreeTest : SenTestCase {
	AATree *tree;
	NSArray *testArray;
}
@end


@implementation AATreeTest

- (void) setUp {
	tree = [[AATree alloc] init];
	testArray = [NSArray arrayWithObjects:
				 @"F", @"B", @"A", @"D", @"C", @"E", @"G", @"I", @"H", nil];
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
	[tree release];
}

@end
