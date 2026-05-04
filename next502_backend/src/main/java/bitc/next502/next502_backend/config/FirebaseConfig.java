package bitc.next502.next502_backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource; // 👈 추가

import java.io.InputStream;

// Firebase Admin SDK 초기화 설정
@Configuration
public class FirebaseConfig {

  // FirebaseApp을 초기화하는 메서드, 서비스 계정 키 파일을 읽어 인증 정보를 설정
  @PostConstruct
  public void init() {
    try {
      // 1. 👈 스프링 전용 ClassPathResource를 사용하면 리소스 파일을 가장 안전하게 읽어옵니다.
      ClassPathResource resource = new ClassPathResource("warehouse-chat-firebase-service-key.json");

      if (!resource.exists()) {
        throw new RuntimeException("파이어베이스 서비스 키 파일을 찾을 수 없습니다. (src/main/resources 위치 확인)");
      }

      InputStream serviceAccount = resource.getInputStream();

      // 2. 읽어온 키 파일을 바탕으로 인증 정보를 설정
      FirebaseOptions options = FirebaseOptions.builder()
              .setCredentials(GoogleCredentials.fromStream(serviceAccount))
              .build();

      // 3. FirebaseApp 인스턴스가 없을 때만(중복 초기화 방지) 초기화 진행
      if (FirebaseApp.getApps().isEmpty()) {
        FirebaseApp.initializeApp(options);
        System.out.println("🔥 파이어베이스 Admin SDK 초기화 성공!");
      }
    } catch (Exception e) {
      System.err.println("❌ 파이어베이스 초기화 중 치명적 에러 발생:");
      e.printStackTrace();
    }
  }
}
