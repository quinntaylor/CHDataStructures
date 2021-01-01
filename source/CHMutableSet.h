/*
 CHDataStructures.framework -- CHMutableSet.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHUtil.h>

/**
 @file CHMutableSet.h
 
 A mutable set class.
 */

/**
 A mutable set class.

 A CFMutableSetRef is used internally to store the key-value pairs. Subclasses may choose to add other instance variables to enable a specific ordering of keys, override methods to modify behavior, and add methods to extend existing behaviors. However, all subclasses should behave like a standard Cocoa dictionary as much as possible, and document clearly when they do not.
 
 @note Any method inherited from NSSet or NSMutableSet is supported by this class and its children. Please see the documentation for those classes for details.
 */ 
@interface CHMutableSet : NSMutableSet {
	CFMutableSetRef set; // A Core Foundation set.
}

- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;

- (void)addObject:(id)anObject;
- (id)anyObject;
- (BOOL)containsObject:(id)anObject;
- (NSUInteger)count;
- (id)member:(id)anObject;
- (NSEnumerator *)objectEnumerator;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject;

@end
