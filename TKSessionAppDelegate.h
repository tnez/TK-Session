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

/**
   Start the session using the information provided in the form.
*/
- (IBAction)begin: (id)sender;

/**
   Cancel the session rather than run it. It is probably easier just
   to quit the application rather than hit this button which will just
   close the setup form.
*/
- (IBAction)cancel: (id)sender;

/**
   Create a tab delimited subject file.

   This is needed for backwards compatibility with certain stand-alone
   Cocoa Applications. This replicates the info file that those
   applications used to deal with that dependency.
*/
- (void)createTabDelimitedSubjectFile;

#pragma mark Environmental Constants
NSString * const RRFSessionSessionExtensionKey;

@end
