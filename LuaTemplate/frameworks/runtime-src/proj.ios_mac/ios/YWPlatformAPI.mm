#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"

#include <sys/stat.h>
#include "YWPlatformAPI.h"
#include "platform/CCFileUtils.h"


#pragma mark LTKeyChain

/**
 * 钥匙串访问
 */
@interface LTKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteData:(NSString *)service;

@end


@implementation LTKeychain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,
            (id)kSecClass, service, (id)kSecAttrService, service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible, nil];
}

+ (void)save:(NSString *)service data:(id)data
{
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)deleteData:(NSString *)service
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end


#pragma mark -
#pragma mark LTImagePickerDelegate


/**
 * 图片选择委托
 */
@interface LTImagePickerDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) UIViewController* viewController;
@property (nonatomic, assign) std::function<void(const std::string& filename)> pickCallback;
@property (nonatomic, assign) CGSize expectSize;

@end


@implementation LTImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*)info
{
//    long time1 = [[NSDate date] timeIntervalSince1970] * 1000;
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    cocos2d::FileUtils* fileUtiles = cocos2d::FileUtils::getInstance();
    std::string dir = fileUtiles->getWritablePath() + "tmp/";
    if (!fileUtiles->isDirectoryExist(dir))
        fileUtiles->createDirectory(dir);
//    NSString* uuid = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
//    std::string filename = [uuid UTF8String] + ".jpg";
    std::string filename = "pickCachedImage.jpg";
    std::string path = dir + filename;
    
    // 图片缩放
    CGSize size = image.size;
    CGFloat scaleX = self.expectSize.width / size.width;
    CGFloat scaleY = self.expectSize.height / size.height;
    CGFloat scale = scaleX < scaleY ? scaleX : scaleY;
    
    CGRect rect = CGRectMake(0.f, 0.f, size.width * scale, size.height * scale);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData* data = UIImageJPEGRepresentation(scaledImage, 90);
    [data writeToFile:[NSString stringWithUTF8String:path.c_str()] atomically:NO];
    chmod(path.c_str(), S_IRWXU | S_IRWXG | S_IRWXO);
    
//    long time2 = [[NSDate date] timeIntervalSince1970] * 1000;
//    NSLog(@"elapsed time: %ld", time2 - time1);
    
    if (self.pickCallback)
    {
        self.pickCallback("tmp/" + filename);
        self.pickCallback = nullptr;
    }
    
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
    [picker autorelease];
    [self autorelease];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.pickCallback)
    {
        self.pickCallback("");
        self.pickCallback = nullptr;
    }
    
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
    [picker autorelease];
    [self autorelease];
}

@end


/**
 * 图片选择控制器，横屏分类
 */
//@interface UIImagePickerController (LandScapeImagePicker)
//
//- (BOOL)shouldAutorotate;
//- (NSUInteger)supportedInterfaceOrientations;
//
//@end
//
//
//@implementation UIImagePickerController (LandScapeImagePicker)
//
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//@end


#pragma mark -
#pragma mark LTImageSaverDelegate


@interface LTImageSaverDelegate : NSObject

@property (nonatomic, assign) std::function<void(bool)> saveCallback;

- (void)save:(NSString*)path;

@end


@implementation LTImageSaverDelegate

- (void)save:(NSString*)path
{
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    self.saveCallback(error == nil);
    [self release];
}

@end



#pragma mark -
#pragma mark LTNetworkStatusMonitor


@interface LTNetworkStatusMonitor : NSObject

@property (nonatomic, retain) Reachability * reachability;
@property (nonatomic, assign) std::function<void(int)> callback;
@property (atomic, assign) NetworkStatus currentStatus;

@end


@implementation LTNetworkStatusMonitor

- (id)init {
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkStatusChange) name:kReachabilityChangedNotification object:nil];
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        self.currentStatus = [self.reachability currentReachabilityStatus];
    }
    return self;
}

- (void)netWorkStatusChange {
    self.currentStatus = [self.reachability currentReachabilityStatus];
    self.callback(self.currentStatus);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [self.reachability release];
    [super dealloc];
}

@end



#pragma mark -


std::string p_getVersionStr()
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [version UTF8String];
}


std::string p_getUDID()
{
    [LTKeychain deleteData:@"UUIDKEY"];
    NSString *uuid = [LTKeychain load:@"UUIDKEY"];
    if (!uuid)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(nullptr);
        uuid = CFBridgingRelease(CFUUIDCreateString (nullptr, uuidRef));
        CFRelease(uuidRef);
        [LTKeychain save:@"UUIDKEY" data:uuid];
    }
    std::string ret("IOS_");
    ret += [uuid UTF8String];
    return ret;
}


std::string p_createUUID()
{
    uuid_t uuid;
    uuid_generate(uuid);
    char buffer[32] = {0};
    uuid_unparse(uuid, buffer);
    return buffer;
}


void p_keepScreenOn(bool enable)
{
    [UIApplication sharedApplication].idleTimerDisabled = enable;
}


std::string p_md5(const char* buffer, uint32_t size)
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(buffer, size, result);
    std::string ret;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
    {
        char buf[4] = { 0 };
        sprintf(buf, "%02x", result[i]);
        ret += buf;
    }
    return ret;
}



static UIViewController* getRootViewController()
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        NSArray* array = [[UIApplication sharedApplication] windows];
        UIWindow* win = [array objectAtIndex:0];
        UIView* ui = [[win subviews] objectAtIndex:0];
        return (UIViewController*)[ui nextResponder];
    }
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}


void p_pickFromAlbum(const std::function<void(const std::string& filename)>& callback, int expectWidth, int expectHeight)
{
    UIViewController* rootViewController = getRootViewController();
    if (rootViewController == nullptr)
    {
        callback("");
        return;
    }
    
    LTImagePickerDelegate* delegate = [[LTImagePickerDelegate alloc] init];
    delegate.viewController = rootViewController;
    delegate.pickCallback = callback;
    delegate.expectSize = CGSizeMake(expectWidth, expectHeight);
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = delegate;
    
    [rootViewController presentViewController:picker animated:YES completion:nil];
    [picker release];
}


void p_pickFromCamera(const std::function<void(const std::string&)>& callback, int expectWidth, int expectHeight)
{
    UIViewController* rootViewController = getRootViewController();
    if (rootViewController == nullptr)
    {
        callback("");
        return;
    }
    
    LTImagePickerDelegate* delegate = [[LTImagePickerDelegate alloc] init];
    delegate.viewController = rootViewController;
    delegate.pickCallback = callback;
    delegate.expectSize = CGSizeMake(expectWidth, expectHeight);
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = delegate;
    
    // 优先使用前置摄像头
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 4
        && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    [rootViewController presentViewController:picker animated:YES completion:nil];
    [picker release];
}


void p_saveToAlbum(const std::function<void(bool)>& callback, const std::string& path)
{
    LTImageSaverDelegate* delegate = [[LTImageSaverDelegate alloc] init];
    delegate.saveCallback = callback;
    [delegate save:[NSString stringWithUTF8String:path.c_str()]];
}



static LTNetworkStatusMonitor* _monitor = nil;


void p_createNetworkStatusMonitor(const std::function<void(int)>& callback)
{
    if (_monitor == nil)
    {
        _monitor = [[LTNetworkStatusMonitor alloc] init];
        _monitor.callback = callback;
    }
}


void p_destroyNetworkStatusMonitor()
{
    [_monitor release];
}


int p_getNetworkStatus()
{
    if (_monitor)
        return _monitor.currentStatus;
    return 0;
}

