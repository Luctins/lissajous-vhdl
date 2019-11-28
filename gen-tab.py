import math

dec_offset = 100.0

for i in range(0,math.floor((math.pi/2)*dec_offset)):
    print("when ",i," => return ",math.floor(math.sin(i/dec_offset)*dec_offset),";")
