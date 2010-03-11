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


@implementation LINPreferencesController

@synthesize preferencesWindow, noUpdateAvailableTextField;

static id sharedInstance = nil;

+ (LINPreferencesController *)sharedInstance
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


- (void)setDefaults
{	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setValue:[NSNumber numberWithInteger:LINListSizeSmall] forKey:@"ListFontSize"];
	[dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"CheckForUpdatesAtStartup"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"WarnAboutSystemFiles"];
	[dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"InformAboutWhatIsNeededAfterSave"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Monaco" size:11]] forKey:@"TextFont"];
	[dictionary setValue:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] forKey:@"LastDirectory"];
	[dictionary setValue:[NSNumber numberWithInteger:LINCheckForUpdatesNever] forKey:@"CheckForUpdatesInterval"];
	[dictionary setValue:[NSNumber numberWithInteger:LINBasicMode] forKey:@"Mode"];
	[dictionary setValue:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Monaco" size:11]] forKey:@"TextFont"];
	
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dictionary];
	
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.ListFontSize" options:NSKeyValueObservingOptionNew context:@"ListFontSizeChanged"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([(NSString *)context isEqualToString:@"ListFontSizeChanged"]) {
		[[LINInterface plistsOutlineView] reloadData];
		
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
}


- (IBAction)checkNowAction:(id)sender
{
	[noUpdateAvailableTextField setHidden:YES];
	[[LINMainController sharedInstance] checkForUpdate];	
}


- (IBAction)resetAllWarningsAction:(id)sender
{
	[LINDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"WarnAboutSystemFiles"];
	[LINDefaults setValue:[NSNumber numberWithBool:YES] forKey:@"InformAboutWhatIsNeededAfterSave"];
}


- (IBAction)showFontPanelAction:(id)sender
{
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	[fontManager setSelectedFont:[NSUnarchiver unarchiveObjectWithData:[LINDefaults valueForKey:@"TextFont"]] isMultiple:NO];
	[fontManager orderFrontFontPanel:nil];
}


- (IBAction)showPreferencesAction:(id)sender
{
	if (preferencesWindow == nil) {
		[NSBundle loadNibNamed:@"LINPreferences.nib" owner:self];
	}
	
	[preferencesWindow makeKeyAndOrderFront:nil];
}


@end
