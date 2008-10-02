//  ListStackTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ListStack.h"

@interface ListStackTest : SenTestCase {
	ListStack *stack;
	NSArray *testArray;
}
@end


@implementation ListStackTest

- (void) setUp {
	stack = [[ListStack alloc] init];
}

- (void) tearDown {
	[stack release];
}

@end
