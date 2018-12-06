
void messageCb( const std_msgs::Int16& reference)
{
  motor_ref = reference.data / 10.0;
  if ( motor_ref == 660) {
    throw_mode = 0;
     motor_ref = 45;
  }
  else if ( motor_ref > 160)
  {
    motor_ref = 160;
    throw_mode = 0;
  }
  else if ( motor_ref == -660 && throw_mode == 0)
  {
    motor_ref = 55;
    throw_mode = 1;
  }

  else if ( motor_ref < -10)
  {
    motor_ref = -10;
    throw_mode = 0;
  }


}


void do_PID_stuff(float P, float I, float D)
{
  unsigned long time_new = micros();
  e_old = e;
  e = motor_ref - motor_pos;

  if (e_sum > 40 / I) { //saturation
    e_sum = 40 / I;
  }
  else if (e_sum < -20 / I) {
    e_sum = -20 / I;
  }

  double p_part = P * e; //
  double i_part = I * e_sum; //e_sum just increases so much that it immediately overflows.
  double d_part = D * (e - e_old) / ((time_new - time_old) * 0.000001);

  e_sum += e * ((time_new - time_old) * 0.000001);

  if (counter % 500 == 0 ) { //needed to slow down the prints to get reasonable values

    int16_t elb_pos = int16_t(motor_pos * 10);
    int_msg_5.data = elb_pos;
    elbow_pos.publish( &int_msg_5);

    //    int16_t motor_ref_debug = motor_ref;
    //    int_msg_4.data = motor_ref_debug;
    //    chatter_3.publish( &int_msg_4 );
    //    int16_t pos_part16 = motor_pos;
    //    int_msg_4.data = pos_part16;
    //    chatter_3.publish( &int_msg_4 );
    //    //    int16_t e16 = e;
    //    //    int_msg_4.data = e16;

    int16_t p_part16 = p_part;
    int_msg_4.data = p_part16;
    chatter_3.publish( &int_msg_4 );

    int16_t i_part16 = i_part;
    int_msg_4.data = i_part16;
    chatter_3.publish( &int_msg_4 );

    int16_t d_part16 = d_part;
    int_msg_4.data = d_part16;
    chatter_3.publish( &int_msg_4 );

    //    int_msg_4.data = 9999;
    //    chatter_3.publish( &int_msg_4 );

  }

  float pwm = round(p_part + i_part + d_part);
  if (pwm > 170 /*255*/ ) {
    pwm = 170;
  }
  else if (pwm < -170) {
    pwm = -170;
  }
  else {} //Nothing is done if the pwm is within the proper intervall!

  if (pwm >= 0) {  // Set direction of rotation to driver
    digitalWrite(PWM_DIR_PIN, PWM_POSITIVE_DIR);
  } else {
    digitalWrite(PWM_DIR_PIN, PWM_NEGATIVE_DIR);
  }

  //float pwm_1 = ( (pwm_1)*0.3137 +10.0 ) * 2.55 ;
  analogWrite(PWM_VALUE_PIN, abs(pwm));   // Set value of PWM to driver

  time_old = time_new ;
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

void do_throw_stuff() {
  if (motor_pos < motor_ref && thrown == 0) {
    digitalWrite(PWM_DIR_PIN, PWM_POSITIVE_DIR);
    analogWrite(PWM_VALUE_PIN, 255);
  }
  if (motor_pos >= motor_ref) {
    digitalWrite(PWM_DIR_PIN, PWM_NEGATIVE_DIR);
    thrown = 1;
    //ros write throwBool = 1
  }
}
