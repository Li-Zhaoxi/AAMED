from pyAAMED import pyAAMED
import cv2


imgC = cv2.imread('002_0038.jpg')
imgG = cv2.cvtColor(imgC, cv2.COLOR_BGR2GRAY)

aamed = pyAAMED(600, 600)

aamed.setParameters(3.1415926/3, 3.4,0.77)
res = aamed.run_AAMED(imgG)
print(res)
aamed.drawAAMED(imgG)
cv2.waitKey()
