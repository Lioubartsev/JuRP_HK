int32_t P_controller(int32_t ref, int current_pos) {
  return current_pos - ref;
}

int32_t u_to_pwm(int u) {
  // Scale control signal to one byte
  int pwm = u % 255;

  // Set pwm in range [-10, 10]
  pwm = pwm < -10 ? -10 : pwm;
  pwm = pwm > 10 ? 10 : pwm;
  return pwm
}
