function [SDates,EDates] = createdates(startDate,endDate,TradingDayStart,TradingDayEnd,Type)

% Creates starting and ending dates for sub periods
% -------------------------------------------------------------------------
%
% $Author: M Harvey$ $Date: 06-Mar-2015 20:21:08$



% EXAMPLES
% [startDate]         = '01-Nov-2013 12:34:43';
% [endDate]           = '31-Dec-2013 15:22:22';
% [TradingDayStart]   = [];
% [TradingDayEnd]     = [];
% [Type]              = [];

% [startDate]         = '01-Nov-2013 12:34:43';
% [endDate]           = '31-Dec-2013 15:22:22';
% [TradingDayStart]   = '10:00';
% [TradingDayEnd]     = [];
% [Type]              = [];

% [startDate]         = '01-Nov-2013 12:34:43';
% [endDate]           = '31-Dec-2013 15:22:22';
% [TradingDayStart]   = '10:00';
% [TradingDayEnd]     = '12:00';
% [Type]              = [];

% [startDate]         = '01-Nov-2013 12:34:43';
% [endDate]           = '31-Dec-2013 15:22:22';
% [TradingDayStart]   = '10:00';
% [TradingDayEnd]     = '12:00';
% [Type]              = 10;

% [startDate]         = '01-Nov-2013 12:34:43';
% [endDate]           = '06-Nov-2013 15:22:22';
% [TradingDayStart]   = '10:00';
% [TradingDayEnd]     = '12:00';
% [Type]              = 'day';

% [startDate]         = '14-Nov-2013 12:34:43';
% [endDate]           = '05-Dec-2013 15:22:22';
% [TradingDayStart]   = '10:00';
% [TradingDayEnd]     = '12:00';
% [Type]              = 'Week';


% [startDate]         = '14-Nov-2013 12:34:43';
% [endDate]           = '05-Dec-2013 15:22:22';
% [TradingDayStart]   = '10:00';
% [TradingDayEnd]     = '12:00';
% [Type]              = 'month';


if isempty(TradingDayStart)
    [TradingDayStart] = '08:30:00';
end

if isempty(TradingDayEnd)
    [TradingDayEnd]   = '17:30:00';
end
if ( rem(datenum( startDate ),1) == 0 )
    [startDate] = cellstr([char(startDate),' ',char(TradingDayStart)]);
end

if ( rem(datenum( endDate ),1) == 0 )
    [endDate] = cellstr([char(endDate),' ',char(TradingDayEnd)]);
end


if isempty(Type) % if type is empty default to week
    [Type] = 7;
elseif (Type == 0) % if type is 0 do nothing
    [SDates] = cellstr( datestr( startDate, 0 ) );
    [EDates] = cellstr(datestr( endDate, 0 ) );
    return;
elseif strncmpi(Type,'month',5)
    [Type] = 'Month';
elseif strncmpi(Type,'week',4)
    [Type] = 7;
elseif strncmpi(Type,'day',3)
    [Type] = 1;
else
    error('createDates:argChk','Unknown type.');
end

switch ( ischar(Type) & ( strncmp(Type,'Month',5) | strncmp(Type,'month',5) ) )
    
    case 1
        
        [startTime]   = datestr(startDate,' HH:MM:SS');
        [endTime]     = datestr(endDate,' HH:MM:SS');
        [Y1,M1,D1,~,~,~] = datevec(startDate);
        [Y2,M2,D2,~,~,~] = datevec(endDate);
        [startDate] = datenum(Y1,M1,D1);
        [endDate] = datenum(Y2,M2,D2);
        
        if (endDate - startDate <= 28)
            [SDates] = cellstr( [datestr( startDate, 'dd-mmm-yyyy' ),' ',startTime] );
            [EDates] = cellstr( [datestr( endDate,   'dd-mmm-yyyy' ),' ',endTime  ] );
            return
        end
        
        [Years] = Y1 : 1 : Y2;
        
        switch (length(Years) == 1)
            
            case 1
                
                [AllDate] = myeomdate(Years(1),M1:M2-1)';
                
                [startDates] = [ startDate; AllDate + 1 ];
                [endDates] = [ AllDate ; endDate ];
                
                clear AllDate
                
            case 0
                
                [MYdates] = cell(length(Years(2:end-1)),1);
                for k = 2 : length(Years) - 1
                    MYdates{k-1,1} = myeomdate(Years(k),1:12)';
                end
                
                switch ( M2 == 1 )
                    
                    case 1
                        
                        [FYdates]  = myeomdate(Years(1),M1:12)';
                        [endDates] = [ [ FYdates; vertcat(MYdates{:}) ] ; endDate ];
                        [startDates] = [ startDate; endDates(1:end-1,:) + 1 ];
                        
                    case 0
                        
                        [FYdates] = myeomdate(Years(1),M1:12)';
                        [EYdates] = myeomdate(Years(end),1:M2-1)';
                        [endDates] = [ [ FYdates; vertcat(MYdates{:}); EYdates ] ; endDate ];
                        [startDates] = [ startDate; endDates(1:end-1,:) + 1 ];
                        
                end
                
        end
        
        clear FYdates MYdates EYdates Y1 Y2 M1 M2 D1 D2 Years
        
        m = length(startDates);
        
        [startDate] = datestr( startDates, 'dd-mmm-yyyy' );
        [endDate]   = datestr( endDates, 'dd-mmm-yyyy' );
        
        [SDates] = [ startDate [ [' ',datestr(startTime,'HH:MM:SS')]; repmat( [' ',datestr(TradingDayStart,'HH:MM:SS')],m-1, 1) ] ];
        [EDates] = [ endDate [ repmat( [' ',datestr(TradingDayEnd,'HH:MM:SS')],m-1, 1); [' ',datestr(endTime,'HH:MM:SS')] ] ];
        
        clear m startDate endDate startTime endTime
        
    case 0
        
        [startTime]   = datestr(startDate,' HH:MM:SS');
        [endTime]     = datestr(endDate,' HH:MM:SS');
        [Y1,M1,D1,~,~,~] = datevec(startDate);
        [Y2,M2,D2,~,~,~] = datevec(endDate);
        [startDate] = datenum(Y1,M1,D1);
        [endDate] = datenum(Y2,M2,D2);
        
        if (endDate - startDate < Type)
            [SDates] = cellstr( [datestr( startDate, 'dd-mmm-yyyy' ),' ',startTime] );
            [EDates] = cellstr( [datestr( endDate,   'dd-mmm-yyyy' ),' ',endTime  ] );
            return
        end
        
        clear Y1 Y2 M1 M2 D1 D2
        
        daysVar = ( startDate : 1 : endDate )';
        
        ix = sort( [ 1 Type : Type : length(daysVar) Type + 1 : Type : length(daysVar) - 1 ], 'ascend' );
        
        dates = [ daysVar(ix); endDate ];
        
        clear startDate endDate daysVar ix
        
        switch ( rem(length(dates)/2,1) ~= 0 )
            case 1
                dates = [ dates(1:end-2); dates(end) ];
                dates = [ dates(1:2:end,:) dates(2:2:end,:) ];
            case 0
                dates = [ dates(1:2:end,:) dates(2:2:end,:) ];
        end
        
        [startDate] = datestr( dates(:,1), 'dd-mmm-yyyy' );
        [endDate]   = datestr( dates(:,2), 'dd-mmm-yyyy' );
        
        m = size(startDate,1);
        
        clear dates
        
        [SDates] = [ startDate [ [' ',datestr(startTime,'HH:MM:SS')]; repmat( [' ',datestr(TradingDayStart,'HH:MM:SS')],m-1, 1) ] ];
        [EDates] = [ endDate [ repmat( [' ',datestr(TradingDayEnd,'HH:MM:SS')],m-1, 1); [' ',datestr(endTime,'HH:MM:SS')] ] ];
        
        clear m startDate endDate startTime endTime
        
end

% format for output
[SDates] = cellstr(datestr(SDates,0));
[EDates] = cellstr(datestr(EDates,0));

% remove any saturdays and sundays
switch Type
    case 1
       [daynumber,~] = weekday(SDates);
       removalindex = (daynumber==1|daynumber==7);
       SDates(removalindex) = [];
       EDates(removalindex) = [];
end


end

function d = myeomdate(y,m)
%MYEOMDATE Last date of month. 
%   D = MYEOMDATE(N) returns the last date of the month, in serial form,
%   given the date N.  N can be input as a serial date number or date
%   string.
%
%   D = MYEOMDATE(Y,M) returns the last date of the month, in serial
%   form, for the given year, Y, and month, M.  
% 
%   For example, d = myeomdate(1997,2) returns d = 729449 which is the serial
%   date corresponding to February 28, 1997.

% NB! This function used MATLAB's EOMDATE from the Financial Toolbox as a
% reference and it is the exact same, with some steps expanded and commented
% for better understanding.

% Examples:
% d = myeomdate(2004,2)
% 732006	(29-Feb-2004 00:00:00)

% d = myeomdate([2004 2005 2006 2007 2008],2)
% 732006	(29-Feb-2004 00:00:00)
% 732371	(28-Feb-2005 00:00:00)
% 732736	(28-Feb-2006 00:00:00)
% 733101	(28-Feb-2007 00:00:00)
% 733467	(29-Feb-2008 00:00:00)

% d = myeomdate([2004 2005 2006 2007 2008],[2 2 2 2 2])
% 732006	(29-Feb-2004 00:00:00)
% 732371	(28-Feb-2005 00:00:00)
% 732736	(28-Feb-2006 00:00:00)
% 733101	(28-Feb-2007 00:00:00)
% 733467	(29-Feb-2008 00:00:00)
 
% d = myeomdate([2004 2005 2006 2007 2008],[2 5 3 1 12])
% 732006	(29-Feb-2004 00:00:00)
% 732463	(31-May-2005 00:00:00)
% 732767	(31-Mar-2006 00:00:00)
% 733073	(31-Jan-2007 00:00:00)
% 733773	(31-Dec-2008 00:00:00)
 
% d = myeomdate(2004,[2 5 3 1 12])
% 732006	(29-Feb-2004 00:00:00)
% 732098	(31-May-2004 00:00:00)
% 732037	(31-Mar-2004 00:00:00)
% 731977	(31-Jan-2004 00:00:00)
% 732312	(31-Dec-2004 00:00:00)

% d = myeomdate(2005,[2 5 3 1 12])
% 732371	(28-Feb-2005 00:00:00)
% 732463	(31-May-2005 00:00:00)
% 732402	(31-Mar-2005 00:00:00)
% 732343	(31-Jan-2005 00:00:00)
% 732677	(31-Dec-2005 00:00:00)

% Check for incorrect number of inputs
if nargin < 1;
    error('myeomdate:argChk','Too few input arguments.');
end

% Date input
if nargin == 1
  [y,m] = datevec(y);
  ld = myeomday(y,m);
  d = datenum(y,m,ld,0,0,0);
  return
end

% Check for dodge months
if any(m<1|m>12);
    error('myeomdate:argChk','Not a month.');
end
% Check for matching size input vectors
if (length(y)>1 && length(m)>1 && length(y) ~= length(m))
    error('myeomdate:argChk','Dimensions of input vectors do not match.');
end

% Reshape
y = reshape(y,1,numel(y));
m = reshape(m,1,numel(m));

% Get last day of month using MYEOMDAY
ld = myeomday(y,m);

% Create datenums
d = datenum(y,m,ld,0,0,0);

end

function d = myeomday(y,m)
%MYEOMDAY End of month.
%   D = MYEOMDAY(Y,M) returns the last day of the month for the given
%   year, Y, and month, M.

% NB! This function used MATLAB's EOMDAY from the Financial Toolbox as a
% reference and it is the exact same, with some steps expanded and commented
% for better understanding.

% Examples:
% d = myeomday(2004,2)
% d = 29
% d = myeomday([2004 2005 2006 2007 2008],2)
% d = 29    28    28    28    29
% d = myeomday([2004 2005 2006 2007 2008],[2 2 2 2 2])
% d = 29    28    28    28    29
% d = myeomday([2004 2005 2006 2007 2008],[2 5 3 1 12])
% d = 29    31    31    31    31
% d = myeomday(2004,[2 5 3 1 12])
% d = 29    31    31    31    31
% d = myeomday(2005,[2 5 3 1 12])
% d = 28    31    31    31    31

% Check for incorrect number of inputs
if nargin < 2;
    error('myeomday:argChk','Too few input arguments.');
end
% Check for dodge months
if any(m<1|m>12);
    error('myeomday:argChk','Not a month.');
end
% Check for matching size input vectors
if (length(y)>1 && length(m)>1 && length(y) ~= length(m))
    error('myeomday:argChk','Dimensions of input vectors do not match.');
end

% Number of days in the month.
daysPerMonth = [31 28 31 30 31 30 31 31 30 31 30 31]';

% Make result the right size and orientation.
% Nothing special is happening here; it is included to ensure that the
% dimension of the outpiut vector d is correct
d = y - m;

% Extract number of days per month corresponding to the months specified in
% the array m
d(:) = daysPerMonth(m);

% Correct for any leap years
% d((m == 2) & ((rem(y,4) == 0 & rem(y,100) ~= 0) | rem(y,400) == 0)) = 29;
% Get a logical index of leap years.
% First check for the months in m that are February (i.e. where m == 2)
% A year is a leap year if:
% Case 1: It is divisible by 4 AND it is divisible by 100
% Case 2: It is divisible by 400.
leapYearIndex = (m==2) & ( (rem(y,4) == 0 & rem(y,100) ~= 0) | (rem(y,400) == 0) );
% Correct d for any leap years as indicated by "leapYearIndex"
d(leapYearIndex) = 29;
end