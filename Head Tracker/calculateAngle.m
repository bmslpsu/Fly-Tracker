function angle = calculateAngle(frame, mask, center,column)
val = frame(mask);
val2 = vec2mat(val,column);
val3 = transpose(val2);
tot_mass = sum(val3(:));
[ii,jj] = ndgrid(1:size(val3,1),1:size(val3,2));
R = sum(ii(:).*val3(:))/tot_mass;
C = sum(jj(:).*val3(:))/tot_mass;
angle = atan2((R-center(1)),(C-center(2)));
end