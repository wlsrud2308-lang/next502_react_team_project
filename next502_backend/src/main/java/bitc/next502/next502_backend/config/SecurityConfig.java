package bitc.next502.next502_backend.config;

import bitc.next502.next502_backend.config.jwt.JwtTokenAuthenticationFilter;
import bitc.next502.next502_backend.config.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@RequiredArgsConstructor
public class SecurityConfig {

  private final JwtTokenProvider jwtTokenProvider;

  @Bean
  public BCryptPasswordEncoder bCryptPasswordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  public JwtTokenAuthenticationFilter jwtTokenAuthenticationFilter() {
    return new JwtTokenAuthenticationFilter(jwtTokenProvider);
  }

  @Bean
  public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
    return authConfig.getAuthenticationManager();
  }

  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    //  모든 접속 허용
    configuration.setAllowedOriginPatterns(Arrays.asList("*"));
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type"));
    configuration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
  }

  @Bean
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .httpBasic(httpBasic -> httpBasic.disable())
            .formLogin(form -> form.disable())
            .logout(logout -> logout.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()))
            .authorizeHttpRequests(auth -> auth
                    // 1. 완전 공개
                    .requestMatchers("/", "/auth/**", "/api/auth/**", "/ocr/**", "/ws-stomp/**", "/board/**", "/h2-console/**", "/uploads/**", "/error").permitAll()
                    // 창고 관련 중 '검색'과 '상세조회'만 공개
                    .requestMatchers("/warehouse/search", "/warehouse/{id:[0-9]+}").permitAll()

                    // 2. 임대인(PROVIDER) 및 관리자 전용
                    // ★ '내 창고 목록'과 '창고 등록'은 임대인 권한이 있어야 함
                    .requestMatchers("/warehouse/my-list", "/warehouse/insert").hasAnyAuthority("ROLE_PROVIDER", "ROLE_ADMIN")
                    .requestMatchers("/admin/**").hasAuthority("ROLE_ADMIN")

                    // 3. 모든 로그인 회원 가능 (채팅, 찜, 마이페이지)
                    .requestMatchers("/chat/**", "/favorite/**", "/member/**", "/api/member/**").hasAnyAuthority("ROLE_MEMBER", "ROLE_PROVIDER", "ROLE_ADMIN")

                    // 4. 그 외 모든 요청은 인증 필요
                    .anyRequest().authenticated())
            .addFilterBefore(jwtTokenAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .build();
  }
}