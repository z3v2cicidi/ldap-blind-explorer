unit untIniSettings;

interface
uses IniFiles32, SysUtils, untVariables;
procedure LoadSettingsFromIni(fname: string);
procedure SaveSettingsToIni(fname: string);
function ReplaceGlobalKeywords(dataIn:string): string;

implementation
uses untMain;


function ReplaceGlobalKeywords(dataIn:string): string;
var
  l: string;
begin
  rf := [rfReplaceAll];
  l := StringReplace(dataIn, '<temp_dir>', tempDir, rf);
  l := StringReplace(l, '<app_dir>', currentDir + '\', rf);
  result := l;
end;



//--------------------------------------------------------load settings from INI

procedure LoadSettingsFromIni(fname: string);
var myIni: TIniFile32;
  sectionName: string;
begin
  myIni := TIniFile32.Create(fname);
  with myIni do
  begin
    sectionName := 'settings';

    frmMain.memCharset.Text := readString(sectionName, 'charset', '');
    frmMain.edtKeywordTrue.Text := readString(sectionName, 'keyword_true', '');
    frmMain.edtURL.Text := readString(sectionName, 'url', '');
    frmMain.edtParameters.Text := readString(sectionName, 'parameters', '');
    frmMain.SetHTTPMethod(readString(sectionName, 'method', ''));
    Free;
  end;
end;




//--------------------------------------------------------save settings from INI
procedure SaveSettingsToIni(fname: string);
var myIni: TIniFile32;
  sectionName: string;
begin
  myIni := TIniFile32.Create(fname);
  with myIni do
  begin
    sectionName := 'settings';

    writeString(sectionName, 'charset', frmMain.memCharset.Text);
    writeString(sectionName, 'keyword_true', frmMain.edtKeywordTrue.Text);
    writeString(sectionName, 'url', frmMain.edtURL.Text);
    writeString(sectionName, 'parameters', frmMain.edtParameters.Text);
    writeString(sectionName, 'method', frmMain.GetHTTPMethod);
    Free;
  end;
end;





end.

