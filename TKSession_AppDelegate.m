////////////////////////////////////////////////////////////
//  TKSession_AppDelegate.m
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 8/29/10
//  Copyright 2010 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////
#import "TKSession_AppDelegate.h"
#import "TKSession.h"
#import "TKSubjects.h"

@implementation TKSession_AppDelegate
@synthesize availableComponents,errorLog,adminWindow,availableComponentView,
componentView,errorLog,sessionView,subjectView,sessionWindow;

- (void)dealloc {
    [availableComponents release];
    [errorLog release];
    [super dealloc];
}

- (id)init {
    if(self=[super init]) {
        [NSApp setDelegate:self];
        errorLog = [[NSString alloc] initWithString:@""];
        [self readPreferences:TK_SESSION_PATH_TO_PREFERENCES];
        [self readAvailableComponents:TK_SESSION_PATH_TO_BUNDLE_MANIFESTS];
        return self;
    }
    return nil;
}

- (BOOL)importBundle: (NSString *)pathToNewBundle {
    // TODO: copy bundle in to bundle directory and manifest to directory
    return NO;
}

- (IBAction)editPreferences: (id)sender {
    // TODO: open application preferences nib
}

- (BOOL)readAvailableComponents: (NSString *)pathToManifestDirectory {
    // TODO: for each document in this directory that satisfies manifest requirements
    //          create an NSDictionary in the NSArray of available components
}

- (void)readPreferences: (NSString *)preferencesFileName {
    // TODO: check that preferences are of type NSDictionary
    //          read dictionary into appPreferences
}

+ (NSDictionary *)sharedPreferences {
    return (NSDictionary *)appPreferences;
}

@end

/** Constants and External Values */
NSString * const TKSessionPreferencesFileName = @"AppPreferences";
NSString * const TKSessionPreferencesFileExtension = @"plist";

/** Preference Keys */
NSString * const TKSessionBundleDirectoryKey = @"TKSessionBundleDirectory";
NSString * const TKSessionBundleManifestDirectoryKey = @"TKSessionBundleManifestDirectory";
NSString * const TKSessionSessionManifestDirectoryKey = @"TKSessionManifestDirectory";
NSString * const TKSessionSubjectFileNameKey = @"TKSessionSubjectFileName";
NSString * const TKSessionSubjectFileExtensionKey = @"TKSessionSubjectFileExtension";