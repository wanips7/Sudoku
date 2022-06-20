{ Sudoku Game }
{ Version: 0.7 }
{ Author: wanips }
{ https://github.com/wanips7 }

unit sudoku;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.SyncObjs, System.Generics.Collections, System.IniFiles;

const
  ROWS_COUNT = 9;
  COLS_COUNT = ROWS_COUNT;
  CELLS_COUNT = COLS_COUNT * ROWS_COUNT;
  EMPTY = 0;

const
  EASY_DIFF_CELLS_COUNT = 45;
  MEDIUM_DIFF_CELLS_COUNT = 55;
  HIGH_DIFF_CELLS_COUNT = 65;

type
  TPos = record
    Row: Integer;
    Col: Integer;
    constructor Create(const Row, Col: Integer); overload;
    constructor Create(const Index: Integer); overload;
    function ToIndex: Integer;
  end;

type
  TNumList = array of Integer;
  TCol = array [0 .. COLS_COUNT - 1] of Integer;
  TRow = TCol;

type
  TPositionsList = array of TPos;

type
  TGameDifficult = (gdEasy, gdMedium, gdHigh, gdExpert);

type
  TStat = record
    SecElapsed: Cardinal;
    Progress: Byte;
  end;

type
  TAction = record
    Index: Integer;
    NewValue: Integer;
    OldValue: Integer;
  end;

type
  TNotes = class (TList<Integer>)
  private
  public
    procedure Add(const Value: Integer);
    function IsEmpty: Boolean;
    function ToString: string;
  end;

type
  TSudokuGrid = class;

  TSudokuCell = class
  private
    FIsFixed: Boolean;
    FIndex: Integer;
    FNotes: TNotes;
    FOwner: TSudokuGrid;
    FPos: TPos;
    FValue: Integer;
    function GetBoxPos: TPos;
  protected
    procedure SetIsFixed(const Value: Boolean);
  public
    property IsFixed: Boolean read FIsFixed;
    property Index: Integer read FIndex;
    property BoxPos: TPos read GetBoxPos;
    property Pos: TPos read FPos;
    property Notes: TNotes read FNotes;
    property Value: Integer read FValue;
    constructor Create(const Index: Integer; Owner: TSudokuGrid);
    destructor Destroy; override;
    procedure Clear;
    function CanSetValue(Value: Byte): Boolean; overload;
    function CanSetValue(Value: Byte; out DuplicatePos: TPos): Boolean; overload;
    function IsEmpty: Boolean;
    procedure SetValue(const Value: Integer);
    function TrySetValue(Value: Byte): Boolean; overload;
    function TrySetValue(Value: Byte; out DuplicatePos: TPos): Boolean; overload;
  end;

  TCellsList = array of TSudokuCell;

  TSudokuGrid = class
  private
    FOnFullFill: TNotifyEvent;
    FList: TCellsList;
    FFillProgress: Single;
    function GetFilledCount: Integer;
    function GetEmptyCount: Integer;
    function GetCount: Integer;
    function GetPositionsList: TPositionsList;
    procedure DoFullFill;
    procedure ClearRandomCells(Count: Integer);
  protected
    procedure DoCellChange;
  public
    property FilledCount: Integer read GetFilledCount;
    property Count: Integer read GetCount;
    property EmptyCount: Integer read GetEmptyCount;
    property FillProgress: Single read FFillProgress;
    property OnFulFill: TNotifyEvent read FOnFullFill write FOnFullFill;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetCell(const Row, Col: Integer): TSudokuCell; overload;
    function GetCell(const Pos: TPos): TSudokuCell; overload;
    function GetCell(const Index: Integer): TSudokuCell; overload;
    function GetCellsInBox(const Box: TPos): TCellsList;
    function GetCellsInCol(const Col: Integer): TCellsList;
    function GetCellsInRow(const Row: Integer): TCellsList;
    function GetFirstEmpty(out Value: TSudokuCell): Boolean;
  end;

  TActionsList = class
  private
    FList: TList<TAction>;
    FGrid: TSudokuGrid;
    function GetCount: Integer;
    procedure Add(const Value: TAction);
  public
    property Count: Integer read GetCount;
    constructor Create(const Cells: TSudokuGrid);
    destructor Destroy; override;
    procedure Clear;
    function TryApply(const CellIndex, CellValue: Integer): Boolean;
    procedure UndoLast;
  end;

  TGridGenerator = class
  private
    FGrid: TSudokuGrid;
    FSolutionGrid: TSudokuGrid;
    FRandomGridNums: TNumList;
    FRandomGridPositions: TNumList;
    function CanSolveGrid: Boolean;
    procedure SolutionsCount(var Value: Integer);
    function HasMultipleSolutions: Boolean;
    procedure Generate;
    procedure MarkFilledCellsAsFixed;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ApplyDifficult(Value: TGameDifficult);
    procedure New(const Cells: TSudokuGrid);
  end;

type
  TSudoku = class
  private
    FOnTimeChange: TNotifyEvent;
    FActions: TActionsList;
    FOnBegin: TNotifyEvent;
    FOnEnd: TNotifyEvent;
    FGrid: TSudokuGrid;
    FGenerator: TGridGenerator;
    FDifficult: TGameDifficult;
    FIsPaused: Boolean;
    FStat: TStat;
    FStartTic: Cardinal;
    FTicsLeft: Integer;
    procedure DoBegin;
    procedure DoEnd;
    function GetTicsLeft: Integer;
    procedure UpdateTicsLeft;
  public
    property OnBegin: TNotifyEvent read FOnBegin write FOnBegin;
    property OnEnd: TNotifyEvent read FOnEnd write FOnEnd;
    property IsPaused: Boolean read FIsPaused;
    property TicsLeft: Integer read GetTicsLeft;
    property Actions: TActionsList read FActions;
    property Stat: TStat read FStat;
    property Difficult: TGameDifficult read FDifficult;
    property Grid: TSudokuGrid read FGrid;
    constructor Create;
    destructor Destroy; override;
    procedure NewGame(Difficult: TGameDifficult);
    procedure LoadGame(const FileName: string);
    procedure SaveGame(const FileName: string);
    procedure Pause;
    procedure Resume;
  end;

function IndexToPos(const Value: Integer): TPoint;
function GetBoxPos(const Value: TPoint): TPoint;

implementation

function IndexToPos(const Value: Integer): TPoint;
begin
  Result.X := Value mod 9;
  Result.Y := Value div 9;
end;

function GetBoxPos(const Value: TPoint): TPoint;
begin
  Result.X := (Value.X - Value.X mod 3);
  Result.Y := (Value.Y - Value.Y mod 3);
end;

function IsSudokuNum(const Value: Integer): Boolean; inline;
begin
  Result := (Value >= 1) and (Value <= 9);
end;

{ TPos }

constructor TPos.Create(const Row, Col: Integer);
begin
  Self.Row := Row;
  Self.Col := Col;
end;

constructor TPos.Create(const Index: Integer);
begin
  Self.Row := Index mod ROWS_COUNT;
  Self.Col := Index div COLS_COUNT;
end;

function TPos.ToIndex: Integer;
begin
  Result := Self.Row + Self.Col * COLS_COUNT;
end;

{ TNotes }

procedure TNotes.Add(const Value: Integer);
begin
  if IsSudokuNum(Value) then
    if not Contains(Value) then
      inherited Add(Value);
end;

{ TCell }

function GetRandomNumList(StartValue, Len: Byte): TNumList;
var
  i, r: Byte;
  NumList: TNumList;
begin
  Result := [];

  if Len > 0 then
  begin
    SetLength(Result, Len);
    SetLength(NumList, Len);

    for i := 0 to Len - 1 do
      NumList[i] := StartValue + i;

    for i := Len - 1 downto 0 do
    begin
      r := Random(Length(NumList));
      Result[i] := NumList[r];
      Delete(NumList, r, 1);
    end;
  end;
end;

function TSudokuCell.CanSetValue(Value: Byte): Boolean;
var
  DuplicatePos: TPos;
begin
  Result := CanSetValue(Value, DuplicatePos);
end;

function TSudokuCell.CanSetValue(Value: Byte; out DuplicatePos: TPos): Boolean;

  function IsUniqueInRow(const Cell: TSudokuCell): Boolean;
  var
    i: integer;
    Col: Integer;
  begin
    Col := Cell.Pos.Col;
    for i := 0 to ROWS_COUNT - 1 do
      if (FOwner.GetCell(i, Col).Value = Value) then
      begin
        DuplicatePos := TPos.Create(i, Col);
        Result := False;
        Exit;
      end;

    Result := True;
  end;

  function IsUniqueInCol(const Cell: TSudokuCell): Boolean;
  var
    i: integer;
    Row: Integer;
  begin
    Row := Cell.Pos.Row;
    for i := 0 to COLS_COUNT - 1 do
      if (FOwner.GetCell(Row, i).Value = Value) then
      begin
        DuplicatePos := TPos.Create(Row, i);
        Result := False;
        Exit;
      end;

    Result := True;
  end;

  function IsUniqueInBox(const Cell: TSudokuCell): Boolean;
  var
    Row, Col: integer;
    Offset: TPos;
  begin
    Offset := BoxPos;

    for Row := Offset.Row to Offset.Row + 2 do
      for Col := Offset.Col to Offset.Col + 2 do
        if FOwner.GetCell(Row, Col).Value = Value then
        begin
          DuplicatePos := TPos.Create(Row, Col);
          Result := False;
          Exit;
        end;

    Result := True;
  end;

begin
  Result := IsUniqueInRow(Self) and IsUniqueInCol(Self) and IsUniqueInBox(Self);
end;

procedure TSudokuCell.Clear;
begin
  if not FIsFixed then
  begin
    SetValue(EMPTY);
    FNotes.Clear;
  end;
end;

constructor TSudokuCell.Create(const Index: Integer; Owner: TSudokuGrid);
begin
  FNotes := TNotes.Create;
  FIndex := Index;
  FPos := TPos.Create(FIndex);
  FOwner := Owner;

  SetIsFixed(False);
end;

destructor TSudokuCell.Destroy;
begin
  FNotes.Free;
  inherited;
end;

function TSudokuCell.GetBoxPos: TPos;
begin
  Result.Row := (FPos.Row - FPos.Row mod 3);
  Result.Col := (FPos.Col - FPos.Col mod 3);
end;

function TSudokuCell.IsEmpty: Boolean;
begin
  Result := FValue = EMPTY;
end;

procedure TSudokuCell.SetIsFixed(const Value: Boolean);
begin
  FIsFixed := Value;
end;

procedure TSudokuCell.SetValue(const Value: Integer);
begin
  FValue := Value;
  FOwner.DoCellChange;
end;

function TSudokuCell.TrySetValue(Value: Byte): Boolean;
var
  DuplicatePos: TPos;
begin
  Result := TrySetValue(Value, DuplicatePos);
end;

function TSudokuCell.TrySetValue(Value: Byte; out DuplicatePos: TPos): Boolean;
begin
  Result := CanSetValue(Value, DuplicatePos);
  if Result then
    SetValue(Value);
end;

{ TCells }

procedure TSudokuGrid.Clear;
var
  i: Integer;
begin
  for i := 0 to GetCount - 1 do
  begin
    FList[i].SetIsFixed(False);
    FList[i].Clear;
  end;
end;

constructor TSudokuGrid.Create;
var
  i: Integer;
begin
  FOnFullFill := nil;

  SetLength(FList, CELLS_COUNT);
  for i := 0 to GetCount - 1 do
    FList[i] := TSudokuCell.Create(i, Self);

  Clear;
end;

destructor TSudokuGrid.Destroy;
var
  i: Integer;
begin
  for i := 0 to GetCount - 1 do
    FList[i].Free;
  inherited;
end;

procedure TSudokuGrid.DoCellChange;
begin
  if GetEmptyCount = 0 then
    DoFullFill;
end;

procedure TSudokuGrid.DoFullFill;
begin
  if Assigned(FOnFullFill) then
    FOnFullFill(Self);
end;

function TSudokuGrid.GetFilledCount: Integer;
begin
  Result := GetCount - GetEmptyCount;
end;

function TSudokuGrid.GetCell(const Row, Col: Integer): TSudokuCell;
begin
  Result := GetCell(TPos.Create(Row, Col).ToIndex);
end;

function TSudokuGrid.GetCell(const Pos: TPos): TSudokuCell;
begin
  Result := GetCell(Pos.ToIndex);
end;

function TSudokuGrid.GetCell(const Index: Integer): TSudokuCell;
begin
  if (Index >= 0) and (Index < CELLS_COUNT) then
    Result := FList[Index]
  else
    raise Exception.Create('Error: out of index');
end;

function TSudokuGrid.GetCellsInBox(const Box: TPos): TCellsList;
var
  Row, Col: integer;
  i: Integer;
begin
  SetLength(Result, COLS_COUNT);

  i := 0;
  for Row := Box.Row to Box.Row + 2 do
    for Col := Box.Col to Box.Col + 2 do
      begin
        Result[i] := GetCell(Row, Col);
        Inc(i);
      end;
end;

function TSudokuGrid.GetCellsInCol(const Col: Integer): TCellsList;
var
  i: Integer;
begin
  SetLength(Result, COLS_COUNT);
  for i := 0 to COLS_COUNT - 1 do
    Result[i] := GetCell(i, Col);
end;

function TSudokuGrid.GetCellsInRow(const Row: Integer): TCellsList;
var
  i: Integer;
begin
  SetLength(Result, ROWS_COUNT);
  for i := 0 to ROWS_COUNT - 1 do
    Result[i] := GetCell(Row, i);
end;

function TSudokuGrid.GetCount: Integer;
begin
  Result := Length(FList);
end;

function TSudokuGrid.GetEmptyCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to GetCount - 1 do
    if FList[i].IsEmpty then
      Inc(Result);
end;

function TSudokuGrid.GetPositionsList: TPositionsList;
var
  i: Integer;
begin
  SetLength(Result, GetCount);

  for i := 0 to GetCount - 1 do
    Result[i] := TPos.Create(i);
end;

procedure TSudokuGrid.ClearRandomCells(Count: Integer);
var
  i, n: Integer;
  Positions: TPositionsList;
begin
  if Count > 0 then
  begin
    Positions := GetPositionsList;

    for i := 0 to GetCount - 1 do
    begin
      if GetCell(Positions[i]).IsEmpty then
        Delete(Positions, i, 1);
    end;

    if Length(Positions) > Count then
      for i := 0 to Count - 1 do
      begin
        n := Random(Length(Positions));
        GetCell(Positions[n]).Clear;
        Delete(Positions, i, 1);
      end;
  end;
end;

function TSudokuGrid.GetFirstEmpty(out Value: TSudokuCell): Boolean;
var
  i: Integer;
begin
  for i := 0 to GetCount - 1 do
    if FList[i].IsEmpty then
    begin
      Value := FList[i];
      Exit(True);
    end;

  Result := False;
end;

{ TNotes }

function TNotes.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

function TNotes.ToString: string;
var
  i: Integer;
begin
  Result := '';
  if not IsEmpty then
  for i in List do
    Result := Result + i.ToString;
end;

{ TActionsList }

procedure TActionsList.Add(const Value: TAction);
begin
  FList.Add(Value);
end;

function TActionsList.TryApply(const CellIndex, CellValue: Integer): Boolean;
var
  Cell: TSudokuCell;
  Action: TAction;
begin
  Cell := FGrid.GetCell(CellIndex);

  Action.Index := CellIndex;
  Action.OldValue := Cell.Value;
  Action.NewValue := CellValue;
  Result := Cell.TrySetValue(CellValue);

  if Result then
  begin
    Add(Action);
  end;
end;

procedure TActionsList.Clear;
begin
  FList.Clear;
end;

constructor TActionsList.Create(const Cells: TSudokuGrid);
begin
  FList := TList<TAction>.Create;
  FGrid := Cells;
end;

destructor TActionsList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TActionsList.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TActionsList.UndoLast;
var
  Action: TAction;
begin
  if GetCount > 0 then
  begin
    Action := FList.Last;

    FGrid.GetCell(Action.Index).SetValue(Action.OldValue);

    FList.Delete(FList.Count - 1);
  end;
end;

{ TGridGenerator }

procedure TGridGenerator.ApplyDifficult(Value: TGameDifficult);
var
  i, TempValue: integer;
  Cell: TSudokuCell;
  Len: Integer;
begin
  case Value of
    gdEasy:
      Len := EASY_DIFF_CELLS_COUNT;
    gdMedium:
      Len := MEDIUM_DIFF_CELLS_COUNT;
    gdHigh:
      Len := HIGH_DIFF_CELLS_COUNT;
    gdExpert:
      Len := FGrid.Count;
  end;

  for i := 0 to Len - 1 do
  begin
    Cell := FGrid.GetCell(FRandomGridPositions[i]);
    TempValue := Cell.Value;
    Cell.Clear;

    if HasMultipleSolutions then
    begin
      Cell.SetValue(TempValue);
    end;
  end;

  MarkFilledCellsAsFixed;
end;

function TGridGenerator.CanSolveGrid: Boolean;
var
  Num: integer;
  n: Integer;
  Cell: TSudokuCell;
begin
  if FGrid.GetFirstEmpty(Cell) then
  begin
    for num := 0 to ROWS_COUNT - 1 do
    begin
      n := FRandomGridNums[num];

      if Cell.CanSetValue(n) then
      begin
        Cell.SetValue(n);
        if CanSolveGrid then
          Exit(true);
        Cell.Clear;
      end;
    end;

    Result := false;
  end
    else
  Result := True;
end;

constructor TGridGenerator.Create;
begin
  FSolutionGrid := TSudokuGrid.Create;
end;

destructor TGridGenerator.Destroy;
begin
  FSolutionGrid.Free;
  inherited;
end;

function TGridGenerator.HasMultipleSolutions: Boolean;
var
  Count : integer;
begin
  Count := 0;
  SolutionsCount(Count);
  Result := Count <> 1;
end;

procedure TGridGenerator.MarkFilledCellsAsFixed;
var
  i: Integer;
  Cell: TSudokuCell;
begin
  for I := 0 to FGrid.Count - 1 do
  begin
    Cell := FGrid.GetCell(i);
    if not Cell.IsEmpty then
      Cell.SetIsFixed(True);
  end;
end;

procedure TGridGenerator.Generate;
var
  i: Integer;
  Value: Integer;
  Cell: TSudokuCell;
begin
  FRandomGridPositions := GetRandomNumList(0, CELLS_COUNT);
  FRandomGridNums := GetRandomNumList(1, ROWS_COUNT);

  FGrid.Clear;

  CanSolveGrid;

  for I := 0 to FGrid.Count - 1 do
  begin
    Value := FGrid.GetCell(i).Value;
    Cell := FSolutionGrid.GetCell(i);
    Cell.SetValue(Value);
  end;
end;

procedure TGridGenerator.New(const Cells: TSudokuGrid);
begin
  FGrid := Cells;
  Generate;
end;

procedure TGridGenerator.SolutionsCount(var Value: Integer);
var
  i: integer;
  Cell: TSudokuCell;
begin
  if FGrid.GetFirstEmpty(Cell) then
  begin
    for i := 0 to ROWS_COUNT - 1 do
    begin
      if Value >= 2 then
        break;

      if Cell.CanSetValue(FRandomGridNums[i]) then
      begin
        Cell.SetValue(FRandomGridNums[i]);
        SolutionsCount(Value);
      end;

      Cell.Clear;
    end
  end
    else
  begin
    Inc(Value);
  end;
end;

{ TSudoku }

constructor TSudoku.Create;
begin
  Randomize;

  FGrid := TSudokuGrid.Create;
  FGenerator := TGridGenerator.Create;
  FActions := TActionsList.Create(FGrid);

  FOnBegin := nil;
  FOnEnd := nil;

  FDifficult := gdEasy;
  FStartTic := 0;

  FIsPaused := True;
end;

destructor TSudoku.Destroy;
begin
  FGrid.Free;
  FGenerator.Free;
  FActions.Free;
  inherited;
end;

procedure TSudoku.DoBegin;
begin
  if Assigned(FOnBegin) then
    FOnBegin(Self);
end;

procedure TSudoku.DoEnd;
begin
  Pause;

  if Assigned(FOnEnd) then
    FOnEnd(Self);
end;

procedure TSudoku.LoadGame(const FileName: string);
var
  SaveFile: TIniFile;
  Cell: TSudokuCell;
  s, n: string;
  i: Integer;
begin
  FGrid.Clear;
  FGrid.OnFulFill := FOnEnd;

  SaveFile := TIniFile.Create(FileName);

  FDifficult := TGameDifficult(SaveFile.ReadInteger('Main', 'Difficult', 0));
  FTicsLeft := SaveFile.ReadInteger('Main', 'TicsLeft', 0);
  FStartTic := GetTickCount - FTicsLeft;

  for i := 0 to FGrid.Count - 1 do
  begin
    Cell := FGrid.GetCell(i);

    s := 'Cell' + i.ToString;

    Cell.SetValue(SaveFile.ReadInteger(s, 'Value', 0));
    Cell.SetIsFixed(SaveFile.ReadBool(s, 'IsFixed', False));

    if Cell.IsEmpty then
      for n in SaveFile.ReadString(s, 'Notes', '') do
        Cell.Notes.Add(n.ToInteger);
  end;

  SaveFile.Free;

  DoBegin;
end;

procedure TSudoku.SaveGame(const FileName: string);
var
  SaveFile: TIniFile;
  Cell: TSudokuCell;
  s: string;
  i: Integer;
begin

  SaveFile := TIniFile.Create(FileName);

  SaveFile.WriteInteger('Main', 'Difficult', Integer(FDifficult));
  SaveFile.WriteInteger('Main', 'TicsLeft', GetTicsLeft);

  for i := 0 to FGrid.Count - 1 do
  begin
    Cell := FGrid.GetCell(i);

    s := 'Cell' + i.ToString;
    SaveFile.WriteInteger(s, 'Value', Cell.Value);
    SaveFile.WriteBool(s, 'IsFixed', Cell.IsFixed);
    SaveFile.WriteString(s, 'Notes', Cell.Notes.ToString);
  end;

  SaveFile.Free;
end;

procedure TSudoku.NewGame(Difficult: TGameDifficult);
begin
  FGrid.OnFulFill := nil;
  FDifficult := Difficult;

  FGenerator.New(FGrid);
  FGenerator.ApplyDifficult(FDifficult);

  FGrid.OnFulFill := FOnEnd;

  FStartTic := GetTickCount;

  FIsPaused := False;

  DoBegin;
end;

procedure TSudoku.Pause;
begin
  UpdateTicsLeft;
  FIsPaused := True;
end;

procedure TSudoku.Resume;
begin
  FStartTic := GetTickCount - FTicsLeft;
  FIsPaused := False;
end;

function TSudoku.GetTicsLeft: Integer;
begin
  if not FIsPaused then
    UpdateTicsLeft;
  Result := FTicsLeft;
end;

procedure TSudoku.UpdateTicsLeft;
begin
  FTicsLeft := GetTickCount - FStartTic;
end;

end.
