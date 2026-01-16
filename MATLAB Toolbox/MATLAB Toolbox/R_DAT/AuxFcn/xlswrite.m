function xlswrite(data,header,colnames,filename,sheetname)
% xlswrite     Easily create an Excel spreadsheet from MATLAB
%
%  xlswrite(data,header,colnames,filename,sheetname) creates a Microsoft Excel spreadsheet
%  using the MATLAB ActiveX interface. Microsoft Excel is required.
%
% Inputs:
%    data           Numeric matrix to write to file.
%   (Optional):
%    header      String of header information. Use string or cell array for multiple lines.
%    colnames    Cell array of strings for column names. One cell element per row/column.
%    filename    String with Excel filename ('.xls' extention is optional).
%                If not specified, contents will be added to a new Excel spreadsheet.
%                If filename already exists, will open, add/replace data and overwrite the file.
%    sheetname:  Name of sheet to write data to. The default is the first sheet.
%                If a name is specified, the sheet must exist.
%
% ex 1:
%      header = 'Who Let The Dogs Out?';
%      colnames = {'Ch1','Ch2','Ch3','Ch4'};
%      data = rand(100,4);
%
%      xlswrite(data,header,colnames,'myfile.xls');
%          will save the spreadsheet as myfile.xls.  The user won't see Excel.
%      xlswrite(data,header,colnames);
%          will open Excel with these contents in a new spreadsheet.
%
% ex 2:
%      filename = 'family.xls';
%      sheetname = 'Plan2';
%      header{1} = 'First header line';
%      header{2} = 'Second header line';
%      colnames = {'1st','2nd','3rd','4th','5th'};
%      data = rand(10,5);
%
%      xlswrite(data,header,colnames,filename,sheetname)
%

% Scott Hirsch
% The MathWorks
% This is provided free, no warranty, ...
%
% Copied from ActiveX example in documentation
%
% In collaboration with:
%
% Fahad Al Mahmood fahad@al-mahmood.com
% Fahad developed the capabilities for writing to multiple sheets
%
% Dragon  dragon5645995@sina.com.cn
% Dragon fixed a bug when writing out 52 or more columns
% 
% Leonardo Lopes GEEV/EEV-E leonardo_ita01@yahoo.com.br  November 2007
% Modified to allow the use of international versions of MS Excel
% Developed the capability to use multiple rows for column names
% Developed the capability to handle "NaN" elements
% Improved code robustness and interface
%
% Leonardo Lopes IPEV/EEV-S leonardo_ita01@yahoo.com.br  April 2011
% When using Excel version 2007 and after, saves using Excel 97-2003 format
%

% Parse inputs
if nargin<2
    header = [];
end

if nargin<3
    colnames = {};
end

if nargin<4 || isempty(filename)
    visible = 1;  % Not saving to a file, so make Excel visible
    filename = '';
else
    visible = 0;  % Saving to a file. Keep Excel hidden
end

if nargin < 5
    sheetname = '';
end

if ischar(header)
    header = cellstr(header);
end
header = header(:);

% Check if data size is supported by Excel
if length(header) + size(colnames,1) + size(data,1) > 65536
    errordlg('Headers and Matrix are too large. Excel only supports 65536 rows.','Error','modal');
end
if max(size(colnames,2), size(data,2)) > 256
    errordlg('Matrix is too large. Excel only supports 256 columns.','Error','modal');
end

% Adjust filename to include filepath
if ~isempty(filename) && ~any(filename==filesep)
    filename = [pwd filesep filename];
end
    
% Open Excel, add workbook, change active worksheet, 
% get/put array, save.
% First, open an Excel Server.
Excel = actxserver('Excel.Application');

% Installed Excel version
ver = str2double(get(Excel,'Version'));
    
% Three cases:
% * Open a new workbook, but don't save (filename is empty)
% * Open a new workbook, save with given file name
% * Open an existing workbook
if isempty(filename)
    % Insert a new workbook
    op = invoke(Excel.Workbooks, 'Add');
    
elseif exist(filename,'file')==0
    % Create new file
    op = invoke(Excel.Workbooks,'Add');
    if ver >= 12
        invoke(op, 'SaveAs', filename, 56); % saves as Excel 97-2003 format
    else
        invoke(op, 'SaveAs', filename);
    end    
else
    % Open existing file
    disp(['Opening Excel File ...(' filename ')']);
    op = invoke(Excel.Workbooks, 'open', filename);
end

% If the user does not specify a filename, make Excel visible
% If he does, save the file and quit Excel without making it visible
set(Excel, 'Visible', visible);

% Make the specified sheet active
if isempty(sheetname)
    sheetname = get(Excel.ActiveSheet,'Name'); % Get first sheet
end
try 
    Sheets = Excel.ActiveWorkBook.Sheets;
    target_sheet = get(Sheets, 'Item', sheetname);
catch
    % Error if the sheet doesn't exist. It would be nice to create it, but I'm too lazy.
    invoke(Excel, 'Quit');
    error(['Sheet ' sheetname ' does not exist!']);
end
invoke(target_sheet, 'Activate');

% Write header
Activesheet = Excel.Activesheet;
if isempty(header)
    nhr=0;
elseif iscell(header)
    nhr = length(header);
    for ii=1:nhr
        ActivesheetRange = get(Activesheet,'Range',['A' num2str(ii)],['A' num2str(ii)]);
        set(ActivesheetRange, 'Value', header{ii});
    end
else
    nhr = 1;
    ActivesheetRange = get(Activesheet,'Range','A1','A1');
    set(ActivesheetRange, 'Value', header);
end

% Add column names
if ~isempty(colnames)
    [nrows, ncols] = size(colnames);
    for jj=1:nrows
        nhr = nhr + 1;      % Extra column names
        for ii=1:ncols
            colname = localComputLastCol('A',ii);
            cellname = [colname num2str(nhr)];
            ActivesheetRange = get(Activesheet,'Range',cellname,cellname);
            set(ActivesheetRange, 'Value', colnames{jj,ii});
        end
    end
end

% Correction for empty cells (may crash ActXServer)
if iscell(data)
    for n = 1:size(data,1)
        for m = 1:size(data,2)
            if isempty(data{n,m}) && ~ischar(data{n,m})
                data{n,m} = '';
            end
        end
    end
end

% Put the MATLAB array into Excel
FirstRow = nhr + 1;
LastRow = FirstRow + size(data,1) - 1;
FirstCol = 'A';
LastCol = localComputLastCol(FirstCol,size(data,2));
ActivesheetRange = get(Activesheet,'Range',[FirstCol num2str(FirstRow)],[LastCol num2str(LastRow)]);
set(ActivesheetRange, 'Value', data);

% Correction of NaN insertion (ActiveX interface can't handle NaN's and puts 65535)
for ncol = 1:size(data,2)
    
    if ~iscell(data)
        NaNchk = any(isnan(data(:,ncol)));
    else
        NaNchk = 0;
        for n = 1:size(data,1)
            if isnumeric(data{n,ncol}) && isnan(data{n,ncol})
                NaNchk = 1;
                break
            end
        end
    end
    
    if NaNchk
        
        if ~iscell(data)
            bkpts = find(diff([0; isnan(data(:,ncol)); 0]));
        else
            bkpts = find(diff([0 isnan([data{:,ncol}]) 0]));
        end
        bkpts(2:2:end) = bkpts(2:2:end) - 1;
        
        for n = 1:2:length(bkpts)
            
            NRow1 = nhr + bkpts(n);
            NRow2 = nhr + bkpts(n+1);
            
            NCol = localComputLastCol('A',ncol);
            ActivesheetRange = get(Activesheet,'Range',[NCol num2str(NRow1)],[NCol num2str(NRow2)]);
            set(ActivesheetRange, 'Value', 'NaN');
            
        end
    end
end

% If user specified a filename, save the file and quit Excel
if ~isempty(filename)
    invoke(op, 'Save');
    invoke(Excel, 'Quit');
    disp(['Excel file ' filename ' has been saved.']);
end

% Delete the ActiveX object
delete(Excel);

% localComputLastCol - Computes the last column that will have data written to it
% in Excel, given the letter(s) of the first column and the number of columns to write.
% Modification of Scott Hirsch's code 
% by Mark Hayworth, The Procter & Gamble Company, September 2006.
function LastColumnLetters = localComputLastCol(FirstCol, numberOfColumnsToWrite)
% Convert to upper case.
FirstCol = upper(FirstCol);

if length(FirstCol) == 1 
    FirstColOffset = double(FirstCol) - double('A');    %Offset from column A
else
    % Fix for starting columns having double letters
    % provided by Mark Hayworth, Procter & Gamble
    firstLetter = FirstCol(1);
    secondLetter = FirstCol(2);
    FirstColOffset = 26 * (double(firstLetter) - double('A') + 1) + (double(secondLetter) - double('A'));    %Offset from column A
end

% Compute the numerical column number where the last data will reside.
lastColumnNumber = FirstColOffset + numberOfColumnsToWrite;
if lastColumnNumber > 256
    % Excel (STILL!) can handle only 256 columns.
    % Set it to 256 if it exceeds this, just to avoid an error.
    lastColumnNumber = 256;
end

% Compute the column header letters.  It will either be one letter in the range of A-Z
% or two letters, like AA, AB, . . . IV.  IV is the most Excel can handle.
if lastColumnNumber <= 26
    % It needs just a single letter.
    % Just convert to ASCII code, add the number of needed columns, 
    % and convert back to a string.
    LastColumnLetters = char(double(FirstCol) + numberOfColumnsToWrite - 1);
else
    % It needs a double letter.
    
    % This block fixes Scott Hirsch's code (which has a bug for high 
    % column letters and/or high numbers of columns to write).
    % Fixed by Mark Hayworth, The Procter & Gamble Company.
    
    % Get which group of 26 it's in: A-Z, AA-AZ, BA-BZ, ... HA-HZ, or IA-IV
    % A* = group #0, B* = group #1, I* = group #8.
    groupNumber = ceil(lastColumnNumber / 26) - 2;  
    
    % Find out what the offset is for the last column with that group of 26.
    % In other words, how many columns beyond the last group of 26 is it?
    groupOffset = rem(lastColumnNumber - 1, 26);
    % The above line maps ranges 27-52, 53-78, 79-104, 105-130, 106-156, 
    % 157-182, 183-208, 209-234, and 235-260 into the range 0-25.
    
    LastColFirstLetter  = char(double('A') + groupNumber);
    LastColSecondLetter = char(double('A') + groupOffset);
    % Append first and last letters together to get combined double letter.
    LastColumnLetters = [LastColFirstLetter LastColSecondLetter];
end
