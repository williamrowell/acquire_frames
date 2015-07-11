%% CONFIG

% video device
% to find available: imaqhwinfo
src_driver = 'dcam';
src_dev_idx = 1;

% device format
% to find available:
% vid_info = imaqhwinfo(src_driver, src_device_index);
% vid_info.SupportedFormats
src_fmt = 'Y8_640x480';

% device frame rate
% set(src_obj, 'FrameRate')
src_frame_rate = 30;

% other video device settings
src_brightness = 700;
src_gain = 29;

% video duration in frames
frames_per_trigger = 100;

% repeat delay in seconds
trigger_delay = 10;

% number of repeats
num_triggers = 5;

% output file
dest_file = 'test.avi';

% output frame rate
dest_frame_rate = 5;

% frame stamp format and contents


%% INITIALIZE VIDEO DEVICE
vid = videoinput(src_driver, src_dev_idx, src_fmt);
set(vid, 'SelectedSourceName', 'input1');
src_obj = getselectedsource(vid);

% is your frame rate available?
avail_frame_rates = set(src_obj, 'FrameRate');
if ~sum(ismember(avail_frame_rates, num2str(src_frame_rate)))
    error('%s is not an available frame rate.', num2str(src_frame_rate));
end
% set src frame rate
src_obj.FrameRate = num2str(src_frame_rate);
% set other src parameters
src_obj.Gain = src_gain;
src_obj.Brightness = src_brightness;
vid.FramesPerTrigger = frames_per_trigger;
vid.TriggerRepeat = num_triggers;
triggerconfig(vid,'manual');


preview(vid);
pause;
closepreview;


%% INITIALIZE OUTPUT

set(vid, 'LoggingMode', 'disk');

avi = avifile(dest_file, 'fps', dest_frame_rate);

set(vid, 'DiskLogger', avi);



%% RECORD VIDEO
start(vid);

for i = 1:num_triggers
    trigger(vid);
    pause(trigger_delay);
end

avi = get(vid,'DiskLogger');
avi = close(avi);

%% CLEAN UP

delete(vid);
clear vid;
