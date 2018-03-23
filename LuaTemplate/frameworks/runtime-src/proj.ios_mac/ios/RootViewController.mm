/****************************************************************************
 Copyright (c) 2013      cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#import "cocos2d.h"
#import "scripting/lua-bindings/manual/platform/ios/CCLuaObjcBridge.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "Ads/AdmobController.h"
#import "Tools/ToolsController.h"
#import "Tools/GameCenterHelper.h"
#import "WX/SendMsgToWeChatViewController.h"
#import "Constant.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    // Initialize the CCEAGLView
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [UIScreen mainScreen].bounds
                                         pixelFormat: (__bridge NSString *)cocos2d::GLViewImpl::_pixelFormat
                                         depthFormat: cocos2d::GLViewImpl::_depthFormat
                                  preserveBackbuffer: NO
                                          sharegroup: nil
                                       multiSampling: NO
                                     numberOfSamples: 0 ];
    
    // Enable or disable multiple touches
    [eaglView setMultipleTouchEnabled:YES];
    
    // Set EAGLView as view of RootViewController
    self.view = eaglView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [[AdmobController getInstance] setRootViewController:self];
    [[ToolsController getInstance] setRootViewController:self];
    [[SendMsgToWeChatViewController getInstance] setViewController:self];
    
    if ([DevMode isEqualToString:@"APP_STORE"])
    {
        [[GameCenterDelegate getInstance] setRootViewController:self];
    }
    
    _billingFunctionId = 0;
    [SVProgressHUD setViewForExtension:self.view];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
#ifdef __IPHONE_6_0
- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
#endif

- (BOOL) shouldAutorotate {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    auto glview = cocos2d::Director::getInstance()->getOpenGLView();

    if (glview)
    {
        CCEAGLView *eaglview = (__bridge CCEAGLView *)glview->getEAGLView();

        if (eaglview)
        {
            CGSize s = CGSizeMake([eaglview getWidth], [eaglview getHeight]);
            cocos2d::Application::getInstance()->applicationScreenSizeChanged((int) s.width, (int) s.height);
        }
    }
}

//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

//- (void)showRemoveAdsAlert
//{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pay To Remove Ads" message:@"All the ads in this game will be removed forever ! if you have already purchased this item, please click the \"restore\" button to recover it free !" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *restoreAction = [UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self restoreRemoveAds];
//    }];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self removeAds];
//    }];
//    [alertController addAction:cancelAction];
//    [alertController addAction:restoreAction];
//    [alertController addAction:okAction];
//    
//    [self presentViewController:alertController animated:YES completion:nil];
//}


/*
 * In-app Billings
 */

- (void)registerBillingCallBackFunc:(int) functionId
{
    _billingFunctionId = functionId;
}

- (void)restore
{
    _currentProId = @"";
   [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
   [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)purchase:(NSString*) productId
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    _currentProId = productId;
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:_currentProId];
    }else{
        NSLog(@"不允许程序内付费");
    }
}

//去苹果服务器请求商品
- (void)requestProductData:(NSString *)type{
    NSLog(@"-------------请求对应的产品信息----------------");
    [SVProgressHUD showWithStatus:@"waitting..."];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        [SVProgressHUD dismiss];
        NSLog(@"--------------没有商品------------------");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:_currentProId]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:@"支付失败"];
    NSLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    [SVProgressHUD dismiss];
    NSLog(@"------------反馈信息结束-----------------");
}
//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
-(void)verifyPurchaseWithPaymentTransaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:AppStore];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dic);
    if([dic[@"status"] intValue]==0){
        NSLog(@"购买成功！");
        NSDictionary *dicReceipt= dic[@"receipt"];
        NSArray *dicInApp=dicReceipt[@"in_app"];
        
        long int count = [dicInApp count];
        if ([_currentProId length] == 0) //Restore
        {
            cocos2d::LuaObjcBridge::pushLuaFunctionById(_billingFunctionId);
            for (int i = 0 ; i < count; i++) {
                NSDictionary *productPurchased = [dicInApp objectAtIndex:i];
                NSString *productIdentifier= productPurchased[@"product_id"];//读取产品标识
                cocos2d::LuaObjcBridge::getStack()->pushString([productIdentifier UTF8String]);
            }
            cocos2d::LuaObjcBridge::getStack()->executeFunction((int)count);
        }
        else //Purchase
        {
            for (int i = 0 ; i < count; i++) {
                NSDictionary *productPurchased = [dicInApp objectAtIndex:i];
                NSString *productIdentifier= productPurchased[@"product_id"];//读取产品标识
                if ([productIdentifier isEqualToString:_currentProId])
                {
                    if (_billingFunctionId != 0)
                    {
                        cocos2d::LuaObjcBridge::pushLuaFunctionById(_billingFunctionId);
                        cocos2d::LuaObjcBridge::getStack()->pushString([_currentProId UTF8String]);
                        cocos2d::LuaObjcBridge::getStack()->executeFunction(1);
                    }
                    break;
                }
            }
        }
        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
//        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//        if (! [productIdentifier isEqualToString:_currentProId]) {
//            int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
//            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
//        }else{
//            [defaults setBool:YES forKey:productIdentifier];
//            AppController* ctl = [AppController getInstance];
//            [ctl disableAllAds];
//        }
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else{
        NSLog(@"购买失败，未通过验证！");
    }
}
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                // 发送到苹果服务器验证凭证
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [SVProgressHUD showErrorWithStatus:@"购买失败"];
            }
                break;
            default:
                break;
        }
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
