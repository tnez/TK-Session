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

@synthesize subject,setupWindow,sessionWindow,protocolField;

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
    // create the _TEMP file directory if doesn't already exist
    [[NSFileManager defaultManager]
     createDirectoryAtPath:[[[NSBundle mainBundle] bundlePath]
                            stringByAppendingPathComponent:@"_TEMP"]
     attributes:nil];
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
  [NSApp terminate:self];
}

- (void)createTabDelimitedSubjectFile {
  // create the string
  NSString *writeData = [[NSString alloc] initWithFormat:
                         @"Subjcet ID\t%@\nStudy Day\t%@\nToday's Dose\t%@\nDrug Level\t%@\nDrug Code\t%@\nDate\t%@\n",
                         [subject subject_id],[subject session],
                         [subject drugDose],[subject drugLevel],
                         [subject drugCode],[[NSDate date] description]];
  DLog(@"Current Info (data): %@",writeData);
  // generate our file name
  NSString *filename = [[[NSBundle mainBundle] bundlePath]
                        
                        stringByAppendingPathComponent:@"_TEMP/current.info"];
  DLog(@"Current Info (path): %@",filename);
  // create the file
  BOOL success = [[NSFileManager defaultManager]
                  createFileAtPath:filename
                  contents:[writeData dataUsingEncoding:NSUTF8StringEncoding]
                  attributes:nil];
  // if we encountered an error
  if(!success) {
    ELog(@"Error writing subject file:%@",filename);
  }
  [writeData release];
}

- (IBAction)begin: (id)sender {
  // create current.info (backwards compatability)
  [self createTabDelimitedSubjectFile];
  // setup session
  [session setSubject:subject];
  [session setSessionWindow:sessionWindow];
  [sessionWindow setIsVisible:YES];
  // begin session
  if(![session run]) {
    [NSAlert
     alertWithError:@"Could not begin session... check the console for errors"];
  }
}

#pragma mark Environmental Constants
NSString * const RRFSessionSessionExtensionKey = @"session";
@end
