package bitc.next502.next502_backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // /uploads/ 로 시작하는 모든 URL 요청을 허용합니다.
        registry.addResourceHandler("/uploads/**")
                // 실제 파일이 저장된 서버 컴퓨터의 물리적 경로를 지정합니다.
                .addResourceLocations("file:" + System.getProperty("user.dir") + "/uploads/");
    }
}
