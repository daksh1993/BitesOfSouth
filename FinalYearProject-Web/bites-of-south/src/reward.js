import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth, db } from './firebase';
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';
import './reward.css';

const Reward = () => {
  const [userPoints, setUserPoints] = useState(0);
  const [redeemableItems, setRedeemableItems] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchUserPoints = async () => {
      const user = auth.currentUser;
      if (user) {
        const userRef = doc(db, "users", user.uid);
        const userDoc = await getDoc(userRef);
        if (userDoc.exists()) {
          setUserPoints(userDoc.data().rewardPoints || 0);
        }
      }
    };

    const fetchRewards = async () => {
      try {
        const rewardsRef = collection(db, "rewards");
        const rewardsSnapshot = await getDocs(rewardsRef);
        const rewardsList = await Promise.all(
          rewardsSnapshot.docs.map(async (rewardDoc) => {
            const data = rewardDoc.data();
            // Ensure menuItemId is an array; fallback to empty array if not
            const menuItemIds = Array.isArray(data.menuItemId) ? data.menuItemId : [];
            const menuItems = await Promise.all(
              menuItemIds.map(async (id) => {
                const menuItemRef = doc(db, "menu", id);
                const menuItemDoc = await getDoc(menuItemRef);
                if (menuItemDoc.exists()) {
                  return { id, ...menuItemDoc.data() };
                }
                return null;
              })
            );
            const validMenuItems = menuItems.filter(item => item !== null);
            return {
              id: rewardDoc.id,
              ...data,
              menuItems: validMenuItems,
            };
          })
        );
        // Filter out rewards with no valid menu items if needed
        setRedeemableItems(rewardsList.filter(reward => reward.menuItems.length > 0));
      } catch (error) {
        console.error("Error fetching rewards:", error);
      }
    };

    fetchUserPoints();
    fetchRewards();
  }, []);

  const handleBack = () => {
    navigate(-1);
  };

  const handleRedeem = (item) => {
    const user = auth.currentUser;
    if (!user) {
      alert("Please log in to redeem rewards.");
      return;
    }

    const requiredPoints = item.requiredPoints || 0;
    if (userPoints < requiredPoints) {
      alert("Insufficient points!");
      return;
    }

    // Check if this reward is already in the cart
    const currentCart = JSON.parse(localStorage.getItem("cart")) || [];
    if (currentCart.some(cartItem => cartItem.id === item.id && cartItem.isRedeemed)) {
      alert("This reward is already in your cart!");
      return;
    }

    // Add to cart without deducting points here
    const cartItem = {
      id: item.id,
      title: item.name,
      price: 0,
      quantity: 1,
      image: item.menuItems[0]?.image || "",
      makingTime: Math.max(...item.menuItems.map(m => m.makingTime || 15)),
      isRedeemed: true,
      requiredPoints: requiredPoints,
    };
    const updatedCart = [...currentCart, cartItem];
    localStorage.setItem('cart', JSON.stringify(updatedCart));
    navigate('/cart');
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
          stroke="#9dc01e"
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
        <p className="warning-text">*Once redeemed, points are not reversible.</p>
      </div>

      <section className="rewards-section">
        <h3 className="rewards-title">Redeem Rewards</h3>
        <div className="rewards-list">
          {redeemableItems.length > 0 ? (
            redeemableItems.map((item) => (
              <div key={item.id} className="reward-card">
                <div className="reward-images">
                  {item.menuItems.slice(0, 3).map((menuItem, index) => (
                    <img
                      key={index}
                      src={menuItem.image}
                      alt={menuItem.name || `Item ${index + 1}`}
                      className="reward-image"
                      style={{ width: `${100 / Math.min(item.menuItems.length, 3)}%` }}
                    />
                  ))}
                  <div className="reward-overlay">
                    <h4 className="reward-name">{item.name}</h4>
                    <p className="reward-points">{item.requiredPoints || 0} Points</p>
                  </div>
                </div>
                <div className="reward-info">
                  <p className="reward-description">
                    {item.menuItems.map((menuItem) => menuItem.description).join(' + ')}
                  </p>
                  <button
                    className={`redeem-btn ${userPoints < (item.requiredPoints || 0) ? 'disabled' : ''}`}
                    disabled={userPoints < (item.requiredPoints || 0)}
                    onClick={() => handleRedeem(item)}
                  >
                    Redeem
                  </button>
                </div>
              </div>
            ))
          ) : (
            <p>No rewards available or loading...</p>
          )}
        </div>
      </section>
    </div>
  );
};

export default Reward;