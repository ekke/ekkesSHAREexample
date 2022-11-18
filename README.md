# Share Example App

[AUTHOR ( ekke )](AUTHOR.md)

This app is part of ekke's blog series about mobile x-platform development:
http://j.mp/qt-x

## License Information
[see LICENSE ( The Unlicense )](LICENSE)

## ekkes SHARE example
This is not a real-life app - this app only demonstrates

1. HowTo share Files from Qt Mobile App with other Apps on Android and iOS

2. HowTo open Qt Mobile App from other Apps on Android and iOS

!!! not production ready !!!

## 1. HowTo share Files from Qt Mobile App with other Apps on Android and iOS

On Android we're using Intents, on iOS UIDocumentInteractionController.


Developed and tested on Android 6 - 13, iOS and Qt 5.15.7
Android: This release now supports FileProvider and sets Permissions if incoming Files need
iOS: This release supports Xcode 12 and minimum iOS 12 (required by Qt 5.15)

Now more examplels included to share with other Apps: PNG, JPEG, DOCX, PDF

Here's an Overview about the workflows, per ex. Open a File from inside your App and edit in another App outside.

![Overview](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/share_overview_v2.png)

The goal of this app is to Open / View / Edit Files from your AppData Location in other Apps. But to be able to access your Files from AppData Location you first must copy them from AppData to shared UserData - per ex. DocumentsLocation.
Of course at the end you need the modified File and you must delete the copy from Documentslocation, so we must watch for a SIGNAL from Android Intent or iOS UIDocumentInteractionController.

![Files from AppData to Documents and back](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/file_flow.png)

## Share (Open / Edit) or Print from QtQuickControls2 Apps

### Android Chooser to Open in...
![Android Chooser to Open in ...](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/android_share_chooser.png)

### Android Send Stream to Printer
![Android Send Stream to Printer](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/android_share_send_chooser.png)

### iOS Preview Page
![iOS Preview](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/ios_preview.png)

### iOS Share with ...
![iOS Share](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/ios_share.png)


## 2. HowTo open Qt Mobile App from other Apps on Android and iOS

### Open Qt Apps from Android Apps

![New Intent coming in from other Android App](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/new_intent.png)

![Process Intent from other Android App](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/process_intent.png)

### Open Qt Apps from iOS Apps

![Handle Url from other iOS App](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/handle_url_from_ios_apps.png)


## More Infos
follow me @ekkescorner

To read more please take a look at these blogs:

![ekkes Sharing Blogs at Qt Blog](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/qt_blog_overview.png)

Qt: Part 1: http://blog.qt.io/blog/2017/12/01/sharing-files-android-ios-qt-app/

Qt: Part 2: http://blog.qt.io/blog/2018/01/16/sharing-files-android-ios-qt-app-part-2/

Qt: part 3: http://blog.qt.io/blog/2018/02/06/sharing-files-android-ios-qt-app-part-3/

Qt: part 4: coming soon

blogs at ekkes-corner: ... work in progress - stay tuned ...

articles in (german) web & mobile developer magazin: ... work in progress - stay tuned ...






