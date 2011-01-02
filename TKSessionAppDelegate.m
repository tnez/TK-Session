////////////////////////////////////////////////////////////
//  TKSessionAppDelegate.m
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 1/2/11
//  Copyright 2011 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import "TKSessionAppDelegate.h"
#import "TKSession.h"

@implementation TKSessionAppDelegate

- (BOOL)application:(NSApplication *)theApplication
  openFile:(NSString *)filename {
    // if this is a session file...
    if([[filename pathExtension]
        isEqualToString:RRFSessionSessionExtensionKey]) {
      // ...create a session from the file
      session = [[TKSession alloc] initWithFile:filename];
    }
  return YES;
}

#pragma mark Environmental Constants
NSString * const RRFSessionSessionExtensionKey = @"session";
@end
