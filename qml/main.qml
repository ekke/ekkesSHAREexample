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

    property int request_NO_RESPONSE_IMAGE: 0;
    property int request_NO_RESPONSE_PDF: -1;
    property int request_EDIT_FILE_IMAGE: 42;
    property int request_EDIT_FILE_PDF: 44;
    property int request_VIEW_FILE_IMAGE: 22;
    property int request_VIEW_FILE_PDF: 21;
    property int request_SEND_FILE_IMAGE: 11;
    property int request_SEND_FILE_PDF: 10;

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: pageTextUrl
            property alias result: textResult.text
            Button {
                id: shareButton
                text: qsTr("Share Text and Url")
                anchors.centerIn: parent
                onClicked: {
                    shareUtils.share("Qt","http://qt.io")
                }
            }
            Label {
                id: textResult
                text: ""
                anchors.top: shareButton.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
        }

        Page {
            id: pageSend
            property alias result: sendResult.text
            Switch {
                id: sendSwitch
                text: checked? "PDF" : "PNG"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: sendButton
                text: qsTr("Send File")
                onClicked: {
                    sendResult.text = ""
                    if(Qt.platform.os === "android") {
                        // if not using a RequestId we must know when Intent was finished
                        // on Android we can do this by checking the ApplicationState
                        if(sendSwitch.checked) {
                            myApp.setShareState(true, false, request_SEND_FILE_PDF)
                        } else {
                            myApp.setShareState(true, false, request_SEND_FILE_IMAGE)
                        }
                    }
                    if(sendSwitch.checked) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Send File", "application/pdf", request_NO_RESPONSE_PDF)
                    } else {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Send File", "image/png", request_NO_RESPONSE_IMAGE)
                    }
                }
                anchors.top: sendSwitch.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: sendButtonWResult
                text: qsTr("Send File with Result")
                onClicked: {
                    sendResult.text = ""
                    if(sendSwitch.checked) {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_PDF), "View File", "application/pdf", request_SEND_FILE_PDF)
                    } else {
                        shareUtils.sendFile(copyFileFromAppDataIntoDocuments(request_SEND_FILE_IMAGE), "View File", "image/png", request_SEND_FILE_IMAGE)
                    }
                }
                anchors.top: sendButton.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Label {
                id: sendResult
                text: ""
                anchors.top: sendButtonWResult.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
        }

        Page {
            id: pageView
            property alias result: viewResult.text
            Switch {
                id: viewSwitch
                text: checked? "PDF" : "PNG"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: viewButton
                text: qsTr("View File")
                onClicked: {
                    viewResult.text = ""
                    if(Qt.platform.os === "android") {
                        // if not using a RequestId we must know when Intent was finished
                        // on Android we can do this by checking the ApplicationState
                        if(viewSwitch.checkable) {
                            myApp.setShareState(true, false, request_VIEW_FILE_PDF)
                        } else {
                            myApp.setShareState(true, false, request_VIEW_FILE_IMAGE)
                        }
                    }
                    if(viewSwitch.checked) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "View File", "application/pdf", request_NO_RESPONSE_PDF)
                    } else {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "View File", "image/png", request_NO_RESPONSE_IMAGE)
                    }
                }
                anchors.top: viewSwitch.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: viewButtonWResult
                text: qsTr("View File with Result")
                onClicked: {
                    viewResult.text = ""
                    if(viewSwitch.checked) {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_PDF), "View File", "application/pdf", request_VIEW_FILE_PDF)
                    } else {
                        shareUtils.viewFile(copyFileFromAppDataIntoDocuments(request_VIEW_FILE_IMAGE), "View File", "image/png", request_VIEW_FILE_IMAGE)
                    }
                }
                anchors.top: viewButton.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: viewButtonCheckMime
                text: qsTr("Check MimeType for VIEW")
                property string mimeType: viewSwitch.checked? "application/pdf" : "image/png"
                onClicked: {
                    viewResult.text = ""
                    var verified = shareUtils.checkMimeTypeView(mimeType)
                    if(verified) {
                        viewResult.text = "success:\nApps available to View\n"+mimeType
                    } else {
                        viewResult.text = "sorry:\nNO Apps available to View\n"+mimeType
                    }
                }
                anchors.top: viewButtonWResult.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }

            Label {
                id: viewResult
                text: ""
                anchors.top: viewButtonCheckMime.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
        }

        Page {
            id: pageEdit
            property alias result: editResult.text
            Switch {
                id: editSwitch
                text: checked? "PDF" : "PNG"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: editButton
                text: qsTr("Edit File")
                onClicked: {
                    editResult.text = ""
                    if(Qt.platform.os === "android") {
                        // if not using a RequestId we must know when Edit was finished
                        // on Android we can do this by checking the ApplicationState
                        if(editSwitch.checked) {
                            myApp.setShareState(true, true, request_EDIT_FILE_PDF)
                        } else {
                            myApp.setShareState(true, true, request_EDIT_FILE_IMAGE)
                        }
                    }
                    if(editSwitch.checked) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_PDF), "Edit File", "application/pdf", request_NO_RESPONSE_PDF)
                    } else {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_NO_RESPONSE_IMAGE), "Edit File", "image/png", request_NO_RESPONSE_IMAGE)
                    }
                }
                anchors.top: editSwitch.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: editButtonWResult
                text: qsTr("Edit File with Result")
                onClicked: {
                    editResult.text = ""
                    if(editSwitch.checked) {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_PDF), "Edit File", "application/pdf", request_EDIT_FILE_PDF)
                    } else {
                        shareUtils.editFile(copyFileFromAppDataIntoDocuments(request_EDIT_FILE_IMAGE), "Edit File", "image/png", request_EDIT_FILE_IMAGE)
                    }

                }
                anchors.top: editButton.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Button {
                id: editButtonCheckMime
                text: qsTr("Check MimeType for EDIT")
                property string mimeType: editSwitch.checked? "application/pdf" : "image/png"
                onClicked: {
                    editResult.text = ""
                    var verified = shareUtils.checkMimeTypeEdit(mimeType)
                    if(verified) {
                        editResult.text = "success:\nApps available to Edit\n"+mimeType
                    } else {
                        editResult.text = "sorry:\nNO Apps available to Edit\n"+mimeType
                    }
                }
                anchors.top: editButtonWResult.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }
            Label {
                id: editResult
                text: ""
                anchors.top: editButtonCheckMime.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
            }

        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Text+URL")
        }
        TabButton {
            text: qsTr("Send")
        }
        TabButton {
            text: qsTr("View")
        }
        TabButton {
            text: qsTr("Edit")
        }
    } // footer

    function onShareEditDone(requestCode) {
        console.log ("share done: "+ requestCode)
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            pageEdit.result = "Edit Done"
            requestEditDone(requestCode)
            return
        }
        pageEdit.result = "Done"
        pageView.result = "Done"
        pageSend.result = "Done"
    }
    function onShareFinished(requestCode) {
        console.log ("share canceled: "+ requestCode)
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE) {
            pageView.result = "View finished or canceled"
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            pageEdit.result = "Edit canceled"
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE) {
            pageSend.result = "Sending File finished or canceled"
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        pageEdit.result = "canceled"
        pageView.result = "canceled"
        pageSend.result = "canceled"
    }
    function onShareNoAppAvailable(requestCode) {
        console.log ("share no App available: "+ requestCode)
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE) {
            pageView.result = "No App found (View File)"
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            pageEdit.result = "No App found (Edit File)"
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE) {
            pageSend.result = "No App found (Send File)"
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        pageEdit.result = "No App found"
        pageView.result = "No App found"
        pageSend.result = "No App found"
    }
    function onShareError(requestCode, message) {
        console.log ("share error: "+ requestCode + " / " + message)
        if(requestCode === request_VIEW_FILE_PDF || requestCode === request_VIEW_FILE_IMAGE) {
            pageView.result = "(View File) " + message
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_EDIT_FILE_PDF || requestCode === request_EDIT_FILE_IMAGE) {
            pageEdit.result = "(Edit File) " + message
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        if(requestCode === request_SEND_FILE_PDF || requestCode === request_SEND_FILE_IMAGE) {
            pageSend.result = "(Send File) " + message
            requestCanceledOrViewDoneOrSendDone(requestCode)
            return
        }
        pageEdit.result = message
        pageView.result = message
        pageSend.result = message
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
        popup.open()
    }
    Popup {
        id: popup
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: 16
        y: 16
        implicitHeight: 160
        implicitWidth: appWindow.width * .9
        Column {
            anchors.right: parent.right
            anchors.left: parent.left
            spacing: 20
            Label {
                id: popupLabel
                topPadding: 8
                leftPadding: 8
                rightPadding: 24
                text: qsTr("Cannot copy to Documents work folder\nPlease check permissions\nThen restart the App")
                wrapMode: Text.WordWrap
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
}
