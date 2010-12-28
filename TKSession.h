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
  NSDictionary *manifest;               // the manifest, or definition for
                                        // the currently loaded session
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
  NSDictionary *components;             // the block of components currently
                                        // loaded
  NSInteger currentComponentID;         // the ID of the current component (in
                                        // this case current ranges from about
                                        // to be launched to componentDidFinish)  
  TKSubject *subject;                   // the subject object created during
                                        // setup
}

@property(readonly) NSDictionary *manifest;
@property(readonly) NSDictionary *components;
@property(nonatomic, retain) TKSubject *subject;

- (void)componentDidBegin: (NSNotification *)info;
- (void)componentDidFinish: (NSNotification *)info;
- (void)componentWillBegin: (NSNotification *)info;
/**
 launchComponentWithID:
 Discussion - Attempts to launch the component whose ID value corresponds to the value of 
 componentID given. A componentID of zero constitutes the end of components.
 Return Value - Will return YES if component was identified and could begin,
 otherwise will return NO.
 */
- (BOOL)launchComponentWithID: (NSInteger)componentID;
- (BOOL)loadSessionFromFilePath: (NSString *)pathToFile;
- (BOOL)passedPreflightCheck: (NSString **)errorString;
- (BOOL)run;

#pragma mark Registry Accessors
- (NSDictionary *)registryForTask: (NSInteger)taskID;
- (NSDictionary *)registryForLastTask;
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset;

#pragma mark Registry Setters
- (BOOL)setValue: (id)newValue forRegistryKey: (NSString *)key;

#pragma mark Preference Keys
NSString * const RRFSessionProtocolKey;
NSString * const RRFSessionDescriptionKey;
NSString * const RRFSessionCreationDateKey;
NSString * const RRFSessionModifiedDateKey;
NSString * const RRFSessionStatusKey;
NSString * const RRFSessionLastRunDateKey;
NSString * const RRFSessionComponentsKey;
NSString * const RRFSessionComponentsDefinitionKey;
NSString * const RRFSessionComponentsJumpsKey;
NSString * const RRFSessionHistoryKey;
NSString * const RRFSessionRunKey;

@end 
