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


@implementation LINViewMenuController


- (IBAction)switchModeAction:(id)sender
{
	[LINInterface switchView:sender];
}


- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	BOOL enableMenuItem = YES;
	
	if ([anItem tag] == 1) { // Switch mode
		if ([[LINDefaults valueForKey:@"Mode"] integerValue] == LINBasicMode) {
			[anItem setTitle:EXPERT_MODE_TITLE];
		} else {
			[anItem setTitle:BASIC_MODE_TITLE];
		}
		if ([LINMain hasInsertedView] == NO) {
			return NO;
		}
	}
	
	return enableMenuItem;
}

@end
