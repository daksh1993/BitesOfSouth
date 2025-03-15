import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { 
  createUserWithEmailAndPassword, 
  signInWithPopup, 
  GoogleAuthProvider, 
  signInWithEmailAndPassword 
} from "firebase/auth";
import { auth, db } from "./firebase"; // Corrected import
import { setDoc, doc } from "firebase/firestore"; 
import "./loginpage.css";
import { FcGoogle } from "react-icons/fc"; 

const AuthPage = () => {
  const [isSignup, setIsSignup] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const navigate = useNavigate(); // Use React Router for navigation

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (isSignup && !name) {
      setError("Name is required for sign up!");
      return;
    }

    try {
      if (isSignup) {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        await setDoc(doc(db, "customer", user.uid), {
          name: name,
          email: email,
          createdAt: new Date().toISOString(),
        });

        setSuccess("Account created successfully! Please log in.");
      } else {
        await signInWithEmailAndPassword(auth, email, password);
        setSuccess("Logged in successfully!");
        navigate("/payment"); // Redirect to Payment Page
      }
    } catch (error) {
      setError(error.message);
    }
  };

  const handleGoogleSignIn = async () => {
    const provider = new GoogleAuthProvider();
    try {
      const result = await signInWithPopup(auth, provider);
      const user = result.user;

      await setDoc(
        doc(db, "customer", user.uid),
        { name: user.displayName || "", email: user.email, createdAt: new Date().toISOString() },
        { merge: true }
      );

      setSuccess("Signed in successfully!");
      navigate("/payment"); // Redirect to Payment Page
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="login-page">
      <div className="login-container">
        <h2>{isSignup ? "Sign Up" : "Log In"}</h2>

        {error && <p className="error">{error}</p>}
        {success && <p className="success">{success}</p>}

        <form onSubmit={handleSubmit}>
          {isSignup && (
            <div className="form-group">
              <label>Name</label>
              <input type="text" value={name} onChange={(e) => setName(e.target.value)} placeholder="Enter your name" required />
            </div>
          )}

          <div className="form-group">
            <label>Email</label>
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Enter your email" required />
          </div>

          <div className="form-group">
            <label>Password</label>
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="Enter your password" required />
          </div>

          <button type="submit" className="login-btn">{isSignup ? "Sign Up" : "Log In"}</button>
        </form>

        <div className="or-divider"><span>OR</span></div>

        <button className="google-signin-btn" onClick={handleGoogleSignIn}>
          <FcGoogle className="google-icon" /> Sign in with Google
        </button>

        <div className="toggle-section">
          <p onClick={() => setIsSignup(!isSignup)}>
            {isSignup ? "Already have an account? Log in" : "Don't have an account? Sign up"}
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
