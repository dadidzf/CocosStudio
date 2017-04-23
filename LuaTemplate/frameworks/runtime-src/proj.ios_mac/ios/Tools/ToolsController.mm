/****************************************************************************
    By dzf 20170423
 ****************************************************************************/

#import "ToolsController.h"
#import "RootViewController.h"

@implementation ToolsController

static ToolsController* _instance = nil;

+ (ToolsController*) getInstance
{
    if (_instance == nil)
    {
        _instance = [ToolsController alloc];
    }
    
    return _instance;
}

- (void)setRootViewController:(RootViewController*) viewCtrl
{
    _viewController = viewCtrl;
}

/*
 * Lua interface
 */

+ (void)gameShareLua:(NSDictionary *)dict
{
    [[ToolsController getInstance] gameShare:[dict objectForKey:@"url"]
                                    andTitle:[dict objectForKey:@"title"] andPic:[dict objectForKey:@"pic"]];
}


/*
 * ios implementation
 */

// @picPath can be "" means no pic to share
- (void)gameShare:(NSString*)shareUrl andTitle:(NSString*) shareTitle andPic:(NSString*) picPath
{
    NSURL *url = [NSURL URLWithString:shareUrl];
    UIImage *imageToShare = [UIImage imageNamed:picPath];
    
    NSArray *objectsToShare;
    if ([picPath isEqualToString:@""])
         objectsToShare = @[shareTitle, url];
    else
         objectsToShare = @[shareTitle, imageToShare, url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [_viewController presentViewController:controller animated:YES completion:nil];
    }
    //if iPad
    else
    {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popup presentPopoverFromRect:CGRectMake(
            _viewController.view.frame.size.width/2, _viewController.view.frame.size.height/2, 0, 0)inView:_viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

@end
