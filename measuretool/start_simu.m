clc;clear;close all;


import java.awt.Robot;
import java.awt.event.*;

global robot
robot = java.awt.Robot;

t = timer;
t.StartDelay = 1;%延时1秒开始
t.ExecutionMode = 'fixedRate';%启用循环执行
t.Period = 0.5;%循环间隔2秒
t.TasksToExecute = 10000;%循环次数9次
t.TimerFcn = @simulationKeybord;

start(t)%开始执行