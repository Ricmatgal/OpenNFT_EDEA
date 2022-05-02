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
% Tex = evalin('base', 'Tex');

% fixation cross
Screen('DrawLines', P.Screen.wPtr, P.Screen.allCoords,...
4, 1, [P.Screen.xCenter P.Screen.yCenter], 2);
P.Task.fixOns(1,P.Task.trialCounter) = Screen('Flip', P.Screen.wPtr);
fprintf('\nTask Fix Onset!\n')

% wait a bit
WaitSecs(1)

% re-adjust textsize for response options on screen
Screen('TextSize',P.Screen.wPtr, 28);


if P.END_run_msg == 0

    if P.VAS_flag == 1

        start_timer = GetSecs;
        vas_timer   = 0;
        waitframes  = 1;

%         % Send Trigger Task onset
%         outp(P.parportAddr,P.triggers(8));
%         % wait abit
%         WaitSecs(0.05);
%         % close trigger port
%         outp(P.parportAddr,0);


        %%======== MOTIVATION VAS ===============%%%

        % Loop the animation until the escape key is pressed
        P.Screen.vbl = Screen('Flip', P.Screen.wPtr);
        while vas_timer < P.VAS_duration

            % Check the keyboard to see if a button has been pressed
            [keyIsDown,secs, keyCode] = KbCheck;

            % Depending on the button press,
            if keyCode(P.Screen.leftKey)
                P.X = P.X - P.pixelsPerPress;
            elseif keyCode(P.Screen.rightKey)
                P.X = P.X + P.pixelsPerPress;
            end

            % Boundaries
            if P.X < P.Screen.w/2 - P.HSize(3)/2
                P.X = P.Screen.w/2 - P.HSize(3)/2;
            elseif P.X > P.Screen.w/2 + P.HSize(3)/2
                P.X = P.Screen.w/2 + P.HSize(3)/2;
            end

            % Lines
            Screen('FillRect', P.Screen.wPtr, P.HColor, P.HLine);
            P.VLine = CenterRectOnPointd(P.VSize, P.X, P.Screen.h * 0.6);
            Screen('FillRect', P.Screen.wPtr, P.VColor, P.VLine);

            % Text
            DrawFormattedText(P.Screen.wPtr, 'How motivated are you?', 'center',P.Screen.h * 0.3, [255 255 255]);

            Screen('TextSize', P.Screen.wPtr, 40); %Screen('TextFont', P.Screen.wPtr, 'Courier New');
            DrawFormattedText(P.Screen.wPtr, '0', P.Screen.w * 0.15 , P.Screen.h * 0.61, [255 255 255]);
            Screen('TextSize', P.Screen.wPtr, 40); %Screen('TextFont', P.Screen.wPtr, 'Courier New');
            DrawFormattedText(P.Screen.wPtr, '100', P.Screen.w * 0.85 , P.Screen.h * 0.61, [255 255 255]);

            % Flip to the screen
            P.Screen.vbl=Screen('Flip', P.Screen.wPtr, P.Screen.vbl + (waitframes - 0.5) * P.Screen.ifi);

            % update timer
            vas_timer = GetSecs - start_timer;

        end

        % record motivation score
        P.VAS_score = (P.X-(P.Screen.w-P.HSize(3))/2)/10;

        % set VAS flag to zero so next task blocks will just be the task
        P.VAS_flag = 0;

%     elseif P.VAS_flag == 0

        % ptbTask is triggered but VAS has already been execute
        % If we just had the last trial within our run: mark last task block
%         if P.Task.trialCounter == numel(P.ProtCond{3}) + 1
            % this will trigger the end message right below in the same
            % iteration.
        P.END_run_msg = 1;
%         end

    end

elseif P.END_run_msg == 1

    % Draw end run message to buffer
    DrawFormattedText(P.Screen.wPtr, 'Thanks! End of the RUN', 'center','center', [255 255 255]);

    % Flip message to the screen
%     P.Screen.vbl=Screen('Flip', P.Screen.wPtr);
    Screen('Flip', P.Screen.wPtr);

    % Wait a bit
    WaitSecs(3)

end
% close trigger port
% outp(P.parportAddr,0);

% Assign P struct to base
assignin('base', 'P', P);

% Trial by Trial saving
save([P.WorkFolder, filesep, 'TaskFolder', filesep, 'taskResults', filesep, 'NFB_taskResults_r' num2str(P.NFRunNr)], 'P');

end



% % (re)setting parameters for each trial
% task_text={{{'MALE'},{'FEMALE'}}, {{'HAPPY'} {'SAD'}}};

% % button response counters to direct visualisation of responses
% left_button_count = 0;
% right_button_count = 0;

% % counter to manage responses and adjust display accordingly
% qc=1;
% resp_c = 1;

% % start listening to key input
% KbQueueCreate();
% KbQueueStart();

% % flip once
% P.Screen.vbl = Screen('Flip', P.Screen.wPtr);

% % get trial onset
% P.trialOns(1,P.Task.trialCounter) = GetSecs;
% for ii = 1: P.Screen.nrims

%     waitframes = 1;
%     for frame = 1:P.Screen.numFrames
%         % draw the response options to buffer
%         DrawFormattedText(P.Screen.wPtr, task_text{qc}{1}{1}, P.Screen.xCenter+P.Screen.option_lx,...
%             P.Screen.yCenter+P.Screen.option_ly, [0 0 0]);
%         DrawFormattedText(P.Screen.wPtr, task_text{qc}{2}{1}, P.Screen.xCenter+P.Screen.option_rx,...
%             P.Screen.yCenter+P.Screen.option_ry, [0 0 0]);

%         % Draw the image to buffer
%         Screen('DrawTexture', P.Screen.wPtr,  Tex(P.Task.trialCounter,ii));

%         % Flip the screen
%         P.Screen.vbl = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + (waitframes - 0.5) * P.Screen.ifi);
%     end

%     % Start recording and evaluating responses. In this example, responses
%     % are evaluated after every image displayed. As this is a highly simplified
%     % version of a real task it makes less sense in its current form.
%     [pressed, firstPress]=KbQueueCheck();
%     if pressed && resp_c < 3
%          % first response male
%          if firstPress(P.Screen.leftKey) && resp_c == 1
%              % record type, frame and time of response
%              P.Task.responses.answer{1,P.Task.trialCounter} = 'male';
%              P.Task.responses.detection_frame(1,P.Task.trialCounter)=ii;
%              P.Task.responses.timing(1,P.Task.trialCounter) = GetSecs;

%              % update counters
%              left_button_count = 1;
%              qc = 2;
%              resp_c = resp_c+1;

%              % second response happy (left)
%              elseif firstPress(P.Screen.leftKey) && resp_c == 2
%                  P.Task.responses.answer{2,P.Task.trialCounter} = 'happy';
%                  P.Task.responses.detection_frame(2,P.Task.trialCounter)=ii;
%                  P.Task.responses.timing(2,P.Task.trialCounter) = GetSecs;

%                  task_text{qc}{2}{1} = '';
%                  resp_c = resp_c+1;
%              % second response sad (right)
%              elseif firstPress(P.Screen.rightKey) && resp_c == 2
%                  P.Task.responses.answer{2,P.Task.trialCounter} = 'sad';
%                  P.Task.responses.detection_frame(2,P.Task.trialCounter)=ii;
%                  P.Task.responses.timing(2,P.Task.trialCounter) = GetSecs;

%                  task_text{qc}{1}{1} = '';
%                  resp_c = resp_c+1;

%          % first response female
%          elseif firstPress(P.Screen.rightKey) && resp_c == 1
%              P.Task.responses.answer{1,P.Task.trialCounter} = 'female';
%              P.Task.responses.detection_frame(1,P.Task.trialCounter)=ii;
%              P.Task.responses.timing(1,P.Task.trialCounter) = GetSecs;

%              right_button_count = 1;
%              qc = 2;
%              resp_c = resp_c+1;

%             % second response happy (left)
%              elseif firstPress(P.Screen.leftKey) && resp_c == 2
%                  P.Task.responses.answer{2,P.Task.trialCounter} = 'happy';
%                  P.Task.responses.detection_frame(2,P.Task.trialCounter)=ii;
%                  P.Task.responses.timing(2,P.Task.trialCounter) = GetSecs;

%                  task_text{qc}{2}{1} = '';
%                  resp_c = resp_c+1;
%              % second response sad (right)
%              elseif firstPress(P.Screen.rightKey) && resp_c == 2
%                  P.Task.responses.answer{2,P.Task.trialCounter} = 'sad';
%                  P.Task.responses.detection_frame(2,P.Task.trialCounter)=ii;
%                  P.Task.responses.timing(2,P.Task.trialCounter) = GetSecs;

%                  task_text{qc}{1}{1} = '';
%                  resp_c = resp_c+1;

%          % if no response we break the loop after the last image of
%          % the trial was displayed
%          elseif ii == P.Screen.numFrames
%                  P.Task.responses.answer{1,trial} = 'no resp';
%                  P.Task.responses.detection_frame(1,P.Task.trialCounter)=NaN;
%                  P.Task.responses.detection_frame(2,P.Task.trialCounter)=NaN;
%                  P.Task.responses.timing(1,P.Task.trialCounter) = NaN;
%                  P.Task.responses.timing(2,P.Task.trialCounter) = NaN;
%             break
%          end
%     end
% end

% % update trial counter
% P.Task.trialCounter = P.Task.trialCounter +1;
% assignin('base', 'P', P);

% % fixation cross for the remainder of the task block
% Screen('DrawLines', P.Screen.wPtr, P.Screen.allCoords,...
% 4, 1, [P.Screen.xCenter P.Screen.yCenter], 2);
% Screen('Flip', P.Screen.wPtr);

% end
