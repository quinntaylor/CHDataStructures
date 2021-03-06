//
//  CHSortedDictionary.h
//  CHDataStructures
//
//  Copyright © 2009-2021, Quinn Taylor
//

#import <CHDataStructures/CHMutableDictionary.h>
#import <CHDataStructures/CHSortedSet.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @file CHSortedDictionary.h
 
 A dictionary which enumerates keys according to their natural sorted order.
 */

/**
 A dictionary which enumerates keys according to their natural sorted order. The following additional operations are provided to take advantage of the ordering:
   - \link #firstKey\endlink
   - \link #lastKey\endlink
   - \link #subsetFromKey:toKey:options:\endlink
 
 Key-value entries are inserted just as in a normal dictionary, including replacement of values for existing keys, as detailed in \link NSMutableDictionary#setObject:forKey: -[NSMutableDictionary setObject:forKey:]\endlink. However, an additional CHSortedSet structure is used in parallel to sort the keys, and keys are enumerated in that order.
 
 Implementations of sorted dictionaries (aka "maps") in other languages include the following:

 - <a href="http://java.sun.com/javase/6/docs/api/java/util/SortedMap.html">SortedMap</a> (Java)
 - <a href="http://www.cppreference.com/wiki/stl/map/start">map</a> (C++)
 
 @note Any method inherited from NSDictionary or NSMutableDictionary is supported, but only overridden methods are listed here.
 
 @see CHSortedSet
 */
@interface CHSortedDictionary<__covariant KeyType, __covariant ObjectType> : CHMutableDictionary
{
	id<CHSortedSet> sortedKeys;
}

#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns the minimum key in the receiver, according to natural sorted order.
 
 @return The minimum key in the receiver, or @c nil if the receiver is empty.
 
 @see lastKey
 */
- (nullable KeyType)firstKey;

/**
 Returns the maximum key in the receiver, according to natural sorted order.
 
 @return The maximum key in the receiver, or @c nil if the receiver is empty.
 
 @see firstKey
 */
- (nullable KeyType)lastKey;

/**
 Returns a new dictionary containing the entries for keys delineated by two given objects. The subset is a shallow copy (new memory is allocated for the structure, but the copy points to the same objects) so any changes to the objects in the subset affect the receiver as well. The subset is an instance of the same class as the receiver.
 
 @param start Low endpoint of the subset to be returned; need not be a key in receiver.
 @param end High endpoint of the subset to be returned; need not be a key in receiver.
 @param options A combination of @c CHSubsetConstructionOptions values that specifies how to construct the subset. Pass 0 for the default behavior, or one or more options combined with a bitwise OR to specify different behavior.
 @return A new sorted dictionary containing the key-value entries delineated by @a start and @a end. The contents of the returned subset depend on the input parameters as follows:
 - If both @a start and @a end are @c nil, all keys in the receiver are included. (Equivalent to calling @c -copy.)
 - If only @a start is @c nil, keys that match or follow @a start are included.
 - If only @a end is @c nil, keys that match or preceed @a start are included.
 - If @a start comes before @a end in an ordered set, keys between @a start and @a end (or which match either object) are included.
 - Otherwise, all keys @b except those that fall between @a start and @a end are included.
 */
- (NSMutableDictionary<KeyType, ObjectType> *)subsetFromKey:(KeyType)start
													  toKey:(KeyType)end
													options:(CHSubsetConstructionOptions)options;

// @}
@end

 NS_ASSUME_NONNULL_END
