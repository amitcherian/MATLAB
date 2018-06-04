close all
clear all

pathname = uigetdir; %opens a dialog box for the user to select the file location
cd(pathname)%cd = opens the folder
Allfiles = dir;   % get list of all files from current directory
filenames = {Allfiles.name}; % Allfiles.name or ".name" is the varialble array that is created when using dir
folders = filenames([Allfiles.isdir]); %isdir checks if the filenames that were populated is a directory (else the array includes both files and folders)
folders = folders(3:end);%remove unwanted first two charaters

%Initialize variables with zeros
fE1=zeros(8,1);
fE2=zeros(8,1);
meanE1=zeros();
meanE2=zeros();
ratio=zeros();

%%
%Load folders list
for i=1:length(folders) % # of folders
    s=folders(i); %load folders one by one
    folder=sprintf('%s', s{:});%convert folder name to string
    cd ([pathname '\' folder '\Pos0'])%Enter image directory
    A=dir('*.tif'); %load all tiff files in the directory
    check1=1; %counter for images from first camera
    check2=1; %counter for images from second camera
   %Load images 
    for ii=1:length(A)% # of frames for a camera
        if isempty(strfind(A(ii).name,'Evolve1')) == 0
            evolve1(check1).name=A(ii).name;
            check1=check1+1;
        end
        if isempty(strfind(A(ii).name,'Evolve2')) == 0
            evolve2(check2).name=A(ii).name;
            check2=check2+1;
        end
    end
    mean_int=[];
    
    %Find mean
    for iii = 1: length(evolve1)
        PA = double(imread(evolve1(iii).name));
        PAC=PA(129:384,129:384);
        PE = double(imread(evolve2(iii).name));
        PE=flipud(PE);
        PEC=PE(129:384,129:384);
        mean_int(iii,1)= mean(mean(PAC));
        mean_int(iii,2)= mean(mean(PEC));
        mean_int(iii,3)= mean_int(iii,1)./mean_int(iii,2);
        clear PA PAC PE PEC; 
    end
    
    
    %fluctuation and avg intensity
    [E1min,E1minindex] = min(mean_int(:,1));
    [E1max,E1maxindex] = max(mean_int(:,1));
    E1fluctratio=((E1max-E1min)/E1min)*100;
    avgintensityE1=mean(mean_int(:,1));
    
    [E2min,E2minindex] = min(mean_int(:,2));
    [E2max,E2maxindex] = max(mean_int(:,2));
    E2fluctratio=((E2max-E2min)/E2min)*100;
    avgintensityE2=mean(mean_int(:,2));
    
    [E12min,E12minindex] = min(mean_int(:,3));
    [E12max,E12maxindex] = max(mean_int(:,3));
    E12fluctratio=((E12max-E12min)/E12min)*100;
    avgintensityE12=mean(mean_int(:,3));
    
    f=[1:length(evolve1)];
    
    %Extract data from Metadata
    fid = fopen('metadata.txt', 'rt');

    metaData = readtable('metadata.txt','Delimiter',':','ReadVariableNames',false);

    % search for Exposure:
    Exposure_index = find(strcmp([metaData{:,1}], 'Evolve1-Exposure'), 1, 'first');
    Exposure_value = str2double(metaData{Exposure_index,2});

    % search for Gain:
    Gain_index = find(strcmp([metaData{:,1}], 'Evolve1-MultiplierGain'), 1, 'first');
    Gain_value = str2double(metaData{Gain_index,2});

    % search for Gain Mode:
    GainMode_index = find(strcmp([metaData{:,1}], 'Evolve1-Gain'), 1, 'first');
    GainMode_value = str2double(metaData{GainMode_index,2});

    % search for Clear Mode:
    ClearMode_index = find(strcmp([metaData{:,1}], 'Evolve1-ClearMode'), 1, 'first');
    ClearMode_value = metaData{ClearMode_index,2};

    % search for Readout Rate:
    ReadoutRate_index = find(strcmp([metaData{:,1}], 'Evolve1-ReadoutRate'), 1, 'first');
    ReadoutRate_value = metaData{ReadoutRate_index,2};

    fclose(fid);
    
    %Plot Graphs
    %%%%%%%%%%%%%%%%Evolve-1
    figure(101)
    plot(f,mean_int(:,1),'m-o','MarkerEdgeColor','m','MarkerFaceColor','m','LineWidth',1);%m-o magenta colored solid lines with circular markers
    E1strmin = ['Min Intensity = ' num2str(E1min) ' at frame ' num2str(E1minindex)];
    E1strmax = ['Max Intensity = ',num2str(E1max) ' at frame ' num2str(E1maxindex)]; 
    E1strfluc = [' hence a variation of ' num2str(E1fluctratio) '%'];
                
    title(strcat('Mean intensty of Evolve-1 ( ', num2str(avgintensityE1), ' ), ', folder),'Interpreter','none');
    xlabel({'Frames in Time';E1strmin;E1strmax;E1strfluc});
    ylabel('Mean Intensity of PA');
                
    saveas(gcf,fullfile([pathname '\' folder],[ folder ' Evolve-1.png'])); %gcf = get current file
    
    %%%%%%%%%%%%%%%%Evolve-2
    figure(102)
    plot(f,mean_int(:,2),'m-o','MarkerEdgeColor','m','MarkerFaceColor','m','LineWidth',1);%m-o magenta colored solid lines with circular markers
    E2strmin = ['Min Intensity = ' num2str(E2min) ' at frame ' num2str(E2minindex)];
    E2strmax = ['Max Intensity = ',num2str(E2max) ' at frame ' num2str(E2maxindex)]; 
    E2strfluc = [' hence a variation of ' num2str(E2fluctratio) '%'];
                
    title(strcat('Mean intensty of Evolve-2 ( ', num2str(avgintensityE2), ' ), ', folder),'Interpreter','none');
    xlabel({'Frames in Time';E2strmax;E2strmin;E2strfluc});
    ylabel('Mean Intensity of PE');
                
    saveas(gcf,fullfile([pathname '\' folder],[ folder ' Evolve-2.png'])); %gcf = get current file
    
    %%%%%%%%%%%%%%%%Ratio
    figure(103)
    plot(f,mean_int(:,3),'m-o','MarkerEdgeColor','m','MarkerFaceColor','m','LineWidth',1);%m-o magenta colored solid lines with circular markers
    E12strmin = ['Min G-Fac = ' num2str(E12min) ' at frame ' num2str(E12minindex)];
    E12strmax = ['Max G-Fac = ',num2str(E12max) ' at frame ' num2str(E12maxindex)]; 
    E12strfluc = [' hence a variation of ' num2str(E12fluctratio) '%'];
                
    title(strcat('Mean value of G-Fac ( ', num2str(avgintensityE12), ' ), ', folder),'Interpreter','none');
    xlabel({'Frames in Time';E12strmin;E12strmax;E12strfluc});
    ylabel('G-Factor ');
                
    saveas(gcf,fullfile([pathname '\' folder],[ folder ' G-Factor.png'])); %gcf = get current file
    save([ pathname folder ' metadata.mat']);            
    close all
end


close all
