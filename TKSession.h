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

@end 
