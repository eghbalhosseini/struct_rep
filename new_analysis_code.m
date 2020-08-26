%%Function to create figures with several different parameters. Like
%%combine_elec_analysis, but has only S & W conditions, has option to make figures with only one freq,
%%(combined_elecs=False), and only uses probe positions 1-8 instead of including 0 (no probe present in sequence)

function output=new_analysis_code(combined_subs,combined_elecs,stim,lang_resp,correct) 
    %% specify where the data is
    if combined_elecs
        data_path='C:\Users\kirsi\Dropbox\struct_rep_data'; 
    else
        data_path='C:\Users\kirsi\Documents\data\ave_window_time';
    end
    subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
    if combined_subs
        sent_word_combine=[];
        sent_probe_combine=[];

        wlist_word_combine=[];
        wlist_probe_combine=[];
    end

    for m=1:length(subject_id)
        if combined_elecs
            d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v4_compressed.mat')); 
        else
            d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v3_compressed.mat'));
        end
        d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
        fprintf('%d .mat files found\n',length(d_data))

        %% combine responses from all sessions for a given condition. (S= sentence,....)

        sent_word_tensor_all=[];
        sent_probe_tensor_all=[];
        wlist_word_tensor_all=[];
        wlist_probe_tensor_all=[];

        for k=1:length(d_data)
            subj=load(d_data{k});
            subj_id=fieldnames(subj);
            subj=subj.(subj_id{1});
            data=subj.data;
            info=subj.info;
            if combined_elecs
                if correct
                    data_out_all=extract_condition_response(data,info,'S','word',true,false,true);
                    sent_word_tensor_all=cat(3,sent_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'S',stim,true,false,true);
                    sent_probe_tensor_all=cat(3,sent_probe_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W','word',true,false,true);
                    wlist_word_tensor_all=cat(3,wlist_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W',stim,true,false,true);
                    wlist_probe_tensor_all=cat(3,wlist_probe_tensor_all,data_out_all);
                else
                    data_out_all=extract_condition_response(data,info,'S','word',false,false,true);
                    sent_word_tensor_all=cat(3,sent_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'S',stim,false,false,true);
                    sent_probe_tensor_all=cat(3,sent_probe_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W','word',false,false,true);
                    wlist_word_tensor_all=cat(3,wlist_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W',stim,false,false,true);
                    wlist_probe_tensor_all=cat(3,wlist_probe_tensor_all,data_out_all);
                end
            else
                if correct
                    data_out_all=extract_condition_response(data,info,'S','word',true,false,false);
                    sent_word_tensor_all=cat(3,sent_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'S',stim,true,false,false);
                    sent_probe_tensor_all=cat(3,sent_probe_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W','word',true,false,false);
                    wlist_word_tensor_all=cat(3,wlist_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W',stim,true,false,false);
                    wlist_probe_tensor_all=cat(3,wlist_probe_tensor_all,data_out_all);
                else
                    data_out_all=extract_condition_response(data,info,'S','word',false,false,false);
                    sent_word_tensor_all=cat(3,sent_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'S',stim,false,false,false);
                    sent_probe_tensor_all=cat(3,sent_probe_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W','word',false,false,false);
                    wlist_word_tensor_all=cat(3,wlist_word_tensor_all,data_out_all);

                    data_out_all=extract_condition_response(data,info,'W',stim,false,false,false);
                    wlist_probe_tensor_all=cat(3,wlist_probe_tensor_all,data_out_all);
                end
            end
        end 

        %% Sort tensors according to probe positions
        %Create vector with all positions across participants for each condition
        sent_positions=[];
        wlist_positions=[];

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
            else
                temp_sent_pos=get_positions(info,data,'S',false);
                sent_positions=cat(1, sent_positions, temp_sent_pos);

                temp_wlist_pos=get_positions(info,data,'W',false);
                wlist_positions=cat(1, wlist_positions, temp_wlist_pos);
            end
        end

        %Sort pos vecs ascending order, sort tensors the same way
        [sent_positions, index]=sort(sent_positions);
        sent_word_tensor_all=sent_word_tensor_all(:,:,index);
        sent_probe_tensor_all=sent_probe_tensor_all(:,:,index);

        [wlist_positions, index]=sort(wlist_positions);
        wlist_word_tensor_all=wlist_word_tensor_all(:,:,index);
        wlist_probe_tensor_all=wlist_probe_tensor_all(:,:,index);

        %% Take average of trials with same probe position
        %find indices of sorted pos vec where pos changes
        sent_changes=diff(sent_positions);
        sent_change_indices=find(ismember(sent_changes,1));
        sent_change_indices=sent_change_indices+1;

        wlist_changes=diff(wlist_positions);
        wlist_change_indices=find(ismember(wlist_changes,1));
        wlist_change_indices=wlist_change_indices+1;

        %Take average of trials at each probe position
        sent_word_tensor_all=probe_pos_ave_trials(sent_change_indices, sent_word_tensor_all);
        sent_probe_tensor_all=probe_pos_ave_trials(sent_change_indices, sent_probe_tensor_all); 

        wlist_word_tensor_all=probe_pos_ave_trials(wlist_change_indices, wlist_word_tensor_all);
        wlist_probe_tensor_all=probe_pos_ave_trials(wlist_change_indices, wlist_probe_tensor_all);    

        %% Remove condition where probe not present
        sent_word_tensor_all=sent_word_tensor_all(:,:,2:9);
        sent_probe_tensor_all=sent_probe_tensor_all(:,:,2:9);

        wlist_word_tensor_all=wlist_word_tensor_all(:,:,2:9);
        wlist_probe_tensor_all=wlist_probe_tensor_all(:,:,2:9);

        if lang_resp
            %% Only use lang responsive channels
            if combined_elecs
                sent_word_tensor_all=sent_word_tensor_all.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
                wlist_word_tensor_all=wlist_word_tensor_all.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);

                sent_probe_tensor_all=sent_probe_tensor_all.*info.sig_and_pos_chans_combine_elecs;
                wlist_probe_tensor_all=wlist_probe_tensor_all.*info.sig_and_pos_chans_combine_elecs;
            else
                sent_word_tensor_all=sent_word_tensor_all.*repmat(info.sig_and_pos_chans_single_freq,1,8);
                wlist_word_tensor_all=wlist_word_tensor_all.*repmat(info.sig_and_pos_chans_single_freq,1,8);

                sent_probe_tensor_all=sent_probe_tensor_all.*info.sig_and_pos_chans_single_freq;
                wlist_probe_tensor_all=wlist_probe_tensor_all.*info.sig_and_pos_chans_single_freq;
            end
        else
            %% Only use valid channels
            if combined_elecs
                scale_matrix=zeros(5*length(info.valid_channels),1);
                for i=1:length(info.valid_channels)
                    temp=repmat(info.valid_channels(i),5,1);
                    scale_matrix(1+5*(i-1):5*i)=temp;
                end
                sent_word_tensor_all=sent_word_tensor_all.*repmat(scale_matrix,1,8);
                wlist_word_tensor_all=wlist_word_tensor_all.*repmat(scale_matrix,1,8);

                sent_probe_tensor_all=sent_probe_tensor_all.*scale_matrix;
                wlist_probe_tensor_all=wlist_probe_tensor_all.*scale_matrix;
            else
                sent_word_tensor_all=sent_word_tensor_all.*repmat(info.valid_channels,1,8);
                wlist_word_tensor_all=wlist_word_tensor_all.*repmat(info.valid_channels,1,8);

                sent_probe_tensor_all=sent_probe_tensor_all.*info.valid_channels;
                wlist_probe_tensor_all=wlist_probe_tensor_all.*info.valid_channels;
            end
        end
        
        if combined_subs
            %% add to combined elec tensor
            sent_word_combine=cat(1,sent_word_combine,sent_word_tensor_all);
            sent_probe_combine=cat(1,sent_probe_combine,sent_probe_tensor_all);

            wlist_word_combine=cat(1,wlist_word_combine,wlist_word_tensor_all);
            wlist_probe_combine=cat(1,wlist_probe_combine,wlist_probe_tensor_all);
        else
            break
        end
    end

    %% compute a cosine distance over all electrodes to compare word & probe conditions
    %sentence condition
    if combined_subs
        word_tensor=sent_word_combine;
        probe_tensor=sent_probe_combine;
    else
        word_tensor=sent_word_tensor_all;
        probe_tensor=sent_probe_tensor_all;
    end
    sentence_angles_all=calc_similarities(word_tensor,probe_tensor);

    %wordlist condition
    if combined_subs
        word_tensor=wlist_word_combine;
        probe_tensor=wlist_probe_combine;
    else
        word_tensor=wlist_word_tensor_all;
        probe_tensor=wlist_probe_tensor_all;
    end
    wlist_angles_all=calc_similarities(word_tensor,probe_tensor);


    %% figure
    max_sent=max(cell2mat(transpose(sentence_angles_all)),[],'all');
    min_sent=min(cell2mat(transpose(sentence_angles_all)),[],'all');
    max_wlist=max(cell2mat(transpose(wlist_angles_all)),[],'all');
    min_wlist=min(cell2mat(transpose(wlist_angles_all)),[],'all');
    
    total_max=max([max_sent,max_wlist],[],'all');
    total_min=min([min_sent,min_wlist],[],'all');
    
    strings=['S','W'];
    angs={sentence_angles_all, wlist_angles_all};
    figure;
    
    plot1=axes('position',[0.1 0.6 0.3 0.3]);
    imagesc(plot1, cell2mat(transpose(angs{1,1})));
    colorbar(plot1);
    caxis([total_min total_max]);
    title(strcat('angle b/w ',strings(1,1),' & probe'));
    xlabel('word position');
    ylabel('probe position');
    
    plot2=axes('position',[0.6 0.6 0.3 0.3]);
    imagesc(plot2, cell2mat(transpose(angs{1,2})));
    colorbar(plot2);
    caxis([total_min total_max]);
    title(strcat('angle b/w ',strings(1,2),' & probe'));
    xlabel('word position');
    ylabel('probe position');


    if combined_subs
        starter='C:\Users\kirsi\Documents\data\analysis\important_figures\presentation\combined';
        if combined_elecs
            starter=strcat(starter,'\all_freq\',stim);
        else
            starter=strcat(starter,'\one_freq\',stim);
        end
        
        if ~lang_resp & ~correct
            figname=starter;
        elseif lang_resp & ~correct
            figname=strcat(starter,'_lang_resp');
        elseif ~lang_resp & correct
            figname=strcat(starter,'_correct');
        else
            figname=strcat(starter,'_correct_lang_resp');
        end
    else
        starter='C:\Users\kirsi\Documents\data\analysis\important_figures\presentation\AMC026';
        if combined_elecs
            starter=strcat(starter,'\all_freq\',stim);
        else
            starter=strcat(starter,'\one_freq\',stim);
        end
        
        if ~lang_resp & ~correct
            figname=starter;
        elseif lang_resp & ~correct
            figname=strcat(starter,'_lang_resp');
        elseif ~lang_resp & correct
            figname=strcat(starter,'_correct');
        else
            figname=strcat(starter,'_correct_lang_resp');
        end
    end
    savefig(figname);
    output=figname;
end
