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


@implementation LINFileMenuController

static id sharedInstance = nil;

+ (LINFileMenuController *)sharedInstance
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
    return sharedInstance;
}


- (IBAction)newAction:(id)sender
{
	if ([LINVarious shouldWeCloseTheCurrentPlist]) {
		[NSApp beginSheet:[LINInterface whichFolderSheet] modalForWindow:[LINInterface mainWindow] modalDelegate:LINInterface didEndSelector:nil contextInfo:nil];
	}
}


- (IBAction)saveAction:(id)sender
{
	[self performSave];
}


- (BOOL)performSave
{
	[[LINInterface plistsTreeController] commitEditing];
	
	if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINExpertMode && [LINMain hasInsertedView] == YES) {
		if ([LINVarious shouldUpdateDictionaryFromExpertString] == NO) {
			return NO;
		}
	}
	
	id object = [[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0];
	
	if ([object valueForKeyPath:@"plist.Label"] == nil || [[object valueForKeyPath:@"plist.Label"] length] < 1 || [object valueForKeyPath:@"temporaryPlist.What"] == nil || [[object valueForKeyPath:@"temporaryPlist.What"] length] < 1) {
		[LINVarious standardAlertSheetWithMessage:NSLocalizedString(@"All needed values are not filled out", @"All needed values are not filled out") informativeText:NSLocalizedString(@"You need to write at least a value under Name and What", @"You need to write at least a value under Name and What") suppressionString:nil];
		return NO;
	}
	
	if ([[LINDefaults valueForKey:@"InformAboutWhatIsNeededAfterSave"] boolValue] == YES) {
		[LINVarious standardAlertSheetWithMessage:NSLocalizedString(@"You need to restart or logout for changes to apply", @"You need to restart or logout for changes to apply") informativeText:NSLocalizedString(@"In order for any changes to be applied properly and for it to run as the correct user you need to restart your computer or just logout if you know that that is enough", @"In order for any changes to be applied properly and for it to run as the correct user you need to restart your computer or just logout if you know that that is enough") suppressionString:@"InformAboutWhatIsNeededAfterSave"];
	}
	
	BOOL shouldRefresh = NO;
	NSString *path;
	if ([[object valueForKey:@"isNewFile"] boolValue] == YES) {
		path = [NSString stringWithString:[[[object valueForKey:@"parentDirectory"] stringByAppendingPathComponent:[object valueForKeyPath:@"plist.Label"]] stringByAppendingPathExtension:@"plist"]];
		shouldRefresh = YES;
		[object setValue:path forKey:@"path"];
		[object setValue:[NSNumber numberWithBool:NO] forKey:@"isNewFile"];
		[object setValue:[object valueForKeyPath:@"plist.Label"] forKey:@"name"];
	} else {
		path = [NSString stringWithString:[object valueForKey:@"path"]];
	}
	
	NSMutableDictionary *dictionary;
	NSData *data;
	NSString *plistString;
	
	if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINExpertMode) {
		plistString = [[LINInterface expertTextView] string];
		data = [plistString dataUsingEncoding:NSUTF8StringEncoding];
		NSPropertyListFormat format;
		dictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:nil];
	} else {
		dictionary = [NSMutableDictionary dictionaryWithDictionary:[LINVarious finalDictionaryFromOriginal:[object valueForKey:@"plist"] temporary:[object valueForKey:@"temporaryPlist"]]];
		data = [NSPropertyListSerialization dataFromPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
		plistString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	if (dictionary == nil) {
		NSBeep();
	}
	
	
	if ([[object valueForKey:@"parentDirectory"] isEqualToString:MYAGENTS]) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:MYAGENTS] == NO) {
			[[NSFileManager defaultManager] createDirectoryAtPath:MYAGENTS attributes:nil];
		}
		
		if ([dictionary writeToFile:path atomically:YES]) {
			[LINMain resetCurrentPlistChanged];
			if (shouldRefresh) {
				[LINVarious refreshObject:object path:path];
			}
			[object setValue:plistString forKey:@"plistString"];
			return YES;
		} else {
			[LINVarious standardAlertSheetWithMessage:[NSString stringWithFormat:UKNOWN_ERROR_WHEN_SAVING, [object valueForKey:@"path"]] informativeText:PLEASE_TRY_AGAIN suppressionString:nil];
			return NO;
		}
	} else {
		BOOL result = [[LINAuthenticationController sharedInstance] performAuthenticatedSaveOfData:data path:path];
		if (result == YES) {
			[object setValue:plistString forKey:@"plistString"];
			if (shouldRefresh == YES) {
				[LINVarious refreshObject:object path:path];
			}
		}
		
		return result;
	}
			
}

- (IBAction)showInFinderAction:(id)sender
{
	id object = [[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0];
	[[NSWorkspace sharedWorkspace] selectFile:[object valueForKey:@"path"] inFileViewerRootedAtPath:nil];
}


- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	BOOL enableMenuItem = YES;
	
	if ([anItem tag] == 1 || [anItem tag] == 2) { // Save, Show in Finder
		if ([[[LINInterface plistsTreeController] selectedObjects] count] == 0) {
			enableMenuItem = NO;
		}
		if ([anItem tag] == 1 && [LINMain currentPlistHasUnsavedChanges] == NO) {
			enableMenuItem = NO;
		}		
	}  else if ([anItem tag] == 3) {
		if ([LINMain currentPlistHasUnsavedChanges]) {
			enableMenuItem = NO;
		}
	}
	
	return enableMenuItem;
}


- (IBAction)refreshListAction:(id)sender
{
	if ([LINVarious shouldWeCloseTheCurrentPlist]) {

		NSArray *indexPaths = [[LINInterface plistsTreeController] selectionIndexPaths];
		//[[LINInterface plistsTreeController] setSelectionIndexPaths:[NSArray array]];

		[LINVarious updatePlistsOutlineView];
		[LINMain resetCurrentPlistChanged];
		[[LINInterface plistsTreeController] setSelectionIndexPaths:indexPaths];
	}
}
@end
