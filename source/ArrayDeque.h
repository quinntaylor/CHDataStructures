//  ArrayDeque.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Deque.h"

/**
 A fairly basic Deque implemented using an NSMutableArray.
 See the protocol definition for Deque to understand the programming contract.
 */
@interface ArrayDeque : NSObject <Deque> {
	NSMutableArray *array;
}

#pragma mark Method Implementations

- (void) prependObject:(id)anObject;
- (void) prependObjectsFromEnumerator:(NSEnumerator*)enumerator;
- (void) appendObject:(id)anObject;
- (void) appendObjectsFromEnumerator:(NSEnumerator*)enumerator;
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
