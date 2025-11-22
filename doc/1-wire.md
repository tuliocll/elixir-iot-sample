To enabled 1-Wire on your Raspberry Pi, follow these steps:

Edit the `/boot/config.txt` file and add the following line at the end:

```
dtoverlay=w1-gpio,gpiopin=27
```

> Very important! I used this gpio(`27`), change if you choose a diferent.
