unit untVariables;

interface
uses SysUtils;


const
  iniSettingsFileName = 'LdapBlindExplorer_settings.ini';
  logFileName = 'LdapBlindExplorer_log.txt';

var
    currentDir,
    tempDir,
    currentIniSettingsFileName,
    currentLogFileName,
    logOptions: string;

    rf: TReplaceFlags;

    batchFile,
    resultFile,
    tempCurlConfig,
    sourceHTTPHeader,
    curlExe,
    tmp_dir: string;

    test_string,
    main_charset: string;
    global_i: integer;

    global_stop: boolean;

implementation

end.

