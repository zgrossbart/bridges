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
}

@property (retain) RootMenuViewController *rootMenuViewController;


- (IBAction)showBridgesTapped:(id)sender;

@end
