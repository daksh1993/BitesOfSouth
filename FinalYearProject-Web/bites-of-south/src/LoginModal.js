// src/LoginModal.js
import React, { useState } from 'react';
import { auth, db } from './firebase';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signInWithPopup, 
  GoogleAuthProvider,
  updateProfile,
  fetchSignInMethodsForEmail,
  linkWithCredential,
  EmailAuthProvider,
  sendEmailVerification
} from 'firebase/auth';
import { setDoc, doc, addDoc, collection, serverTimestamp, getDoc } from 'firebase/firestore';
import './LoginModal.css';

const LoginModal = ({ isOpen, onClose }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phoneNo, setPhoneNo] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState(null);
  const [isRegistering, setIsRegistering] = useState(false);

  if (!isOpen) return null;

  const logAuthEvent = async (userId, eventType) => {
    try {
      await addDoc(collection(db, "users", userId, "authEvents"), {
        type: eventType,
        timestamp: serverTimestamp()
      });
    } catch (err) {
      console.error("Error logging auth event:", err.code, err.message);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      await logAuthEvent(user.uid, "login");
      
      const userRef = doc(db, "users", user.uid);
      const userDoc = await getDoc(userRef);
      const userData = userDoc.data();
      console.log("Login data:", userData);
      
      if (userData?.phoneNo) {
        setPhoneNo(userData.phoneNo);
      }
      
      setName('');
      setEmail('');
      setPhoneNo('');
      setPassword('');
      setConfirmPassword('');
      setError(null);
      onClose();
    } catch (err) {
      console.error("Login error:", err.code, err.message);
      setError("Invalid email or password"); // Simplified error for now
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    try {
      const signInMethods = await fetchSignInMethodsForEmail(auth, email);
      console.log("Sign-in methods before register:", signInMethods);

      let user;
      if (signInMethods.length === 0) {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        user = userCredential.user;
        await sendEmailVerification(user);
        await logAuthEvent(user.uid, "register");
      } else {
        setError("Email already registered with another method.");
        return;
      }

      await updateProfile(user, { displayName: name });
      const userRef = doc(db, "users", user.uid);
      const userDoc = await getDoc(userRef);
      const existingData = userDoc.exists() ? userDoc.data() : {};

      const userData = {
        ...existingData,
        name: name || existingData.name,
        email: user.email,
        phoneNo: phoneNo || existingData.phoneNo || '',
        createdAt: existingData.createdAt || serverTimestamp(),
        lastLoginProvider: "email",
        emailVerified: user.emailVerified,
        googleVerified: false
      };
      await setDoc(userRef, userData, { merge: true });
      
      console.log("Registered with data:", userData);
      setName('');
      setEmail('');
      setPhoneNo('');
      setPassword('');
      setConfirmPassword('');
      setError(null);
      onClose();
    } catch (err) {
      console.error("Register error:", err.code, err.message);
      setError("Registration failed. Try again.");
    }
  };

  const handleGoogleSignIn = async () => {
    const provider = new GoogleAuthProvider();
    try {
      const googleResult = await signInWithPopup(auth, provider);
      const user = googleResult.user;
      const signInMethods = await fetchSignInMethodsForEmail(auth, user.email);
      console.log("Sign-in methods after Google:", signInMethods);

      const userRef = doc(db, "users", user.uid);
      const userDoc = await getDoc(userRef);
      const existingData = userDoc.exists() ? userDoc.data() : {};

      if (signInMethods.length === 1 && signInMethods[0] === 'google.com') {
        await logAuthEvent(user.uid, "google_register");
        const userData = {
          name: user.displayName,
          email: user.email,
          phoneNo: existingData.phoneNo || '',
          createdAt: serverTimestamp(),
          lastLoginProvider: "google",
          emailVerified: user.emailVerified,
          googleVerified: true
        };
        await setDoc(userRef, userData);
        console.log("New Google registration:", userData);
      } else {
        await logAuthEvent(user.uid, "google_login");
        const userData = {
          ...existingData,
          lastLoginProvider: "google",
          emailVerified: user.emailVerified,
          googleVerified: true
        };
        await setDoc(userRef, userData, { merge: true });
        console.log("Google login with existing data:", userData);
      }

      setName('');
      setEmail('');
      setPhoneNo('');
      setPassword('');
      setConfirmPassword('');
      setError(null);
      onClose();
    } catch (err) {
      console.error("Google sign-in error:", err.code, err.message);
      setError("Google sign-in failed.");
    }
  };

  const toggleMode = () => {
    setIsRegistering(!isRegistering);
    setError(null);
  };

  return (
    <div className={`modal-overlay ${isOpen ? 'open' : ''}`}>
      <div className="modal-content">
        <button className="modal-close-btn" onClick={onClose}>×</button>
        <h2>{isRegistering ? 'Register' : 'Sign In'}</h2>
        <form onSubmit={isRegistering ? handleRegister : handleLogin}>
          {isRegistering && (
            <div className="form-group">
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Full Name"
                required
              />
            </div>
          )}
          <div className="form-group">
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Email"
              required
            />
          </div>
          {isRegistering && (
            <div className="form-group">
              <input
                type="tel"
                value={phoneNo}
                onChange={(e) => setPhoneNo(e.target.value)}
                placeholder="Phone Number"
                required
                pattern="[0-9]{10}"
                title="Please enter a 10-digit phone number"
              />
            </div>
          )}
          <div className="form-group">
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Password"
              required
            />
          </div>
          {isRegistering && (
            <div className="form-group">
              <input
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Confirm Password"
                required
              />
            </div>
          )}
          {error && <p className="error-message">{error}</p>}
          <button type="submit" className="login-btn">
            {isRegistering ? 'Register' : 'Login'}
          </button>
        </form>

        {!isRegistering && (
          <button className="google-btn" onClick={handleGoogleSignIn}>
            <i className="fab fa-google"></i> Sign in with Google
          </button>
        )}

        <p className="toggle-text">
          {isRegistering ? 'Already have an account?' : "Don't have an account?"}
          <span className="toggle-link" onClick={toggleMode}>
            {isRegistering ? ' Sign In' : ' Register'}
          </span>
        </p>
      </div>
    </div>
  );
};

export default LoginModal;