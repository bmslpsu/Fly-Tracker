function [Mask] = HeadMask(vid)
% MakeWingMask:
    Vid = squeeze(vid);
    dim = size(Vid);
    figure
    imagesc(Vid(:,:,1));                                
    axis equal
    xlim([0 dim(2)])
    ylim([0 dim(1)])
       
    rPts = [...
        impoint(gca, dim(2)*0.7, dim(1)*0.1, 'PositionConstraintFcn', @(pos) rPositionConstraintFcn(pos, dim))... 	% rTopRight
        impoint(gca, dim(2)*0.7, dim(1)*0.9, 'PositionConstraintFcn', @(pos) rPositionConstraintFcn(pos, dim))...  	% rBottomRight
        impoint(gca, dim(2)*0.6, dim(1)*0.5, 'PositionConstraintFcn', @(pos) rPositionConstraintFcn(pos, dim))...   % rInnerCircle
        impoint(gca, dim(2)*0.55, dim(1)*0.5,'PositionConstraintFcn', @(pos) rPositionConstraintFcn(pos, dim))]; 	% rCenter
    setPositionConstraintFcn(rPts(3), @(pos) rInnerCircleConstraintFcn(pos, dim, rPts));
    for i = 1:4
        setColor(rPts(i), 'r');
    end
    
    
    global rCenterOldPos rCallbackOk;                                               % Global variables for the rightside callback functions
    rCenterOldPos = getPosition(rPts(4));
    rCallbackOk = true;
    addNewPositionCallback(rPts(4), @(pos) rCenterCallback(pos, rPts));             % Rightside callback functions
    addNewPositionCallback(rPts(1), @(pos) rTopRightCallback(pos, rPts));
    addNewPositionCallback(rPts(2), @(pos) rBottomRightCallback(pos, rPts));
    addNewPositionCallback(rPts(3), @(pos) rInnerCircleCallback(rPts));
    global rGUILines;                                                               % The array that holds the lines and arcs used for the rightside GUI
    rGUILines = [line() line() line() line() line()];                               % Need to initialize it for redrawRightGUI
    for i = 1:5                                                                     % Order of lines(1-5): top line, bottom line, outer arc, middle arc, inner arc
        rGUILines(i).Color = [1 0 0];                                               % Make all the lines on the right red
    end
    
    redrawRightGUI(rPts)                                                            % Drawing for the first time
    
    uistack(rGUILines, 'bottom');                                                   % Making sure the order on the UI stack is good so that the impoints are actually clickable and not obscured by the lines
    uistack(rGUILines);
    
    msgbox({'Choose the area for the wings and click the button when done'});
    
    btnDone = uicontrol('Style', 'togglebutton', 'String', 'Done',...
        'Position', [475 370 50 20]);
    btnCancel = uicontrol('Style', 'togglebutton', 'String', 'Cancel',...
        'Position', [475 345 50 20]);
    
    while ~btnDone.Value && ~btnCancel.Value
        pause(0.05)
    end
    if btnCancel.Value
        return
    end
    btnDone.Value = 0;
    
    % Make strcture containing mask points
    Mask.R.center   = getPosition(rPts(4));

    
    Mask.R.points   = rMaskPts(rPts);

    
    Mask.R.top      = getPosition(rPts(1));


    Mask.R.bot      = getPosition(rPts(2));


end

%% Function for getting the perimeter points for the mask in the format [X1 Y1; X2 Y2;... Xn Yn]
function pts = rMaskPts(rPts)
    bottomPos = getPosition(rPts(2));                                                                               % Get some useful positions
    centerPos = getPosition(rPts(4));
    topPos    = getPosition(rPts(1));
    outerRadius  = distance(centerPos, topPos);                                                                     % Calculate the radii
    innerRadius  = distance(centerPos, getPosition(rPts(3)));
    topTheta = atan2(topPos(2)-centerPos(2), topPos(1)-centerPos(1));                                               % Calculate the angle between the horizontal and the line made from the center of the cirlce to the top right point
    bottomTheta = atan2(bottomPos(2)-centerPos(2), bottomPos(1)-centerPos(1));                                      % Calculate the angle between the horizontal and the line made from the center of the circle to the bottom right point
 
    [x, y] = ellipse(centerPos(1), centerPos(2), outerRadius, outerRadius, 0, [bottomTheta topTheta]);              % Calculate the points for the outer arc
    outerArc = vertcat(x,y)';
    
    [x, y] = ellipse(centerPos(1), centerPos(2), innerRadius, innerRadius, 0, [bottomTheta topTheta]);              % Calculate the points for the inner arc
    innerArc = vertcat(x,y)';
    
    pts = vertcat(outerArc, flipud(innerArc));
end
%% Function for drawing the right-side GUI lines
function redrawRightGUI(rPts)
    global rGUILines;
    bottomPos = getPosition(rPts(2));                                                                               % Get some useful positions
    centerPos = getPosition(rPts(4));
    topPos    = getPosition(rPts(1));
    outerRadius  = distance(centerPos, topPos);                                                                     % Calculate the radii
    innerRadius  = distance(centerPos, getPosition(rPts(3)));
    middleRadius = mean([outerRadius innerRadius]);
    topTheta = atan2(topPos(2)-centerPos(2), topPos(1)-centerPos(1));                                               % Calculate the angle between the horizontal and the line made from the center of the cirlce to the top right point
    bottomTheta = atan2(bottomPos(2)-centerPos(2), bottomPos(1)-centerPos(1));                                      % Calculate the angle between the horizontal and the line made from the center of the circle to the bottom right point
    
    rGUILines(1).XData = [innerRadius*cos(topTheta)+centerPos(1) outerRadius*cos(topTheta)+centerPos(1)];           % Set the info for the top line
    rGUILines(1).YData = [innerRadius*sin(topTheta)+centerPos(2) outerRadius*sin(topTheta)+centerPos(2)];
    
    rGUILines(2).XData = [innerRadius*cos(bottomTheta)+centerPos(1) outerRadius*cos(bottomTheta)+centerPos(1)];     % Set the info for the bottom line
    rGUILines(2).YData = [innerRadius*sin(bottomTheta)+centerPos(2) outerRadius*sin(bottomTheta)+centerPos(2)];
    
    [x, y] = ellipse(centerPos(1), centerPos(2), outerRadius, outerRadius, 0, [bottomTheta topTheta]);              % Calculate the points for the outer arc
    rGUILines(3).XData = x;
    rGUILines(3).YData = y;
    
    [x, y] = ellipse(centerPos(1), centerPos(2), middleRadius, middleRadius, 0, [bottomTheta topTheta]);            % Calculate the points for the middle arc
    rGUILines(4).XData = x;
    rGUILines(4).YData = y;
    
    [x, y] = ellipse(centerPos(1), centerPos(2), innerRadius, innerRadius, 0, [bottomTheta topTheta]);              % Calculate the points for the inner arc
    rGUILines(5).XData = x;
    rGUILines(5).YData = y;
end
%% Right position constraint and callback functions
function rInnerCircleCallback(rPts)
    global rCallbackOk;
    if rCallbackOk
        rCallbackOk = false;
        redrawRightGUI(rPts);
        rCallbackOk = true;
    end
end

function rTopRightCallback(pos, rPts)
    global rCallbackOk;
    if rCallbackOk
        rCallbackOk = false;
        outerRadius = distance(getPosition(rPts(4)), pos);                                                                      % Calculate the radii
        innerRadius = distance(getPosition(rPts(4)), getPosition(rPts(3)));
        bottomPos = getPosition(rPts(2));                                                                                       % Get some useful positions
        centerPos = getPosition(rPts(4));
        bottomTheta = atan2(bottomPos(2)-centerPos(2), bottomPos(1)-centerPos(1));                                              % Calculate the angle between the horizontal and the line made from the center of the circle to the bottom right point
        setConstrainedPosition(rPts(2), [outerRadius*cos(bottomTheta)+centerPos(1) outerRadius*sin(bottomTheta)+centerPos(2)]); % Set the position of the bottom right point
        midPt = midpoint(pos, getPosition(rPts(2)));                                                                            % Get the midpoint between the top right and bottom points
        innerTheta = atan2(midPt(2)-centerPos(2), midPt(1)-centerPos(1));                                                       % Calculate the angle between the horizontal and the line made from the center of the circle to the point defining the inner circle
        setConstrainedPosition(rPts(3), [innerRadius*cos(innerTheta)+centerPos(1) 0]);                                          % Set the position of the point defining the inner circle
        redrawRightGUI(rPts)
        rCallbackOk = true;
    end
end

function rBottomRightCallback(pos, rPts)
    global rCallbackOk;                                                                                                         
    if rCallbackOk
        rCallbackOk = false;
        outerRadius = distance(getPosition(rPts(4)), pos);                                                                  % Calculate the radii
        innerRadius = distance(getPosition(rPts(4)), getPosition(rPts(3)));
        topPos = getPosition(rPts(1));                                                                                      % Get some useful positions
        centerPos = getPosition(rPts(4));
        topTheta = atan2(topPos(2)-centerPos(2), topPos(1)-centerPos(1));                                                   % Calculate the angle between the horizontal and the line made from the center of the circle to the top right point
        setConstrainedPosition(rPts(1), [outerRadius*cos(topTheta)+centerPos(1) outerRadius*sin(topTheta)+centerPos(2)]);   % Set the position of the top right point
        midPt = midpoint(getPosition(rPts(1)), pos);                                                                        % Get the midpoint between the top right and bottom points
        innerTheta = atan2(midPt(2)-centerPos(2), midPt(1)-centerPos(1));                                                   % Calculate the angle between the horizontal and the line made from the center of the circle to the point defining the inner circle
        setConstrainedPosition(rPts(3), [innerRadius*cos(innerTheta)+centerPos(1) 0]);                                      % Set the position of the point defining the inner circle
        redrawRightGUI(rPts)
        rCallbackOk = true;
    end
end

function rCenterCallback(pos, rPts)
    global rCenterOldPos rCallbackOk;
    if rCallbackOk
        rCallbackOk = false;
        delta = pos - rCenterOldPos;

        for i = 1:3
            setConstrainedPosition(rPts(i), getPosition(rPts(i)) + delta); % Shift everything by how much the center moved
        end
        redrawRightGUI(rPts)
        rCenterOldPos = pos;
        rCallbackOk = true;
    end
end

function newPos = rPositionConstraintFcn(newPos, dim)
%     if newPos(1) > dim(1)
%         newPos(1) = dim(1);
%     elseif newPos(1) < dim(1)/2
%         newPos(1) = dim(1)/2;
%     end
    
    if newPos(2) > dim(2)
        newPos(2) = dim(2);
    elseif newPos(2) < 0
        newPos(2) = 0;
    end
end

function newPos = rInnerCircleConstraintFcn(newPos, dim, rPts)
    newPos = rPositionConstraintFcn(newPos, dim);
    
    center = getPosition(rPts(4));
    if newPos(1) < center(1)
        newPos(1) = center(1)+1;
    end
    
    midpt = midpoint(getPosition(rPts(1)), getPosition(rPts(2)));
    m = (midpt(2)-center(2))/(midpt(1)-center(1));
    newPos(2) = m*(newPos(1)-center(1)) + center(2); % Basically using point-slope formula to keep the point on line
end

function mid = midpoint(pt1, pt2)
    mid = [(pt1(1) + pt2(1))/2 (pt1(2) + pt2(2))/2];
end

function dist = distance(pt1, pt2)
    dist = sqrt((pt1(1) - pt2(1))^2 + (pt1(2) - pt2(2))^2);
end
