//  CHMutableArrayDequeTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayDeque.h"

@interface CHMutableArrayDequeTest : SenTestCase {
	CHMutableArrayDeque *deque;
	NSArray *testArray;
}
@end


@implementation CHMutableArrayDequeTest

- (void) setUp {
	deque = [[CHMutableArrayDeque alloc] init];
}

- (void) tearDown {
	[deque release];
}

@end
