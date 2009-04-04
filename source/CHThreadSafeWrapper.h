/*
 CHThreadSafeWrapper.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2009, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <Foundation/Foundation.h>

/**
 @file CHThreadSafeWrapper.h
 
 A simple wrapper class for adding thread-safe protection to any Cocoa object.
 */

/**
 A simple wrapper class for adding thread-safe protection to any Cocoa object.
 Accepts and retains an object, then uses NSLock to interpose a critical section
 block around any message sent to the wrapper class. Messages are sent to the
 initialized wrapper just as you would the underlying object. (Any messages that
 @a object responds to will be forwarded to it.)
 */
@interface CHThreadSafeWrapper : NSObject {
	id object;    /**< The object whose messages are protected using @a lock. */
	NSLock* lock; /**< A lock used for protecting message sends to @a object. */
}

/**
 Create a new thread-safe wrapper for a given object.
 @param anObject The object to protect in a critical section using an NSLock.
 @throw NSInternalInconsistencyException If @a anObject is nil.
 */
- (id) initWithObject:(id)anObject;

/**
 Returns the object protected by this thread-safe wrapper.
 @return The object protected by this thread-safe wrapper.
 */
- (id) object;

@end
