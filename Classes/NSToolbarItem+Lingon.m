/*
Lingon version 2.1.1, 2008-12-18
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/lingon

Copyright 2005-2008 Peter Borg

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "NSToolbarItem+Lingon.h"


@implementation NSToolbarItem (NSToolbarItemLingon)


+ (NSToolbarItem *)createToolbarItemWithIdentifier:(NSString *)itemIdentifier name:(NSString *)name image:(NSImage *)image action:(SEL)selector tag:(NSInteger)tag target:(id)target
{
	NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	NSRect toolbarItemRect = NSMakeRect(0.0, 0.0, 28.0, 27.0);
	
	NSView *view = [[NSView alloc] initWithFrame:toolbarItemRect];
	NSButton *button = [[NSButton alloc] initWithFrame:toolbarItemRect];
	[button setBezelStyle:NSTexturedRoundedBezelStyle];
	[button setTitle:@""];
	[button setImage:image];
	[button setTarget:target];
	[button setAction:selector];
	[[button cell] setImageScaling:NSImageScaleProportionallyDown];
	[button setImagePosition:NSImageOnly];
	
	[toolbarItem setLabel:name];
	[toolbarItem setPaletteLabel:name];
	[toolbarItem setToolTip:name];
	
	[view addSubview:button];
	
	[toolbarItem setTag:tag];
	[toolbarItem setView:view];
	
	return toolbarItem;
}

@end
