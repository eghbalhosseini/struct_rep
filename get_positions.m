%%Get probe positions in trials corresponding to stim
function output=get_positions(info,data,cond,correct_response)
    positions=info.position_matrix;
    wordtypes=info.word_type;
    pos_right=find(strcmp(info.subject_response,'RIGHT'));
    pos_wrong=find(strcmp(info.subject_response,'WRONG'));
    pos_desired=sort([pos_right;pos_wrong]);
    positions=positions(pos_desired);
    wordtypes=wordtypes(pos_desired);
    data=data(pos_desired);
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
    relevant_wtype=find(strcmp(wordtypes,cond)); %indices of wordtypes corresponding to stim
    relevant_pos=positions(relevant_wtype);
    output=relevant_pos;
end