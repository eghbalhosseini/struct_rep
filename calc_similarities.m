function angle=calc_similarities(word_tensor,probe_tensor)
   probe_norm=arrayfun(@(x)  sqrt(transpose(probe_tensor(:,:,x))*probe_tensor(:,:,x)),[1:size(probe_tensor,3)],'uni',false);
   words_norm=arrayfun(@(x)  diag(sqrt(transpose(word_tensor(:,:,x))*word_tensor(:,:,x))),[1:size(word_tensor,3)],'uni',false);
   norm_product=cellfun(@(x,y) transpose(x.*y) ,probe_norm,words_norm,'uni',false);
   w_probe_dot=arrayfun(@(x)  transpose(probe_tensor(:,:,x))*word_tensor(:,:,x),[1:size(word_tensor,3)],'uni',false);
   w_probe_angle=cellfun(@(x,y) x./y,w_probe_dot,norm_product,'uni',false);
   angle=w_probe_angle
end