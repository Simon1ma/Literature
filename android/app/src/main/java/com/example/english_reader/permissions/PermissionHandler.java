package com.example.english_reader.permissions;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class PermissionHandler {
    private static final String TAG = "PermissionHandler";
    private static final int REQUEST_CAMERA_PERMISSION = 100;
    private static final int REQUEST_STORAGE_PERMISSION = 101;
    
    private final Activity activity;

    public PermissionHandler(Activity activity) {
        this.activity = activity;
    }

    /**
     * 检查相机权限
     */
    public boolean checkCameraPermission() {
        return ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) 
                == PackageManager.PERMISSION_GRANTED;
    }

    /**
     * 请求相机权限
     */
    public void requestCameraPermission() {
        ActivityCompat.requestPermissions(
                activity,
                new String[]{Manifest.permission.CAMERA},
                REQUEST_CAMERA_PERMISSION
        );
    }

    /**
     * 检查存储权限
     */
    public boolean checkStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11及以上使用新的存储权限管理
            return true; // 使用应用专属存储空间，不需要特殊权限
        } else {
            return ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    == PackageManager.PERMISSION_GRANTED;
        }
    }

    /**
     * 请求存储权限
     */
    public void requestStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11及以上使用新的存储权限管理
            Log.d(TAG, "Android 11+ uses scoped storage, no need for storage permission");
        } else {
            ActivityCompat.requestPermissions(
                    activity,
                    new String[]{
                            Manifest.permission.READ_EXTERNAL_STORAGE,
                            Manifest.permission.WRITE_EXTERNAL_STORAGE
                    },
                    REQUEST_STORAGE_PERMISSION
            );
        }
    }

    /**
     * 处理权限请求结果
     */
    public boolean handlePermissionResult(int requestCode, String[] permissions, int[] grantResults) {
        if (grantResults.length == 0) {
            return false;
        }

        switch (requestCode) {
            case REQUEST_CAMERA_PERMISSION:
                return grantResults[0] == PackageManager.PERMISSION_GRANTED;
            case REQUEST_STORAGE_PERMISSION:
                boolean allGranted = true;
                for (int result : grantResults) {
                    if (result != PackageManager.PERMISSION_GRANTED) {
                        allGranted = false;
                        break;
                    }
                }
                return allGranted;
            default:
                return false;
        }
    }
}