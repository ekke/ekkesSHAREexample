// (c) 2017 Ekkehard Gentz (ekke)
// this project is based on ideas from
// http://blog.lasconic.com/share-on-ios-and-android-using-qml/
// see github project https://github.com/lasconic/ShareUtils-QML
// also inspired by:
// https://www.androidcode.ninja/android-share-intent-example/
// https://www.calligra.org/blogs/sharing-with-qt-on-android/
// https://stackoverflow.com/questions/7156932/open-file-in-another-app
// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
// OpenURL in At Android: got ideas from:
// https://github.com/BernhardWenzel/open-url-in-qt-android
// https://github.com/tobiatesan/android_intents_qt
//
// see also /COPYRIGHT and /LICENSE

package org.ekkescorner.examples.sharex;

import org.qtproject.qt5.android.QtNative;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.os.*;
import android.content.*;
import android.app.*;

import java.lang.String;
import android.content.Intent;
import java.io.File;
import android.net.Uri;
import android.util.Log;
import android.content.ContentResolver;
import android.webkit.MimeTypeMap;

import org.ekkescorner.utils.*;



public class QShareActivity extends QtActivity
{
    // native - must be implemented in Cpp via JNI
    // file scheme:
    public static native void setFileUrlReceived(String url);
    // content scheme:
    public static native void setFileReceivedAndSaved(String url);

    public static boolean isIntentPending;
    public static boolean isInitialized;
    public static String workingDirPath;

    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
          Log.d("ekkescorner", "QShareActivity");
          // now we're checking if the App was started from another Android App via Intent
          Intent theIntent = getIntent();
          if (theIntent != null){
              String theAction = theIntent.getAction();
              if (theAction != null){
                  Log.d("ekkescorner YYY ", theAction);
                  // now we know there's an Intent Action and we can process as usually
                  // delay processIntent();
                  isIntentPending = true;
              }
          }
    }

    @Override
    public void onNewIntent(Intent intent) {
      super.onNewIntent(intent);
      setIntent(intent);
      // Intent will be processed, if all is initialized and Qt / QML can handle the event
      if(isInitialized) {
          processIntent();
      } else {
          isIntentPending = true;
      }
    }

    public void checkPendingIntents(String workingDir) {
        isInitialized = true;
        workingDirPath = workingDir;
        Log.d("ekkescorner ZZZZZ", workingDirPath);
        if(isIntentPending) {
            isIntentPending = false;
            Log.d("ekkescorner ZZZZZ", "checkPendingIntents: true");
            processIntent();
        } else {
            Log.d("ekkescorner ZZZZZ", "nothingPending");
        }
    }

    // process the Intent if Action is SEND or VIEW
    private void processIntent(){
      Intent intent = getIntent();

      Uri intentUri;
      String intentScheme;
      String intenAction;
      // we are listening to android.intent.action.SEND or VIEW
      if (intent.getAction().equals("android.intent.action.VIEW")){
             intenAction = "VIEW";
             intentUri = intent.getData();
      } else if (intent.getAction().equals("android.intent.action.SEND")){
             intenAction = "SEND";
              Bundle bundle = intent.getExtras();
              intentUri = (Uri)bundle.get(Intent.EXTRA_STREAM);
       } else {
              Log.d("ekkescorner XXX unknown action:", intent.getAction());
              return;
       }
       Log.d("ekkescorner action:", intenAction);
       if (intentUri == null){
            Log.d("ekkescorner XXX  URI:", "is null");
            return;
       }

       // Attention: opening the own app will give Surface1 null using launchMode singleTask
       // setting launchMode singleInstance and taskAffinity the current UI still exists
       // TODO creating custom Chooser without own App
       if (intentUri.toString().indexOf("Documents/share_example_x_files") != -1) {
           Log.d("ekkescorner XXX  URI:", "is own Uri and not allowed");
           return;
       }

       // content or file
       intentScheme = intentUri.getScheme();
       if (intentScheme == null){
            Log.d("ekkescorner XXX URI Scheme:", "is null");
            return;
       }
       if(intentScheme.equals("file")){
            // URI as encoded string
            Log.d("ekkescorner XXX File URI: ", intentUri.toString());
            setFileUrlReceived(intentUri.toString());
            // we are done Qt can deal with file scheme
            return;
       }
       if(!intentScheme.equals("content")){
              Log.d("ekkescorner XXX URI unkmnown scheme: ", intentScheme);
              return;
       }
       // ok - it's a content scheme URI
       // we will try to resolve the Path to a file URI
       // if this won't work, we'll copy the file into our App working dir via InputStream
       // hopefully in most cases Pathresolver will give a path
       // to easy test if InputStream will work, there's a switch to forceInputStream

       // perhaps you nee the file extension, MimeType or Name from ContentResolver
       // here's HowTi get it:
       Log.d("ekkescorner XXX URI: ", intentUri.toString());
       ContentResolver cR = this.getContentResolver();
       MimeTypeMap mime = MimeTypeMap.getSingleton();
       String fileExtension = mime.getExtensionFromMimeType(cR.getType(intentUri));
       Log.d("ekkescorner XXX extension: ",fileExtension);
       String mimeType = cR.getType(intentUri);
       Log.d("ekkescorner XXX MimeType: ",mimeType);
       String name = QShareUtils.getContentName(cR, intentUri);
       if(name != null) {
           Log.d("ekkescorner XXX Name:", name);
       } else {
           Log.d("ekkescorner XXX Name:", "is NULL");
       }
       String filePath;
       filePath = QSharePathResolver.getRealPathFromURI(this, intentUri);
       if(filePath == null) {
            Log.d("ekkescorner XXX QSharePathResolver:", "filePath is NULL");
       } else {
            Log.d("ekkescorner XXX QSharePathResolver:", filePath);
            setFileUrlReceived(filePath);
            // we are done Qt can deal with file scheme
            return;
       }

       // going the InputStream way:
       filePath = QShareUtils.createFile(cR, intentUri, workingDirPath);
       if(filePath == null) {
           Log.d("ekkescorner XXX FilePath:", "is NULL");
           return;
       }
       setFileReceivedAndSaved(filePath);



    }

}
