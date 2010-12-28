////////////////////////////////////////////////////////////
//  TKSession.m
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////

#import "TKSession.h"

@implementation TKSession
@synthesize manifest, components, subject;

#pragma mark Housekeeping
- (void)awakeFromNib {
  // nothing for now
  // ...
}

- (void)dealloc {
  // de-register for notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  // release reserved memory
  [manifest release];
  [components release];
  [subject release];
  // nothing for now
  [super dealloc];
}


- (void)componentDidBegin: (NSNotification *)info {
  // TODO: add entry to component history
  // TODO: update start in registry file
}

- (void)componentDidFinish: (NSNotification *)info {
  // TODO: update end in registry file
}

- (void)componentWillBegin: (NSNotification *)info {
  // ...as of now there is nothing to do here...
}

- (BOOL)loadSessionFromFilePath: (NSString *)pathToFile {
  if(manifest=[NSDictionary dictionaryWithContentsOfFile:pathToFile]) {
    [manifest retain];
    return YES;
  } else {
    ELog(@"Could not load from path: %@",pathToFile);
    return NO;
  }
}

- (BOOL)passedPreflightCheck: (NSString **)errorString {
  // TODO: implement
  return NO;
}

- (BOOL)run {
  // register for notifications from components
  NSNotificationCenter *postOffice = [NSNotificationCenter defaultCenter];
  [postOffice addObserver:self
                 selector:@selector(componentWillBegin:)
                     name:TKComponentWillBeginNotification
                   object:nil];
  [postOffice addObserver:self
                 selector:@selector(componentDidBegin:)
                     name:TKComponentDidBeginNotification
                 object:nil];  
  [postOffice addObserver:self
                 selector:@selector(componentDidEnd:)
                     name:TKComponentDidFinishNotification
                   object:nil];
  // TODO: load the next component using ID == 0
  // we will first need to write the method to do this!!!
  return NO;
}

#pragma mark Preference Keys
NSString * const RRFSessionProtocolKey = @"protocol";
NSString * const RRFSessionDescriptionKey  = @"description";
NSString * const RRFSessionCreationDateKey = @"creationDate";
NSString * const RRFSessionModifiedDateKey = @"modifiedDate";
NSString * const RRFSessionStatusKey = @"status";
NSString * const RRFSessionLastRunDateKey = @"lastRunDate";
NSString * const RRFSessionComponentsKey = @"components";
NSString * const RRFSessionComponentsJumpsKey = @"jumps";

@end
