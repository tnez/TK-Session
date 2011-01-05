////////////////////////////////////////////////////////////
//  TKSession.h
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>

@interface TKSession : NSObject {
  NSDictionary *components;             // the block of components currently
                                        // loaded  
  NSString *currentComponentID;         // the ID of the current component (in
                                        // this case current ranges from about
                                        // to be launched to componentDidFinish)    
  NSDictionary *manifest;               // the manifest, or definition for
                                        // the currently loaded session
  NSString *pathToRegistryFile;         // path to registry file
  NSMutableDictionary *registry;        // information pertaining to the current
                                        // session... this includes information
                                        // parsed into runs for each component
                                        // as well as a history representing
                                        // completed components... it is through
                                        // the registry that components can
                                        // access session information or 
                                        // information pertaining to other
                                        // components or specific runs of said
                                        // component... the registry will be
                                        // regularly written to disk so that
                                        // we may recover from crash a crash
  TKComponentController *compObj;       // the actual component object
  TKSubject *subject;                   // the subject object created during
                                        // setup
}

@property(readonly) NSDictionary *components;
@property(readonly) NSDictionary *manifest;
@property(readonly) NSString *pathToRegistryFile;
@property(nonatomic, retain) TKComponentController *compObj;
@property(nonatomic, retain) TKSubject *subject;

- (void)componentDidBegin: (NSNotification *)info;
- (void)componentDidFinish: (NSNotification *)info;
- (void)componentWillBegin: (NSNotification *)info;
- (id)initWithFile: (NSString *)filename;
/**
 launchComponentWithID:
 Discussion - Attempts to launch the component whose ID value corresponds to the value of 
 componentID given. A componentID of zero constitutes the end of components.
 Return Value - Will return YES if component was identified and could begin,
 otherwise will return NO.
 */
- (BOOL)launchComponentWithID: (NSString *)componentID;
- (BOOL)loadSessionFromFilePath: (NSString *)pathToFile;
- (BOOL)passedPreflightCheck: (NSString **)errorString;
- (BOOL)run;
- (void)tearDown;

#pragma mark Registry Accessors
/**
 Return copy of entire dictionary belonging to the task w/ the given ID
 Should return nil if ID is invalid
 */
- (NSDictionary *)registryForTask: (NSString *)taskID;
/**
 Return copy of entire dictionary belonging to the last completed task
 Should return nil if last task cannot be found
 */
- (NSDictionary *)registryForLastTask;
/**
 Return copy of entire dictionary belonging to the task referenced by the
 given offset. Should return nil if offset is invalid.
 Positive offsets are interpreted as from the first run task forward.
 Zero offset is the current task.
 Negative offsets are interpreted as the last run task backward.
*/
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset;

#pragma mark Registry Setters
/** 
 Sets a value for key pertaining to the whole current task (not to an 
 individual run of said task).
 */
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key;
/**
 Sets a value for key pertaining to the current run of the current task
 */
- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key;

#pragma mark Registry Maintenance
/**
 Write the registry file to disk
 Returns YES if successful
 */
- (BOOL)bounceRegistryToDisk;
/**
 Returns the path to where the registry file will be stored
 */
- (NSString *)pathToRegistryFile;
/**
 This method should be called whenever we have made a change to the registry
 in memory
 */
- (void)registryDidChange;

#pragma mark Preference Keys
NSString * const RRFSessionProtocolKey;
NSString * const RRFSessionSubjectKey;
NSString * const RRFSessionSessionKey;
NSString * const RRFSessionMachineKey;
NSString * const RRFSessionDescriptionKey;
NSString * const RRFSessionDataDirectoryKey;
NSString * const RRFSessionStartKey;
NSString * const RRFSessionStartTaskKey;
NSString * const RRFSessionEndKey;
NSString * const RRFSessionCreationDateKey;
NSString * const RRFSessionModifiedDateKey;
NSString * const RRFSessionStatusKey;
NSString * const RRFSessionLastRunDateKey;
NSString * const RRFSessionComponentsKey;
NSString * const RRFSessionComponentsDefinitionKey;
NSString * const RRFSessionComponentsJumpsKey;
NSString * const RRFSessionComponentsOffsetKey;
NSString * const RRFSessionHistoryKey;
NSString * const RRFSessionRunKey;

#pragma mark Environmental Constants
NSString * const RRFSessionPathToRegistryFileKey;

@end 
