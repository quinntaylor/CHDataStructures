/*
 CHDataStructures.framework -- CHLockableObjectTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLockableObject.h"

@interface CHLockableObject (Test)

- (id<NSLocking>) theLock;

@end

@implementation CHLockableObject (Test)

- (id<NSLocking>) theLock {
	return lock;
}

@end

#pragma mark -

@interface CHLockableObjectTest : SenTestCase {
	CHLockableObject* lockable;
	NSNumber* number;
}

@end

@implementation CHLockableObjectTest

- (void) setUp {
	lockable = [[CHLockableObject alloc] init];
}

- (void) tearDown {
	[lockable release];
}

- (void) testLockUnlock {
	STAssertNil([lockable theLock], @"The NSLock should be nil.");
	[lockable lock];
	STAssertNotNil([lockable theLock], @"The NSLock should no longer be nil.");
	STAssertNil(number, @"The ivar 'number' should be nil.");
	[NSThread detachNewThreadSelector:@selector(setNumber:)
							 toTarget:self
						   withObject:[NSNumber numberWithInt:1]];
	STAssertNil(number, @"The ivar 'number' should be nil.");
	[lockable unlock];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	[lockable lock];
	[lockable unlock];
	STAssertNotNil(number, @"The ivar 'number' should no longer be nil.");
}

- (void) testTryLock {
	STAssertNil([lockable theLock], @"The NSLock should be nil.");
	STAssertTrue([lockable tryLock], @"Should be able to acquire lock.");
	STAssertNotNil([lockable theLock], @"The NSLock should no longer be nil.");
	[lockable unlock];
	
	[NSThread detachNewThreadSelector:@selector(setNumberAndSleep:)
							 toTarget:self
						   withObject:nil];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	STAssertFalse([lockable tryLock], @"Should not be able to acquire lock.");
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	STAssertTrue([lockable tryLock], @"Should be able to acquire lock.");
	[lockable unlock];
}

- (void) testLockBeforeDate {
	STAssertNil([lockable theLock], @"The NSLock should be nil.");
	[lockable lockBeforeDate:[NSDate date]];
	STAssertNotNil([lockable theLock], @"The NSLock should no longer be nil.");
	[lockable unlock];
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
