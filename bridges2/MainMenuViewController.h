//
//  MainMenuViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "RootMenuViewController.h"

@interface MainMenuViewController : UIViewController {
    RootMenuViewController *_rootMenuViewController;
    
//    IBOutlet UITableView *_view;
    CGFloat  mFontSize;
    NSArray* mFontNames;
    IBOutlet UINavigationItem *_navItem;
}

@property (retain) RootMenuViewController *rootMenuViewController;

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, retain) NSArray* fontNames;

@property (nonatomic) int curIndex;


- (IBAction)showBridgesTapped:(id)sender;

@end
