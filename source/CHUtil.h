//
//  CHUtil.h
//  CHDataStructures
//
//  Copyright © 2008-2021, Quinn Taylor
//

#import <Foundation/Foundation.h>

/**
 @file CHUtil.h
 A group of utility C functions for simplifying common exceptions and logging.
 */

/** Macro for reducing visibility of symbol names not indended to be exported. */
#define HIDDEN __attribute__((visibility("hidden")))

/** Macro for designating symbols as being unused to suppress compile warnings. */
#define UNUSED __attribute__((unused))

#pragma mark -

/** Global variable to store the size of a pointer only once. */
OBJC_EXPORT size_t kCHPointerSize;

typedef BOOL(*CHObjectEqualityTest)(id,id);

/**
 Simple function for checking object equality, to be used as a function pointer.
 
 @param o1 The first object to be compared.
 @param o2 The second object to be compared.
 @return <code>[o1 isEqual:o2]</code>
 */
HIDDEN BOOL CHObjectsAreEqual(id o1, id o2);

/**
 Simple function for checking object identity, to be used as a function pointer.
 
 @param o1 The first object to be compared.
 @param o2 The second object to be compared.
 @return <code>o1 == o2</code>
 */
HIDDEN BOOL CHObjectsAreIdentical(id o1, id o2);

/**
 Determine whether two collections enumerate the equivalent objects in the same order.
 
 @param collection1 The first collection to be compared.
 @param collection2 The second collection to be compared.
 @return Whether the collections are equivalent.
 
 @throw NSInvalidArgumentException if one of both of the arguments do not respond to the @c -count or @c -objectEnumerator selectors.
 */
OBJC_EXPORT BOOL CHCollectionsAreEqual(id collection1, id collection2);

/**
 Generate a hash for a collection based on the count and up to two objects. If objects are provided, the result of their -hash method will be used.
 
 @param count The number of objects in the collection.
 @param o1 The first object to include in the hash.
 @param o2 The second object to include in the hash.
 @return An unsigned integer that can be used as a table address in a hash table structure.
 */
HIDDEN NSUInteger CHHashOfCountAndObjects(NSUInteger count, id o1, id o2);

#pragma mark -

/**
 Convenience macro for raising an exception for an invalid index.
 */
#define CHRaiseIndexOutOfRangeExceptionIf(a, comparison, b) \
({ \
	NSUInteger aValue = (a); \
	NSUInteger bValue = (b); \
	if (aValue comparison bValue) { \
		[NSException raise:NSRangeException \
		            format:@"%s -- Index out of range: %s (%lu) %s %s (%lu)", \
                           __PRETTY_FUNCTION__, #a, aValue, #comparison, #b, bValue]; \
	} \
})

/**
 Convenience macro for raising an exception on an invalid argument.
 */
#define CHRaiseInvalidArgumentException(str) \
[NSException raise:NSInvalidArgumentException \
            format:@"%s -- %@", \
                   __PRETTY_FUNCTION__, str]

/**
 Convenience macro for raising an exception on an invalid nil argument.

 */
#define CHRaiseInvalidArgumentExceptionIfNil(argument) \
if (argument == nil) { \
	CHRaiseInvalidArgumentException(@"Invalid nil value: " @#argument); \
}

/**
 Convenience macro for raising an exception when a collection is mutated.
 */
#define CHRaiseMutatedCollectionException() \
[NSException raise:NSGenericException \
            format:@"%s -- Collection was mutated during enumeration", \
                   __PRETTY_FUNCTION__]

/**
 Convenience macro for raising an exception for unsupported operations.
 */
#define CHRaiseUnsupportedOperationException() \
[NSException raise:NSInternalInconsistencyException \
            format:@"%s -- Unsupported operation", \
                   __PRETTY_FUNCTION__]

/**
 Provides a more terse alternative to NSLog() which accepts the same parameters. The output is made shorter by excluding the date stamp and process information which NSLog prints before the actual specified output.
 
 @param format A format string, which must not be nil.
 @param ... A comma-separated list of arguments to substitute into @a format.
 
 Read <b>Formatting String Objects</b> and <b>String Format Specifiers</b> on <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/Strings/"> this webpage</a> for details about using format strings. Look for examples that use @c NSLog() since the parameters and syntax are idential.
 */
OBJC_EXPORT void CHQuietLog(NSString *format, ...);

/**
 A macro for including the source file and line number where a log occurred.
 
 @param format A format string, which must not be nil.
 @param ... A comma-separated list of arguments to substitute into @a format.
 
 This is defined as a compiler macro so it can automatically fill in the file name and line number where the call was made. After printing these values in brackets, this macro calls #CHQuietLog with @a format and any other arguments supplied afterward.
 
 @see CHQuietLog
 */
#ifndef CHLocationLog
#define CHLocationLog(format,...) \
{ \
	NSString *file = [[NSString alloc] initWithUTF8String:__FILE__]; \
	printf("[%s:%d] ", [[file lastPathComponent] UTF8String], __LINE__); \
	[file release]; \
	CHQuietLog((format),##__VA_ARGS__); \
}
#endif
