function [theta, J_history] = gradientDescentMulti(X, y, theta, alpha, numberOfIterations)
%GRADIENTDESCENTMULTI Performs gradient descent to learn theta
%   theta = GRADIENTDESCENTMULTI(x, y, theta, alpha, numberOfIterations) updates theta by
%   taking numberOfIterations gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
J_history = zeros(numberOfIterations, 1); 

for iteration = 1:numberOfIterations
    % Perform a single gradient step on the parameter vector theta. 

    % we minimize the value of J(theta) by changing the values of the 
    % vector theta NOT changing X or y

    % alpha = learning rate as a single number

    % hypothesis = mx1 column vector
    % X = mxn matrix
    % theta = nx1 column vector
    hypothesis = X * theta;

    % errors = mx1 column vector
    % y = mx1 column vector
    errors = hypothesis .- y;

    newDecrement = (alpha * (1/m) * errors' * X); 
    
    theta = theta - newDecrement';

    % Save the cost J in every iteration    
    J_history(iteration) = computeCostMulti(X, y, theta);

end

end
