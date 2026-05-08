package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "t_board")
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class BoardEntity extends BaseTimeEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long boardId;

    @Column(nullable = false)
    private String title;   // 제목

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content; // 내용

    private String category; // 공지사항, 리뷰, Q&A 등

    @Column(columnDefinition = "TEXT")
    private String reply;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id") // 작성자
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({"password", "authorities", "enabled", "accountNonExpired", "accountNonLocked", "credentialsNonExpired", "hibernateLazyInitializer", "handler"})
    private MemberEntity writer;
}
