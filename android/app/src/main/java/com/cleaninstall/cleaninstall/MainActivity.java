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
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "clean_install/native";
    private static final int ICON_SIZE_PX = 96;
    private final ExecutorService _executor = Executors.newSingleThreadExecutor();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {

            switch (call.method) {

                case "getInstalledApps":
                    _executor.execute(() -> {
                        try {
                            List<Map<String, String>> apps = getInstalledApps();
                            runOnUiThread(() -> result.success(apps));
                        } catch (Exception e) {
                            runOnUiThread(() -> result.error("ERROR", e.getMessage(), null));
                        }
                    });
                    break;

                case "getSha256":
                    final String apkPath = call.argument("apkPath");
                    _executor.execute(() -> {
                        String sha = getFileSha256(apkPath);
                        runOnUiThread(() -> result.success(sha));
                    });
                    break;

                case "uninstallApp":
                    String packageName = call.argument("packageName");
                    uninstallApp(packageName);
                    result.success(null);
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
                appData.put("appName", pm.getApplicationLabel(appInfo).toString());
                appData.put("apkPath", appInfo.sourceDir);
                appData.put("packageName", appInfo.packageName);
                appData.put("dataPath", appInfo.dataDir);
                appData.put("obbPath", "/storage/emulated/0/Android/obb/" + appInfo.packageName);

                Drawable icon = pm.getApplicationIcon(appInfo);
                appData.put("icon", drawableToBase64(icon));

                appList.add(appData);
            }
        }
        return appList;
    }

    private String drawableToBase64(Drawable drawable) {
        Bitmap source;
        if (drawable instanceof BitmapDrawable) {
            source = ((BitmapDrawable) drawable).getBitmap();
        } else {
            int w = drawable.getIntrinsicWidth();
            int h = drawable.getIntrinsicHeight();
            if (w <= 0) w = ICON_SIZE_PX;
            if (h <= 0) h = ICON_SIZE_PX;
            source = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(source);
            drawable.setBounds(0, 0, w, h);
            drawable.draw(canvas);
        }

        Bitmap scaled = Bitmap.createScaledBitmap(source, ICON_SIZE_PX, ICON_SIZE_PX, true);

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        scaled.compress(Bitmap.CompressFormat.JPEG, 75, stream);

        if (scaled != source) scaled.recycle();

        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP);
    }

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