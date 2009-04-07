/*
 CHLockableTest.m
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

#import <SenTestingKit/SenTestingKit.h>
#import "CHLockable.h"

@interface CHLockable (Test)

- (id<NSLocking>) nsLock;

@end

@implementation CHLockable (Test)

- (id<NSLocking>) nsLock {
	return lock;
}

@end

#pragma mark -

@interface CHLockableTest : SenTestCase {
	CHLockable* lockable;
	NSNumber* number;
}

@end

@implementation CHLockableTest

- (void) setUp {
	lockable = [[CHLockable alloc] init];
}

- (void) tearDown {
	[lockable release];
}

- (void) testLockUnlock {
	STAssertNil([lockable nsLock], @"The NSLock should be nil.");
	[lockable lock];
	STAssertNotNil([lockable nsLock], @"The NSLock should no longer be nil.");
	STAssertNil(number, @"The ivar 'number' should be nil.");
	[NSThread detachNewThreadSelector:@selector(setNumber:)
							 toTarget:self
						   withObject:[NSNumber numberWithInt:1]];
	STAssertNil(number, @"The ivar 'number' should be nil.");
	[lockable unlock];
	[NSThread sleepForTimeInterval:0.1];
	[lockable lock];
	[lockable unlock];
	STAssertNotNil(number, @"The ivar 'number' should no longer be nil.");
}

- (void) testTryLock {
	STAssertNil([lockable nsLock], @"The NSLock should be nil.");
	STAssertTrue([lockable tryLock], @"Should be able to acquire lock.");
	STAssertNotNil([lockable nsLock], @"The NSLock should no longer be nil.");
	[lockable unlock];
	
	[NSThread detachNewThreadSelector:@selector(setNumberAndSleep:)
							 toTarget:self
						   withObject:nil];
	[NSThread sleepForTimeInterval:0.1];
	STAssertFalse([lockable tryLock], @"Should not be able to acquire lock.");
	[NSThread sleepForTimeInterval:0.2];
	STAssertTrue([lockable tryLock], @"Should be able to acquire lock.");
}

- (void) testLockBeforeDate {
	STAssertNil([lockable nsLock], @"The NSLock should be nil.");
	[lockable lockBeforeDate:[NSDate date]];
	STAssertNotNil([lockable nsLock], @"The NSLock should no longer be nil.");
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
	[NSThread sleepForTimeInterval:0.2];
	[lockable unlock];
}

@end
