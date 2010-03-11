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


@implementation LINToolbarController

@synthesize saveToolbarItem;

static id sharedInstance = nil;

+ (LINToolbarController *)sharedInstance
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


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:@"LINNewToolbarItem",
		@"LINSaveToolbarItem",
		@"LINPreferencesToolbarItem",
		NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarSeparatorItemIdentifier,
		nil];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar  
{
	return [NSArray arrayWithObjects:@"LINNewToolbarItem",
		NSToolbarSpaceItemIdentifier,
		@"LINSaveToolbarItem",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"LINPreferencesToolbarItem",
		nil];
	
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
	if ([itemIdentifier isEqualToString:@"LINNewToolbarItem"]) {
		
		return [NSToolbarItem createToolbarItemWithIdentifier:itemIdentifier name:NSLocalizedString(@"New", @"New") image:[NSImage imageNamed:@"LINNewIcon"] action:@selector(new:) tag:0 target:self];
	
	} else if ([itemIdentifier isEqualToString:@"LINSaveToolbarItem"]) {
       
		saveToolbarItem = [NSToolbarItem createToolbarItemWithIdentifier:itemIdentifier name:NSLocalizedString(@"Save", @"Save") image:[NSImage imageNamed:@"LINSaveIcon"] action:@selector(save:) tag:0 target:self];
		return saveToolbarItem;
	
	} else {
		return nil;
	}
		
}


- (void)new:(id)sender
{
	[[LINFileMenuController sharedInstance] newAction:nil];
}


- (void)save:(id)sender
{
	[[LINFileMenuController sharedInstance] saveAction:nil];
}


- (void)preferences:(id)sender
{
	[[[LINPreferencesController sharedInstance] preferencesWindow] makeKeyAndOrderFront:nil];
}


//- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem 
//{
//	BOOL enableItem = YES;
//	
//	if ([toolbarItem tag] == 1) { // Save
//		if ([LINMain currentPlistHasUnsavedChanges] == NO) {
//			enableItem = NO;
//		}
//	}
//	
//    return enableItem;
//}

@end
