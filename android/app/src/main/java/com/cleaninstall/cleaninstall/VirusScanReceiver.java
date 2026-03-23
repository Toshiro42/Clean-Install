package com.cleaninstall.cleaninstall;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;

public class VirusScanReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {

        String packageName = intent.getData() != null
                ? intent.getData().getSchemeSpecificPart()
                : null;

        if (packageName == null) return;

        try {
            PackageManager pm = context.getPackageManager();
            ApplicationInfo appInfo =
                    pm.getApplicationInfo(packageName, 0);

            String sha256 = getFileSha256(appInfo.sourceDir);

            Intent broadcastIntent =
                    new Intent("CLEAN_INSTALL_AUTO_SCAN");

            broadcastIntent.putExtra("packageName", packageName);
            broadcastIntent.putExtra("sha256", sha256);

            context.sendBroadcast(broadcastIntent);

        } catch (Exception e) {
            Log.e("VirusScanReceiver", "Auto scan failed", e);
        }
    }

    private String getFileSha256(String filePath) {

        try {
            FileInputStream fis =
                    new FileInputStream(new File(filePath));

            MessageDigest digest =
                    MessageDigest.getInstance("SHA-256");

            byte[] buffer = new byte[8192];
            int bytesRead;

            while ((bytesRead = fis.read(buffer)) != -1) {
                digest.update(buffer, 0, bytesRead);
            }

            fis.close();

            byte[] hash = digest.digest();
            StringBuilder sb = new StringBuilder();

            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }

            return sb.toString();

        } catch (Exception e) {
            return null;
        }
    }
}
