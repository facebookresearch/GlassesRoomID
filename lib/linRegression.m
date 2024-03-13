% Copyright (c) Facebook, Inc. and its affiliates.

function [slope, intercept, line, r2] = linRegression(x,y)
% Thomas Deppisch, 2023

    X = [ones(length(x),1)  x];
    b = X\y;
    line = b(1) + x*b(2);

    residuals = y - X * b;
    r2 = 1 - sum(residuals.^2) / sum((y - mean(y)).^2); % r2 in percent describes the goodness of fit: 0 = bad, 100 = perfect

    slope = b(2);
    intercept = b(1);

    % figure
    % plot(x,y,'o')
    % hold on
    % plot(x,line,'--r')
    % grid on
end
