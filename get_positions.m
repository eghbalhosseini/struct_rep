%%Get probe positions in trials corresponding to stim
function output=get_positions(info,cond)
    positions=info.position_matrix;
    wordtypes=info.word_type;
    relevant_wtype=find(strcmp(wordtypes,cond)); %indices of wordtypes corresponding to stim
    relevant_pos=positions(relevant_wtype);
    output=relevant_pos;
end
