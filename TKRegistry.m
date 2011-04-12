//
//  TKRegistry.m
//  TK-Session
//
//  Created by Travis Nesland on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TKRegistry.h"
#import "TKSession.h"

@implementation TKRegistry

@synthesize isDirty;
@synthesize session;
@synthesize stop;
@synthesize writeInterval;

#define TK_REGISTRY_DEFAULT_WRITE_INTERVAL 2000
#define TK_REGISTRY_DEFAULT_TIMEOUT_INTERVAL 5000

#pragma mark Housekeeping
- (void)dealloc
{
  [data release];data=nil;
  [writePath release];writePath=nil;
  [super dealloc];
}

- (id)init
{
  if(self=[super init])
  {
    [self setIsDirty:NO];
    [self setStop:NO];
    [self setWriteInterval:TK_REGISTRY_DEFAULT_WRITE_INTERVAL];
    return self;
  }
  return nil;
}

- (id)initWithContentsOfFile: (NSString *)_fullPathToFile
{
  if(self=[self init])
  {
    data = [[NSMutableDictionary alloc] initWithContentsOfFile:_fullPathToFile];
    writePath = [[NSString alloc] initWithString:_fullPathToFile];
    [NSThread detachNewThreadSelector:@selector(bouceRegistryToDisk:) toTarget:self withObject:nil];
    return self;
  }
  ELog(@"Could not create registry instance");
  return nil;
}

- (id)initWithPath: (NSString *)_writePath
{
  if(self=[self init])
  {
    data = [[NSMutableDictionary alloc] init];
    writePath = [[NSString alloc] initWithString:_writePath];
    if(![[NSFileManager defaultManager] createFileAtPath:writePath contents:nil attributes:nil])
    {
      ELog(@"Could not create empty registry file on disk: %@",writePath);
      return nil;
    }
    DLog(@"Launching bounce thread from thread: %@",[NSThread currentThread]);
    [NSThread detachNewThreadSelector:@selector(bouceRegistryToDisk:) toTarget:self withObject:nil];    
    return self;
  }
  ELog(@"Could not create registry instance");
  return nil;
}

#pragma mark Accessors
- (NSString *)fullPath
{
  return [writePath copy];
}

- (NSDictionary *)registryForTask: (NSString *)taskID {
  NSDictionary * retValue = nil;  
  @synchronized(self) {
    @try {
      retValue = [NSDictionary dictionaryWithDictionary:
                  [[self valueForKey:RRFSessionComponentsKey] valueForKey:taskID]];
    }
    @catch (NSException * e) {
      ELog(@"Could not find task with ID: %@",taskID);
    }
  }
  return retValue;
}

- (NSDictionary *)registryForLastTask {
  // get the ID of the last completed task from the history
  // in the registry... the history is an array of number objects
  // representing succession of task ID's through time
  return [self registryForTaskWithOffset:-1];
}

- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset {
  NSDictionary *retValue = nil;  
  @synchronized(self) {
    @try {
      // determine ID of the task using offset
      NSInteger targetIdx;
      NSArray *history = [NSArray arrayWithArray:[self valueForKey:RRFSessionHistoryKey]];
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
  }
  return retValue;
}

+ (NSString *)temporaryPath
{
  return [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:RRFRegistryTemporaryPathKey] stringByStandardizingPath];
}

- (id)valueForKey: (NSString *)key
{
  if(key)
  {
    return [data valueForKey:key];
  }
  // key was nil
  ELog(@"No key was provided");
  return nil;
}

#pragma mark Setters
- (void)setValue: (id)anObj forKey: (NSString *)aKey
{
  @synchronized(self)
  {
    [data setValue:anObj forKey:aKey];
    [self setIsDirty:YES];
    DLog(@"Just set: %@ for: %@",anObj,aKey);
  }
}

- (void)setValue: (id)newValue forRegistryKey: (NSString *)key {
  @synchronized(self) {
    @try {
      DLog(@"value: %@ forKey: %@",newValue,key);
      // get reference to current task...
      NSMutableDictionary *currentTask = 
      [[data objectForKey:RRFSessionComponentsKey] objectForKey:[session currentComponentID]];
      // set value for said dictionary
      [currentTask setValue:newValue forKey:key];
      // we're dirty now
      [self setIsDirty:YES];
    }
    @catch (NSException * e) {
      ELog(@"Could not set value for run registry key: %@ due to exception: %@",
           key,e);
    }
  }
}

- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key {
  @synchronized(self) {
    @try {
      DLog(@"value: %@ forKey: %@",newValue,key);
      // get reference to current run of current task...
      NSMutableDictionary* currentRun = 
      [[self valueForKeyPath:
        [NSString stringWithFormat:@"%@.%@.%@",RRFSessionComponentsKey,[session currentComponentID],RRFSessionRunKey]] lastObject];
      // set value for said dictionary
      [currentRun setValue:newValue forKey:key];
      // we're dirty now
      [self setIsDirty:YES];
    }
    @catch (NSException * e) {
      ELog(@"Could not set value for run registry key: %@ due to exception: %@",
           key,e);
    }
  }
}

#pragma mark File Operations
- (BOOL)moveToPath: (NSString *)_fullPath
{
  DLog(@"Attempting to copy registry file to: %@",_fullPath);
  BOOL result = YES;
  TKTime methodStart = current_time_marker();
  NSFileManager *fm = [NSFileManager defaultManager];
  while([self isDirty])
  {
    // check if we have been at this too long
    NSUInteger ms_sinceStart = time_as_milliseconds(time_since(methodStart));
    if(ms_sinceStart > TK_REGISTRY_DEFAULT_TIMEOUT_INTERVAL)
    {
      ELog(@"Timed out waiting for registry to write");
      result = NO;
      break;
    }
    // wait for a polling interval
    [NSThread sleepForTimeInterval:2.0];
  }
  // now we can safely stop write thread
  [self setStop:YES];
  // try to move the file
  NSError *moveError = nil;
  [fm moveItemAtPath:writePath toPath:_fullPath error:&moveError];
  if(moveError) // if error...
  {
    ELog(@"Encountered error trying to move registry file");
    result = NO;
  } else { DLog(@"Registry file deleted"); }
  return result;
}

#pragma mark Internal Methods
- (NSTimer *)bouceRegistryToDisk: (id)arg
{
  NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
  DLog(@"Spawned bounce thread: %@",[NSThread currentThread]);
  struct timespec ts;
  ts.tv_sec = writeInterval/1000;
  @synchronized(self)
  {
    while(!stop) {
      if(isDirty) {
        if([data writeToFile:writePath atomically:YES]) {
          [self setIsDirty:NO];
        } else {
          ELog(@"Could not write registry to disk!");
        }
      } // end of durtydurty
      DLog(@"Preparing to sleep for %d seconds",ts.tv_sec);
      nanosleep(&ts, NULL);
    }
  }
  [aPool drain];
}

#pragma mark CONSTANTS
NSString * const RRFRegistryTemporaryPathKey = @"_TEMP/regfile.plist";

@end
