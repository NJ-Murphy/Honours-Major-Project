%% AMF Research Project: Computing VPIN: Bulk Classification vs. Lee-Ready
%% data_processing_script_LR_715798
%
% Author: N.J. Murphy
%
% Person Version:
% AMF-Project-NJM-715798_NMurphy_30-11-2016_L-R-005_data-processing-script-LR
%
% 1 Problem Specification:  This script aims to replicate the calclations and analysis from 
%   Easley et al[1] for stocks listed in the top 40 of the Johannesburg Stock Exchange(JSE).
%
% 2 Data Specification: 6 months worth of order book data for 16 stocks listed
%   on the JSE Top 40. The specified period is from 01 January 2013 to 03 June
%   2013. 
%   In order to run and publish this script, 2 stocks were ralabelled in order
%   to loop over a 2 week period and 2 stocks from the test data was
%   used.
%   
% 3 Configuration Control:
%        userpath/MATLAB/AMF
%        userpath/MATLAB/AMF/AMF_Project_NJM_715798       
%        userpath/MATLAB/AMF/AMF_Project_NJM_715798/Scripts    
%        userpath/MATLAB/AMF/AMF_Project_NJM_715798/Functions 
%        userpath/MATLAB/AMF/AMF_Project_NJM_715798/Data
%        userpath/MATLAB/AMF/AMF_Project_NJM_715798/html        
%
% 4 Version Control: No current version control
%
% 5 References: 
% [1] D. Easley, M. L\`{o}pez de Prado,M. O'Hara. Flow toxicity and liquidity 
%     in a highv frequency world. Review of Financial Studies, February, 2012.
% [2] D.Easley, N.Kiefer, M.O'Hara, J.Paperman. Liquidity, Information, and 
%     Infrequently Traded Stocks. Journal of Finance, September, 1996.
% [3] D.Abada, J.Yag\"{u}eb. From PIN to VPIN: An introduction to order flow toxicity. 
%     The Spanish Review of Financial Economics, 2012.
% [4] R.Engle, J.Lange. Predicting VNET: A Model of the Dynamics of Market 
%     Depth, Journal of Financial Markets, 4: 113-142, 2001.
% [5] W.C.Wei, D.Gerace, A.Frino. Informed Trading, Flow Toxicity and the Impact 
%     on Intraday Trading Factors. Australasian Accounting, Business and Finance 
%     Journal, 7(2), 2013.
%
% 6 Current Situation: data_processing_script_LR_715798
% 7 Future Situation: no future situation
%
% Uses: This script will be the final data processing script for
% implementing the Lee-Ready algorithm to calculate VPIN
 

%% 1. Data Description 
%
% 1  RIC               - Reuters instrument code.
%                              A Reuters instrument code, or RIC, is a ticker
%                              like code used by Thomson Reuters to identify
%                              financial instruments and indices.
% 
% 2   DateL            - Date of transaction.
% 3   TimeL            - Time of transaction.
% 4   DateTimeL        - Date and time of transaction.
% 5   Type             - Type of transaction: * Auction
%                                             * Quote
%                                             * Trade
% 6   Price            - Price of transaction for auction and trade
% 7   Volume           - Volume of tramsaction for auction and trade
% 8   MarketVWAP       - Market Volumes Weighted average prices
%                        = sum(shares bought * share price)/(Total shares bought)
% 9   L1BidPrice       - The price a buyer is willing to pay
% 10  L1BidSize        - The size of order a buyer wishes to achieve
% 11  L1AskPrice       - The price the seller is willing to offer
% 12  L1AskSize        - The size of order the seller wishes to achieve
%


%% 2. Data Cases
% 1) Trade entry with zero volume
% {'GRTJ.J','01-NOV-2013','09:00:09.315846','2013-11-01T09:00:09.315Z','Trade',2550,0,0}

% 2) Trades occurring after 17:00
% {'AGLJ.J','07-NOV-2013','17:00:05.746125','2013-11-07T17:00:05.746Z','Trade',25283,363506,25602.5000000000,9765625,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:00:05.746125','2013-11-07T17:00:05.746Z','Trade',25659,0,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:00:30.967130','2013-11-07T17:00:30.967Z','Quote',0,0,0,0,0,25416,20205;
% 'AGLJ.J','07-NOV-2013','17:06:14.197755','2013-11-07T17:06:14.197Z','Trade',25283,39430,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:10:12.394170','2013-11-07T17:10:12.394Z','Trade',25602,8000,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:26:44.908276','2013-11-07T17:26:44.908Z','Trade',25485,10460,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:26:45.448335','2013-11-07T17:26:45.448Z','Trade',25548,20358,0,0,0,0,0}

% {'GRTJ.J','06-NOV-2013','16:49:19.253191',2483,429;
% 'GRTJ.J','06-NOV-2013','17:00:02.488567',2480,599771;
% 'GRTJ.J','06-NOV-2013','17:24:55.045941',2477,76385}

% 3) No trade occurs over consecutive time bars- thus no price shift nor volume will be
% entered into these time bars 
% {'GRTJ.J','01-NOV-2013','11:33:57.686807',2533,1008;'GRTJ.J','01-NOV-2013','11:37:11.160757',2533,1399}

% 4) Empty time bars where no trade occurs(rows 2 and 3 below)
% {'01-NOV-2013','10:16:00.000','10:17:00.000',[2x5 cell' char(10) '],[];
% '01-NOV-2013','10:17:00.000','10:18:00.000',[],[];'01-NOV-2013','10:18:00.000','10:19:00.000',[],[];
% '01-NOV-2013','10:19:00.000','10:20:00.000',[],[];'01-NOV-2013','10:20:00.000','10:21:00.000',[],[];
% '01-NOV-2013','10:21:00.000','10:22:00.000',[3x5 cell' char(10) '],[]}


%% 3. Clear Workspace
% This section prepares the workspace for the implementation of the script.
close all;      % close any open figures
clc;            % clear command window
format long g;  % formating for output on comand window
format compact; % formating for output on comand window


%% 4. Path Setup
% Set the project paths
[projectPath] = pwd;
% Add the project path so that the script sees the necessary functions
addpath(projectPath);
userpathstr = userpath;
userpathstr = userpathstr(~ismember(userpathstr,';'));
%projectpath = 'AMF/AMF_FinalProject_NJM_715798';   %path for personal computer
projectpath = 'AMF_FinalProject_NJM_715798';   %path for AMF machine
addpath(fullfile(userpathstr,projectpath,'Functions'));
addpath(fullfile(userpathstr,projectpath,'Scripts'));
addpath(fullfile(userpathstr,projectpath,'html'));

% # Filepath to input data
% Path to where the data are stored    
%[datafilepath] = 'C:\Users\Nicholas\Documents\MATLAB\AMF\AMF_FinalProject_NJM_715798\Data\Transactions';  %path to data on personal computer
%[datafilepath] = '\\AMF\Data\Transactions\JSE';   %path to CSAM cluster data
[datafilepath] = 'Z:\Data\Transactions\JSE'; % This is the path for data on AMFcluster

%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Process the Data %%
% Trade entries are sorted into buckets of equal size, V, which is
% specified to be the average daily volume over the entire period. The number 
% of buckets is chosen to 50. Once all 50 buckets are complete, the VPIN metric 
% is computed. If the last trade needed to complete a bucket is for a 
% size greater than required, the excess size is given to the next bucket.
% The VPIN is then computed after each bucket is filled. This implies,
% for example, if bucket 51 is filled, we will drop the first bucket and 
% computed the VPIN for buckets 2-51. Thus VPIN is calculated in volume-time 
% which is argued to be necessary in the high frequency world. Perform steps to 
% remove extraneous data and data falling outside the continuous trading session.

noofstocks = 7; %specify number of stocks to be analysed and processed
VPINstore = cell(1,noofstocks);  %initialise a cell array to store the timenars for each stock for the entire period
VBS = zeros(1,noofstocks);  %initiate vector to store VBS for each stock
RICstore = cell(1,noofstocks);  %initialise array to store RIC's
outliers = zeros(1,noofstocks);   %initialise vector to store number of outliers

for n = 1:noofstocks  % Loop over stocks
 %%%%%%%%%%%%%%%%%%
 %% 6. Load Data %%
 % The data from the matfile for the specified dates and specified stock is 
 % loaded on each iteration of the loop over stocks. The createdate.m function 
 % is used to generate the required dates from these matfiles.
  
  % Step 1: Generate dates using createdates.m function
  %[startDate] = '01-Jan-2013';  %start date for cluster data
  %[endDate] = '03-Jun-2013';  %end date for cluster data
  [startDate] = '01-Nov-2013';  %start date for test data
  [endDate] = '07-Nov-2013';  %end date for test data
  [TradingDayStart]   = []; % Defaults to 08:30:00
  [TradingDayEnd]     = []; % Defaults to 17:30:00
  [Type]              = []; % Defaults to week
  [s,e] = createdates(startDate,endDate,TradingDayStart,TradingDayEnd,Type); %call createdates function to generate dates

  % Step 2: Predefine variable to store matfile names for each stock
  matfilename = cell(length(e),1);   %create a cell array to store the names of the matfiles
  storedata = cell(length(e),1); %create cell array to store trades for all stocks for entire period
  storequotes = cell(length(e),1); %create cell array to store trades for all stocks for entire period

  for k = 1:length(e)  %loop over weeks
     % Step 3: Pre-define path to the required folder 
    folders = dir(datafilepath);  %directory of the datafilepath
    folderpath = cell(noofstocks,1);  %create a cell array to store the paths for each of the stock folders
    
    % Step 4: construct the matfile name for the required stock and week
    % and extract the data from that matfile
    weekStart = datestr(s{k,1},'ddmmmyyyy_HHMM');
    weekEnd = datestr(e{k,1},'ddmmmyyyy_HHMM');
    folderpath{n} = strcat(datafilepath,'\',folders(28+n).name);  %path to specific stock folder
    [RIC] = folderpath{n}(end-5:end);  %extract stock RIC
    matfilename{k} = strcat(RIC,'-Transactions-',weekStart,'-to-',weekEnd,'.mat');  %retrieve name of required matfile for each week as we iterate over the weeks loop
    
    % Step 5: Load the required order book data
    [data] = load(fullfile(datafilepath,RIC,matfilename{k})); %load the matfile
    
    % Step 6: Extract only data   
    data = data.data; 

    %________________________________________________________________________
    %%%%%%%%%%%%%%
    %% 7. Clean %% 
    % Remove Auction data and get the date-time of all trades in order to extract
    % trade corresponding to the continuos trading session (9:00-16:50).
    % Also remove any trades which have a volume greater than 5 standard
    % deviations form the mean.
    
    % Step 1: Remove all rows which contain NAN's and zeros throughout. Also
    %remove all rows which have an auction price formation.
    data(any(strcmp(data(:,1:5),''),2) | any(isnan(cell2mat(data(:,6:end))),2),:) = []; 
    data(strncmpi(data(:,5),'Auction',1),:) = [];   
  
    % Step 2: Get the date-time of the trades
    [yr,mt,dy,~,~,~] = datevec(data(:,2)); %find year, month and day
    [~,~,~,hr,mn,sc] = datevec(data(:,3));  %find hour, minute and second
    [tradedatetime] = datenum(yr,mt,dy,hr,mn,sc);  %create vector of dates and times 
  
    % Step 3: Remove all events between before 09h00 and after 17h00
    [removalindextime] = (hr<9 | hr>=17| (hr==16&mn>50)); %find indices of such events
    tradedatetime(removalindextime) = [];  %remove entries from date vector
    data(removalindextime,:) = [];  %remove entries from data
   
    % Step 4: Remove unnecessary variables
    clearvars removalindextime yr mt dy hr mn sc tradedatetime 
  
    % Step 5: Remove trades which have a volume greater than 3 standard
    % deviations form the mean
    nooftradesbefore = length(data);  %calculate the number of trade entries before removing outliers
    data(mean(cell2mat(data(:,7))) + 5*std(cell2mat(data(:,7)))< cell2mat(data(:,7)),:) = []; %remove all rows with a volume greater than 3 standard
    % deviations form the mean
    nooftradesafter = length(data); %calculate the number of trade entries after removing outliers
    noofoutliers = nooftradesbefore-nooftradesafter;  %number of ouliers removed
  
    %________________________________________________________________________
    %%%%%%%%%%%%%%%%%%
    %% 8. Lee-Ready %%
    % Implement the Lee-Ready algorithm to distinguish buyer-initiated from
    % seller-initiated trades. We first check if the transaction obeys the
    % quote rule and if that fails we then implement the tick rule. The quote 
    % rule states: Transactions which occur at prices higher(lower) than the 
    % midquote are classified as being buyer-initiated(buyer-initiated). If
    % the transaction does not obey the quote rule we move onto the tick
    % rule which states: Transactions which occur at a price that equals the
    % midquote but is higher(lower) than the previous transaction price are 
    % classified as being buyer-initiated (seller-initiated).If there is no price 
    % change but the previous tick change was up (down), then the trade is
    % classified as a buy (sell).
    
    % Step 1: Create a new data set which contain all quote entries from compactdata and
    % get extraction indices to extract daily data from this dataset.
    quotedata = data(strncmpi(data(:,5),'Quote',1),:);  %all quote entries

    [~,uniqueday] = unique(datenum(quotedata(:,2)),'first'); %find the indices for each day
    [daystart] = uniqueday(1:end);  %find the indices for the start of each day
    [dayend] = [uniqueday(2:end)-1;size(quotedata,1)]; %find the indices for the end of each day
     
    % Step 2: Drop down all bid/ask prices and volumes into cells which have zero
    % bid/ask prices and volumes and then calculate the midquote for each
    % quote entry
    quotedata(:,13) = {0}; %create column
    for i = 1:length(dayend)   %loop over days
       for j = (daystart(i)+1):dayend(i)  %loop from beginning of day to end of day
          if cell2mat(quotedata(j,9:10)) == 0   
             quotedata(j,9:10) = quotedata(j-1,9:10);  %find the previous best bid price and volume if the cells contain zeros
          elseif cell2mat(quotedata(j,11:12)) == 0 
             quotedata(j,11:12) = quotedata(j-1,11:12);  %find the previous best ask price and volume if the cells contain zeros
          end
          if quotedata{j,9} ~= 0 && quotedata{j,11} ~= 0
            quotedata{j,13} = (quotedata{j,9} + quotedata{j,11})/2;  %Calculate the mid-quotes
          end
       end
    end
    data(:,13) = {0}; %create column of zeros
    data(strncmpi(data(:,5),'Quote',1),:) = quotedata;  %Fill the quotes back into the alldata set
    clearvars uniquedayq daystartq dayendq   
    
    % Step 3: Get extraction indices to extract daily data from compactdata set.
    [~,uniqueday] = unique(datenum(data(:,2)),'first');  %find the indices for each day
    [daystart] = uniqueday(1:end);
    [dayend] = [uniqueday(2:end)-1;size(data,1)]; 
      
    % Step 4: Find all rows in which a trade occurred as the first entry in the data set on a particular day
    for i = 1:length(dayend)
      if strncmpi(data(daystart(i),5),'Trade',1) == 1 
         j=0;
         while strncmpi(data(daystart(i)+j,5),'Trade',1) == 1
           data(daystart(i)+j,5) = {'Remove'};  %label all rows in which a trade occurred as the first entry in the data 
                                                              %set on a particular day with 'Remove' for removing later
           j = j+1;
         end
     end
   end

   data(strncmpi(data(:,5),'Remove',1),:) = [];  
        
   % Step 5: Recalculate indices for daily data
   [~,uniqueday] = unique(datenum(data(:,2)),'first');  %recalculate the indices for each day since transaction that were the first entry of the day were removed
   [daystart] = uniqueday(1:end);  %find the indices for the start of each day
   [dayend] = [uniqueday(2:end)-1;size(data,1)];  %find the indices for the end of each day
      
   % Step 6: Implement the Lee-Ready algorithm
   data(:,14) = {''};  %create column of zeros
   for i = 1:length(dayend)  %loop over the days 
     for j = (daystart(i)+1):dayend(i)  %loop from the beginning to the end of the day
       if strncmpi(data(j,5),'Trade',1) == 1   %check if a transaction has taken place
          % Quote Rule 
             if  strncmpi(data(j-1,5),'Quote',1) == 1 && isempty(cell2mat(data(j-1,13))) == 1  %row before the transaction is a quote and does not
                                                                                         % have a mid-quote since it is at the beginning of the day
                if data{j,6} == data{j-1,9}  
                   data{j,14} = -1;  %since the bid was hit, it is a market sell
                else
                   data{j,14} = 1;  %since the ask was hit, it is a market buy
                end
            elseif strncmpi(data(j-1,5),'Quote',1) == 1 && data{j,6} > data{j-1,13}  %the row before transaction is a quote and 
                                                                                     %trade price is greater than the midquote
                data{j,14} = 1;  %classify as buy
            elseif strncmpi(data(j-1,5),'Quote',1) == 1 && data{j,6} < data{j-1,13}  %the row before transaction is a quote and 
                                                                                     %trade price is less than the midquote
                data{j,14} = -1;  %classify as sell
          % Tick Rule
            elseif strncmpi(data(j-1,5),'Quote',1) == 1 && data{j,6} == data{j-1,13}  %the row before transaction is a quote and trade 
                                                                                      %price is equal to the midquote
                if cell2mat(data(find([data{daystart(i):j-1,6}],1,'last')+ daystart(i)-1,6)) <...
                   data{j,6}  %current trade is greater than the most recent trade
                   data{j,14} = 1;  %classify as buy
                elseif cell2mat(data(find([data{daystart(i):j-1,6}],1,'last')+ daystart(i)-1,6)) >...
                   data{j,6}  %current trade is less than the most recent trade
                   data{j,14} = -1;  %classify as sell
                elseif cell2mat(data(find([data{daystart(i):j-1,6}],1,'last')+ daystart(i)-1,6)) ==...
                   data{j,6}  %current trade is equal to the most recent trade
                   data{j,14} = cell2mat(data(find([data{daystart(i):j-1,6}],1,'last')+ daystart(i)-1,14));
                end
            elseif strncmpi(data(j-1,5),'Trade',1) == 1  %two trades happen in succession 
                if data{j,6} == data{j-1,6}  %first trade price is equal to the second trade price
                   data{j,14} = data{j-1,14};  %classify transaction the same as what the first one was classified
                elseif data{j,6} > data{j-1,6}  %first trade price is greater than the second trade price
                    data{j,14} = 1;  %classify as buy
                elseif data{j,6} < data{j-1,6}  %first trade price is less than the second trade price
                    data{j,14} = -1;  %classify as sell
                end
             end
        end
     end
   end   
  
   %________________________________________________________________________
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% 9. Trade and Quote Data %%
   % Extract only the trade data for entire period for
   % the nth stock. 
  
   % Step 1: Extract only trades
   trades = data(strncmpi(data(:,5),'Trade',1),:);  %extract only trade data
   
   % Step 2: Remove all unneccessary data- columns 8 to 12,rows
   % with zero trade volume and rows 4 and 5 which contain information we
   % will not need.
   trades(:,8:13) = [];
   trades(cell2mat(trades(:,7))==0,:) = [];
   trades(:,4:5) = [];
  
   % Step 3: store data for the nth stock for the kth week
   storedata{k,1} = trades;
   storequotes{k,1} = quotedata;

  end  
  
  quotedata = vertcat(storequotes{1:end,1});  %all quote entries
  tradedata = vertcat(storedata{1:end,1});  %extract trades for nth stock for entire period
  clearvars trades storedata storequotes data
  
  %________________________________________________________________________
  %%%%%%%%%%%%%%%%%%%%%
  %% 10. VBS and ADV %% 
  % Calculate volume bucket size(VBS) based on average daily volume(ADV)over the entire period.
  % We will choose a sample of 50 buckets per calculation of
  % VPIN as specified by the authors. The VBS will then be the ADV divided
  % by the number of buckets(50).
  
  % Step 1: Calculate indices for daily data
  [~,uniqueday] = unique(datenum(tradedata(:,2)),'first');  %recalculate the indices for each day since transaction that were the first entry of the day were removed
  [daystart] = uniqueday(1:end);  %find the indices for the start of each day
  [dayend] = [uniqueday(2:end)-1;size(tradedata,1)];  %find the indices for the end of each day
      
  dailyvol = zeros(length(daystart),1);  %initialise daily volume for the nth stock
  
  for i = 1:length(daystart)  %loop over days
    dailyvol(i,1) = sum(cell2mat(tradedata(daystart(i):dayend(i),5)));  %compute total daily volume 
  end
  avedailyvol = sum(dailyvol(:,1))/length(daystart);  %compute average daily volume for the nth stock
  
  % Step 2: Compute the bucket size and define the number of buckets 
  noofbuckets = 50;  %define the number of buckets used to calulate the VBS
  VBS(1,n) = round(avedailyvol/noofbuckets,0);  %define VBS to be one fiftieth of average daily volume
  clearvars dayend daystart uniqueday dailyvol
  
  %________________________________________________________________________
  %%%%%%%%%%%%%%%%%%%%%%%%
  %% 11. Volume Buckets %%
  % Iterate through the trades and sum up the volumes of 
  % of the entries until the VBS threshold is reached. Assign the given set of
  % trades the current bucket index. If the last trade in the given set of
  % trades which make up the volume of the tau-th bucket is of volume greater than 
  % that required to fill the volume bucket, the last trade is broken up into
  % 2 parts where one will fill the most recent bucket and the excess volume will be given 
  % to the next bucket. 
  
  % Step 1: initiate variables needed for the volume bcuketing 
  bucketind = 0; %initialise index for finding the index of time bars for which a bucket will be completed
  tau = 1;  %initialise index for storing the time bar index at each completion of a bucket
  
  % Step 2: Set up a loop over entire sample of data in order to find
  % indices for time bars where buckets will strart and end. The
  % excess volume in a given bucket is transferred to the next bucket along
  % with the corresponding price change
  i =0 ;
  while i < length(tradedata)  
    if sum(cell2mat(tradedata((bucketind(tau)+1):i,5))) >= VBS(1,n) %find index for time bar where a bucket will be completed
      excess = sum(cell2mat(tradedata((bucketind(tau)+1):i,5))) - sum(cell2mat(tradedata((bucketind(tau)+1):(i-1),5))) - VBS(1,n) + sum(cell2mat(tradedata((bucketind(tau)+1):(i-1),5))); %calculate the excess volume in the current bucketind which will be given to next bucket
      tradedata{i,5} = VBS(1,n) - sum(cell2mat(tradedata((bucketind(tau)+1):(i-1),5)));  %complete the current volume bucket with the required amount of volume  
      tradedata((i+1):(end+1),:) = tradedata((i):(end),:);  %create an extra time bar with the same times as the i-th time bar since extra volume must be carried over to next bucket
      tradedata{i+1,5} = excess;  %amount of volume the next bucket has received from previous bucket
      tradedata((bucketind(tau)+1):i,7) = {tau};  %assign the trade a bucket index 
      tau = tau + 1;  %add one to bucket counter
      bucketind(tau) = i;  %store the index of the time bar for which the bucket will be filled  
    end
  i = i + 1;  %add one to the while loop counter
  end
  
  %________________________________________________________________________
  %%%%%%%%%%%%%%
  %% 12. VPIN %%
  % Iterate over the trade bar data and as soon as the threshold of 50 buckets 
  % is reached and compute the VPIN metric. 
  % For each bucket, sum up the transaction buy and sell volumes and print the 
  % order imbalance at the time the last trade occurred. Compute VPIN and extract the 
  % midquote at the time VPIN was printed.
 
  % Step 1: Gather necessary inputs for calculation
  [~,uniquebucket] = unique(cell2mat(tradedata(:,7)),'first');  %find the total number of buckets in the time bar data
  [bucketstart] = uniquebucket(1:end);  %find the indices for the start of each day
  [bucketend] = [uniquebucket(2:end)-1;find(cell2mat(tradedata(:,6)),1,'last')]; 
  totalbuckets = unique(cell2mat(tradedata(:,7)),'first');  %total number of buckets in the sample for the n-th stock   
  noofvpins = length(totalbuckets) - 50 + 1;  %calculate the number of times VPIN will be updated
  VPIN = cell(noofvpins,3); %initialise a vector to store dates, times and VPIN metric
  samplesize = 50;  %define the number of buckets used in order to update VPIN
  
  % Step 2: Compute serial dates for quote data
  [yrq,mtq,dyq,~,~,~] = datevec(quotedata(:,2)); %find year, month and day
  [~,~,~,hrq,mnq,scq] = datevec(quotedata(:,3));  %find hour, minute and second
  [tradedatetimequotes] = datenum(yrq,mtq,dyq,hrq,mnq,scq);  %create vector of dates and times 
  clearvars uniquebucket hrq dyq mnq mtq scq yrq
  
  for i = 1:noofvpins  %loop over the number of updates of VPIN
    for j = (bucketstart(i)):bucketend(i+samplesize-1)  %loop form 1st bucket in VPIN calculation to the last bucket(50) in the calculation
      if tradedata{j,6} == 1
        tradedata{j,8} = tradedata{j,5};  %compute the buy volume for the jth volume bucket
      elseif tradedata{j,6} == -1
        tradedata{j,9} = tradedata{j,5};  %compute the sell volume for the jth volume bucket
      end
    end
    
    for j = i:(i+samplesize-1)  %loop over the current sample of buckets which we are computing VPIN for
      tradedata{bucketend(j),10} = abs(sum(cell2mat(tradedata(bucketstart(j):bucketend(j),9))) - sum(cell2mat(tradedata(bucketstart(j):bucketend(j),8)))); %compute Order Imbalance for each bucket in the i-th calculation of VPIN
    end
    VPIN{i,3} = sum(cell2mat(tradedata((bucketstart(i)):bucketend(i+samplesize-1),10)))/(samplesize*VBS(1,n));  %compute VPIN for the i-th update of the metric
    VPIN{i,2} = tradedata(bucketend(i+samplesize-1),3); %enter in the time for the corresponding VPIN calculation
    VPIN{i,1} = tradedata(bucketend(i+samplesize-1),2);  %enter in the date of the corresponding VPIN calculation 
    
    % Find mid-quote when VPIN is printed
    % Step 1: Get the date-time of current VPIN
    [yrvpin,mtvpin,dyvpin,~,~,~] = datevec(VPIN{i,1}); %find year, month and day
    [~,~,~,hrvpin,mnvpin,scvpin] = datevec(VPIN{i,2});  %find hour, minute and second
    tradedatetimeVPIN = datenum(yrvpin,mtvpin,dyvpin,hrvpin,mnvpin,scvpin);  %create vector of dates and times 

    VPIN{i,4} = cell2mat(quotedata(find(tradedatetimequotes(:)<=tradedatetimeVPIN,1,'last'),13)); %find the index of the most recent quote which occurred before VPIN was updates
  end    
  
  % Store results
  VPINstore{1,n} = VPIN;  %store the timebars for the n-th stock
  RICstore{1,n} = tradedata{1,1};  %store the RIC for the n-th stock for retrieval
  outliers(1,n) = noofoutliers;  %store the number of outliers for the nth stock
  
  clearvars tradedata tradedatetimequotes quotedata tradedatetimeVPIN...
      VPIN yrvpin dyvpin bucketend bucketstart 
end
%==========================================================================