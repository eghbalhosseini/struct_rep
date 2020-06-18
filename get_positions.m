%%Get probe positions in trials corresponding to stim
function output=get_positions(info,stim)
    positions=info.position_matrix;
    wordtypes=info.word_type;
    relevant_wtype=find(strcmp(wordtypes,stim)); %indices of wordtypes corresponding to stim
    relevant_pos=positions(relevant_wtype);
    output=relevant_pos;
end
