//  AbstractStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Stack.h"

/**
 An abstract implementation of the Stack protocol with several convenience methods.
 Child classes must re-implement protocol methods according to their inner workings.
 */
@interface AbstractStack : NSObject <Stack>
{
	
}

#pragma mark Inherited Methods
- (void) pushObject:(id)anObject;
- (id) popObject;
- (id) topObject;
- (NSUInteger) count;
- (NSEnumerator *)objectEnumerator;
- (NSArray *) contentsAsArrayByReversingOrder:(BOOL)reverseOrder;
+ (id<Stack>) stackWithArray:(NSArray *)array byReversingOrder:(BOOL)reverseOrder;

@end
