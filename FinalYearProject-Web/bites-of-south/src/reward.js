import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth, db } from './firebase';
import { doc, getDoc, collection, getDocs, updateDoc } from 'firebase/firestore';
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
            const menuItems = await Promise.all(
              data.menuItemId.map(async (id) => {
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
        setRedeemableItems(rewardsList);
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

  const handleRedeem = async (item) => {
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

    // Deduct points immediately
    const userRef = doc(db, "users", user.uid);
    const newPoints = userPoints - requiredPoints;
    try {
      await updateDoc(userRef, { rewardPoints: newPoints });
      setUserPoints(newPoints); // Update UI instantly
      console.log(`Deducted ${requiredPoints} points. New total: ${newPoints}`);

      // Add to cart
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
    } catch (error) {
      console.error("Error deducting points:", error);
      alert("Failed to redeem reward. Please try again.");
    }
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
            <p>Loading rewards...</p>
          )}
        </div>
      </section>
    </div>
  );
};

export default Reward;