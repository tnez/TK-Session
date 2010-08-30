////////////////////////////////////////////////////////////
//  TKSession_AppDelegate.h
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>

/** Text Expansion */
#define TK_SESSION_PATH_TO_PREFERENCES [[NSBundle mainBundle] pathForResource:TKSessionPreferencesFileName ofType:TK_SESSION_PREFERENCE_FILE_TYPE]
#define TK_SESSION_PREFERENCE_FILE_TYPE TKSessionPreferencesFileExtension
#define TK_SESSION_PATH_TO_BUNDLES [appPreferences valueForKey:TKSessionBundleDirectoryKey]
#define TK_SESSION_PATH_TO_BUNDLE_MANIFESTS [appPreferences valueForKey:TKSessionBundleManifestDirectoryKey]
#define TK_SESSION_PATH_TO_SESSION_MANIFESTS [appPreferences valueForKey:TKSessionManifestDirectoryKey]
#define TK_SESSION_PATH_TO_SUBJECTS_FILE [[NSBundle mainBundle] pathForResource:[appPreferences valueForKey:TKSessionSubjectFileNameKey] ofType:TK_SESSION_SUBJECTS_FILE_TYPE]
#define TK_SESSION_SUBJECTS_FILE_TYPE [appPreferences valueForKey:TKSessionSubjectFileExtensionKey]

@interface TKSession_AppDelegate : NSObject {
    
    NSArray                                 *availableComponents;
    NSMutableDictionary                     *appPreferences;
    NSString                                *errorLog;
    
    /** Interface Elements */
    IBOutlet NSWindow                       *adminWindow;
    IBOutlet NSView                         *availableComponentView;
    IBOutlet NSView                         *componentView;
    IBOutlet NSView                         *errorLog;
    IBOutlet NSView                         *sessionView;
    IBOutlet NSView                         *subjectView;
    IBOutlet NSWindow                       *sessionWindow;
}

@property(readonly) NSArray                 *availableComponents;
@property(readonly) NSMutableDictionary     *appPreferences;
@property(readonly) NSString                *errorLog;
@property(assign)   IBOutlet NSWindow       *adminWindow;
@property(assign)   IBOutlet NSView         *availableComponentView;
@property(assign)   IBOutlet NSView         *componentView;
@property(assign)   IBOutlet NSView         *errorLog;
@property(assign)   IBOutlet NSView         *sessionView;
@property(assign)   IBOutlet NSView         *subjectView;
@property(assign)   IBOutlet NSWindow       *sessionWindow;

- (BOOL)importBundle: (NSString*)pathToNewBundle;
- (IBAction)editPreferences: (id)sender;
- (BOOL)readAvailableComponents: (NSString *)pathToManifestsDirectory;
- (void)readPreferences: (NSString *)preferencesFileName;
+ (NSDictionary *)sharedPreferences;

@end

extern NSString * const TKSessionBundleDirectoryKey;
extern NSString * const TKSessionBundleManifestDirectoryKey;
extern NSString * const TKSessionPreferencesFileName;
extern NSString * const TKSessionPreferencesFileExtension;
extern NSString * const TKSessionSessionManifestDirectoryKey;
extern NSString * const TKSessionSubjectFileNameKey;
extern NSString * const TKSessionSubjectFileExtensionKey;

