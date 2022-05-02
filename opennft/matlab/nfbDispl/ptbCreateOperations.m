% Helper function for displayFeedback() to create mental operation for the baseline part of the NF run

function [strings_operation] = ptbCreateOperations(neqs)

a = 0; b = 10; % range from -100 to 100;

% how many numbers per equation?

n1 = randi([a,b],1,neqs);
n2 = randi([a,b],1,neqs);
n3 = randi([a,b],1,neqs);
% n4 = randi([a,b],1,neqs);

% concatenate the numbers
numbs= [n1; n2; n3];

% make indexes for numbers randomization
idx_numbs= randi([1,neqs],3,neqs);

% how many possible different operators per equation?
operators = ['-', '+'];

% make indexes for operators randomization
idx_oper= randi([1,numel(operators)],size(numbs,1)-1,neqs);

% initialize operation strings
strings_operation = cell(0);

% main routine

    for run = 1:neqs

        strings_operation{run} = [' ', num2str(numbs(1,idx_numbs(1,(run)))), ' ', operators(idx_oper(1,(run))), ...
            ' ', num2str(numbs(2,idx_numbs(2,(run)))), ' ', operators(idx_oper(2,(run))), ...
            ' ', num2str(numbs(3,idx_numbs(3,(run))))];
    end
end