//
//  LevelCell.h
//  bridges2
//
//  Created by Zack Grossbart on 9/21/12.
//
//

#import <UIKit/UIKit.h>

/**
 * This class handles the UI for the cell for each level in the level
 * chooser we use for iPad.
 */
@interface LevelCell : UICollectionViewCell

/**
 * Set if this cell should show a border.  True if it should and
 * false if it shouldn't.
 */
-(void)setBorderVisible:(bool) visible;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *screenshot;
@property (strong, nonatomic) IBOutlet UIImageView *checkMark;

@end
