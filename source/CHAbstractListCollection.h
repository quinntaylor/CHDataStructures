//
//  CHAbstractListCollection.h
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <CHDataStructures/CHLinkedList.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @file CHAbstractListCollection.h
 An abstract class which implements common behaviors of list-based collections.
 */

/**
 An abstract class which implements common behaviors of list-based collections. This class has a single instance variable on which all the implemented methods act, and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSFastEnumeration
 */
@interface CHAbstractListCollection<__covariant ObjectType> : NSObject <NSCoding, NSCopying, NSFastEnumeration>
{
	id<CHLinkedList> list; // List used for storing contents of collection.
}

- (instancetype)initWithArray:(NSArray<ObjectType> *)anArray NS_DESIGNATED_INITIALIZER;
- (NSArray<ObjectType> *)allObjects;
- (BOOL)containsObject:(ObjectType)anObject;
- (BOOL)containsObjectIdenticalTo:(ObjectType)anObject;
- (NSUInteger)count;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (NSUInteger)indexOfObject:(ObjectType)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(ObjectType)anObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSEnumerator *)objectEnumerator;
- (NSArray<ObjectType> *)objectsAtIndexes:(NSIndexSet *)indexes;
- (void)removeAllObjects;
- (void)removeObject:(ObjectType)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectIdenticalTo:(ObjectType)anObject;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;

@end

NS_ASSUME_NONNULL_END
