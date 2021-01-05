//
//  CHUtilTest.m
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <XCTest/XCTest.h>
#import <CHDataStructures/CHUtil.h>

@interface CHUtilTest : XCTestCase

@end

@implementation CHUtilTest

#define expectedReason(message) \
([NSString stringWithFormat:@"%s -- %@", __PRETTY_FUNCTION__, message])

- (void)testCollectionsAreEqual {
	NSArray *array = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:array forKeys:array];
	NSSet *set = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	
	XCTAssertTrue(CHCollectionsAreEqual(nil, nil));
	
	XCTAssertTrue(CHCollectionsAreEqual(array, array));
	XCTAssertTrue(CHCollectionsAreEqual(dict, dict));
	XCTAssertTrue(CHCollectionsAreEqual(set, set));

	XCTAssertTrue(CHCollectionsAreEqual(array, [array copy]));
	XCTAssertTrue(CHCollectionsAreEqual(dict, [dict copy]));
	XCTAssertTrue(CHCollectionsAreEqual(set, [set copy]));
	
	XCTAssertFalse(CHCollectionsAreEqual(array, nil));
	XCTAssertFalse(CHCollectionsAreEqual(dict, nil));
	XCTAssertFalse(CHCollectionsAreEqual(set, nil));

	id obj = [NSString string];
	XCTAssertThrowsSpecificNamed(CHCollectionsAreEqual(array, obj), NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed(CHCollectionsAreEqual(dict, obj), NSException, NSInvalidArgumentException);
	XCTAssertThrowsSpecificNamed(CHCollectionsAreEqual(set, obj), NSException, NSInvalidArgumentException);
}

- (void)testIndexOutOfRangeException {
	BOOL raisedException;
	@try {
		int idx = 5;
		int count = 4;
		CHRaiseIndexOutOfRangeExceptionIf(idx, >, count);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSRangeException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Index out of range: idx (5) > count (4)"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testInvalidArgumentException {
	BOOL raisedException;
	@try {
		CHRaiseInvalidArgumentException(@"Some silly reason.");
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInvalidArgumentException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Some silly reason."));
	}
	XCTAssertTrue(raisedException);
}

- (void)testNilArgumentException {
	BOOL raisedException;
	id object = nil;
	@try {
		CHRaiseInvalidArgumentExceptionIfNil(object);
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInvalidArgumentException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Invalid nil value: object"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testMutatedCollectionException {
	BOOL raisedException;
	@try {
		CHRaiseMutatedCollectionException();
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSGenericException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Collection was mutated during enumeration"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testUnsupportedOperationException {
	BOOL raisedException;
	@try {
		CHRaiseUnsupportedOperationException();
	}
	@catch (NSException * e) {
		raisedException = YES;
		XCTAssertEqualObjects([e name], NSInternalInconsistencyException);
		XCTAssertEqualObjects([e reason], expectedReason(@"Unsupported operation"));
	}
	XCTAssertTrue(raisedException);
}

- (void)testCHQuietLog {
	// Can't think of a way to verify stdout, so I'll just exercise all the code
	CHQuietLog(@"Hello, world!");
	CHQuietLog(@"Hello, world! I accept specifiers: %@ instance at 0x%x.",
			   [self class], self);
	CHQuietLog(nil);
}

@end
