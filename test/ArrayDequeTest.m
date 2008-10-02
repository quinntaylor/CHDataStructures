//  ArrayDequeTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ArrayDeque.h"

@interface ArrayDequeTest : SenTestCase {
	ArrayDeque *deque;
	NSArray *testArray;
}
@end


@implementation ArrayDequeTest

- (void) setUp {
	deque = [[ArrayDeque alloc] init];
}

- (void) tearDown {
	[deque release];
}

@end
