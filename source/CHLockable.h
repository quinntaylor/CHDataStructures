/*
 CHDataStructures.framework -- CHLockable.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>

/**
 @file CHLockable.h
 
 A simple abstract parent class for adding simple built-in locking capabilities.
 */

/**
 A simple abstract parent class for adding simple built-in locking capabilities. An NSLock is used internally to coordinate the operation of multiple threads of execution within the same application, and methods are exposed to allow clients to manipulate the lock in simple ways. Since not all clients will use the lock, it is created lazily the first time a client attempts to acquire the lock.
 */
@interface CHLockable : NSObject <NSLocking>
{
	NSLock* lock; /**< A lock for synchronizing interaction between threads. */
}

/**
 Attempts to acquire a lock and immediately returns a Boolean that indicates whether the attempt was successful.
 
 @return @c YES if the lock was acquired, otherwise @c NO.
 
 @see CHLockable
 */
- (BOOL) tryLock;

/**
 Attempts to acquire a lock, blocking a thread's execution until the lock can be acquired. An application protects a critical section of code by requiring a thread to acquire a lock before executing the code. Once the critical section is past, the thread relinquishes the lock by invoking @link #unlock @endlink.

 <div class="warning">
 @b Warning: Calling \link NSLocking#lock -lock\endlink on NSLock twice from the same thread will lock the thread permanently. Use NSRecursiveLock for recursive locks. (This would require using a separate lock external to this class.)
 </div>
 
 @see CHLockable
 */
- (void) lock;

/**
 Attempts to acquire a lock before a given time and returns a Boolean indicating whether the attempt was successful. The thread is blocked until the receiver acquires the lock or @a limit is reached.
 
 @param limit The time limit for attempting to acquire a lock.
 @return @c YES if the lock was acquired before @a limit, otherwise @c NO.
 
 @see CHLockable
 */
- (BOOL) lockBeforeDate:(NSDate*)limit;

/**
 Relinquishes a previously acquired lock.
 
 <div class="warning">
 @b Warning: NSLock uses POSIX threads to implement its locking behavior. When sending an @link #unlock -unlock @endlink message to an NSLock object, you must be sure that message is sent from the same thread that sent the initial #lock message. Unlocking a lock from a different thread can cause undefined behavior.
 </div>
 
 @see CHLockable
 */
- (void) unlock;

@end
