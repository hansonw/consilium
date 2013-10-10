package org.apache.cordova.downloader;

import java.io.File;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.net.URLConnection;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.DownloadManager;
import android.app.DownloadManager.Request;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Environment;
import android.util.Base64;
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
            String fileName = params.has("name") ? params.getString("name") : null;
            String dirName = Environment.getExternalStorageDirectory().getAbsolutePath() + "/Download/";
            File dir = new File(dirName);
            if (!dir.exists()) {
              dir.mkdirs();
            }

            String fileUrl = params.has("url") ? params.getString("url") : null;
            if (fileName == null) {
              if (fileUrl != null) {
                fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
              } else {
                fileName = "untitled";
              }
            }

            // Find a unique filename
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

            if (fileUrl != null) {
              downloadUrl(fileUrl, fileName, dirName, callbackContext);
            } else {
              downloadData(params.getString("data"), fileName, dirName, callbackContext);
            }
          } catch (JSONException e) {
            e.printStackTrace();
            Log.e("PhoneGapLog", "Downloader Plugin: Error: " + PluginResult.Status.JSON_EXCEPTION);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION));
          } catch (IOException e) {
            e.printStackTrace();
            Log.e("PhoneGapLog", "Downloader Plugin: Error: " + PluginResult.Status.IO_EXCEPTION);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.IO_EXCEPTION));
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

  private void downloadUrl(String fileUrl, String fileName, String dirName, CallbackContext callbackContext) {
    showToast("Download started.", "short");

    DownloadManager downloadManager = (DownloadManager)cordova.getActivity().getSystemService(Context.DOWNLOAD_SERVICE);
    Request req = new Request(Uri.parse(fileUrl));
    req.setNotificationVisibility(Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
       .setTitle(fileName)
       .setDestinationUri(Uri.fromFile(new File(dirName, fileName)))
       .setDescription(getAppName());
    downloadManager.enqueue(req);

    cordova.getActivity().registerReceiver(new BroadcastReceiver() {
      public void onReceive(Context context, Intent intent) {
        showToast("Download complete.", "short");
      }
    }, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));

    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
  }

  private void downloadData(String dataUri, String fileName, String dirName, CallbackContext callbackContext) throws IOException {
    File file = new File(dirName, fileName);

    String[] parts = dataUri.split(",");
    String base64 = parts[parts.length - 1];
    byte[] data = Base64.decode(base64, Base64.DEFAULT);

    BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(file));
    bos.write(data);
    bos.flush();
    bos.close();

    String mimeType = URLConnection.guessContentTypeFromName(fileName);

    DownloadManager downloadManager = (DownloadManager)cordova.getActivity().getSystemService(Context.DOWNLOAD_SERVICE);
    downloadManager.addCompletedDownload(fileName, getAppName(), true, mimeType, file.getAbsolutePath(), data.length, true);

    showToast("Download complete.", "short");
    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
  }

  private String getAppName() {
    int stringId = cordova.getActivity().getApplicationInfo().labelRes;
    return cordova.getActivity().getString(stringId);
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
