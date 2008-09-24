//
//  Test.m
//  DataStructures

#import <Foundation/Foundation.h>

#import "UnbalancedTree.h"
#import "RedBlackTree.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    id<Tree> tree = [[UnbalancedTree alloc] init];
	[tree addObject:@"abc"];
	[tree addObject:@"xyz"];
	[tree addObject:@"Hello"];
	[tree addObject:@"World"];
	
	[tree findObject:@"xyz"];
	
	[tree removeAllObjects];
	
	
    [pool drain];
    return 0;
}
