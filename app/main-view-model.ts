import { Observable } from '@nativescript/core';
import { SmsService } from './services/sms.service';

export class HelloWorldModel extends Observable {
    private smsService: SmsService;
    private _messages: any[] = [];

    constructor() {
        super();
        this.smsService = new SmsService();
        this.loadMessages();
    }

    async loadMessages() {
        try {
            this._messages = await this.smsService.readSms();
            this.notifyPropertyChange('messages', this._messages);
        } catch (error) {
            console.error('Error loading messages:', error);
        }
    }

    get messages(): any[] {
        return this._messages;
    }
}