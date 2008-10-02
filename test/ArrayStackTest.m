//  ArrayStackTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "ArrayStack.h"

@interface ArrayStackTest : SenTestCase {
	ArrayStack *stack;
	NSArray *testArray;
}
@end


@implementation ArrayStackTest

- (void) setUp {
	stack = [[ArrayStack alloc] init];
}

- (void) tearDown {
	[stack release];
}

@end
