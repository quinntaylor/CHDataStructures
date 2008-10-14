//  ListQueueTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHListQueue.h"

@interface CHListQueueTest : SenTestCase {
	CHListQueue *queue;
	NSArray *testArray;
}
@end


@implementation CHListQueueTest

- (void) setUp {
	queue = [[CHListQueue alloc] init];
}

- (void) tearDown {
	[queue release];
}

@end
