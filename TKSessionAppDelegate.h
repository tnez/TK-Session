////////////////////////////////////////////////////////////
//  TKSessionAppDelegate.h
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 1/2/11
//  Copyright 2011 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>

// forward declarations
@class TKSession;

@interface TKSessionAppDelegate : NSObject {
  TKSession *session;
}

/**
 See NSApplicationDelegate protocol for documentation
 This method is nesc. for the session to be able to launch applications from
 the finder or by drag and drop on to the dock
 */
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

#pragma mark Environmental Constants
NSString * const RRFSessionSessionExtensionKey;

@end
