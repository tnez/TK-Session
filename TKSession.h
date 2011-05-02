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
@class TKFileMoveQueue;
@class TKRegistry;

@interface TKSession : NSObject {
  NSDictionary *components;             // the block of components currently
                                        // loaded  
  NSString *currentComponentID;         // the ID of the current component (in
                                        // this case current ranges from about
                                        // to be launched to componentDidFinish)
  NSString *dataDirectory;              // path to data directory to use for
                                        // this session
  NSDictionary *manifest;               // the manifest, or definition for
                                        // the currently loaded session
  TKFileMoveQueue *moveQueue;           // queue of files to be moved
  TKRegistry *registry;                 // information pertaining to the current
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
  TKComponentController *compObj;       // the actual component object
  TKSubject *subject;                   // the subject object created during
                                        // setup
  NSWindow *sessionWindow;              // this is the window that bundles use
}

@property(readonly) NSDictionary *components;
@property(readonly) NSString *currentComponentID;
@property(readonly) NSString *dataDirectory;
@property(readonly) NSDictionary *manifest;
@property(readonly) TKFileMoveQueue *moveQueue;
@property(nonatomic, retain) TKComponentController *compObj;
@property(nonatomic, retain) TKSubject *subject;
@property(assign) NSWindow *sessionWindow;

/**
   The component instance did begin.

   This method is to be considered unreliable. If you need to know
   when a component is to begin, use componentWillBegin, which will
   always be sent before the component begins, while this method, may
   return much later than expected due to issues with the way the
   components run loop is handled.
*/
- (void)componentDidBegin: (NSNotification *)info;

/**
   The previously running component did finish.
*/
- (void)componentDidFinish: (NSNotification *)info;

/**
   The current component is about to begin.
   
   This should be used rather than componentDidBegin due to
   reliability issues.
*/
- (void)componentWillBegin: (NSNotification *)info;

/**
   Initialize a session instance with the given session configuration
   file.

   @param filename The fullpath to the session configuration file to
   be used for this session.

   @return The session instance.
 */
- (id)initWithFile: (NSString *)filename;

/**
   Attempt to launch a component with the given ID.

   @param componentID The component ID as a string, as defined in the
   session configuration file, which you wish to launch. The component
   ID 'end' is a reserved value and signifies that the session is
   complete and should be torn down.

   @return YES if the component was successfully launched, otherwise
   NO.
*/
- (BOOL)launchComponentWithID: (NSString *)componentID;

/**
   This is strange, but I don't think this is called anywhere. This is
   a ghost-line, its like a ghost town. It was created somewhere in
   the design process, and then deserted, leaving nothing but empty
   saloons and blowing tumbleweeds. But I dare not delete, for the
   Society for the Preservation of Extraneous Code, or S.P.E.C., is
   surely not to be trifled with!
 */
- (BOOL)loadSessionFromFilePath: (NSString *)pathToFile;

/**
   Does the session pass its prefilight check?

   @param errorString A pointer to a string which will hold the error
   string upon return.
   
   @return YES if the session passes its preflight check. It is not
   possible to detect run-time errors because the session is not
   actually run. Only setup requirements can be checked.
*/
- (BOOL)passedPreflightCheck: (NSString **)errorString;

/**
   Attempt the recovery process.

   @return YES if the recovery process was successful and we have
   launched our first component.
*/
- (BOOL)recoverFromCrash;

/**
   Start the actual session, return YES upon success.
 */
- (BOOL)run;

/**
   The finalization process that should be done when the session has
   finished.

   Here files queued for move, if any (these are used with the
   stand-alone Cocoa Apps), and temp files are cleaned up.
 */
- (void)tearDown;

#pragma mark Registry Accessors

/**
   Return registry corresponding to given task ID... returns nil if
   not found.

   @param taskID The ID of the target task as defined in the session
   configuration file.
*/
- (NSDictionary *)registryForTask: (NSString *)taskID;

/**
   Return copy of entire dictionary belonging to the last completed task
   Should return nil if last task cannot be found
*/
- (NSDictionary *)registryForLastTask;

/**
   Registry for the task using the given offset value.

   @param offset How far offset is the target task from the current
   task? -1 represents the last completed task, -n represents the task
   completed n tasks-ago. 1 equals the first task, n represents nth
   completed task starting at the beginning. 0 represents the current
   task.
*/
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset;

/**
   Value for registry key path (this is nescesary for bundles to
   effectively share information through the registry)

   @param aKeyPath The key path you wish to query, from the
   root of the registry file.

   @return The object associated with the given key path, or
   nil, if the key path given could not be located in the registry.
*/
- (id)valueForRegistryKeyPath: (NSString *)aKeyPath;

#pragma mark Registry Setters

/**
   Set value for given global key for the current task

   @param newValue The new value you wish to store.

   @param key The key with which you would like to associate the new
   value.
*/
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key;

/**
   Set value for given key for current run of current task

   @param newValue The new value you wish to store.

   @param key The key with which you would like to associate the new
   value.
*/
- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key;

@end 

#pragma mark Preference Keys
NSString * const RRFSessionProtocolKey;
NSString * const RRFSessionSubjectKey;
NSString * const RRFSessionSessionKey;
NSString * const RRFSessionMachineKey;
NSString * const RRFSessionDescriptionKey;
NSString * const RRFSessionDataDirectoryKey;
NSString * const RRFSessionStartKey;
NSString * const RRFSessionStartTaskKey;
NSString * const RRFSessionEndKey;
NSString * const RRFSessionCreationDateKey;
NSString * const RRFSessionModifiedDateKey;
NSString * const RRFSessionStatusKey;
NSString * const RRFSessionLastRunDateKey;
NSString * const RRFSessionComponentsKey;
NSString * const RRFSessionComponentsDefinitionKey;
NSString * const RRFSessionComponentsJumpsKey;
NSString * const RRFSessionComponentsOffsetKey;
NSString * const RRFSessionHistoryKey;
NSString * const RRFSessionRunKey;

#pragma mark Environmental Constants
NSString * const RRFSessionPathToFileMoveQueueKey;
