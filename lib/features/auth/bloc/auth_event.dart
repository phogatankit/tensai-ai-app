abstract class AuthEvent {}
class CheckLoginStatus extends AuthEvent {}
class LoginRequested extends AuthEvent { final String email, password; LoginRequested(this.email, this.password); }
class SignUpRequested extends AuthEvent { final String email, password; SignUpRequested(this.email, this.password); }
class LogoutRequested extends AuthEvent {}