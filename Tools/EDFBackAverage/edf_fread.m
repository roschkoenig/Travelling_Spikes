function data = edf_fread(edf_file, start_time, duration)
% EDF_FREAD  read data from an EDF+ file
%
% edf_fread(edf_file, start_time, duration)
%     edf_file: structure for an EDF+ file
%     start_time: starting from 0 second
%     duration: in seconds
%
%     data(n_timepoints, n_ch): read data

if start_time < 0
    error('Start time must be >= 0');
end

if duration < 1
    error('Duration must be >= 1');
end

start_point = round(edf_file.sampling_rate * start_time);
end_point = start_point + round(edf_file.sampling_rate * duration) - 1;

ch_max_sampling_rate = find(edf_file.sampling_rate == max(edf_file.sampling_rate));
ch_max_sampling_rate = ch_max_sampling_rate(1);

start_record_number = floor(start_point(ch_max_sampling_rate) ...
    / edf_file.header.number_of_samples_in_each_data_record(ch_max_sampling_rate)) + 1;
end_record_number = floor(end_point(ch_max_sampling_rate) ...
    / edf_file.header.number_of_samples_in_each_data_record(ch_max_sampling_rate)) + 1;

start_offset = mod(start_point, edf_file.header.number_of_samples_in_each_data_record(ch_max_sampling_rate));
end_offset = mod(end_point, edf_file.header.number_of_samples_in_each_data_record(ch_max_sampling_rate));

if end_record_number > edf_file.header.number_of_data_records
    end_record_number = edf_file.header.number_of_data_records;
    end_offset = edf_file.header.number_of_samples_in_each_data_record - 1;
end

data_record = edf_fread_record(edf_file, start_record_number, end_record_number - start_record_number + 1);

for ch = edf_file.header.number_of_signals_in_data_record:-1:1
    start = start_offset(ch) + 1;
    finish = (end_record_number - start_record_number) * ...
        edf_file.header.number_of_samples_in_each_data_record(ch) + end_offset(ch) + 1;
    data(:, ch) = data_record(start:finish, ch);
end

if size(data, 1) ~= edf_file.sampling_rate * duration
    data((end + 1):edf_file.sampling_rate * duration, :) = 0;
end
