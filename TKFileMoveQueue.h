////////////////////////////////////////////////////////////////////////////////
//  TKFileMoveQueue.h
//  TKFileMoveQueue
//  ----------------------------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 1/25/2011
//  Copyright 2010 Residential Research Facility, University of Kentucky.
//  All Rights Reserved.
//  ----------------------------------------------------------------------------
//  Description:
//  This creates a queue of files to be moved to another location when the
//  session is finished. Each entry has an input file (full path), destination 
//  file (full path).
//
////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>


@interface TKFileMoveQueue : NSObject {
  NSMutableArray *queue;  // queue of records
  NSString *pathToFile;   // disk storage of queue, in case of crash
}

/**
 Create instance of ourself and register the path to store file
 */
- (id)initWithFilePath: (NSString *)fullPath;

/**
 Return the next item in the queue, until empty, at which point return nil
 Item is an NSDictionary with keys: TKFileMoveQueueItemInputKey and
 TKFileMoveQueueItemOutputKey which refer to NSString references to full
 paths
 */
- (NSDictionary *)nextItem;

/**
 This is called whenever we change our move queue
 */
- (void)queueDidChange;

/**
 Add an item to the queue - both input and output paths should be full
 Returns YES upon success, NO otherwise
 */
- (BOOL)queueInputFile: (NSString *)fullInputPath
         forOutputFile: (NSString *)fullOutputPath;

/**
 Recover the queue from disk - this will be used in the case of application
 crash and recovery process
 */
- (void)recoverUsingFile: (NSString *)fullPathToFile;

/**
 Perform nescasary clean-up code. Should be called after when the session
 is through with the queue
 */
- (void)tearDown;

/**
 Write the contents of the queue to the provided file name
 Returns YES upon success, NO otherwise
 */
- (BOOL)writeToFile: (NSString *)fullPathToFile;

/**
 Constant keys for individual items
 */
extern NSString * const TKFileMoveQueueItemInputKey;
extern NSString * const TKFileMoveQueueItemOutputKey;

@end
