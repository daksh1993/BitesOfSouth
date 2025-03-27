// src/reward.js
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth, db } from './firebase'; // Import db and auth
import { doc, getDoc } from 'firebase/firestore';
import './reward.css';

const Reward = () => {
  const [userPoints, setUserPoints] = useState(0); // Dynamic state instead of hardcoded
  const redeemableItems = [
    { id: 1, name: 'Masala Dosa', points: 50, description: '', image: 'https://plus.unsplash.com/premium_photo-1674327105076-36c4419864cf?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2FwcHVjY2lubyUyMGNvZmZlZXxlbnwwfHwwfHx8MA%3D%3D' },
    { id: 2, name: 'Filter Coffee', points: 30, description: '', image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJ2Tdo_wCleQwPfgFiDQLSxyFQpTQiKL_4UA&s' },
    { id: 3, name: 'Thali', points: 280, description: '', image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn9GcQ2yHPUpbpTFTVX8KOkfjnmgdlBgAXSQ8qcxw&s' },
  ];

  const navigate = useNavigate();

  useEffect(() => {
    const fetchUserPoints = async () => {
      const user = auth.currentUser;
      if (user) {
        const userRef = doc(db, "users", user.uid);
        const userDoc = await getDoc(userRef);
        if (userDoc.exists()) {
          const userData = userDoc.data();
          setUserPoints(userData.rewardPoints || 0); // Default to 0 if undefined
        }
      }
    };
    fetchUserPoints();
  }, []);

  const handleBack = () => {
    navigate(-1);
  };

  return (
    <div className="reward-wrapper">
      <button className="back-btn" onClick={handleBack}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="#28a745"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M15 18l-6-6 6-6" />
        </svg>
        Back
      </button>

      <div className="wallet-card">
        <div className="wallet-header">
          <h1>Dosa Points</h1>
          <div className="coin-wrapper">
            <img src="./images/CoinAnim.gif" alt="Coin Animation" className="coin-gif" />
          </div>
        </div>
        <div className="wallet-balance">
          <span className="balance-label">Your Points</span>
          <h2 className="balance-value">{userPoints} Points</h2>
        </div>
      </div>

      <section className="rewards-section">
        <h3 className="rewards-title">Redeem Rewards</h3>
        <div className="rewards-list">
          {redeemableItems.map((item) => (
            <div key={item.id} className="reward-item">
              <img src={item.image} alt={item.name} className="item-image" />
              <div className="item-details">
                <h4 className="item-name">{item.name}</h4>
                <p className="item-points">{item.points} Points</p>
                <p className="item-description">{item.description}</p>
                <button
                  className={`redeem-btn ${userPoints < item.points ? 'disabled' : ''}`}
                  disabled={userPoints < item.points}
                  onClick={() => alert(`Redeemed ${item.name}!`)}
                >
                  Redeem
                </button>
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default Reward;