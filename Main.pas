{ Sudoku Game }
{ Version: 0.7 }
{ Author: wanips }
{ https://github.com/wanips7 }

unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IniFiles, System.ImageList, VisualGrid, sudoku,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.TabControl, FMX.StdCtrls,
  FMX.ImgList, FMX.Objects, FMX.ScrollBox, FMX.Effects, FMX.Controls.Presentation;

const
  MAIN_ELEMENT_COLOR = $FF525252;
  GRID_NUM_COLOR = $FF646464;
  GRID_NUM_HIGHLIGHT_COLOR = $FFa57503;
  FIXED_CELL_VALUE_COLOR = $FF727272;
  CELL_NOTE_COLOR = $FF909090;
  CELL_NOTE_HIGHLIGHT_COLOR = $FFa57503;
  SELECTED_CELL_COLOR = $FFb5dcb5;
  HIGHLIGHT_CELL_COLOR = $FFe4ece4;
  SAME_NUM_HIGHLIGHT = 0;

type
  TPageId = (piMain, piSettings, piInGame, piStatistics, piSelectDifficult, piPaused, piEndGame, piAbout);

type
  PSettingsData = ^TSettingsData;
  TSettingsData = record
    Lang: string;
    HideImpossibleNums: Boolean;
    HighlightColsRowSquares: Boolean;
    ShowTimer: Boolean;
    HighlightIdentNums: Boolean;
    Theme: Integer;
  end;

type
  TStatsCounters = record
    SolvedCount: Integer;
    UnsolvedCount: Integer;
    BestTime: Integer;
    WorstTime: Integer;
    AverageTime: Integer;
    procedure Update(const SecondsLeft: Integer);
    procedure IncUnsolved;
  end;

type
  TStatsData = record
    Common: TStatsCounters;
    Easy: TStatsCounters;
    Medium: TStatsCounters;
    Hard: TStatsCounters;
    Expert: TStatsCounters;
  end;

type
  TLastGame = record
    Difficult: TGameDifficult;
    Exist: Boolean;
    procedure Load;
    procedure Save;
    procedure SetDifficult(const Value: TGameDifficult);
    procedure SetExist(const Value: Boolean);
  end;

type
  TAppData = class
  private
    FFile: TIniFile;
    FSettings: TSettingsData;
    FStats: TStatsData;
    FLastGame: TLastGame;
    function GetSettings: PSettingsData;
  public
    property LastGame: TLastGame read FLastGame write FLastGame;
    property Settings: PSettingsData read GetSettings;
    property Stats: TStatsData read FStats write FStats;
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
  end;

type
  TFormMain = class(TForm)
    TabItemAbout: TTabItem;
    CornerButton6: TCornerButton;
    Label3: TLabel;
    Label4: TLabel;
    SwitchHideImpossibleValues: TSwitch;
    Lang: TLang;
    LabelTimeSpentValue: TLabel;
    LabelBestTimeEndValue: TLabel;
    LabelItsRecord: TLabel;
    RectangleControls: TRectangle;
    LabelHighlightColsRowSquares: TLabel;
    SwitchHighlightColsRowSquares: TSwitch;
    LabelShowTimer: TLabel;
    SwitchShowTimer: TSwitch;
    LabelHighlightIdentNums: TLabel;
    SwitchHighlightIdentNums: TSwitch;
    Label5: TLabel;
    Label6: TLabel;
    procedure CornerButtonAboutClick(Sender: TObject);
    procedure SwitchHideImpossibleValuesPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure SwitchHideImpossibleValuesSwitch(Sender: TObject);
    procedure SwitchHighlightColsRowSquaresSwitch(Sender: TObject);
    procedure SwitchShowTimerSwitch(Sender: TObject);
    procedure SwitchHighlightIdentNumsSwitch(Sender: TObject);
  private
    FDifficult: TGameDifficult;
    FNotesMode: Boolean;
    FTimer: TTimer;
  published
    TabControl: TTabControl;
    TabItemMainMenu: TTabItem;
    TabItemSettings: TTabItem;
    TabItemInGame: TTabItem;
    TabItemStatistics: TTabItem;
    CornerButtonNewGame: TCornerButton;
    Label1: TLabel;
    StyleBook1: TStyleBook;
    CornerButtonContinueGame: TCornerButton;
    CornerButtonStatistics: TCornerButton;
    CornerButtonSettings: TCornerButton;
    CornerButtonExit: TCornerButton;
    LabelGameDifficult: TLabel;
    LabelTimeLeft: TLabel;
    CornerButtonBack: TCornerButton;
    CornerButtonPause: TCornerButton;
    ImageList: TImageList;
    CornerButtonSetNum1: TCornerButton;
    CornerButtonSetNum2: TCornerButton;
    CornerButtonSetNum3: TCornerButton;
    CornerButtonSetNum9: TCornerButton;
    CornerButtonSetNum6: TCornerButton;
    CornerButtonSetNum5: TCornerButton;
    CornerButtonSetNum8: TCornerButton;
    CornerButtonSetNum4: TCornerButton;
    CornerButtonSetNum7: TCornerButton;
    CornerButtonUndoLastAction: TCornerButton;
    CornerButtonNotesMode: TCornerButton;
    CornerButtonClearCell: TCornerButton;
    RectangleGrid: TRectangle;
    ShadowEffect1: TShadowEffect;
    GlowEffect: TGlowEffect;
    RectangleBackground: TRectangle;
    TabItemSelectDifficult: TTabItem;
    CornerButtonStartGame: TCornerButton;
    LabelDifficult: TLabel;
    CornerButtonLessDifficult: TCornerButton;
    CornerButtonMoreDifficult: TCornerButton;
    CornerButton2: TCornerButton;
    PresentedScrollBox2: TPresentedScrollBox;
    LabelHideImpossibleValues: TLabel;
    CornerButton3: TCornerButton;
    CornerButton4: TCornerButton;
    CornerButtonResume: TCornerButton;
    Label2: TLabel;
    TabItemPaused: TTabItem;
    LabelCurrentStatsPage: TLabel;
    LabelUnsolvedText: TLabel;
    LabelAverageTimeText: TLabel;
    LabelBestTimeText: TLabel;
    LabelWorstTimeText: TLabel;
    TabItemEndGame: TTabItem;
    CornerButtonGoToMainMenu: TCornerButton;
    LabelEndGame: TLabel;
    LabelTimeSpent: TLabel;
    TabControlStats: TTabControl;
    TabItemCommon: TTabItem;
    TabItemEasy: TTabItem;
    TabItemMedium: TTabItem;
    TabItemHard: TTabItem;
    TabItemExpert: TTabItem;
    LabelSolvedText: TLabel;
    LabelSolvedValue: TLabel;
    LabelUnsolvedValue: TLabel;
    LabelBestTimeValue: TLabel;
    LabelWorstTimeValue: TLabel;
    LabelAverageTimeValue: TLabel;
    CornerButtonPrevStats: TCornerButton;
    CornerButtonNextStats: TCornerButton;
    CornerButtonAbout: TCornerButton;
    LabelBestTime: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CornerButtonPauseClick(Sender: TObject);
    procedure RectangleGridPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure CellClick(Sender: TObject; const Cell: PCell);
    procedure DrawCell(Sender: TObject; const Cell: PCell; Canvas: TCanvas);
    procedure SetNumOrAddNoteToSelectedCell(const Value: Integer);
    procedure ClearUselessNotes(const SudokuCell: TSudokuCell);
    procedure ClickSetNumButton(Sender: TObject);
    procedure CornerButtonClearCellClick(Sender: TObject);
    procedure CornerButtonNotesModeClick(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure CornerButtonNewGameClick(Sender: TObject);
    procedure CornerButtonBackClick(Sender: TObject);
    procedure CornerButton2Click(Sender: TObject);
    procedure CornerButtonPrevDifficultClick(Sender: TObject);
    procedure CornerButtonNextDifficultClick(Sender: TObject);
    procedure TrySetDifficult(const Value: TGameDifficult);
    procedure CornerButtonStartGameClick(Sender: TObject);
    procedure UpdateTime(Sender: TObject);
    procedure ShowAllowNumButtons(const Cell: PCell);
    procedure ShowAllNumButtons;
    procedure CornerButtonStatisticsClick(Sender: TObject);
    procedure GoToPage(const Id: TPageId);
    procedure CornerButtonSettingsClick(Sender: TObject);
    procedure CornerButtonHideImpossibleValuesSwitchClick(Sender: TObject);
    procedure CornerButtonResumeClick(Sender: TObject);
    procedure CornerButtonExitClick(Sender: TObject);
    procedure CornerButtonPrevStatsClick(Sender: TObject);
    procedure CornerButtonNextStatsClick(Sender: TObject);
    procedure ShowStatsLabels;
    procedure CornerButtonUndoLastActionClick(Sender: TObject);
    procedure EndGame(Sender: TObject);
    procedure CornerButtonContinueGameClick(Sender: TObject);
    procedure UpdateTimeLeftLabel;
    procedure UpdateSettings;
    procedure DrawSwitch(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

const
  FILE_UNSOLVED_GAME = 'Unsolved.sgf';
  FILE_APP_DATA = 'AppData.ini';

var
  AppData: TAppData;
  AppPath: string;
  GameGrid: TVisualGrid;
  Sudoku: TSudoku;

function MillisecToTime(Value: Integer): string;
var
  Time: string;
begin
  Value := Value div MSecsPerSec;

  if Value >= SecsPerHour then
    Time := 'hh:nn:ss'
  else
    Time := 'nn:ss';

  Result := FormatDateTime(Time, Value / SecsPerDay);
end;

procedure TFormMain.CellClick(Sender: TObject; const Cell: PCell);

  function IsHighlightCell(const Value: PCell): Boolean;
  var
    CelectedPos: TPoint;
    CurrentPos: TPoint;
  begin
    CelectedPos := IndexToPos(Cell.Index);
    CurrentPos := IndexToPos(Value.Index);
    Result := (CelectedPos.X = CurrentPos.X) or (CelectedPos.Y = CurrentPos.Y) or
      (GetBoxPos(CelectedPos) = GetBoxPos(CurrentPos));
  end;

var
  i: Integer;
  TempCell: PCell;
begin
  for i := 0 to GameGrid.CellsCount - 1 do
  begin
    TempCell := GameGrid.GetCell(i);

    if AppData.Settings.HighlightColsRowSquares then

    if IsHighlightCell(TempCell) then
      TempCell.FillColor(HIGHLIGHT_CELL_COLOR)
    else
      TempCell.FillColor(TAlphaColors.White);
  end;

  if AppData.Settings.HideImpossibleNums then
    ShowAllowNumButtons(Cell)
  else
    ShowAllNumButtons;

  GameGrid.Repaint;
end;

procedure TFormMain.ClearUselessNotes(const SudokuCell: TSudokuCell);
var
  Cell: TSudokuCell;
  Cells: TCellsList;
  Value: Integer;
begin
  Value := SudokuCell.Value;

  Cells := Sudoku.Grid.GetCellsInCol(SudokuCell.Pos.Col);
  Cells := Cells + Sudoku.Grid.GetCellsInRow(SudokuCell.Pos.Row);
  Cells := Cells + Sudoku.Grid.GetCellsInBox(SudokuCell.BoxPos);

  for Cell in Cells do
  begin
    if Cell.Notes.Contains(Value) then
      Cell.Notes.Remove(Value);
  end;
end;

procedure TFormMain.ClickSetNumButton(Sender: TObject);
begin
  SetNumOrAddNoteToSelectedCell((Sender as TCornerButton).Text.ToInteger);
end;

procedure TFormMain.CornerButtonSettingsClick(Sender: TObject);
begin
  GoToPage(piSettings);
end;

procedure TFormMain.CornerButtonStartGameClick(Sender: TObject);
begin
  if AppData.LastGame.Exist then
    case AppData.LastGame.Difficult of
      gdEasy:
        AppData.Stats.Easy.IncUnsolved;
      gdMedium:
        AppData.Stats.Medium.IncUnsolved;
      gdHigh:
        AppData.Stats.Hard.IncUnsolved;
      gdExpert:
        AppData.Stats.Expert.IncUnsolved;
    end;

  AppData.Stats.Common.IncUnsolved;
  AppData.LastGame.SetExist(True);
  AppData.LastGame.SetDifficult(FDifficult);

  Sudoku.NewGame(FDifficult);
  UpdateTime(Self);
  GoToPage(piInGame);

end;

procedure TFormMain.CornerButtonStatisticsClick(Sender: TObject);
begin
  GoToPage(piStatistics);
  ShowStatsLabels;
end;

procedure TFormMain.CornerButtonUndoLastActionClick(Sender: TObject);
begin
  Sudoku.Actions.UndoLast;
  GameGrid.Repaint;
end;

procedure TFormMain.CornerButtonHideImpossibleValuesSwitchClick(Sender: TObject);
var
  Button: TCornerButton;
begin
  Button := Sender as TCornerButton;

  AppData.Settings.HideImpossibleNums := Button.IsPressed;

  if Button.IsPressed then
    Button.ImageIndex := 5
  else
    Button.ImageIndex := 6;
end;

procedure TFormMain.CornerButton2Click(Sender: TObject);
begin
  GoToPage(piMain);
end;

procedure TFormMain.CornerButtonAboutClick(Sender: TObject);
begin
  GoToPage(piAbout);
end;

procedure TFormMain.CornerButtonBackClick(Sender: TObject);
begin
  if TabControl.ActiveTab.Index = Integer(piInGame) then
    Sudoku.Pause;

  GoToPage(piMain);
end;

procedure TFormMain.CornerButtonClearCellClick(Sender: TObject);
var
  Cell: PCell;
begin
  if GameGrid.GetCelected(Cell) then
  begin
    Sudoku.Grid.GetCell(Cell.Index).Clear;
    GameGrid.Repaint;
  end;
end;

procedure TFormMain.CornerButtonContinueGameClick(Sender: TObject);
begin
  if AppData.LastGame.Exist then
  begin
    Sudoku.Resume;
    UpdateTimeLeftLabel;
    GoToPage(piInGame);
  end;
end;

procedure TFormMain.CornerButtonExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormMain.CornerButtonPrevDifficultClick(Sender: TObject);
begin
  TrySetDifficult(Pred(FDifficult));
end;

procedure TFormMain.CornerButtonNextDifficultClick(Sender: TObject);
begin
  TrySetDifficult(Succ(FDifficult));
end;

procedure TFormMain.CornerButtonNewGameClick(Sender: TObject);
begin
  GoToPage(piSelectDifficult);
  TrySetDifficult(gdEasy);
end;

procedure TFormMain.CornerButtonNotesModeClick(Sender: TObject);
begin
  FNotesMode := not FNotesMode;
  GlowEffect.Enabled := FNotesMode;
end;

procedure TFormMain.CornerButtonPauseClick(Sender: TObject);
begin
  Sudoku.Pause;
  GoToPage(piPaused);

end;

procedure TFormMain.CornerButtonResumeClick(Sender: TObject);
begin
  Sudoku.Resume;
  GoToPage(piInGame);

end;

procedure TFormMain.DrawCell(Sender: TObject; const Cell: PCell; Canvas: TCanvas);
var
  SudokuCell: TSudokuCell;
  TextAlign: TTextAlign;
  i: Integer;
  FontStyle: TFontStyleExt;
  TempCell: PCell;
  SelectedValue: Integer;

  procedure DrawNote(const Value: Integer);
  var
    TextAlign, VTextAlign: TTextAlign;
    Rect: TRect;
    Offset: Integer;
  begin
    case Value of
      1:
        begin
          TextAlign := TTextAlign.Leading;
          VTextAlign := TTextAlign.Leading;
        end;
      2:
        begin
          TextAlign := TTextAlign.Center;
          VTextAlign := TTextAlign.Leading;
        end;
      3:
        begin
          TextAlign := TTextAlign.Trailing;
          VTextAlign := TTextAlign.Leading;
        end;
      4:
        begin
          TextAlign := TTextAlign.Leading;
          VTextAlign := TTextAlign.Center;
        end;
      5:
        begin
          TextAlign := TTextAlign.Center;
          VTextAlign := TTextAlign.Center;
        end;
      6:
        begin
          TextAlign := TTextAlign.Trailing;
          VTextAlign := TTextAlign.Center;
        end;
      7:
        begin
          TextAlign := TTextAlign.Leading;
          VTextAlign := TTextAlign.Trailing;
        end;
      8:
        begin
          TextAlign := TTextAlign.Center;
          VTextAlign := TTextAlign.Trailing;
        end;
      9:
        begin
          TextAlign := TTextAlign.Trailing;
          VTextAlign := TTextAlign.Trailing;
        end;
    end;

    Offset := Cell.Rect.Width div 10;
    Rect := Cell.Rect;
    Rect.Left := Rect.Left + Offset;
    Rect.Right := Rect.Right - Offset;

    if SelectedValue = Value then
      Canvas.Fill.Color := CELL_NOTE_HIGHLIGHT_COLOR
    else
      Canvas.Fill.Color := CELL_NOTE_COLOR;

    Canvas.Font.Size := Round(Cell.Size.Width / 4);
    Canvas.Font.Style := [TFontStyle.fsBold];
    Canvas.FillText(Rect, Value.ToString, False, 100, [], TextAlign, VTextAlign);
  end;

begin
  SelectedValue := 0;
  if GameGrid.GetCelected(TempCell) then
  begin
    SelectedValue := Sudoku.Grid.GetCell(TempCell.Index).Value;
  end;

  SudokuCell := Sudoku.Grid.GetCell(Cell.Index);

  if not SudokuCell.IsEmpty then
  begin
    if AppData.Settings.HighlightIdentNums and (SelectedValue = SudokuCell.Value) then
    begin
      FontStyle.Weight := TFontWeight.Regular;
      Canvas.Fill.Color := GRID_NUM_HIGHLIGHT_COLOR;
    end
      else
    begin
      if SudokuCell.IsFixed then
      begin
        FontStyle.Weight := TFontWeight.SemiLight;
      end
        else
      begin
        FontStyle.Weight := TFontWeight.Light;
      end;

      Canvas.Fill.Color := GRID_NUM_COLOR;
    end;

    FontStyle.SimpleStyle := [];
    Canvas.Font.Size := Round(Cell.Size.Width / 1.4);
    Canvas.Font.Family := 'Segoe UI';
    Canvas.Font.StyleExt := FontStyle;
    Canvas.FillText(Cell.Rect, SudokuCell.Value.ToString, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  end
    else
  if not SudokuCell.Notes.IsEmpty then
  for i := 1 to 9 do
  begin
    if SudokuCell.Notes.Contains(i) then
      DrawNote(i);
  end;
end;

procedure TFormMain.DrawSwitch(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
const
  ELLIPSE_OFFSET = 6;
begin
  Canvas.Fill.Color := MAIN_ELEMENT_COLOR;
  Canvas.Stroke.Color := MAIN_ELEMENT_COLOR;
  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Kind := TBrushKind.Solid;

  Canvas.DrawEllipse(ARect, 1);

  if (Sender as TSwitch).IsChecked then
    Canvas.FillEllipse(RectF(ARect.Left + ELLIPSE_OFFSET, ARect.Top + ELLIPSE_OFFSET,
      ARect.Right - ELLIPSE_OFFSET, ARect.Bottom - ELLIPSE_OFFSET), 1);
end;

procedure TFormMain.EndGame(Sender: TObject);
var
  TicsLeft: Integer;
begin
  AppData.LastGame.SetExist(False);
  TicsLeft := Sudoku.TicsLeft;

  case Sudoku.Difficult of
    gdEasy:
      begin
        LabelItsRecord.Visible := TicsLeft < AppData.Stats.Easy.BestTime;
        AppData.Stats.Easy.Update(TicsLeft);
      end;

    gdMedium:
      begin
        LabelItsRecord.Visible := TicsLeft < AppData.Stats.Medium.BestTime;
        AppData.Stats.Medium.Update(TicsLeft);
      end;

    gdHigh:
      begin
        LabelItsRecord.Visible := TicsLeft < AppData.Stats.Hard.BestTime;
        AppData.Stats.Hard.Update(TicsLeft);
      end;

    gdExpert:
      begin
        LabelItsRecord.Visible := TicsLeft < AppData.Stats.Expert.BestTime;
        AppData.Stats.Expert.Update(TicsLeft);
      end;
  end;

  AppData.Stats.Common.Update(TicsLeft);

  LabelTimeSpentValue.Text := LabelTimeLeft.Text;
  LabelBestTimeEndValue.Text := '';

  GoToPage(piEndGame);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: Integer;
  Button: TCornerButton;
  Width: Integer;
begin
  AppPath := ExtractFilePath(ParamStr(0));

  Sudoku := TSudoku.Create;
  Sudoku.OnEnd := EndGame;

  RectangleGrid.Height := RectangleGrid.Width;

  GameGrid := TVisualGrid.Create(RectangleGrid);
  GameGrid.Parent := RectangleGrid;
  GameGrid.OnCellClick := CellClick;
  GameGrid.OnDrawCell := DrawCell;
  GameGrid.CelectedColor := SELECTED_CELL_COLOR;

  GameGrid.CellDistance := Round(RectangleGrid.Width / 130);
  GameGrid.BlockDistance := Round(RectangleGrid.Width / 33);

  Width := Round(RectangleGrid.Width / 11);
  GameGrid.CellSize := TSize.Create(Width, Width);

  Width := Round(RectangleGrid.Width - Width * 9 - GameGrid.BlockDistance * 2 - GameGrid.CellDistance * 6);
  Width := Width div 2;
  GameGrid.GridOffset := TPoint.Create(Width, Width);

  GameGrid.BlockSize := 3;
  GameGrid.RowsCount := 9;
  GameGrid.ColsCount := 9;

  GameGrid.Update;

  AppData := TAppData.Create(AppPath + FILE_APP_DATA);
  AppData.Load;
  AppData.LastGame.Load;

  TrySetDifficult(Sudoku.Difficult);

  UpdateSettings;

  ShadowEffect1.Parent := GameGrid;

  SwitchHideImpossibleValues.Opacity := 0;
  SwitchHighlightColsRowSquares.Opacity := 0;
  SwitchShowTimer.Opacity := 0;
  SwitchHighlightIdentNums.Opacity := 0;

  RectangleGrid.Fill.Kind := TBrushKind.None;
  RectangleControls.Fill.Kind := TBrushKind.None;

  for i := 1 to 9 do
  begin
    Button := FormMain.FindComponent('CornerButtonSetNum' + i.ToString) as TCornerButton;
    Button.OnClick := ClickSetNumButton;
  end;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := MSecsPerSec;
  FTimer.OnTimer := UpdateTime;

  FNotesMode := False;

  TabControl.TabPosition := TTabPosition.None;
  TabControlStats.TabPosition := TTabPosition.None;
  TabControlStats.Opacity := 0;

  GoToPage(piSettings);
  GoToPage(piMain);

  TabControl.Tabs[Integer(piAbout)].Repaint;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  if AppData.LastGame.Exist then
    AppData.LastGame.Save;

  AppData.Save;
  AppData.Free;

  GameGrid.Free;
  Sudoku.Free;
  FTimer.Free;
end;

procedure TFormMain.GoToPage(const Id: TPageId);
begin
  TabControl.GotoVisibleTab(Integer(Id), TTabTransition.None);
end;

procedure TFormMain.RectangleGridPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Brush: TBrush;
begin
//  Brush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColors.Red);
//
//  Canvas.FillRect(TRectF.Create(TPointF.Create(0, 0), 50, 50), 100, Brush);

//  GameGrid.Draw;
//
//  GameGrid.Repaint;

end;

procedure TFormMain.TrySetDifficult(const Value: TGameDifficult);
var
  DiffText: string;
begin
  if (Integer(Value) >= 0) and (Integer(Value) <= Integer(High(TGameDifficult))) then
  begin
    FDifficult := Value;

    case FDifficult of
      gdEasy:
        DiffText := Translate('Easy');
      gdMedium:
        DiffText := Translate('Medium');
      gdHigh:
        DiffText := Translate('Hard');
      gdExpert:
        DiffText := Translate('Expert');
    end;

    LabelDifficult.Text := DiffText;
    LabelGameDifficult.Text := DiffText;
  end;
end;

procedure TFormMain.SetNumOrAddNoteToSelectedCell(const Value: Integer);
var
  Cell: PCell;
  SudokuCell: TSudokuCell;
begin
  if GameGrid.GetCelected(Cell) then
  begin
    SudokuCell := Sudoku.Grid.GetCell(Cell.Index);

    if FNotesMode then
    begin
      if SudokuCell.Notes.Contains(Value) then
        SudokuCell.Notes.Remove(Value)
      else
        SudokuCell.Notes.TryAdd(Value);
    end
      else
    begin
      Sudoku.Actions.TryApply(Cell.Index, Value);
      ClearUselessNotes(SudokuCell);
    end;

    GameGrid.Repaint;
  end;
end;

procedure TFormMain.ShowAllowNumButtons(const Cell: PCell);
var
  i: Integer;
  Button: TCornerButton;
  SudokuCell: TSudokuCell;
begin
  SudokuCell := Sudoku.Grid.GetCell(Cell.Index);

  for i := 1 to 9 do
  begin
    Button := FormMain.FindComponent('CornerButtonSetNum' + i.ToString) as TCornerButton;
    Button.Visible := SudokuCell.CanSetValue(i)
  end;
end;

procedure TFormMain.ShowAllNumButtons;
var
  i: Integer;
  Button: TCornerButton;
begin
  for i := 1 to 9 do
  begin
    Button := FormMain.FindComponent('CornerButtonSetNum' + i.ToString) as TCornerButton;
    Button.Visible := True;
  end;
end;

procedure TFormMain.CornerButtonPrevStatsClick(Sender: TObject);
begin
  TabControlStats.Previous(TTabTransition.None);
  ShowStatsLabels;
end;

procedure TFormMain.CornerButtonNextStatsClick(Sender: TObject);
begin
  TabControlStats.Next(TTabTransition.None);
  ShowStatsLabels;
end;

procedure TFormMain.ShowStatsLabels;

  procedure UpdateStatsCounters(const StatsCounters: TStatsCounters);
  begin
    LabelSolvedValue.Text := StatsCounters.SolvedCount.ToString;
    LabelUnsolvedValue.Text := StatsCounters.UnsolvedCount.ToString;
    LabelBestTimeValue.Text := MillisecToTime(StatsCounters.BestTime);
    LabelWorstTimeValue.Text := MillisecToTime(StatsCounters.WorstTime);
    LabelAverageTimeValue.Text := MillisecToTime(StatsCounters.AverageTime);
  end;

var
  Name: string;
begin

  case TabControlStats.ActiveTab.Index of
    0:
      begin
        Name := Translate('Common');
        UpdateStatsCounters(AppData.Stats.Common);
      end;

    1:
      begin
        Name := Translate('Easy');
        UpdateStatsCounters(AppData.Stats.Easy);
      end;

    2:
      begin
        Name := Translate('Medium');
        UpdateStatsCounters(AppData.Stats.Medium);
      end;

    3:
      begin
        Name := Translate('Hard');
        UpdateStatsCounters(AppData.Stats.Hard);
      end;

    4:
      begin
        Name := Translate('Expert');
        UpdateStatsCounters(AppData.Stats.Expert);
      end;
  end;

  LabelCurrentStatsPage.Text := Name;

end;

procedure TFormMain.SwitchHideImpossibleValuesPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  DrawSwitch(Sender, Canvas, ARect);
end;

procedure TFormMain.SwitchHideImpossibleValuesSwitch(Sender: TObject);
begin
  AppData.Settings.HideImpossibleNums := (Sender as TSwitch).IsChecked;
end;

procedure TFormMain.SwitchHighlightColsRowSquaresSwitch(Sender: TObject);
begin
  AppData.Settings.HighlightColsRowSquares := (Sender as TSwitch).IsChecked;
end;

procedure TFormMain.SwitchHighlightIdentNumsSwitch(Sender: TObject);
begin
  AppData.Settings.HighlightIdentNums := (Sender as TSwitch).IsChecked;
end;

procedure TFormMain.SwitchShowTimerSwitch(Sender: TObject);
var
  IsChecked: Boolean;
begin
  IsChecked := (Sender as TSwitch).IsChecked;
  AppData.Settings.ShowTimer := IsChecked;
  LabelTimeLeft.Visible := IsChecked;
end;

procedure TFormMain.UpdateSettings;
begin
  SwitchHideImpossibleValues.IsChecked := AppData.Settings.HideImpossibleNums;
  SwitchHighlightColsRowSquares.IsChecked := AppData.Settings.HighlightColsRowSquares;

  SwitchShowTimer.IsChecked := AppData.Settings.ShowTimer;
  LabelTimeLeft.Visible := AppData.Settings.ShowTimer;

  SwitchHighlightIdentNums.IsChecked := AppData.Settings.HighlightIdentNums;

end;

procedure TFormMain.UpdateTime(Sender: TObject);
begin
  if TabControl.ActiveTab.Index = Integer(piInGame) then
    UpdateTimeLeftLabel;

 // Log.d(TThread.GetTickCount.ToString  + ' debugging');
end;

procedure TFormMain.UpdateTimeLeftLabel;
begin
  LabelTimeLeft.Text := MillisecToTime(Sudoku.TicsLeft);
end;

procedure TFormMain.TabControlChange(Sender: TObject);
begin
  RectangleBackground.Parent := TabControl.ActiveTab;
  RectangleBackground.SendToBack;

  CornerButtonContinueGame.Visible := AppData.LastGame.Exist;
end;

{ TSettings }

constructor TAppData.Create(const FileName: string);
begin
  FSettings := Default(TSettingsData);
  FStats := Default(TStatsData);
  FFile := TIniFile.Create(FileName);

  FLastGame := Default(TLastGame);
end;

destructor TAppData.Destroy;
begin
  FFile.Free;
  inherited;
end;

function TAppData.GetSettings: PSettingsData;
begin
  Result := @FSettings;
end;

procedure TAppData.Load;
begin
  try
    { Settings }
    FSettings.Lang := FFile.ReadString('Settings', 'Lang', 'EN');
    FSettings.HideImpossibleNums := FFile.ReadBool('Settings', 'HideImpossibleNums', False);
    FSettings.HighlightColsRowSquares := FFile.ReadBool('Settings', 'HighlightColsRowSquares', True);
    FSettings.ShowTimer := FFile.ReadBool('Settings', 'ShowTimer', True);
    FSettings.Theme := FFile.ReadInteger('Settings', 'Theme', 0);
    FSettings.HighlightIdentNums := FFile.ReadBool('Settings', 'HighlightIdentNums', True);

    { Last game }
    FLastGame.Difficult := TGameDifficult(FFile.ReadInteger('LastGame', 'Difficult', 0));
   // FLastGame.Exist := FileExists(AppPath + FILE_UNSOLVED_GAME);
    FLastGame.Exist := FFile.ReadBool('LastGame', 'Exist', False) and FileExists(AppPath + FILE_UNSOLVED_GAME);

    { Stats }
    FStats.Common.SolvedCount := FFile.ReadInteger('CommonStats', 'SolvedCount', 0);
    FStats.Common.UnsolvedCount := FFile.ReadInteger('CommonStats', 'UnsolvedCount', 0);
    FStats.Common.BestTime := FFile.ReadInteger('CommonStats', 'BestTime', 0);
    FStats.Common.WorstTime := FFile.ReadInteger('CommonStats', 'WorstTime', 0);
    FStats.Common.AverageTime := FFile.ReadInteger('CommonStats', 'AverageTime', 0);

    FStats.Easy.SolvedCount := FFile.ReadInteger('EasyStats', 'SolvedCount', 0);
    FStats.Easy.UnsolvedCount := FFile.ReadInteger('EasyStats', 'UnsolvedCount', 0);
    FStats.Easy.BestTime := FFile.ReadInteger('EasyStats', 'BestTime', 0);
    FStats.Easy.WorstTime := FFile.ReadInteger('EasyStats', 'WorstTime', 0);
    FStats.Easy.AverageTime := FFile.ReadInteger('EasyStats', 'AverageTime', 0);

    FStats.Medium.SolvedCount := FFile.ReadInteger('MediumStats', 'SolvedCount', 0);
    FStats.Medium.UnsolvedCount := FFile.ReadInteger('MediumStats', 'UnsolvedCount', 0);
    FStats.Medium.BestTime := FFile.ReadInteger('MediumStats', 'BestTime', 0);
    FStats.Medium.WorstTime := FFile.ReadInteger('MediumStats', 'WorstTime', 0);
    FStats.Medium.AverageTime := FFile.ReadInteger('MediumStats', 'AverageTime', 0);

    FStats.Hard.SolvedCount := FFile.ReadInteger('SolvedStats', 'SolvedCount', 0);
    FStats.Hard.UnsolvedCount := FFile.ReadInteger('SolvedStats', 'UnsolvedCount', 0);
    FStats.Hard.BestTime := FFile.ReadInteger('SolvedStats', 'BestTime', 0);
    FStats.Hard.WorstTime := FFile.ReadInteger('SolvedStats', 'WorstTime', 0);
    FStats.Hard.AverageTime := FFile.ReadInteger('SolvedStats', 'AverageTime', 0);

    FStats.Expert.SolvedCount := FFile.ReadInteger('ExpertStats', 'SolvedCount', 0);
    FStats.Expert.UnsolvedCount := FFile.ReadInteger('ExpertStats', 'UnsolvedCount', 0);
    FStats.Expert.BestTime := FFile.ReadInteger('ExpertStats', 'BestTime', 0);
    FStats.Expert.WorstTime := FFile.ReadInteger('ExpertStats', 'WorstTime', 0);
    FStats.Expert.AverageTime := FFile.ReadInteger('ExpertStats', 'AverageTime', 0);

  except
    raise Exception.Create('Error: can''t load app data');
  end;
end;

procedure TAppData.Save;
begin
  try
    { Settings }
    FFile.WriteString('Settings', 'Lang', FSettings.Lang);
    FFile.WriteBool('Settings', 'HideImpossibleNums', FSettings.HideImpossibleNums);
    FFile.WriteBool('Settings', 'HighlightColsRowSquares', FSettings.HighlightColsRowSquares);
    FFile.WriteBool('Settings', 'ShowTimer', FSettings.ShowTimer);
    FFile.WriteInteger('Settings', 'Theme', FSettings.Theme);
    FFile.WriteBool('Settings', 'ShowTimer', FSettings.HighlightIdentNums);

    { Last game }
    FFile.WriteInteger('LastGame', 'Difficult', Integer(FLastGame.Difficult));
    FFile.WriteBool('LastGame', 'Exist', FLastGame.Exist);

    { Stats }
    FFile.WriteInteger('CommonStats', 'SolvedCount', FStats.Common.SolvedCount);
    FFile.WriteInteger('CommonStats', 'UnsolvedCount', FStats.Common.UnsolvedCount);
    FFile.WriteInteger('CommonStats', 'BestTime', FStats.Common.BestTime);
    FFile.WriteInteger('CommonStats', 'WorstTime', FStats.Common.WorstTime);
    FFile.WriteInteger('CommonStats', 'AverageTime', FStats.Common.AverageTime);

    FFile.WriteInteger('EasyStats', 'SolvedCount', FStats.Easy.SolvedCount);
    FFile.WriteInteger('EasyStats', 'UnsolvedCount', FStats.Easy.UnsolvedCount);
    FFile.WriteInteger('EasyStats', 'BestTime', FStats.Easy.BestTime);
    FFile.WriteInteger('EasyStats', 'WorstTime', FStats.Easy.WorstTime);
    FFile.WriteInteger('EasyStats', 'AverageTime', FStats.Easy.AverageTime);

    FFile.WriteInteger('MediumStats', 'SolvedCount', FStats.Medium.SolvedCount);
    FFile.WriteInteger('MediumStats', 'UnsolvedCount', FStats.Medium.UnsolvedCount);
    FFile.WriteInteger('MediumStats', 'BestTime', FStats.Medium.BestTime);
    FFile.WriteInteger('MediumStats', 'WorstTime', FStats.Medium.WorstTime);
    FFile.WriteInteger('MediumStats', 'AverageTime', FStats.Medium.AverageTime);

    FFile.WriteInteger('SolvedStats', 'SolvedCount', FStats.Hard.SolvedCount);
    FFile.WriteInteger('SolvedStats', 'UnsolvedCount', FStats.Hard.UnsolvedCount);
    FFile.WriteInteger('SolvedStats', 'BestTime', FStats.Hard.BestTime);
    FFile.WriteInteger('SolvedStats', 'WorstTime', FStats.Hard.WorstTime);
    FFile.WriteInteger('SolvedStats', 'AverageTime', FStats.Hard.AverageTime);

    FFile.WriteInteger('ExpertStats', 'SolvedCount', FStats.Expert.SolvedCount);
    FFile.WriteInteger('ExpertStats', 'UnsolvedCount', FStats.Expert.UnsolvedCount);
    FFile.WriteInteger('ExpertStats', 'BestTime', FStats.Expert.BestTime);
    FFile.WriteInteger('ExpertStats', 'WorstTime', FStats.Expert.WorstTime);
    FFile.WriteInteger('ExpertStats', 'AverageTime', FStats.Expert.AverageTime);

  except
    raise Exception.Create('Error: can''t save app data');
  end;
end;

{ TStatsCounters }

procedure TStatsCounters.IncUnsolved;
begin
  Inc(UnsolvedCount);
end;

procedure TStatsCounters.Update(const SecondsLeft: Integer);
begin
  Inc(SolvedCount);

  if (BestTime = 0) or (SecondsLeft < BestTime) then
    BestTime := SecondsLeft;

  if (WorstTime = 0) or (SecondsLeft > WorstTime) then
    WorstTime := SecondsLeft;

  AverageTime := ((AverageTime * SolvedCount - 1) + SecondsLeft) div SolvedCount;
end;

{ TLastGame }

procedure TLastGame.Load;
begin
  Sudoku.LoadGame(AppPath + FILE_UNSOLVED_GAME);
end;

procedure TLastGame.Save;
begin
  Sudoku.SaveGame(AppPath + FILE_UNSOLVED_GAME);
end;

procedure TLastGame.SetDifficult(const Value: TGameDifficult);
begin
  Difficult := Value;
end;

procedure TLastGame.SetExist(const Value: Boolean);
begin
  Exist := Value;
end;

end.
