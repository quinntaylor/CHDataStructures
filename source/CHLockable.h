/*
 CHLockable.h
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
 this library. If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <Foundation/Foundation.h>

/**
 @file CHLockable.h
 
 A simple abstract parent class for adding simple built-in locking capabilities.
 */

/**
 A simple abstract parent class for adding simple built-in locking capabilities.
 An NSLock is used internally to coordinate the operation of multiple threads of
 execution within the same application, and methods are exposed to allow clients
 to manipulate the lock in simple ways. Since not all clients will use the lock,
 it is created lazily the first time a client attempts to acquire the lock.
 
 <div class="callout">
 @b Note: Just as when using NSLock directly, calling @link #lock -lock @endlink
 twice on the same thread will lock up your thread permanently.
 </div>
 */
@interface CHLockable : NSObject <NSLocking> {
	NSLock* lock; /**< A lock for synchronizing interaction between threads. */
}

/**
 Attempts to acquire a lock and immediately returns a Boolean that indicates
 whether the attempt was successful.
 @return YES if the lock was acquired, otherwise NO.
 */
- (BOOL) tryLock;

/**
 Attempts to acquire a lock, blocking a thread's execution until the lock can be
 acquired. An application protects a critical section of code by requiring a
 thread to acquire a lock before executing the code. Once the critical section
 is past, the thread relinquishes the lock by invoking @link #unlock @endlink.
 */
- (void) lock;

/**
 Attempts to acquire a lock before a given time and returns a Boolean indicating
 whether the attempt was successful. The thread is blocked until the receiver
 acquires the lock or @a limit is reached.
 @param limit The time limit for attempting to acquire a lock.
 @return YES if the lock was acquired before @a limit, otherwise NO.
 */
- (BOOL) lockBeforeDate:(NSDate*)limit;

/**
 Relinquishes a previously acquired lock.
 <div class="callout">
 @b Warning: NSLock uses POSIX threads to implement its locking behavior. When
 sending an @link #unlock -unlock @endlink message to an NSLock object, you must
 be sure that message is sent from the same thread that sent the initial @link
 #lock -lock @endlink message. Unlocking a lock from a different thread can
 result in undefined behavior.
 </div>
 */
- (void) unlock;

@end
