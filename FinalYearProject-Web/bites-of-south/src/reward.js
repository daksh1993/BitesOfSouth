// src/reward.js
import React from 'react';
import { useNavigate } from 'react-router-dom';
import './reward.css';

const Reward = () => {
  const userPoints = 150; // Replace with dynamic data
  const redeemableItems = [
    { id: 1, name: 'Masala Dosa', points: 50, image: 'https://plus.unsplash.com/premium_photo-1674327105076-36c4419864cf?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2FwcHVjY2lubyUyMGNvZmZlZXxlbnwwfHwwfHx8MA%3D%3D' },
    { id: 2, name: 'Filter Coffee', points: 30, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJ2Tdo_wCleQwPfgFiDQLSxyFQpTQiKL_4UA&s' },
    { id: 3, name: 'Thali', points: 280, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2yHPUpbpTFTVX8KOkfjnmgdlBgAXSQ8qcxw&s' },
    // { id: 4, name: 'Dosa Combo', points: 150, image: 'https://thumbs.dreamstime.com/b/long-drink-25554746.jpg' },
  ];

  const navigate = useNavigate();

  const handleBack = () => {
    navigate(-1); // Go back to the previous page
  };

  return (
    <div className="reward-wrapper">
      {/* Back Button */}
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

      {/* Wallet Section */}
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

      {/* Redeemable Rewards */}
      <section className="rewards-section">
        <h3 className="rewards-title">Redeem Rewards</h3>
        <div className="rewards-list">
          {redeemableItems.map((item) => (
            <div key={item.id} className="reward-item">
              <img src={item.image} alt={item.name} className="item-image" />
              <div className="item-info">
                <h4 className="item-name">{item.name}</h4>
                <p className="item-points">{item.points} Points</p>
              </div>
              <button
                className={`redeem-btn ${userPoints < item.points ? 'disabled' : ''}`}
                disabled={userPoints < item.points}
                onClick={() => alert(`Redeemed ${item.name}!`)} // Replace with your logic
              >
                Redeem
              </button>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default Reward;