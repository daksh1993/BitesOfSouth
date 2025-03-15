import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';  // Import useNavigate for navigation
import "./menupage.css";

const menuImages = [
    { src: '/images/menu4.jpg', alt: 'Menu 1' },
    { src: '/images/menu4.jpg', alt: 'Menu 2' },
    { src: '/images/menu4.jpg', alt: 'Menu 3' },
    { src: '/images/menu4.jpg', alt: 'Menu 4' }
];

const iconImages = [
    { src: '/images/dosa.png', alt: 'Dosa' },
    { src: '/images/idli.png', alt: 'Idli' },
    { src: '/images/uttapam.png', alt: 'Uttapam' },
    { src: '/images/thali.png', alt: 'Thali' },
    { src: '/images/rasam.png', alt: 'Rasam' },
    { src: '/images/beverages.png', alt: 'Beverages' }
];

const MenuPage = () => {
    const navigate = useNavigate();
    const [currentIndex, setCurrentIndex] = useState(0);

    // Auto-slide effect for menu images
    useEffect(() => {
        const interval = setInterval(() => {
            setCurrentIndex(prevIndex => (prevIndex + 1) % menuImages.length);
        }, 3000); // Change image every 3 seconds
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="menu-page">
            {/* Admin Panel */}
            <header className="taskbar">
                <div className="logo-container">
                    <img src="/images/logo.png" alt="Logo" className="logo" />
                </div>
                <div className="auth-buttons">
                    <button className="login-btn" onClick={() => navigate('/login')}>Login</button>
                    <button className="signup-btn" onClick={() => navigate('/login')}>Signup</button>
                </div>
            </header>

            {/* Content Wrapper */}
            <div className="content-wrapper">
                {/* Image Carousel */}
                <div className="carousel">
                    <img src={menuImages[currentIndex].src} alt={menuImages[currentIndex].alt} className="carousel-image" />
                    {/* Dots Indicator */}
                    <div className="dots-container">
                        {menuImages.map((_, index) => (
                            <span key={index} className={`dot ${index === currentIndex ? "active" : ""}`}></span>
                        ))}
                    </div>
                </div>

                {/* Icons Grid */}
                <div className="icon-grid">
                    {iconImages.map((icon, index) => (
                        <div className="icon-item" key={icon.src}>
                            <img src={icon.src} alt={icon.alt} className="icon-size logo" />
                            <p>{icon.alt}</p>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

export default MenuPage;
