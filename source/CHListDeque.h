/*
 CHDataStructures.framework -- CHListDeque.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 */

#import <CHDataStructures/CHDeque.h>
#import <CHDataStructures/CHAbstractListCollection.h>

/**
 @file CHListDeque.h
 A simple CHDeque implemented using a CHDoublyLinkedList.
 */

/**
 A simple CHDeque implemented using a CHDoublyLinkedList. A doubly-linked list is a natural choice since a deque supports insertion and removal at both ends (removing from the tail is O(n) in a singly-linked list, but O(1) in a doubly-linked list) and enumerating objects from back to front (hopelessly inefficient in a singly-linked list). The trade-offs for these benefits are marginally higher storage cost and marginally slower operations due to handling reverse links.
 */
@interface CHListDeque : CHAbstractListCollection <CHDeque>

@end
