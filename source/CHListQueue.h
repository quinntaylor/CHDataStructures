/*
 CHDataStructures.framework -- CHListQueue.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 */

#import <CHDataStructures/CHQueue.h>
#import <CHDataStructures/CHAbstractListCollection.h>

/**
 @file CHListQueue.h
 A simple CHQueue implemented using a CHSinglyLinkedList.
 */

/**
 A simple CHQueue implemented using a CHSinglyLinkedList. A singly-linked list is a natural choice since a queue can only insert at one end (the back) and remove at the other end (the front). Since CHSinglyLinkedList tracks the tail node, both of these operations are O(1). Other queue operations generally only proceed from front to back, so the lack of reverse pointers is not problematic, and each object requires less storage space.
 */
@interface CHListQueue : CHAbstractListCollection <CHQueue>

@end
