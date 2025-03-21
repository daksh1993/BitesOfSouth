import React, { useEffect, useState } from "react";
import "./Menu.css";
import { getDocs, collection } from "firebase/firestore";
import { db } from "./firebase";
import { useNavigate, useLocation } from "react-router-dom";

function Menu() {
  const [cart, setCart] = useState([]);
  const [showCartPopup, setShowCartPopup] = useState(false);
  const [menuItems, setMenuItems] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortOption, setSortOption] = useState("");
  const [category, setCategory] = useState("All");
  const [categories, setCategories] = useState([]);
  const [selectedItem, setSelectedItem] = useState(null); // For zoomed-in modal
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    fetchMenu();
    loadCart();

    const searchParams = new URLSearchParams(location.search);
    const filter = searchParams.get("filter");
    if (filter) {
      setCategory(filter);
    }
  }, [location.search]);

  const fetchMenu = async () => {
    const querySnapshot = await getDocs(collection(db, "menu"));
    const menuData = querySnapshot.docs.map((doc) => doc.data());
    setMenuItems(menuData);
    const uniqueCategories = [...new Set(menuData.map((item) => item.category))];
    setCategories(uniqueCategories);
  };

  const loadCart = () => {
    const storedCart = JSON.parse(localStorage.getItem("cart")) || [];
    setCart(storedCart);
    if (storedCart.length > 0) {
      setShowCartPopup(true);
    }
  };

  const addToCart = (item) => {
    setCart((prevCart) => {
      const existingItem = prevCart.find((cartItem) => cartItem.title === item.title);
      let updatedCart;
      if (existingItem) {
        updatedCart = prevCart.map((cartItem) =>
          cartItem.title === item.title
            ? { ...cartItem, quantity: cartItem.quantity + 1 }
            : cartItem
        );
      } else {
        updatedCart = [...prevCart, { ...item, quantity: 1 }];
      }
      localStorage.setItem("cart", JSON.stringify(updatedCart));
      return updatedCart;
    });
    setShowCartPopup(true);
  };

  const removeFromCart = (item) => {
    setCart((prevCart) => {
      const existingItem = prevCart.find((cartItem) => cartItem.title === item.title);
      let updatedCart;
      if (existingItem.quantity > 1) {
        updatedCart = prevCart.map((cartItem) =>
          cartItem.title === item.title
            ? { ...cartItem, quantity: cartItem.quantity - 1 }
            : cartItem
        );
      } else {
        updatedCart = prevCart.filter((cartItem) => cartItem.title !== item.title);
      }
      localStorage.setItem("cart", JSON.stringify(updatedCart));
      if (updatedCart.length === 0) setShowCartPopup(false);
      return updatedCart;
    });
  };

  const goToCart = () => {
    if (cart.length > 0) {
      navigate("/Cart");
    }
  };

  const getItemQuantity = (itemTitle) => {
    const item = cart.find((cartItem) => cartItem.title === itemTitle);
    return item ? item.quantity : 0;
  };

  const filteredMenu = menuItems.filter((item) => {
    return (
      item.title.toLowerCase().includes(searchQuery.toLowerCase()) &&
      (category === "All" || item.category.toLowerCase() === category.toLowerCase())
    );
  });

  const sortedMenu = [...filteredMenu].sort((a, b) => {
    if (sortOption === "priceLowHigh") return a.price - b.price;
    if (sortOption === "priceHighLow") return b.price - a.price;
    if (sortOption === "ratingHighLow") return b.rating - a.rating;
    if (sortOption === "ratingLowHigh") return a.rating - b.rating;
    return 0;
  });

  const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
  const totalPrice = cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const openItemModal = (item) => {
    setSelectedItem(item);
  };

  const closeItemModal = () => {
    setSelectedItem(null);
  };

  return (
    <div className="top">
      {/* Search Input */}
      <div className="SearchBtn">
        <input
          type="text"
          placeholder="Search for dishes"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        <i className="fa-solid fa-magnifying-glass"></i>
      </div>

      {/* Filter and Sort Options */}
      <div className="FilterSortContainer">
        <select
          className="Sorting"
          value={sortOption}
          onChange={(e) => setSortOption(e.target.value)}
        >
          <option value="">Sort By</option>
          <option value="priceLowHigh">Price: Low to High</option>
          <option value="priceHighLow">Price: High to Low</option>
          <option value="ratingHighLow">Rating: High to Low</option>
          <option value="ratingLowHigh">Rating: Low to High</option>
        </select>

        <select value={category} onChange={(e) => setCategory(e.target.value)}>
          <option value="All">All Categories</option>
          {categories.map((cat, index) => (
            <option key={index} value={cat}>
              {cat}
            </option>
          ))}
        </select>
      </div>

      <div className="line"></div>

      {/* Display Sorted and Filtered Menu Items */}
      <div className="DishItems">
        {sortedMenu.length > 0 ? (
          sortedMenu.map((data, index) => (
            <div
              className="DishItmesPlacement"
              key={index}
              onClick={() => openItemModal(data)} // Click to open modal
            >
              <div className="LSidePlacement">
                <div className="ItemType">
                  <img src="/images/veg-icon.jpeg" alt="veg" />
                </div>
                <div className="itemTitle">
                  <h3>{data.title}</h3>
                </div>
                <div className="itemPrice">
                  <h4>₹{data.price}</h4>
                </div>
                <div className="itemRatings">
                  <img src="/images/Stars.png" alt="rating" />
                  <p>{data.rating}</p>
                </div>
                <div className="itemDescription">
                  <h5>{data.description}</h5>
                </div>
              </div>
              <div className="RSidePlacement">
                <div className="ItemsImgs">
                  <img src={data.image} alt="DishImg" />
                </div>
                <div className="AddToCart" onClick={(e) => e.stopPropagation()}>
                  {getItemQuantity(data.title) > 0 ? (
                    <div className="quantity-controls">
                      <button onClick={() => removeFromCart(data)}>-</button>
                      <span>{getItemQuantity(data.title)}</span>
                      <button onClick={() => addToCart(data)}>+</button>
                    </div>
                  ) : (
                    <button className="add-btn" onClick={() => addToCart(data)}>
                      ADD
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))
        ) : (
          <p>No menu items available.</p>
        )}
      </div>

      {/* Enhanced Cart Popup */}
      {showCartPopup && cart.length > 0 && (
        <div className="cartPopup" onClick={goToCart}>
          <div className="cartPopup-content">
            <span className="cartPopup-icon">🛒</span>
            <span className="cartPopup-text">
              {totalItems} {totalItems === 1 ? "item" : "items"} in cart
            </span>
            <span className="cartPopup-price">₹{totalPrice.toFixed(2)}</span>
            <span className="cartPopup-action">View Cart ➡️</span>
          </div>
        </div>
      )}

      {/* Zoomed-In Item Modal */}
      {selectedItem && (
        <div className="item-modal-overlay" onClick={closeItemModal}>
          <div
            className="item-modal"
            onClick={(e) => e.stopPropagation()} // Prevent closing when clicking inside
          >
            <button className="modal-close-btn" onClick={closeItemModal}>
              ×
            </button>
            <div className="modal-content">
              <img src={selectedItem.image} alt={selectedItem.title} className="modal-image" />
              <div className="modal-details">
                <div className="modal-header">
                  <img src="/images/veg-icon.jpeg" alt="veg" className="modal-item-type" />
                  <h2>{selectedItem.title}</h2>
                </div>
                <p className="modal-price">₹{selectedItem.price}</p>
                <div className="modal-rating">
                  <img src="/images/Stars.png" alt="rating" />
                  <span>{selectedItem.rating}</span>
                </div>
                <p className="modal-description">{selectedItem.description}</p>
                <div className="modal-add-to-cart">
                  {getItemQuantity(selectedItem.title) > 0 ? (
                    <div className="quantity-controls">
                      <button onClick={() => removeFromCart(selectedItem)}>-</button>
                      <span>{getItemQuantity(selectedItem.title)}</span>
                      <button onClick={() => addToCart(selectedItem)}>+</button>
                    </div>
                  ) : (
                    <button
                      className="add-btn"
                      onClick={() => addToCart(selectedItem)}
                    >
                      ADD
                    </button>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Menu;