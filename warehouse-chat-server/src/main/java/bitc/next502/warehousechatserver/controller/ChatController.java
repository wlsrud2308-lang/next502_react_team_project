package bitc.next502.warehousechatserver.controller;

import bitc.next502.warehousechatserver.domain.dto.ChatRequestDTO;
import bitc.next502.warehousechatserver.domain.dto.RoomResponseDTO;
import bitc.next502.warehousechatserver.domain.dto.TokenResponseDTO;
import bitc.next502.warehousechatserver.service.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// 채팅 관련 클라이언트 요청을 처리하는 컨트롤러
// Firebase Custom Token 발급 및 채팅방 조회/생성 API를 제공
@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

  private final ChatRoomService chatRoomService;

//  클라이언트(앱) 시작 시 또는 로그인 직후 호출하여 Firebase 인증용 커스텀 토큰을 요청
//  매개변수 : userId 토큰을 발급받을 사용자의 식별자
//  반환값 : 생성된 Firebase 커스텀 토큰이 담긴 DTO
  @GetMapping("/token")
  public ResponseEntity<TokenResponseDTO> getChatToken(@RequestParam String userId) {
    // TODO: 보안 강화를 위해 향후에는 RequestParam 대신 Header에 포함된 JWT나 인증 객체를 통해 사용자를 식별하도록 변경을 권장합니다.
    String customToken = chatRoomService.createFirebaseCustomToken(userId);
    return ResponseEntity.ok(new TokenResponseDTO(customToken));
  }

//  창고 상세 화면에서 '채팅하기'를 눌렀을 때 호출되어 채팅방 번호를 반환, 기존 방이 없으면 새로 생성
//  매개변수 : request 창고 ID, 제공자 ID, 사용자 ID를 포함한 ChatRequestDTO
//  반환값 : 생성되거나 조회된 채팅방 번호가 담긴 RoomResponseDTO
  @PostMapping("/room")
  public ResponseEntity<RoomResponseDTO> startChat(@RequestBody ChatRequestDTO request) {
    Long roomId = chatRoomService.getOrCreateChatRoom(
        request.getWarehouseId(),
        request.getProviderId(),
        request.getUserId()
    );

    // Firebase 에서 노드/문서 ID로 사용하기 쉽도록 "room_" 접두사를 붙여서 반환
    return ResponseEntity.ok(new RoomResponseDTO("room_" + roomId));
  }
}
