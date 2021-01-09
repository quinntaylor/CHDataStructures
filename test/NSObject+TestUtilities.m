//
//  NSObject+TestUtilities.m
//  CHDataStructures
//
//  Copyright © 2021, Quinn Taylor
//

#import "NSObject+TestUtilities.h"

@implementation NSObject (TestUtilites)

- (instancetype)copyUsingNSCoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	return [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
#pragma clang diagnostic pop
}

@end
