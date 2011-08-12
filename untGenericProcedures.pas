unit untGenericProcedures;

interface
uses Controls;
procedure EnableDoubleBuffering(AParent: TWinControl; const AEnabled: Boolean);


implementation







//--------enable double buffering for TWInControls (eliminate stupid flickering)
procedure EnableDoubleBuffering(AParent: TWinControl; const AEnabled: Boolean);
var
  i: Integer;
  AWinControl: TWinControl;
begin
  with AParent do
  begin
      if AParent is TWinControl then AParent.DoubleBuffered := AEnabled;
    
      for i := 0 to ControlCount - 1 do begin
        if Controls[i] is TWinControl then
        begin
           AWinControl := TWinControl(Controls[i]);
           AWinControl.DoubleBuffered := AEnabled;
           if AWinControl.ControlCount > 0 then EnableDoubleBuffering(AWinControl, true);
        end
      end;
  end;
end;






end.

