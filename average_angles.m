function output=average_angles(word, probe, change)
    if isempty(change)
        angle=calc_similarities(word, probe);
        angle=cell2mat(transpose(angle));
        angle_cells{1,1}=mean(angle,1);
    elseif length(change)==1
        angle_cells=cell(2,1);
        temp_word=word(:,:,1:change(1));
        temp_probe=probe(:,:,1:change(1));
        angle=calc_similarities(temp_word,temp_probe);
        angle=cell2mat(transpose(angle));
        angle=mean(angle,1);
        angle_cells{1,1}=angle;
        
        temp_word=word(:,:,change(1):end);
        temp_probe=probe(:,:,change(1):end);
        angle=calc_similarities(temp_word,temp_probe);
        angle=cell2mat(transpose(angle));
        angle=mean(angle,1);
        angle_cells{2,1}=angle;
    else
        angle_cells=cell(length(change)+1,1);
        temp_word=word(:,:,1:change(1));
        temp_probe=probe(:,:,1:change(1));
        angle=calc_similarities(temp_word,temp_probe);
        angle=cell2mat(transpose(angle));
        angle=mean(angle,1);
        angle_cells{1,1}=angle
        for i=2:length(change)
            temp_word=word(:,:,change(i-1):change(i)-1);
            temp_probe=probe(:,:,change(i-1):change(i)-1);
            angle=calc_similarities(temp_word,temp_probe);
            angle=cell2mat(transpose(angle));
            angle=mean(angle,1);
            angle_cells{i,1}=angle;
        end
        temp_word=word(:,:,change(i):end);
        temp_probe=probe(:,:,change(i):end);
        angle=calc_similarities(temp_word,temp_probe);
        angle=cell2mat(transpose(angle));
        angle=mean(angle,1);
        angle_cells{i,1}=angle;
    end
    output=angle_cells;