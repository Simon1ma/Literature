package com.example.english_reader.storage;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.provider.OpenableColumns;
import android.util.Log;

import androidx.core.content.FileProvider;

import java.io.BufferedReader;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * FileCacheManager - 文件缓存管理器
 * 
 * 这个类负责处理应用中的文件操作，包括：
 * - 创建和管理临时图片文件
 * - 保存和读取文本文件
 * - 处理文件URI和路径转换
 * - 管理应用的文件缓存
 */
public class FileCacheManager {
    private static final String TAG = "FileCacheManager";
    private final Context context;  // 应用上下文
    private String currentPhotoPath; // 当前拍照图片的路径
    
    /**
     * 构造函数
     * 
     * @param context 应用上下文，用于访问应用资源和目录
     */
    public FileCacheManager(android.content.Context context) {
        this.context = context;
    }

    /**
     * 创建用于保存照片的临时文件
     */
    public File createImageFile() throws IOException {
        // 创建图片文件名
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
                imageFileName,  /* 前缀 */
                ".jpg",         /* 后缀 */
                storageDir      /* 目录 */
        );

        // 保存文件路径以供后续使用
        currentPhotoPath = image.getAbsolutePath();
        return image;
    }

    /**
     * 获取当前照片路径
     */
    public String getCurrentPhotoPath() {
        return currentPhotoPath;
    }

    /**
     * 获取文件的Uri
     */
    public Uri getUriForFile(File file) {
        return FileProvider.getUriForFile(
                context,
                "com.example.english_reader.fileprovider",
                file);
    }

    /**
     * 从Uri获取文件路径
     */
    public String getPathFromUri(Uri uri) {
        if (uri == null) return null;
        String scheme = uri.getScheme();
        try {
            if ("content".equals(scheme)) {
                String fileName = getFileName(uri);
                if (fileName == null || fileName.isEmpty()) {
                    fileName = "content_" + System.currentTimeMillis();
                }
                return copyFileToInternalStorage(uri, fileName);
            } else if ("file".equals(scheme)) {
                return uri.getPath();
            } else {
                return null;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error getting file path from URI: " + e.getMessage());
            return null;
        }
    }

    /**
     * 从Uri获取文件名
     */
    private String getFileName(Uri uri) {
        if (uri == null) return null;
        String result = null;
        String scheme = uri.getScheme();
        if ("content".equals(scheme)) {
            try (Cursor cursor = context.getContentResolver().query(uri, null, null, null, null)) {
                if (cursor != null && cursor.moveToFirst()) {
                    int columnIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                    if (columnIndex != -1) {
                        result = cursor.getString(columnIndex);
                    }
                }
            } catch (Exception e) {
                Log.e(TAG, "Error getting file name: " + e.getMessage());
            }
        }
        if (result == null) {
            String path = uri.getPath();
            if (path != null) {
                int cut = path.lastIndexOf('/');
                if (cut != -1) {
                    result = path.substring(cut + 1);
                } else {
                    result = path;
                }
            }
        }
        return result;
    }

    /**
     * 将文件复制到内部存储
     */
    private String copyFileToInternalStorage(Uri uri, String fileName) {
        try {
            File outputFile = new File(context.getFilesDir(), fileName);
            try (InputStream inputStream = context.getContentResolver().openInputStream(uri);
                 BufferedInputStream bis = inputStream != null ? new BufferedInputStream(inputStream) : null;
                 BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(outputFile))) {
                if (bis == null) {
                    return null;
                }
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = bis.read(buffer)) != -1) {
                    bos.write(buffer, 0, bytesRead);
                }
                bos.flush();
                return outputFile.getAbsolutePath();
            }
        } catch (IOException e) {
            Log.e(TAG, "Error copying file: " + e.getMessage());
            return null;
        }
    }

    /**
     * 保存文本文件
     */
    public String saveTextFile(String content, String fileName) throws IOException {
        File file = new File(context.getFilesDir(), fileName);
        try (FileOutputStream fos = new FileOutputStream(file);
             OutputStreamWriter writer = new OutputStreamWriter(fos, StandardCharsets.UTF_8)) {
            writer.write(content);
            writer.flush();
            return file.getAbsolutePath();
        }
    }

    /**
     * 读取文本文件
     */
    public String readTextFile(String fileName) throws IOException {
        File file = new File(context.getFilesDir(), fileName);
        StringBuilder content = new StringBuilder();
        try (FileInputStream fis = new FileInputStream(file);
             InputStreamReader isr = new InputStreamReader(fis, StandardCharsets.UTF_8);
             BufferedReader reader = new BufferedReader(isr)) {
            String line;
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
            return content.toString();
        }
    }

    /**
     * 检查文件是否存在
     */
    public boolean fileExists(String fileName) {
        File file = new File(context.getFilesDir(), fileName);
        return file.exists();
    }

    /**
     * 删除文件
     */
    public boolean deleteFile(String fileName) {
        File file = new File(context.getFilesDir(), fileName);
        return file.exists() && file.delete();
    }

    /**
     * 获取缓存大小
     */
    public long getCacheSize() {
        return getDirSize(context.getCacheDir()) + getDirSize(context.getExternalCacheDir());
    }

    /**
     * 清除缓存
     */
    public boolean clearCache() {
        boolean result = deleteDir(context.getCacheDir());
        if (context.getExternalCacheDir() != null) {
            result &= deleteDir(context.getExternalCacheDir());
        }
        return result;
    }

    /**
     * 获取目录大小
     */
    private long getDirSize(File dir) {
        if (dir == null || !dir.exists()) {
            return 0;
        }
        
        long size = 0;
        File[] files = dir.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isFile()) {
                    size += file.length();
                } else {
                    size += getDirSize(file);
                }
            }
        }
        return size;
    }

    /**
     * 删除目录
     */
    private boolean deleteDir(File dir) {
        if (dir == null || !dir.exists() || !dir.isDirectory()) {
            return false;
        }
        
        boolean result = true;
        File[] files = dir.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isFile()) {
                    result &= file.delete();
                } else {
                    result &= deleteDir(file);
                }
            }
        }
        return result;
    }
}