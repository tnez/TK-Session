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
#import <TKUtility/TKUtility.h>

@class TKSession;

@interface TKSessionAppDelegate : NSObject {
  TKSession *session;
  IBOutlet TKSubject *subject;
  IBOutlet NSWindow *setupWindow;
  IBOutlet NSWindow *sessionWindow;
  IBOutlet NSTextField *protocolField;
}
@property (assign) IBOutlet TKSubject *subject;
@property (assign) IBOutlet NSWindow *setupWindow;
@property (assign) IBOutlet NSWindow *sessionWindow;
@property (assign) IBOutlet NSTextField *protocolField;

- (void)applicationWillFinishLaunching: (NSNotification *)aNotification;
- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
/**
 See NSApplicationDelegate protocol for documentation
 This method is nesc. for the session to be able to launch applications from
 the finder or by drag and drop on to the dock
 */
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (void)awakeFromNib;
- (IBAction)cancel: (id)sender;
- (void)createTabDelimitedSubjectFile;
- (IBAction)begin: (id)sender;

#pragma mark Environmental Constants
NSString * const RRFSessionSessionExtensionKey;

@end
