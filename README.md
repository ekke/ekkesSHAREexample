# Share Example App

[AUTHOR ( ekke )](AUTHOR.md)

This app is part of ekke's blog series about mobile x-platform development:
http://j.mp/qt-x

## License Information
[see LICENSE ( The Unlicense )](LICENSE)

## ekkes SHARE example
This is not a real-life app - this app only demonstrates

1. HowTo share Files from Qt Mobile App with other Apps on Android and iOS

2. HowTo open Qt Mobile App from other Apps: the Android part is nearly done, iOS coming soon

!!! not production ready !!!

!!! please set Permission WRITE_EXTERNAL_STORAGE on Android 6+ !!!

## 1. HowTo share Files from Qt Mobile App with other Apps on Android and iOS

On Android we're using Intents, on iOS UIDocumentInteractionController.

Developed and tested on Android 6, Android 7, Android 8, iOS and Qt 5.9.1
Android: Target SDK 23
there are changes in Android 7: https://developer.android.com/about/versions/nougat/android-7.0-changes.html#sharing-files

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


## 2. HowTo open Qt Mobile App from other Apps: the Android part is done, iOS coming soon

![New Intent coming in from other Android App](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/new_intent.png)

![Process Intent from other Android App](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/process_intent.png)

## More Infos
follow me @ekkescorner

To read more please take a look at these blogs:

Qt: http://blog.qt.io/blog/2017/12/01/sharing-files-android-ios-qt-app/

Qt: part 2 coming soon

ekkes-corner: ... work in progress - stay tuned ...






