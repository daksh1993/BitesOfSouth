import React, { useEffect, useState } from "react";
import Lottie from "react-lottie";
import successAnimation from "./success.json";
import { useNavigate, useLocation } from "react-router-dom";
import "./OrderProcessing.css"; // Import the CSS file

function OrderProcessing() {
    const navigate = useNavigate();
    const location = useLocation();
    const [processingTime, setProcessingTime] = useState(0);

    useEffect(() => {
        if (!location.state || !location.state.cart) {
            navigate("/"); // Redirect if no order data
            return;
        }

        const cartItems = location.state.cart;
        let totalCookingTime = cartItems.reduce((total, item) => total + item.makingTime, 0);
        const estimatedTime = Math.ceil(totalCookingTime / 3); // 3 chefs working in parallel
        setProcessingTime(estimatedTime);

        // Simulate order processing delay
        setTimeout(() => {
            navigate("/order-tracking", { state: { cart: cartItems, processingTime: estimatedTime } });
        }, 5000); // 5 seconds delay before moving to tracking
    }, [location, navigate]);

    const defaultOptions = {
        loop: true,
        autoplay: true,
        animationData: successAnimation,
        rendererSettings: {
            preserveAspectRatio: "xMidYMid slice",
        },
    };

    return (
        <div className="order-processing-container">
            <h2>Payment Successful!</h2>
            <Lottie options={defaultOptions} height={200} width={200} />
            <p className="processing-text">Processing your order...</p>
            <p className="time-estimate">Estimated Time: <strong>{processingTime} mins</strong></p>
        </div>
    );
}

export default OrderProcessing;