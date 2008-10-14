//  ArrayHeapTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHArrayHeap.h"

@interface CHArrayHeapTest : SenTestCase {
	CHArrayHeap *heap;
	NSArray *testArray;
}
@end


@implementation CHArrayHeapTest

- (void) setUp {
	heap = [[CHArrayHeap alloc] init];
}

- (void) tearDown {
	[heap release];
}

@end
