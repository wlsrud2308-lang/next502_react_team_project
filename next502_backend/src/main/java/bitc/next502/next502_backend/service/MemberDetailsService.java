package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberDetailsService implements UserDetailsService {

  private final MemberRepository memberRepository;

  @Override
  public MemberEntity loadUserByUsername(String userId) throws UsernameNotFoundException {
    return memberRepository.findByUserId(userId).orElseThrow(() -> new IllegalArgumentException("사용자 ID 가 없습니다."));
  }
}
