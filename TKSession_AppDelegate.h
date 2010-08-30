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

@end

extern NSString * const TKSessionBundleDirectoryKey;
extern NSString * const TKSessionBundleManifestDirectoryKey;
extern NSString * const TKSessionPreferencesFileNameKey;
extern NSString * const TKSessionPreferencesFileExtensionKey;
extern NSString * const TKSessionSessionManifestDirectoryKey;
extern NSString * const TKSessionSubjectFileNameKey;
extern NSString * const TKSessionSubjectFileExtensionKey;

