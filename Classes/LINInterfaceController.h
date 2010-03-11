/*
Lingon version 2.1.1, 2008-12-18
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://tuppis.com/lingon

Copyright 2005-2008 Peter Borg

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import <Cocoa/Cocoa.h>


@interface LINInterfaceController : NSObject {

	IBOutlet NSTreeController *plistsTreeController;
	IBOutlet NSOutlineView *plistsOutlineView;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *whichFolderSheet;
	IBOutlet NSMatrix *whichFolderMatrix;
	
	IBOutlet NSTextField *labelTextField;
	
	IBOutlet NSView *basicView;
	IBOutlet NSView *expertView;
	
	IBOutlet NSSplitView *splitView;
	
	IBOutlet NSTextView *expertTextView;
	IBOutlet NSImageView *expertValidPlistIcon;
	IBOutlet NSTextField *expertTextField;
	
	IBOutlet NSButton *modeButton;
	
	IBOutlet NSPopUpButton *insertParameterPopUp;
	
	NSImage *validIcon;
	NSImage *notValidIcon;
	
	NSArray *insertParametersArray;
	
}

@property (readonly) IBOutlet NSTreeController *plistsTreeController;
@property (readonly) IBOutlet NSOutlineView *plistsOutlineView;
@property (readonly) IBOutlet NSWindow *mainWindow;
@property (readonly) IBOutlet NSWindow *whichFolderSheet;
@property (readonly) IBOutlet NSMatrix *whichFolderMatrix;

@property (readonly) IBOutlet NSTextField *labelTextField;

@property (readonly) IBOutlet NSView *basicView;
@property (readonly) IBOutlet NSView *expertView;

@property (readonly) IBOutlet NSSplitView *splitView;

@property (readonly) IBOutlet NSTextView *expertTextView;
@property (readonly) IBOutlet NSImageView *expertValidPlistIcon;
@property (readonly) IBOutlet NSTextField *expertTextField;

@property (readonly) IBOutlet NSPopUpButton *insertParameterPopUp;

@property (assign) NSImage *validIcon;
@property (assign) NSImage *notValidIcon;

@property (readonly) IBOutlet NSButton *modeButton;

@property (assign) NSArray *insertParametersArray;

+ (LINInterfaceController *)sharedInstance;

- (IBAction)setPathAction:(id)sender;

- (IBAction)cancelWhichFolderAction:(id)sender;
- (IBAction)createWhichFolderAction:(id)sender;

- (void)changeViewWithAnimationForOldView:(NSView *)oldView newView:(NSView *)newView;

- (IBAction)switchView:(id)sender;
@end
