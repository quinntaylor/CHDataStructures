//  ArrayQueueTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ArrayQueue.h"

@interface ArrayQueueTest : SenTestCase {
	ArrayQueue *queue;
	NSArray *testArray;
}
@end


@implementation ArrayQueueTest

- (void) setUp {
	queue = [[ArrayQueue alloc] init];
}

- (void) tearDown {
	[queue release];
}

@end
