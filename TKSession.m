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

@implementation TKSession
@synthesize manifest,components,availableComponents,subject,adminWindow,
availableComponentView,componentView,errorLog,sessionView,subjectView,sessionWindow;

- (void)dealloc {
    // nothing for now
    [super dealloc];
}

- (IBAction)edit: (id)sender {
    // TODO:
}

- (IBAction)insertComponent: (id)sender {
    // TODO:
}

- (void)load {
    // TODO:
}

- (IBAction)new: (id)sender {
    // TODO:
}

- (IBAction)preflight: (id)sender {
    // TODO:
}

- (IBAction)run: (id)sender {
    // TODO:
}

- (IBAction)save: (id)sender {
    // TODO:
}

@end

/** Preference Keys */
NSString * const TkSessionNameKey = @"TKSessionName";
