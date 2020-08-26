%%Take probe position values from info.probe_position_matrix only for
%%trials with desired condition (S,W,J,N). Use in any script making figures

function output=get_positions(info,data,cond,correct_response)
    %% Remove Fixation Trials
    positions=info.position_matrix;
    wordtypes=info.word_type;
    pos_right=find(strcmp(info.subject_response,'RIGHT'));
    pos_wrong=find(strcmp(info.subject_response,'WRONG'));
    pos_desired=sort([pos_right;pos_wrong]);
    positions=positions(pos_desired);
    wordtypes=wordtypes(pos_desired);
    data=data(pos_desired);
    
    %% Only use correct trials
    if correct_response
        indices=[];
        for i=1:length(data)
            if data{i,1}.trial_probe_answer=='1'
                if data{i,1}.subject_response=='RIGHT'
                    indices=[indices,i];
                end
            elseif data{i,1}.trial_probe_answer=='0'
                if data{i,1}.subject_response=='WRONG'
                    indices=[indices,i];
                end
            elseif data{i,1}.trial_probe_answer==data{i,1}.subject_response
                indices=[indices,i];
            end
        end
        positions=positions(indices);
        wordtypes=wordtypes(indices);
    end
    
    %% Create vector with probe positions of desired condition trials
    relevant_wtype=find(strcmp(wordtypes,cond)); %indices of wordtypes corresponding to stim
    relevant_pos=positions(relevant_wtype);
    output=relevant_pos;
end