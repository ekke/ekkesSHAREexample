// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#import "iosshareutils.hpp"

#import <UIKit/UIKit.h>
#import <QGuiApplication>
#import <QQuickWindow>

#import <UIKit/UIDocumentInteractionController.h>

#import "docviewcontroller.hpp"

IosShareUtils::IosShareUtils(QObject *parent) : PlatformShareUtils(parent)
{
    //
}

bool IosShareUtils::checkMimeTypeView(const QString &mimeType) {
#pragma unused (mimeType)
    // dummi implementation on iOS
    // MimeType not used yet
    return true;
}

bool IosShareUtils::checkMimeTypeEdit(const QString &mimeType) {
#pragma unused (mimeType)
    // dummi implementation on iOS
    // MimeType not used yet
    return true;
}

void IosShareUtils::share(const QString &text, const QUrl &url) {

    NSMutableArray *sharingItems = [NSMutableArray new];

    if (!text.isEmpty()) {
        [sharingItems addObject:text.toNSString()];
    }
    if (url.isValid()) {
        [sharingItems addObject:url.toNSURL()];
    }

    // get the main window rootViewController
    UIViewController *qtUIViewController = [[UIApplication sharedApplication].keyWindow rootViewController];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    if ( [activityController respondsToSelector:@selector(popoverPresentationController)] ) { // iOS8
        activityController.popoverPresentationController.sourceView = qtUIViewController.view;
    }
    [qtUIViewController presentViewController:activityController animated:YES completion:nil];
}

void IosShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    mCurrentRequestId = requestId;

    NSString* nsFilePath = filePath.toNSString();
    NSURL *nsFileUrl = [NSURL fileURLWithPath:nsFilePath];

    static DocViewController* docViewController = nil;
    if(docViewController!=nil)
    {
        [docViewController removeFromParentViewController];
        [docViewController release];
    }

    UIDocumentInteractionController* documentInteractionController = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:nsFileUrl];

    UIViewController* qtUIViewController = [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    if(qtUIViewController!=nil)
    {
        docViewController = [[DocViewController alloc] init];

        docViewController.requestId = requestId;

        [qtUIViewController addChildViewController:docViewController];
        documentInteractionController.delegate = docViewController;
        [documentInteractionController presentPreviewAnimated:YES];
    }
}


void IosShareUtils::viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    mCurrentRequestId = requestId;

    NSString* nsFilePath = filePath.toNSString();
    NSURL *nsFileUrl = [NSURL fileURLWithPath:nsFilePath];

    static DocViewController* docViewController = nil;
    if(docViewController!=nil)
    {
        [docViewController removeFromParentViewController];
        [docViewController release];
    }

    UIDocumentInteractionController* documentInteractionController = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:nsFileUrl];

    UIViewController* qtUIViewController = [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    if(qtUIViewController!=nil)
    {
        docViewController = [[DocViewController alloc] init];

        docViewController.requestId = requestId;

        [qtUIViewController addChildViewController:docViewController];
        documentInteractionController.delegate = docViewController;
        [documentInteractionController presentPreviewAnimated:YES];
    }
}

void IosShareUtils::editFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    mCurrentRequestId = requestId;

    NSString* nsFilePath = filePath.toNSString();
    NSURL *nsFileUrl = [NSURL fileURLWithPath:nsFilePath];

    static DocViewController* docViewController = nil;
    if(docViewController!=nil)
    {
        [docViewController removeFromParentViewController];
        [docViewController release];
    }

    UIDocumentInteractionController* documentInteractionController = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:nsFileUrl];

    UIViewController* qtUIViewController = [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    if(qtUIViewController!=nil)
    {
        docViewController = [[DocViewController alloc] init];

        docViewController.requestId = requestId;

        [qtUIViewController addChildViewController:docViewController];
        documentInteractionController.delegate = docViewController;
        [documentInteractionController presentPreviewAnimated:YES];
    }
}

void IosShareUtils::handleDocumentPreviewDone()
{
    // TODO HowTo know about
    // documentInteractionControllerDidEndPreview
    qDebug() << "handleShareDone: " << mCurrentRequestId;
    emit shareFinished(mCurrentRequestId);
}


