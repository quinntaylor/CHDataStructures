//  ArrayQueueTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHArrayQueue.h"

@interface CHArrayQueueTest : SenTestCase {
	CHArrayQueue *queue;
	NSArray *testArray;
}
@end


@implementation CHArrayQueueTest

- (void) setUp {
	queue = [[CHArrayQueue alloc] init];
}

- (void) tearDown {
	[queue release];
}

@end
