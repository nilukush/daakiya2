import { firebase } from '@nativescript/firebase-core';
import '@nativescript/firebase-firestore';
import { AuthService } from './auth.service';
import { SmsService } from './sms.service';

export interface Message {
    id: string;
    address: string;
    body: string;
    date: number;
    type: number;
    userId: string;
}

export class MessageService {
    private firestore: firebase.firestore.Firestore;
    private smsService: SmsService;
    private authService: AuthService;

    constructor(authService: AuthService) {
        this.firestore = firebase.firestore();
        this.smsService = new SmsService();
        this.authService = authService;
    }

    async syncMessages(): Promise<void> {
        if (!this.authService.user) {
            throw new Error('User not authenticated');
        }

        const messages = await this.smsService.readSms();
        const batch = this.firestore.batch();

        messages.forEach((message) => {
            const messageRef = this.firestore
                .collection('messages')
                .doc(message.id);

            batch.set(messageRef, {
                ...message,
                userId: this.authService.user.uid,
                syncedAt: firebase.firestore.FieldValue.serverTimestamp()
            });
        });

        await batch.commit();
    }

    listenToMessages(callback: (messages: Message[]) => void): () => void {
        if (!this.authService.user) {
            throw new Error('User not authenticated');
        }

        const unsubscribe = this.firestore
            .collection('messages')
            .where('userId', '==', this.authService.user.uid)
            .orderBy('date', 'desc')
            .onSnapshot((snapshot) => {
                const messages = snapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data()
                } as Message));
                callback(messages);
            });

        return unsubscribe;
    }
}