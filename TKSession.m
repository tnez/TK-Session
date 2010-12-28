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

- (BOOL)launchComponentWithID: (NSInteger)componentID {
  // if componentID is equal to zero, we are signifying the end condition
  if(componentID == 0) {
    // TODO: we need to end the session here
    return YES;
  } 
  // attempt to get the corresponding definition
  NSDictionary *componentDefinition =
    [components objectForKey: [NSString stringWithFormat:@"%d",componentID]];
  // if we found a definition for the given component ID...
  if(componentDefinition) {
    // attempt to load the component and begin
    TKComponentController *newComponent =
      [TKComponentController loadFromDefinition:componentDefinition];
    // if the new component is cleared to begin...
    if([newComponent isClearedToBegin]) {
      // begin and return
      DLog(@"Attempting to start new component: %@",
           [[NSDate date] description]);
      [newComponent begin];
      return YES;
    } else { // there was an error while attempting to start component
      ELog(@"Encountered error while attempting to start new component");
      return NO;
    }
  } else { // we could not find a valid component definition
    ELog(@"Could not get definition for component with ID: %d",componentID);
    return NO;
  }
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
  // load the next component using ID == 1
  // this ID is designated for the first component
  if([self launchComponentWithID:1]) {
    DLog(@"Session has started run at: %@",[[NSDate date] description]);
    return YES;
  } else {
    // there was a problem starting the session run
    ELog(@"Session could not be started");
    return NO;
  }
}

#pragma mark Preference Keys
NSString * const RRFSessionProtocolKey = @"protocol";
NSString * const RRFSessionDescriptionKey  = @"description";
NSString * const RRFSessionCreationDateKey = @"creationDate";
NSString * const RRFSessionModifiedDateKey = @"modifiedDate";
NSString * const RRFSessionStatusKey = @"status";
NSString * const RRFSessionLastRunDateKey = @"lastRunDate";
NSString * const RRFSessionComponentsKey = @"components";
NSString * const RRFSessionComponentsDefinitionKey = @"definition";
NSString * const RRFSessionComponentsJumpsKey = @"jumps";

@end
