/*
 CHDataStructures.framework -- CHAbstractListCollection.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHLinkedList.h>

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
@interface CHAbstractListCollection : NSObject <NSCoding, NSCopying, NSFastEnumeration>
{
	id<CHLinkedList> list; // List used for storing contents of collection.
}

- (instancetype)initWithArray:(NSArray *)anArray NS_DESIGNATED_INITIALIZER;
- (NSArray *)allObjects;
- (BOOL)containsObject:(id)anObject;
- (BOOL)containsObjectIdenticalTo:(id)anObject;
- (NSUInteger)count;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSEnumerator *)objectEnumerator;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectIdenticalTo:(id)anObject;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end
