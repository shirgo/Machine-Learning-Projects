clc, clear, close all

data_dir = [pwd filesep 'training' filesep];

%% Add this directory to the MATLAB path.
addpath(pwd)
folder_list = dir([data_dir 'training*']);

%% Extract features
win_len = 5; % Window length for feature extraction in seconds
win_overlap = 0; % Overlap between adjacent windows in percentage

feature_table = table();
class = [];

for ifolder = 1:length(folder_list)
    disp(['Processing files from folder: ' folder_list(ifolder).name])
    current_folder = [data_dir filesep folder_list(ifolder).name];
    
    % Import ground truth labels (1, -1) from reference. 1 = Normal, -1 =
    % Abnormal
    reference_table = importReferencefile([current_folder filesep 'REFERENCE.csv']);
    
    fid = fopen([current_folder filesep 'RECORDS'],'r');
    if(fid ~= -1)
        RECLIST = textscan(fid,'%s');
    else
        error(['Could not open ' data_dir 'RECORDS for scoring. Exiting...'])
    end
    fclose(fid);
    
    RECORDS = RECLIST{1};
    
    parfor irecord = 1:length(RECORDS)
        disp(['     Processing file: ' RECORDS{irecord}])
        [PCG, fs] = audioread([current_folder filesep RECORDS{irecord} '.wav']);
        
        current_features = extractFeaturesChallenge(PCG, fs, win_len, win_overlap);
        current_class = reference_table(strcmp(reference_table.record_name,...
            RECORDS{irecord}), :).record_label;
        
        feature_table = [feature_table; current_features];
        class = [class; repmat(current_class, height(current_features), 1)];
    end
end

feature_table.class = class;