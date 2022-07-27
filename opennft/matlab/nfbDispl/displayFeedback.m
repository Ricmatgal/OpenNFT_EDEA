function displayFeedback(displayData)
% Function to display feedbacks using PTB functions
%
% input:
% displayData - input data structure
%
% Note, synchronization issues are simplified, e.g. sync tests are skipped.
% End-user is advised to configure the use of PTB on their own workstation
% and justify more advanced configuration for PTB.
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% Written by Yury Koush, Artem Nikonorov

tDispl = tic;

P = evalin('base', 'P');
%Tex = evalin('base', 'Tex');

% Note, don't split cell structure in 2 lines with '...'.
fieldNames = {'feedbackType', 'condition', 'dispValue', 'Reward', 'displayStage','displayBlankScreen', 'iteration'};
defaultFields = {'', 0, 0, '', '', '', 0};
% disp(displayData)
eval(varsFromStruct(displayData, fieldNames, defaultFields))

if ~strcmp(feedbackType, 'DCM')
    dispColor = [255, 255, 255];
    instrColor = [155, 150, 150];
end

% If we are in sham mode, and a yok subject is selected, we use the shame
% data for the whole routine, i.e. we update the dispvalue
if isfield(P, 'shamData')
    dispValue = cell2mat(P.shamData(iteration-P.nrSkipVol));
    rawDispV = cell2mat(P.shamDataRaw(1:iteration-P.nrSkipVol));
    rawDispV = rawDispV(rawDispV>0);
    rawDisp_s = sort(rawDispV(1:end-1), 'descend');

else
    % if its not a sham nfb we retrieve the subject specific
    % rawdisplay values as saved in the displayData structure.
    rawDispV = displayData.rawDispValues;
    rawDisp_s = sort(rawDispV(displayData.rawDispValues>0), 'descend');

end

% % adjust the limits
% P.limLow = min(displayData.rawDispValues(displayData.rawDispValues>0));
% P.limUp = max(displayData.rawDispValues(displayData.rawDispValues>0));






switch feedbackType
    %% Continuous PSC
    case 'bar_count'
        dispValue  = dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;
        switch condition
            case 1 % Baseline
                % Text "COUNT"
                Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
                Screen('DrawText', P.Screen.wPtr, 'COUNT', ...
                    floor(P.Screen.w/2-P.Screen.h/4), ...
                    floor(P.Screen.h/2-P.Screen.h/10), instrColor);
            case 2 % Regualtion
                % Fixation Point
                Screen('FillOval', P.Screen.wPtr, [255 255 255], ...
                    [floor(P.Screen.w/2-P.Screen.w/200), ...
                    floor(P.Screen.h/2-P.Screen.w/200), ...
                    floor(P.Screen.w/2+P.Screen.w/200), ...
                    floor(P.Screen.h/2+P.Screen.w/200)]);
                % draw target bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
                    P.Screen.lw, [255 0 0]);
                % draw activity bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/2-dispValue), ...
                    floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]);
        end
        P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
            P.Screen.vbl + P.Screen.ifi/2);
    
    % %% Continuous PSC with task block
    % case 'bar_count_task'
    %     dispValue  = dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;
    %     switch condition
    %         case 1 % Baseline
    %             % Text "COUNT"
    %             Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
    %             Screen('DrawText', P.Screen.wPtr, 'COUNT', ...
    %                 floor(P.Screen.w/2-P.Screen.h/4), ...
    %                 floor(P.Screen.h/2-P.Screen.h/10), instrColor);
                
    %              P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
    %                  P.Screen.vbl + P.Screen.ifi/2);
                
    %         case 2 % Regualtion
    %             % Fixation Point
    %             Screen('FillOval', P.Screen.wPtr, [255 255 255], ...
    %                 [floor(P.Screen.w/2-P.Screen.w/200), ...
    %                 floor(P.Screen.h/2-P.Screen.w/200), ...
    %                 floor(P.Screen.w/2+P.Screen.w/200), ...
    %                 floor(P.Screen.h/2+P.Screen.w/200)]);
    %             % draw target bar
    %             Screen('DrawLines', P.Screen.wPtr, ...
    %                 [floor(P.Screen.w/2-P.Screen.w/20), ...
    %                 floor(P.Screen.w/2+P.Screen.w/20); ...
    %                 floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
    %                 P.Screen.lw, [255 0 0]);
    %             % draw activity bar
    %             Screen('DrawLines', P.Screen.wPtr, ...
    %                 [floor(P.Screen.w/2-P.Screen.w/20), ...
    %                 floor(P.Screen.w/2+P.Screen.w/20); ...
    %                 floor(P.Screen.h/2-dispValue), ...
    %                 floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]);
                
    %                 P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
    %                     P.Screen.vbl + P.Screen.ifi/2);
    %         case 3
    %             % ptbTask sequence called seperetaly in python
                
    %     end

        %%===================== Type of feedback we use ===============================================%%
        %% Continuous PSC with task block
    case 'bar_count_task'

        switch condition

            case 2 % Baseline

                % Send Trigger Baseline
                % outp(P.parportAddr,P.triggers(1))


                P.k_eq = P.k_eq + 1; % update the equation index
                P.K_rot = P.K_rot + 1; % update the wheel orientation index

                
                Screen('TextSize',P.Screen.wPtr,P.textSizeBAS);

                Screen('DrawTextures', P.Screen.wPtr, P.wheelTex, [],...
                    P.dstRects(:, 1:2), P.rotation_angle_BAS(P.K_rot),[],[]); % need to adjust the rotation angle update

                DrawFormattedText(P.Screen.wPtr, P.strings_operation{P.k_eq}, 'center','center', P.Screen.white);
                
                Screen('Flip',P.Screen.wPtr);


            case 3 % Regulation
                
                fprintf('Feedback Value from nfbCalc: %f \n',dispValue);

                P.test.visit_case2(end+1) = now;

                % If current iteration is greater than the last
                % iteration we update the NFB. This is, because this
                % function is visited multiple times during the
                % acquisition of a volume. If we are still in the same
                % volume we don't want an update on the speed.
                if iteration > P.NFBC.it_curr(end)

                    % send Trigger Regulation
                    % outp(P.parportAddr,P.triggers(2))
                    
                    nFirstBasVolumes = max(P.ProtCond{2}{1});
                    NfirstVolumes = 10;
                    if (length(rawDispV) - nFirstBasVolumes > 1 && length(rawDispV) - nFirstBasVolumes <= NfirstVolumes)
                        if max(rawDisp_s) > P.limUp
                            P.limUp   = rawDisp_s(1);
                        elseif min(rawDisp_s) <  P.limLow
                            P.limLow  = rawDisp_s(end);
                        end
                    elseif length(rawDispV) - nFirstBasVolumes > NfirstVolumes
                        P.limLow  = min(rawDisp_s);
                        P.limUp   = max(rawDisp_s);
                    end



                    % Adaptive Feedback display for differential PSC, scaled according to limits (limlow, limup) of brain activity and steps
                    % and using a logarithmic scale

                    logTest = 1;
                    tanhTest = 1;

                    if ~logTest

                    %if blockNF > 1
                        
                        dispValue = ((dispValue - P.limLow) / (P.limUp - P.limLow)) * (P.stepMax - P.stepMin) + P.stepMin;
                    
                    %end

                    else
                        
                        %if blockNF > 1

                            dispValue = ((dispValue - P.limLow) / (P.limUp - P.limLow)); % we normalize according to own min and max activity

                        %end

                        fprintf('Feedback Value from nfbCalc after scaling: %f with lims: %f, %f  \n',dispValue,P.limLow,P.limUp);
                        P.scaledDispVal(iteration-P.nrSkipVol) = dispValue;
                        


                        % let's try with the log, values are normalized between -1 and 1.
                        % so we scale by 10 in order that we do not have values below 0
                        % then we take the log of the absolute value and assign a sign
                        % log e and log 2 allows a higher maximum speed


                        if ~ tanhTest

                        while dispValue > -1 && dispValue < 1
                            dispValue = dispValue * 10;
                        end
    
                            if dispValue > 0
                                dispValue = log2(dispValue);
                            elseif dispValue < 0
                                dispValue = -log2(abs(dispValue));
                            else
                                dispValue = 0;
                            end

                        else

                            dispValue = tanh(dispValue)*10; % fit inside a tahn function for smoothing and upscaling

                        end

                    end


                    % we get the rotation value for the wheel
                    P.rotSpe  = dispValue;
                    fprintf('Feedback value given to the wheel: %s \n',dispValue)
                    P.finalDispVal(iteration-P.nrSkipVol) = dispValue;


                else

                    % if we are still within the same volume we keep
                    % the rotation speed as is.
                    P.rotSpe  = P.rotSpe;

                end

                % This loop makes sure we keep rotating within the
                % acquisition of one volume. This to make the rotation
                % movements smooth rather than intermitted (update each
                % new volume only). Ideally we want the number of
                % iterations and the time that that takes to be as
                % close as possible to the acquition time but NOT
                % longer.
                tic
                

                % change color according to the rotation speed value
                % (>0 good job, <0 wrong), direction of rotation is
                % taken care of later, the rotation speed comes from the nfbCalc V1 right/V1 left routine
                if P.rotSpe > 0 % green
                    fixCol = [0, 128, 0];
                elseif P.rotSpe < 0 % red
                    fixCol = [255, 0, 0];
                elseif P.rotAng == 0 || P.TRANSF == 1
                    % if no movement, fixation cross is white
                    fixCol = P.Screen.white;
                end

                wheelAngles = [];

                % Draw the wheels and rotate them
                times2repeat = ceil(((double(P.TR)/1000)/2)/(P.Screen.numFrames*P.Screen.ifi));
                for ii = 1:times2repeat

                    % Here we carefully control for how many frames we
                    % display each flip. numFrames is defines in
                    % ptbPreperation.m

                    waitframes = 1;
                    for frame = 1:P.Screen.numFrames

                        % depending whether we have checked the transfer run box in
                        % the GUI we will either let everything run as
                        % usual OR we fix the wheel rotation to 0 and
                        % the fixation cross color to white.

                        if P.TRANSF == 0
                            
                            % intialize the wheels according to the specific angle
                            fvol = cellfun(@(x) x(1) == (iteration-P.nrSkipVol), P.ProtCond{3});
                            if any(fvol)
                                P.rotAng = P.rotation_angle_BAS(P.K_rot);
                                P.rotSpe = 0;
                                fixCol = P.Screen.white;
                            end

                            Screen('DrawTextures', P.Screen.wPtr, P.wheelTex, [],...
                                P.dstRects(:, 1:2), P.rotAng, [], []);
                            % fixation cross while regulation
                            Screen('DrawLines', P.Screen.wPtr, P.Screen.allCoords,...
                            P.Screen.lineWidthPix, fixCol, [P.Screen.xCenter P.Screen.yCenter], 2); % last arguments is the smoothing

                            % cue while regulation
                            % Screen('TextSize',P.Screen.wPtr,120);
                            % if P.V1_left == 1 % need to point to the right hemifield, therefore increasing left V1
                            %     DrawFormattedText(P.Screen.wPtr,'> + >','center','center',fixCol);
                            % else % viceversa
                            %     DrawFormattedText(P.Screen.wPtr,'< + <','center','center',fixCol);
                            % end

                        elseif P.TRANSF == 1
                            Screen('DrawTextures', P.Screen.wPtr, P.wheelTex, [],...
                                P.dstRects(:, 1:2), 0, [], []);
                            Screen('DrawLines', P.Screen.wPtr, P.Screen.allCoords,...
                            P.Screen.lineWidthPix, P.Screen.white, [P.Screen.xCenter P.Screen.yCenter], 2);
                        end

                        P.Screen.vbl = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + (waitframes - 0.5) * P.Screen.ifi);
                    end

                    % Increment the angle if rotation is clockwise
                    % Decrement the angle if rotation is counter clockwise
                    if P.leftRot == 1
                        P.rotAng = P.rotAng - P.rotSpe;
                    elseif P.rightRot == 1
                        P.rotAng = P.rotAng + P.rotSpe;
                    end
                    
                    wheelAngles(end+1) = P.rotAng; % updated the wheelAngles list to store info

                end

                P.test.time_displFBloop(end+1) = toc;

                % Record the iteration
                P.NFBC.it_curr(end+1)= iteration;


                P.PtbCallIdx = P.PtbCallIdx + 1;
                P.WheelAnglesStruct(iteration).Iteration(P.PtbCallIdx).PtbScreenCall = wheelAngles;

                if P.PtbCallIdx == 2
                    P.PtbCallIdx = 0;
                end


            case 1
                % ptbTask.m sequence called separately in python (VAS)


            case 4 % intermittent score (final value after regulation block)
                
                % this is calculated in nfbCalc already
                % dispValue = ceil((sum(P.finalDispVal(P.ProtCond{3}{displayData.currNFblock})) / P.stepMax) * 10);
                %P.sumFBscore(iteration-P.nrSkipVol) = dispValue;

                % but if we want to take the P.finalDispVal then..
                % dispValue = (round(mean(P.finalDispVal(P.ProtCond{3}{displayData.currNFblock}))...
                %    *100)/max(P.finalDispVal(P.ProtCond{3}{displayData.currNFblock})));
                
                % rescaling the P.finalDispVal vector (rotation speed) from 0 to
                % 100 for the precedent NF block, then taking the mean
                % (i.e. giving a score 0-100 of how good they performed)
                
                minRescale = -10;
                maxRescale = 10;
                dispValue = round(mean(rescale(P.finalDispVal(P.ProtCond{3}{displayData.currNFblock}),minRescale,maxRescale)));
                P.sumFBscore(iteration-P.nrSkipVol) = dispValue;

                k = cellfun(@(x) x(2) == (iteration-P.nrSkipVol), P.ProtCond{4});
                % if onset volume: show fixation cross (currently dispValue still
                % contains the last contNF value, this will be updated after
                % the acquisition of the first Sum volume).
                if any(k)

                    % trigger for FB
                    % outp(P.parportAddr,P.triggers(6))

                    % Total Score center message
                    Screen('TextSize',P.Screen.wPtr,50);
                    DrawFormattedText(P.Screen.wPtr, 'Total Score: ','center', 'center', P.Screen.white);
                    % if regular run:
                    if P.TRANSF == 0
                        % feedback value
                        Screen('TextSize',P.Screen.wPtr,P.textSizeSUM);
                        DrawFormattedText(P.Screen.wPtr, mat2str(dispValue), ...
                            'center',  P.Screen.h * 0.65, P.Screen.white);
                        % if transfer run:
                    elseif P.TRANSF == 1
                        DrawFormattedText(P.Screen.wPtr, 'XXX',...
                            'center', P.Screen.h * 0.65, P.Screen.white);
                    end
                    % record onset event
                    if size(P.Onsets.SumFB_fix,2) < P.Task.trialCounter
                        P.Onsets.SumFB_fix(1,P.Task.trialCounter) = Screen('Flip', P.Screen.wPtr);
                    else
                        Screen('Flip', P.Screen.wPtr);
                    end

                end

                % Add trial number to keep count.
                k = cellfun(@(x) x(end) == (iteration-P.nrSkipVol), P.ProtCond{4});
                if any(k)
                    P.Task.trialCounter = find(k==1)+1;
                end
        end

        
    %% Intermittent PSC
case 'value_fixation'
        indexSmiley = round(dispValue);
        if indexSmiley == 0
            indexSmiley = 1;
        end
        switch condition
            case 1  % Baseline
                for i = 1:2
                    % fixation
                    Screen('FillOval', P.Screen.wPtr, ...
                        [randi([50,200]) 0 0], P.Screen.fix+[0 0 0 0]);
                    % dots
                    Screen('DrawDots', P.Screen.wPtr, P.Screen.xy, ...
                        P.Screen.dsize, P.Screen.dotCol,P.Screen.db,0);
                    % display
                    P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
                        P.Screen.vbl + P.Screen.ifi/2);
                    % flickering
                    if 1
                        pause(randi([30,100])/1000)
                    end
                end
                
            case 2  % Regulation
                for i = 1:2
                    % arrow
                    Screen('FillRect',P.Screen.wPtr, instrColor, ...
                        P.Screen.arrow.rect + [0 0 0 0]);
                    Screen('FillPoly',P.Screen.wPtr, instrColor, ...
                        P.Screen.arrow.poly_right + [0 0; 0 0; 0 0]);
                    Screen('FillPoly',P.Screen.wPtr, instrColor, ...
                        P.Screen.arrow.poly_left + [0 0; 0 0; 0 0]);
                    % fixation
                    Screen('FillOval', P.Screen.wPtr, ...
                        [randi([50,200]) 0 0], P.Screen.fix+[0 0 0 0]);
                    % dots
                    Screen('DrawDots', P.Screen.wPtr, P.Screen.xy, ...
                        P.Screen.dsize, P.Screen.dotCol, P.Screen.db,0);
                    % display
                    P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                        P.Screen.vbl + P.Screen.ifi/2);
                    % basic flickering given TR
                    if 1
                        pause(randi([30,100])/1000);
                    end
                end
                
            case 3 % NF
                % feedback value
                Screen('DrawText', P.Screen.wPtr, mat2str(dispValue), ...
                    P.Screen.w/2 - P.Screen.w/30+0, ...
                    P.Screen.h/2 - P.Screen.h/4, dispColor);
                % smiley
                Screen('DrawTexture', P.Screen.wPtr, ...
                    Tex(indexSmiley), ...
                    P.Screen.rectSm, P.Screen.dispRect+[0 0 0 0]);
                % display
                P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl + P.Screen.ifi/2);
        end
        
    %% Trial-based DCM
    case 'DCM'
        nrP = P.nrP;
        nrN = P.nrN;
        imgPNr = P.imgPNr;
        imgNNr = P.imgNNr;
        switch condition
            case 1 % Neutral textures
                % Define texture
                nrP = 0;
                nrN = nrN + 1;
                if (nrN == 1) || (nrN == 5) || (nrN == 9)
                    imgNNr = imgNNr + 1;
                    disp(['Neut Pict:' mat2str(imgNNr)]);
                end
                if nrN < 5
                    basImage = Tex.N(imgNNr);
                elseif (nrN > 4) && (nrN < 9)
                    basImage = Tex.N(imgNNr);
                elseif nrN > 8
                    basImage = Tex.N(imgNNr);
                end
                % Draw Texture
                Screen('DrawTexture', P.Screen.wPtr, basImage);
                P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl+P.Screen.ifi/2);

            case 2 % Positive textures
                % Define texture
                nrN = 0;
                nrP = nrP + 1;
                if (nrP == 1) || (nrP == 5) || (nrP == 9)
                    imgPNr = imgPNr + 1;
                    disp(['Posit Pict:' mat2str(imgPNr)]);
                end
                if nrP < 5
                    dispImage = Tex.P(imgPNr);
                elseif (nrP > 4) && (nrP < 9)
                    dispImage = Tex.P(imgPNr);
                elseif nrP > 8
                    dispImage = Tex.P(imgPNr);
                end
                % Draw Texture
                Screen('DrawTexture', P.Screen.wPtr, dispImage);
                P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl+P.Screen.ifi/2);

            case 3 % Rest epoch
                % Black screen case is called seaprately in Python to allow
                % using PTB Matlab Helper process for DCM model estimations

            case 4 % NF display
                nrP = 0;
                nrN = 0;
                % red if positive, blue if negative
                if dispValue >0
                    dispColor = [255, 0, 0];
                else
                    dispColor = [0, 0, 255];
                end
                % instruction reminder
                Screen('DrawText', P.Screen.wPtr, 'UP', ...
                    P.Screen.w/2 - P.Screen.w/15, ...
                    P.Screen.h/2 - P.Screen.w/8, [255, 0, 0]);
                % feedback value
                Screen('DrawText', P.Screen.wPtr, ...
                    ['(' mat2str(dispValue) ')'], ...
                    P.Screen.w/2 - P.Screen.w/7, ...
                    P.Screen.h/2 + P.Screen.w/200, dispColor);
                % monetary reward value
                Screen('DrawText', P.Screen.wPtr, ['+' Reward 'CHF'], ...
                    P.Screen.w/2 - P.Screen.w/7, ...
                    P.Screen.h/2 + P.Screen.w/7, dispColor);
                P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl + P.Screen.ifi/2);
                % basic flickering given TR
                if 1
                    pause(randi([600,800])/1000);
                    P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                        P.Screen.vbl + P.Screen.ifi/2);
                end
        end
        P.nrP = nrP;
        P.nrN = nrN;
        P.imgPNr = imgPNr;
        P.imgNNr = imgNNr;
end

% EventRecords for PTB
% Each event row for PTB is formatted as
% [t9, t10, displayTimeInstruction, displayTimeFeedback]
t = posixtime(datetime('now','TimeZone','local'));
tAbs = toc(tDispl);
if strcmp(displayStage, 'instruction')
    P.eventRecords(1, :) = repmat(iteration,1,4);
    P.eventRecords(iteration + 1, :) = zeros(1,4);
    P.eventRecords(iteration + 1, 1) = t;
    P.eventRecords(iteration + 1, 3) = tAbs;
elseif strcmp(displayStage, 'feedback')
    P.eventRecords(1, :) = repmat(iteration,1,4);
    P.eventRecords(iteration + 1, :) = zeros(1,4);
    P.eventRecords(iteration + 1, 2) = t;
    P.eventRecords(iteration + 1, 4) = tAbs;
end

%recs = P.eventRecords;
%save(P.eventRecordsPath, 'recs', '-ascii', '-double');

save([P.WorkFolder, filesep, 'TaskFolder', filesep, 'taskResults', filesep, 'displayFeedback_r' num2str(P.NFRunNr)], 'P')

% close trigger port
% outp(P.parportAddr,0);

assignin('base', 'P', P);
