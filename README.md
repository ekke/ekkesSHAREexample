# Share Example App

[AUTHOR ( ekke )](AUTHOR.md)

This app is part of ekke's blog series about mobile x-platform development:
http://j.mp/qt-x

## License Information
[see LICENSE ( The Unlicense )](LICENSE)

... work in progress - stay tuned ...

PLEASE NO QUESTIONS BEFORE MY BLOG ARTICLE IS PUBLISHED

wait for tweet @ekkescorner

## ekkes SHARE example
This is not a real-life app - this app only demonstrates HowTo share Files with other Apps on Android and iOS

!!! not production ready !!!

!!! please set Permission WRITE_EXTERNAL_STORAGE on Android 6+ !!!

On Android we're using Intents, on iOS UIDocumentInteractionController.

Developed and tested on Android 6, Android 7, Android 8, iOS and Qt 5.9.1

Here's an Overview about the workflows, per ex. Open a File from inside your App and edit in another App outside.

![Overview](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/share_overview.png)

The goal of this app is to Open / View / Edit Files from your AppData Location in other Apps. But to be able to access your Files from AppData Location you first must copy them from AppData to shared UserData - per ex. DocumentsLocation.
Of course at the end you need the modified File and you must delete the copy from Documentslocation, so we must watch for a SIGNAL from Android Intent or iOS UIDocumentInteractionController.

![Files from AppData to Documents and back](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/file_flow.png)

## Share (Open / Edit) or Print from QtQuickControls2 Apps

![Android Chooser to Open in ...](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/android_share_chooser.png)

![Android Send Stream to Printer](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/android_share_send_chooser.png)

![iOS Preview](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/ios_preview.png)

![iOS Share](https://github.com/ekke/ekkesSHAREexample/blob/master/docs/ios_share.png)


## More Infos
To read more please take a look at these blogs:

Qt: ... work in progress - stay tuned ...

ekkes-corner: ... work in progress - stay tuned ...






