/*
 CHDataStructures.framework -- CHLinkedDictionary.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableDictionary.h"
#import "CHQueue.h"

/**
 A dictionary which enumerates keys in the order in which they are inserted. The following additional operations are provided to take advantage of the ordering:
   - \link #firstKey -firstKey\endlink
   - \link #lastKey -lastKey\endlink
   - \link #keyAtIndex: -keyAtIndex:\endlink
   - \link #reverseKeyEnumerator -reverseKeyEnumerator\endlink
 
 Key-value entries are inserted just as in a normal dictionary, including replacement of values for existing keys, as detailed in \link #setObject:forKey: -setObject:forKey:\endlink. However, an additional structure is used in parallel to track insertion order, and keys are enumerated in that order. If a key to be added does not currently exist in the dictionary, it is added to the end of the list, otherwise the insertion order of the key does not change.

 Implementations of linked maps include <a href="http://java.sun.com/javase/6/docs/api/java/util/LinkedHashMap.html">LinkedHashMap</a> in <b>Java SE</b>, <a href="http://commons.apache.org/collections/apidocs/org/apache/commons/collections/map/LinkedMap.html">LinkedMap</a> in <b>Apache Commons</b>, and <a href="http://sano.luaforge.net/documentation/LinkedMap.html">LinkedMap</a> in <b>Lua</b>.
 
 @note Any method inherited from NSDictionary or NSMutableDictionary is supported, but only overridden methods are listed here.
 
 @todo Add support for evicting the eldest key-value entry at a given size (like a cache)?
 
 @todo Allow the option for re-inserting a key to move it to the end of the list.
 */
@interface CHLinkedDictionary : CHLockableDictionary {
	id insertionOrder;
}

#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns the first key in the receiver, according to insertion order.
 
 @return The first key in the receiver, or @c nil if the receiver is empty.
 
 @see keyAtIndex:
 @see lastKey
 @see removeObjectForFirstKey
 */
- (id) firstKey;

/**
 Returns the last key in the receiver, according to insertion order.
 
 @return The last key in the receiver, or @c nil if the receiver is empty.
 
 @see firstKey
 @see keyAtIndex:
 @see removeObjectForLastKey
 */
- (id) lastKey;

/**
 Returns the key at the specified index, based on insertion order.
 
 @param index The insertion-order index of the key to retrieve.
 @return The key at the specified index, based on insertion order.
 @throw NSRangeException If @a index is greater than or equal to the key count.
 
 @see \link NSDictionary#containsKey: - containsKey:\endlink
 @see firstKey
 @see lastKey
 */
- (id) keyAtIndex:(NSUInteger)index;

/**
 Returns an enumerator that lets you access each key in the receiver in reverse order.
 
 @return An enumerator that lets you access each key in the receiver in reverse order. The enumerator returned is never @c nil; if the dictionary is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @note If you need to modify the entries concurrently, use \link NSDictionary#allKeys -allKeys\endlink to create a "snapshot" of the dictionary's keys and work from this snapshot to modify the entries.
 
 @see \link NSDictionary#allKeys - allKeys\endlink
 @see \link NSDictionary#allKeysForObject: - allKeysForObject:\endlink
 @see NSFastEnumeration protocol
 */
- (NSEnumerator*) reverseKeyEnumerator;

// @}
@end
