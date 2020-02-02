function [] = simulationKeybord(a,b,c)

global robot;

robot.keyPress    (java.awt.event.KeyEvent.VK_UP);
robot.keyRelease  (java.awt.event.KeyEvent.VK_UP);
disp('按下一次')
end