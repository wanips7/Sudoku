unit VisualGrid;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Objects, System.Generics.Collections;

type
  PCell = ^TCell;
  TCell = record
  private
    FOnUpdate: TNotifyEvent;
    FIndex: Integer;
    FPoint: TPoint;
    FSize: TSize;
    FRect: TRect;
    FColor: TAlphaColor;
  public
    property Color: TAlphaColor read FColor;
    property Index: Integer read FIndex;
    property Size: TSize read FSize;
    property Point: TPoint read FPoint;
    property Rect: TRect read FRect;
    constructor Create(const Index: Integer; const Size: TSize; const Point: TPoint);
    procedure FillColor(const Value: TColor);
  end;

type
  TOnMouseClick = procedure(Sender: TObject; const Point: TPoint) of object;
  TOnCellClick = procedure(Sender: TObject; const Cell: PCell) of object;
  TOnDrawCell = procedure(Sender: TObject; const Cell: PCell; Canvas: TCanvas) of object;

type
  TVisualGrid = class(TShape)
  private
    FCellsList: TList<TCell>;
    FCellSize: TSize;
    FCellDistance: Integer;
    FBlockSize: Integer;
    FBlockDistance: Integer;
    FRowsCount: Integer;
    FColsCount: Integer;
    FCelectedColor: TAlphaColor;
    FGridOffset: TPoint;
    FOnMouseClick: TOnMouseClick;
    FOnCellClick: TOnCellClick;
    FOnDrawCell: TOnDrawCell;
    FSelectedIndex: Integer;
    function PosToIndex(const Row, Col: Integer): Integer;
    function IndexToPos(const Value: Integer): TPoint; inline;
    procedure Paint; override;
    procedure Draw;
    function GetCellsCount: Integer;
    function IsPointInCell(const Point: TPoint; out Cell: PCell): Boolean;
    procedure DoMouseClick(Sender: TObject; const Point: TPoint);
    procedure DoCellClick(Sender: TObject; const Cell: PCell);
    procedure DoDrawCell(Sender: TObject; const Cell: PCell; const Canvas: TCanvas);
    procedure SetRowsCount(const Value: Integer);
    procedure SetColsCount(const Value: Integer);
    procedure SetCellSize(const Width, Height: Integer);
    procedure SetGridOffset(const X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  protected
    procedure DrawCell(const Cell: PCell; const Canvas: TCanvas); virtual;
  public
    property OnMouseClick: TOnMouseClick read FOnMouseClick write FOnMouseClick;
    property OnDrawCell: TOnDrawCell read FOnDrawCell write FOnDrawCell;
    property OnCellClick: TOnCellClick read FOnCellClick write FOnCellClick;
    property RowsCount: Integer read FRowsCount write SetRowsCount;
    property ColsCount: Integer read FColsCount write SetColsCount;
    property CelectedColor: TAlphaColor read FCelectedColor write FCelectedColor;
    property CellsCount: Integer read GetCellsCount;
    property BlockDistance: Integer read FBlockDistance write FBlockDistance;
    property BlockSize: Integer read FBlockSize write FBlockSize;
    property CellDistance: Integer read FCellDistance write FCellDistance;
    property GridOffset: TPoint read FGridOffset write FGridOffset;
    property CellSize: TSize read FCellSize write FCellSize;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update;
    function GetCell(const Row, Col: Integer): PCell; overload;
    function GetCell(const Index: Integer): PCell; overload;
    function GetCelected(out Cell: PCell): Boolean;
    procedure ClearSelected;
    procedure SetSelected(const Cell: PCell);
  end;

implementation

{ TCell }

constructor TCell.Create(const Index: Integer; const Size: TSize; const Point: TPoint);
begin
  FOnUpdate := nil;
  FIndex := Index;
  FColor := TAlphaColors.White;
  FSize := Size;
  FPoint := Point;
  FRect := TRect.Create(FPoint, FSize.Width, FSize.Height);
end;

procedure TCell.FillColor(const Value: TColor);
begin
  FColor := Value;
end;

{ TVisualGameGrid }

function TVisualGrid.PosToIndex(const Row, Col: Integer): Integer;
begin
  Result := Row + Col * FColsCount;
end;

function TVisualGrid.IndexToPos(const Value: Integer): TPoint;
begin
  Result.X := Value mod FRowsCount;
  Result.Y := Value div FColsCount;
end;

procedure TVisualGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Cell: PCell;
begin
  if IsPointInCell(Point(Round(X), Round(Y)), Cell) then
    DoCellClick(Self, Cell);

  inherited;
end;

procedure TVisualGrid.ClearSelected;
begin
  FSelectedIndex := -1;
end;

constructor TVisualGrid.Create(AOwner: TComponent);
begin
  inherited;

  FOnMouseClick := nil;
  FOnCellClick := nil;
  FOnDrawCell := nil;

  FCellsList := TList<TCell>.Create;

  SetCellSize(42, 42);
  SetGridOffset(10, 10);
  SetRowsCount(9);
  SetColsCount(9);

  FCellDistance := 5;

  FBlockSize := 3;
  FBlockDistance := 15;

  FCelectedColor := TAlphaColors.Gold;

  SetBounds(0, 0, 500, 500);

  Update;

  ClearSelected;
end;

destructor TVisualGrid.Destroy;
begin
  FCellsList.Clear;
  FCellsList.Free;
  inherited;
end;

procedure TVisualGrid.DoCellClick(Sender: TObject; const Cell: PCell);
begin
  if Assigned(FOnCellClick) then
    FOnCellClick(Self, Cell);

  SetSelected(Cell);
  Repaint;
end;

procedure TVisualGrid.DoDrawCell(Sender: TObject; const Cell: PCell; const Canvas: TCanvas);
begin
  if Assigned(FOnDrawCell) then
    FOnDrawCell(Self, Cell, Canvas);
end;

procedure TVisualGrid.DoMouseClick(Sender: TObject; const Point: TPoint);
begin
  if Assigned(FOnMouseClick) then
    FOnMouseClick(Self, Point);
end;

procedure TVisualGrid.Draw;
var
  i: Integer;
  Cell: PCell;
begin
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.BeginScene;

  if FCellsList.Count > 0 then
  begin
    for i := 0 to FCellsList.Count - 1 do
    begin
      Cell := GetCell(i);

      Canvas.Fill.Color := Cell.Color;
      DrawCell(Cell, Canvas);
    end;

    if GetCelected(Cell) then
    begin
      Canvas.Fill.Color := FCelectedColor;
      DrawCell(Cell, Canvas);
    end;
  end;

  Canvas.EndScene;
end;

function TVisualGrid.GetCellsCount: Integer;
begin
  Result := FCellsList.Count;
end;

procedure TVisualGrid.DrawCell(const Cell: PCell; const Canvas: TCanvas);
begin
  Canvas.FillRect(Cell.Rect, 2, 2, AllCorners, 100, Canvas.Fill, TCornerType.Round);
  DoDrawCell(Self, Cell, Canvas);
end;

function TVisualGrid.GetCelected(out Cell: PCell): Boolean;
begin
  Result := FSelectedIndex > -1;
  if Result then
    Cell := GetCell(FSelectedIndex);
end;

function TVisualGrid.GetCell(const Index: Integer): PCell;
begin
  if (Index >=0) and (Index < FCellsList.Count) then
    Result := @FCellsList.List[Index]
  else
    raise Exception.Create('Error: out of index');
end;

function TVisualGrid.GetCell(const Row, Col: Integer): PCell;
begin
  Result := GetCell(PosToIndex(Row, Col));
end;

procedure TVisualGrid.Paint;
begin


  Draw;
end;

function TVisualGrid.IsPointInCell(const Point: TPoint; out Cell: PCell): Boolean;
var
  i: Integer;
  TempCell: PCell;
begin
  if FCellsList.Count > 0 then
    for i := 0 to FCellsList.Count - 1 do
    begin
      TempCell := GetCell(i);

      if TempCell.Rect.Contains(Point) then
      begin
        Cell := TempCell;
        Exit(True);
      end;

    end;

  Result := False;
end;


procedure TVisualGrid.SetCellSize(const Width, Height: Integer);
begin
  FCellSize.Width := Width;
  FCellSize.Height := Height;
end;

procedure TVisualGrid.SetColsCount(const Value: Integer);
begin
  if Value > 0 then
    FColsCount := Value;
end;

procedure TVisualGrid.SetGridOffset(const X, Y: Integer);
begin
  FGridOffset.X := X;
  FGridOffset.Y := Y;
end;

procedure TVisualGrid.SetRowsCount(const Value: Integer);
begin
  if Value > 0 then
    FRowsCount := Value;
end;

procedure TVisualGrid.SetSelected(const Cell: PCell);
begin
  ClearSelected;
  FSelectedIndex := Cell.Index;
end;

procedure TVisualGrid.Update;
var
  Row, Col: Integer;
  Cell: TCell;
  Point: TPoint;
  i: Integer;
begin
  FCellsList.Clear;
  ClearSelected;

  i := 0;
  for Row := 0 to FRowsCount - 1 do
    for Col := 0 to FColsCount - 1 do
    begin
      Point := TPoint.Create(FGridOffset.X + Row * (FCellSize.Width + FCellDistance),
        FGridOffset.Y + Col * (FCellSize.Height + FCellDistance));

      if (FBlockSize > 0) and (FBlockDistance > 0) then
      begin
        Point.X := Point.X + (Row div FBlockSize) * FBlockDistance - FCellDistance;
        Point.Y := Point.Y + (Col div FBlockSize) * FBlockDistance - FCellDistance;
      end;

      Cell := TCell.Create(i, FCellSize, Point);

      FCellsList.Add(Cell);
      Inc(i);
    end;

end;

end.
