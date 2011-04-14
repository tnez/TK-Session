////////////////////////////////////////////////////////////
//  TKRegistry.h
//  TK-Session
//  --------------------------------------------------------
//  Author: Travis Nesland <tnesland@gmail.com>
//  Created: 4/7/11
//  Copyright 2011 Residential Research Facility, University
//  of Kentucky. All Rights Reserved.
/////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>
@class TKSession;


@interface TKRegistry : NSObject {
  NSMutableDictionary *data;  // the actual dictionary holding our data
  BOOL isDirty;               // has the registry changed since last write to
                              // disk
  TKSession *session;         // the session to which registry is attached  
  BOOL stop;                  // flag to stop the background thread
  NSUInteger writeInterval;   // interval (in milleseconds) with which we will
                              // write out to file if dirty
  NSString *writePath;        // path to which we will write
}

@property (readwrite) BOOL isDirty;
@property (assign) TKSession *session;
@property (readwrite) BOOL stop;
@property (readwrite) NSUInteger writeInterval;

/**
 Initialize the registry object using an existing registry on disk
 @param NSString* _fullPathToFile The path where the existing registry is sitting on disk.
 @return Returns pointer to the new registry instance, nil if it could not be created
 */
- (id)initWithContentsOfFile: (NSString *)_fullPathToFile;

/**
 Initialize the registry object
 @param NSString* _writePath The path where we want the registry file to be written.
 @return Returns pointer to registry instance, nil if it could not be created
 
 This will initialize the registry file and begin an internal run loop on a new thread that will write the registry to disk on a specified interval, every time there are changes yet to be committed.
 */
- (id)initWithPath: (NSString *)_writePath;

#pragma mark Accessors
/**
 The full path for the disk representation of the registry.
 */
- (NSString *)fullPath;

/**
 Get registry for task ID
 @param NSString* taskID The ID that corresponds to the you wish to retreive. Should correspond to handle in the session definition.
 @return Returns an immutable copy registry for matching task. Returns nil if no match is found.
 */
- (NSDictionary *)registryForTask: (NSString *)taskID;

/**
 Get registry for last completed task (this is not the same as the current task).
 @return Returns an immutable copy of registry for last completed task.
 */
- (NSDictionary *)registryForLastTask;

/**
 Get registry for task with the given offset.
 @param NSInteger offset Positive values are offset from the first run task forward. Zero is the current task. Negative values are offset from the last run task moving backward.
 @return Returns an immutable copy of the registry or nil if the offset is invalid.
 */
- (NSDictionary *)registryForTaskWithOffset: (NSInteger)offset;

/**
 Get the temporary storage path for registry files.
 @return NSString * The full standardized path to the temporary storage location for registry files.
 */
+ (NSString *)temporaryPath;

/**
 Get the value associated with the given key.
 @param NSString * key The key associated with the value you are looking for. May not be nil.
 @return id Returns the value associated with the given key, or nil, if the key is not found.
 */
- (id)valueForKey: (NSString *)key;

/**
 Get the value associated with the given key path.
 @param NSString * keyPath The key path you wish to retrieve.
 @return id Returns the value associated with the given key-path, or nil, if the key-path is not found.
 */
- (id)valueForKeyPath: (NSString *)keyPath;

#pragma mark Setters
/**
 Initialize a new run registry for the given component ID if needed.
 @param NSString * componentID The component ID for which to create a new run registry.
 
 This method firsts checks if the component ID needs a new run registry. This will be the case if either the component's run registry is currently empty, or the most recent run registry contains a valid end key. If neither of these two conditions are satisfied, then we are attempting to recover the component, thus no new run registry should be created.
 */
- (void)initializeRegistryForComponentRun: (NSString *)componentID;

/**
 Set a value at the top-level of the registry.
 @param id newValue The value you wish to store.
 @param NSString * key The key with which you wish to associate the value.
*/
- (void)setValue: (id)newValue forKey: (NSString *)key;

/**
 Set a value for a task-wide registry key.
 @param NSString* key A string representing the key. If the key does not yet exists, it will be created. Must not be nil.
*/
- (void)setValue: (id)newValue forRegistryKey: (NSString *)key;

/**
 Set a value for a key in the current run of the current task.
 @param NSString* key A string representing the key. If the key does not yet exists, it will be created. Must not be nil.
*/
- (void)setValue: (id)newValue forRunRegistryKey: (NSString *)key;

#pragma mark File Operations
/**
 Move the registry to new path
 @param NSString* _fullPath Full and standardized path representing move target for registry.
 @return YES if file was moved successfully, otherwise NO.
 */
- (BOOL)moveToPath: (NSString *)_fullPath;

#pragma mark COSTANTS
extern NSString * const RRFRegistryComponentsKey;
extern NSString * const RRFRegistryComponentEndKey;
extern NSString * const RRFRegistryComponentStartKey;
extern NSString * const RRFRegistryHistoryKey;
extern NSString * const RRFRegistryRunKey;
extern NSString * const RRFRegistryTemporaryPathKey;

@end
