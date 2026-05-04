package bitc.next502.warehousechatserver.service;

import bitc.next502.warehousechatserver.domain.entity.ChatRoomEntity;
import bitc.next502.warehousechatserver.domain.repository.ChatRoomRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

// 채팅방 관련 비즈니스 로직을 처리하는 서비스
@Service
@RequiredArgsConstructor
public class ChatRoomService {

  private final ChatRoomRepository chatRoomRepository;

//  Firebase 인증을 위한 커스텀 토큰을 생성
//  매개변수 : userId 토큰을 발급받을 사용자의 ID
//  반환값 : 생성된 Firebase 커스텀 토큰 문자열
  public String createFirebaseCustomToken(String userId) {
    try {
      // Firebase Admin SDK를 사용하여 사용자의 UID를 기반으로 Custom Token 생성
      return FirebaseAuth.getInstance().createCustomToken(userId);
    }
    catch (FirebaseAuthException e) {
      throw new RuntimeException("파이어베이스 토큰 발급에 실패했습니다.");
    }
  }

//  창고(warehouse)와 사용자(user) 기준으로 기존 채팅방을 조회하거나, 없으면 새로 생성
//  첫번째 매개변수 : warehouseId 채팅방과 연결된 창고 ID
//  두번째 매개변수 : providerId 창고 제공자의 ID
//  세번째 매개변수 userId 채팅을 시도하는 사용자 ID
//  반환값 : 조회되거나 생성된 채팅방의 ID (PK)
  @Transactional
  public Long getOrCreateChatRoom(Long warehouseId, String providerId, String userId) {
    // 기존에 생성된 채팅방이 있는지 조회
    return chatRoomRepository.findByWarehouseIdAndUserId(warehouseId, userId)
        .map(ChatRoomEntity::getId)
        // 채팅방이 없으면 새로운 채팅방 엔티티를 생성하고 DB에 저장
        .orElseGet(() -> {
          ChatRoomEntity newRoom = ChatRoomEntity.builder()
              .warehouseId(warehouseId)
              .providerId(providerId)
              .userId(userId)
              .build();
          return chatRoomRepository.save(newRoom).getId();
        });
  }
}
