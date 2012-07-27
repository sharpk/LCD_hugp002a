/*
*
*  	Test program for interfacing the HUGP002A character LCD to the Arduino
*
*   Copyright (c) 2012 Ken Sharp
*   License: http://opensource.org/licenses/mit-license.php
*
* 	The circuit:
* 	LCD RS pin to digital pin 12
* 	LCD Enable pin to digital pin 11
* 	LCD D4 pin to digital pin 5
* 	LCD D5 pin to digital pin 4
* 	LCD D6 pin to digital pin 3
* 	LCD D7 pin to digital pin 2
* 	LCD R/W pin to ground
*	LCD backlight control to pin 8
*/

#include <LiquidCrystal.h>

//icon code defines
#define LCD_ICON_BATTERY_OUTLINE 0x11
#define LCD_ICON_BATTERY_SEG1 0x20
#define LCD_ICON_BATTERY_SEG2 0x21
#define LCD_ICON_BATTERY_SEG3 0x10
#define LCD_ICON_BATTERY_OUTLINE_AND_SEG2 0x31
#define LCD_ICON_BATTERY_SEG1_AND_SEG3 0x30
#define LCD_ICON_BLACK_PHONE 0x12
#define LCD_ICON_WHITE_PHONE 0x13
#define LCD_ICON_PEN 0x14
#define LCD_ICON_SCAN 0x15
#define LCD_ICON_ENVELOPE 0x18
#define LCD_ICON_NO_SVC 0x19
#define LCD_ICON_BAR1 0x1B
#define LCD_ICON_BAR2 0x2D
#define LCD_ICON_BAR3 0x1D
#define LCD_ICON_BAR2_AND_BAR3 0x3D

char row_offsets[4] = {0x00, 0x10, 0x40, 0x50};
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
	lcd.begin(14,4);
	lcd.print("hello world!");
	hugp002a_iconsOff();
	
	// Turn on backlight
	digitalWrite(8, 0);
}

void loop() {
	static int i = 0;
	delay(5000);
	
	hugp002a_iconControl(LCD_ICON_BATTERY_OUTLINE_AND_SEG2, i%2, 1);
	hugp002a_iconControl(LCD_ICON_BATTERY_SEG1_AND_SEG3, i%2, 1);
	hugp002a_iconControl(LCD_ICON_BLACK_PHONE, i%2, 1);
	hugp002a_iconControl(LCD_ICON_WHITE_PHONE, i%2, 1);
	hugp002a_iconControl(LCD_ICON_PEN, i%2, 1);
	hugp002a_iconControl(LCD_ICON_SCAN, i%2, 1);
	hugp002a_iconControl(LCD_ICON_ENVELOPE, i%2, 1);
	hugp002a_iconControl(LCD_ICON_NO_SVC, i%2, 1);
	hugp002a_iconControl(LCD_ICON_BAR1, i%2, 1);
	hugp002a_iconControl(LCD_ICON_BAR2_AND_BAR3, i%2, 1);

	hugp002a_setCursor(0,1);
	lcd.print(millis()/1000);
	hugp002a_setCursor(0,2);
	lcd.print("hello ");
	lcd.print(i);
	i++;
}

void hugp002a_setCursor(char col, char row) {
	lcd.command(LCD_SETDDRAMADDR | col + row_offsets[row]);
}

/* must call at least one print() prior to calling this */
void hugp002a_iconsOff() {
	int i;
	lcd.command(0x30);
	lcd.command(0x02);
	for (i=0x40; i <= 0x4d; i++) {
		lcd.command(i);
		lcd.write(0x00);
	}
	lcd.command(0x29);
}

void hugp002a_iconControl(unsigned char icon, char blink, char state) {
	unsigned char icon_byte, icon_addr;

	icon_addr = (0x0f & icon) + 0x40;

	if (state > 0) {
		icon_byte = (icon & 0xf0) >> 4;
		if (blink > 0)
			icon_byte |= 0x80;
	}
	else {
		icon_byte = 0;
	}
	
	lcd.command(0x30);
	lcd.command(0x02);
	
	lcd.command(icon_addr);
	lcd.write(icon_byte);
	
	lcd.command(0x29);
}

// This function doesn't seem to work
// I found this on the internet so I've kept
// it here for documentation and future investigation
void hugp002a_iconsBlink(char state) {
	lcd.command(0x30);
	lcd.command(0x02);
	lcd.command((state) ? 0x2e : 0x2c);
	lcd.command(0x29);
}