import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "AIzaSyCby4NWOOrCQbwpBmbgqtFasJM5kusD4ig",
    authDomain: "piensa-play-56a1c.firebaseapp.com",
    projectId: "piensa-play-56a1c",
    storageBucket: "piensa-play-56a1c.appspot.com",
    messagingSenderId: "978066257302",
    appId: "1:978066257302:web:5f60cf1863758cb7e159b7",
    measurementId: "G-G60RPSQLE7"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
