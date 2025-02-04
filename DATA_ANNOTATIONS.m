folder_path = "C:\Users\Krish\OneDrive\Desktop\ISDL\ORIGNAL DATSET\Test_00";
output_path = 'C:\Users\Krish\OneDrive\Desktop\ISDL\DATASET'; 
file_list = dir(fullfile(folder_path, '*.mat'));

number = 0;                                                                %TRACKS THE NUMBER OF FILE                                                                                                                                %FOR SEIZURE FILE

for k = 1:length(file_list)

    file_path = fullfile(folder_path, file_list(k).name);
    
    t_time=3000000;                                                        %TOTAL ENTERIES
    elec_no=15;                                                            %ELECTRODES
    window_size=10;                                                        %WINDOW SIZE SPECIFY
    divider=2;                                                             %WE WILL USE ONLY LAST DESIRED_COLNS/DIVIDER ENTERIES ONLY
    desired_cols = 6000;                                                   %TO REDUCE THE FREQUENCY OF DATA POINTS
    new_length=desired_cols/divider;                                       %NEW LENGTH OF THE INPUT ARRAY
    new_starting_index=desired_cols-new_length;
                                                       
    A = zeros(elec_no, 8, desired_cols/(divider*window_size));             %FINAL MATRIX
    
    [~, base_file_name, ~] = fileparts(file_list(k).name);                 %STRUCTURE NAME
    segment_number = regexprep(base_file_name, '.*_0*', '');
    
    %file_variable = ['interictal_segment_', segment_number];
    file_variable = ['test_segment_', segment_number];
    %file_variable = ['preictal_segment_', segment_number];

    %file_name = sprintf('seizure_%d.csv', number);                         %OUTPUT FILE
    %number=number+1;
    file_name = sprintf('non_izure_%d.csv', number);                       %OUTPUT FILE
    number=number+1;
   
    dest_file_name= fullfile(output_path, file_name );
    
    s = load(file_path);
    s=s.(file_variable);
    s=s.data;                                                              %s=15*3000000
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TO MAKE DATA MORE MANAGABLE
    batch_size = size(s, 2) / desired_cols;
    new_s = zeros(size(s, 1), desired_cols);

    for i = 1:size(s, 1)
        row = s(i, :);
        reshaped_row = reshape(row, batch_size, []);
        new_s(i, :) = mean(reshaped_row, 1);
    end                                                                    %new_s=15*6000

    new_s=new_s(:,new_starting_index+1:desired_cols);                      %new_s=15*3000
    disp(file_list(k).name)
    
    for i= 1:1:elec_no 
        temp=['---------->DOING ELECTRODE  ',num2str(i)];
        disp(temp)
        N = normalize(new_s(i,:));                                         %DATA NORMALIZATION AND EXTRACTION OF EACH ROW
        window_number=1;                                                   %WINDOW NUMBER SPECIFY EACH SEGMENT

        for j=1:window_size:new_length
            temp_array=N(1,j:j+window_size-1);                                  %VECTOR
            %PARMETERS FUCTION
            A(i,1,window_number)= mean(temp_array);                             %MEAN
            A(i,2,window_number)= var(temp_array);                              %VARIANCE
            A(i,3,window_number)= max(temp_array)-min(temp_array);              %RANGE
            A(i,4,window_number)= skewness(temp_array);                         %SKEWNESS   
            A(i,5,window_number)= kurtosis(temp_array);                         %KURTOSIS
            A(i,6,window_number)= zerocrossrate(temp_array);                    %ZERO CROSS RATE        
            window_number=window_number+1;
        end
        
        fourier_array=fft(A(i,1,:));                                            %FOURIER VECTOR
        len=length(fourier_array);
        %FOURIER COEFFICCIENTS
        A(i,7,1:300) = abs(fourier_array/len);                             %FOURIER COEFFICCIENTS AMPLITUDE
        A(i,8,1:300) = angle(fourier_array/len);                           %PHASE ANGLE
    end
    writematrix(A,dest_file_name)                                          %A=15*8*300 
    disp(size(A))
end
disp("DONE")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
