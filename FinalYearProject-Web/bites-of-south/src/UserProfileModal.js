// src/components/UserProfileModal.js
import React, { useState, useEffect } from 'react';
import { auth, db } from './firebase'; // Ensure this matches your firebase config import
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { updateProfile, updateEmail } from 'firebase/auth';
import './UserProfileModal.css';

const UserProfileModal = ({ isOpen, onClose, user }) => {
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [editedName, setEditedName] = useState('');
  const [editedEmail, setEditedEmail] = useState('');
  const [editedPhoneNo, setEditedPhoneNo] = useState('');
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUserData = async () => {
      if (user) {
        try {
          const userRef = doc(db, 'users', user.uid); // Changed from 'clients' to 'users'
          const userDoc = await getDoc(userRef);
          if (userDoc.exists()) {
            const data = userDoc.data();
            console.log("Fetched user data:", data); // Debug log
            setUserData(data);
            setEditedName(data.name || user.displayName || '');
            setEditedEmail(data.email || user.email || '');
            setEditedPhoneNo(data.phoneNo || ''); // Ensure phoneNo is set
          } else {
            console.log("No user document found, using auth data");
            setEditedName(user.displayName || '');
            setEditedEmail(user.email || '');
            setEditedPhoneNo(''); // Default to empty if no Firestore data
          }
          setLoading(false);
        } catch (err) {
          console.error('Error fetching user data:', err);
          setError('Failed to load profile data');
          setLoading(false);
        }
      }
    };
    if (isOpen) {
      fetchUserData();
    }
  }, [isOpen, user]);

  if (!isOpen) return null;

  const handleLogout = () => {
    auth.signOut();
    onClose();
  };

  const handleEditToggle = () => {
    setIsEditing(!isEditing);
    setError(null);
  };

  const handleSave = async () => {
    try {
      const userRef = doc(db, 'users', user.uid); // Changed from 'clients' to 'users'
      const updateData = {
        name: editedName,
        email: editedEmail,
        phoneNo: editedPhoneNo // Always update phoneNo
      };

      // Update Firebase Auth if name or email changed
      if (editedName !== user.displayName) {
        await updateProfile(auth.currentUser, { displayName: editedName });
      }
      if (editedEmail !== user.email) {
        await updateEmail(auth.currentUser, editedEmail);
      }

      // Update Firestore
      console.log("Saving updated data:", updateData); // Debug log
      await updateDoc(userRef, updateData);

      // Update local state
      setUserData(prev => ({
        ...prev,
        name: editedName,
        email: editedEmail,
        phoneNo: editedPhoneNo
      }));
      setIsEditing(false);
      setError(null);

      // Update auth object for consistency
      user.displayName = editedName;
      user.email = editedEmail;

      const updatedDoc = await getDoc(userRef);
      console.log("Saved data after update:", updatedDoc.data()); // Debug log
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <button className="modal-close-btn" onClick={onClose}>×</button>
        <h2>User Profile</h2>
        {loading ? (
          <p>Loading...</p>
        ) : (
          <div className="profile-details">
            <img
              src={user?.photoURL || 'https://via.placeholder.com/100'}
              alt="User Avatar"
              className="profile-avatar"
            />
            {isEditing ? (
              <>
                <div className="form-group">
                  <label><strong>Name:</strong></label>
                  <input
                    type="text"
                    value={editedName}
                    onChange={(e) => setEditedName(e.target.value)}
                    className="edit-input"
                  />
                </div>
                <div className="form-group">
                  <label><strong>Email:</strong></label>
                  <input
                    type="email"
                    value={editedEmail}
                    onChange={(e) => setEditedEmail(e.target.value)}
                    className="edit-input"
                  />
                </div>
                <div className="form-group">
                  <label><strong>Phone Number:</strong></label>
                  <input
                    type="tel"
                    value={editedPhoneNo}
                    onChange={(e) => setEditedPhoneNo(e.target.value)}
                    className="edit-input"
                    pattern="[0-9]{10}"
                    title="Please enter a 10-digit phone number"
                    placeholder="Enter phone number"
                  />
                </div>
                {error && <p className="error-message">{error}</p>}
                <button className="save-btn" onClick={handleSave}>
                  Save
                </button>
                <button className="cancel-btn" onClick={handleEditToggle}>
                  Cancel
                </button>
              </>
            ) : (
              <>
                <p><strong>Name:</strong> {userData?.name || user?.displayName || 'N/A'}</p>
                <p><strong>Email:</strong> {userData?.email || user?.email || 'N/A'}</p>
                <p><strong>Phone Number:</strong> {userData?.phoneNo || 'Not provided'}</p>
                <button className="edit-btn" onClick={handleEditToggle}>
                  Edit Profile
                </button>
                <button className="logout-btn" onClick={handleLogout}>
                  Logout
                </button>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default UserProfileModal;