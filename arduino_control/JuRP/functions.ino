// initiate 50 kHz pwm

void initPWM() {// ####Setup pwm####
  // reset registers
  TCCR0A = 0x00;
  TCCR0B = 0x00;

  TCCR0A = _BV(COM0A0) | _BV(COM0B1) | _BV(WGM01) | _BV(WGM00); //FastPWM
  TCCR0B = _BV(WGM02) | _BV(CS11);// | _BV(WGM23); //prescale 8
  OCR0A = 39; // 50khz
  OCR0B = 19;//19;
  
  //setPWM(duty); //set dutycycle
}

 //Set duty cycle on pwm
void setPWM(float duty) { //sets pwm on pin 11
  if (duty > 100) {
    duty = 100;
  }
  else if (duty < 0) {
    duty = 0;
  }
  else if (duty == 0 ){
    OCR0B = 0;
  }
  else{
    OCR0B = duty/100*40 - 1;  
  }
}

void encoder_isr(){ //the interrupt function
//  
  enc_val = enc_val << 2;
  enc_val = enc_val | ((PIND & 0b1100) >> 2); //NOTE: Arduino Mega -> PINE. Arduino Uno -> PIND
  //enc_val now has the right lookup table index value
  enc_count = enc_count + lookup_table[enc_val & 0b1111];
}

///*
////Initiate 1 kHz timer
//void initTimer() {
//  // reset registers
//  TCCR5A = 0x00;
//  TCCR5B = 0x00;
//  // Set mode
//  TCCR5B |= (1 << WGM52); // CTC mode
//  // set clock source and prescaler
//  TCCR5B |= (1 << CS50) | (1 << CS51); // internal clock source, prescaler 64
//  // timer mask register set
//  TIMSK5 |= (1 << OCIE5A);
//  // counter variables
//  OCR5A = TOP5 * sample_time_ms;
//}*/
//
////Reads data from serial 0 and returns it.
//float serialRead(void) {
//  float inData = 0;
//  inData = Serial.parseFloat();
//  //Serial.println(inData); //Debug print
//  return inData;
//}
//
//// read encoder and determine direction
///*
//void encoder_isr() {
//  static uint8_t enc_val = 0; //NEEDS TABLE FOR REFERENCE
//  enc_val = enc_val | (PINE & 0b00110000); //Pin 0, 1 keep track of new enc
//  enc_val = enc_val >> 4; //set the value to the first pins
//  if (enc_val == 2 || enc_val == 4 || enc_val == 11 || enc_val == 13) { // if positive direction in the table
//    dir = 1;
//  }
//  else if (enc_val == 1 || enc_val == 7 || enc_val == 8 || enc_val == 14) { //if negative
//    dir = -1;
//  }
//  enc_val = enc_val << 6; //move it to the left of the values recorded next cycle
//  enc_count = enc_count + dir; //count the encoder.
//}
//*/
//
//// timer interrupt for calculating speed on motor.
///*
//ISR(TIMER5_COMPA_vect) {  // interrupt on 1 kHz clock
//  //static float rpm;
//  rpm = enc_count*0.3; // rpm = float(enc_count) * 60 * ENC_SAMPLE_RATE / sample_time_ms / PPR
//  enc_count = 0;
//  
//  err = (ref - rpm); // reading actual rpm
//  X = P*err + X_Old*I; // Calculating output
//  if(X > 50){
//    X = 50;
//  }
//  else if(X < -50){
//    X = -50;
//  }
//  X_Old = X_Old + err;
//  X += 50;
//  duty = X;
//  setPWM(duty); // Actuate output  
//}
//*/
