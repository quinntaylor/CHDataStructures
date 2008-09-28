//  AbstractQueue.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Queue.h"

/**
 An abstract implementation of the Queue protocol with several convenience methods.
 Child classes must re-implement protocol methods according to their inner workings.
 */
@interface AbstractQueue : NSObject <Queue>
{

}

#pragma mark Inherited Methods

- (void) enqueueObject:(id)anObject;
- (id) dequeueObject;
- (id) frontObject;
- (NSUInteger) count;
- (void) removeAllObjects;
- (NSEnumerator *)objectEnumerator;
- (NSArray *) contentsAsArrayByReversingOrder:(BOOL)reverseOrder;
+ (id<Queue>) queueWithArray:(NSArray *)array byReversingOrder:(BOOL)reverseOrder;

@end
