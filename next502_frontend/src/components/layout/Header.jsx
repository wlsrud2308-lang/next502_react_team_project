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

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <nav
      className={`fixed-top transition-all py-2 ${
        isScrolled ? 'bg-white shadow-sm py-1' : 'bg-transparent py-3'
      }`}
      style={{ transition: 'all 0.3s ease' }}
    >
      <div className="container d-flex align-items-center justify-content-between">
        {/* ================= LOGO ================= */}
        <div className="navbar-brand m-0 p-0 cursor-pointer">
          <img
            src={isScrolled ? '/logo_color.png' : '/logo_w.png'}
            alt="창고이음 로고"
            style={{ width: '180px', transition: 'all 0.3s ease' }}
          />
        </div>

        {/* ================= PC MENU (Large screens only) ================= */}
        <ul className="nav d-none d-lg-flex">
          {menuData.map((menu, idx) => (
            <li
              key={idx}
              className="nav-item position-relative mx-2"
              onMouseEnter={() => setActiveMenu(idx)}
              onMouseLeave={() => setActiveMenu(null)}
            >
              <span
                className={`nav-link fw-bold px-3 py-3 cursor-pointer ${
                  isScrolled ? 'text-dark' : 'text-white'
                }`}
              >
                {menu.title}
              </span>

              {/* 2차 메뉴 드롭다운 */}
              <div
                className={`dropdown-menu border-0 shadow-lg p-3 rounded-3 mt-0 ${
                  activeMenu === idx ? 'show d-block' : 'd-none'
                }`}
                style={{ minWidth: '200px', left: '50%', transform: 'translateX(-50%)' }}
              >
                {menu.items.map((item, i) => (
                  <a
                    key={i}
                    href={item.link}
                    className="dropdown-item rounded-2 py-2 px-3 small fw-medium text-secondary hover-bg-light"
                  >
                    {item.name}
                  </a>
                ))}
              </div>
            </li>
          ))}
        </ul>

        {/* ================= RIGHT SIDE UTILS ================= */}
        <div className="d-flex align-items-center gap-3">
          <button
            className={`btn btn-sm d-none d-md-block fw-bold ${isScrolled ? 'btn-outline-primary' : 'btn-outline-light'}`}
          >
            로그인
          </button>
          <button
            className={`btn btn-sm border-0 d-lg-none ${isScrolled ? 'text-dark' : 'text-white'}`}
          >
            <span className="fs-3">☰</span>
          </button>
        </div>
      </div>
    </nav>
  );
}

export default Header;
