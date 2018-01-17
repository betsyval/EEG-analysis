%%% EEG analysis script 14/11/2017 %%%
addpath('C:\Users\s1011306\Downloads\fieldtrip-20180114\fieldtrip-20180114')

%read continuous data
cfg = [];
cfg.dataset     = '301.vhdr';
data_org        = ft_preprocessing(cfg)

%rereferencing
cfg = [];
cfg.dataset     = '301.vhdr';
cfg.reref       = 'yes';
cfg.channel     = 'all';
cfg.implicitref = 'LinkMast';            % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel     = {'LinkMast', 'TP9'}; % the average of these channels is used as the new reference
data_eeg        = ft_preprocessing(cfg);
%discard dummy channels?
%this is to look at three channels
plot(data_eeg.time{1}, data_eeg.trial{1}(1:3,:));
legend(data_eeg.label(1:3));

%reading horizontal EOGH
cfg = [];
cfg.dataset = '301.vhdr';
cfg.channel = {'EOGleft', 'EOGright'};
cfg.reref = 'yes';
cfg.refchannel = 'EOGleft';
data_eogh = ft_preprocessing(cfg);

%checking that EOGleft was referenced to itself
figure
plot(data_eogh.time{1}, data_eogh.trial{1}(1,:));
hold on
plot(data_eogh.time{1}, data_eogh.trial{1}(2,:),'g'); 
legend({'EOGleft' 'EOGright'}); 
%rename/discard dummy channel with the next lines
data_eogh.label{2} = 'EOGH';
cfg = [];
cfg.channel = 'EOGH';
data_eogh   = ft_preprocessing(cfg, data_eogh); % nothing will be done, only the selection of the interesting channel
%reading vertical EOGH
cfg = [];
cfg.dataset = '301.vhdr';
cfg.channel = {'EOGabove', 'EOGbelow'}; %is there a difference in which above/below put before?
cfg.reref = 'yes';
cfg.refchannel = 'EOGabove'
data_eogv = ft_preprocessing(cfg);
data_eogv.label{2} = 'EOGV';
cfg = [];
cfg.channel = 'EOGV';
data_eogv = ft_preprocessing(cfg, data_eogv); % nothing will be done, only the selection of the interesting channel
%combination of a single representation of using
cfg = [];
data_all = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv);

%trial segmentation
cfg = [];
cfg.dataset             = '301.vhdr';
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);

%select data of two conditions --- it works!
cfg = [];
cfg.dataset             = '301.vhdr';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S208', 'S218'};
cfg_vis_condA          = ft_definetrial(cfg);

cfg.trialdef.eventvalue = {'S209', 'S219'};
cfg_vis_condB            = ft_definetrial(cfg);

%cut the trials out of the continuous data segment
data_vis_condA = ft_redefinetrial(cfg_vis_condA, data_all);
data_vis_condB   = ft_redefinetrial(cfg_vis_condB,   data_all);

%visual inspection ?
cfg          = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_all);

%visual inspection of visual channels, to mark them as good or bad
cfg        = [];
cfg.method = 'channel';
ft_rejectvisual(cfg, data_all)
%channel layout?? (the tutorial uses an existing layout)

cfg = [];
cfg.method   = 'summary';
cfg.layout   = 'mpi_customized_acticap64.mat';   % this allows for plotting individual trials
cfg.channel  = [1:60];    % do not show EOG channels
data_clean   = ft_rejectvisual(cfg, data_all);

disp(data_clean.trialinfo')
%computing and plotting ERPs
% use ft_timelockanalysis to compute the ERPs 
% cfg = [];
% cfg.trials = find(cfg_vis_condA);
% task1 = ft_timelockanalysis(cfg, data_all);
% 
% cfg = [];
% cfg.trials = find(cfg_vis_condB);
% task2 = ft_timelockanalysis(cfg, data_all);
% 
% cfg = [];
% cfg.layout = 'mpi_customized_acticap64.mat';
% cfg.interactive = 'yes';
% cfg.showoutline = 'yes';
% ft_multiplotER(cfg, task1, task2)

%averaging trials
cfg = [];
avgCondA = ft_timelockanalysis(cfg_vis_condA, data_all);
avgCondB = ft_timelockanalysis(cfg_vis_condB,   data_all);

%plotting - but still the layout
cfg = [];
cfg.showlabels = 'yes'; 
cfg.fontsize = 6; 
cfg.layout = 'CTF151.lay';
cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgFIC); 


