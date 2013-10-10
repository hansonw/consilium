package org.apache.cordova.downloader;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.Random;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.scigit.consilium.R;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.widget.Toast;

public class Downloader extends CordovaPlugin {

  @Override
  public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) {
    if (action.equals("get")) {
      cordova.getThreadPool().execute(new Runnable() {
        public void run() {
          try {
            JSONObject params = args.getJSONObject(0);
            String fileUrl = params.getString("url");
            String fileName = params.has("name") ? params.getString("name") :
                              fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
            String dirName = Environment.getExternalStorageDirectory().getAbsolutePath()
                             + "/Download/";
            downloadUrl(fileUrl, dirName, fileName, callbackContext);
          } catch (JSONException e) {
            e.printStackTrace();
            Log.e("PhoneGapLog", "Downloader Plugin: Error: " + PluginResult.Status.JSON_EXCEPTION);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION));
          } catch (InterruptedException e) {
            e.printStackTrace();
            Log.e("PhoneGapLog", "Downloader Plugin: Error: " + PluginResult.Status.ERROR);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
          }
        }
      });
      return true;
    } else {
      Log.e("PhoneGapLog", "Downloader Plugin: Error: " + PluginResult.Status.INVALID_ACTION);
      callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.INVALID_ACTION));
      return false;
    }
  }

  private Boolean downloadUrl(String fileUrl, String dirName,
                              String fileName, CallbackContext callbackContext)
                              throws InterruptedException, JSONException {
    try {
      showToast("Download started.","short");

      File dir = new File(dirName);
      if (!dir.exists()) {
        dir.mkdirs();
      }
      File file = new File(dirName, fileName);
      if (file.exists()) {
        int idx = fileName.lastIndexOf('.');
        String name = idx >= 0 ? fileName.substring(0, idx) : fileName;
        String ext = idx >= 0 ? fileName.substring(idx+1) : "";
        for (int i = 1; file.exists(); i++) {
          fileName = name + "-" + i + "." + ext;
          file = new File(dirName, fileName);
        }
      }

      Intent intent = new Intent ();
      intent.addFlags (Intent.FLAG_ACTIVITY_NEW_TASK);
      PendingIntent pend = PendingIntent.getActivity(cordova.getActivity(), 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
      NotificationManager mNotifyManager = (NotificationManager) cordova.getActivity().getSystemService(Activity.NOTIFICATION_SERVICE);
      NotificationCompat.Builder mBuilder =
        new NotificationCompat.Builder(cordova.getActivity())
                                      .setSmallIcon(R.drawable.ic_stat_notification)
                                      .setContentTitle(cordova.getActivity().getString(R.string.app_name))
                                      .setContentText("File: " + fileName + " - 0%");

      int mNotificationId = new Random().nextInt(10000);
      mNotifyManager.notify(mNotificationId, mBuilder.build());

      URL url = new URL(fileUrl);
      HttpURLConnection ucon = (HttpURLConnection) url.openConnection();
      ucon.setRequestMethod("GET");
      ucon.connect();

      InputStream is = ucon.getInputStream();
      byte[] buffer = new byte[1024];
      int readed = 0, progress = 0, totalReaded = 0, fileSize = ucon.getContentLength();
      FileOutputStream fos = new FileOutputStream(file);
      int step = 0;
      while ((readed = is.read(buffer)) > 0) {
        fos.write(buffer, 0, readed);
        totalReaded += readed;
        int newProgress = (int) (totalReaded*100/fileSize);
        if (newProgress != progress && newProgress > step) {
          mBuilder.setProgress(100, newProgress, false);
          mBuilder.setContentText("File: " + fileName + " - " + step + "%");
          mBuilder.setContentIntent(pend);
          mNotifyManager.notify(mNotificationId, mBuilder.build());
          step = step + 1;
        }
      }
      fos.flush();
      fos.close();
      is.close();
      ucon.disconnect();

      intent = new Intent(Intent.ACTION_VIEW);
      String type = URLConnection.guessContentTypeFromName(fileName);
      if (type == null || type.equals(""))
        intent.setData(Uri.fromFile(file));
      else
        intent.setDataAndType(Uri.fromFile(file), URLConnection.guessContentTypeFromName(fileName));
      PendingIntent openResult = PendingIntent.getActivity(cordova.getActivity(), 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

      mBuilder.setContentText("Download of \"" + fileName + "\" complete").setProgress(0,0,false);
      mBuilder.setAutoCancel(true);
      mBuilder.setContentIntent(openResult);
      mNotifyManager.notify(mNotificationId, mBuilder.build());

      try {
        Thread.sleep(1000);
      } catch (InterruptedException e) {
        Log.d("PhoneGapLog", "Downloader Plugin: Thread sleep error: " + e);
      }
      showToast("Download finished.","short");

      if(!file.exists()) {
        mNotifyManager.cancel(mNotificationId);
        showToast("Download went wrong, please try again or contact the developer.","long");
        Log.e("PhoneGapLog", "Downloader Plugin: Error: Download went wrong.");
      }
      callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
      return true;
    } catch (FileNotFoundException e) {
      showToast("File does not exists or cannot connect to webserver, please try again or contact the developer.","long");
      Log.e("PhoneGapLog", "Downloader Plugin: Error downloading " + fileUrl);
      e.printStackTrace();
      callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
      return false;
    } catch (IOException e) {
      showToast("Error downloading file, please try again or contact the developer.","long");
      Log.e("PhoneGapLog", "Downloader Plugin: Error downloading " + fileUrl);
      e.printStackTrace();
      callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
      return false;
    }
  }

  private void showToast(final String message, final String duration) {
    cordova.getActivity().runOnUiThread(new Runnable() {
      public void run() {
        Toast toast;
        if(duration.equals("long")) {
          toast = Toast.makeText(cordova.getActivity(), message, Toast.LENGTH_LONG);
          } else {
          toast = Toast.makeText(cordova.getActivity(), message, Toast.LENGTH_SHORT);
        }
        toast.show();
      }
    });
  }
}
