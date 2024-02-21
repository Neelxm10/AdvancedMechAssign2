%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PATH PLANNER%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's start off by defining some via points in an array for both x and y
% coordinates as well as wrist orientation (in radians).
clc; clear all; close all;
x = [0, 0.05, 0.10, 0.15, 0.25]; % meters
y = [0, 25, 5, 10, 0]; % meters
O = [0, pi/2, pi/4, 0, pi]; % radians

% With the via points defined, let's define the time segments.
Ts = [ 3, 4, 3, 3]; % seconds

% Let's assume fixed acceleration
Af = 2.0; % fixed at 2 m/s^2

% Let's define the number of line segments
n = length(x) - 1;

% Create a time progression matrix like Professor Ala did.
% First column of Tp matrix - segmentation start time
% Second column of Tp matrix - first parabolic blend (end) time
% Third column of Tp matrix - linear segment end time
% Fourth Column of Tp matrix - second parabolic end time.
Tp = zeros(n, 4);

% Calculate blend times, velocities, and accelerations
for i = 1:n
    % Calculate blend times
    blend_time = Ts(i) / 3;

    % Assign values to progression time matrix
    Tp(i, 1) = (i - 1) * Ts(i);
    Tp(i, 2) = Tp(i, 1) + blend_time;
    Tp(i, 3) = Tp(i, 2) + Ts(i) - 2 * blend_time;
    Tp(i, 4) = Tp(i, 3) + blend_time;
end

% Preallocate memory for acceleration, position, and velocity vectors
% representing (X, Y, O)
A = zeros(n, 3);
V = zeros(n, 3);
P = zeros(n, 3);

% Assign constant acceleration in all three planes.
for i = 1:n
    A(i, :) = [Af, Af, Af];

    % Will produce instantaneous velocity (should be linear in nature as
    % acceleration is constant)
    V(i, 1) = A(i, 1) * Tp(i, 2);
    V(i, 2) = A(i, 2) * (Tp(i, 3) - Tp(i, 2));
    V(i, 3) = (O(i + 1) - O(i)) / Ts(i); % Linear segment in wrist orientation

    % Calculating position (actually applying the blends)
    % Using x = x0 + v0t + 1/2at^2
    P(i, 1) = x(i) + V(i, 1) * (Tp(i, 2)) + (0.5 * (A(i, 1) * (Tp(i, 2)^2)));
    % Parabolic segment in y
    P(i, 2) = y(i) + V(i, 2) * (Tp(i, 3) - Tp(i, 2)) + 0.5 * A(i, 2) * ((Tp(i, 3) - Tp(i, 2))^2);
    % Linear segment in wrist orientation
    P(i, 3) = O(i) + V(i, 3) * (Tp(i, 4) - Tp(i, 3)) % Linear segment in wrist orientation
end

% Extract relevant blend times for plotting
t_step = [Tp(:, 2), Tp(:, 3)];

% Plot X-coordinate
figure
plot(t_step', P(:, 1), 'o-');
hold on;
plot(Tp(:, 1), x(2:5), 'ro');
title('X-coordinate');

% Plot Y-coordinate
figure
plot(t_step', P(:, 2), 'o-');
hold on;
plot(Tp(:, 1), y(2:5), 'ro');
title('Y-coordinate');

% Plot Wrist Orientation
figure
plot(t_step', P(:, 3), 'o-');
hold on;
plot(Tp(:, 1), O(2:5), 'ro');
title('Wrist Orientation');