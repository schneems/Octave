% octave cheatsheet
% not equals(~=)
1 ~=2 % => 1

% change prompt
PS1('>> ');

% semicolon suppresses output


% print
disp( 1+1)
disp(sprintf('2 decimals: %0.2f', 3.146))
format long
format short


% matrix
A = [1 2; 3 4 ; 5 6]
A =

   1   2
   3   4
   5   6

% vector
v = [1; 2; 3]

% range fat vector
v = 1: 0.1: 1.5
v =

    1.0000    1.1000    1.2000    1.3000    1.4000    1.5000

% matrix of ones
ones(2,3)
ans =

   1   1   1
   1   1   1


zeroes(1,3) % matrix of zeroes
rand(3,3)   % matrix of random numbers
eye(3)      # identity matrix
ans =

Diagonal Matrix

   1   0   0
   0   1   0
   0   0   1

v = [1,2,3,4]
% length returns longest dimension
length(v) % =>  4

% size returns matrix of size
size(v)   % => [1,4]


% working with files
  load file
  load featuresX.dat

  who   % shows variables in current scope
  whos  % shows variables and size

  clear featuresX % removes variable featuresX

  % save to disk
  v = [1;2;3;4;5]

  save hello.mat v; % saves v to file hello.mat

  clear % removes all variables in workspace

  save hello.mat v -ascii; % save as text

A(3,2) % gets the value on row 3, column 2
A(2,:) % get every element in row 2

A = [A, [100; 101; 102]] % append another column to a

% ==============================

A = [1 2 ; 3 4 ; 5 6]
B = [11 12; 13 14; 15 16]
C = [1 1; 2 2]

% element wise multiplication (.*)

A .* B
ans =

   11   24
   39   56
   75   96

abs(A) % absolute value

% transpose
A'
ans =

   1   3   5
   2   4   6

A = magic(3) % magic squares, all rows columns and diagonals add up to the same thing

[r,c] = find(A >= 7)
r =
  1
  3
  2

c =
  1
  2
  3


sum(A, 1) % sums rows
sum(A, 2) % sums columns
prod
floor
ceil



flipud(A) % flips matrix up down

pinv(A)   % gives the inverse of A


% plotting
t = [0:0.01: 0.98];
y1 = sin(2*pi*4*t);

plot(t, y1);


y2 = cos(2*pi*4*t)
plot(t,y1);
hold on
plot(t,y2);
plot(t,y2, 'r');
xlabel('time')
ylabel('value')
legend('sin', 'cos')
title('my plot')

print -dpng 'myplot.png'
close

figure(1); plot(t,y1);
figure(2); plot(t,y2);
subplot(1,2,1); %divides plot a 1x2 grid access first element
plot(t, y1);
subplot(1,2,2)
plot(t, y2)

clf % clears figure


imagesc(A), colorbar, colormap gray;


% =================================

v = zeros(10,1)

for i = 1:10,
  v(i) = 2^i;
end


indicies = 1:10
for i = indices,
  disp(i);
end;

i = 1;
while i <= 5,
  v(i) = 100;
  i = i+1;
end;

i = 1;
while true,
  v(i) = 999;
  i = i + 1;
  if i == 6,
    break;
  end;
end;


v(1) = 2
if v(1) = 2;
  disp('the value is one');
elseif v(1) == 2,
  disp('the value is true');
else
  disp("the value is not one or two.");
end;


squareThisNumber.m
function y = squareThisNmber(x)
y = x^2;

suareAndCuebeThisNumber.m
function [y1,y2] = squareAndCubeThisNumber(x)
y1 = x^2;
y2 = x^3;


X = [1 1; 1 2; 1 3]
y = [1; 2; 3]

theta = [0;1];

costFunctionJ.m
  function J = costFunctionJ(X, y, theta)

  % X is the 'design matrix' containing our training examples
  % y is the class labels

  m           = size(X, 1)            % number of training examples
  predictions = X*theta;              % predictions of hypothesis on examples
  sqrErrors   = (predictions - y).^2; % squared errors

  J = 1/(2*m) * sum(sqrErrors);


J % => 0



Theta1 = ones(10,11);
Theta2 = ones(10,11);
Theta3 = 3*ones(10,11);

thetaVec = [ Theta1(:); Theta2(:); Theta3(:)];

Theta1 == reshape(thetaVec(1:110), 10, 11)

gradApprox = (J(theta = EPSILON) - J(theta - EPSILON))/(2*EPSILON)

for i = 1:n,
  thetaPlus = theta;
  thetaPlus(i) = thetaPlus(i) + EPSILON;
  thetaMinus = theta;
  thetaMinus(i) = thetaMinus(i) - EPSILON;
  gradApprox(i) = (J(thetaPlus) - J(thetaMinus))/(2*EPSILON);
end

% check that gradApprox ~ DVec

% - implement backprom to compute DVec (unrolled D1, D2, D3)
% - implement numerical gradient check to compute gradApprox
% - make sure they give similar values
% - TURN OFF gradient checking using backprob code for learning with
%   NO gradient checking

optTheta = fminunc(@costFunction, initialTheta, options);

initialTheta = zeros(n,1); % can we do better?

% INIT_EPSILON is unrelated to EPSILON
Theta1 = rand(10,11) * (2*INIT_EPSILON) - INIT_EPSILON;
Theta1 = rand(1,11) * (2*INIT_EPSILON) - INIT_EPSILON;

load('ex3data1.mat');