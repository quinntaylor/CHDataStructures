/*
 CHDataStructures.framework -- CHLockableTest.m
 
 Copyright (c) 2009-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHCircularBuffer.h"
#import "CHLockableDictionary.h"
#import "CHLockableObject.h"
#import "CHLockableSet.h"

@interface CHCircularBuffer (Test)
- (id<NSLocking>) theLock;
@end

@implementation CHCircularBuffer (Test)
- (id<NSLocking>) theLock {
	return lock;
}
@end

#pragma mark -

@interface CHLockableDictionary (Test)
- (id<NSLocking>) theLock;
@end

@implementation CHLockableDictionary (Test)
- (id<NSLocking>) theLock {
	return lock;
}
@end

#pragma mark -

@interface CHLockableObject (Test)
- (id<NSLocking>) theLock;
@end

@implementation CHLockableObject (Test)
- (id<NSLocking>) theLock {
	return lock;
}
@end

#pragma mark -

@interface CHLockableSet (Test)
- (id<NSLocking>) theLock;
@end

@implementation CHLockableSet (Test)
- (id<NSLocking>) theLock {
	return lock;
}
@end

#pragma mark -

static NSNumber* number;

@interface CHLockableTest : SenTestCase {
	id lockable;
	NSArray* lockableClasses;
	NSEnumerator *classes;
	Class aClass;
}
@end

@implementation CHLockableTest

- (void) setUp {
	lockableClasses = [NSArray arrayWithObjects:[CHCircularBuffer class],
	                                            [CHLockableDictionary class],
	                                            [CHLockableObject class],
	                                            [CHLockableSet class],
											    nil];
}

- (void) testCreateLock {
	// Note: This test uses -performSelector: to avoid compilation warnings.
	// However, the -createLock method actually exists in CHLockable classes.
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		// Test that the lock is nil after initialization
		STAssertNil([lockable theLock], nil);
		// Create the lock and test that it is non-nil
		[lockable performSelector:@selector(createLock)];
		STAssertNotNil([lockable theLock], nil);
		// Tests that the lock isn't created more than once
		id<NSLocking> theLock = [lockable theLock];
		[lockable performSelector:@selector(createLock)];
		STAssertEquals([lockable theLock], theLock, nil);
	}
}

- (void) testLockUnlock {
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		// Lock should be nil, created dynamically by calling -lock
		STAssertNil([lockable theLock], nil);
		[lockable lock];
		STAssertNotNil([lockable theLock], nil);
		// While locked, detach a thread to modify an instance variable
		number = nil;
		[NSThread detachNewThreadSelector:@selector(setNumber:)
								 toTarget:self
							   withObject:[NSNumber numberWithInt:1]];
		// The variable should be nil, since -setNumber: blocks on the lock
		STAssertNil(number, nil);
		// Unlocking and sleeping allows -setNumber: to lock/modify/unlock
		[lockable unlock];
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		// The variable should be set after sleeping
		[lockable lock];
		STAssertNotNil(number, nil);
		// Unlock before the instance is deallocated
		[lockable unlock];
	}
}

- (void) testTryLock {
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		// Lock should be nil, created dynamically by calling -tryLock
		STAssertNil([lockable theLock], nil);
		STAssertTrue([lockable tryLock], nil);
		STAssertNotNil([lockable theLock], nil);
		// Acquiring the lock when it's already locked should fail instantly.
		STAssertFalse([lockable tryLock], nil);
		STAssertNotNil([lockable theLock], nil);
		// Release the lock and reaquire it
		[lockable unlock];
		STAssertTrue([lockable tryLock], nil);
		// Unlock before the instance is deallocated
		[lockable unlock];
	}
}

- (void) testLockBeforeDate {
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		// Lock should be nil, created dynamically by calling -lockBeforeDate:
		STAssertNil([lockable theLock], nil);
		STAssertTrue([lockable lockBeforeDate:[NSDate date]], nil);
		STAssertNotNil([lockable theLock], nil);
		// Acquiring the lock when it's already locked should fail instantly.
		STAssertFalse([lockable tryLock], nil);
		// Release the lock and reaquire it
		[lockable unlock];
		STAssertTrue([lockable lockBeforeDate:[NSDate date]], nil);
		// Unlock before the instance is deallocated
		[lockable unlock];
	}
}

#pragma mark Multi-thread methods

- (void) setNumber:(NSNumber*)aNumber {
	[lockable lock]; // Blocks until lock can be acquired.
	number = aNumber;
	[lockable unlock];
}
	
@end
