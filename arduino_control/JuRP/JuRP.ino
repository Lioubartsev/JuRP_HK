

volatile long enc_count = 0;
static uint8_t enc_val = 0;
static int8_t lookup_table[] = {0, -1, 1, 0, 1, 0, 0, -1, -1, 0, 0, 1, 0, 1, -1, 0};
//https://makeatronics.blogspot.tw/2013/02/efficiently-reading-quadrature-with.html
//the point is to figure out which direction the motor is rotating.
//By using the new and old A and B values you can look it up in a table.
//That table will tell if you have gone one step forward (1), backward (-1) or if the motor has stood


int goal_enc_count = 13000; //the initial value of the "goal encoder value (encoder value
int rough_place = 1; //used to make it easier to send position commands from the arduino
float err = 0;
float inp = 0;
float P = 0.05;
float I = 0;
float D = 0;
int pwmPin = 5;//9;
int dirPin = 11;
float duty = 0; //initialize duty cycle

float temp =0;

void setup() {

  Serial.begin(9600);
  Serial.setTimeout(10); //makes the parseInt function faster

  pinMode(2, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  //pinMode(5, OUTPUT); //OCR0B, aka PWMpin

  
  attachInterrupt(digitalPinToInterrupt(2), encoder_isr, CHANGE);
  attachInterrupt(digitalPinToInterrupt(3), encoder_isr, CHANGE); //attach pins 2 and 3 to the interrupt

  //OCR0B, aka PWMpin is 5
  digitalWrite(pwmPin, OUTPUT); //make these two ouput pins
  digitalWrite(dirPin, OUTPUT);

  initPWM();

}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.println(err);
  if (Serial.available() > 0) {
    // read the incoming byte:
    rough_place = Serial.parseInt(); //we send a "rough place"
    goal_enc_count = (rough_place % 10 + 1) * 2500; //note that the max encoder value is roughly 30000 points, so we try to

  }

//  temp = rough_place*10;
//  setPWM(temp);
   
  err = goal_enc_count - enc_count; //positive direction up
  if (err < 0){
    digitalWrite(dirPin, LOW);
  }
  else {
    digitalWrite(dirPin, HIGH);
  }

  inp = abs(err*P);
  setPWM(inp);

  
  //We have an incredicly crude p-controller that either moves the end effector up or down depending on where it is in relation
  //to the encoder position, as well as try to put the whole machine in a "maintaining vertical position"-mode when it is within a span.
  /*
  if (enc_count <= goal_enc_count - 750) {
    Upp();
  }
  else if (enc_count >= goal_enc_count + 750) {
    Ned();
  }
  else {
    Maintain();
  }
  */
}



//Note that we never adjust the duty-cycles in a true PID-fashion, the actuation signal is just bouncing between a top and bottom.
void Upp() {
  //analogWrite(pwmPin, 220); //relatively strong signal upwards actuation, not 100% (which would be is 255)
  setPWM(50);
  digitalWrite(dirPin, HIGH);
}

void Ned() {
  //analogWrite(pwmPin, 100); //much lower than Upp because going down the 1DoF model has gravity on its side
  setPWM(30);
  digitalWrite(dirPin, LOW);

}

void Maintain() { //this function maintains vertical position
  //analogWrite(pwmPin, 35); //35, or roughly 13% duty cycle with the 12v supply input, is basically enough to keep it maintaining its vertical position and no slide down
  setPWM(10);
  digitalWrite(dirPin, HIGH);
}
