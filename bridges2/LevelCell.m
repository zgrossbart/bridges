//
//  LevelCell.m
//  bridges2
//
//  Created by Zack Grossbart on 9/21/12.
//
//

#import "LevelCell.h"

@implementation LevelCell

@synthesize titleLabel = _titleLabel;
@synthesize screenshot = _screenshot;
@synthesize checkMark = _checkMark;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //[[NSBundle mainBundle] loadNibNamed:@"LevelCell" owner:self options:nil];
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"LevelCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        /*id *newView = [[arrayOfViews objectAtIndex:0] retain];
        [newView setFrame:paramFrame];
        
        [self release];
        self = newView;*/
        
        //[self addSubview:[arrayOfViews objectAtIndex:0] retain];
        
        self = [[arrayOfViews objectAtIndex:0] retain];
        
    }
    
    return self;
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


- (void)dealloc {
    [super dealloc];
}
@end
