//  ListStackTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHListStack.h"

@interface CHListStackTest : SenTestCase {
	CHListStack *stack;
	NSArray *testArray;
}
@end


@implementation CHListStackTest

- (void) setUp {
	stack = [[CHListStack alloc] init];
}

- (void) tearDown {
	[stack release];
}

@end
