//  CHMutableArrayHeapTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayHeap.h"

@interface CHMutableArrayHeapTest : SenTestCase {
	CHMutableArrayHeap *heap;
	NSArray *testArray;
}
@end


@implementation CHMutableArrayHeapTest

- (void) setUp {
	heap = [[CHMutableArrayHeap alloc] init];
}

- (void) tearDown {
	[heap release];
}

@end
