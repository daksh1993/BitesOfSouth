import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import {getAuth} from "firebase/auth";
import {getFirestore} from "firebase/firestore";


const firebaseConfig = {
  apiKey: "AIzaSyCUyC9GwgKJExVhv-qqXZgNlxZax2PLKls",
  authDomain: "loginpage-c84b2.firebaseapp.com",
  projectId: "loginpage-c84b2",
  storageBucket: "loginpage-c84b2.firebasestorage.app",
  messagingSenderId: "897810175641",
  appId: "1:897810175641:web:d4e8b5e691e07c8c978a08",
  measurementId: "G-09L7TRMJVN"
};

// Initialize Firebase

const app = initializeApp(firebaseConfig);
export const auth=getAuth();
export const db=getFirestore(app);
const analytics = getAnalytics(app);
export default app;