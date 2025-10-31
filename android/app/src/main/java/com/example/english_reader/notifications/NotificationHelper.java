package com.example.english_reader.notifications;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.pm.PackageManager;
import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.example.english_reader.MainActivity;
import com.example.english_reader.R;

public class NotificationHelper {
    private static final String TAG = "NotificationHelper";
    private static final String CHANNEL_ID = "english_reader_channel";
    private static final String CHANNEL_NAME = "English Reader Notifications";
    private static final String CHANNEL_DESC = "Notifications for English Reader app";
    
    private final Context context;
    private final NotificationManager notificationManager;
    private int notificationId = 0;

    public NotificationHelper(Context context) {
        this.context = context;
        this.notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        createNotificationChannel();
    }

    /**
     * 创建通知渠道（Android 8.0及以上需要）
     */
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            channel.setDescription(CHANNEL_DESC);
            notificationManager.createNotificationChannel(channel);
            Log.d(TAG, "Notification channel created");
        }
    }

    /**
     * 显示基本通知
     */
    public void showNotification(String title, String message) {
        Intent intent = new Intent(context, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        
        PendingIntent pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true);
        
        if (!hasNotificationPermission()) {
            Log.w(TAG, "POST_NOTIFICATIONS permission not granted; skip notify");
            return;
        }

        notificationManager.notify(notificationId++, builder.build());
        Log.d(TAG, "Notification shown: " + title);
    }

    /**
     * 显示带有大文本样式的通知
     */
    public void showBigTextNotification(String title, String message, String bigText) {
        Intent intent = new Intent(context, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        
        PendingIntent pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(message)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(bigText))
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true);
        
        if (!hasNotificationPermission()) {
            Log.w(TAG, "POST_NOTIFICATIONS permission not granted; skip notify");
            return;
        }

        notificationManager.notify(notificationId++, builder.build());
        Log.d(TAG, "Big text notification shown: " + title);
    }

    /**
     * 显示带有进度条的通知
     */
    public void showProgressNotification(String title, String message, int progress, int maxProgress) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setOngoing(true);
        
        // 设置进度
        if (progress >= maxProgress) {
            // 进度完成，移除"正在进行"标志
            builder.setProgress(0, 0, false)
                   .setOngoing(false)
                   .setContentText("下载完成");
        } else {
            builder.setProgress(maxProgress, progress, false);
        }
        
        if (!hasNotificationPermission()) {
            Log.w(TAG, "POST_NOTIFICATIONS permission not granted; skip notify");
            return;
        }

        notificationManager.notify(notificationId, builder.build());
        
        // 如果进度完成，增加通知ID以便下次使用新的通知
        if (progress >= maxProgress) {
            notificationId++;
        }
    }

    /**
     * 取消所有通知
     */
    public void cancelAllNotifications() {
        notificationManager.cancelAll();
        Log.d(TAG, "All notifications canceled");
    }

    /**
     * 取消特定ID的通知
     */
    public void cancelNotification(int id) {
        notificationManager.cancel(id);
        Log.d(TAG, "Notification canceled: " + id);
    }

    /**
     * Android 13+ requires runtime POST_NOTIFICATIONS permission before posting.
     */
    private boolean hasNotificationPermission() {
        if (Build.VERSION.SDK_INT < 33) return true;
        return context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED;
    }
}