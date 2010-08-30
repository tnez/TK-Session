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
        [self readPreferences:TKSessionPreferencesFileNameKey];
        [self readAvailableComponents:TKSessionBundleManifestDirectoryKey];
        return self;
    }
    return nil;
}

- (BOOL)importBundle: (NSString *)pathToNewBundle {
    // TODO: copy bundle in to bundle directory and manifest to directory
    return NO;
}

@end
