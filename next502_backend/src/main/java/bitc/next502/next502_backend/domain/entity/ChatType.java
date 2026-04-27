package bitc.next502.next502_backend.domain.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ChatType {
    TEXT("텍스트"),
    IMAGE("이미지"),
    VOICE("보이스톡"),
    SYSTEM("시스템 메시지");

    private final String description;
}