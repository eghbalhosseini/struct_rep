%%Function to create figures with multiple parameters. Only makes figures
%%for combined elecs (multiple frequencies), no option for figures with one
%%frequency

function output=combine_elec_analysis(combine_participants,correct,lang_resp,stim) 
    data_path='C:\Users\kirsi\Dropbox\struct_rep_data'; 
    subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
    if combine_participants
        combine_elecs_all_sent_word=[];
        combine_elecs_all_wlist_word=[];
        combine_elecs_all_jab_word=[];
        combine_elecs_all_non_word=[];

        combine_elecs_all_sent_probe=[];
        combine_elecs_all_wlist_probe=[];
        combine_elecs_all_jab_probe=[];
        combine_elecs_all_non_probe=[];
    end
    
    for m=1:length(subject_id)
        d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v4_compressed.mat')); 
        d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
        fprintf('%d .mat files found',length(d_data))
        sent_word_combined_elecs=[];
        sent_probe_combined_elecs=[];
        wlist_word_combined_elecs=[];
        wlist_probe_combined_elecs=[];
        jab_word_combined_elecs=[];
        jab_probe_combined_elecs=[];
        non_word_combined_elecs=[];
        non_probe_combined_elecs=[];

        for k=1:length(d_data)
            subj=load(d_data{k});
            subj_id=fieldnames(subj);
            subj=subj.(subj_id{1});
            data=subj.data;
            info=subj.info;
            if correct
                data_out_all=extract_condition_response(data,info,'S','word',true,false,true);
                sent_word_combined_elecs=cat(3,sent_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'S',stim,true,false,true);
                sent_probe_combined_elecs=cat(3,sent_probe_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'W','word',true,false,true);
                wlist_word_combined_elecs=cat(3,wlist_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'W',stim,true,false,true);
                wlist_probe_combined_elecs=cat(3,wlist_probe_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'J','word',true,false,true);
                jab_word_combined_elecs=cat(3,jab_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'J',stim,true,false,true);
                jab_probe_combined_elecs=cat(3,jab_probe_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'N','word',true,false,true);
                non_word_combined_elecs=cat(3,non_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'N',stim,true,false,true);
                non_probe_combined_elecs=cat(3,non_probe_combined_elecs,data_out_all);
            else %not correct
                data_out_all=extract_condition_response(data,info,'S','word',false,false,true);
                sent_word_combined_elecs=cat(3,sent_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'S',stim,false,false,true);
                sent_probe_combined_elecs=cat(3,sent_probe_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'W','word',false,false,true);
                wlist_word_combined_elecs=cat(3,wlist_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'W',stim,false,false,true);
                wlist_probe_combined_elecs=cat(3,wlist_probe_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'J','word',false,false,true);
                jab_word_combined_elecs=cat(3,jab_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'J',stim,false,false,true);
                jab_probe_combined_elecs=cat(3,jab_probe_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'N','word',false,false,true);
                non_word_combined_elecs=cat(3,non_word_combined_elecs,data_out_all);

                data_out_all=extract_condition_response(data,info,'N',stim,false,false,true);
                non_probe_combined_elecs=cat(3,non_probe_combined_elecs,data_out_all);
            end
        end

        %% Sort tensors according to probe positions
        %Create vector with all positions across participants for each condition
        sent_positions=[];
        wlist_positions=[];
        jab_positions=[];
        non_positions=[];

        for k=1:length(d_data)
            subj=load(d_data{k});
            subj_id=fieldnames(subj);
            subj=subj.(subj_id{1});
            data=subj.data;
            info=subj.info;
            if correct
                temp_sent_pos=get_positions(info,data,'S',true);
                sent_positions=cat(1, sent_positions, temp_sent_pos);

                temp_wlist_pos=get_positions(info,data,'W',true);
                wlist_positions=cat(1, wlist_positions, temp_wlist_pos);

                temp_jab_pos=get_positions(info,data,'J',true);
                jab_positions=cat(1, jab_positions, temp_jab_pos);

                temp_non_pos=get_positions(info,data,'N',true);
                non_positions=cat(1, non_positions, temp_non_pos);
            else
                temp_sent_pos=get_positions(info,data,'S',false);
                sent_positions=cat(1, sent_positions, temp_sent_pos);

                temp_wlist_pos=get_positions(info,data,'W',false);
                wlist_positions=cat(1, wlist_positions, temp_wlist_pos);

                temp_jab_pos=get_positions(info,data,'J',false);
                jab_positions=cat(1, jab_positions, temp_jab_pos);

                temp_non_pos=get_positions(info,data,'N',false);
                non_positions=cat(1, non_positions, temp_non_pos);
            end
        end

        %Sort pos vecs ascending order, sort tensors the same way
        [sent_positions, index]=sort(sent_positions);
        sent_word_combined_elecs=sent_word_combined_elecs(:,:,index);
        sent_probe_combined_elecs=sent_probe_combined_elecs(:,:,index);

        [wlist_positions, index]=sort(wlist_positions);
        wlist_word_combined_elecs=wlist_word_combined_elecs(:,:,index);
        wlist_probe_combined_elecs=wlist_probe_combined_elecs(:,:,index);

        [jab_positions, index]=sort(jab_positions);
        jab_word_combined_elecs=jab_word_combined_elecs(:,:,index);
        jab_probe_combined_elecs=jab_probe_combined_elecs(:,:,index);

        [non_positions, index]=sort(non_positions);
        non_word_combined_elecs=non_word_combined_elecs(:,:,index);
        non_probe_combined_elecs=non_probe_combined_elecs(:,:,index);

        %% Average trials at each probe position
        % Find indices where probe position changes
        sent_changes=diff(sent_positions);
        sent_change_indices=find(ismember(sent_changes,1));
        sent_change_indices=sent_change_indices+1;

        wlist_changes=diff(wlist_positions);
        wlist_change_indices=find(ismember(wlist_changes,1));
        wlist_change_indices=wlist_change_indices+1;

        jab_changes=diff(jab_positions);
        jab_change_indices=find(ismember(jab_changes,1));
        jab_change_indices=jab_change_indices+1;

        non_changes=diff(non_positions);
        non_change_indices=find(ismember(non_changes,1));
        non_change_indices=non_change_indices+1;

        %Take average of trials at each probe position
        sent_word_combined_elecs=probe_pos_ave_trials(sent_change_indices, sent_word_combined_elecs);
        sent_probe_combined_elecs=probe_pos_ave_trials(sent_change_indices, sent_probe_combined_elecs); 

        wlist_word_combined_elecs=probe_pos_ave_trials(wlist_change_indices, wlist_word_combined_elecs);
        wlist_probe_combined_elecs=probe_pos_ave_trials(wlist_change_indices, wlist_probe_combined_elecs);    

        jab_word_combined_elecs=probe_pos_ave_trials(jab_change_indices, jab_word_combined_elecs);
        jab_probe_combined_elecs=probe_pos_ave_trials(jab_change_indices, jab_probe_combined_elecs); 

        non_word_combined_elecs=probe_pos_ave_trials(non_change_indices, non_word_combined_elecs);
        non_probe_combined_elecs=probe_pos_ave_trials(non_change_indices, non_probe_combined_elecs);
        
        %% Lang Responsive
        if lang_resp
            sent_word_combined_elecs=sent_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
            wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
            jab_word_combined_elecs=jab_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
            non_word_combined_elecs=non_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);

            sent_probe_combined_elecs=sent_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
            wlist_probe_combined_elecs=wlist_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
            jab_probe_combined_elecs=jab_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
            non_probe_combined_elecs=non_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
        else  %only use valid channels
            scale_matrix=zeros(5*length(info.valid_channels),1);
            for i=1:length(info.valid_channels)
                temp=repmat(info.valid_channels(i),5,1);
                scale_matrix(i+4*(i-1):5*i)=temp;
            end
            sent_word_combined_elecs=sent_word_combined_elecs.*repmat(scale_matrix,1,8);
            wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(scale_matrix,1,8);
            jab_word_combined_elecs=jab_word_combined_elecs.*repmat(scale_matrix,1,8);
            non_word_combined_elecs=non_word_combined_elecs.*repmat(scale_matrix,1,8);

            sent_probe_combined_elecs=sent_probe_combined_elecs.*scale_matrix;
            wlist_probe_combined_elecs=wlist_probe_combined_elecs.*scale_matrix;
            jab_probe_combined_elecs=jab_probe_combined_elecs.*scale_matrix;
            non_probe_combined_elecs=non_probe_combined_elecs.*scale_matrix;
        end
        
        %% Combine averaged tensors from all subjects along dim1
        if combine_participants
            combine_elecs_all_sent_word=cat(1,combine_elecs_all_sent_word, sent_word_combined_elecs);
            combine_elecs_all_wlist_word=cat(1,combine_elecs_all_wlist_word, wlist_word_combined_elecs);
            combine_elecs_all_jab_word=cat(1,combine_elecs_all_jab_word, jab_word_combined_elecs);
            combine_elecs_all_non_word=cat(1,combine_elecs_all_non_word, non_word_combined_elecs);

            combine_elecs_all_sent_probe=cat(1,combine_elecs_all_sent_probe, sent_probe_combined_elecs);
            combine_elecs_all_wlist_probe=cat(1,combine_elecs_all_wlist_probe, wlist_probe_combined_elecs);
            combine_elecs_all_jab_probe=cat(1,combine_elecs_all_jab_probe, jab_probe_combined_elecs);
            combine_elecs_all_non_probe=cat(1,combine_elecs_all_non_probe, non_probe_combined_elecs);
            break %from m loop -> only need one figure
        else    
            %% Compute cosine distance
            %sentence
            word_tensor=sent_word_combined_elecs;
            probe_tensor=sent_probe_combined_elecs;
            sent_angles=calc_similarities(word_tensor,probe_tensor);

            %wordlist
            word_tensor=wlist_word_combined_elecs;
            probe_tensor=wlist_probe_combined_elecs;
            wlist_angles=calc_similarities(word_tensor,probe_tensor);

            %jabber
            word_tensor=jab_word_combined_elecs;
            probe_tensor=jab_probe_combined_elecs;
            jab_angles=calc_similarities(word_tensor,probe_tensor);

            %nonword
            word_tensor=non_word_combined_elecs;
            probe_tensor=non_probe_combined_elecs;
            non_angles=calc_similarities(word_tensor,probe_tensor);

            %% Generate figure
            strings={'S','W','J','N'};
            angs={sent_angles, wlist_angles, jab_angles, non_angles};
            figure;
            for i=1:length(strings)
                subplot(2,2,i);
                imagesc(cell2mat(transpose(angs{1,i})));
                colorbar();
                title(strcat('angle b/w ',strings{1,i},' & probe'));
                ylabel('trials');
            end
            if stim(1:4)=='pret'
                starter=strcat('C:\Users\kirsi\Documents\data\analysis\important_figures\updated_files\',subject_id{1,m},'\',stim,'_5_freqs\',stim);
            else
                starter=strcat('C:\Users\kirsi\Documents\data\analysis\important_figures\updated_files\',subject_id{1,m},'\',stim,'\',stim);
            end
            if ~lang_resp & ~correct
                figname=starter;
            elseif ~lang_resp & correct
                figname=strcat(starter,'_correct');
            elseif lang_resp & ~correct
                figname=strcat(starter,'_lang_resp');
            else
                figname=strcat(starter,'_correct_lang_resp');
            end
            savefig(figname);
        end
    end
    if combine_participants
        %% Compute cosine distance
        %sentence
        word_tensor=combine_elecs_all_sent_word;
        probe_tensor=combine_elecs_all_sent_probe;
        sent_angles=calc_similarities(word_tensor,probe_tensor);

        %wordlist
        word_tensor=combine_elecs_all_wlist_word;
        probe_tensor=combine_elecs_all_wlist_probe;
        wlist_angles=calc_similarities(word_tensor,probe_tensor);

        %jabber
        word_tensor=combine_elecs_all_jab_word;
        probe_tensor=combine_elecs_all_jab_probe;
        jab_angles=calc_similarities(word_tensor,probe_tensor);

        %nonword
        word_tensor=combine_elecs_all_non_word;
        probe_tensor=combine_elecs_all_non_probe;
        non_angles=calc_similarities(word_tensor,probe_tensor);

        %% Generate figure
        strings={'S','W','J','N'};
        angs={sent_angles, wlist_angles, jab_angles, non_angles};
        output=figure;
        for i=1:length(strings)
            subplot(2,2,i);
            imagesc(cell2mat(transpose(angs{1,i})));
            colorbar();
            title(strcat('angle b/w ',strings{1,i},' & probe'));
            ylabel('trials');
        end
        if stim(1:4)=='pret'
            starter=strcat('C:\Users\kirsi\Documents\data\analysis\important_figures\updated_files\combine_subject_electrodes\',stim,'_5_freqs\',stim);
        else
            starter=strcat('C:\Users\kirsi\Documents\data\analysis\important_figures\updated_files\combine_subject_electrodes\',stim,'\',stim);
        end
        if ~lang_resp & ~correct
            figname=starter;
        elseif ~lang_resp & correct
            figname=strcat(starter,'_correct');
        elseif lang_resp & ~correct
            figname=strcat(starter,'_lang_resp');
        else
            figname=strcat(starter,'_correct_lang_resp');
        end
        savefig(figname);
    end
    output=figname;
end

