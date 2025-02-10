// src/Home.js
import React from 'react';
import './Home.css';  // Import the CSS file

const Home = () => {
  return (
    <div className="home">  {/* Apply the CSS class */}
      <section className="FirstH">
        <div className="nav">
          <div className="logo">
            <span>
              <img src="/images/dosaimg.png" alt="Logo" loading="lazy" />
              <h3>BitesOfSouth</h3>
            </span>
          </div>
          <div className="options">
            <ul className="NavOption">
              <li className="Bscreen">
                <a href="">Home</a>
              </li>
              <li className="Bscreen">
                <a href="">Order</a>
              </li>
              <li className="Bscreen">
                <a href="">About Us</a>
              </li>
              <li className="signin">
                <a href="">Sign in</a>
              </li>
            </ul>
          </div>
        </div>

        <div className="SecondH">
          <div className="LSideImg">
            <img src="/images/!TEmpSIdePic.avif" alt="" />
          </div>
          <div className="SloganSearch">
            <div className="MidPart">
              <div className="search-container">
                <input
                  type="text"
                  className="serachH"
                  placeholder="Search for Dosa, items or more"
                />
                <button className="searchHbtn">
                  <i className="fa-solid fa-magnifying-glass" id="search"></i>
                </button>
              </div>
              <h1 className="slogan">Bites of South: Where Food Meets Culture.</h1>

              <div className="FoodOption">
                <div className="Option1">
                  <a href='/menu'> 
                  <h1>Order</h1>
                  <h2>Order Food Online</h2>
                  <img src="/images/Dosa.avif" alt="" />
                  </a>
                </div>
                <div className="Option1">
                  <h1>Order</h1>
                  <h2>Order Food Online</h2>
                  <img src="/images/Dosa.avif" alt="" />
                </div>
                <div className="Option1">
                  <h1>Order</h1>
                  <h2>Order Food Online</h2>
                  <img src="/images/Dosa.avif" alt="" />
                </div>
                <div className="Option1" id="mobshow">
                  <h1>Order</h1>
                  <h2>Order Food Online</h2>
                  <img src="/images/Dosa.avif" alt="" />
                </div>
              </div>
            </div>
          </div>
          <div className="RSideImg">
            <img src="/images/TempPIcsSIde.avif" alt="" />
          </div>
        </div>
      </section>

      <section className="FirstOrder">
        <div className="carousel-container">
          <h3 className="carousel-title">Inspiration for your first order</h3>
          <div className="carousel">
            <div className="slide">
              <a className="food-link" href="">
                <div className="image-container">
                  <img
                    className="food-image"
                    src="https://b.zmtcdn.com/data/o2_assets/d0bd7c9405ac87f6aa65e31fe55800941632716575.png"
                    alt="Pizza"
                  />
                </div>
                <p className="food-title">Pizza</p>
              </a>
            </div>
            <div className="slide">
              <a className="food-link" href="">
                <div className="image-container">
                  <img
                    className="food-image"
                    src="https://b.zmtcdn.com/data/o2_assets/bf2d0e73add1c206aeeb9fec762438111727708719.png"
                    alt="Biryani"
                  />
                </div>
                <p className="food-title">Biryani</p>
              </a>
            </div>
            <div className="slide">
              <a className="food-link" href="">
                <div className="image-container">
                  <img
                    className="food-image"
                    src="https://b.zmtcdn.com/data/dish_images/197987b7ebcd1ee08f8c25ea4e77e20f1634731334.png"
                    alt="Chicken"
                  />
                </div>
                <p className="food-title">Chicken</p>
              </a>
            </div>
            <div className="slide">
              <a className="food-link" href="">
                <div className="image-container">
                  <img
                    className="food-image"
                    src="https://b.zmtcdn.com/data/dish_images/ccb7dc2ba2b054419f805da7f05704471634886169.png"
                    alt="Burger"
                  />
                </div>
                <p className="food-title">Burger</p>
              </a>
            </div>
            <div className="slide">
              <a className="food-link" href="">
                <div className="image-container">
                  <img
                    className="food-image"
                    src="https://b.zmtcdn.com/data/o2_assets/e444ade83eb22360b6ca79e6e777955f1632716661.png"
                    alt="Fried Rice"
                  />
                </div>
                <p className="food-title">Fried Rice</p>
              </a>
            </div>
            <div className="slide">
              <a className="food-link" href="">
                <div className="image-container">
                  <img
                    className="food-image"
                    src="https://b.zmtcdn.com/data/dish_images/d9766dd91cd75416f4f65cf286ca84331634805483.png"
                    alt="Idli"
                  />
                </div>
                <p className="food-title">Idli</p>
              </a>
            </div>
          </div>
        </div>
      </section>
      
<section className="maps">
    <div className="TitleMaps">
        <h2>We are located over here!</h2>
    </div>
    <div className="googlemapsD"> 
        <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3768.764234514681!2d72.847182!3d19.1617948!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3be7b64deb48f999%3A0xaeddd49518fd2974!2sBalaji%20Dosa%20Corner!5e0!3m2!1sen!2sin!4v1738253951373!5m2!1sen!2sin" allowFullScreen loading="lazy"></iframe> 
    </div>    
</section>

      <section className="Footer">
      <div className="footer-container">
        <div className="footer-main">
            <div className="footer-logo">
                <div className="logo-image">
                    <img src="/images/dosaimg.png" alt="Logo" loading="lazy"/>
                </div>
            </div>
            <div className="footer-text">© 2025 Bites Of South Limited</div>
        </div>

        <div className="footer-links">
            <ul className="company-links">
                <li className="link-item"><div className="section-title">Company</div></li>
                <li className="link-item"><a href="" target="_blank">About Us</a></li>
                <li className="link-item"><a href="" target="_blank">Help & Support</a></li>
                <li className="link-item"><a href="" target="_blank" rel="nofollow noopener">Partner with Us</a></li>
                <li className="link-item"><a href="" target="_blank" rel="nofollow noopener">Contact US</a></li>
            </ul>

            <ul className="legal-links">
                <li className="link-item"><div className="section-title">Legal</div></li>
                <li className="link-item"><a href="" target="_blank">Terms & Conditions</a></li>
                <li className="link-item"><a href="" target="_blank">Cookie Policy</a></li>
                <li className="link-item"><a href="" target="_blank">Privacy Policy</a></li>
            </ul>

            <ul className="location-links">
                <li className="link-item"><div className="section-title">Available at:</div></li>
                <li className="link-item"><a href="">Mumbai</a></li>
            </ul>


                
                <ul className="payment-methods-list">                       
                        <li className="link-item"><div className="section-title">Payment Methods</div></li>
                        <li className="link-item"> <img className="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/upi-icon.svg" width="50" height="30" alt="UPI" loading="lazy"/> <img className="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/gpay-svg.svg" width="50" height="30" alt="Google Pay" loading="lazy"/></li>
                        <li className="link-item"> <img className="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/paytm-svg.svg" width="50" height="30" alt="Paytm" loading="lazy"/> <img className="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/visa-svg.svg" width="50" height="30" alt="Visa" loading="lazy"/></li>       
                </ul>

            
            <div className="social-links">
                <a href="" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/Linkedin.svg" alt="LinkedIn" loading="lazy"/>
                </a>
                <a href="" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/icon-instagram.svg" alt="Instagram" loading="lazy"/>
                </a>
                <a href="" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/icon-facebook.svg" alt="Facebook" loading="lazy"/>
                </a>
                <a href="" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/icon-pinterest.svg" alt="Pinterest" loading="lazy"/>
                </a>
                <a href="" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/Twitter.svg" alt="Twitter" loading="lazy"/>
                </a>
            </div>
        </div>
    </div>
      </section>
    </div>
  );
};

export default Home;
