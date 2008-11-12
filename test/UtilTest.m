/*
 UtilTest.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
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
#import "Util.h"

@interface UtilTest : SenTestCase
{
	Class aClass;
	SEL aMethod;
	NSMutableString *reason;
	BOOL raisedException;
}

@end

@implementation UtilTest

- (void) setUp {
	aClass = [NSObject class];
	aMethod = @selector(foo:bar:);
	reason = [NSMutableString stringWithString:@"[NSObject foo:bar:] -- "];
	raisedException = NO;
}

- (void) testIndexOutOfRangeException {
	@try {
		CHIndexOutOfRangeException(aClass, aMethod, 4, 4);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSRangeException,
							 @"Incorrect exception name.");
		[reason appendString:@"Index (4) out of range (0-3)."];
		STAssertEqualObjects([e reason], reason, @"Incorrect exception reason.");
	}
	STAssertTrue(raisedException, @"Should have raised an exception.");
}

- (void) testInvalidArgumentException {
	@try {
		CHInvalidArgumentException(aClass, aMethod, @"Some silly reason.");
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSInternalInconsistencyException,
							 @"Incorrect exception name.");
		[reason appendString:@"Some silly reason."];
		STAssertEqualObjects([e reason], reason, @"Incorrect exception reason.");
	}
	STAssertTrue(raisedException, @"Should have raised an exception.");
}

- (void) testNilArgumentException {
	@try {
		CHNilArgumentException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSInternalInconsistencyException,
							 @"Incorrect exception name.");
		[reason appendString:@"Invalid nil argument."];
		STAssertEqualObjects([e reason], reason, @"Incorrect exception reason.");
	}
	STAssertTrue(raisedException, @"Should have raised an exception.");
}

- (void) testMutatedCollectionException {
	@try {
		CHMutatedCollectionException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSGenericException,
							 @"Incorrect exception name.");
		[reason appendString:@"Collection was mutated during enumeration."];
		STAssertEqualObjects([e reason], reason, @"Incorrect exception reason.");
	}
	STAssertTrue(raisedException, @"Should have raised an exception.");
}

- (void) testUnsupportedOperationException {
	@try {
		CHUnsupportedOperationException(aClass, aMethod);
	}
	@catch (NSException * e) {
		raisedException = YES;
		STAssertEqualObjects([e name], NSInternalInconsistencyException,
							 @"Incorrect exception name.");
		[reason appendString:@"Unsupported operation."];
		STAssertEqualObjects([e reason], reason, @"Incorrect exception reason.");
	}
	STAssertTrue(raisedException, @"Should have raised an exception.");
}

- (void) testCHQuietLog {
	// Can't think of a way to verify stdout, so I'll just exercise all the code
	CHQuietLog(@"Hello, world!");
	CHQuietLog(@"Hello, world! I accept specifiers: %@ instance at 0x%x.",
			   [self class], self);
	CHQuietLog(nil);
}

@end
