package bitc.next502.next502_backend.domain.dto;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ChatRoomDTO {
    private Long chatRoomId;
    private String warehouseName;
}
