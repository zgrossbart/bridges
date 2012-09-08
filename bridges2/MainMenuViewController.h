//
//  MainMenuViewController.h
//  bridges2
//
//  Created by Zack Grossbart on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "RootMenuViewController.h"
#import "RootMenuViewControlleriPad.h"

@interface MainMenuViewController : UIViewController {
    RootMenuViewController *_rootMenuViewController;
    
//    IBOutlet UITableView *_view;
    CGFloat  mFontSize;
    NSArray* mFontNames;
    IBOutlet UITableView *_mainTable;
    IBOutlet UINavigationItem *_navItem;
    IBOutlet UIScrollView *_scrollView;
}

@property (retain) RootMenuViewController *rootMenuViewController;
@property (retain) RootMenuViewControlleriPad *rootMenuViewControlleriPad;

@property (nonatomic) int curIndex;


- (IBAction)showBridgesTapped:(id)sender;

@end
