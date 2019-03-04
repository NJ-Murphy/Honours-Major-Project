%% AMF Research Project: Flow Toxicity on the JSE 
%% data science script
%
% Author: N.J. Murphy
%
% Person Version:
% AMF-Project-NJM-715798_NMurphy_23-11-2016_Science_LR-data_science_001
%
% 1 Problem Specification:  This script aims to replicate the calclations and analysis from 
%   Easley et al[1] for stocks listed in the top 40 of the Johannesburg Stock Exchange(JSE).

%
% 2 Data Specification: 6 months worth of order book data for 16 stocks listed
%   on the JSE Top 40. The specified period is from 01 January 2013 to 03
%   June 2013. 
%   
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
% [1] D.Easley, M.López de Prado, M.O’Hara. Flow toxicity and liquidity 
%     in a highv frequency world. Review of Financial Studies, February, 2012.
% [2] D.Easley, N.Kiefer, M.O’Hara, J.Paperman. Liquidity, Information, and 
%     Infrequently Traded Stocks. Journal of Finance, September, 1996.
% [3] D.Abada, J.Yagüeb. From PIN to VPIN: An introduction to order flow toxicity. 
%     The Spanish Review of Financial Economics, 2012.
% [4] R.Engle, J.Lange. Predicting VNET: A Model of the Dynamics of Market 
%     Depth, Journal of Financial Markets, 4: 113-142, 2001.
% [5] W.C.Wei, D.Gerace, A.Frino. Informed Trading, Flow Toxicity and the Impact 
%     on Intraday Trading Factors. Australasian Accounting, Business and Finance 
%     Journal, 7(2), 2013.
%
% 6 Current Situation: VBS_ADV001aa
% 7 Future Situation:  
%
% Uses: This script will be used calculate the VPIN given the output of the
% data processing for the bulk classification algorithm but changes the
% calulcation of the price changes to not be expanded observations
 

%% 1. Data Description 

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


%% 2. Data Cases
%1) Trade entry with zero volume
% {'GRTJ.J','01-NOV-2013','09:00:09.315846','2013-11-01T09:00:09.315Z','Trade',2550,0,0}

%2) Trades occurring after 17:00
%{'AGLJ.J','07-NOV-2013','17:00:05.746125','2013-11-07T17:00:05.746Z','Trade',25283,363506,25602.5000000000,9765625,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:00:05.746125','2013-11-07T17:00:05.746Z','Trade',25659,0,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:00:30.967130','2013-11-07T17:00:30.967Z','Quote',0,0,0,0,0,25416,20205;
% 'AGLJ.J','07-NOV-2013','17:06:14.197755','2013-11-07T17:06:14.197Z','Trade',25283,39430,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:10:12.394170','2013-11-07T17:10:12.394Z','Trade',25602,8000,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:26:44.908276','2013-11-07T17:26:44.908Z','Trade',25485,10460,0,0,0,0,0;
% 'AGLJ.J','07-NOV-2013','17:26:45.448335','2013-11-07T17:26:45.448Z','Trade',25548,20358,0,0,0,0,0}

%{'GRTJ.J','06-NOV-2013','16:49:19.253191',2483,429;
% 'GRTJ.J','06-NOV-2013','17:00:02.488567',2480,599771;
% 'GRTJ.J','06-NOV-2013','17:24:55.045941',2477,76385}

%3) No trade occurs over consecutive time bars- thus no price shift nor volume will be
%entered into these time bars 
%{'GRTJ.J','01-NOV-2013','11:33:57.686807',2533,1008;'GRTJ.J','01-NOV-2013','11:37:11.160757',2533,1399}

%4) Empty time bars where no trade occurs(rows 2 and 3 below)
%{'01-NOV-2013','10:16:00.000','10:17:00.000',[2x5 cell' char(10) '],[];
%'01-NOV-2013','10:17:00.000','10:18:00.000',[],[];'01-NOV-2013','10:18:00.000','10:19:00.000',[],[];
%'01-NOV-2013','10:19:00.000','10:20:00.000',[],[];'01-NOV-2013','10:20:00.000','10:21:00.000',[],[];
%'01-NOV-2013','10:21:00.000','10:22:00.000',[3x5 cell' char(10) '],[]}


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
projectpath = 'AMF/AMF_FinalProject_NJM_715798';   %path for personal computer
addpath(fullfile(userpathstr,projectpath,'Functions'));
addpath(fullfile(userpathstr,projectpath,'Scripts'));
addpath(fullfile(userpathstr,projectpath,'html'));
addpath(fullfile(userpathstr,projectpath,'Data'));
figpath = 'C:\Users\Nicholas\Documents\Work\Varsity\AMF\Project\Semester 2\Proposal\Plots';

% Filepath to input data   
[datafilepath] = 'C:\Users\Nicholas\Documents\MATLAB\AMF\AMF_FinalProject_NJM_715798\Data\Final';  %path to data on personal computer


%% 5. Load Data
% Step 1: Load the Lee-Ready data
%[dataLR] = load(fullfile(datafilepath,'\JanJunLR1_12')); %load the matfile
[dataLR] = load(fullfile(datafilepath,'\JanJunLR13_16')); %load the matfile

% Step 2: Extract only data   
dataLR = dataLR.myJobOutput; 

% Step 3: Load the Bulk Classification data
[dataBC] = load(fullfile(datafilepath,'\JanJunBC1_17')); %load the matfile

% Step 4: Extract only data   
dataBC = dataBC.myJobOutput; 

%% 6. Calculate and plot VPIN

% Initialise variables
 noofstocks = dataLR.noofstocks; %specify number of stocks to be analysed and processed 
 stock_timebars = cell(1,noofstocks);  %initialise array to store all time bars for each stock
 samplesize = 50;  %define the number of buckets used in order to update VPIN
 VBS_BC = zeros(1,noofstocks); %volume bucket size BC
 AveVPIN_BC = zeros(1,noofstocks); %average VPIN value for each stock
 VBS_LR = zeros(1,noofstocks); %volume bucket size LR
 AveVPIN_LR = zeros(1,noofstocks);
 plotnum = 0;
 VPINStDev_LR = zeros(1,noofstocks);
 VPINStDev_BC = zeros(1,noofstocks);
  
 for n = 1:noofstocks  % loop over stocks  
  %VPIN:
  %Iterate over the tima bar data and as soon as the threshold of 50 buckets 
  %is reached, expand the number observations of delta p by repeating deltap as
  %many times as the total volume in the 50 bucket sample and compute the VPIN metric. 
  %For each row in the sample, use the given probabilistic method to classify buyer 
  %and seller initiated volume for the time bar. The buyer volume is
  %calculated using the value of the normal distribution evaluated over the
  %price change of the given bar standardised by the standard deviation of
  %the expanded sample price changes. The seller volume is just the complement of the
  %probability measure for buyers. We then multiply the volume of the time bar
  %by the buyer and seller probability measures to get the buyer and seller
  %volume for each time bar. 
  
  %extract the name for the nth stock
  stockname = dataLR.RICstore{1,n+lrstep}; 
  title_stock = strcat(stockname(1:3)); % create title 
  
  % Exctract VPIN data for each method 
  VPIN_LR = dataLR.VPINstore{1,n};
  VPIN_BC = dataBC.VPINstore{1,n}; 
 
  % Remove Nans
  VPIN_BC(any(isnan(cell2mat(VPIN_BC(:,3))),2),:) = [];
  VPIN_LR(any(isnan(cell2mat(VPIN_LR(:,3))),2),:) = [];
  
  % Compute log changes in mid price
  logchangesmidprice_BC = log(cell2mat(VPIN_BC(2:end,4)))-log(cell2mat(VPIN_BC(1:end-1,4)));
  logchangesmidprice_BC(any(logchangesmidprice_BC(:)==Inf | logchangesmidprice_BC(:)==-Inf,2),:) = [];
  % Compute log changes in mid price
  logchangesmidprice_LR = log(cell2mat(VPIN_LR(2:end,4)))-log(cell2mat(VPIN_LR(1:end-1,4)));
  logchangesmidprice_LR(any(logchangesmidprice_LR(:)==Inf | logchangesmidprice_LR(:)==-Inf,2),:) = [];
  
  % Standard deviation of VPIN
  VPINStDev_LR(n,1) = std(cell2mat(VPIN_LR(:,3)));
  VPINStDev_BC(n,1) = std(cell2mat(VPIN_BC(:,3)));
  
  % Extract StDev of price changes
  VPINstd = cell2mat(VPIN_BC(:,5));
  
  % Compute average VPIN for n-th stock
  AveVPIN_BC(n,1) = mean(cell2mat(VPIN_BC(:,3)));
  AveVPIN_LR(n,1) = mean(cell2mat(VPIN_LR(:,3)));
  
  % VPIN Skews
  VPINskew_BC(n,1) = skewness(cell2mat(VPIN_BC(:,3)));
  VPINskew_LR(n,1) = skewness(cell2mat(VPIN_LR(:,3)));
  
  % Extract VBS's
  VBS_LR(n,1) = dataLR.VBS(1,n);  
  VBS_BC(n,1) = dataBC.VBS(1,n); 
  
  % Compute data needed for x-axis 
  for i = 1:length(VPIN_LR) 
     [yrlr(i),mtlr(i),dylr(i),~,~,~]= datevec(VPIN_LR{i,1});
  end
  Startdateplot = datenum(2013,01,02);
  [d] = datenum(yrlr,mtlr,dylr);
  xData_LR = linspace(d(1),d(end),length(VPIN_LR));
  xDatamid_LR = linspace(d(1),d(end),length(logchangesmidprice_LR));
  dateV_LR = Startdateplot:d(1,end);
  
  for i = 1:length(VPIN_BC) 
    [yrbc(i),mtbc(i),dybc(i),~,~,~] = datevec(VPIN_BC{i,1});
  end 
  [d_BC] = datenum(yrbc,mtbc,dybc);
  xData_BC = linspace(d_BC(1),d_BC(end),length(VPIN_BC));
  xDatamid_BC = linspace(d_BC(1),d_BC(end),length(logchangesmidprice_BC));
  xDatastd = linspace(d(1),d(end),length(VPINstd));
  dateV_BC = Startdateplot:d_BC(1,end);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot VPIN versus dates %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(n+plotnum)
  subplot(2,2,[1 2])
  h1 = plot(xData_BC,cell2mat(VPIN_BC(:,3)),xData_LR ,cell2mat(VPIN_LR(:,3)));
  hold on 
  hax1 = get(h1(1), 'Parent'); % axes handle
  set(gca,'XTickLabelRotation',50)%,'xticklabel',datestr(xData_BC(1:200:end),'dd-mmm-yyyy'))
  set(hax1(1), 'XTick', dateV_BC(1:15:end)); 
  datetick('x','dd-mmm-yy','keepticks')
  ylim([0,0.9])
  xlim([Startdateplot (d(end)+1)])

  % plot VPIN Peak
  [Peak_LR, PeakIdx_LR] = findpeaks(cell2mat(VPIN_LR(:,3)));
  [Peak_BC, PeakIdx_BC] = findpeaks(cell2mat(VPIN_BC(:,3)));
  Peak_BC = max(Peak_BC);
  Peak_LR = max(Peak_LR);
  indexmax_BC = find(max(cell2mat(VPIN_BC(:,3))) == cell2mat(VPIN_BC(:,3)));
  indexmax_LR = find(max(cell2mat(VPIN_LR(:,3))) == cell2mat(VPIN_LR(:,3)));
  plot(xData_BC(indexmax_BC(1)),Peak_BC,'ko','MarkerSize',6,'MarkerFaceColor','[.49 1 .9]')  
  
  % plot minimum point 
  indexmin_BC = find(min(cell2mat(VPIN_BC(:,3))) == cell2mat(VPIN_BC(:,3)));
  indexmin_LR = find(min(cell2mat(VPIN_LR(:,3))) == cell2mat(VPIN_LR(:,3)));
  plot(xData_BC(indexmin_BC(1)),min(cell2mat(VPIN_BC(:,3))),'ko','MarkerSize',6,'MarkerFaceColor','[1 .5 0]') % 
  plot(xData_LR(indexmax_LR(1)),Peak_LR,'ks','MarkerSize',6,'MarkerFaceColor','g')  
  plot(xData_LR(indexmin_LR(1)),min(cell2mat(VPIN_LR(:,3))),'ks','MarkerSize',6,'MarkerFaceColor','r') % 

  % title and labels   
  title1 = strcat(title_stock,{': '},{'VPIN vs Time'});
  title(title1)  
  legend('VPIN Bulk-Classification (BC)','VPIN Lee-Ready (LR)','VPIN BC  Max','VPIN BC Min','VPIN LR  Max','VPIN LR Min','Location','Best')
  xlabel('Date')
  ylabel(hax1,'VPIN') 
  hold off
  
  %%%%%%%%%%%%%%%%%%%
  % plot miquote BC %
  %%%%%%%%%%%%%%%%%%%
  subplot(2,2,3)
  h2 = plot(xDatamid_BC(1:end),logchangesmidprice_BC(:));
  hold on
  hax2 = get(h2, 'Parent'); % axes handle
  set(gca,'XTickLabelRotation',50,'FontSize',8)
  set(hax2, 'XTick', dateV_BC(1:15:end)); 
  datetick('x','dd-mmm-yy','keepticks')
    
  % plot maximum point
  indexmaxmid_BC = find(max(logchangesmidprice_BC(:)) == logchangesmidprice_BC(:));
  plot(xDatamid_BC(indexmaxmid_BC(1)),max(logchangesmidprice_BC(:)),'ko','MarkerSize',6,'MarkerFaceColor','g') % 
  % plot minimum point
  indexminmid_BC = find(min(logchangesmidprice_BC(:)) == logchangesmidprice_BC(:));
  plot(xDatamid_BC(indexminmid_BC(1)),min(logchangesmidprice_BC(:)),'ko','MarkerSize',6,'MarkerFaceColor','r') % 
  
  % titles, labels and axes
  xlim([Startdateplot (d(end)+1)])
  title2 = strcat(title_stock,{': '},{'Change in log-midquote price Bulk Classification'});
  title(title2) 
  xlabel('Date')
  ylabel(hax2(1),'$\triangle$ log-midquote','interpreter','latex','FontSize', 11)  
  h0 = legend('$\triangle$ log-midquote','Midquote Max','Midquote Min','Location','Best')
  set(h0,'Interpreter','latex')
  hold off
  
  %%%%%%%%%%%%%%%%%%%
  % plot miquote LR %
  %%%%%%%%%%%%%%%%%%%
  subplot(2,2,4)
  h2 = plot(xDatamid_LR(1:end),logchangesmidprice_LR(:));
  hold on
  hax2 = get(h2, 'Parent'); % axes handle
  set(gca,'XTickLabelRotation',50,'FontSize',8)
  set(hax2, 'XTick', dateV_BC(1:15:end)); 
  datetick('x','dd-mmm-yy','keepticks')
    
  % plot maximum point
  indexmaxmid_LR = find(max(logchangesmidprice_LR(:)) == logchangesmidprice_LR(:));
  plot(xDatamid_LR(indexmaxmid_LR(1)),max(logchangesmidprice_LR(:)),'ko','MarkerSize',6,'MarkerFaceColor','g') % 
  % plot minimum point
  indexminmid_LR = find(min(logchangesmidprice_LR(:)) == logchangesmidprice_LR(:));
  plot(xDatamid_LR(indexminmid_LR(1)),min(logchangesmidprice_LR(:)),'ko','MarkerSize',6,'MarkerFaceColor','r') % 
  
  % titles, labels and axes
  xlim([Startdateplot (d(end)+1)])
  title2 = strcat(title_stock,{': '},{'Change in log-midquote price Lee-Ready'});
  title(title2) 
  xlabel('Date')
  ylabel(hax2(1),'$\triangle$ log-midquote','interpreter','latex','FontSize', 11)  
  h2 = legend('$\triangle$ log-midquote','Midquote Max','Midquote Min','Location','Best');
  set(h2,'Interpreter','latex')
  hold off
  
  %%%%%%%%%%%%%%%
  % save figure %
  %%%%%%%%%%%%%%%
  savetoname = char(strcat(figpath,'\',title_stock));
  fig = gcf;
  fig.PaperUnits = 'centimeters';
  fig.PaperPosition = [0 0 23 20]; %proposal size
  print(savetoname,'-dpng','-r300')
  
  %%%%%%%%%%%%%%%%%%%%%%
  % plot StDev vs time %
  %%%%%%%%%%%%%%%%%%%%%%
  figure(n+plotnum+1)
  hl = plot(xDatastd,VPINstd); 
  hold on
  hax3 = get(hl, 'Parent'); % axes handle
  set(gca,'XTickLabelRotation',50)
  set(hax3, 'XTick', dateV_BC(1:15:end)); 
  datetick(hax3,'x', 'dd-mmm-yy', 'keepticks');
  
  % plot maximum point
  indexmaxstd = find(max(VPINstd) == VPINstd);
  plot(xDatastd(indexmaxstd(1)),max(VPINstd),'ko','MarkerSize',6,'MarkerFaceColor','g') %
  % plot minimum point
  indexminstd = find(min(VPINstd) == VPINstd);
  plot(xDatastd(indexminstd(1)),min(VPINstd),'ko','MarkerSize',6,'MarkerFaceColor','r') % 
  
  % titles, labels and axes
  title3 = strcat(title_stock,{': '},{'StDev of price changes corresponding to each 50 bucket sample'});
  title(title3) 
  xlabel('Date')
  ylabel('$\sigma_{\triangle P}$ (50)','interpreter','latex','FontSize', 15)   
  xlim([Startdateplot (d(end)+1)])
  h = legend('$\sigma_{\triangle P}$ (50)','StDev Max','StDev Min','Location','Best');
  set(h,'Interpreter','latex')
  hold off
  
  %%%%%%%%%%%%%%%
  % save figure %
  %%%%%%%%%%%%%%%
  savetoname = char(strcat(figpath,'\',title_stock,'_StDev'));
  fig = gcf;
  fig.PaperUnits = 'centimeters';
  fig.PaperPosition = [0 0 16 7];
  print(savetoname,'-dpng','-r300')
  
  plotnum = n+1;
  % Remove variables 
  clearvars d dataV yr mt dy xData logchangesmidprice_BC x1 xtime = [];
 end