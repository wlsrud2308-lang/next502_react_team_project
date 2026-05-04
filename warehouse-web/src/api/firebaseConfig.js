import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAxF2h05aJs17INwOIT6PFZxJS9M-4sMcs",
  authDomain: "warehouse-chat-b3200.firebaseapp.com",
  projectId: "warehouse-chat-b3200",
  storageBucket: "warehouse-chat-b3200.firebasestorage.app",
  messagingSenderId: "33192132386",
  appId: "1:33192132386:web:3802d77eb85a6ec47baf7b",
  measurementId: "G-ZEF1QXLWL2"
};

// 설정 정보를 바탕으로 Firebase 앱을 초기화
const app = initializeApp(firebaseConfig);

export const db = getFirestore(app);
