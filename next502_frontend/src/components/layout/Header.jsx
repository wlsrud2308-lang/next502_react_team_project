import { useEffect, useState } from 'react';

function Header() {
  const [activeMenu, setActiveMenu] = useState(null);
  const [isScrolled, setIsScrolled] = useState(false);

  const menuData = [
    {
      title: '창고이음 소개',
      items: [
        { name: '창고이음이란?', link: '#' },
        { name: '창고이음 이용안내', link: '#' },
      ],
    },
    {
      title: '창고 등록·이용',
      items: [{ name: '창고 이용', link: '#' }],
    },
    {
      title: '창고 검색',
      items: [{ name: '창고 검색', link: '#' }],
    },
    {
      title: '커뮤니티',
      items: [
        { name: '공지사항', link: '#' },
        { name: '자주 하는 질문', link: '#' },
        { name: '묻고 답하기', link: '#' },
        { name: '물류뉴스', link: '#' },
      ],
    },
  ];

  // ================= SCROLL EVENT =================
  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 80);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav className={`main-header ${isScrolled ? 'scrolled' : 'top'}`}>
      <div className="container h-100 d-flex align-items-center justify-content-between">

        {/* ================= LOGO ================= */}
        <div className="logo">
          <img src="/logo_w.png" alt="창고이음 로고" style={{ width: '220px', maxWidth: '100%' }} />
        </div>

        {/* ================= MAIN MENU ================= */}
        <ul className="nav">
          {menuData.map((menu, idx) => (
            <li
              key={idx}
              className="nav-item position-relative px-3"
              onMouseEnter={() => setActiveMenu(idx)}
              onMouseLeave={() => setActiveMenu(null)}
            >
              {/* 1차 메뉴 */}
              <span className="nav-link fw-semibold menu-item">{menu.title}</span>

              {/* 2차 메뉴 */}
              {activeMenu === idx && (
                <div className="dropdown-menu-custom shadow-sm">
                  {menu.items.map((item, i) => (
                    <a key={i} href={item.link} className="dropdown-item-custom">
                      {item.name}
                    </a>
                  ))}
                </div>
              )}
            </li>
          ))}
        </ul>

        {/* ================= MOBILE BUTTON ================= */}
        <button className="btn btn-outline-dark btn-sm">☰</button>
      </div>
    </nav>
  );
}

export default Header;
