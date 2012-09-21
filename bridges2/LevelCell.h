//
//  LevelCell.h
//  bridges2
//
//  Created by Zack Grossbart on 9/21/12.
//
//

#import <UIKit/UIKit.h>

@interface LevelCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *screenshot;
@property (strong, nonatomic) IBOutlet UIImageView *checkMark;

@end
