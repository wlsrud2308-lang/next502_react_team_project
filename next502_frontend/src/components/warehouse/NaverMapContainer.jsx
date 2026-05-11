import React, { useEffect, useRef } from 'react';

const NaverMapContainer = ({ warehouses, onMarkerClick }) => {
  const mapElement = useRef(null);
  const mapRef = useRef(null);
  const markersRef = useRef([]);
  const currentDataRef = useRef([]);

  useEffect(() => {
    if (!window.naver || !window.naver.maps) return;
    if (!mapRef.current && mapElement.current) {
      mapRef.current = new window.naver.maps.Map(mapElement.current, {
        center: new window.naver.maps.LatLng(35.1795543, 129.0756416),
        zoom: 12,
        logoControl: false,
        mapDataControl: false,
      });
    }
  }, []);

  useEffect(() => {
    if (!mapRef.current || !window.naver || !window.naver.maps) return;

    // 1. 기존 마커 제거
    markersRef.current.forEach((marker) => marker.setMap(null));
    markersRef.current = [];
    currentDataRef.current = warehouses;

    if (!warehouses || warehouses.length === 0) return;

    const bounds = new window.naver.maps.LatLngBounds();
    let processedCount = 0;

    warehouses.forEach((item) => {
      window.naver.maps.Service.geocode({ query: item.address }, (status, response) => {
        if (currentDataRef.current !== warehouses) return;
        processedCount++;

        if (status === window.naver.maps.Service.Status.OK && response.v2.addresses[0]) {
          const result = response.v2.addresses[0];
          const coord = new window.naver.maps.LatLng(result.y, result.x);

          // 2. 마커 생성
          const marker = new window.naver.maps.Marker({
            position: coord,
            map: mapRef.current,
            title: item.name,
            animation: window.naver.maps.Animation.DROP,
            icon: {
              content: `
                <div style="cursor:pointer;">
                    <div style="width:28px; height:28px; background:#0d6efd; border:2px solid #fff; border-radius:50% 50% 50% 0; transform:rotate(-45deg); box-shadow:0 2px 5px rgba(0,0,0,0.3);"></div>
                </div>`,
              anchor: new window.naver.maps.Point(14, 28),
            },
          });

          // 3. 정보창 설정
          const infoWindow = new window.naver.maps.InfoWindow({
            content: `
              <div style="padding:12px; min-width:180px; border-radius:8px; font-family: sans-serif;">
                <div style="font-weight:bold; font-size:14px; margin-bottom:4px; color:#333;">${item.name}</div>
                <div style="font-size:12px; color:#666; margin-bottom:8px;">${item.address}</div>
                <button id="info-btn-${item.warehouseId}" style="width:100%; border:none; background:#0d6efd; color:white; padding:6px; border-radius:4px; font-size:12px; cursor:pointer;">
                    상세보기
                </button>
              </div>`,
            backgroundColor: '#fff',
            borderWidth: 0,
            pixelOffset: new window.naver.maps.Size(0, -10),
          });

          // [이벤트 1] 마우스 올리면 정보창 열기
          window.naver.maps.Event.addListener(marker, 'mouseover', () => {
            infoWindow.open(mapRef.current, marker);

            // 정보창 렌더링 후 버튼 이벤트 바인딩
            setTimeout(() => {
              const btn = document.getElementById(`info-btn-${item.warehouseId}`);
              if (btn && onMarkerClick) {
                btn.onclick = (e) => {
                  e.stopPropagation();
                  onMarkerClick(item.warehouseId);
                };
              }
            }, 50);
          });

          // [이벤트 2] 마우스가 마커 밖으로 나가면 정보창 닫기
          window.naver.maps.Event.addListener(marker, 'mouseout', () => {
            infoWindow.close();
          });

          // [이벤트 3] 마커 클릭 시 동작
          window.naver.maps.Event.addListener(marker, 'click', () => {
            if (onMarkerClick) onMarkerClick(item.warehouseId);
          });

          bounds.extend(coord);
          markersRef.current.push(marker);
        }

        // 데이터 개수에 따른 포커스 처리
        if (processedCount === warehouses.length && !bounds.isEmpty()) {
          if (warehouses.length === 1) {
            mapRef.current.setCenter(bounds.getCenter());
            mapRef.current.setZoom(17);
          } else {
            mapRef.current.panToBounds(bounds);
          }
        }
      });
    });
  }, [warehouses, onMarkerClick]);

  return <div ref={mapElement} style={{ width: '100%', height: '100%' }} className="rounded-4" />;
};

export default NaverMapContainer;