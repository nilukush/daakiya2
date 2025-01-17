import { android as androidApp } from '@nativescript/core/application';
import { Observable } from '@nativescript/core';

export class SmsService extends Observable {
    private hasPermission = false;

    constructor() {
        super();
        this.requestPermissions();
    }

    async requestPermissions(): Promise<boolean> {
        if (androidApp) {
            try {
                const permissions = android.Manifest.permission;
                const hasPermission = await permissions.requestPermissions([
                    permissions.READ_SMS,
                    permissions.RECEIVE_SMS
                ]);
                this.hasPermission = hasPermission;
                return hasPermission;
            } catch (error) {
                console.error('Permission error:', error);
                return false;
            }
        }
        return false;
    }

    async readSms(): Promise<any[]> {
        if (!this.hasPermission) {
            await this.requestPermissions();
        }

        if (androidApp) {
            const messages = [];
            const cursor = androidApp.context.getContentResolver().query(
                android.net.Uri.parse("content://sms/inbox"),
                null,
                null,
                null,
                "date DESC"
            );

            if (cursor) {
                while (cursor.moveToNext()) {
                    const message = {
                        id: cursor.getString(cursor.getColumnIndex("_id")),
                        address: cursor.getString(cursor.getColumnIndex("address")),
                        body: cursor.getString(cursor.getColumnIndex("body")),
                        date: cursor.getLong(cursor.getColumnIndex("date")),
                        type: cursor.getInt(cursor.getColumnIndex("type"))
                    };
                    messages.push(message);
                }
                cursor.close();
            }

            return messages;
        }
        return [];
    }
}