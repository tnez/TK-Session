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
#import "TKFileMoveQueue.h"

@implementation TKSession
@synthesize components,dataDirectory,manifest,moveQueue,pathToRegistryFile,
compObj,subject,sessionWindow;

#pragma mark Housekeeping
- (void)awakeFromNib {
  // nothing for now
  // ...
}

- (void)dealloc {
  // de-register for notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  // release reserved memory
  [dataDirectory release];dataDirectory=nil;
  [manifest release];manifest=nil;
  [moveQueue release];moveQueue=nil;
  [registry release];registry=nil;
  [components release];components=nil;
  [pathToRegistryFile release];pathToRegistryFile=nil;
  [compObj release];compObj=nil;
  [subject release];subject=nil;
  // nothing for now
  [super dealloc];
}

- (id)init {
  if([super init]) {
    // create our registry
    registry = [[NSMutableDictionary alloc] initWithCapacity:3];
    pathToRegistryFile = [[[[NSBundle mainBundle] bundlePath]
                           stringByAppendingPathComponent:
                           RRFSessionPathToRegistryFileKey] retain];
    // top level objects of registry
    // {dict:session,dict:components,array:history}
    // create our move queue... used by external apps to queue data files
    // to be moved at end of session
    moveQueue = [[TKFileMoveQueue alloc] initWithFilePath:
                 [[[NSBundle mainBundle] bundlePath] 
                  stringByAppendingPathComponent:
                  RRFSessionPathToFileMoveQueueKey]];
    return self;
  }
  return nil;
}

- (void)componentDidBegin: (NSNotification *)info {
  DLog(@"%@ did begin",[compObj task]);
}

- (void)componentDidFinish: (NSNotification *)info {
  DLog(@"%@ did finish",[compObj task]);
  // release the old compObj and set to nil
  [compObj release];compObj=nil;
  // update end in registry file
  [self setValue:[NSDate date] forRunRegistryKey:@"end"];
  // incorp offset in dictionary get the next value
  NSInteger offset = [[[self registryForTask:currentComponentID]
                       valueForKey:RRFSessionComponentsOffsetKey] integerValue];
  // get jump value
  NSString *jumpToTask = [[[components valueForKey:currentComponentID]
                           valueForKey:RRFSessionComponentsJumpsKey]
                          objectAtIndex:offset];
  DLog(@"Jump value for task: %@ is %@",currentComponentID,jumpToTask);
  [self performSelector:@selector(launchComponentWithID:)
             withObject:jumpToTask afterDelay:0];
}

- (void)componentWillBegin: (NSNotification *)info {
    DLog(@"%@ will begin",[compObj task]);
}

- (BOOL)initRegistryFile {
  @try {
    // latch path to registry file
    pathToRegistryFile = [[[[NSBundle mainBundle] bundlePath]
                           stringByAppendingPathComponent:
                           RRFSessionPathToRegistryFileKey] retain];
    // create empty file at path
    if(![[NSFileManager defaultManager]
         createFileAtPath:[self pathToRegistryFile]
         contents:nil attributes:nil]) {
      ELog(@"Could not create empty registry file on disk: %@",
           [self pathToRegistryFile]);
      return NO;
    }
    // create registry in memory
    registry = [[NSMutableDictionary alloc] init];
    // load global session info
    [registry setValue:[subject study] forKey:RRFSessionProtocolKey];
    [registry setValue:[subject subject_id] forKey:RRFSessionSubjectKey];
    [registry setValue:[subject session] forKey:RRFSessionSessionKey];
    [registry setValue:[NSDate date] forKey:RRFSessionStartKey];
    DLog(@"Loaded global values in registry");
    // create empty history
    [registry setValue:[NSMutableArray array] forKey:RRFSessionHistoryKey];
    DLog(@"Created empty history in registry");
    // create empty components dictionary
    [registry setValue:[NSMutableDictionary dictionary]
                forKey:RRFSessionComponentsKey];
    DLog(@"Created empty component block in registry");

    // for every element in the component block of the manifest
    // create an a mutable dictionary with the key of task ID
    // and a nested runs mutable dictionary
    NSMutableDictionary *compSection =
      [registry valueForKey:RRFSessionComponentsKey];
    for(NSString *taskID in [components allKeys]) {
      // create the component registry
      [compSection setValue:[NSMutableDictionary dictionary] forKey:taskID];
      // create an empty run registry inside
      NSMutableDictionary* curSection = [compSection valueForKey:taskID];
      [curSection setValue:[NSMutableArray array]
                    forKey:RRFSessionRunKey];
    } // end for loop
    DLog(@"Created entries for all components in registry");
    // we have succeeded (presumably) :}
    [self registryDidChange];    
    return YES;
  } // end of try block
  @catch (NSException * e) {
    // we have failed :{
    ELog(@"Encountered exception when trying to create registry file: %@",
         e);
    return NO;
  }
  return NO; // bleh
}
   
- (id)initWithFile: (NSString *)filename {
  if(self=[self init]) {
    // read session file
    manifest = [[NSDictionary alloc] initWithContentsOfFile:filename];
    // if there was an error reading the file...
    if(!manifest) {
      ELog(@"Could not read session file: %@",filename);
    }
    // create components
    components = [[NSDictionary alloc] initWithDictionary:
                  [manifest valueForKey:RRFSessionComponentsKey]];
    if(!components) {
      ELog(@"Could not create components from manifest");
    }
    return self;
  }
  return nil;
}

- (BOOL)launchComponentWithID: (NSString *)componentID {
  // grab current component ID
  if(currentComponentID) {
    [currentComponentID release];
  }
  currentComponentID = [[NSString alloc] initWithString:componentID];
  // if componentID is equal to zero, we are signifying the end condition
  if([componentID isEqualToString:@"end"]) {
    [self tearDown];
  } 
  //add entry to component history
  [[registry valueForKey:RRFSessionHistoryKey] addObject:currentComponentID];
  // create a new run entry for current task
  [[[self registryForTask:currentComponentID]
    valueForKey:RRFSessionRunKey]
   addObject:[NSMutableDictionary dictionaryWithCapacity:2]];
  // update start in registry file
  [self setValue:[NSDate date] forRunRegistryKey:@"start"];
  // attempt to get the corresponding definition
  NSDictionary *componentDefinition =
    [[components objectForKey:componentID] valueForKey:@"definition"];
  // if we found a definition for the given component ID...
  if(componentDefinition) {
    // attempt to load the component and begin
    [self setCompObj:
     [TKComponentController loadFromDefinition:componentDefinition]];
    [compObj setDelegate:self];
    [compObj setSessionWindow:sessionWindow];
    [compObj setSubject:subject];
    // if the new component is cleared to begin...
    if([compObj isClearedToBegin]) {
      // begin and return
      DLog(@"Attempting to start new component: %@",componentDefinition);
      // add entry to registry file history
      [compObj begin];
      return YES;
    } else { // there was an error while attempting to start component
      ELog(@"Encountered error while attempting to start new component");
      return NO;
    }
  } else { // we could not find a valid component definition
    ELog(@"Could not get definition for component with ID: %@",componentID);
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

- (BOOL)recoverFromCrash {
  [moveQueue recoverUsingFile:RRFSessionPathToFileMoveQueueKey];
  // load the regfile
  [registry release]; // release the old registry
  registry = [[NSMutableDictionary alloc]
              initWithContentsOfFile:pathToRegistryFile];
  // get the last object in history
  NSString *lastRunComponent = [[registry valueForKey:RRFSessionHistoryKey]
                                lastObject];
  DLog(@"Attempting to recover to last run component:%@",lastRunComponent);
  if([self launchComponentWithID:lastRunComponent]) {
    return YES;
  } else { // there was a problem starting the last component
    ELog(@"Could not recover to last run compnent:%@",lastRunComponent);
    return NO;
  }
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
  // setup loggers and timers
  [NSThread detachNewThreadSelector:@selector(spawnAndBeginTimer:) toTarget:[TKTimer class] withObject:nil];
  DLog(@"Session timer started");
  [NSThread detachNewThreadSelector:@selector(spawnMainLogger:) toTarget:[TKLogging class] withObject:nil];
  [NSThread detachNewThreadSelector:@selector(spawnCrashRecoveryLogger:) toTarget:[TKLogging class] withObject:nil];
  DLog(@"Session logs started");
  // setup the data directory -- record path
  dataDirectory = [[NSString alloc] initWithString:
                   [[NSString stringWithFormat:@"%@/%@/%@/%@",
                     [manifest valueForKey:RRFSessionDataDirectoryKey],
                     [subject study],[subject subject_id],[subject session]]
                    stringByStandardizingPath]];
  // setup the data directory -- create the directory on disk
  NSError *dataDirError;
  if(![[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&dataDirError]) {
    // if there was an error creating the dir, log it
    ELog(@"%@",dataDirError);
  }
  // if the regfile still exists at path...
  DLog(@"Checking for regfile at path:%@",pathToRegistryFile);
  if([[NSFileManager defaultManager]
      fileExistsAtPath:pathToRegistryFile]) {
    // begin recovery process
    return [self recoverFromCrash];
  }
  // ...if we've made it here this can be assumed to be a new run
  // initialize the registry file
  if(![self initRegistryFile]) {
    ELog(@"Could not initialize the registry file");
  }
  // load the next component using the start ID
  if([self launchComponentWithID:
      [manifest valueForKey:RRFSessionStartTaskKey]]) {
    DLog(@"Session has started run at: %@",[NSDate date]);
    return YES;
  } else {
    // there was a problem starting the session run
    ELog(@"Session could not be started");
    return NO;
  }
}

- (void)tearDown {
  // move registry file to data directory
  @try {
   // get target file name
    NSString *targetName = [NSString stringWithFormat:@"%@_%@_%@_REG.plist",
                            [subject study],[subject subject_id],
                            [subject session]];
    // attempt to move the registry file
    DLog(@"Attempting to copy registry file:%@ to dir:%@",
         [pathToRegistryFile stringByStandardizingPath],
         [[dataDirectory stringByAppendingPathComponent:targetName]
          stringByStandardizingPath]);
    NSError *copyError = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm copyItemAtPath:[pathToRegistryFile stringByStandardizingPath]
                toPath:[[dataDirectory 
                         stringByAppendingPathComponent:targetName]
                          stringByStandardizingPath]
                 error:&copyError];
    if(copyError) {
      ELog(@"There was a problem moving the registry file: %@",copyError);
    } else { // copy was successful
      DLog(@"Attempting to delete registry file:%@",
           [pathToRegistryFile stringByStandardizingPath]);
      [fm removeItemAtPath:[pathToRegistryFile stringByStandardizingPath]
                     error:nil];
    }
    // attempt to move queued files
    NSError *fileQueueError;
    NSDictionary *qItem = nil;
    while(qItem = [moveQueue nextItem]) {
      [fileQueueError release];fileQueueError=nil; // reset error
      // move the file
      DLog(@"Attempting to move: %@ to: %@",
           [qItem valueForKey:TKFileMoveQueueItemInputKey],
           [qItem valueForKey:TKFileMoveQueueItemOutputKey]);
      [fm moveItemAtPath:[qItem valueForKey:TKFileMoveQueueItemInputKey]
      toPath:[qItem valueForKey:TKFileMoveQueueItemOutputKey]
                   error:&fileQueueError];
      // log error if any
      if(fileQueueError) ELog(@"%@",fileQueueError);
    }
    // tear down the move queue
    [moveQueue tearDown];
  }
  @catch (NSException * e) {
    ELog(@"%@",e);
  }
  @finally {
    DLog(@"Terminating application");
    [NSApp terminate:self];
  }
}

#pragma mark Registry Accessors
- (NSDictionary *)registryForTask: (NSString *)taskID {
  NSDictionary * retValue = nil;
  @try {
    retValue = [[NSDictionary dictionaryWithDictionary:
                 [[registry valueForKey:RRFSessionComponentsKey]
                  valueForKey:taskID]] retain];
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
    ELog(@"Could not find task with offset: %d Exception: %@",offset,e);
  }
  @finally {
    return [retValue autorelease];
  }
}

#pragma mark Registry Setters
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key {
  @try {
    DLog(@"value: %@ forKey: %@",newValue,key);
    // get reference to current task...
    NSMutableDictionary *currentTask = 
    [[registry objectForKey:RRFSessionComponentsKey]
     objectForKey:currentComponentID];
    // set value for said dictionary
    [currentTask setValue:newValue forKey:key];
    // we did change
    [self registryDidChange];
  }
  @catch (NSException * e) {
    ELog(@"Could not set value for run registry key: %@ due to exception: %@",
         key,e);
  }
}

- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key {
  @try {
    DLog(@"value: %@ forKey: %@",newValue,key);
    // get reference to current run of current task...
    NSMutableDictionary* currentRun = 
      [[registry valueForKeyPath:
        [NSString stringWithFormat:
         @"%@.%@.%@",RRFSessionComponentsKey,currentComponentID,
         RRFSessionRunKey]] lastObject];
    // set value for said dictionary
    [currentRun setValue:newValue forKey:key];
    // we did change
    [self registryDidChange];
  }
  @catch (NSException * e) {
    ELog(@"Could not set value for run registry key: %@ due to exception: %@",
         key,e);
  }
}

#pragma mark Registry Maintenence
/**
 Write the registry file to disk
 Returns YES if successful
 */
- (BOOL)bounceRegistryToDisk {
  return [registry writeToFile:[self pathToRegistryFile] atomically:YES];
}

/**
 Path to which the registry file should be stored
 */
- (NSString *)pathToRegistryFile {
  return pathToRegistryFile;
}

/**
 This method should be called whenever we have made a change to the registry
 in memory
 */
- (void)registryDidChange {
  DLog(@"Writing registry to disk");
  if(![self bounceRegistryToDisk]) {
    ELog(@"Unable to write the registry to disk");
  }
}

#pragma mark Preference Keys
NSString * const RRFSessionProtocolKey = @"protocol";
NSString * const RRFSessionSubjectKey = @"subject";
NSString * const RRFSessionSessionKey = @"session";
NSString * const RRFSessionMachineKey = @"machine";
NSString * const RRFSessionStartKey = @"start";
NSString * const RRFSessionStartTaskKey = @"startTask";
NSString * const RRFSessionEndKey = @"end";
NSString * const RRFSessionDescriptionKey  = @"description";
NSString * const RRFSessionDataDirectoryKey = @"dataDirectory";
NSString * const RRFSessionCreationDateKey = @"creationDate";
NSString * const RRFSessionModifiedDateKey = @"modifiedDate";
NSString * const RRFSessionStatusKey = @"status";
NSString * const RRFSessionLastRunDateKey = @"lastRunDate";
NSString * const RRFSessionComponentsKey = @"components";
NSString * const RRFSessionComponentsDefinitionKey = @"definition";
NSString * const RRFSessionComponentsJumpsKey = @"jumps";
NSString * const RRFSessionComponentsOffsetKey = @"jumpOffset";
NSString * const RRFSessionHistoryKey = @"history"; 
NSString * const RRFSessionRunKey = @"runs";

#pragma mark Environmental Constants
NSString * const RRFSessionPathToRegistryFileKey = @"_TEMP/regfile.plist";
NSString * const RRFSessionPathToFileMoveQueueKey = @"_TEMP/moveQueue.plist";

@end
