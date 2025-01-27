import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      
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
                  <h1>Order</h1>
                  <h2>Order Food Online</h2>
                  <img src="/images/Dosa.avif" alt="" />
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
              <a className="food-link" href="/mumbai/delivery/dish-pizza">
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
              <a className="food-link" href="/mumbai/delivery/dish-biryani">
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
              <a className="food-link" href="/mumbai/delivery/dish-chicken">
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
              <a className="food-link" href="/mumbai/delivery/dish-burger">
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
              <a className="food-link" href="/mumbai/delivery/dish-fried-rice">
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
              <a className="food-link" href="/mumbai/delivery/dish-idli">
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
      <section className="Footer">
      <div class="footer-container">
        <div class="footer-main">
            <div class="footer-logo">
                <div class="logo-image">
                    <img src="/images/dosaimg.png" alt="Logo" loading="lazy"/>
                </div>
            </div>
            <div class="footer-text">© 2025 Bites Of South Limited</div>
        </div>

        <div class="footer-links">
            <ul class="company-links">
                <li class="link-item"><div class="section-title">Company</div></li>
                <li class="link-item"><a href="https://www.swiggy.com/about" target="_blank">About Us</a></li>
                <li class="link-item"><a href="https://www.swiggy.com/support" target="_blank">Help & Support</a></li>
                <li class="link-item"><a href="https://partner-with-us.swiggy.com/onboard#/swiggy" target="_blank" rel="nofollow noopener">Partner with Us</a></li>
                <li class="link-item"><a href="https://ride.swiggy.com" target="_blank" rel="nofollow noopener">Contact US</a></li>
            </ul>

            <ul class="legal-links">
                <li class="link-item"><div class="section-title">Legal</div></li>
                <li class="link-item"><a href="https://www.swiggy.com/terms-and-conditions" target="_blank">Terms & Conditions</a></li>
                <li class="link-item"><a href="https://www.swiggy.com/cookie-policy" target="_blank">Cookie Policy</a></li>
                <li class="link-item"><a href="https://www.swiggy.com/privacy-policy" target="_blank">Privacy Policy</a></li>
            </ul>

            <ul class="location-links">
                <li class="link-item"><div class="section-title">Available at:</div></li>
                <li class="link-item"><a href="/city/bangalore">Mumbai</a></li>
            </ul>


                
                <ul class="payment-methods-list">                       
                        <li class="link-item"><div class="section-title">Payment Methods</div></li>
                        <li class="link-item"> <img class="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/upi-icon.svg" width="50" height="30" alt="UPI" loading="lazy"/> <img class="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/gpay-svg.svg" width="50" height="30" alt="Google Pay" loading="lazy"/></li>
                        <li class="link-item"> <img class="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/paytm-svg.svg" width="50" height="30" alt="Paytm" loading="lazy"/> <img class="payment-icon" src="https://lapinozpizza.in/assets/wla_new/img/footer/visa-svg.svg" width="50" height="30" alt="Visa" loading="lazy"/></li>       
                </ul>

            
            <div class="social-links">
                <a href="https://www.linkedin.com/company/swiggy-in/" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/Linkedin.svg" alt="LinkedIn" loading="lazy"/>
                </a>
                <a href="https://www.instagram.com/swiggyindia/?hl=en" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/icon-instagram.svg" alt="Instagram" loading="lazy"/>
                </a>
                <a href="https://www.facebook.com/swiggy.in/" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/icon-facebook.svg" alt="Facebook" loading="lazy"/>
                </a>
                <a href="https://in.pinterest.com/swiggyindia/" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/icon-pinterest.svg" alt="Pinterest" loading="lazy"/>
                </a>
                <a href="https://twitter.com/Swiggy?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor" target="_blank">
                    <img src="https://media-assets.swiggy.com/portal/testing/seo-home/Twitter.svg" alt="Twitter" loading="lazy"/>
                </a>
            </div>
        </div>
    </div>
      </section>

    </div>
  );
}

export default App;
