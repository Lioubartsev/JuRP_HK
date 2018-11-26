
void messageCb( const std_msgs::Int16& reference)
{
  motor_ref = reference.data / 10.0;
  //int16_t motor_ref_debug = motor_ref;
  //int_msg_4.data = motor_ref_debug;
  //chatter_3.publish( &int_msg_4 );
}

int32_t e_to_pwm(float e, float e_old, double e_sum) {
  static long int time_old = time_new;
  time_new = micros();
  float k_part = 0.1 * e; //comes from a wish that an error signal of 288 counts (45 degrees) should result in a 100% pwm control signal
  float d_part = 1 * (e - e_old) / (time_new - time_old);
  long i_part = 0 * e_sum; //e_sum just increases so much that it immediately overflows.

  if (i_part > 60) { //saturation
    i_part = 60;
  }
  else if (i_part < -60) {
    i_part = -60;
  }
  if (counter % 999 == 0) { //needed to slow down the prints to get reasonable values
    
    int16_t motor_ref_debug = motor_ref;
    int_msg_4.data = motor_ref_debug;  
    chatter_3.publish( &int_msg_4 );
    int16_t e16 = e;
    int_msg_4.data = e16;
    chatter_3.publish( &int_msg_4 );
    int_msg_4.data = 9999;
    chatter_3.publish( &int_msg_4 );
  }
  float pwm = k_part + d_part + i_part;
  // Set pwm in range [-10, 10]
  pwm = round(pwm);
  //Serial.println(pwm);
  if (pwm > 255) {
    pwm = 255;
  }
  else if (pwm < -255) {
    pwm = -255;
  }
  else {} //Nothing is done if the pwm is within the proper intervall!
  //Serial.println(pwm);
  return pwm;
}
void do_PID_stuff(float current_pos, float reference_pos) {

  e_old = e;

  e = reference_pos - current_pos;

  //the integration of the error:
  if (counter % 10 == 0) { //needed because the variable will just overflow immediately otherwise)
    e_sum += e;
  } //Currently just 0 because it is crazy


  new_pwm = e_to_pwm(e, e_old, e_sum); //convert error signal eto PWM duty cycle
  if (new_pwm >= 0) {  // Set direction of rotation to driver
    digitalWrite(PWM_DIR_PIN, PWM_POSITIVE_DIR);
    //Serial.print("Pos  ");
  } else {
    digitalWrite(PWM_DIR_PIN, PWM_NEGATIVE_DIR);
    //Serial.print("Neg  ");
  }
  analogWrite(PWM_VALUE_PIN, abs(new_pwm));   // Set value of PWM to driver

}

float get_serial_value() {
  /*We are reading over Serial using .read();
    We know that we will get it in the format ([-])[number]\r\n.
    In asciicode: "-" = 45, \r = 10, \n = 13, numbers from 0-9 = 48-57.
    If we know that it is a negative value, we use that knowledge later.
    If it's an \r, we just let it be taken out of the buffer; but it if it's \n we know we've reached the end.
  */
  int EOL_BOOL = 0;  int Neg_BOOL = 0;  int c; int value = 0;

  if (breakfastSerial.available() > 0) {
    while (!EOL_BOOL) {
      c = breakfastSerial.read();
      if (c == 13) {}
      else if (c == 10) {
        EOL_BOOL = 1;
      }
      else if (c == 45) {
        Neg_BOOL = 1;
      }
      else if ((c > 47) && (c < 58)) {
        value = value * 10 + c - 48; //take old values x10 to shift it up a decimal point
      }
      else {}
    }
    if (Neg_BOOL) {
      value = value * -1; //correct so that it is negative
    }

  }
//  int16_t value_debug = (int16_t)value; //WORKS
//  int_msg_4.data = value_debug;
//  chatter_3.publish( &int_msg_4 );
  //transform enc count to degrees
  return value * 360.0 / (2304.0 * gear_ratio); //conversion, gives float

}
