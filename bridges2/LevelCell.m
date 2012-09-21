//
//  LevelCell.m
//  bridges2
//
//  Created by Zack Grossbart on 9/21/12.
//
//

#import "LevelCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation LevelCell

@synthesize titleLabel = _titleLabel;
@synthesize screenshot = _screenshot;
@synthesize checkMark = _checkMark;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"LevelCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [[arrayOfViews objectAtIndex:0] retain];
        
        [self.screenshot.layer setCornerRadius:8.0f];
        [self.screenshot.layer setMasksToBounds:YES];
        self.screenshot.layer.borderColor = [UIColor colorWithRed:(1.0 * 170) / 255 green:(1.0 * 170) / 255 blue:(1.0 * 170) / 255 alpha:0.5].CGColor;
        self.screenshot.layer.borderWidth = 1.0f;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}
@end
