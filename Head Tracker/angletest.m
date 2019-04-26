angle_o = -135;
angle_c = -90;
cc = angle_o-angle_c;
angle_o1 = -135:1:-45;
angle_1 = angle_o1-cc;
x = ones(1,91);
y = tand (angle_1);
angle_f = atan2d(y,x);