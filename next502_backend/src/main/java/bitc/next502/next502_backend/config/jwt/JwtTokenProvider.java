package bitc.next502.next502_backend.config.jwt;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.Role;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Header;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.time.Duration;
import java.util.*;

@Service
@RequiredArgsConstructor
public class JwtTokenProvider {

  private final JwtProperties jwtProperties;

  public String generateToken(MemberEntity memberEntity, Duration expiredAt) {
    Date now = new Date(); // 날짜/시간 객체 생성

    return makeToken(new Date(now.getTime() + expiredAt.toMillis()), memberEntity);
  }

  private String makeToken(Date expiry, MemberEntity memberEntity) {
    Date now = new Date();

    Map<String, Object> claims = new HashMap<>();
    claims.put("id", memberEntity.getId());
    claims.put("userId", memberEntity.getUserId());
    claims.put("userNick", memberEntity.getUserNick());
    claims.put("userEmail", memberEntity.getUserEmail());
    claims.put("userRole", memberEntity.getRole());

    Key secretKey = Keys.hmacShaKeyFor(jwtProperties.getSecretKey().getBytes());

    return Jwts.builder()
        .setHeaderParam(Header.TYPE, Header.JWT_TYPE)
        .setIssuer(jwtProperties.getIssuer())
        .setIssuedAt(now)
        .setExpiration(expiry)
        .setSubject(memberEntity.getUserEmail())
        .addClaims(claims)
        .signWith(secretKey)
        .compact();
  }

  public boolean validToken(String token) {
    try {
      Key secretKey = Keys.hmacShaKeyFor(jwtProperties.getSecretKey().getBytes());

      Jwts.parser()
          .setSigningKey(secretKey)
          .build()
          .parseClaimsJws(token);
      return true;
    }
    catch (Exception e) {
      return false;
    }
  }

  public Authentication getAuthentication(String token) {

    Claims claims = getClaims(token);

    Set<SimpleGrantedAuthority> authorities = Collections.singleton(new SimpleGrantedAuthority(claims.get("userRole").toString()));

    MemberEntity member = MemberEntity.builder()
        .userId(claims.get("userId").toString())
        .userNick(claims.get("userNick").toString())
        .userEmail(claims.get("userEmail").toString())
        .role(Role.valueOf(claims.get("userRole").toString()))
        .build();

    return new UsernamePasswordAuthenticationToken(member, token, authorities);
  }

  private Claims getClaims(String token) {
    Key secretKey = Keys.hmacShaKeyFor(jwtProperties.getSecretKey().getBytes());

    return Jwts.parser()
        .setSigningKey(secretKey)
        .build()
        .parseClaimsJws(token)
        .getBody();
  }
}
