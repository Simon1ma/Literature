package com.example.english_reader;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.os.Environment;
import android.content.Context;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import com.example.english_reader.storage.FileCacheManager;
import com.example.english_reader.permissions.PermissionHandler;
import com.example.english_reader.notifications.NotificationHelper;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.english_reader/native";
    private static final int PICK_IMAGE_REQUEST = 1001;
    private static final int TAKE_PHOTO_REQUEST = 1002;
    private static final int PICK_FILE_REQUEST = 1003;
    
    private MethodChannel.Result pendingResult;
    private PermissionHandler permissionHandler;
    private FileCacheManager fileCacheManager;
    private NotificationHelper notificationHelper;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        
        // 初始化工具类
        permissionHandler = new PermissionHandler(this);
        fileCacheManager = new FileCacheManager(this);
        notificationHelper = new NotificationHelper(this);
        
        // 设置方法通道
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    // 处理来自Flutter的方法调用
                    switch (call.method) {
                        case "pickImage":
                            pickImage(result);
                            break;
                        case "takePhoto":
                            takePhoto(result);
                            break;
                        case "saveFile":
                            String content = call.argument("content");
                            String fileName = call.argument("fileName");
                            saveFile(content, fileName, result);
                            break;
                        case "readFile":
                            String readFileName = call.argument("fileName");
                            readFile(readFileName, result);
                            break;
                        case "showNotification":
                            String title = call.argument("title");
                            String message = call.argument("message");
                            showNotification(title, message, result);
                            break;
                        case "checkPermissions":
                            String permission = call.argument("permission");
                            checkPermissions(permission, result);
                            break;
                        case "requestPermissions":
                            String requestPermission = call.argument("permission");
                            requestPermissions(requestPermission, result);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                }
            );
    }

    // 选择图片
    private void pickImage(MethodChannel.Result result) {
        pendingResult = result;
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        startActivityForResult(intent, PICK_IMAGE_REQUEST);
    }

    // 拍照
    private void takePhoto(MethodChannel.Result result) {
        if (!permissionHandler.checkCameraPermission()) {
            permissionHandler.requestCameraPermission();
            result.error("PERMISSION_DENIED", "Camera permission not granted", null);
            return;
        }
        
        pendingResult = result;
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        
        // 创建保存照片的文件
        File photoFile = null;
        try {
            photoFile = fileCacheManager.createImageFile();
        } catch (IOException ex) {
            result.error("FILE_ERROR", "Error creating image file", null);
            return;
        }
        
        if (photoFile != null) {
            Uri photoURI = fileCacheManager.getUriForFile(photoFile);
            intent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
            startActivityForResult(intent, TAKE_PHOTO_REQUEST);
        }
    }

    // 保存文件
    private void saveFile(String content, String fileName, MethodChannel.Result result) {
        try {
            String filePath = fileCacheManager.saveTextFile(content, fileName);
            result.success(filePath);
        } catch (IOException e) {
            result.error("SAVE_ERROR", "Error saving file: " + e.getMessage(), null);
        }
    }

    // 读取文件
    private void readFile(String fileName, MethodChannel.Result result) {
        try {
            String content = fileCacheManager.readTextFile(fileName);
            result.success(content);
        } catch (IOException e) {
            result.error("READ_ERROR", "Error reading file: " + e.getMessage(), null);
        }
    }

    // 显示通知
    private void showNotification(String title, String message, MethodChannel.Result result) {
        notificationHelper.showNotification(title, message);
        result.success(true);
    }

    // 检查权限
    private void checkPermissions(String permission, MethodChannel.Result result) {
        boolean hasPermission = false;
        
        switch (permission) {
            case "camera":
                hasPermission = permissionHandler.checkCameraPermission();
                break;
            case "storage":
                hasPermission = permissionHandler.checkStoragePermission();
                break;
            default:
                result.error("INVALID_PERMISSION", "Invalid permission type", null);
                return;
        }
        
        result.success(hasPermission);
    }

    // 请求权限
    private void requestPermissions(String permission, MethodChannel.Result result) {
        pendingResult = result;
        
        switch (permission) {
            case "camera":
                permissionHandler.requestCameraPermission();
                break;
            case "storage":
                permissionHandler.requestStoragePermission();
                break;
            default:
                result.error("INVALID_PERMISSION", "Invalid permission type", null);
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        if (pendingResult == null) {
            return;
        }
        
        if (resultCode == RESULT_OK) {
            switch (requestCode) {
                case PICK_IMAGE_REQUEST:
                    Uri selectedImageUri = data.getData();
                    if (selectedImageUri != null) {
                        String imagePath = fileCacheManager.getPathFromUri(selectedImageUri);
                        pendingResult.success(imagePath);
                    } else {
                        pendingResult.error("SELECTION_CANCELED", "Image selection was canceled", null);
                    }
                    break;
                case TAKE_PHOTO_REQUEST:
                    String photoPath = fileCacheManager.getCurrentPhotoPath();
                    pendingResult.success(photoPath);
                    break;
                case PICK_FILE_REQUEST:
                    Uri selectedFileUri = data.getData();
                    if (selectedFileUri != null) {
                        String filePath = fileCacheManager.getPathFromUri(selectedFileUri);
                        pendingResult.success(filePath);
                    } else {
                        pendingResult.error("SELECTION_CANCELED", "File selection was canceled", null);
                    }
                    break;
            }
        } else {
            pendingResult.error("SELECTION_CANCELED", "Selection was canceled", null);
        }
        
        pendingResult = null;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (pendingResult != null) {
            boolean permissionGranted = permissionHandler.handlePermissionResult(requestCode, permissions, grantResults);
            pendingResult.success(permissionGranted);
            pendingResult = null;
        }
    }
}