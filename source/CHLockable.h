/*
 CHDataStructures.framework -- CHLockable.h
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHLockable.h
 
 A simple protocol for adding built-in locking capabilities.
 */

/**
 A simple protocol for adding simple built-in locking capabilities. The methods are intended to be use a lock that is an instance variable of the implementing class. The protocol  adopts the NSLocking protocol (which includes the \link NSLocking#lock -lock\endlink and \link NSLocking#unlock -unlock\endlink methods) as a convenience for users that may wish to statically type instances of this class or its children as @c id<NSLocking> as a hint for compile-time type checking.
 */
@protocol CHLockable <NSLocking>

/** @name Locks and Synchronization */
// @{

/**
 Attempts to acquire a lock and immediately returns whether the attempt was successful.
 
 @return @c YES if the lock was acquired, otherwise @c NO.
 
 @see CHLockable
 */
- (BOOL) tryLock;

/**
 Attempts to acquire a lock, blocking a thread's execution until the lock can be acquired. An application protects a critical section of code by requiring a thread to acquire a lock before executing the code. Once the critical section is past, the thread relinquishes the lock by invoking #unlock.

 @warning Calling \link NSLocking#lock -lock\endlink on NSLock twice from the same thread will lock the thread permanently. Use NSRecursiveLock for recursive locks.
 
 @see CHLockable
 @see NSLocking protocol
 */
- (void) lock;

/**
 Attempts to acquire a lock before a given time and returns whether the attempt was successful. The thread is blocked until the receiver acquires the lock or @a limit is reached.
 
 @param limit The time limit for attempting to acquire a lock.
 @return @c YES if the lock was acquired before @a limit, otherwise @c NO.
 
 @see CHLockable
 */
- (BOOL) lockBeforeDate:(NSDate*)limit;

/**
 Relinquishes a previously acquired lock.
 
 @warning NSLock uses POSIX threads to implement its locking behavior. When sending an \link NSLocking#unlock -unlock\endlink message to an NSLock object, you must be sure that message is sent from the same thread that sent the initial \link NSLocking#lock -lock\endlink message. Unlocking a lock from a different thread can cause undefined behavior.
 
 @see CHLockable
 @see NSLocking protocol
 */
- (void) unlock;

// @}

@end
