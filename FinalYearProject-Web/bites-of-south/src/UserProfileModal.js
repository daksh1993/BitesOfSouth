// src/UserProfileModal.js
import React, { useState, useEffect } from 'react';
import { db } from './firebase';
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { updateProfile, updateEmail } from 'firebase/auth';
import './UserProfileModal.css';
import { useNavigate } from 'react-router-dom';

const UserProfileModal = ({ isOpen, onClose, user, onLogout }) => {
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [editedName, setEditedName] = useState('');
  const [editedEmail, setEditedEmail] = useState('');
  const [editedPhoneNo, setEditedPhoneNo] = useState('');
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchUserData = async () => {
      if (user) {
        try {
          const userRef = doc(db, 'users', user.uid);
          const userDoc = await getDoc(userRef);
          if (userDoc.exists()) {
            const data = userDoc.data();
            setUserData(data);
            setEditedName(data.name || user.displayName || '');
            setEditedEmail(data.email || user.email || '');
            setEditedPhoneNo(data.phoneNo || '');
          } else {
            setEditedName(user.displayName || '');
            setEditedEmail(user.email || '');
            setEditedPhoneNo('');
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

  const handleSave = async () => {
    try {
      const userRef = doc(db, 'users', user.uid);
      const updateData = { name: editedName, email: editedEmail, phoneNo: editedPhoneNo };
      if (editedName !== user.displayName) await updateProfile(user, { displayName: editedName });
      if (editedEmail !== user.email) await updateEmail(user, editedEmail);
      await updateDoc(userRef, updateData);
      setUserData(prev => ({ ...prev, ...updateData }));
      setIsEditing(false);
      setError(null);
    } catch (err) {
      setError(err.message);
    }
  };

  const handleEditToggle = () => {
    setIsEditing(!isEditing);
    setError(null);
  };

  const handleNavigation = (path) => {
    navigate(path);
    onClose(); // Close the modal after navigation
  };

  const handleLogout = () => {
    onLogout(); // Call the logout function passed from parent
    onClose(); // Close the modal after logout
  };

  return (
    <div className={`UserProfileModal-modal-overlay ${isOpen ? 'open' : ''}`}>
      <div className="UserProfileModal-modal-content">
        <button className="UserProfileModal-modal-close-btn" onClick={onClose}>
          <span>×</span>
        </button>
        <div className="UserProfileModal-menu-header">
          <img
            src={user?.photoURL || 'https://via.placeholder.com/40'}
            alt="User Avatar"
            className="UserProfileModal-menu-avatar"
          />
          <div className="UserProfileModal-user-info">
            <span className="UserProfileModal-user-name">{userData?.name || user?.displayName || 'User'}</span>
            <span className="UserProfileModal-user-email">{userData?.email || user?.email || 'N/A'}</span>
          </div>
        </div>
        {loading ? (
          <div className="UserProfileModal-loading">Loading...</div>
        ) : (
          <div className="UserProfileModal-menu-options">
            <ul>
              <li onClick={handleEditToggle}>
                <span className="UserProfileModal-icon">✎</span> Edit Profile
              </li>
              {isEditing && (
                <div className="UserProfileModal-edit-profile-section">
                  <div className="UserProfileModal-form-group">
                    <label>Name</label>
                    <input
                      type="text"
                      value={editedName}
                      onChange={(e) => setEditedName(e.target.value)}
                      className="UserProfileModal-edit-input"
                      placeholder="Enter your name"
                    />
                  </div>
                  <div className="UserProfileModal-form-group">
                    <label>Email</label>
                    <input
                      type="email"
                      value={editedEmail}
                      onChange={(e) => setEditedEmail(e.target.value)}
                      className="UserProfileModal-edit-input"
                      placeholder="Enter your email"
                    />
                  </div>
                  <div className="UserProfileModal-form-group">
                    <label>Phone Number</label>
                    <input
                      type="tel"
                      value={editedPhoneNo}
                      onChange={(e) => setEditedPhoneNo(e.target.value)}
                      className="UserProfileModal-edit-input"
                      placeholder="Enter your phone number"
                    />
                  </div>
                  {error && <p className="UserProfileModal-error-message">{error}</p>}
                  <button className="UserProfileModal-save-btn" onClick={handleSave}>Save Changes</button>
                </div>
              )}
              <li onClick={() => handleNavigation('/orders')}>
                <span className="UserProfileModal-icon">📦</span> Orders
              </li>
              <li onClick={handleLogout} className="UserProfileModal-logout-option">
                <span className="UserProfileModal-icon">🚪</span> Logout
              </li>
            </ul>
          </div>
        )}
      </div>
    </div>
  );
};

export default UserProfileModal;