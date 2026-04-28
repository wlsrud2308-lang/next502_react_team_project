import React, { useEffect, useRef } from 'react';

const NaverMapContainer = ({ warehouses }) => {
  const mapElement = useRef(null);
  const mapRef = useRef(null);
  const markersRef = useRef([]); // 마커들을 관리할 Ref

  // 1. 지도 초기화 (최초 1회)
  useEffect(() => {
    if (!mapRef.current && mapElement.current) {
      const mapOptions = {
        center: new window.naver.maps.LatLng(35.1795543, 129.0756416), // 부산 시청 기준
        zoom: 12,
      };
      mapRef.current = new window.naver.maps.Map(mapElement.current, mapOptions);
      console.log('📍 지도 초기화 완료');
    }
  }, []);

  // 2. 창고 데이터가 변경될 때마다 실행
  useEffect(() => {
    // 지도가 없거나 데이터가 없으면 실행 안 함
    if (!mapRef.current) return;

    console.log('📦 지도 업데이트 시작. 데이터 개수:', warehouses?.length);

    // [기존 마커 제거]
    markersRef.current.forEach((marker) => marker.setMap(null));
    markersRef.current = [];

    if (!warehouses || warehouses.length === 0) {
      console.log('⚠️ 표시할 창고 데이터가 없습니다.');
      return;
    }

    // [새로운 마커 생성]
    warehouses.forEach((item) => {
      // 주소가 없는 데이터 예외 처리
      if (!item.address) {
        console.warn(`⏩ '${item.name}' 창고의 주소가 비어있습니다.`);
        return;
      }

      window.naver.maps.Service.geocode({ query: item.address }, (status, response) => {
        if (status !== window.naver.maps.Service.Status.OK) {
          console.error('❌ 주소 변환 실패:', item.address);
          return;
        }

        const result = response.v2.addresses[0];
        const coord = new window.naver.maps.LatLng(result.y, result.x);

        // 마커 생성
        const marker = new window.naver.maps.Marker({
          position: coord,
          map: mapRef.current,
          title: item.name,
          animation: window.naver.maps.Animation.DROP, // 마커가 툭 떨어지는 효과
        });

        // 정보창 생성
        const infoWindow = new window.naver.maps.InfoWindow({
          content: `
            <div style="padding:10px; line-height:150%;">
              <h5 style="margin:0; font-size:16px;">${item.name}</h5>
              <p style="margin:5px 0 0; font-size:13px; color:#666;">${item.address}</p>
            </div>`,
          borderWidth: 1,
          anchorSize: new window.naver.maps.Size(10, 10),
        });

        // 마커 클릭 이벤트
        window.naver.maps.Event.addListener(marker, 'click', () => {
          if (infoWindow.getMap()) {
            infoWindow.close();
          } else {
            infoWindow.open(mapRef.current, marker);
          }
        });

        markersRef.current.push(marker); // 관리 배열에 추가
      });
    });

    // (선택사항) 검색 결과가 있다면 첫 번째 위치로 지도 중심 이동
    /*
    if (warehouses.length > 0 && warehouses[0].address) {
       // 비동기 geocode 특성상 좌표를 따로 계산해서 mapRef.current.setCenter(coord) 호출 가능
    }
    */
  }, [warehouses]); // ⭐️ warehouses가 바뀔 때마다 다시 그립니다.

  return <div ref={mapElement} style={{ width: '100%', height: '100%', minHeight: '400px' }} />;
};

export default NaverMapContainer;
