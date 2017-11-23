// (c) 2017 Ekkehard Gentz (ekke)
// this project is based on ideas from
// http://blog.lasconic.com/share-on-ios-and-android-using-qml/
// see github project https://github.com/lasconic/ShareUtils-QML
// also inspired by:
// https://www.androidcode.ninja/android-share-intent-example/
// https://www.calligra.org/blogs/sharing-with-qt-on-android/
// https://stackoverflow.com/questions/7156932/open-file-in-another-app
// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
// see also /COPYRIGHT and /LICENSE

package org.ekkescorner.utils;

import org.qtproject.qt5.android.QtNative;

import java.lang.String;
import android.content.Intent;
import java.io.File;
import android.net.Uri;
import android.util.Log;



public class QShareUtils
{
    static final int EDIT_FILE = 42;  // The request code

    protected QShareUtils()
    {
       //Log.d("ekkescorner", "QShareUtils()");
    }

    public static void share(String text, String url) {
        if (QtNative.activity() == null)
            return;
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, text + " " + url);
        sendIntent.setType("text/plain");
        QtNative.activity().startActivity(sendIntent);
    }

    public static void sendFile(String filePath, String title, String mimeType) {
        if (QtNative.activity() == null)
            return;
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);

        File imageFileToShare = new File(filePath);
        Uri uri = Uri.fromFile(imageFileToShare);
        Log.d("ekkescorner sendFile", uri.toString());
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
        sendIntent.setType(mimeType);

        sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        sendIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        QtNative.activity().startActivity(Intent.createChooser(sendIntent, title));
    }

    public static void viewFile(String filePath, String title, String mimeType) {
        if (QtNative.activity() == null)
            return;
        Intent viewIntent = new Intent();
        viewIntent.setAction(Intent.ACTION_VIEW);

        File imageFileToShare = new File(filePath);
        Uri uri = Uri.fromFile(imageFileToShare);
        Log.d("ekkescorner viewFile", uri.toString());
        viewIntent.setDataAndType(uri, mimeType);

        viewIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        viewIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        QtNative.activity().startActivity(Intent.createChooser(viewIntent, title));
    }

    public static void editFile(String filePath, String title, String mimeType) {
        if (QtNative.activity() == null)
            return;
        Intent editIntent = new Intent();
        editIntent.setAction(Intent.ACTION_EDIT);

        File imageFileToShare = new File(filePath);
        Uri uri = Uri.fromFile(imageFileToShare);
        Log.d("ekkescorner editFile", uri.toString());
        editIntent.setDataAndType(uri, mimeType);

        editIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        editIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        QtNative.activity().startActivityForResult(Intent.createChooser(editIntent, title), EDIT_FILE);
    }

}
