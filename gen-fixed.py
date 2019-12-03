
import math

a = 2
b = 6
d = math.pi/2

print("x,y")

for i in range(0,math.floor(100*2*math.pi)):
    print(math.floor(100*(1+math.sin(a*i+d))),",",math.floor(100*(1+math.sin(b*i))))
