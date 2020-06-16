function myimage=create_figure(angle1, string1, angle2, string2)
   myimage=figure;
   subplot(1,2,1)
   imagesc(cell2mat(transpose(angle1)));
   colorbar()
   title(strcat('angle b/w ',string1,' and probe'));
   subplot(1,2,2)
   imagesc(cell2mat(transpose(angle2)));
   colorbar()
   title(strcat('angle b/w ',string2,' and probe'));
end