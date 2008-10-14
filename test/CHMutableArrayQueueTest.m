//  CHMutableArrayQueueTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayQueue.h"

@interface CHMutableArrayQueueTest : SenTestCase {
	CHMutableArrayQueue *queue;
	NSArray *testArray;
}
@end


@implementation CHMutableArrayQueueTest

- (void) setUp {
	queue = [[CHMutableArrayQueue alloc] init];
}

- (void) tearDown {
	[queue release];
}

@end
