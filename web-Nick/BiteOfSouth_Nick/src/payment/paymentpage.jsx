import React, { useState } from "react";
import "./paymentpage.css";
import { FaRegCreditCard, FaMobileAlt, FaWallet, FaMoneyBillWave, FaBell, FaDoorOpen, FaMicrophone, FaPhoneSlash } from "react-icons/fa";

const PaymentPage = () => {
  const [activeTab, setActiveTab] = useState("Delivery Type");
  const [selectedTip, setSelectedTip] = useState(30); // Default tip selection
  const [selectedInstruction, setSelectedInstruction] = useState(null);

  const tips = [20, 30, 50, "Other"];
  const instructions = [
    { icon: <FaBell />, text: "Avoid ringing bell" },
    { icon: <FaDoorOpen />, text: "Leave at the door" },
    { icon: <FaMicrophone />, text: "Directions to reach" },
    { icon: <FaPhoneSlash />, text: "Avoid calling" },
  ];

  return (
    <div className="payment-container">
      {/* Apply Coupon Section */}
      <div className="section coupon-section">
        <h3 className="section-title">SAVINGS CORNER</h3>
        <div className="apply-coupon">
          <span className="coupon-icon">🏷</span>
          <span>Apply Coupon</span>
        </div>
      </div>

      {/* Delivery Type Section */}
      <div className="section delivery-section">
        <div className="delivery-tabs">
          {["Delivery Type", "Tip", "Instructions"].map((tab) => (
            <span
              key={tab}
              className={activeTab === tab ? "active" : ""}
              onClick={() => setActiveTab(tab)}
            >
              {tab}
            </span>
          ))}
        </div>

        {/* Conditional rendering for tabs */}
        {activeTab === "Delivery Type" && (
          <div className="delivery-option">
            <span className="standard-delivery">⚡ Standard</span>
            <span className="delivery-time">10 mins</span>
          </div>
        )}

        {activeTab === "Tip" && (
          <div className="tip-section">
            <p className="tip-message">
              Day & night, our delivery partners bring your favourite meals. Thank them with a tip.
            </p>
            <div className="tip-options">
              {tips.map((tip) => (
                <div
                  key={tip}
                  className={`tip-option ${selectedTip === tip ? "selected-tip" : ""}`}
                  onClick={() => setSelectedTip(tip)}
                >
                  ₹ {tip}
                  {tip === 30 && <span className="most-tipped">Most Tipped</span>}
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === "Instructions" && (
          <div className="instructions-section">
            {instructions.map((instruction, index) => (
              <div
                key={index}
                className={`instruction-option ${selectedInstruction === index ? "selected-instruction" : ""}`}
                onClick={() => setSelectedInstruction(index)}
              >
                {instruction.icon}
                <span>{instruction.text}</span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Total Payment Section */}
      <div className="section total-payment-section">
        <h3 className="section-title">To Pay</h3>
      </div>

      {/* Payment Method Section */}
      <div className="section payment-method-section">
        <h4 className="section-title">PAY USING</h4>
        <div className="payment-method">
          <FaRegCreditCard className="payment-icon" />
          <span>Credit Card</span>
        </div>
        <div className="payment-method">
          <FaMobileAlt className="payment-icon" />
          <span>UPI</span>
        </div>
        <div className="payment-method">
          <FaWallet className="payment-icon" />
          <span>Wallet</span>
        </div>
        <div className="payment-method">
          <FaMoneyBillWave className="payment-icon" />
          <span>Cash on Delivery</span>
        </div>
      </div>

      {/* Pay Button */}
      <button className="pay-button">Pay</button>
    </div>
  );
};

export default PaymentPage;
