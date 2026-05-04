package bitc.next502.warehousechatserver.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;

import javax.swing.*;
import java.io.InputStream;

//Firebase Admin SDK 초기화 설정
@Configuration
public class FirebaseConfig {

// FirebaseApp을 초기화하는 메서드, 서비스 계정 키 파일을 읽어 인증 정보를 설정
  @PostConstruct
  public void init() {
    try {
      // resources 폴더 안의 서비스 계정 키(JSON) 파일을 읽어옴
      InputStream serviceAccount = getClass().getResourceAsStream("/warehouse-chat-firebase-service-key.json");

      if (serviceAccount == null) {
        throw new RuntimeException("파이어베이스 서비스 키 파일을 찾을 수 없습니다.");
      }

      // 읽어온 키 파일을 바탕으로 인증 정보를 설정
      FirebaseOptions options = FirebaseOptions.builder()
          .setCredentials(GoogleCredentials.fromStream(serviceAccount))
          .build();

      // FirebaseApp 인스턴스가 없을 때만(중복 초기화 방지) 초기화 진행
      if (FirebaseApp.getApps().isEmpty()) {
        FirebaseApp.initializeApp(options);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
