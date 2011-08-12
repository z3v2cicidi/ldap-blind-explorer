unit untLog;

interface
uses untVariables, untIniSettings, SysUtils, Forms;
procedure LogInint;
procedure Log(inform: string);

implementation



//-----------------------------------------------------------initialize log file

procedure LogInint;
var
  f: TextFile;
begin
  if (pos('rewrite', logOptions) > 0) then
  begin
    assignFile(f, currentLogFileName);
    rewrite(f);
    closeFile(f);
  end;
end;





//-----------just add information to log file or log window with date-time stamp

procedure Log(inform: string);
var
  f: TextFile;
  l: string;
  FormatSettings: TFormatSettings;
begin
  FormatSettings.LongTimeFormat := 'dd.mm.yyyy hh.nn.ss';
  if (pos('file', logOptions) > 0) or (pos('both', logOptions) > 0) then
  begin
    assignFile(f, currentLogFileName);
    if fileExists(currentLogFileName) then append(f) else rewrite(f);

    if (inform <> '') then
    begin
      l := trim(dateTimeToStr(now, FormatSettings)) + chr(9) + inform;
      writeln(f, l);
    end else
    begin
      writeln(f, '');
    end;
    closeFile(f);
    application.processMessages;
  end;

  if (pos('screen', logOptions) > 0) or (pos('both', logOptions) > 0) then
  begin
     //frmMain.memLog.lines.add(inform);
  end;
end;

end.

