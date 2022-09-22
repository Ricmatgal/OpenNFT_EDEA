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

% fixation cross
Screen('DrawLines', P.Screen.wPtr, P.Screen.allCoords,...
4, 1, [P.Screen.xCenter P.Screen.yCenter], 2);

P.Task.fixOns(1,P.Task.trialCounter) = Screen('Flip', P.Screen.wPtr);

% fprintf('\nTask Fix Onset!\n')

% re-adjust textsize for response options on screen
Screen('TextSize',P.Screen.wPtr, P.textSizeVAS);


if P.END_run_msg == 0

    if P.VAS_flag == 1

        start_timer = GetSecs;
        vas_timer   = 0;
        waitframes  = 1;

         if P.triggerON
             % Send Trigger Task onset
             outp(P.parportAddr,P.triggers(1));
             % Wait a bit
             WaitSecs(0.05);
             % Close trigger port
             outp(P.parportAddr,0);
         end


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
            DrawFormattedText(P.Screen.wPtr, 'HOW MOTIVATED ARE YOU?', 'center',P.Screen.h * 0.3, [255 255 255]);

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
        P.END_run_msg = 1;

    end

elseif P.END_run_msg == 1
    
     if P.triggerON
         % Send Trigger run offset
         outp(P.parportAddr,P.triggers(5));
         % Wait a bit
         WaitSecs(0.05);
         % Close trigger port
         outp(P.parportAddr,0);
     end

    % Draw end run message to buffer
    DrawFormattedText(P.Screen.wPtr, strcat('THANKS! END OF THE RUN: ',num2str(P.NFRunNr)), 'center','center', [255 255 255]);

    % Flip message to the screen
    Screen('Flip', P.Screen.wPtr);

    % Wait a bit
    % WaitSecs(3)

end

% Assign P struct to base
assignin('base', 'P', P);

% Trial by Trial saving
save([P.WorkFolder, filesep, 'TaskFolder', filesep, 'taskResults', filesep, 'NFB_taskResults_r' num2str(P.NFRunNr)], 'P');

end
