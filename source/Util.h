/*
 CHDataStructures.framework -- Util.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>

/**
 @file Util.h
 A group of utility C functions for simplifying common exceptions and logging.
 */

// Macro for reducing visibility of symbol names not indended to be exported.
#define HIDDEN __attribute__((visibility("hidden")))

// Macro for marking symbols a (potentially) unused to supress compile warnings.
#define UNUSED __attribute__((unused))

// Used for indicating that an object is not found when returning an NSUInteger.
#define CHNotFound NSUIntegerMax

/**
 Convenience function for raising an exception for an invalid range (index).
 
 @param aClass The class object for the originator of the exception. Callers should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass @c _cmd for this parameter.
 @param index The offending index passed to the receiver.
 @param elements The number of elements present in the receiver.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHIndexOutOfRangeException(Class aClass, SEL method,
                                       NSUInteger index, NSUInteger elements);

/**
 Convenience function for raising an exception on an invalid argument.
 
 @param aClass The class object for the originator of the exception. Callers should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass @c _cmd for this parameter.
 @param str An NSString describing the offending invalid argument.
 */
extern void CHInvalidArgumentException(Class aClass, SEL method, NSString *str);

/**
 Convenience function for raising an exception on an invalid nil object argument.
 
 @param aClass The class object for the originator of the exception. Callers should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass @c _cmd for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 
 @see CHInvalidArgumentException
 */
extern void CHNilArgumentException(Class aClass, SEL method);

/**
 Convenience function for raising an exception when a collection is mutated.
 
 @param aClass The class object for the originator of the exception. Callers should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass @c _cmd for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHMutatedCollectionException(Class aClass, SEL method);

/**
 Convenience function for raising an exception for un-implemented functionality.
 
 @param aClass The class object for the originator of the exception. Callers should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass @c _cmd for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
extern void CHUnsupportedOperationException(Class aClass, SEL method);

/**
 Provides a more terse alternative to NSLog() which accepts the same parameters. The output is made shorter by excluding the date stamp and process information which NSLog prints before the actual specified output.
 
 @param format A format string, which must not be nil.
 @param ... A comma-separated list of arguments to substitute into @a format.
 
 Read <b>Formatting String Objects</b> and <b>String Format Specifiers</b> on <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/Strings/"> this webpage</a> for details about using format strings. Look for examples that use @c NSLog() since the parameters and syntax are idential.
 */
extern void CHQuietLog(NSString *format, ...);

/**
 A macro for including the source file and line number where a log occurred.
 
 @param format A format string, which must not be nil.
 @param ... A comma-separated list of arguments to substitute into @a format.
 
 This is defined as a compiler macro so it can automatically fill in the file name and line number where the call was made. After printing these values in brackets, this macro calls #CHQuietLog with @a format and any other arguments supplied afterward.
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
