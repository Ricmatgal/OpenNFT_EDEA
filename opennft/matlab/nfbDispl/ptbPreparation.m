function ptbPreparation(screenId, workFolder, protName)
% Function to prepare PTB parameters to use them during setup and
% run-time within the Matlab Helper process.
%
% input:
% screenId   - screen number from GUI ('Display Feedback on')
% workFolder - path to work folder to get the Settings and picture sets to
%              load
% protName   - name of the neurofeedback protocol from GUI
%
% output:
% Output is assigned to workspace variables.
%
% Note, synchronization issues are simplified, e.g. sync tests are skipped.
% End-user is advised to configure the use of PTB on their own workstation
% and justify more advanced configuration for PTB.
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% Written by Yury Koush

P = evalin('base', 'P');

Screen('CloseAll');
Screen('Preference', 'SkipSyncTests', 2);

if ~ismac
    % Because this command messes the coordinate system on the Mac OS
    Screen('Preference', 'ConserveVRAM', 64);
end

AssertOpenGL();

myscreens = Screen('Screens');
if length(myscreens) == 3
    % two monitors: [0 1 2]
    % screenid = myscreens(screenId + 1);
    screenid = 1;
elseif length(myscreens) == 2
    % one monitor: [0 1]
    screenid = myscreens(screenId);
else
    % if different, configure your mode
    screenid = 0;
end

screenid = 2;
fFullScreen = P.DisplayFeedbackFullscreen;

if ~fFullScreen
    % part of the screen, e.g. for test mode
    if strcmp(protName, 'Cont')
        P.Screen.wPtr = Screen('OpenWindow', screenid, [0 0 0], ...
            [40 40 640 520]);
    else
        P.Screen.wPtr = Screen('OpenWindow', screenid, [0 0 0], ...
            [40 40 720 720]);
    end
else
    % full screen
    P.Screen.wPtr = Screen('OpenWindow', screenid, [0 0 0]);
end

[w, h] = Screen('WindowSize', P.Screen.wPtr);
P.Screen.ifi = Screen('GetFlipInterval', P.Screen.wPtr);

% settings
P.Screen.vbl=Screen('Flip', P.Screen.wPtr);
P.Screen.h = h;
P.Screen.w = w;
P.Screen.lw = 10;

% Text presentation specs
P.Font = 'Geneva';
P.textSizeVAS = 30;
P.textSizeBAS = 60;
P.textSizeNF = 10; % width of the fixation cross while regulating
P.textSizeSUM = 100;

% Text "HELLO" - also to check that PTB-3 function 'DrawText' is working
Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
Screen('DrawText', P.Screen.wPtr, 'HELLO', ...
    floor(P.Screen.w/2-P.Screen.h/6), ...
    floor(P.Screen.h/2-P.Screen.h/10), [200 200 200]);
P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);

pause(1);

% Each event row for PTB is formatted as
% [t9, t10, displayTimeInstruction, displayTimeFeedback]
P.eventRecords = [0, 0, 0, 0];

%% PSC
if strcmp(protName, 'Cont')
    % fixation
    P.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
    Screen('FillOval', P.Screen.wPtr, [255 255 255], P.Screen.fix);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
    Tex = struct;
end

if strcmp(protName, 'ContTask')

    % -----------------------------------------------------------
    % ----------------------- PHYSIOLOGY ------------------------
    % -----------------------------------------------------------
    % Initialize the inpout32.dll I/O driver:
%     config_io;
%     % Set condition code to zero:
%     outp(57392, 0);
%     % Set automatic BIOPAC and eye tracker recording to "stop":
%     outp(57394, bitset(inp(57394), 3, 0));
%     % Close pneumatic valve:
%     outp(57394, bitset(inp(57394), 4, 1));
%
%     usingMRI = 1;
%     if usingMRI
%         P.parportAddr = hex2dec('2FD8');
%     else
%         P.parportAddr = hex2dec('378');
%     end

    % Define Triggers
    % 3 = VAS onset, 64 = motivation probe, 1 = Baseline, 2 = Regulation
    % 4 = Task, 8 = Detection, 16 = Recognition, 32 = SumFB, 5 = run
    % offset;
    P.triggers = [1, 2, 4, 8, 16, 32, 64, 3, 5];

    % -----------------------------------------------------------
    % -----------------------------------------------------------


    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', P.Screen.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Retreive the maximum priority number
    P.Screen.topPriorityLevel = MaxPriority(P.Screen.wPtr);
    
    % fixation cross settings
    P.Screen.fixCrossDimPix = 40;
    
    % Set the line width for fixation cross
    P.Screen.lineWidthPix = 8;

    % Setting the coordinates
    P.Screen.wRect = [0, 0, P.Screen.w, P.Screen.h];
    [P.Screen.xCenter, P.Screen.yCenter] = RectCenter(P.Screen.wRect);
    P.Screen.xCoords = [-P.Screen.fixCrossDimPix P.Screen.fixCrossDimPix 0 0];
    P.Screen.yCoords = [0 0 -P.Screen.fixCrossDimPix P.Screen.fixCrossDimPix];
    P.Screen.allCoords = [P.Screen.xCoords; P.Screen.yCoords];

    
    % scramble-image presentation parameters
    P.Screen.numSecs = P.Screen.ifi*2;     % presentation dur in sec (500ms)
    P.Screen.numFrames = round(P.Screen.numSecs / P.Screen.ifi);    % in frames
    
    % get some color information
    P.Screen.white = WhiteIndex(screenid);
    P.Screen.black = BlackIndex(screenid);
    P.Screen.grey  = P.Screen.white / 2;

    % response option coords on the x and y axis relative to center
    P.Screen.option_lx = -350;    % left option     x
    P.Screen.option_rx = 250;     % right option    x
    P.Screen.option_ly = 400;     % left option     y
    P.Screen.option_ry = 400;     % right option    y
    
    % accepted response keys
    P.Screen.leftKey = KbName('1!');
    P.Screen.rightKey = KbName('2@');

    % show initial fixation dot
    P.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
    Screen('FillOval', P.Screen.wPtr, [255 255 255], P.Screen.fix);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);

    
    %% Cecilia Task Parameters
    P.nrEqBlock = 3;
    P.nrAnglesBlock = 2;
    P.nrEq      = length(P.ProtCond{2})*P.nrEqBlock; % number of blocks which requires the equations to be generated for
    P.nrDigits = 2; % how many digits per equation?
    % (all baseline blocks - 2 per baseline block)
    P.nrFigs    = 2; % number of textures on screen
    P.dim       = 100; % Texture dimensions
    P.yPos      = P.Screen.yCenter;
    P.xPos      = linspace(w * 0.15, w * 0.85, P.nrFigs);
    P.strings_operation = repelem(ptbCreateOperations(P.nrEq, P.nrDigits),ceil(length(P.ProtCond{2}{1})*2/P.nrEqBlock)); % times 2 because function visited twice
    list_angles = 360/length(P.ProtCond{2}):360/length(P.ProtCond{2}):360;
    P.rotation_angle_BAS = repelem(list_angles(randperm(length(list_angles))),floor(length(P.ProtCond{2}{1})*2/P.nrAnglesBlock)); % times 2 because function visited twice
    P.K_rot = 0;
    P.k_eq = 0;
    P.rotAng = 0;
    P.rotSpe = 0;
    % we have to double the amount of strings operation and rotation angles BAS that we should need because the diplay function is called twice durin each iteration

    %  hemifield and wheel parameters
    if P.rightRot == 1
        P.WheelRot = 'right';
    elseif P.leftRot == 1
        P.WheelRot = 'left';
    end

    if P.V1_right == 1
        P.TargetSide = 'right';
    elseif P.V1_left == 1
        P.TargetSide = 'left';
    end

    % struct to iteratively save wheel angles during NFB
    P.PtbCallIdx = 0;
    P.WheelAnglesStruct.Iteration.PtbScreenCall = struct;


    %% Double blind parameters import

    % get the ID and gender, either to write the list, or to do the
    % matchings
    

    if any(strcmp('DoubleBlindDir',fieldnames(P))) && P.DoubleBlindCheck == 0 % we are not in double blind mode

            groupID = 'Exp';
            availability = 'V';
            yokedOn = 'None';
            BufferSub = [];

        if ~isfile([P.DoubleBlindDir filesep 'LiveList.mat']) % if the file has not still been created
            
            sub_row = {strcat(P.SubjectID),strcat(P.SubGender), P.TargetSide,P.WheelRot,groupID,availability,yokedOn,BufferSub}; % create the new row
            LiveList = cell2table(sub_row); % initialize a table
            LiveList.Properties.VariableNames = {'subID','Sex','TargetSide','WheelRot','groupID','Availability','yokedOn','BufferSub'};
            save([P.DoubleBlindDir filesep 'LiveList.mat'],'LiveList'); % save the table

        elseif isfile([P.DoubleBlindDir filesep 'LiveList.mat']) % if the file already exist

            load([P.DoubleBlindDir filesep 'LiveList.mat'],'LiveList') % load the table
            sub_row = {strcat(P.SubjectID),strcat(P.SubGender), P.TargetSide,P.WheelRot,groupID,availability,yokedOn,BufferSub}; % create the new row
            LiveList(str2double(P.SubjectID),:) = sub_row; % add to the table
            save([P.DoubleBlindDir filesep 'LiveList.mat'],'LiveList'); % save the table
        end
        
        % pass by default a null yokId flag (where are still collecting exp
        % participants
        P.yokID = 'Null'; % flag for the Python interface

    elseif any(strcmp('DoubleBlindDir',fieldnames(P))) && P.DoubleBlindCheck == 1 % if we are in double blind mode
 
        load([P.DoubleBlindDir filesep 'LiveList.mat'],'LiveList') % load the table to check if the process has already been done (for example
        % if we are in the second run for the same participant
        
        % check
        if any(strcmp(P.SubjectID,LiveList.subID)) % the double blind routine has already been applied to the participant
            
            sub_row = LiveList(str2double(P.SubjectID),:);      
        else
            % call the getSubSettings function to determine the experimental conditions for this sub
            sub_row = getSubSettings(str2double(P.SubjectID),lower(P.SubGender),P.DoubleBlindDir);
        end

        % Get the Yolk SubID in case of a SHAM feedback condition, so that we
        % can find the activation file for the participant
        
        if strcmp(sub_row.groupID,'Sham')
            P.yokID = ['0' char(sub_row.yokedOn)];
        else
            P.yokID = 'Null'; % flag for the Python interface
        end

        % transmits the indo to the P struct
        P.TargetSide = sub_row.TargetSide;
        
        % rotation wheel
        if strcmp(sub_row.WheelRot,'right') % which rotation has the wheel?
            P.rightRot = 1;
        else
            P.leftRot = 1;
        end

        % target side
        if strcmp(sub_row.TargetSide,'right')
            P.V1_right = 1;
        else
            P.V1_left = 1;
        end
        
    end

        %% Prepare PTB texture(s)
        P.stimFolderPath    = P.StimFolder;

        % wheelImage = 'wheel_illustrator_prf_2.png';
        wheelImage = 'wheel_illustrator.png';
        % wheelImage = 'wheel_illustrator_grayscale.png';
        P.imWheel           = imread([P.stimFolderPath, filesep, wheelImage]);
    
        P.wheelTex          = Screen('MakeTexture', P.Screen.wPtr, P.imWheel);
        [P.s1, P.s2, P.s3]  = size(P.imWheel);
        P.aspRat            = P.s2/P.s1;
        P.heightScalers     = 0.35;
        P.imageHeights      = h .* P.heightScalers;
        P.imageWidths       = P.imageHeights .* P.aspRat;
    
        P.nrDim = P.dim * 2 + 1;
        P.baseRectDst = [0, 0, P.nrDim, P.nrDim];
        P.dstRects = nan(4, 2);
    
        for ii = 1:2
            P.theRect           = [0 0 P.imageWidths P.imageHeights]; % dimension of rectangle where to display image
            P.dstRects(:, ii)   = CenterRectOnPointd(P.theRect, P.xPos(ii), P.yPos);
        end
    
        % here will per probably needed to adjust the P.dstRects formula so
        % that it fits Soraya script for stimuli delivery
    
        [solution_in_cm_mirror,solution_in_cm_stimuliscreen,solution_in_pixel_stimuliscreen] = compute_distance_readable_from_screen_center_overt_fmri(50,60, 6.45, 3);
        P.distanceStimuli = solution_in_pixel_stimuliscreen;
    
        P.dstRects(:,1) = CenterRectOnPointd(P.theRect, P.Screen.xCenter -  P.distanceStimuli , P.yPos);
        P.dstRects(:,2) = CenterRectOnPointd(P.theRect, P.Screen.xCenter +  P.distanceStimuli , P.yPos);
        P.dstEqs =  P.distanceStimuli/2;
    
        P.NFBC.it_curr = [0];
        P.test.tstamp  = [0];
        P.test.visit_case2 = [0];
        P.test.time_displFBloop = [0];
    
        % ======================= VAS Parameters ==============================
        P.HSize = [0 0 1000 3]; P.HColor = [255 255 255];
        P.HLine = CenterRectOnPointd(P.HSize, P.Screen.xCenter, P.Screen.h * 0.6);
    
        P.VSize = [0 0 6 80]; P.VColor = [255 255 255];
        P.X     = P.Screen.xCenter;
    
        % Set the amount we want our square to move on each button press
        P.pixelsPerPress = 10;
    
        % set the flag to 1 so each run the first task iteration will be VAS
        P.VAS_flag = 1;
    
        P.VAS_duration = 3; % in seconds
        % =====================================================================
    
        % set flag to 0. We flip it to 1 after the last task block so the final
        % 'task' block will be the end run message.
        P.END_run_msg   = 0;
    
        % text font, size and style
        Screen('TextFont',P.Screen.wPtr, P.Font);
        % Screen('TextSize', P.Screen.wPtr, 18);
        Screen('TextStyle',P.Screen.wPtr, 0);
        
        % initiate trial counter variable for keeping track of task trials.
        % Counter values are used to index images in texture pointer mat.
        P.Task.trialCounter = 1;
        P.trialMem = 0;
    
        % initiate the onset structures
        P.Onsets.NF         = [];
        P.Onsets.Bas        = [];
        P.Onsets.Task       = [];
        P.Onsets.SumFB_fix  = [];
        P.Onsets.SumNF      = [];
    
    %     P.limLow  = 0;
    %     P.limUp   = 0.02;
    %     P.stepMin = -3;
    %     P.stepMax = 3;
        P.stepMin = -3.5;
        P.stepMax = 3.5;
    
    %     P.stepMinUp = 0;
    %     P.stepMaxUp = 1;
    %     P.stepMinDown = -1;
    %     P.stepMaxDown =  0;
    
        P.finalDispVal = 0;
    
        % to start the initial guess of the limits based on the previous run.
        % its only the initial range and will be updated as soon as new display
        % values come in.. it helps to make the first FB block less eratic
        if P.NFRunNr == 1
            P.limLow  = -0.1;
            P.limUp   = 0.1;
        else
            prevNfbPtbP   = fullfile(P.WorkFolder,['taskFolder', filesep, 'taskResults', filesep,...
                                           'NFB_taskResults_r' sprintf('%d',P.NFRunNr-1)]);
            prevLims            = load(prevNfbPtbP);
    
            P.limLow  = prevLims.P.limLow;
            P.limUp   = prevLims.P.limUp;
        end

    % %% Prepare PTB Sprites
    % stimPath = P.TaskFolder;
    % load([stimPath filesep 'stimNames.mat'])
    
    % sz = size(stimNames,2);             % nr of unique images
    % P.Screen.nrims = 10;                % how many repetitions of an image
    % Tex = zeros(sz,P.Screen.nrims);     % initialize pointer matrix
    % for i = 1:sz
    %     for j = 1:P.Screen.nrims
    %         imgArr = imread([stimPath filesep stimNames{i} filesep num2str(j) '.png']);
    %         Tex(i,j) = Screen('MakeTexture', P.Screen.wPtr, imgArr);
    %         clear imgArr
    %     end
    % end
    
    % % text font, size and style
    % Screen('TextFont',P.Screen.wPtr, 'Courier New');
    % Screen('TextSize', P.Screen.wPtr, 12);
    % Screen('TextStyle',P.Screen.wPtr, 3);
    
    % % initiate trial counter variable for keeping track of task trials.
    % % Counter values will be used to index images in texture pointer mat.
    % P.Task.trialCounter = 1;
   
end

if strcmp(protName, 'Inter')
    for i = 1:10
        imgSm = imread([workFolder filesep 'Settings' filesep ...
            'Smiley' filesep 'Sm' sprintf('%02d', i)], 'bmp');
        Tex(i) = Screen('MakeTexture', P.Screen.wPtr, imgSm);
        clear imgSm
    end
    P.Screen.rectSm = Screen('Rect', Tex(i));
    
    w_dispRect = round(P.Screen.rectSm(4)*1.5);
    w_offset_dispRect = 0;
    P.Screen.dispRect =[(w/2 - w_dispRect/2), ...
        (h/2 + w_offset_dispRect), (w/2 + w_dispRect/2), ...
        (h/2 + w_offset_dispRect+w_dispRect)];
    
    %% Dots
    % MRI screen parameters
    dist_mri = 44.3; % distance to the screen, cm
    scrw_mri = [34.8 25.8]; % cm
    
    % MRI screen scaling
    screenpix = [w h]; %pixel resolution
    screen_VA = [( 2 * atan(scrw_mri(1) / (2*dist_mri)) ), ...
        ( 2 * atan(scrw_mri(2) / (2*dist_mri)) )]; % the screens visual
    % angle in radians
    screen_VA = screen_VA * 180/pi; % the screens visual angle in degrees
    degrees_per_pixel = screen_VA ./ screenpix; % degrees per pixel
    degrees_per_pixel_mean = mean(degrees_per_pixel); % approximation of
    % the average number of degrees per pixel
    pixels_per_degree = 1 ./ degrees_per_pixel;
    pixels_per_degree_mean = 1 ./ degrees_per_pixel_mean;
    
    % circle prescription, via dots
    ddeg = 1:10:360; % degree
    drad = ddeg * pi/180; % rad
    P.Screen.dsize = 5; % dot size
    cs = [cos(drad); sin(drad)];
    % dot positions
    d=round(P.TargDIAM .* pixels_per_degree_mean);
    P.Screen.xy = cs * d / 2;
    r_offset = P.TargRAD * pixels_per_degree(1);
    loc_xy = round(r_offset * [cosd(P.TargANG) sind(P.TargANG)]);
    P.Screen.db = [w/2 h/2] + [+loc_xy(1)  -loc_xy(2)];
    
    % color
    P.Screen.dotCol = 200;
    
    % fixation
    P.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
    Screen('FillOval', P.Screen.wPtr, [155 0 0], P.Screen.fix);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
    
    % pointing arrow
    P.Screen.arrow.rect = [w/2-w/100, h/2-w/40, w/2+w/100, h/2-w/52];
    P.Screen.arrow.poly_right = [w/2+w/100, h/2-w/32; ...
        w/2+w/50,  h/2-w/46; w/2+w/100, h/2-w/74];
    P.Screen.arrow.poly_left  = [w/2-w/100, h/2-w/32; ...
        w/2-w/50,  h/2-w/46; w/2-w/100, h/2-w/74];
    
    Screen('TextSize',P.Screen.wPtr, 100);
    
end

%% DCM
% Note that images are subject of copyright and thereby replaced.
% Note that pictures and names are not randomized in our example for
% simplicity. The randomization could be done on the level of
% namePictP.mat and namePictN.mat structures given unique pictures per
% NF run in .\nPict and .\nPict folders.
if strcmp(protName, 'InterBlock')
    
    P.nrN = 0;
    P.nrP = 0;
    P.imgPNr = 0;
    P.imgNNr = 0;
    
    %% Prepare PTB Sprites
    % positive pictures
    basePath = strcat(workFolder, filesep, 'Settings', filesep);
    load([basePath 'namePictP.mat']);
    sz = size(namePictP,1);
    Tex.P = zeros(1,sz);
    for i = 1:sz
        fname = strrep(namePictP(i,:), ['.' filesep], basePath);
        imgArr = imread(fname);
        dimImgArr = size(imgArr);
        Tex.P(i) = Screen('MakeTexture', P.Screen.wPtr, imgArr);
        clear imgArr
    end
    
    % neutral pictures
    basePath = strcat(workFolder, filesep, 'Settings', filesep);
    load([basePath 'namePictN.mat']);
    sz = size(namePictN,1);
    Tex.N = zeros(1,sz);
    for i = 1:sz
        fname = strrep(namePictN(i,:), ['.' filesep], basePath);
        imgArr = imread(fname);
        dimImgArr = size(imgArr);
        Tex.N(i) = Screen('MakeTexture', P.Screen.wPtr, imgArr);
        clear imgArr
    end
    
    % text font, style and size
    Screen('TextFont',P.Screen.wPtr, 'Courier New');
    Screen('TextSize',P.Screen.wPtr, 40);
    Screen('TextStyle',P.Screen.wPtr, 3);
    
    %% Draw initial fixation
    Screen('FillOval', P.Screen.wPtr, [150 150 150], ...
        [P.Screen.w/2-w/100, P.Screen.h/2-w/100, ...
        P.Screen.w/2+w/100, P.Screen.h/2+w/100]);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
end

assignin('base', 'P', P);
%assignin('base', 'Tex', Tex);
