// lib/utils/navigation_state.dart

// 홈 버튼 눌렸을 때 HomeScreen의 didPopNext에서 탭을 0으로 리셋하기 위한 플래그
bool _goHomeRequested = false;

void requestGoHome() => _goHomeRequested = true;

bool consumeGoHomeRequest() {
  final v = _goHomeRequested;
  _goHomeRequested = false;
  return v;
}
