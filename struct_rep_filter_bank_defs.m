f_low=3;
f_high=150;
[cfs,sds]=get_filter_param_chang_lab(f_low,f_high);
rate=2000;
X=1:10000;
time = size(X,2);
d=1./rate;
filter_bank={};
time = size(X,2);
d=1./rate;
freq=[0:ceil(time/2-1), ceil(-(time)/2):1:-1]/(d*time);
for s=1:length(cfs)
        filter_bank{s}=gaussian_filter(X,rate,cfs(s),sds(s));
end 

figure;
subplot(1,1,1)
for i=1:length(filter_bank)
    hold on 
    plot(freq,filter_bank{i},'color',[.5,.5,.5],'linewidth',2,'linestyle','-')
    xlim([0,max(cfs)+20])
end 

% 
bands = ['theta', 'alpha', 'beta', 'gamma', 'high gamma'];
min_freqs = [4., 8., 15., 30., 70.];
max_freqs = [7., 14., 29., 59., 150.];
%HG_freq = 200.
rate=2000;
X=1:10000;
time = size(X,2);
d=1./rate;
freq=[0:ceil(time/2-1), ceil(-(time)/2):1:-1]/(d*time);
%figure;
%subplot(1,1,1)
cmap=viridis(5);
for k=1:length(min_freqs)
    [cfs,sds]=get_filter_param_chang_lab(min_freqs(k),max_freqs(k));
    filter_bank={};
    for s=1:length(cfs)
        filter_bank{s}=gaussian_filter(X,rate,cfs(s),sds(s));
    end 
    for i=1:length(filter_bank)
    hold on 
    plot(freq,filter_bank{i},'color',cmap(k,:),'linewidth',2)
    end 
    xlim([0,max(max_freqs)+20])
end 
title('grouping of frequency ranges (theta, alpha,...) within the gaussian filter bank')
