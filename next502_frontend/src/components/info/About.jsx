import React from 'react';
import { Container, Breadcrumb } from 'react-bootstrap';
import Header from '../layout/Header';
import Footer from '../layout/Footer';

function About() {
  const imgPath = 'http://localhost:8080/uploads/info/';

  return (
    <div className="wrapper">
      <Header />

      {/* 1. 상단 배너 */}
      <section
        className="d-flex align-items-center justify-content-center text-white"
        style={{
          background: 'linear-gradient(135deg, #a13d8d 0%, #3e56a7 100%)',
          height: '220px',
          marginTop: '80px',
        }}
      >
        <div className="text-center">
          <h2 className="fw-bold display-6">창고이음 소개</h2>
        </div>
      </section>

      {/* 2. 브레드크럼 */}
      <div className="bg-dark py-2">
        <Container>
          <Breadcrumb className="m-0 custom-breadcrumb">
            <Breadcrumb.Item href="/" className="text-white">
              HOME
            </Breadcrumb.Item>
            <Breadcrumb.Item active className="text-white-50">
              창고이음 소개
            </Breadcrumb.Item>
            <Breadcrumb.Item active className="text-white">
              창고이음이란?
            </Breadcrumb.Item>
          </Breadcrumb>
        </Container>
      </div>

      <Container className="py-5">
        {/* 3. 섹션 타이틀 */}
        <div className="mb-4 border-start border-primary border-4 ps-3">
          <h3 className="fw-bold m-0 text-dark">창고이음이란?</h3>
        </div>

        {/* 4. 텍스트 설명 */}
        <div className="p-4 bg-light rounded-3 border mb-5">
          <p className="lh-lg mb-0 fs-5 text-dark">
            창고를 필요로 하는 사람들에게 부산의 창고 정보를 소개하고, 창고를 가지고 있는
            사람들에게는 창고가 필요한 사람을 연결해주는
            <strong className="text-danger"> 온라인 창고안내 서비스</strong>입니다.
          </p>
        </div>

        {/* 5. 이미지 중앙 정렬 영역 (구조도 제외) */}
        <div className="d-flex flex-column gap-5 align-items-center">
          {/* 이미지 1, 2, 3만 순서대로 출력 */}
          {['1.png', '2.png', '3.png'].map((imgName, idx) => (
            <div key={idx} className="w-100 d-flex justify-content-center">
              <div
                className="shadow-sm rounded-4 overflow-hidden border bg-white"
                style={{ maxWidth: '800px' }}
              >
                <img
                  src={`${imgPath}${imgName}`}
                  alt={`소개 ${idx + 1}`}
                  className="img-fluid w-100"
                  onError={(e) => (e.target.style.display = 'none')} // 이미지 로드 실패 시 숨김 처리
                />
              </div>
            </div>
          ))}
        </div>
      </Container>

      <Footer />

      <style>{`
        .custom-breadcrumb .breadcrumb-item + .breadcrumb-item::before { color: rgba(255,255,255,0.5) !important; }
        .img-fluid { display: block; height: auto; }
      `}</style>
    </div>
  );
}

export default About;
