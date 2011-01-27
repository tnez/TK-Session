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

#import "TKFileMoveQueue.h"


@implementation TKFileMoveQueue

- (void)dealloc {
  [queue release]; queue=nil;
  [pathToFile release]; pathToFile=nil;
  //
  [super dealloc];
}

- (id)initWithFilePath: (NSString *)fullPath {
  if(self=[super init]) {
    queue = [[NSMutableArray alloc] init];                   // create the queue
    pathToFile = [[NSString alloc] initWithString:fullPath]; // store the file
                                                             // path
    return self;
  } 
  return nil;
}

- (NSDictionary *)nextItem {
  if([queue count]==0) return nil; // if the queue is empty, return nil
  NSDictionary *item = nil;
  @try {
    // otherwise, grab the item at the front of the line
    item = [[NSDictionary alloc] initWithDictionary: [queue objectAtIndex:0]];
    // and remove the grabbed item
    [queue removeObjectAtIndex:0];
  }
  @catch (NSException *e) {
    ELog(@"%@",e); // log any exceptions
  }
  return [item autorelease]; // return an autoreleased instance
}

- (void)queueDidChange {
  // write the file to disk, logging errors if encountered
  if(![self writeToFile:pathToFile]) {
    ELog(@"Error writing queue to disk at: %@",pathToFile);
  }
}

- (BOOL)queueInputFile: (NSString *)fullInputPath
         forOutputFile: (NSString *)fullOutputPath {
  BOOL didFail = NO; // create fail flag for error handling
  @try {
    [queue addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                      fullInputPath, TKFileMoveQueueItemInputKey,
                      fullOutputPath, TKFileMoveQueueItemOutputKey, nil]];
  }
  @catch (NSException *e) {
    ELog(@"%@",e); // log exception
    didFail = YES; // raise fail flag
  }
  if(didFail) {
    return NO;
  } else {
    DLog(@"Queued File: %@ forPath: %@",fullInputPath,fullOutputPath);
    [self queueDidChange];
    return YES;
  }
}

- (void)recoverUsingFile: (NSString *)fullPathToFile {
  // release old queue and path to file if any
  [queue release]; queue=nil;
  [pathToFile release]; queue=nil;
  // read array from file path
  queue = [[NSMutableArray alloc] initWithContentsOfFile:fullPathToFile];
  // store the path to file
  pathToFile = [[NSString alloc] initWithString:fullPathToFile];
}

- (void)tearDown {
  // remove the queue from disk
  NSError *error=nil;
  [[NSFileManager defaultManager] removeItemAtPath:pathToFile
                                             error:&error];
  if(error) {
    ELog(@"Error removing queue file:%@",[error localizedDescription]);
  }
}

- (BOOL)writeToFile: (NSString *)fullPathToFile {
  // write the file to disk returning YES upon success
  return [queue writeToFile:fullPathToFile atomically:YES];
}

NSString * const TKFileMoveQueueItemInputKey = @"TKFileMoveQueueItemInput";
NSString * const TKFileMoveQueueItemOutputKey = @"TKFileMoveQueueItemOutput";

@end
