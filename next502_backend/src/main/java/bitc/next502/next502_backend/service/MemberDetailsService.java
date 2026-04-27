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
    return memberRepository.findByUserId(userId)
            .orElseThrow(() -> new UsernameNotFoundException("해당 아이디를 찾을 수 없습니다: " + userId));
  }
}