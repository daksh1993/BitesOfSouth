import React, { useState, useEffect } from 'react';
import { auth, db } from './firebase';
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { updateProfile, updateEmail } from 'firebase/auth';
import { useNavigate } from 'react-router-dom'; // For navigation
import './UserProfileModal.css';

const UserProfileModal = ({ isOpen, onClose, user }) => {
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [editedName, setEditedName] = useState('');
  const [editedEmail, setEditedEmail] = useState('');
  const [editedPhoneNo, setEditedPhoneNo] = useState('');
  const [error, setError] = useState(null);
  const navigate = useNavigate(); // React Router hook for navigation

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
      const userRef = doc(db, 'users', user.uid);
      const updateData = { name: editedName, email: editedEmail, phoneNo: editedPhoneNo };
      if (editedName !== user.displayName) await updateProfile(auth.currentUser, { displayName: editedName });
      if (editedEmail !== user.email) await updateEmail(auth.currentUser, editedEmail);
      await updateDoc(userRef, updateData);
      setUserData(prev => ({ ...prev, ...updateData }));
      setIsEditing(false);
      setError(null);
      user.displayName = editedName;
      user.email = editedEmail;
    } catch (err) {
      setError(err.message);
    }
  };

  const handleOrdersClick = () => {
    onClose(); // Close the modal
    navigate('/orders'); // Navigate to full-screen Orders page
  };

  return (
    <div className={`modal-overlay ${isOpen ? 'open' : ''}`}>
      <div className="modal-content">
        <button className="modal-close-btn" onClick={onClose}>
          <span>×</span>
        </button>
        <div className="menu-header">
          <img
            src={user?.photoURL || 'https://via.placeholder.com/40'}
            alt="User Avatar"
            className="menu-avatar"
          />
          <div className="user-info">
            <span className="user-name">{userData?.name || user?.displayName || 'User'}</span>
            <span className="user-email">{userData?.email || user?.email || 'N/A'}</span>
          </div>
        </div>
        {loading ? (
          <div className="loading">Loading...</div>
        ) : (
          <div className="menu-options">
            <ul>
              <li onClick={handleEditToggle}>
                <span className="icon">✎</span> Edit Profile
              </li>
              {isEditing && (
                <div className="edit-profile-section">
                  <div className="form-group">
                    <label>Name</label>
                    <input
                      type="text"
                      value={editedName}
                      onChange={(e) => setEditedName(e.target.value)}
                      className="edit-input"
                      placeholder="Enter your name"
                    />
                  </div>
                  <div className="form-group">
                    <label>Email</label>
                    <input
                      type="email"
                      value={editedEmail}
                      onChange={(e) => setEditedEmail(e.target.value)}
                      className="edit-input"
                      placeholder="Enter your email"
                    />
                  </div>
                  <div className="form-group">
                    <label>Phone Number</label>
                    <input
                      type="tel"
                      value={editedPhoneNo}
                      onChange={(e) => setEditedPhoneNo(e.target.value)}
                      className="edit-input"
                      placeholder="Enter your phone number"
                    />
                  </div>
                  {error && <p className="error-message">{error}</p>}
                  <button className="save-btn" onClick={handleSave}>Save Changes</button>
                </div>
              )}
              <li onClick={handleOrdersClick}>
                <span className="icon">📦</span> Orders
              </li>
              <li onClick={handleLogout} className="logout-option">
                <span className="icon">🚪</span> Logout
              </li>
            </ul>
          </div>
        )}
      </div>
    </div>
  );
};

export default UserProfileModal;