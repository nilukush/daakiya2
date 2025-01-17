import { firebase } from '@nativescript/firebase-core';
import '@nativescript/firebase-auth';
import { Observable } from '@nativescript/core';

export class AuthService extends Observable {
    private auth: firebase.Auth;
    private _user: firebase.User | null = null;

    constructor() {
        super();
        this.auth = firebase.auth();
        this.auth.onAuthStateChanged((user) => {
            this._user = user;
            this.notifyPropertyChange('user', user);
        });
    }

    get user() {
        return this._user;
    }

    async signIn(email: string, password: string): Promise<firebase.User> {
        try {
            const userCredential = await this.auth.signInWithEmailAndPassword(email, password);
            return userCredential.user;
        } catch (error) {
            console.error('Sign in error:', error);
            throw error;
        }
    }

    async signUp(email: string, password: string): Promise<firebase.User> {
        try {
            const userCredential = await this.auth.createUserWithEmailAndPassword(email, password);
            return userCredential.user;
        } catch (error) {
            console.error('Sign up error:', error);
            throw error;
        }
    }

    async signOut(): Promise<void> {
        try {
            await this.auth.signOut();
        } catch (error) {
            console.error('Sign out error:', error);
            throw error;
        }
    }
}