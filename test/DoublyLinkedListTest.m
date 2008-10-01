//  DoublyLinkedListTest.m
//  DataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "DoublyLinkedList.h"

@interface DoublyLinkedListTest : SenTestCase {
	DoublyLinkedList *dlist;
	NSArray *testArray;
}
@end


@implementation DoublyLinkedListTest

- (void) setUp {
    dlist = [[DoublyLinkedList alloc] init];
	testArray = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
}

- (void) tearDown {
    [dlist release];
}

@end
