// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: appWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Share Examples")

    // some request ids to test
    // in real-life apps you would use customerNumber, orderId, workflowId or similoar values to identify the context when getting a value back
    property int request_NO_RESPONSE_IMAGE: 0;
    property int request_NO_RESPONSE_PDF: -1;
    property int request_EDIT_FILE_IMAGE: 42;
    property int request_EDIT_FILE_PDF: 44;
    property int request_VIEW_FILE_IMAGE: 22;
    property int request_VIEW_FILE_PDF: 21;
    property int request_SEND_FILE_IMAGE: 11;
    property int request_SEND_FILE_PDF: 10;

    // alternate implementations:
    // currently only on Android and ignored under iOS)
    //
    // cpp: AndroidShareUtils implements 2 differen ways to start an Intent:
    // default: one simple JNI Call and doing other stuff in Java
    // alternate Implementation: doing it all using JNI Calls (only some parts completely implemented, because the one-JNI-fits-it-all is the recommended way)
    // attention: to test JNI with QAndroidActivityResultReceiver you must uncomment onActivityResult() in QShareActivity.java
    property bool useAltImpl: false


    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: homePage
            Image {
                id: image0
                anchors.top: parent.top
                anchors.right: parent.right
                sourceSize.width: 160
                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        image0.source = ""
                    }
                }
            }
            Label {
                id: titleLabel
                text: qsTr("Welcome to ekke's Share Example App")
                wrapMode: Label.WordWrap
                anchors.top: image0.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
            }
            Label {
                id: infoLabel
                text: qsTr("Swipe through Pages or TabBar to test\n* Share Text\n* Send File (PNG or PDF)\n* View File (PNG or PDF)\n* Edit File (PNG or PDF)\nHint: Scroll the Bottom Tab Bar horizontally to get all Tabs !")
                wrapMode: Label.WordWrap
                anchors.top: titleLabel.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
            }
            Label {
                id: androidInfoLabel
                visible: Qt.platform.os === "android"
                text: qsTr("On Android there are two implementations: pure JNI (complicated) or simple JNI Call + Java (recommended)")
                wrapMode: Label.WordWrap
                anchors.top: infoLabel.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
            }
            Label {
                id: reverseLabel
                text: qsTr("... and the reverse Way: GoTo a Page, open another App, share File with this Example App. Single Image should appear on current Page, other Filetypes or more Files should open a Popup\n...work in progress... Android implemented, iOS on TODO")
                wrapMode: Label.WordWrap
                anchors.top: Qt.platform.os === "android"? androidInfoLabel.bottom : infoLabel.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
            }
        }

        Page {
            id: pageTextUrl
            Button {
                id: shareButton
                text: qsTr("Share Text and Url")
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
                onClicked: {
                    shareUtils.share("Qt","http://qt.io")
                }
            }
            Image {
                id: image1
                anchors.top: parent.top
                anchors.right: parent.right
                sourceSize.width: 160
                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        image1.source = ""
                    }
                }
            }
        }

        Page {
            id: pageSend
            Switch {
                id: sendJNISwitch
                visible: Qt.platform.os === "android"
                text: checked? "ON-> use Pure JNI\n(switch off for Java+JNI)" : "OFF-> use Java+JNI\n(switch on for Pure JNI)"
                checked: appWindow.useAltImpl
                onCheckedChanged: {
                    appWindow.useAltImpl = checked
                }
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Label {
                visible: appWindow.useAltImpl
                text: qsTr("Pure JNI not recommended.\nPlease read the blog / docs")
                color: "red"
                anchors.top:sendJNISwitch.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
            }
            Switch {
                id: sendSwitch
                text: checked? "ON-> use PDF\n(switch off for PNG)" : "OFF-> use PNG\n(switch on for PDF)"
                anchors.top: Qt.platform.os === "android"? sendJNISwitch.bottom : parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: appWindow.useAltImpl? 32 : 12
            }
            Button {
                id: sendButton
                text: Qt.platform.os === "android"? qsTr("Send File\n(no feedback)") : qsTr("Send File")
                onClicked: {
                    if(sendSwitch.checked) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Send File", "application/pdf", request_NO_RESPONSE_PDF, appWindow.useAltImpl)
                    } else {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Send File", "image/png", request_NO_RESPONSE_IMAGE, appWindow.useAltImpl)
                    }
                }
                anchors.top: sendSwitch.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Button {
                id: sendButtonWResult
                text: Qt.platform.os === "android"? qsTr("Send File with Result\n(recommended)") : qsTr("Send File with RequestId\n(recommended)")
                onClicked: {
                    if(sendSwitch.checked) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_PDF), "Send File", "application/pdf", request_SEND_FILE_PDF, appWindow.useAltImpl)
                    } else {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_IMAGE), "Send File", "image/png", request_SEND_FILE_IMAGE, appWindow.useAltImpl)
                    }
                }
                anchors.top: sendButton.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Image {
                id: image2
                anchors.top: parent.top
                anchors.right: parent.right
                sourceSize.width: 160
                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        image2.source = ""
                    }
                }
            }
        }

        Page {
            id: pageView
            Switch {
                id: viewJNISwitch
                visible: Qt.platform.os === "android"
                text: checked? "ON-> use Pure JNI\n(switch off for Java+JNI)" : "OFF-> use Java+JNI\n(switch on for Pure JNI)"
                checked: appWindow.useAltImpl
                onCheckedChanged: {
                    appWindow.useAltImpl = checked
                }
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Label {
                visible: appWindow.useAltImpl
                text: qsTr("Pure JNI not recommended.\nPlease read the blog / docs")
                color: "red"
                anchors.top:viewJNISwitch.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
            }
            Switch {
                id: viewSwitch
                text: checked? "ON-> use PDF\n(switch off for PNG)" : "OFF-> use PNG\n(switch on for PDF)"
                anchors.top: Qt.platform.os === "android"? viewJNISwitch.bottom : parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: appWindow.useAltImpl? 32 : 12
            }
            Button {
                id: viewButton
                text: Qt.platform.os === "android"? qsTr("View File\n(no feedback)") : qsTr("View File")
                onClicked: {
                    if(viewSwitch.checked) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "View File", "application/pdf", request_NO_RESPONSE_PDF, appWindow.useAltImpl)
                    } else {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "View File", "image/png", request_NO_RESPONSE_IMAGE, appWindow.useAltImpl)
                    }
                }
                anchors.top: viewSwitch.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Button {
                id: viewButtonWResult
                text: Qt.platform.os === "android"? qsTr("View File with Result\n(recommended)") : qsTr("View File with RequestId\n(recommended)")
                onClicked: {
                    if(viewSwitch.checked) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_PDF), "View File", "application/pdf", request_VIEW_FILE_PDF, appWindow.useAltImpl)
                    } else {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_IMAGE), "View File", "image/png", request_VIEW_FILE_IMAGE, appWindow.useAltImpl)
                    }
                }
                anchors.top: viewButton.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Button {
                id: viewButtonCheckMime
                text: Qt.platform.os === "android"? qsTr("Check MimeType for VIEW") : qsTr("Check MimeType for VIEW\n(not used yet on iOS)")
                property string mimeType: viewSwitch.checked? "application/pdf" : "image/png"
                onClicked: {
                    var verified = shareUtils.checkMimeTypeView(mimeType)
                    if(verified) {
                        popup.labelText = "success:\nApps available to View\n"+mimeType
                        popup.open()
                    } else {
                        popup.labelText = "sorry:\nNO Apps available to View\n"+mimeType
                        popup.open()
                    }
                }
                anchors.top: viewButtonWResult.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Image {
                id: image3
                anchors.top: parent.top
                anchors.right: parent.right
                sourceSize.width: 160
                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        image3.source = ""
                    }
                }
            }
        }

        Page {
            id: pageEdit
            Switch {
                id: editJNISwitch
                visible: Qt.platform.os === "android"
                text: checked? "ON-> use Pure JNI\n(switch off for Java+JNI)" : "OFF-> use Java+JNI\n(switch on for Pure JNI)"
                checked: appWindow.useAltImpl
                onCheckedChanged: {
                    appWindow.useAltImpl = checked
                }
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Label {
                visible: appWindow.useAltImpl
                text: qsTr("Pure JNI not recommended.\nPlease read the blog / docs")
                color: "red"
                anchors.top:editJNISwitch.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
            }
            Switch {
                id: editSwitch
                text: checked? "ON-> use PDF\n(switch off for PNG)" : "OFF-> use PNG\n(switch on for PDF)"
                anchors.top: Qt.platform.os === "android"? editJNISwitch.bottom : parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: appWindow.useAltImpl? 32 : 12
            }
            Button {
                id: editButton
                text: Qt.platform.os === "android"? qsTr("Edit File\n(no feedback)") : qsTr("Edit File")
                onClicked: {
                    if(editSwitch.checked) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Edit File", "application/pdf", request_NO_RESPONSE_PDF, appWindow.useAltImpl)
                    } else {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Edit File", "image/png", request_NO_RESPONSE_IMAGE, appWindow.useAltImpl)
                    }
                }
                anchors.top: editSwitch.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Button {
                id: editButtonWResult
                text: Qt.platform.os === "android"? qsTr("Edit File with Result\n(recommended)") : qsTr("Edit File with RequestId\n(recommeded)")
                onClicked: {
                    if(editSwitch.checked) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_PDF), "Edit File", "application/pdf", request_EDIT_FILE_PDF, appWindow.useAltImpl)
                    } else {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_IMAGE), "Edit File", "image/png", request_EDIT_FILE_IMAGE, appWindow.useAltImpl)
                    }

                }
                anchors.top: editButton.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Button {
                id: editButtonCheckMime
                text: Qt.platform.os === "android"? qsTr("Check MimeType for EDIT") : qsTr("Check MimeType for EDIT\n(not used yet on iOS)")
                property string mimeType: editSwitch.checked? "application/pdf" : "image/png"
                onClicked: {
                    var verified = shareUtils.checkMimeTypeEdit(mimeType)
                    if(verified) {
                        popup.labelText = "success:\nApps available to Edit\n"+mimeType
                        popup.open()
                    } else {
                        popup.labelText = "sorry:\nNO Apps available to Edit\n"+mimeType
                        popup.open()
                    }
                }
                anchors.top: editButtonWResult.bottom
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 24
            }
            Image {
                id: image4
                anchors.top: parent.top
                anchors.right: parent.right
                sourceSize.width: 160
                MouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        image4.source = ""
                    }
                }
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        width: parent.width
        Repeater {
            id: tabButtonRepeater
            model: [qsTr("Home"), qsTr("Text"), qsTr("Send"), qsTr("View"), qsTr("Edit")]
                TabButton {
                    text: modelData
                    width: Math.max(90, tabBar.width/tabButtonRepeater.model.length)
                }
        } // tab repeater
    } // footer

    function onShareEditDone(requestCode) {
        console.log ("share done: "+ requestCode)
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            popup.labelText = "Edit Done"
            popup.open()
            requestEditDone(requestCode)
            return
        }
        popup.labelText = "Done"
        popup.open()
    }
    Timer {
        id: delayDeleteTimer
        property int theRequestCode
        interval: 500
        repeat: false
        onTriggered: {
            requestCanceledOrViewDoneOrSendDone(theRequestCode)
        }
    }

    function onShareFinished(requestCode) {
        console.log ("share canceled: "+ requestCode)
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE) {
            popup.labelText = "View finished or canceled"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            popup.labelText = "Edit canceled"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        // Attention using ACTION_SEND it could happen that the Result comes back too fast
        // and immediately deleting the file would cause that target app couldn't finish
        // copying or printing the file
        // workaround: use a Timer
        // curious: this problem only happens if going the JAVA way
        // it doesn't happen the JNI way
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE) {
            popup.labelText = "Sending File finished or canceled"
            popup.open()
            if(appWindow.useAltImpl) {
                requestCanceledOrViewDoneOrSendDone(requestCode)
            } else {
                delayDeleteTimer.theRequestCode = requestCode
                delayDeleteTimer.start()
            }
            return
        }
        popup.labelText = "canceled"
        popup.open()
    }
    function onShareNoAppAvailable(requestCode) {
        console.log ("share no App available: "+ requestCode)
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE) {
            popup.labelText = "No App found (View File)"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            popup.labelText = "No App found (Edit File)"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE) {
            popup.labelText = "No App found (Send File)"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        popup.labelText = "No App found"
        popup.open()
    }
    function onShareError(requestCode, message) {
        console.log ("share error: "+ requestCode + " / " + message)
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE) {
            popup.labelText = "(View File) " + message
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            popup.labelText = "(Edit File) " + message
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE) {
            popup.labelText = "(Send File) " + message
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        popup.labelText = message
        popup.open()
    }

    function copyFileFromAppDataIntoDocuments(requestId) {
        return myApp.filePathDocumentsLocation(requestId)
    }

    // we must delete file from DOCUMENTS
    // edit canceled, view done, send done or no matching app found
    function requestCanceledOrViewDoneOrSendDone(requestId) {
        myApp.deleteFromDocumentsLocation(requestId)
    }
    // we must copy file back from DOCUMENTS into APP DATA and then delete from DOCUMENTS
    function requestEditDone(requestId) {
        myApp.updateFileFromDocumentsLocation(requestId)
    }

    function onNoDocumentsWorkLocation() {
        popup.labelText = qsTr("Cannot copy to Documents work folder\nPlease check permissions\nThen restart the App")
        popup.open()
    }

    // simulates that you selected a destination directory where the File should be displayed / uploaded, ...
    function onFileUrlReceived(url) {
        console.log("QML: onFileUrlReceived "+url)
        var isImage = false
        if(url.endsWith("png") || url.endsWith("jpg")) {
            isImage = true
        }
        if(!isImage) {
            popup.labelText = qsTr("received File is not an Image\n%1").arg(url)
            popup.open()
            return
        }

        if(swipeView.currentIndex === 0) {
            image0.source = "file://"+url
            return
        }
        if(swipeView.currentIndex === 1) {
            image1.source = "file://"+url
            return
        }
        if(swipeView.currentIndex === 2) {
            image2.source = "file://"+url
            return
        }
        if(swipeView.currentIndex === 3) {
            image3.source = "file://"+url
            return
        }
        if(swipeView.currentIndex === 4) {
            image4.source = "file://"+url
            return
        }

    }

    function onFileReceivedAndSaved(url) {
        onFileUrlReceived(url)
    }

    Popup {
        id: popup
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: 16
        y: 16
        implicitHeight: 160
        implicitWidth: appWindow.width * .9
        property alias labelText: popupLabel.text
        Column {
            anchors.right: parent.right
            anchors.left: parent.left
            spacing: 20
            Label {
                id: popupLabel
                topPadding: 8
                leftPadding: 8
                rightPadding: 8
                width: parent.width
                text: qsTr("Cannot copy to Documents work folder\nPlease check permissions\nThen restart the App")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            Button {
                id: okButton
                text: "OK"
                onClicked: {
                    popup.close()
                }
            } // okButton
        } // row button
    } // popup

    Connections {
        target: shareUtils
        onShareEditDone: appWindow.onShareEditDone(requestCode)
    }
    Connections {
        target: shareUtils
        onShareFinished: appWindow.onShareFinished(requestCode)
    }
    Connections {
        target: shareUtils
        onShareNoAppAvailable: appWindow.onShareNoAppAvailable(requestCode)
    }
    Connections {
        target: shareUtils
        onShareError: appWindow.onShareError(requestCode, message)
    }

    // noDocumentsWorkLocation
    Connections {
        target: myApp
        onNoDocumentsWorkLocation: appWindow.onNoDocumentsWorkLocation()
    }

    // called from outside
    Connections {
        target: shareUtils
        onFileUrlReceived: appWindow.onFileUrlReceived(url)
    }

    Connections {
        target: shareUtils
        onFileReceivedAndSaved: appWindow.onFileReceivedAndSaved(url)
    }
}
