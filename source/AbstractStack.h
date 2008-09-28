//  AbstractStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Stack.h"

@interface AbstractStack : NSObject <Stack>
{
	
}

#pragma mark Inherited Methods
- (void) pushObject:(id)anObject;
- (id) popObject;
- (id) topObject;
- (NSUInteger) count;

+ (id<Stack>) stackWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
