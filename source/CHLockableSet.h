/*
 CHDataStructures.framework -- CHLockableSet.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockable.h"

/**
 @file CHLockableSet.h
 
 A mutable set class with simple built-in locking capabilities.
 */

/**
 A mutable set class with simple built-in locking capabilities.

 Since this class extends NSMutableSet, it or any of its children may be used anywhere an NSSet or NSMutableSet is required. It is designed to behave virtually identically to a standard NSMutableSet, but with the addition of built-in locking.
 
 An NSLock is used internally to coordinate the operation of multiple threads of execution within the same application, and methods are exposed to allow clients to manipulate the lock in simple ways. Since not all clients will use the lock, it is created lazily the first time a client attempts to acquire the lock.
 
 A CFMutableSetRef is used internally to store the key-value pairs. Subclasses may choose to add other instance variables to enable a specific ordering of keys, override methods to modify behavior, and add methods to extend existing behaviors. However, all subclasses should behave like a standard Cocoa dictionary as much as possible, and document clearly when they do not.
 
 @note Any method inherited from NSSet or NSMutableSet is supported by this class and its children. Please see the documentation for those classes for details.
 */ 
@interface CHLockableSet : NSMutableSet <CHLockable> {
	NSLock* lock; // A lock for synchronizing interaction between threads.
	__strong CFMutableSetRef set; // A Core Foundation set.
}

- (id) initWithCapacity:(NSUInteger)numItems;

- (void) addObject:(id)anObject;
- (id) anyObject;
- (BOOL) containsObject:(id)anObject;
- (NSUInteger) count;
- (id) member:(id)anObject;
- (NSEnumerator*) objectEnumerator;
- (void) removeAllObjects;
- (void) removeObject:(id)anObject;

@end
