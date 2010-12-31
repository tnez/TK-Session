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
  [registry release];
  [components release];
  [subject release];
  // nothing for now
  [super dealloc];
}

- (void)componentDidBegin: (NSNotification *)info {
  //add entry to component history
  [[registry valueForKey:RRFSessionHistoryKey] addObject:currentComponentID];
  // create a new run entry for current task
  [[[self registryForTaskWithOffset:0]
    valueForKey:RRFSessionRunKey]
   addObject:[NSMutableDictionary dictionaryWithCapacity:2]];
  // update start in registry file
  [self setValue:[NSDate date] forRunRegistryKey:@"start"];
  // TODO: notify that registry has changed
}

- (void)componentDidFinish: (NSNotification *)info {
  // update end in registry file
  [self setValue:[NSDate date] forRunRegistryKey:@"end"];
  // TODO: notify that registry has changed
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
                 selector:@selector(componentDidFinish:)
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

#pragma mark Registry Accessors
- (NSDictionary *)registryForTask: (NSString *)taskID {
  NSDictionary * retValue = nil;
  @try {
    retValue = [NSDictionary dictionaryWithDictionary:
                [[registry valueForKey:RRFSessionComponentsKey]
                 valueForKey:taskID]];
  }
  @catch (NSException * e) {
    ELog(@"Could not find task with ID: %@",taskID);
  }
  @finally {
    return [retValue autorelease];
  }
}

- (NSDictionary *)registryForLastTask {
  // get the ID of the last completed task from the history
  // in the registry... the history is an array of number objects
  // representing succession of task ID's through time
  return [self registryForTaskWithOffset:-1];
}

- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset {
  NSDictionary *retValue = nil;
  @try {
    // determine ID of the task using offset
    NSInteger targetIdx;
    NSArray *history = [NSArray arrayWithArray:
                        [registry valueForKey:RRFSessionHistoryKey]];
    // if offset is positive... implication is that we are offsetting
    // from the begginging...
    if(offset>0) {
      // ...this will be index in the array minus 1
      targetIdx = offset - 1;
    } else {
      // we were given a non-positive offset which implies
      // that we should offset from our current point
      // this is equivalent to the index of the last item in history
      // minus our offset (which may be zero representing the current task)
      targetIdx = [history count] - 1 + offset;
    }
    // we then need the registry for the task with id equal to the
    // value we find in our target index
    NSString *targetID = [history objectAtIndex:targetIdx];
    retValue = [self registryForTask:targetID];
  }
  @catch (NSException * e) {
    ELog(@"Could not find task with offset: %d",offset);
  }
  @finally {
    return [retValue autorelease];
  }
}

#pragma mark Registry Setters
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key {
  @try {
    // get reference to current task...
    // first get current task ID
    NSString *curTaskID = [[registry valueForKey:RRFSessionHistoryKey]
                           lastObject];
    // then get the reference to the current task
    NSMutableDictionary *currentTask = 
    [[registry valueForKey:RRFSessionComponentsKey] valueForKey:curTaskID];
    // set value for said dictionary
    [currentTask setValue:newValue forKey:key];
  }
  @catch (NSException * e) {
    ELog(@"Could not set value for registry key: %@",key);
  }
}

- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key {
  @try {
  // get reference to current task...
    // first get current task ID
    NSString *curTaskID = [[registry valueForKey:RRFSessionHistoryKey]
                           lastObject];
    // then get the reference to the current task
    NSMutableDictionary *currentTask = 
    [[registry valueForKey:RRFSessionComponentsKey] valueForKey:curTaskID];
    // get the reference to the current run of current task
    NSMutableDictionary *currentRun =
    [[currentTask valueForKey:RRFSessionRunKey] lastObject];
    // set value for said dictionary
    [currentRun setValue:newValue forKey:key];
  }
  @catch (NSException * e) {
    ELog(@"Could not set value for run registry key: %@",key);
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
NSString * const RRFSessionHistoryKey = @"history"; 
NSString * const RRFSessionRunKey = @"runs";


@end
