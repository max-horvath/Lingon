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


@implementation LINInterfaceController

@synthesize plistsTreeController, plistsOutlineView, mainWindow, whichFolderSheet, whichFolderMatrix, labelTextField, basicView, expertView, splitView, expertTextView, expertValidPlistIcon, expertTextField, insertParameterPopUp, validIcon, notValidIcon, modeButton, insertParametersArray;

static id sharedInstance = nil;

+ (LINInterfaceController *)sharedInstance
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


- (void)awakeFromNib
{
	LINPlistListCell *cell = [[LINPlistListCell alloc] init];
	[cell setWraps:NO];
	[cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[[plistsOutlineView tableColumnWithIdentifier:@"name"] setDataCell:cell];
	
	[LINVarious updatePlistsOutlineView];
	
	[plistsOutlineView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	[plistsOutlineView setDraggingSourceOperationMask:(NSDragOperationCopy) forLocal:NO];
	
	NSView *contentView = [[splitView subviews] objectAtIndex:1];
	LINDummyView *dummyView = [[LINDummyView alloc] initWithFrame:[contentView bounds]];
	[contentView addSubview:dummyView];
	
	[expertTextView setDelegate:[LINSyntaxColouring sharedInstance]];
	[[LINSyntaxColouring sharedInstance] setUpSyntaxColouring];
	
	validIcon = [NSImage imageNamed:@"LINValidIcon.pdf"];
	notValidIcon = [NSImage imageNamed:@"LINNotValidIcon.pdf"];
	
	[LINMain resetCurrentPlistChanged];

	
	insertParametersArray = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InsertParameters" ofType:@"plist"]];
	NSEnumerator *insertParametersArrayEnumerator = [insertParametersArray reverseObjectEnumerator];
	NSInteger index = [insertParametersArray count] - 1;
	NSMenuItem *menuItem;
	NSMenu *menu = [insertParameterPopUp menu];
	
	for (id item in insertParametersArrayEnumerator) {
		if ([item valueForKey:@"display"] != nil && ![[item valueForKey:@"display"] isEqualToString:@""]) {
			menuItem = [[NSMenuItem alloc] initWithTitle:[item valueForKey:@"display"] action:nil keyEquivalent:@""];
		} else {
			menuItem = [[NSMenuItem alloc] initWithTitle:[item valueForKey:@"key"] action:nil keyEquivalent:@""];
		}
		[menuItem setTag:index];
		[menuItem setTarget:LINVarious];
		[menuItem setAction:@selector(insertParameter:)];
		[menu insertItem:menuItem atIndex:2];
		index--;
	}
}


- (IBAction)cancelWhichFolderAction:(id)sender
{
	[NSApp endSheet:whichFolderSheet];
	[whichFolderSheet close];
}


- (IBAction)createWhichFolderAction:(id)sender
{
	[NSApp endSheet:whichFolderSheet];
	[whichFolderSheet close];
	
	NSInteger whichFolder = [whichFolderMatrix selectedRow];		
	
	NSIndexPath *folderIndexPath = [[NSIndexPath alloc] initWithIndex:whichFolder]; 
	
	NSMutableDictionary *subNode = [NSMutableDictionary dictionary];
	[subNode setValue:[NSNumber numberWithBool:YES] forKey:@"isLeaf"];
	[subNode setValue:@"" forKey:@"path"];
	
	if (whichFolder == LINWhichFolderUsersAgents) {
		[subNode setValue:USERSAGENTS forKey:@"parentDirectory"];
	} else if (whichFolder == LINWhichFolderUsersDaemons) {
		[subNode setValue:USERSDAEMONS forKey:@"parentDirectory"];
	} else {
		[subNode setValue:MYAGENTS forKey:@"parentDirectory"];
	}
	
	[subNode setValue:NSLocalizedString(@"untitled", @"untitled") forKey:@"name"];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	[subNode setValue:nil forKey:@"icon"];
	
	[subNode setValue:[NSNumber numberWithBool:YES] forKey:@"isNewFile"];
	
	[subNode setValue:dictionary forKey:@"plist"];
	[subNode setValue:[LINVarious temporaryDictionaryFromOriginal:dictionary] forKey:@"temporaryPlist"];
	[plistsTreeController insertObject:subNode atArrangedObjectIndexPath:[folderIndexPath indexPathByAddingIndex:0]];
	
	[mainWindow makeFirstResponder:labelTextField];
}


- (IBAction)setPathAction:(id)sender
{
	if ([[[LINInterface plistsTreeController] selectedObjects] count] < 1) {
		return;
	}
	
	NSInteger tag = [sender tag];
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setResolvesAliases:YES];
	[openPanel setAllowsMultipleSelection:NO];
	if (tag == 1) {
		[openPanel setCanChooseDirectories:YES];
		[openPanel setCanChooseFiles:YES];
	} else if (tag == 2) {
		[openPanel setCanChooseDirectories:NO];
		[openPanel setCanChooseFiles:YES];
	} else if (tag == 3) {
		[openPanel setCanChooseDirectories:YES];
		[openPanel setCanChooseFiles:NO];
	}
	[openPanel setTreatsFilePackagesAsDirectories:YES];
	
	[openPanel beginSheetForDirectory:[LINDefaults valueForKey:@"LastDirectory"] file:nil types:nil modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:(void *)sender];
	
}


- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		NSInteger tag = [(id)contextInfo tag];
	
		NSMutableString *path = [NSMutableString stringWithString:[[panel filenames] objectAtIndex:0]];
		
		[LINDefaults setValue:[path stringByDeletingLastPathComponent] forKey:@"LastDirectory"];
		
		NSMutableDictionary *dictionary= [[[[LINInterface plistsTreeController] selectedObjects] objectAtIndex:0] valueForKey:@"temporaryPlist"];
		
		if (tag == 1) { // What
			[path replaceOccurrencesOfString:@" " withString:@"\\ " options:NSLiteralSearch range:NSMakeRange(0, [path length])];
			if ([[path pathExtension] isEqualToString:@"app"]) {
				NSString *application = [NSString stringWithString:[[path lastPathComponent] stringByDeletingPathExtension]];
				NSString *testPath = [NSString stringWithString:[[[path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"MacOS"] stringByAppendingPathComponent:application]];
				if ([[NSFileManager defaultManager] fileExistsAtPath:testPath]) {
					[dictionary setValue:testPath forKey:@"What"];
				} else {
					[dictionary setValue:path forKey:@"What"];
				}
			} else {
				[dictionary setValue:path forKey:@"What"];
			}
		} else if (tag == 2) { // Watched file
			[dictionary setValue:path forKey:@"WatchPath"];
		} else if (tag == 3) { // Watched directory
			[dictionary setValue:path forKey:@"QueueDirectory"];
		}
	}
}


- (void)changeViewWithAnimationForOldView:(NSView *)oldView newView:(NSView *)newView 
{	
	NSView *contentView = [[[LINInterface splitView] subviews] objectAtIndex:1];
	
	[contentView setSubviews:[NSArray array]];
	[contentView addSubview:newView];
	
    NSDictionary *oldFadeOut = [NSDictionary dictionaryWithObjectsAndKeys:oldView, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
	
    NSDictionary *newFadeIn = [NSDictionary dictionaryWithObjectsAndKeys:newView, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
	
    NSArray *animations = [NSArray arrayWithObjects:newFadeIn, oldFadeOut, nil];
	
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [animation setDuration:0.32];
    [animation startAnimation];
}


- (IBAction)switchView:(id)sender
{
	
	NSView *oldView = [[[LINInterface splitView] subviews] objectAtIndex:1];
	if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINBasicMode) {
		[expertView setFrame:[oldView bounds]];
		[LINVarious changeToExpertMode];
		[self changeViewWithAnimationForOldView:basicView newView:expertView];
		[LINDefaults setValue:[NSNumber numberWithInteger:LINExpertMode] forKey:@"Mode"];
	} else {
		if ([LINVarious shouldUpdateDictionaryFromExpertString] == NO) {
			return;
		}
		if ([LINMain currentPlistHasUnsavedChanges]) { // No need to make any convert it if no changes have been made
			[LINVarious updateDictionaryFromExpertString];
		}
		
		[basicView setFrame:[oldView bounds]];
		[LINVarious changeToBasicMode];
		[self changeViewWithAnimationForOldView:expertView newView:basicView];
		[LINDefaults setValue:[NSNumber numberWithInteger:LINBasicMode] forKey:@"Mode"];
	}
	
}



@end
