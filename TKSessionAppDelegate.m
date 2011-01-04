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

@synthesize subject,setupWindow,protocolField;

- (void)applicationWillFinishLaunching: (NSNotification *)aNotification {
  DLog(@"Application will finish launching");
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification {
  DLog(@"Application did finish launching");
  @try {
    // get the protocol from the manifest file
    NSString *protocol = [[session manifest] valueForKey:RRFSessionProtocolKey];
    // set the protocol field in the setup window
    [subject setStudy:protocol];
  }
  @catch (NSException * e) {
    ELog(@"Could not set protocol field in setup window: %@",[e description]);
  }
  @finally {
    // ...
  }
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
  DLog(@"Trying to open with session file: %@",filename);  
    // if this is a session file...
    if([[filename pathExtension]
        isEqualToString:RRFSessionSessionExtensionKey]) {
      // ...create a session from the file
      session = [[TKSession alloc] initWithFile:filename];
    }
  return YES;
}

- (void)awakeFromNib {
  // make ourself the delegate
  /* DLog(@"Making ourself the application's delegate");
  [[NSApplication sharedApplication] setDelegate:self]; */
}

- (IBAction)cancel: (id)sender {
  [NSApp terminate];
}

- (IBAction)begin: (id)sender {
  [session setSubject:subject];
  if(![session run]) {
    [NSAlert
     alertWithError:@"Could not begin session... check the console for errors"];
  }
}

#pragma mark Environmental Constants
NSString * const RRFSessionSessionExtensionKey = @"session";
@end
