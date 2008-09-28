//  AbstractQueue.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Queue.h"

@interface AbstractQueue : NSObject <Queue>
{

}

#pragma mark Inherited Methods

- (void) enqueueObject:(id)anObject;
- (id) dequeueObject;
- (id) frontObject;
- (NSUInteger) count;
- (void) removeAllObjects;
+ (id<Queue>) queueWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
