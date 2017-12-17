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

import android.content.ContentResolver;
import android.database.Cursor;
import android.provider.MediaStore;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileOutputStream;



public class QShareUtils
{
    // dummi
    static final int EDIT_FILE = 42;  // The request code

    protected QShareUtils()
    {
       //Log.d("ekkescorner", "QShareUtils()");
    }

    public static boolean checkMimeTypeView(String mimeType) {
        if (QtNative.activity() == null)
            return false;
        Intent myIntent = new Intent();
        myIntent.setAction(Intent.ACTION_VIEW);
        // without an URI resolve always fails
        // an empty URI allows to resolve the Activity
        File fileToShare = new File("");
        Uri uri = Uri.fromFile(fileToShare);
        myIntent.setDataAndType(uri, mimeType);

        // Verify that the intent will resolve to an activity
        if (myIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            Log.d("ekkescorner checkMime ", "YEP - we can go on and View");
            return true;
        } else {
            Log.d("ekkescorner checkMime", "sorry - no App available to View");
        }
        return false;
    }

    public static boolean checkMimeTypeEdit(String mimeType) {
        if (QtNative.activity() == null)
            return false;
        Intent myIntent = new Intent();
        myIntent.setAction(Intent.ACTION_EDIT);
        // without an URI resolve always fails
        // an empty URI allows to resolve the Activity
        File fileToShare = new File("");
        Uri uri = Uri.fromFile(fileToShare);
        myIntent.setDataAndType(uri, mimeType);

        // Verify that the intent will resolve to an activity
        if (myIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            Log.d("ekkescorner checkMime ", "YEP - we can go on and Edit");
            return true;
        } else {
            Log.d("ekkescorner checkMime", "sorry - no App available to Edit");
        }
        return false;
    }

    public static boolean share(String text, String url) {
        if (QtNative.activity() == null)
            return false;
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, text + " " + url);
        sendIntent.setType("text/plain");

        // Verify that the intent will resolve to an activity
        if (sendIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            QtNative.activity().startActivity(sendIntent);
            return true;
        } else {
            Log.d("ekkescorner share", "Intent not resolved");
        }
        return false;
    }

    public static boolean sendFile(String filePath, String title, String mimeType) {
        if (QtNative.activity() == null)
            return false;
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);

        File imageFileToShare = new File(filePath);
        Uri uri = Uri.fromFile(imageFileToShare);
        Log.d("ekkescorner sendFile", uri.toString());
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
        sendIntent.setType(mimeType);

        sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        sendIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);


        // Verify that the intent will resolve to an activity
        if (sendIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            QtNative.activity().startActivity(Intent.createChooser(sendIntent, title));
            return true;
        } else {
            Log.d("ekkescorner sendFile", "Intent not resolved");
        }
        return false;
    }

    public static boolean viewFile(String filePath, String title, String mimeType) {
        if (QtNative.activity() == null)
            return false;
        Intent viewIntent = new Intent();
        viewIntent.setAction(Intent.ACTION_VIEW);

        File imageFileToShare = new File(filePath);
        Uri uri = Uri.fromFile(imageFileToShare);
        Log.d("ekkescorner viewFile", uri.toString());
        viewIntent.setDataAndType(uri, mimeType);

        viewIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        viewIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        // Verify that the intent will resolve to an activity
        if (viewIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            QtNative.activity().startActivity(Intent.createChooser(viewIntent, title));
            return true;
        } else {
            Log.d("ekkescorner viewFile", "Intent not resolved");
        }
        return false;
    }

    public static boolean editFile(String filePath, String title, String mimeType) {
        if (QtNative.activity() == null)
            return false;
        Intent editIntent = new Intent();
        editIntent.setAction(Intent.ACTION_EDIT);

        File imageFileToShare = new File(filePath);
        Uri uri = Uri.fromFile(imageFileToShare);
        Log.d("ekkescorner editFile", uri.toString());
        editIntent.setDataAndType(uri, mimeType);

        editIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        editIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        // Verify that the intent will resolve to an activity
        if (editIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            QtNative.activity().startActivityForResult(Intent.createChooser(editIntent, title), EDIT_FILE);
            return true;
        } else {
            Log.d("ekkescorner editFile", "Intent not resolved");
        }
        return false;
    }

    public static String getContentName(ContentResolver cR, Uri uri) {
      Cursor cursor = cR.query(uri, null, null, null, null);
      cursor.moveToFirst();
      int nameIndex = cursor
          .getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME);
      if (nameIndex >= 0) {
        return cursor.getString(nameIndex);
      } else {
        return null;
      }
    }

    public static String createFile(ContentResolver cR, Uri uri, String fileLocation) {
        String filePath = null;
        try {
                InputStream iStream = cR.openInputStream(uri);
                if (iStream != null) {
                    String name = getContentName(cR, uri);
                    if (name != null) {
                        filePath = fileLocation + "/" + name;
                        Log.d("ekkescorner ZZZZZ - create File", filePath);
                        File f = new File(filePath);
                        FileOutputStream tmp = new FileOutputStream(f);
                        Log.d("ekkescorner ZZZZZ - create File", "new FileOutputStream");

                        byte[] buffer = new byte[1024];
                        while (iStream.read(buffer) > 0) {
                            tmp.write(buffer);
                        }
                        tmp.close();
                        iStream.close();
                        return filePath;
                    } // name
                } // iStream
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                return filePath;
            } catch (IOException e) {
                e.printStackTrace();
                return filePath;
            } catch (Exception e) {
                e.printStackTrace();
                return filePath;
            }
        return filePath;
    }

}
