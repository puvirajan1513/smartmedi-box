// Arduino code for Smart Medical Box for Disabled People
#include <Wire.h>
#include <RTClib.h>
#include <LiquidCrystal_I2C.h>

// Define components
RTC_DS3231 rtc;
LiquidCrystal_I2C lcd(0x27, 16, 2);

const int ledPin = 13;      // LED for visual alert
const int buzzerPin = 12;   // Buzzer for sound alert
const int buttonPin = 7;    // Button to confirm medicine taken

// Medicine schedule (hour, minute)
const int medicineTimes[3][2] = { {8, 0}, {14, 0}, {20, 0} };

// State variables
bool medicineTaken = false;
bool alertActive = false;
int currentAlarmIndex = -1;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(buzzerPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);

  lcd.init();
  lcd.backlight();

  if (!rtc.begin()) {
    lcd.setCursor(0, 0);
    lcd.print("RTC ERROR!");
    while (1);
  }

  lcd.setCursor(0, 0);
  lcd.print("Smart Med Box");
  delay(2000);
  lcd.clear();
}

void loop() {
  DateTime now = rtc.now();

  // Check current time against medicine schedule
  for (int i = 0; i < 3; i++) {
    if (now.hour() == medicineTimes[i][0] && now.minute() == medicineTimes[i][1] && !alertActive) {
      currentAlarmIndex = i;
      triggerAlert();
    }
  }

  // Handle button press to confirm medicine taken
  if (alertActive && digitalRead(buttonPin) == LOW) {
    medicineTaken = true;
    stopAlert();
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Medicine Taken");
    delay(2000);
    lcd.clear();
  }

  delay(1000); // Loop every second
}

void triggerAlert() {
  alertActive = true;
  medicineTaken = false;

  // Display alert on LCD
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Time for Meds!");
  lcd.setCursor(0, 1);
  lcd.print("Slot: ");
  lcd.print(currentAlarmIndex + 1);

  // Activate LED and buzzer
  digitalWrite(ledPin, HIGH);
  tone(buzzerPin, 1000);
}

void stopAlert() {
  alertActive = false;

  // Deactivate LED and buzzer
  digitalWrite(ledPin, LOW);
  noTone(buzzerPin);
}
