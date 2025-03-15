function ptbTask()

% Scanner PTB task function. This function can be used when you want to
% implement a task condition in addition to the NFB (baseline and
% feedback).It corresponds to condition 3 from the json file and is called
% only once at the onset of a task block. In this sense ptbdisplay is
% temporarily uncoupled from the incoming data which allows you to flip the
% screen many times and record subject responses without interruption.

% Below you  can implement any stimulation using psychtoolbox functions,
% just make sure that your parameters are defined in the ptbPreperation
% function and that the duration of your stimulation doesn't exceed the
% time specified in your json file.
%__________________________________________________________________________
%
% Written by Lucas Peek (lucaspeek@live.nl)

P   = evalin('base', 'P');

% Assign P struct to base
assignin('base', 'P', P);

% Trial by Trial saving
save([P.WorkFolder, filesep, 'TaskFolder', filesep, 'taskResults', filesep, 'NFB_taskResults_r' num2str(P.NFRunNr)], 'P');

end
