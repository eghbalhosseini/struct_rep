function output=new_time_windows(combine_participants,correct,lang_resp,stim,all,first_probe,first_word)
% combine_participants -> true or false
% correct -> true or false, determines if only correct trials are used
% lang_resp -> true or false, determines if only lang resp elecs are used
% stim -> string: probe, preprobe, pretrial, postprobe

    data_path='C:\Users\kirsi\Dropbox\struct_rep_data';
    subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
    if combine_participants
        combine_elecs_all_sent_word=[];
        combine_elecs_all_wlist_word=[];
      
        combine_elecs_all_sent_probe=[];
        combine_elecs_all_wlist_probe=[];
    end
    
    for m=1:length(subject_id)
        d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v4_compressed.mat')); 
        d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
        fprintf('%d .mat files found',length(d_data));
        
        sent_window_word_tens=[];
        wlist_window_word_tens=[];

        sent_window_probe_tens=[];
        wlist_window_probe_tens=[];

        for k=1:length(d_data)
            subj=load(d_data{k});
            subj_id=fieldnames(subj);
            subj=subj.(subj_id{1});
            data=subj.data;
            info=subj.info;
            
            %% Combine freqs for new windows if not already done
            if ~isfield(data{1,1}, 'combined_win')
                for j=1:length(data)
                    field=data{j,1}.signal_gaus_band_hilb_dec_zs_parsed_win;
                    new_field=cell(size(field,1),1);
                    for i=1:size(field,1)
                        temp=field(i,:);
                        temp=cell2mat(transpose(temp));
                        new_field{i,1}=temp;
                    end
                    data{j,1}.combined_win=new_field;
                end
                subject_name=info.subject;
                session_name=info.session_name;
                eval(strcat(subject_name,'_',session_name,'.data=data;'));
                eval(strcat(subject_name,'_',session_name,'.info=info;'));
                save(d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
            end
                    
            if correct
                data_out=extract_condition_response(data,info,'S','word',true,true);
                sent_window_word_tens=cat(3,sent_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'W','word',true,true);
                wlist_window_word_tens=cat(3,wlist_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'S',stim,true,true);
                sent_window_probe_tens=cat(3,sent_window_probe_tens,data_out);

                data_out=extract_condition_response(data,info,'W',stim,true,true);
                wlist_window_probe_tens=cat(3,wlist_window_probe_tens,data_out);
            else
                data_out=extract_condition_response(data,info,'S','word',false,true);
                sent_window_word_tens=cat(3,sent_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'W','word',false,true);
                wlist_window_word_tens=cat(3,wlist_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'S',stim,false,true);
                sent_window_probe_tens=cat(3,sent_window_probe_tens,data_out);

                data_out=extract_condition_response(data,info,'W',stim,false,true);
                wlist_window_probe_tens=cat(3,wlist_window_probe_tens,data_out);
            end
        end
        
        %% Sort tensors according to probe positions
        %Create vector with all positions across trials for each condition
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
        sent_window_word_tens=sent_window_word_tens(:,:,index);
        sent_window_probe_tens=sent_window_probe_tens(:,:,index);

        [wlist_positions, index]=sort(wlist_positions);
        wlist_window_word_tens=wlist_window_word_tens(:,:,index);
        wlist_window_probe_tens=wlist_window_probe_tens(:,:,index);

        %% Average trials at each probe position
        % Find indices where probe position changes
        sent_changes=diff(sent_positions);
        sent_change_indices=find(ismember(sent_changes,1));
        sent_change_indices=sent_change_indices+1;

        wlist_changes=diff(wlist_positions);
        wlist_change_indices=find(ismember(wlist_changes,1));
        wlist_change_indices=wlist_change_indices+1;

        %Take average of trials at each probe position
        sent_window_word_tens=probe_pos_ave_trials(sent_change_indices, sent_window_word_tens);
        sent_window_probe_tens=probe_pos_ave_trials(sent_change_indices, sent_window_probe_tens); 

        wlist_window_word_tens=probe_pos_ave_trials(wlist_change_indices, wlist_window_word_tens);
        wlist_window_probe_tens=probe_pos_ave_trials(wlist_change_indices, wlist_window_probe_tens);
        
        %% Lang Responsive
        if lang_resp
            sent_window_word_tens=sent_window_word_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,size(sent_window_word_tens,2));
            wlist_window_word_tens=wlist_window_word_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,size(sent_window_word_tens,2));

            sent_window_probe_tens=sent_window_probe_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,size(sent_window_probe_tens,2));
            wlist_window_probe_tens=wlist_window_probe_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,size(sent_window_probe_tens,2));
           
        else  %only use valid channels
            scale_matrix=zeros(5*length(info.valid_channels),1);
            for i=1:length(info.valid_channels)
                temp=repmat(info.valid_channels(i),5,1);
                scale_matrix(1+5*(i-1):5*i)=temp;
            end
            sent_window_word_tens=sent_window_word_tens.*repmat(scale_matrix,1,size(sent_window_word_tens,2));
            wlist_window_word_tens=wlist_window_word_tens.*repmat(scale_matrix,1,size(sent_window_word_tens,2));
            
            sent_window_probe_tens=sent_window_probe_tens.*repmat(scale_matrix,1,size(sent_window_probe_tens,2));
            wlist_window_probe_tens=wlist_window_probe_tens.*repmat(scale_matrix,1,size(sent_window_probe_tens,2));
        end
        
        %% take windows you want to work with
        tag='all_windows';
        if ~all
            if first_probe
                sent_window_probe_tens=sent_window_probe_tens(:,1:2,:);
                wlist_window_probe_tens=wlist_window_probe_tens(:,1:2,:);
                tag='first_probe';
            else
                sent_window_probe_tens=sent_window_probe_tens(:,5:6,:);
                wlist_window_probe_tens=wlist_window_probe_tens(:,5:6,:);
                tag='last_probe';
            end
            
            num_sent=(size(sent_window_word_tens,2)/8);
            num_word=(size(wlist_window_word_tens,2)/8);
            temp_sent=zeros(size(sent_window_word_tens,1),16,size(sent_window_word_tens,3));
            temp_wlist=zeros(size(wlist_window_word_tens,1),16,size(wlist_window_word_tens,3));
            if first_word
                for j=1:8
                    temp_sent(:,2*j-1:2*j,:)=sent_window_word_tens(:,1+num_sent*(j-1):2+num_sent*(j-1),:);
                    temp_wlist(:,2*j-1:2*j,:)=wlist_window_word_tens(:,1+num_word*(j-1):2+num_word*(j-1),:);
                end
                sent_window_word_tens=temp_sent;
                wlist_window_word_tens=temp_wlist;
                tag=strcat(tag,'_first_word');
            else
                for j=1:8
                    temp_sent(:,2*j-1:2*j,:)=sent_window_word_tens(:,4+num_sent*(j-1):5+num_sent*(j-1),:);
                    temp_wlist(:,2*j-1:2*j,:)=wlist_window_word_tens(:,4+num_word*(j-1):5+num_word*(j-1),:);
                end
                sent_window_word_tens=temp_sent;
                wlist_window_word_tens=temp_wlist;
                tag=strcat(tag,'_last_word');
            end
        end
        
        
        %% Combine subject tensors or make separate subject figs                
        if combine_participants
            combine_elecs_all_sent_word=cat(1,combine_elecs_all_sent_word, sent_window_word_tens);
            combine_elecs_all_wlist_word=cat(1,combine_elecs_all_wlist_word, wlist_window_word_tens);

            combine_elecs_all_sent_probe=cat(1,combine_elecs_all_sent_probe, sent_window_probe_tens);
            combine_elecs_all_wlist_probe=cat(1,combine_elecs_all_wlist_probe, wlist_window_probe_tens);
     
        else
            %% Agles for each sub
            %sentence
            word_tensor=sent_window_word_tens;
            probe_tensor=sent_window_probe_tens;
            sent_angles=angle_new_windows(word_tensor,probe_tensor);

            %wordlist
            word_tensor=wlist_window_word_tens;
            probe_tensor=wlist_window_probe_tens;
            wlist_angles=angle_new_windows(word_tensor,probe_tensor);

            %% Generate figure each sub
            strings={'sentence','wordlist'};
            angs={sent_angles, wlist_angles};
            for h=1:length(angs)
                figure;
                for i=1:length(angs{1,h})
                    for j=1:length(angs{1,h}{1,i})
                        subplot(length(angs{1,h}),length(angs{1,h}{1,i}),j*i+(7-(j-1))*(i-1));
                        imagesc(angs{1,h}{1,i}{j,1});
                        colorbar();
                    end
                end
                starter=strcat('C:\Users\kirsi\Documents\data\analysis\important_figures\new_windows\',subject_id{1,m},'\',tag,'\',strings{1,h},'\',stim,'\',stim);
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
    end
    
    if combine_participants
        %% Angles all subs
        %sentence
        word_tensor=combine_elecs_all_sent_word;
        probe_tensor=combine_elecs_all_sent_probe;
        sent_angles=angle_new_windows(word_tensor,probe_tensor);

        %wordlist
        word_tensor=combine_elecs_all_wlist_word;
        probe_tensor=combine_elecs_all_wlist_probe;
        wlist_angles=angle_new_windows(word_tensor,probe_tensor);

        %% Generate figure all subs
        strings={'sentence','wordlist'};
        tstrings={'S','W'};
        titles={'first p first w', 'first p last w', 'last p first w', 'last p last w'};
        angs={sent_angles, wlist_angles};

        for h=1:length(angs)
            figure;
            for i=1:4
                subplot(2,2,i);
                imagesc(cell2mat(angs{1,h}{1,i}));
                colorbar();
                title(strcat(tstrings{1,h},', ',titles{1,i}));
            end
            
            starter=strcat('C:\Users\kirsi\Documents\data\analysis\important_figures\new_windows\combine\',tag,'\new_window_combo\',strings{1,h},'\',stim,'\',stim);
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
            
            
            
            
        
        
            
            
            