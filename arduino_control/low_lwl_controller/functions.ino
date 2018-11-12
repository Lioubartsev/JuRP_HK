int32_t P_controller(int32_t ref, int current_pos) {
  return current_pos - ref;
}
