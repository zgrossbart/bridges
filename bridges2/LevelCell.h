/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>

/**
 * This class handles the UI for the cell for each level in the level
 * chooser and the cell for each layer set in the menus we use for iPad.
 */
@interface LevelCell : UICollectionViewCell

/**
 * Set if this cell should show a border.  True if it should and
 * false if it shouldn't.
 */
-(void)setBorderVisible:(bool) visible;

/**
 * The title label for cell in the table.
 */
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

/**
 * The main image for the call which shows a thumbnail of the level
 */
@property (strong, nonatomic) IBOutlet UIImageView *screenshot;

/**
 * The check mark which shows in the upper right corner once you've won a level.
 */
@property (strong, nonatomic) IBOutlet UIImageView *checkMark;

@end
