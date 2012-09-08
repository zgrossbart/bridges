//
//  RootMenuViewControlleriPad.h
//  bridges2
//
//  Created by Zack Grossbart on 9/8/12.
//
//

#import <UIKit/UIKit.h>
#import "Level.h"

@interface RootMenuViewControlleriPad : UIViewController {
    UIWindow *window_;
	UINavigationController *navController_;
    
    /*
     IBOutlet UIButton *_undoBtn;
     IBOutlet UILabel *_coinLabel;
     IBOutlet UIImageView *_coinImage;
     */
    IBOutlet UIButton *_undoBtn;
    IBOutlet UILabel *_coinLabel;
    IBOutlet UIImageView *_coinImage;
}


-(void)showLevel:(Level*) level;

- (IBAction)goHomeTapped:(id)sender;
- (IBAction)undoTapped:(id)sender;
- (IBAction)refreshTapped:(id)sender;

@end
