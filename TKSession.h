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

    /** Logical Elements */
    NSMutableDictionary                     *manifest;
    NSMutableArray                          *components;
    NSArray                                 *availableComponents;
    TKSubject                               *subject;

    /** Interface Elements */
    IBOutlet NSWindow                       *adminWindow;
    IBOutlet NSView                         *availableComponentView;
    IBOutlet NSView                         *componentView;
    IBOutlet NSView                         *errorLog;
    IBOutlet NSView                         *sessionView;
    IBOutlet NSView                         *subjectView;
    IBOutlet NSWindow                       *sessionWindow;

}

@property(readonly) NSMutableDictionary     *manifest;
@property(readonly) NSMutableArray          *components;
@property(readonly) NSArray                 *availableComponents;
@property(readonly) TKSubject               *subject;
@property(assign)   IBOutlet NSWindow       *adminWindow;
@property(assign)   IBOutlet NSView         *availableComponentView;
@property(assign)   IBOutlet NSView         *componentView;
@property(assign)   IBOutlet NSView         *errorLog;
@property(assign)   IBOutlet NSView         *sessionView;
@property(assign)   IBOutlet NSView         *subjectView;
@property(assign)   IBOutlet NSWindow       *sessionWindow;

- (IBAction)edit: (id)sender;
- (IBAction)insertComponent: (id)sender;
- (void)load;
- (IBAction)new: (id)sender;
- (IBAction)preflight: (id)sender;
- (IBAction)removeComponent: (id)sender;
- (IBAction)run: (id)sender;
- (IBAction)save: (id)sender;

@end

extern NSString                             * const TKSessionNameKey;
