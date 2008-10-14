//  ArrayStackTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHArrayStack.h"

@interface CHArrayStackTest : SenTestCase {
	CHArrayStack *stack;
	NSArray *testArray;
}
@end


@implementation CHArrayStackTest

- (void) setUp {
	stack = [[CHArrayStack alloc] init];
}

- (void) tearDown {
	[stack release];
}

@end
