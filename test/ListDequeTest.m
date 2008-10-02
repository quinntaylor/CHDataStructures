//  ListDequeTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ListDeque.h"

@interface ListDequeTest : SenTestCase {
	ListDeque *deque;
	NSArray *testArray;
}
@end


@implementation ListDequeTest

- (void) setUp {
	deque = [[ListDeque alloc] init];
}

- (void) tearDown {
	[deque release];
}

@end
