package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.ChatMessageEntity;
import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.ChatMessageRepository;
import bitc.next502.next502_backend.domain.repository.ChatRoomRepository;
import bitc.next502.next502_backend.domain.repository.WarehouseRepository;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
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
    private final ChatMessageRepository chatMessageRepository;

    /**
     * 1. Firebase 인증을 위한 커스텀 토큰 생성
     */
    public String createFirebaseCustomToken(String userId) {
        try {
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
            throw new IllegalStateException("창고 주인 정보가 없습니다.");
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

        // 에뮬레이터 접근용 주소 (실제 배포 시 서버 IP로 변경 필요)
        return "/uploads/" + fileName;
    }

    /**
     * 5. 특정 채팅방의 메시지 내역 조회 (Slice)
     */
    public Slice<ChatMessageEntity> getChatMessages(Long chatRoomId, Pageable pageable) {
        return chatMessageRepository.findByChatRoom_ChatRoomIdOrderByIdDesc(chatRoomId, pageable);
    }

    /**
     * 6. 읽음 처리 (벌크 업데이트)
     */
    @Transactional
    public void markMessagesAsRead(Long chatRoomId, MemberEntity currentUser) {
        chatMessageRepository.markAsRead(chatRoomId, currentUser.getId());
    }
}
