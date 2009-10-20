/*
 CHDataStructures.framework -- CHLockableTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLockableDictionary.h"
#import "CHLockableObject.h"
#import "CHLockableSet.h"

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

@interface CHLockableTest : SenTestCase {
	id lockable;
	NSArray* lockableClasses;
	NSEnumerator *classes;
	Class aClass;
	NSNumber* number;
}
@end

@implementation CHLockableTest

- (void) setUp {
	lockableClasses = [NSArray arrayWithObjects:[CHLockableDictionary class],
	                                            [CHLockableObject class],
	                                            [CHLockableSet class],
											    nil];
}

- (void) testLockUnlock {
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		STAssertNil([lockable theLock], @"The NSLock should be nil.");
		[lockable lock];
		STAssertNotNil([lockable theLock], @"The NSLock should no longer be nil.");
		number = nil;
		[NSThread detachNewThreadSelector:@selector(setNumber:)
								 toTarget:self
							   withObject:[NSNumber numberWithInt:1]];
		STAssertNil(number, @"The ivar 'number' should still be nil.");
		[lockable unlock];
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		[lockable lock];
		STAssertNotNil(number, @"The ivar 'number' should no longer be nil.");
		[lockable unlock];
	}
}

- (void) testTryLock {
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		STAssertNil([lockable theLock], @"The NSLock should be nil.");
		STAssertTrue([lockable tryLock], @"Should be able to acquire lock.");
		STAssertNotNil([lockable theLock], @"The NSLock should be non-nil.");
		// Try to acquire lock when it's already locked (should fail instantly)
		STAssertFalse([lockable tryLock], @"Should not be able to acquire lock.");
		STAssertNotNil([lockable theLock], @"The NSLock should still be non-nil.");
		[lockable unlock];
	}
}

- (void) testLockBeforeDate {
	classes = [lockableClasses objectEnumerator];
	while (aClass = [classes nextObject]) {
		lockable = [[[aClass alloc] init] autorelease];
		STAssertNil([lockable theLock], @"The NSLock should be nil.");
		[lockable lockBeforeDate:[NSDate date]];
		STAssertNotNil([lockable theLock], @"The NSLock should no longer be nil.");
		[lockable unlock];
	}
}

#pragma mark Multi-thread methods

- (void) setNumber:(NSNumber*)aNumber {
	[lockable lock];
	number = aNumber;
	[lockable unlock];
}
	
- (void) setNumberAndSleep:(NSNumber*)aNumber {
	[lockable lock];
	number = aNumber;
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	[lockable unlock];
}

@end
