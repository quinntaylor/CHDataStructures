/*
 UtilTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
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
