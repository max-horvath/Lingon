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


@implementation LINSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	if (offset == 0) {
		return [[LINInterface mainWindow] frame].size.width - 548.0;
	} else {
		return proposedMin;
	}
}


- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	CGFloat dividerThickness = [sender dividerThickness];
    NSRect listRect  = [[[sender subviews] objectAtIndex:0] frame];
    NSRect contentRect = [[[sender subviews] objectAtIndex:1] frame];
    NSRect newFrame  = [sender frame];
	
    listRect.size.height = newFrame.size.height;
    listRect.origin = NSMakePoint(0, 0);
    contentRect.size.width = newFrame.size.width - listRect.size.width - dividerThickness;
	if (contentRect.size.width < 548) {
		listRect.size.width = listRect.size.width - (548 - contentRect.size.width);
		contentRect.size.width = 548;
	}
    contentRect.size.height = newFrame.size.height;
    contentRect.origin.x = listRect.size.width + dividerThickness;
	
    [[[sender subviews] objectAtIndex:0] setFrame:listRect];
    [[[sender subviews] objectAtIndex:1] setFrame:contentRect];
	
	[sender adjustSubviews];
}

@end
