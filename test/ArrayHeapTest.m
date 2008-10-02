//  ArrayHeapTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ArrayHeap.h"

@interface ArrayHeapTest : SenTestCase {
	ArrayHeap *heap;
	NSArray *testArray;
}
@end


@implementation ArrayHeapTest

- (void) setUp {
	heap = [[ArrayHeap alloc] init];
}

- (void) tearDown {
	[heap release];
}

@end
