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

@implementation LINHelpMenuController


- (IBAction)openManPageAction:(id)sender
{
	NSString *path = [LINBasic genererateTemporaryPath];
	
	if ([sender tag] == LINManPageLaunchdPlist) {

		if (manPageLaunchdPlistWindow == nil) {
			[NSBundle loadNibNamed:@"LINManPageLaunchdPlist.nib" owner:self];
		}

		system([[NSString stringWithFormat:@"/usr/bin/man launchd.plist | col -b > %@", path] UTF8String]);
		[manPageLaunchdPlistTextView setString:[self getManStringAtPath:path]];
		[manPageLaunchdPlistWindow makeKeyAndOrderFront:nil];
		
	} else if ([sender tag] == LINManPageLaunchctl) {
		
		if (manPageLaunchctlWindow == nil) {
			[NSBundle loadNibNamed:@"LINManPageLaunchctl.nib" owner:self];
		}
		
		system([[NSString stringWithFormat:@"/usr/bin/man launchctl | col -b > %@", path] UTF8String]);
		[manPageLaunchctlTextView setString:[self getManStringAtPath:path]];
		[manPageLaunchctlWindow makeKeyAndOrderFront:nil];
		
	} else if ([sender tag] == LINManPageLaunchd) {
		
		if (manPageLaunchdWindow == nil) {
			[NSBundle loadNibNamed:@"LINManPageLaunchd.nib" owner:self];
		}
		
		system([[NSString stringWithFormat:@"/usr/bin/man launchd | col -b > %@", path] UTF8String]);
		[manPageLaunchdTextView setString:[self getManStringAtPath:path]];
		[manPageLaunchdWindow makeKeyAndOrderFront:nil];
		
	}
}


- (NSString *)getManStringAtPath:(NSString *)path
{
	NSString *manString;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		manString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
	} else {
		manString = NSLocalizedString(@"The man page cannot be displayed because of an unknown error. Please try again!", @"The man page cannot be displayed because of an unknown error. Please try again!"); 
	}

	return manString;
}


- (IBAction)lingonHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"Lingon-Manual" ofType:@"pdf"]];
}
@end
