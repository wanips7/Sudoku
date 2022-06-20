program SudokuFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {FormMain},
  VisualGrid in 'VisualGrid.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
