@interface UIButton (ExpandsVertically)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIButton (Expandable)

- (CGSize)sizeThatFits:(CGSize)size {
    
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    // for the width, I subtract 24 for the border
    // for the height, I use a large value that will be reduced when the size is returned from sizeWithFont
    CGSize tempSize = CGSizeMake(size.width - 24, 1000);
    
    CGSize stringSize = [self.titleLabel.text
                         sizeWithFont:self.titleLabel.font
                         constrainedToSize:tempSize
                         lineBreakMode:UILineBreakModeWordWrap];
    
    return CGSizeMake(size.width - 24, stringSize.height);
}

@end