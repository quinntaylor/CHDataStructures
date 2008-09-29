//  ArrayDeque.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Deque.h"

@interface ArrayDeque : NSObject <Deque> {
	NSMutableArray *array;
}

#pragma mark Method Implementations

- (void) addObjectToFront:(id)anObject;
- (void) addObjectToBack:(id)anObject;
- (id) firstObject;
- (id) lastObject;
- (NSArray*) allObjects;

- (void) removeFirstObject;
- (void) removeLastObject;
- (void) removeAllObjects;

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) count;

@end
