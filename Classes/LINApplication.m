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


@implementation LINApplication


- (id)init
{
	self = [super init];
	if (self != nil) {

		[LINMain basicInitialisation];
		[self setDelegate:self];
		
	}
	return self;
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if ([LINVarious shouldWeCloseTheCurrentPlist]) {
		return NSTerminateNow;
	} else {
		return NSTerminateCancel;
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[[[LINInterface splitView] subviews] objectAtIndex:1] setNeedsDisplay:YES]; // Sometimes the icon leaves a bit of residue so remove it by drawing it again
	
}


- (void)changeFont:(id)sender
{
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *panelFont = [fontManager convertFont:[fontManager selectedFont]];
	[LINDefaults setValue:[NSArchiver archivedDataWithRootObject:panelFont] forKey:@"TextFont"];
}

@end
