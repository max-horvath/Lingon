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


@implementation LINOutlineViewDelegate

static id sharedInstance = nil;

+ (LINOutlineViewDelegate *)sharedInstance
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
		hasAlreadyBeenShownSystemWarningThisSession = NO;
    }
    return sharedInstance;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if ([item isLeaf] == NO) {
		return YES;
	} else {
		return NO;
	}
}


- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if ([[LINDefaults valueForKey:@"ListFontSize"] integerValue] == LINListSizeSmall) {
		[cell setFont:[NSFont systemFontOfSize:11.0]];
	} else {
		[cell setFont:[NSFont systemFontOfSize:13.0]];
	}
	
	if ([item isLeaf] == YES) {
		[(LINPlistListCell *)cell setImage:[[item representedObject] valueForKey:@"icon"]];
	} else {
		[(LINPlistListCell *)cell setImage:nil];
	}

}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	if ([item isLeaf] == NO) {
		return NO;
	}
	
	if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINExpertMode && [LINMain hasInsertedView] == YES) {
		if ([LINVarious shouldUpdateDictionaryFromExpertString] == NO) {
			return NO;
		}
	}
	
	if ([LINVarious shouldWeCloseTheCurrentPlist] == YES) {
	
		[[LINInterface mainWindow] setTitle:[NSString stringWithFormat:@"%@ - Lingon", [[item representedObject] valueForKey:@"name"]]];
		[[LINInterface mainWindow] setRepresentedFilename:[[item representedObject] valueForKey:@"path"]];
		
		if ([[[item representedObject] valueForKey:@"parentDirectory"] isEqualToString:SYSTEMAGENTS] || [[[item representedObject] valueForKey:@"parentDirectory"] isEqualToString:SYSTEMDAEMONS]) {
			if (hasAlreadyBeenShownSystemWarningThisSession == NO) {
				[LINVarious standardAlertSheetWithMessage:NSLocalizedString(@"You are strongly recommended not to change the Apple-supplied configuration files in System Agents and System Daemons unless you know what you are doing", @"You are strongly recommended not to change the Apple-supplied configuration files in System Agents and System Daemons unless you know what you are doing") informativeText:NSLocalizedString(@"You can possibly leave your system inoperable if certain changes are made. Although I have tested as much as I can, absolutely no guarantees can be given to changes to these.", @"You can possibly leave your system inoperable if certain changes are made. Although I have tested as much as I can, absolutely no guarantees can be given to changes to these.") suppressionString:@"WarnAboutSystemFiles"];
				hasAlreadyBeenShownSystemWarningThisSession = YES;
			}
			
		}
		
		[[LINMain plistChangesDictionary] removeAllObjects];
		
		return YES;
		
	} else {
		return NO;
	}
	
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	
	if ([LINMain hasInsertedView] == NO) {
		
		[[[LINInterface modeButton] animator] setAlphaValue:1.0];
		
		NSView *oldView = [[[LINInterface splitView] subviews] objectAtIndex:1];
		if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINBasicMode) {
			[[LINInterface basicView] setFrame:[oldView bounds]];
			[[LINInterface modeButton] setTitle:EXPERT_MODE_TITLE];
			[LINVarious changeToBasicMode];
			[LINInterface changeViewWithAnimationForOldView:[LINInterface expertView] newView:[LINInterface basicView]];
		} else {
			[[LINInterface expertView] setFrame:[oldView bounds]];
			[[LINInterface modeButton] setTitle:BASIC_MODE_TITLE];
			[LINVarious changeToExpertMode];
			[LINInterface changeViewWithAnimationForOldView:[LINInterface basicView] newView:[LINInterface expertView]];
		}
		
		[LINMain setHasInsertedView:YES];
	} else {
		if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINExpertMode) {
			[LINVarious changeToExpertMode]; // The expert view needs updating
		}
	}
}



- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	return [[item representedObject] valueForKey:@"path"];
}


- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object
{
	return object;
}


- (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation
{
	if ([item isLeaf] == NO) {
		return [[item representedObject] valueForKey:@"plistCount"];
	} else {
		return [[item representedObject] valueForKey:@"plistString"];
	}
}


- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{	
	id object = [[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0];
	
	if (object == nil) {
		return NO;
	}
	
	NSArray *fileList = [NSArray arrayWithObject:[object valueForKey:@"path"]];
	
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	
	return YES;
}

@end
