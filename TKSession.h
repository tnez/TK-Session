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
class TKSubject;

@interface TKSession : NSObject {
  NSDictionary *manifest;               // the manifest, or definition for
                                        // the currently loaded session
  NSDictionary *components;             // the block of components currently
                                        // loaded
  TKSubject *subject;                   // the subject object created during
                                        // setup
}

@property(readonly) NSMutableDictionary *manifest;
@property(readonly) NSMutableArray *components;
@property(nonatomic, retain) TKSubject *subject;

#pragma mark Session Run Functions
- (BOOL)loadSessionFromFilePath: (NSString *)pathToFile;
- (BOOL)passedPreflightCheck: (NSString **)errorString;
- (BOOL)run;

#pragma mark Preference Keys
extern NSString * const RRFSessionProtocolKey;
extern NSString * const RRFSessionDescriptionKey;
extern NSString * const RRFSessionCreationDateKey;
extern NSString * const RRFSessionModifiedDateKey;
extern NSString * const RRFSessionStatusKey;
extern NSString * const RRFSessionLastRunDateKey;
extern NSString * const RRFSessionComponentsKey;
extern NSString * const RRFSessionComponentsJumpsKey;

@end 
