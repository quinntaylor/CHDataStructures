//  ListQueueTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ListQueue.h"

@interface ListQueueTest : SenTestCase {
	ListQueue *queue;
	NSArray *testArray;
}
@end


@implementation ListQueueTest

- (void) setUp {
	queue = [[ListQueue alloc] init];
}

- (void) tearDown {
	[queue release];
}

@end
