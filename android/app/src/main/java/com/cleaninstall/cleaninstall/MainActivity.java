package com.cleaninstall.cleaninstall;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.util.Base64;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "clean_install/native";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            switch (call.method) {

                case "getInstalledApps":
                    result.success(getInstalledApps());
                    break;

                case "getSha256":
                    String apkPath = call.argument("apkPath");
                    result.success(getFileSha256(apkPath));
                    break;

                case "uninstallApp":
                    String packageName = call.argument("packageName");
                    uninstallApp(packageName);
                    result.success(null); // same as your Kotlin
                    break;

                case "isPackageInstalled":
                    String pkg = call.argument("packageName");
                    result.success(isPackageInstalled(pkg));
                    break;

                default:
                    result.notImplemented();
                    break;
            }
        });
    }

    // =========================
    // Installed Apps
    // =========================

    private List<Map<String, String>> getInstalledApps() {

        PackageManager pm = getPackageManager();
        List<PackageInfo> packages = pm.getInstalledPackages(0);
        List<Map<String, String>> appList = new ArrayList<>();

        for (PackageInfo pkg : packages) {

            ApplicationInfo appInfo = pkg.applicationInfo;

            if ((appInfo.flags & ApplicationInfo.FLAG_SYSTEM) == 0
                    && pm.getLaunchIntentForPackage(appInfo.packageName) != null
                    && !appInfo.packageName.equals(getPackageName())) {

                Map<String, String> appData = new HashMap<>();

                appData.put("appName",
                        pm.getApplicationLabel(appInfo).toString());

                appData.put("apkPath", appInfo.sourceDir);
                appData.put("packageName", appInfo.packageName);
                appData.put("dataPath", appInfo.dataDir);
                appData.put("obbPath",
                        "/storage/emulated/0/Android/obb/" + appInfo.packageName);

                Drawable icon = pm.getApplicationIcon(appInfo);
                appData.put("icon", drawableToBase64(icon));

                appList.add(appData);
            }
        }

        return appList;
    }

    // =========================
    // Drawable → Base64
    // =========================

    private String drawableToBase64(Drawable drawable) {

        Bitmap bitmap;

        if (drawable instanceof BitmapDrawable) {
            bitmap = ((BitmapDrawable) drawable).getBitmap();
        } else {
            bitmap = Bitmap.createBitmap(
                    drawable.getIntrinsicWidth(),
                    drawable.getIntrinsicHeight(),
                    Bitmap.Config.ARGB_8888
            );
            Canvas canvas = new Canvas(bitmap);
            drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
            drawable.draw(canvas);
        }

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);

        byte[] bytes = stream.toByteArray();
        return Base64.encodeToString(bytes, Base64.NO_WRAP);
    }

    // =========================
    // SHA-256
    // =========================

    private String getFileSha256(String filePath) {

        try {
            FileInputStream fis = new FileInputStream(new File(filePath));
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

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

    // =========================
    // Uninstall
    // =========================

    private void uninstallApp(String packageName) {

        Intent intent = new Intent(Intent.ACTION_DELETE);
        intent.setData(Uri.parse("package:" + packageName));
        intent.putExtra(Intent.EXTRA_RETURN_RESULT, true);

        startActivity(intent);
    }

    private boolean isPackageInstalled(String packageName) {
        try {
            getPackageManager().getPackageInfo(packageName, 0);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}