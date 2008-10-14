//  ArrayDequeTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHArrayDeque.h"

@interface CHArrayDequeTest : SenTestCase {
	CHArrayDeque *deque;
	NSArray *testArray;
}
@end


@implementation CHArrayDequeTest

- (void) setUp {
	deque = [[CHArrayDeque alloc] init];
}

- (void) tearDown {
	[deque release];
}

@end
