function [subSettings] = getSubSettings(subID, gender, dbListDir, simulate)

    % Function logic. 
     
    % If we have an Experimental subject
    %   Check if we still have available experimental participants of this
    %   gender in the waiting list.
    %
    %   If this is NOT the case 
    %       See if there are still Sham subjects in the future on LiveList
    %
    %           if this is NOT the case OR we have the nr of shams*sex 
    %           already satisfied
    %               we make this a NEW experimental sub (random settings) 
    %               !! This will add one participant to your sample !!
    %           else 
    %               we go ahead and exchange the planned experimental sub
    %               to a sham
    %
    %   If we still find expermental participants on the waiting list
    %       We go ahead and take it from waiting list
    
    % If we have a sham subject
	
    %   And if we still need sham subjects of this gender 	
    %       We check if there are still available yoke subs on LiveList
	%
    %           If this is NOT the case
	%               We find the next experimental subject on LiveList that matches
	%               And we swap them, our sub is now an experimental sub
	%
    %           If we do have matching yoke sub on LiveList
	%               We copy those settings to current sub entry in live list
	%
    %   If we do not need a sham for this gender 
	%       We create a new experimental entry and push the sham entry on livelist to the end
    %        !! This will add one participant to your sample !!
    
    warning ('off','all');
    
    % This function can also be run as a simulator (i.e. not overwriting
    % the lists. This is how it's called by getSubSuggestion.m to figure
    % out a list of next subjects to recruit.
    if nargin < 4
        simulate = 'False';
    end

    if strcmp(simulate, 'False')
        % load lists
        LiveList        = load([dbListDir, filesep, 'LiveList.mat']);
        ExpWaitingList  = load([dbListDir, filesep, 'ExpWaitingList.mat']);

        % unpack for use
        LiveList        = LiveList.LiveList;
        ExpWaitingList  = ExpWaitingList.ExpWaitingList;
    elseif strcmp(simulate, 'True') 
        % if we are simulating these lists will be passed in stead of the
        % directories.. same name different variable type
        LiveList        = dbListDir.LiveList;
        ExpWaitingList  = dbListDir.ExpWaitingList; 
    end
    
    totNrSubs   = size(ExpWaitingList, 1);

    % define sub row to take into account the first experimental subs
    % before going into double blind mode
    subRow = subID; 
    
    % Get the sex and groupID of current sub
    tmpSex      = gender;
    tmpGroupID  = LiveList.groupID(subRow);
    
    if isequal(tmpGroupID{1}, 'Exp')

        % Chek if we still have matching experimental subjects in the
        % waiting list
        poolIDs = intersect(find(strcmp(tmpSex, ExpWaitingList.Sex)),...
            find(strcmp('V', ExpWaitingList.Availability)));
        

        % check if poolIDs is not empty. if the case it means there are no
        % experimental participants in the waiting list that match. I.e we
        % completed enough experimental participants of this gender..So in
        % this case we change the current experimental subject to a sham
        % subject..  
        if isempty(poolIDs) 

            % find the remaining Sham participants in the LiveList
            % We start looking after current subject, find the index and
            % scale up to match entire LiveList. We will excahnge this
            % entry with the current one.
            ShamSubsLeft = find(strcmp(LiveList.groupID(subRow+1:end), 'Sham')) + subRow;
            
            checkShamCount = numel(intersect(find(strcmp(LiveList.groupID, 'Sham')),...
                           find(strcmp(LiveList.Sex, tmpSex))));

            if isempty(ShamSubsLeft) || (checkShamCount >= (totNrSubs/2))
                rot     = {'left', 'right'};
                side    = {'left', 'right'};

                editSubEntry                = LiveList(subRow,:);
                editSubEntry.subID          = {num2str(subRow)};
                editSubEntry.Sex            = tmpSex;
                editSubEntry.groupID        = {'Exp'};
                editSubEntry.Availability   = {'V'};  
                editSubEntry.yokedOn        = {'None'};
                editSubEntry.BufferSub      = {'V'};

                editSubEntry.TargetSide = rot(randi(numel(side)));
                editSubEntry.WheelRot = rot(randi(numel(rot)));
                
                exChangeSham        = LiveList(subRow, :);
                LiveList(subRow,:)  = editSubEntry;
                LiveList(end+1,:)   = exChangeSham;
                
                % Alternatviley we can change still pick from the waiting
                % list but take one of the opposite gender. We will create
                % a disbalance but this will only be very light. 
            else
            
                % save current subject entry for which we don't have a match
                exChangeExp                = LiveList(subRow, :);

                % take the first experimental subject in line
                exChangeSham                 = LiveList(ShamSubsLeft(1),:);

                % swap them 
                LiveList(subRow, :)          = exChangeSham;
                LiveList(ShamSubsLeft(1),:)  = exChangeExp;

                % Now rewrite the subject --> sham subject
                tmpGroupID = LiveList.groupID(subRow);

                % from here we need to go back to the SHAM routine. For
                % now a quick copy paste but can be optimized.
                % find the experimental subjects in LiveList that match the sex and are available
                poolIDs = intersect(intersect(find(strcmp(tmpSex, LiveList.Sex)),...
                                find(strcmp('V', LiveList.Availability)), 'stable'),...
                                find(strcmp('Exp', LiveList.groupID)), 'stable');

                % randomly pick one of the matching experimental subjects
                pickedSub = poolIDs(randperm(numel(poolIDs),1));

                % change the entry before pasting it back into the LiveList. We
                % need to flag this sub as a sham and set the yoked to unavailable
                editSubEntry                = LiveList(pickedSub,:);
                editSubEntry.groupID        = {'Sham'};
                editSubEntry.Availability   = {'-'};  
                editSubEntry.subID          = {num2str(subRow)};
                editSubEntry.yokedOn        = LiveList.subID(pickedSub);

                LiveList(subRow, :) = editSubEntry;
                LiveList.Availability(pickedSub) = {'X'}; % flag yoked sub to unav 
            end
            
        else
            % if we do find a match in the waiting list extract and copy to
            % live list, mark unavailable on waiting list
            % pick first sub (list was already randomzied)
            pickedSub = poolIDs(1);

            % move subject to livelist and mark unavailable on the waiting list
            LiveList(subRow, :) = ExpWaitingList(pickedSub, :);
            LiveList.yokedOn(subRow) = {'None'};

            ExpWaitingList.Availability(pickedSub) = {'X'};
        end
       
    elseif isequal(tmpGroupID{1}, 'Sham')
        % if it's a sham subject we will go over the subjects we have had
        % so far and find a match. Three conditions need to be met: 
        % Sex, groupID and Yoke Availability. 
        % The list to evaluate is than ofcourse the live list.
    
        % checkShamCount: because we sometimes run out of experimental subs
        % we switch them to sham subject with the routine below. In this
        % case however we do not have an intrinsic check on balance as we
        % will always find a yoke match (we have more experimental subs
        % than sham). Therefor sometimes we might end up with more sham
        % subs of a particular gender than intended causing problems at the
        % last iterations of the sample. Here we check if we have enough
        % sham subs of that gender and if so we add an entry to the waiting
        % list
        checkShamCount = numel(intersect(find(strcmp(LiveList.groupID, 'Sham')),...
                                   find(strcmp(LiveList.Sex, tmpSex))));

        
        if (checkShamCount < (totNrSubs/2))
            
            % check if we have matching experimental subjects available to
            % yoke on
            poolIDs = intersect(intersect(find(strcmp(tmpSex, LiveList.Sex)),...
                                find(strcmp('V', LiveList.Availability)), 'stable'),...
                                find(strcmp('Exp', LiveList.groupID)), 'stable');

            % check if poolIDs is not empty. if the case it means there are no
            % experimental participants that match. In this case we need to
            % swap with the first experimental subject in line that matches
            % current sub.
            if isempty(poolIDs)

                % find the remaining Experimental participants in the LiveList
                % We start looking after current subject, find the index and
                % scale up to match entre LiveList
                ExpSubsLeft = find(strcmp(LiveList.groupID(subRow+1:end), 'Exp')) + subRow;

                % save current subject entry for which we don't have a match
                exChangeSham                = LiveList(subRow, :);

                % take the first experimental subject in line
                exChangeExp                 = LiveList(ExpSubsLeft(1),:);

                % swop them 
                LiveList(subRow, :)         = exChangeExp;
                LiveList(ExpSubsLeft(1),:)  = exChangeSham;

                % Now rewrite the subject 
                tmpGroupID = LiveList.groupID(subRow);

                % from here we need to go back to the experimental routine. For
                % now a quick copy paste but can be optimized.
                % find the subjects in waiting that match the sex and are still
                % marked available
                poolIDs = intersect(find(strcmp(tmpSex, ExpWaitingList.Sex)),...
                    find(strcmp('V', ExpWaitingList.Availability)));

                % pick first sub (list was already randomzied)
                pickedSub = poolIDs(1);

                % move subject to livelist and mark unavailable on the waiting list
                LiveList(subRow, :) = ExpWaitingList(pickedSub, :);
                LiveList.yokedOn(subRow) = {'None'};

                ExpWaitingList.Availability(pickedSub) = {'X'};

            else
                % If we are good we finish the routine:

                % randomly pick one of the matching experimental subjects
                pickedSub = poolIDs(randperm(numel(poolIDs),1));

                % change the entry before pasting it back into the LiveList. We
                % need to flag this sub as a sham and set it to unavailable
                editSubEntry                = LiveList(pickedSub,:);
                editSubEntry.groupID        = {'Sham'};
                editSubEntry.Availability   = {'-'};      
                editSubEntry.subID          = {num2str(subRow)};
                editSubEntry.yokedOn        = LiveList.subID(pickedSub);

                LiveList(subRow, :)                 = editSubEntry;
                LiveList.Availability(pickedSub)    = {'X'}; % flag yoked sub to unav
            end
            
        % if we have satisfied the nr of sham*gender we create a new
        % experimental subject
        elseif (checkShamCount >= (totNrSubs/2))
            rot     = {'left', 'right'};
            side    = {'left', 'right'};

            editSubEntry                = LiveList(subRow,:);
            editSubEntry.subID          = {num2str(subRow)};
            editSubEntry.Sex            = tmpSex;
            editSubEntry.groupID        = {'Exp'};
            editSubEntry.Availability   = {'V'};  
            editSubEntry.yokedOn        = {'None'};
            editSubEntry.BufferSub      = {'V'};

            editSubEntry.TargetSide = rot(randi(numel(side)));
            editSubEntry.WheelRot   = rot(randi(numel(rot)));

            exChangeSham        = LiveList(subRow, :);
            LiveList(subRow,:)  = editSubEntry;
            LiveList(end+1,:)   = exChangeSham;            

%             fprintf('switch!\n')

        end
                        
    
    end
    LiveList.subID{subRow} = num2str(subRow);
    
    
    if strcmp(simulate, 'True')
        % if we simulate we dont overwrite but we just return the updated
        % lists
        subSettings.LiveList        = LiveList;
        subSettings.ExpWaitingList  = ExpWaitingList;
    elseif strcmp(simulate, 'False')
        % if we are not simulating we return the subject settings and
        % overwrite the lists
        % Retrun subsettings to be used for flagging in ptb process
        subSettings = LiveList(subRow, :);
        
        % over write the updated lists for next iteration
        save([dbListDir, filesep, 'LiveList.mat'], 'LiveList')
        save([dbListDir, filesep, 'ExpWaitingList.mat'], 'ExpWaitingList')
    end

end
