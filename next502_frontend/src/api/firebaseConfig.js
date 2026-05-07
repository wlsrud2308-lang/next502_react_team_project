import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: 'AIzaSyDB_qyHVLjz_OXbp5SjQsTVZtxl5Bh_fbA',
  authDomain: 'warehouse-chat-66b3f.firebaseapp.com',
  projectId: 'warehouse-chat-66b3f',
  storageBucket: 'warehouse-chat-66b3f.firebasestorage.app',
  messagingSenderId: '811447269272',
  appId: '1:811447269272:web:e1eb3533e9480b47bcdded',
  measurementId: 'G-EMS4VCTCGX',
};

// 설정 정보를 바탕으로 Firebase 앱을 초기화
const app = initializeApp(firebaseConfig);

export const db = getFirestore(app);
export const auth = getAuth(app);
