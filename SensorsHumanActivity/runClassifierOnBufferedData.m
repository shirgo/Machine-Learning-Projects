function runClassifierOnBufferedData
% runTrainedNetworkOnBufferedData summarizes the complete example
% It loads the data and a pre-trained neural network and it shows the
% latter attributing an activity class to each individual signal buffer.
% The estimated class is displayed along the known ground truth for
% qualitative validation.

% Set number of new samples per iterations
N = 64;
% and length of buffer (time window) to run analysis on
L = 128;

% Gravitational acceleration (m/s^2)
g = 9.80665;

% Load sampling frequency
load('BufferedAccelerations.mat','fs');

% Load feature normalization parameters
load('BufferFeatures.mat','fmean','fstd')

% Initialize simple UI to control signal streaming
doPause = true;
scrsz = get(groot,'ScreenSize');
hfig = figure;
basicControls
hdisp;

% Point to stored data with continuous raw acceleration and activity id
dataFile = dsp.MatFileReader('ContinuousAccelerationsShort.mat','at',...
    'SamplesPerFrame',N);
actidValues = dsp.MatFileReader('ContinuousAccelerationsShort.mat','actid',...
    'SamplesPerFrame',N);

% Buffer to ensure a sufficiently long time window
dataBuffer = dsp.Buffer(L,L-N);

% Scope for signal visualization
accelerationScope = dsp.TimeScope('PlotType', 'Line',...
    'ShowLegend',true,...
    'YLimits',[-2*g 2*g],'YLabel','Acceleration (m s^-2)',...
    'SampleRate',fs,'TimeSpan',L/fs,...
    'ShowGrid',true);

% Load activity labels
actnames = getActivityNames();

while ~isDone(dataFile) && ishandle(hfig)
    
    if(doPause)
        drawnow
        continue
    end
    
    % Get data - None buffer for each acceleration component
    atraw = step(dataFile);
    
    % Buffer data to run analysis on longer segments
    at = step(dataBuffer, atraw);
        
    % Plot three signals
    step(accelerationScope, at)
    
    predActid = predictActivityFromSignalBuffer(at/g, fs, fmean, fstd);
    
    % Display result as title in current plot along with ground truth
    displayPredictionResults(predActid);
    
end

    function displayPredictionResults(predActid)
        estimatedActivity = actnames{predActid}; %#ok<*USENS>
        actid = step(actidValues);
        actualActivity = actnames{actid(1)};
        stringToDisplay = sprintf('Actual: %s\nEstimated: %s',...
            actualActivity, estimatedActivity);
        if(strcmp(actualActivity, estimatedActivity))
            predColor = [0.6000    0.8706    0.6275];
        else
            predColor = [0.8510    0.3765    0.3333];
        end
        if(ishghandle(hdisp))
            hdisp.String = stringToDisplay;
            hdisp.BackgroundColor = predColor;
        end
    end

    function basicControls
        hfig.Name = 'Acquisition Control';
        hfig.Position = (1/10)*[1 4 1.8 1.3].*[scrsz(3) scrsz(4) scrsz(3) scrsz(4)];
        hfig.MenuBar = 'none';
        
        uicontrol('Style','pushbutton', ...
            'Position', (1/10)*[0.1 0.7 1.6 0.5].*[scrsz(3) scrsz(4) scrsz(3) scrsz(4)],...[5 5 80 30], ...
            'String', 'Acquire','FontSize',10, ...
            'Callback',@onButtonPressed);

        hdisp = uicontrol('Style','text', ...
            'Position', (1/10)*[0.1 0.1 1.6 0.5].*[scrsz(3) scrsz(4) scrsz(3) scrsz(4)],...[5 5 80 30], ...
            'String', sprintf('Actual:\nEstimated:'),...
            'FontSize',10,'BackgroundColor',[1 1 1],...
            'HorizontalAlignment','left','FontWeight','bold');

    end

    function onButtonPressed(hObject, eventdata, handles) %#ok<INUSD>
        switch(hObject.String)
            case 'Acquire'
                doPause = false;
                hObject.String = 'Pause';
                show(accelerationScope)
            case 'Pause'
                doPause = true;
                hObject.String = 'Acquire';
        end
        drawnow
    end

end


