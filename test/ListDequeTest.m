//  ListDequeTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHListDeque.h"

@interface CHListDequeTest : SenTestCase {
	CHListDeque *deque;
	NSArray *testArray;
}
@end


@implementation CHListDequeTest

- (void) setUp {
	deque = [[CHListDeque alloc] init];
}

- (void) tearDown {
	[deque release];
}

@end
