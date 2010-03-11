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


@interface LINVariousPerformer : NSObject
{

}

+ (LINVariousPerformer *)sharedInstance;

- (void)updatePlistsOutlineView;

- (NSMutableDictionary *)temporaryDictionaryFromOriginal:(NSDictionary *)dictionary;
- (NSMutableDictionary *)finalDictionaryFromOriginal:(NSDictionary *)originalDictionary temporary:(NSDictionary *)temporaryDictionary;

- (NSInteger)alertWithMessage:(NSString *)message informativeText:(NSString *)informativeText defaultButton:(NSString *)defaultButton alternateButton:(NSString *)alternateButton otherButton:(NSString *)otherButton;
- (void)standardAlertSheetWithMessage:(NSString *)message informativeText:(NSString *)message suppressionString:(NSString *)suppressionString;

- (NSArray *)divideCommandIntoArray:(NSString *)command;

- (BOOL)shouldWeCloseTheCurrentPlist;

- (void)refreshObject:(id)object path:(NSString *)path;

- (void)expandDirectoriesThatShouldBeExpanded;

- (NSString *)stringFromDictionary:(NSDictionary *)dictionary;

- (void)checkIfValidPlist:(NSString *)string;

- (BOOL)validateStringAsPlist:(NSString *)string;

- (void)changeToBasicMode;
- (void)changeToExpertMode;

- (BOOL)shouldUpdateDictionaryFromExpertString;
- (void)updateDictionaryFromExpertString;

- (void)insertParameter:(id)sender;
@end
