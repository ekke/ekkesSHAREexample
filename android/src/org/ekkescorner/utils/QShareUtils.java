// (c) 2017 Ekkehard Gentz (ekke)
// this project is based on ideas from
// http://blog.lasconic.com/share-on-ios-and-android-using-qml/
// see github project https://github.com/lasconic/ShareUtils-QML
// also inspired by:
// https://www.androidcode.ninja/android-share-intent-example/
// https://www.calligra.org/blogs/sharing-with-qt-on-android/
// https://stackoverflow.com/questions/7156932/open-file-in-another-app
// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
// https://stackoverflow.com/questions/5734678/custom-filtering-of-intent-chooser-based-on-installed-android-package-name
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

import java.util.List;
import android.content.pm.ResolveInfo;
import java.util.ArrayList;
import android.content.pm.PackageManager;
import java.util.Comparator;
import java.util.Collections;
import android.content.Context;
import android.os.Parcelable;


public class QShareUtils
{

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

    // thx @oxied and @pooks for the idea: https://stackoverflow.com/a/18835895/135559
    // theIntent is already configured with all needed properties and flags
    // so we only have to add the packageName of targeted app
    public static boolean createCustomChooserAndStartActivity(Intent theIntent, String title, int requestId) {
        final Context context = QtNative.activity();
        final PackageManager packageManager = context.getPackageManager();

        // MATCH_DEFAULT_ONLY: Resolution and querying flag. if set, only filters that support the CATEGORY_DEFAULT will be considered for matching.
        // Check if there is a default app for this type of content.
        ResolveInfo defaultAppInfo = packageManager.resolveActivity(theIntent, PackageManager.MATCH_DEFAULT_ONLY);
        if(defaultAppInfo == null) {
            Log.d("ekkescorner", title+" PackageManager cannot resolve Activity");
            return false;
        }
        if (!defaultAppInfo.activityInfo.name.endsWith("ResolverActivity") && !defaultAppInfo.activityInfo.name.endsWith("EditActivity")) {
            Log.d("ekkescorner", title+" defaultAppInfo not Resolver or EditActivity: "+defaultAppInfo.activityInfo.name);
            return false;
        }

        // Retrieve all apps for our intent. Check if there are any apps returned
        List<ResolveInfo> appInfoList = packageManager.queryIntentActivities(theIntent, PackageManager.MATCH_DEFAULT_ONLY);
        if (appInfoList.isEmpty()) {
            Log.d("ekkescorner", title+" appInfoList.isEmpty");
            return false;
        }
        Log.d("ekkescorner", title+" appInfoList: "+appInfoList.size());

        // Sort in alphabetical order
        Collections.sort(appInfoList, new Comparator<ResolveInfo>() {
            @Override
            public int compare(ResolveInfo first, ResolveInfo second) {
                String firstName = first.loadLabel(packageManager).toString();
                String secondName = second.loadLabel(packageManager).toString();
                return firstName.compareToIgnoreCase(secondName);
            }
        });

        List<Intent> targetedIntents = new ArrayList<Intent>();
        // Filter itself and create intent with the rest of the apps.
        for (ResolveInfo appInfo : appInfoList) {
            // get the target PackageName
            String targetPackageName = appInfo.activityInfo.packageName;
            // we don't want to share with our own app
            // in fact sharing with own app with resultCode will crash because doesn't work well with launch mode 'singleInstance'
            if (targetPackageName.equals(context.getPackageName())) {
                continue;
            }
            // if you have a blacklist of apps please exclude them here

            // we create the targeted Intent based on our already configured Intent
            Intent targetedIntent = new Intent(theIntent);
            // now add the target packageName so this Intent will only find the one specific App
            targetedIntent.setPackage(targetPackageName);
            // collect all these targetedIntents
            targetedIntents.add(targetedIntent);
        }

        // check if there are apps found for our Intent to avoid that there was only our own removed app before
        if (targetedIntents.isEmpty()) {
            Log.d("ekkescorner", title+" targetedIntents.isEmpty");
            return false;
        }

        // now we can create our Intent with custom Chooser
        // we need all collected targetedIntents as EXTRA_INITIAL_INTENTS
        // we're using the last targetedIntent as initializing Intent, because
        // chooser adds its initializing intent to the end of EXTRA_INITIAL_INTENTS :)
        Intent chooserIntent = Intent.createChooser(targetedIntents.remove(targetedIntents.size() - 1), title);
        if (targetedIntents.isEmpty()) {
            Log.d("ekkescorner", title+" only one Intent left for Chooser");
        } else {
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetedIntents.toArray(new Parcelable[] {}));
        }
        // Verify that the intent will resolve to an activity
        if (chooserIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            if(requestId > 0) {
                QtNative.activity().startActivityForResult(chooserIntent, requestId);
            } else {
                QtNative.activity().startActivity(chooserIntent);
            }
            return true;
        }
        Log.d("ekkescorner", title+" Chooser Intent not resolved. Should never happen");
        return false;
    }

    public static boolean sendFile(String filePath, String title, String mimeType, int requestId) {
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

        return createCustomChooserAndStartActivity(sendIntent, title, requestId);
    }

    public static boolean viewFile(String filePath, String title, String mimeType, int requestId) {
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

        return createCustomChooserAndStartActivity(viewIntent, title, requestId);
    }

    public static boolean editFile(String filePath, String title, String mimeType, int requestId) {
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

        return createCustomChooserAndStartActivity(editIntent, title, requestId);
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
                        Log.d("ekkescorner - create File", filePath);
                        File f = new File(filePath);
                        FileOutputStream tmp = new FileOutputStream(f);
                        Log.d("ekkescorner - create File", "new FileOutputStream");

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
