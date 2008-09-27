//  AbstractStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Stack.h"

@interface AbstractStack : NSObject <Stack>
{
	
}

#pragma mark Inherited Methods
- (void) push:(id)anObject;
- (id) pop;
- (id) top;
- (NSUInteger) count;

+ (id<Stack>) stackWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
