//
//  CHMutableDictionary.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHUtil.h>

HIDDEN CFMutableDictionaryRef CHDictionaryCreateMutable(NSUInteger initialCapacity) CF_RETURNS_RETAINED;

/**
 @file CHMutableDictionary.h
 
 A mutable dictionary class.
 */

/**
 A mutable dictionary class.
 
 A CFMutableDictionaryRef is used internally to store the key-value pairs. Subclasses may choose to add other instance variables to enable a specific ordering of keys, override methods to modify behavior, and add methods to extend existing behaviors. However, all subclasses should behave like a standard Cocoa dictionary as much as possible, and document clearly when they do not.
 
 @note Any method inherited from NSDictionary or NSMutableDictionary is supported by this class and its children. Please see the documentation for those classes for details.
 
 @todo Implement @c -copy and @c -mutableCopy differently (so users can actually obtain an immutable copy) and make mutation methods aware of immutability?
 */
@interface CHMutableDictionary : NSMutableDictionary {
	CFMutableDictionaryRef dictionary; // A Core Foundation dictionary.
}

- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER; // Inherited from NSMutableDictionary

@end
