// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

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
    property int request_NO_RESPONSE_JPEG: -2;
    property int request_NO_RESPONSE_DOCX: -3;

    property int request_EDIT_FILE_IMAGE: 42;
    property int request_EDIT_FILE_PDF: 44;
    property int request_EDIT_FILE_JPEG: 45;
    property int request_EDIT_FILE_DOCX: 46;

    property int request_VIEW_FILE_IMAGE: 22;
    property int request_VIEW_FILE_PDF: 21;
    property int request_VIEW_FILE_JPEG: 23;
    property int request_VIEW_FILE_DOCX: 24;

    property int request_SEND_FILE_IMAGE: 11;
    property int request_SEND_FILE_PDF: 10;
    property int request_SEND_FILE_JPEG: 12;
    property int request_SEND_FILE_DOCX: 13;

    property int index_PNG: 0
    property int index_JPEG: 1
    property int index_DOCX: 2
    property int index_PDF: 3

    property var theModel: ["Image (PNG)","Image (JPEG)", "Document (DOCX)", "PDF"]

    // alternate implementations:
    // currently only on Android and ignored under iOS)
    //
    // cpp: AndroidShareUtils implements 2 differen ways to start an Intent:
    // default: one simple JNI Call and doing other stuff in Java
    // alternate Implementation: doing it all using JNI Calls (only some parts completely implemented, because the one-JNI-fits-it-all is the recommended way)
    // attention: to test JNI with QAndroidActivityResultReceiver you must uncomment onActivityResult() in QShareActivity.java
    // warning: the JNI way is only party implemented to demonstrate how uncomfortable this is
    // better only to use the Java way
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
                text: qsTr("Swipe through Pages or TabBar to Share Text or to Send / View / Edit File (PNG, JPEG, TXT, DOCX, PDF)")
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
                text: qsTr("On Android there are two implementations: pure JNI (complicated and not complete) or one simple JNI Call + some Java Classes (recommended)\nUsing Java FileProvider Files are shared from inside your sandbox and no extra permission WRITE_EXTERNAL_STORAGE is needed.")
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
                text: qsTr("Sharing the reverse Way from other Apps to our App:\nGoTo the Page where you want to get the file.\nSwitch to another App, share File with our Example App.\nSingle Image should appear on current Page, other Filetypes or more Files should open a Popup")
                wrapMode: Label.WordWrap
                anchors.top: Qt.platform.os === "android"? androidInfoLabel.bottom : infoLabel.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
            }
            Label {
                id: permissionLabel
                visible: Qt.platform.os === "android"
                text: qsTr("To receive Files from other Apps you need WRITE_EXTERNAL_STORAGE Permission. This App will ask you if Permission not set yet.\nEasy stuff for Qt 5.10+ :)")
                wrapMode: Label.WordWrap
                anchors.top: reverseLabel.bottom
                anchors.left: parent.left
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
            ComboBox {
                id: sendSwitch
                model: theModel
                currentIndex: 0
                anchors.top: Qt.platform.os === "android"? sendJNISwitch.bottom : parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: appWindow.useAltImpl? 32 : 12
                anchors.right: sendButtonWResult.right
            }
            Button {
                id: sendButton
                text: Qt.platform.os === "android"? qsTr("Send File\n(no feedback)") : qsTr("Send File")
                onClicked: {
                    if(sendSwitch.currentIndex === index_PNG) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Send File", "image/png", request_NO_RESPONSE_IMAGE, appWindow.useAltImpl)
                        return
                    }
                    if(sendSwitch.currentIndex === index_JPEG) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_JPEG), "Send File", "image/jpeg", request_NO_RESPONSE_JPEG, appWindow.useAltImpl)
                        return
                    }
                    if(sendSwitch.currentIndex === index_DOCX) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_DOCX), "Send File", "", request_NO_RESPONSE_DOCX, appWindow.useAltImpl)
                        return
                    }
                    if(sendSwitch.currentIndex === index_PDF) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Send File", "application/pdf", request_NO_RESPONSE_PDF, appWindow.useAltImpl)
                        return
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
                    if(sendSwitch.currentIndex === index_PNG) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_IMAGE), "Send File", "image/png", request_SEND_FILE_IMAGE, appWindow.useAltImpl)
                        return
                    }
                    if(sendSwitch.currentIndex === index_JPEG) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_JPEG), "Send File", "image/jpeg", request_SEND_FILE_JPEG, appWindow.useAltImpl)
                        return
                    }
                    if(sendSwitch.currentIndex === index_DOCX) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_DOCX), "Send File", "", request_SEND_FILE_DOCX, appWindow.useAltImpl)
                        return
                    }
                    if(sendSwitch.currentIndex === index_PDF) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_PDF), "Send File", "application/pdf", request_SEND_FILE_PDF, appWindow.useAltImpl)
                        return
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
            ComboBox {
                id: viewSwitch
                model: theModel
                currentIndex: 0
                anchors.top: Qt.platform.os === "android"? viewJNISwitch.bottom : parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: appWindow.useAltImpl? 32 : 12
                anchors.right: viewButtonWResult.right
            }
            Button {
                id: viewButton
                text: Qt.platform.os === "android"? qsTr("View File\n(no feedback)") : qsTr("View File")
                onClicked: {
                    if(viewSwitch.currentIndex === index_PNG) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Send File", "image/png", request_NO_RESPONSE_IMAGE, appWindow.useAltImpl)
                        return
                    }
                    if(viewSwitch.currentIndex === index_JPEG) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_JPEG), "Send File", "image/jpeg", request_NO_RESPONSE_JPEG, appWindow.useAltImpl)
                        return
                    }
                    if(viewSwitch.currentIndex === index_DOCX) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_DOCX), "Send File", "", request_NO_RESPONSE_DOCX, appWindow.useAltImpl)
                        return
                    }
                    if(viewSwitch.currentIndex === index_PDF) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Send File", "application/pdf", request_NO_RESPONSE_PDF, appWindow.useAltImpl)
                        return
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
                    if(viewSwitch.currentIndex === index_PNG) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_IMAGE), "View File", "image/png", request_VIEW_FILE_IMAGE, appWindow.useAltImpl)
                        return
                    }
                    if(viewSwitch.currentIndex === index_JPEG) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_JPEG), "View File", "image/jpeg", request_VIEW_FILE_JPEG, appWindow.useAltImpl)
                        return
                    }
                    if(viewSwitch.currentIndex === index_DOCX) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_DOCX), "View File", "", request_VIEW_FILE_DOCX, appWindow.useAltImpl)
                        return
                    }
                    if(viewSwitch.currentIndex === index_PDF) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_PDF), "View File", "application/pdf", request_VIEW_FILE_PDF, appWindow.useAltImpl)
                        return
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
                property var theMimeTypes: ["image/png","image/jpeg","application/vnd.openxmlformats-officedocument.wordprocessingml.document","application/pdf"]
                property string mimeType: theMimeTypes[viewSwitch.currentIndex]
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
            ComboBox {
                id: editSwitch
                model: theModel
                currentIndex: 0
                anchors.top: Qt.platform.os === "android"? editJNISwitch.bottom : parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: appWindow.useAltImpl? 32 : 12
                anchors.right: editButtonWResult.right
            }
            Button {
                id: editButton
                text: Qt.platform.os === "android"? qsTr("Edit File\n(no feedback)") : qsTr("Edit File")
                onClicked: {
                    if(editSwitch.currentIndex === index_PNG) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Edit File", "image/png", request_NO_RESPONSE_IMAGE, appWindow.useAltImpl)
                        return
                    }
                    if(editSwitch.currentIndex === index_JPEG) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_JPEG), "Edit File", "image/jpeg", request_NO_RESPONSE_JPEG, appWindow.useAltImpl)
                        return
                    }
                    if(editSwitch.currentIndex === index_DOCX) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_DOCX), "Edit File", "", request_NO_RESPONSE_DOCX, appWindow.useAltImpl)
                        return
                    }
                    if(editSwitch.currentIndex === index_PDF) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Edit File", "application/pdf", request_NO_RESPONSE_PDF, appWindow.useAltImpl)
                        return
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
                    if(editSwitch.currentIndex === index_PNG) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_IMAGE), "Edit File", "image/png", request_EDIT_FILE_IMAGE, appWindow.useAltImpl)
                        return
                    }
                    if(editSwitch.currentIndex === index_JPEG) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_JPEG), "Edit File", "image/jpeg", request_EDIT_FILE_JPEG, appWindow.useAltImpl)
                        return
                    }
                    if(editSwitch.currentIndex === index_DOCX) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_DOCX), "Edit File", "", request_EDIT_FILE_DOCX, appWindow.useAltImpl)
                        return
                    }
                    if(editSwitch.currentIndex === index_PDF) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_PDF), "Edit File", "application/pdf", request_EDIT_FILE_PDF, appWindow.useAltImpl)
                        return
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
                property var theMimeTypes: ["image/png","image/jpeg","application/vnd.openxmlformats-officedocument.wordprocessingml.document","application/pdf"]
                property string mimeType: theMimeTypes[editSwitch.currentIndex]
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
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE || requestCode === request_VIEW_FILE_JPEG || requestCode === request_VIEW_FILE_DOCX) {
            popup.labelText = "View finished or canceled"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE || requestCode === request_EDIT_FILE_JPEG || requestCode === request_EDIT_FILE_DOCX) {
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
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE || requestCode === request_SEND_FILE_JPEG || requestCode === request_SEND_FILE_DOCX) {
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
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE || requestCode === request_VIEW_FILE_JPEG || requestCode === request_VIEW_FILE_DOCX) {
            popup.labelText = "No App found (View File)"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE || requestCode === request_EDIT_FILE_JPEG || requestCode === request_EDIT_FILE_DOCX) {
            popup.labelText = "No App found (Edit File)"
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE || requestCode === request_SEND_FILE_JPEG || requestCode === request_SEND_FILE_DOCX) {
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
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE || requestCode === request_VIEW_FILE_JPEG || requestCode === request_VIEW_FILE_DOCX) {
            popup.labelText = "(View File) " + message
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE || requestCode === request_EDIT_FILE_JPEG || requestCode === request_EDIT_FILE_DOCX) {
            popup.labelText = "(Edit File) " + message
            popup.open()
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE || requestCode === request_SEND_FILE_JPEG || requestCode === request_SEND_FILE_DOCX) {
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
        popup.labelText = qsTr("Cannot access external folders and files without checked permissions")
        popup.open()
    }

    // simulates that you selected a destination directory where the File should be displayed / uploaded, ...
    function onFileUrlReceived(url) {
        console.log("QML: onFileUrlReceived "+url)
        var isImage = false
        if(url.endsWith("png") || url.endsWith("jpg") || url.endsWith("jpeg")) {
            isImage = true
        }
        if(!isImage) {
            popup.labelText = qsTr("received File is not an Image\n%1").arg(url)
            popup.open()
            return
        }

        if(Qt.platform.os === "android") {
            if(!myApp.checkPermission()) {
                popup.labelText = qsTr("Displaying the Image needs permission for external storage\n%1").arg(url)
                popup.open()
                return
            }
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
