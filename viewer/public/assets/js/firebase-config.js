// Firebase設定
const firebaseConfig = {
  apiKey: "AIzaSyBUPBJjByvMNR2DoGwtXUYHDQnGh4J5gP8",
  authDomain: "animeishi-73560.firebaseapp.com",
  projectId: "animeishi-73560",
  storageBucket: "animeishi-73560.firebasestorage.app",
  messagingSenderId: "430615036279",
  appId: "1:430615036279:web:c124941e308d43d0942172",
  measurementId: "G-X3XNY74Z4M"
};

// Firebase初期化
firebase.initializeApp(firebaseConfig);

// Firestore初期化
window.db = firebase.firestore();

