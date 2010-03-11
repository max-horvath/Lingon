/*
Lingon version 2.1.1, 2008-12-18
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/lingon

Copyright 2005-2008 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "LINStandardHeader.h"

#define THIS_VERSION 2.11

@implementation LINMainController


@synthesize currentPlistHasUnsavedChanges, plistChangesDictionary, hasInsertedView;


static id sharedInstance = nil;

+ (LINMainController *)sharedInstance
{ 
	if (sharedInstance == nil) { 
		sharedInstance = [[self alloc] init];
	} 
	return sharedInstance; 
} 


- (id)init 
{
	if (sharedInstance == nil) {
        sharedInstance = [super init];
    }
	
	plistChangesDictionary = [NSMutableDictionary dictionary];
	
    return sharedInstance;
}


+ (void)initialize
{
	NSValueTransformer *fontTransformer = [[LINFontTransformer alloc] init];
    [NSValueTransformer setValueTransformer:fontTransformer forName:@"FontTransformer"];
}


- (void)basicInitialisation
{
	SInt32 systemVersion;
	if (Gestalt(gestaltSystemVersion, &systemVersion) == noErr) {
		if (systemVersion < 0x1050) {
			[NSApp activateIgnoringOtherApps:YES];
			[LINVarious alertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"You need %@ or later to run this version of Lingon", @"You need %@ or later to run this version of Lingon"), @"Mac OS X 10.5 Leopard"] informativeText:NSLocalizedString(@"Go to the web site (http://tuppis.com/lingon) to download another version for an earlier Mac OS X system", @"Go to the web site (http://tuppis.com/lingon) to download another version for an earlier Mac OS X system") defaultButton:OK_BUTTON alternateButton:nil otherButton:nil];
			
			[NSApp terminate:nil];
		}
	}
	

	
	[[LINPreferencesController sharedInstance] setDefaults];
	
	if ([[LINDefaults valueForKey:@"CheckForUpdatesInterval"] intValue] != LINCheckForUpdatesNever) {
		BOOL checkForUpdates = NO;
		if ([LINDefaults valueForKey:@"LastCheckForUpdateDate"] == nil) {
			checkForUpdates = YES;
		} else { 
			NSDate *lastCheckDate = [NSUnarchiver unarchiveObjectWithData:[LINDefaults valueForKey:@"LastCheckForUpdateDate"]];
			if ([[LINDefaults valueForKey:@"CheckForUpdatesInterval"] intValue] == LINCheckForUpdatesDaily) {
				if ([[lastCheckDate addTimeInterval:(60 * 60 * 24)] compare:[NSDate date]] == NSOrderedAscending) {
					checkForUpdates = YES;
				}
			} else if ([[LINDefaults valueForKey:@"CheckForUpdatesInterval"] intValue] == LINCheckForUpdatesWeekly) {
				if ([[lastCheckDate addTimeInterval:(60 * 60 * 24 * 7)] compare:[NSDate date]] == NSOrderedAscending) {
					checkForUpdates = YES;
				}
			} else if ([[LINDefaults valueForKey:@"CheckForUpdatesInterval"] intValue] == LINCheckForUpdatesMonthly) {
				if ([[lastCheckDate addTimeInterval:(60 * 60 * 24 * 30)] compare:[NSDate date]] == NSOrderedAscending) {
					checkForUpdates = YES;
				}
			}
		}
		
		if (checkForUpdates == YES) {
			checkForUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkForUpdate) userInfo:nil repeats:NO] retain];
		}									
	}
}


- (void)checkForUpdate
{	
	if (checkForUpdateTimer != nil) {
		[checkForUpdateTimer invalidate];
		checkForUpdateTimer = nil;
	}
	
	[NSThread detachNewThreadSelector:@selector(checkForUpdateInSeparateThread) toTarget:self withObject:nil];
}


- (void)checkForUpdateInSeparateThread
{
	SCNetworkConnectionFlags status; 
	BOOL success = SCNetworkCheckReachabilityByName("lingon.sourceforge.net", &status); 
	BOOL connected = success && (status & kSCNetworkFlagsReachable) && !(status & kSCNetworkFlagsConnectionRequired); 
	if (connected) {
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://lingon.sourceforge.net/checkForUpdate.plist"]];
		if (dictionary) {
			float thisVersion = THIS_VERSION;
			float latestVersion = [[dictionary valueForKey:@"latestVersion"] floatValue];
			if (latestVersion > thisVersion) {
				[self performSelectorOnMainThread:@selector(updateInterfaceOnMainThreadAfterCheckForUpdateFoundNewUpdate:) withObject:dictionary waitUntilDone:YES];
			} else {
				[self performSelectorOnMainThread:@selector(updateInterfaceOnMainThreadAfterCheckForUpdateFoundNewUpdate:) withObject:nil waitUntilDone:YES];
			}
			
			[LINDefaults setValue:[NSArchiver archivedDataWithRootObject:[NSDate date]] forKey:@"LastCheckForUpdateDate"];
		}
	}
	
}


- (void)updateInterfaceOnMainThreadAfterCheckForUpdateFoundNewUpdate:(id)sender
{
	if (sender != nil && [sender isKindOfClass:[NSDictionary class]]) {
		NSInteger returnCode = [LINVarious alertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"A newer version (%@) is available. Do you want to download it?", @"A newer version (%@) is available. Do you want to download it? in checkForUpdate"), [sender valueForKey:@"latestVersionString"]] informativeText:@"" defaultButton:NSLocalizedString(@"Download", @"Download-button") alternateButton:CANCEL_BUTTON otherButton:nil];
		if (returnCode == NSAlertFirstButtonReturn) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender valueForKey:@"url"]]];
		}
		
	} else {
		if ([[[LINPreferencesController sharedInstance] preferencesWindow] isVisible] == YES) {
			[[[LINPreferencesController sharedInstance] noUpdateAvailableTextField] setHidden:NO];
			hideNoUpdateAvailableTextFieldTimer = [[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(hideNoUpdateAvailableTextField) userInfo:nil repeats:NO] retain];
		}
	}
	
}


- (void)hideNoUpdateAvailableTextField
{
	if (hideNoUpdateAvailableTextFieldTimer) {
		[hideNoUpdateAvailableTextFieldTimer invalidate];
		hideNoUpdateAvailableTextFieldTimer = nil;
	}
	
	[[[LINPreferencesController sharedInstance] noUpdateAvailableTextField] setHidden:YES];
}


- (void)currentPlistChanged
{
	if (currentPlistHasUnsavedChanges == NO) {
		currentPlistHasUnsavedChanges = YES;
		[[LINInterface mainWindow] setDocumentEdited:YES];
		
		NSToolbarItem *saveToolbarItem = [[LINToolbarController sharedInstance] saveToolbarItem];
		
		[(NSControl *)[[[saveToolbarItem view] subviews] objectAtIndex:0] setEnabled:YES];
		[[(NSControl *)[[[saveToolbarItem view] subviews] objectAtIndex:0] cell] setEnabled:YES];
	}
}


- (void)resetCurrentPlistChanged
{
	currentPlistHasUnsavedChanges = NO;
	[[LINInterface mainWindow] setDocumentEdited:NO];
	
	NSToolbarItem *saveToolbarItem = [[LINToolbarController sharedInstance] saveToolbarItem];
	
	[(NSControl *)[[[saveToolbarItem view] subviews] objectAtIndex:0] setEnabled:NO];
	[[(NSControl *)[[[saveToolbarItem view] subviews] objectAtIndex:0] cell] setEnabled:NO];
}

@end
