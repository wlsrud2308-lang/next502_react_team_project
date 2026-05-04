package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.ChatRoomRepository;
import bitc.next502.next502_backend.domain.repository.WarehouseRepository;
import com.google.firebase.auth.FirebaseAuth; // 👈 추가
import com.google.firebase.auth.FirebaseAuthException; // 👈 추가
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final WarehouseRepository warehouseRepository;

    /**
     * 1. ⚠️ [추가] Firebase 인증을 위한 커스텀 토큰을 생성합니다.
     * 플러터 앱이 Firestore에 접근하기 위해 이 토큰을 받아 로그인을 수행합니다.
     */
    public String createFirebaseCustomToken(String userId) {
        try {
            // Firebase Admin SDK를 사용하여 사용자의 UID를 기반으로 Custom Token 생성
            return FirebaseAuth.getInstance().createCustomToken(userId);
        } catch (FirebaseAuthException e) {
            throw new RuntimeException("파이어베이스 토큰 발급에 실패했습니다.", e);
        }
    }

    /**
     * 2. 채팅방 생성 또는 기존 방 조회 (MySQL)
     */
    @Transactional
    public ChatRoomEntity createOrGetRoom(Long warehouseId, MemberEntity currentUser) {
        WarehouseEntity warehouse = warehouseRepository.findById(warehouseId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 창고입니다."));

        if (warehouse.getMember() == null) {
            throw new IllegalStateException("창고 주인 정보가 없습니다. DB를 확인하세요.");
        }

        if (warehouse.getMember().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("본인의 창고에는 상담을 신청할 수 없습니다.");
        }

        return chatRoomRepository.findExistRoom(warehouseId, currentUser.getId())
                .orElseGet(() -> {
                    ChatRoomEntity newRoom = ChatRoomEntity.builder()
                            .member(currentUser)
                            .provider(warehouse.getMember())
                            .warehouse(warehouse)
                            .status("OPEN")
                            .build();
                    return chatRoomRepository.save(newRoom);
                });
    }

    /**
     * 3. 로그인한 유저의 채팅방 목록 조회 (MySQL)
     */
    public List<ChatRoomEntity> getMyChatRooms(MemberEntity member) {
        return chatRoomRepository.findAllMyRooms(member);
    }

    /**
     * 4. 이미지 업로드 (로컬 저장 및 URL 리턴)
     */
    @Transactional
    public String uploadImage(MultipartFile file) {
        String uploadDir = System.getProperty("user.dir") + File.separator + "uploads" + File.separator;
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        File dest = new File(uploadDir + fileName);

        try {
            file.transferTo(dest);
        } catch (IOException e) {
            throw new RuntimeException("파일 저장 중 오류가 발생했습니다.");
        }

<<<<<<< HEAD
        // 3. 에뮬레이터에서 접근 가능한 URL 반환
=======
        // 안드로이드 에뮬레이터 접근용 URL 반환
>>>>>>> csy/firebase_chat_server
        return "http://10.0.2.2:8080/uploads/" + fileName;
    }
}
