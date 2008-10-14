//  ArrayStackTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayStack.h"

@interface CHMutableArrayStackTest : SenTestCase {
	CHMutableArrayStack *stack;
	NSArray *testArray;
}
@end


@implementation CHMutableArrayStackTest

- (void) setUp {
	stack = [[CHMutableArrayStack alloc] init];
}

- (void) tearDown {
	[stack release];
}

@end
