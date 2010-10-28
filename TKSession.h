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
    TKSubject                               *subject;

}

@property(readonly) NSMutableDictionary     *manifest;
@property(readonly) NSMutableArray          *components;
@property(readonly) TKSubject               *subject;

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
