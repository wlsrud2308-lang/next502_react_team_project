function Footer() {
  return (
    <footer className="bg-black border-top mt-5">
      <div className="container py-5">
        <div className="row align-items-center">
          <div className="col-12 col-lg-3 text-center text-lg-start mb-3 mb-lg-0">
            <img
              src="/logo_w.png"
              alt="창고이음 로고"
              style={{ width: '220px', maxWidth: '100%' }}
            />
          </div>

          <div className="col-12 col-lg-9 text-center text-lg-end">
            <div style={{ fontSize: '0.8rem' }} className="mb-2">
              <a href="#" className="me-3 text-white fw-semibold text-decoration-none">
                이용약관
              </a>
              <a href="#" className="me-3 text-white fw-semibold text-decoration-none">
                이메일무단수집거부
              </a>
              <a href="#" className="text-white fw-semibold text-decoration-none">
                개인정보처리방침
              </a>
            </div>

            <div style={{ fontSize: '0.9rem' }} className="text-white fw-semibold">
              창고이음 사용 문의 : 051-888-7615 │ 플랫폼 기술 이용 문의 : 050-7878-8299
            </div>

            <div style={{ fontSize: '0.75rem' }} className="text-secondary fw-semibold mt-2">
              Copyright ⓒ 2022 Busan Metropolitan City. all rights reserved.
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
