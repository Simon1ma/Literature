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

/**
 * MainActivity - Flutter应用的主Activity
 * 
 * 这个类是安卓应用的入口点，负责初始化Flutter引擎并设置与Flutter通信的通道。
 * 通过MethodChannel，Flutter可以调用安卓原生功能，如文件操作、相机、通知等。
 */
public class MainActivity extends FlutterActivity {
    // 与Flutter通信的通道名称
    private static final String CHANNEL = "com.example.english_reader/native";
    // 请求码，用于识别不同的Activity结果
    private static final int PICK_IMAGE_REQUEST = 1001;
    private static final int TAKE_PHOTO_REQUEST = 1002;
    private static final int PICK_FILE_REQUEST = 1003;
    
    // 用于存储等待结果的Flutter回调
    private MethodChannel.Result pendingResult;
    // 权限处理工具
    private PermissionHandler permissionHandler;
    // 文件缓存管理工具
    private FileCacheManager fileCacheManager;
    // 通知帮助工具
    private NotificationHelper notificationHelper;

    /**
     * 配置Flutter引擎
     * 当Flutter引擎初始化时，此方法会被调用
     * 在这里设置与Flutter的通信通道
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // 注册Flutter插件
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        
        // 初始化工具类
        permissionHandler = new PermissionHandler(this);
        fileCacheManager = new FileCacheManager(this);
        notificationHelper = new NotificationHelper(this);
        
        // 设置方法通道，用于Flutter调用安卓原生功能
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    // 处理来自Flutter的方法调用
                    switch (call.method) {
                        case "pickImage":
                            // 从相册选择图片
                            pickImage(result);
                            break;
                        case "takePhoto":
                            // 使用相机拍照
                            takePhoto(result);
                            break;
                        case "saveFile":
                            // 保存文件到设备
                            String content = call.argument("content");
                            String fileName = call.argument("fileName");
                            saveFile(content, fileName, result);
                            break;
                        case "saveTextToFile":
                            // 保存文本到设备（兼容Dart侧方法名）
                            String text = call.argument("text");
                            String saveTextFileName = call.argument("fileName");
                            saveFile(text, saveTextFileName, result);
                            break;
                        case "readFile":
                            // 从设备读取文件
                            String readFileName = call.argument("fileName");
                            readFile(readFileName, result);
                            break;
                        case "readTextFromFile":
                            // 从设备读取文本文件（兼容Dart侧方法名）
                            String readTextFileName = call.argument("fileName");
                            readFile(readTextFileName, result);
                            break;
                        case "fileExists":
                            // 判断文件是否存在
                            String existsFileName = call.argument("fileName");
                            fileExists(existsFileName, result);
                            break;
                        case "deleteFile":
                            // 删除指定文件
                            String deleteFileName = call.argument("fileName");
                            deleteFile(deleteFileName, result);
                            break;
                        case "showNotification":
                            // 显示通知
                            String title = call.argument("title");
                            String message = call.argument("message");
                            showNotification(title, message, result);
                            break;
                        case "showBigTextNotification":
                            // 显示大文本通知（降级为普通通知以保持兼容）
                            String bigTitle = call.argument("title");
                            String bigMessage = call.argument("message");
                            showNotification(bigTitle, bigMessage, result);
                            break;
                        case "showProgressNotification":
                            // 显示进度通知（降级为普通通知以保持兼容）
                            String progressTitle = call.argument("title");
                            String progressMessage = call.argument("message");
                            showNotification(progressTitle, progressMessage, result);
                            break;
                        case "checkPermissions":
                            // 检查权限
                            String permission = call.argument("permission");
                            checkPermissions(permission, result);
                            break;
                        case "requestPermissions":
                            // 请求权限
                            String requestPermission = call.argument("permission");
                            requestPermissions(requestPermission, result);
                            break;
                        case "checkCameraPermission":
                            // 仅检查相机权限（兼容Dart侧方法名）
                            checkPermissions("camera", result);
                            break;
                        case "requestCameraPermission":
                            // 仅请求相机权限（兼容Dart侧方法名）
                            requestPermissions("camera", result);
                            break;
                        case "checkStoragePermission":
                            // 仅检查存储权限（兼容Dart侧方法名）
                            checkPermissions("storage", result);
                            break;
                        case "requestStoragePermission":
                            // 仅请求存储权限（兼容Dart侧方法名）
                            requestPermissions("storage", result);
                            break;
                        case "getCacheSize":
                            // 获取缓存大小（字节）
                            getCacheSize(result);
                            break;
                        case "clearCache":
                            // 清理缓存目录
                            clearCache(result);
                            break;
                        default:
                            // 未实现的方法
                            result.notImplemented();
                            break;
                    }
                }
            );
    }

    /**
     * 从相册选择图片
     * 
     * @param result Flutter回调，用于返回结果
     */
    private void pickImage(MethodChannel.Result result) {
        pendingResult = result;
        // 创建选择图片的Intent
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        startActivityForResult(intent, PICK_IMAGE_REQUEST);
    }

    /**
     * 使用相机拍照
     * 
     * @param result Flutter回调，用于返回结果
     */
    private void takePhoto(MethodChannel.Result result) {
        // 检查相机权限
        if (!permissionHandler.checkCameraPermission()) {
            permissionHandler.requestCameraPermission();
            result.error("PERMISSION_DENIED", "Camera permission not granted", null);
            return;
        }
        
        pendingResult = result;
        // 创建拍照Intent
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        
        // 创建保存照片的文件
        File photoFile = null;
        try {
            photoFile = fileCacheManager.createImageFile();
        } catch (IOException ex) {
            result.error("FILE_ERROR", "Error creating image file", null);
            return;
        }
        
        // 设置照片保存位置并启动相机
        if (photoFile != null) {
            Uri photoURI = fileCacheManager.getUriForFile(photoFile);
            intent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI);
            startActivityForResult(intent, TAKE_PHOTO_REQUEST);
        }
    }

    /**
     * 保存文件到设备存储
     * 
     * @param content 文件内容
     * @param fileName 文件名
     * @param result Flutter回调，用于返回结果
     */
    private void saveFile(String content, String fileName, MethodChannel.Result result) {
        try {
            String filePath = fileCacheManager.saveTextFile(content, fileName);
            result.success(filePath);
        } catch (IOException e) {
            result.error("SAVE_ERROR", "Error saving file: " + e.getMessage(), null);
        }
    }

    /**
     * 从设备读取文件内容
     * 
     * @param fileName 要读取的文件名
     * @param result Flutter回调，用于返回结果
     */
    private void readFile(String fileName, MethodChannel.Result result) {
        try {
            String content = fileCacheManager.readTextFile(fileName);
            result.success(content);
        } catch (IOException e) {
            result.error("READ_ERROR", "Error reading file: " + e.getMessage(), null);
        }
    }

    /**
     * 判断内部文件目录中指定文件是否存在
     *
     * @param fileName 文件名
     * @param result Flutter回调
     */
    private void fileExists(String fileName, MethodChannel.Result result) {
        try {
            File file = new File(getFilesDir(), fileName);
            result.success(file.exists());
        } catch (Exception e) {
            result.error("EXISTS_ERROR", "Error checking file: " + e.getMessage(), null);
        }
    }

    /**
     * 删除内部文件目录中指定文件
     *
     * @param fileName 文件名
     * @param result Flutter回调
     */
    private void deleteFile(String fileName, MethodChannel.Result result) {
        try {
            File file = new File(getFilesDir(), fileName);
            boolean deleted = file.exists() && file.delete();
            result.success(deleted);
        } catch (Exception e) {
            result.error("DELETE_ERROR", "Error deleting file: " + e.getMessage(), null);
        }
    }

    /**
     * 显示本地通知
     * 
     * @param title 通知标题
     * @param message 通知内容
     * @param result Flutter回调，用于返回结果
     */
    private void showNotification(String title, String message, MethodChannel.Result result) {
        notificationHelper.showNotification(title, message);
        result.success(true);
    }

    /**
     * 统计应用缓存目录大小（字节）
     */
    private void getCacheSize(MethodChannel.Result result) {
        try {
            long size = computeDirSize(getCacheDir());
            result.success(size);
        } catch (Exception e) {
            result.error("CACHE_SIZE_ERROR", "Error computing cache size: " + e.getMessage(), null);
        }
    }

    /**
     * 清空应用缓存目录
     */
    private void clearCache(MethodChannel.Result result) {
        try {
            boolean cleared = deleteDirRecursive(getCacheDir());
            result.success(cleared);
        } catch (Exception e) {
            result.error("CLEAR_CACHE_ERROR", "Error clearing cache: " + e.getMessage(), null);
        }
    }

    private long computeDirSize(File dir) {
        if (dir == null || !dir.exists()) return 0L;
        long total = 0L;
        File[] files = dir.listFiles();
        if (files == null) return 0L;
        for (File f : files) {
            if (f.isFile()) {
                total += f.length();
            } else {
                total += computeDirSize(f);
            }
        }
        return total;
    }

    private boolean deleteDirRecursive(File dir) {
        if (dir == null || !dir.exists()) return true;
        File[] files = dir.listFiles();
        if (files != null) {
            for (File f : files) {
                if (f.isDirectory()) {
                    deleteDirRecursive(f);
                } else {
                    // ignore deletion result for individual files
                    // to continue best-effort cleanup
                    //noinspection ResultOfMethodCallIgnored
                    f.delete();
                }
            }
        }
        return dir.delete();
    }

    /**
     * 检查应用权限状态
     * 
     * @param permission 权限类型（camera或storage）
     * @param result Flutter回调，用于返回结果
     */
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

    /**
     * 请求应用权限
     * 
     * @param permission 权限类型（camera或storage）
     * @param result Flutter回调，用于返回结果
     */
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

    /**
     * 处理Activity结果回调
     * 当startActivityForResult启动的活动返回结果时调用此方法
     */
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        // 如果没有等待的结果回调，直接返回
        if (pendingResult == null) {
            return;
        }
        
        // 处理成功的结果
        if (resultCode == RESULT_OK) {
            switch (requestCode) {
                case PICK_IMAGE_REQUEST:
                    // 处理选择图片的结果
                    Uri selectedImageUri = data.getData();
                    if (selectedImageUri != null) {
                        // 获取图片的真实路径并返回给Flutter
                        String imagePath = fileCacheManager.getPathFromUri(selectedImageUri);
                        pendingResult.success(imagePath);
                    } else {
                        pendingResult.error("SELECTION_CANCELED", "Image selection was canceled", null);
                    }
                    break;
                case TAKE_PHOTO_REQUEST:
                    // 处理拍照的结果，返回照片路径
                    String photoPath = fileCacheManager.getCurrentPhotoPath();
                    pendingResult.success(photoPath);
                    break;
                case PICK_FILE_REQUEST:
                    // 处理选择文件的结果
                    Uri selectedFileUri = data.getData();
                    if (selectedFileUri != null) {
                        // 获取文件的真实路径并返回给Flutter
                        String filePath = fileCacheManager.getPathFromUri(selectedFileUri);
                        pendingResult.success(filePath);
                    } else {
                        pendingResult.error("SELECTION_CANCELED", "File selection was canceled", null);
                    }
                    break;
            }
        } else {
            // 用户取消了操作
            pendingResult.error("SELECTION_CANCELED", "Selection was canceled", null);
        }
        
        // 清除等待的结果回调
        pendingResult = null;
    }

    /**
     * 处理权限请求结果
     * 当请求权限后，系统会调用此方法返回用户的选择结果
     */
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