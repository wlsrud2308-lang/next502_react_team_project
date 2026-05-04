import React, { useEffect, useRef } from 'react';

const NaverMapContainer = ({ warehouses, onMarkerClick }) => {
  const mapElement = useRef(null);
  const mapRef = useRef(null);
  const markersRef = useRef([]);

  // 1. 지도 초기화
  useEffect(() => {

    if (typeof window === 'undefined' || !window.naver || !window.naver.maps) {
      console.warn('⏳ 네이버 지도 API 로딩 중...');
      return;
    }

    if (!mapRef.current && mapElement.current) {
      const mapOptions = {
        center: new window.naver.maps.LatLng(35.1795543, 129.0756416), // 부산 시청 기준
        zoom: 12,
      };
      mapRef.current = new window.naver.maps.Map(mapElement.current, mapOptions);
      console.log('📍 지도 초기화 완료');
    }
  }, []);

  // 2. 창고 데이터 마커 업데이트
  useEffect(() => {

    if (!mapRef.current || !window.naver || !window.naver.maps) return;


    markersRef.current.forEach((marker) => marker.setMap(null));
    markersRef.current = [];

    if (!warehouses || warehouses.length === 0) return;


    warehouses.forEach((item) => {
      if (!item.address) return;

      window.naver.maps.Service.geocode({ query: item.address }, (status, response) => {
        if (status !== window.naver.maps.Service.Status.OK) return;

        const result = response.v2.addresses[0];
        const coord = new window.naver.maps.LatLng(result.y, result.x);

        const marker = new window.naver.maps.Marker({
          position: coord,
          map: mapRef.current,
          title: item.name,
          animation: window.naver.maps.Animation.DROP,
        });

        const infoWindow = new window.naver.maps.InfoWindow({
          content: `
            <div style="padding:10px; line-height:150%;">
              <h5 style="margin:0; font-size:16px; cursor:pointer; color:#0d6efd" id="info-${item.warehouseId}">
                ${item.name}
              </h5>
              <p style="margin:5px 0 0; font-size:13px; color:#666;">${item.address}</p>
            </div>`,
          borderWidth: 1,
          anchorSize: new window.naver.maps.Size(10, 10),
        });

        window.naver.maps.Event.addListener(marker, 'click', () => {
          if (infoWindow.getMap()) {
            infoWindow.close();
          } else {
            infoWindow.open(mapRef.current, marker);

            // 정보창 클릭 시 상세 페이지 이동 이벤트 연결
            setTimeout(() => {
              const titleEl = document.getElementById(`info-${item.warehouseId}`);
              if (titleEl && onMarkerClick) {
                titleEl.onclick = () => onMarkerClick(item.warehouseId);
              }
            }, 100);
          }
        });

        markersRef.current.push(marker);
      });
    });
  }, [warehouses, onMarkerClick]);

  return (
    <div
      ref={mapElement}
      style={{ width: '100%', height: '100%', minHeight: '400px', backgroundColor: '#f8f9fa' }}
    />
  );
};

export default NaverMapContainer;
