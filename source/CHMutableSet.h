//
//  CHMutableSet.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

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
@interface CHMutableSet<__covariant ObjectType> : NSMutableSet {
	CFMutableSetRef set; // A Core Foundation set.
}

- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER; // Inherited from NSMutableSet

@end
