{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{       �ĵ�FractionItem(���·�����)����ʵ�ֵ�Ԫ        }
{                                                       }
{*******************************************************}

unit HCFractionItem;

interface

uses
  Windows, Classes, Controls, Graphics, HCStyle, HCItem, HCRectItem, HCCustomData,
  HCCommon;

type
  THCFractionItem = class(THCTextRectItem)  // ����(�ϡ����ı���������)
  private
    FTopText, FBottomText: string;
    FTopRect, FBottomRect: TRect;
    FPadding: Byte;
    FLineHide: Boolean;
  protected
    FCaretOffset: ShortInt;
    FMouseLBDowning, FOutSelectInto: Boolean;
    FActiveArea, FMouseMoveArea: TExpressArea;

    procedure FormatToDrawItem(const ARichData: THCCustomData; const AItemNo: Integer); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    function GetOffsetAt(const X: Integer): Integer; override;
    procedure SetActive(const Value: Boolean); override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    /// <summary> ��������ʱ�ڲ��Ƿ���ָ����Key��Shif </summary>
    function WantKeyDown(const Key: Word; const Shift: TShiftState): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function InsertText(const AText: string): Boolean; override;
    procedure GetCaretInfo(var ACaretInfo: TCaretInfo); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    function GetExpressArea(const X, Y: Integer): TExpressArea; virtual;

    property TopRect: TRect read FTopRect write FTopRect;
    property BottomRect: TRect read FBottomRect write FBottomRect;
  public
    constructor Create(const AOwnerData: THCCustomData; const ATopText, ABottomText: string);
    property Padding: Byte read FPadding;
    property LineHide: Boolean read FLineHide write FLineHide;

    property TopText: string read FTopText write FTopText;
    property BottomText: string read FBottomText write FBottomText;
  end;

implementation

uses
  SysUtils, System.Math;

{ THCFractionItem }

constructor THCFractionItem.Create(const AOwnerData: THCCustomData;
  const ATopText, ABottomText: string);
begin
  inherited Create(AOwnerData);
  Self.StyleNo := THCStyle.RsFraction;
  FPadding := 5;
  FActiveArea := TExpressArea.ceaNone;
  FCaretOffset := -1;
  FLineHide := False;

  FTopText := ATopText;
  FBottomText := ABottomText;
end;

procedure THCFractionItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vFocusRect: TRect;
begin
  if Self.Active then
  begin
    ACanvas.Brush.Color := clBtnFace;
    ACanvas.FillRect(ADrawRect);
  end;

  AStyle.TextStyles[TextStyleNo].ApplyStyle(ACanvas);
  ACanvas.TextOut(ADrawRect.Left + FTopRect.Left, ADrawRect.Top + FTopRect.Top, FTopText);
  ACanvas.TextOut(ADrawRect.Left + FBottomRect.Left, ADrawRect.Top + FBottomRect.Top, FBottomText);

  if not FLineHide then  // ������
  begin
    ACanvas.Pen.Color := clBlack;
    ACanvas.MoveTo(ADrawRect.Left + FPadding, ADrawRect.Top + FTopRect.Bottom + FPadding);
    ACanvas.LineTo(ADrawRect.Left + Width - FPadding, ADrawRect.Top + FTopRect.Bottom + FPadding);
  end;

  if FActiveArea <> ceaNone then
  begin
    case FActiveArea of
      ceaTop: vFocusRect := FTopRect;
      ceaBottom: vFocusRect := FBottomRect;
    end;

    vFocusRect.Offset(ADrawRect.Location);
    vFocusRect.Inflate(2, 2);
    ACanvas.Pen.Color := clGray;
    ACanvas.Rectangle(vFocusRect);
  end;

  if (FMouseMoveArea <> ceaNone) and (FMouseMoveArea <> FActiveArea) then
  begin
    case FMouseMoveArea of
      ceaTop: vFocusRect := FTopRect;
      ceaBottom: vFocusRect := FBottomRect;
    end;

    vFocusRect.Offset(ADrawRect.Location);
    vFocusRect.Inflate(2, 2);
    ACanvas.Pen.Color := clMedGray;
    ACanvas.Rectangle(vFocusRect);
  end;
end;

procedure THCFractionItem.FormatToDrawItem(const ARichData: THCCustomData;
  const AItemNo: Integer);
var
  vH, vTopW, vBottomW: Integer;
  vStyle: THCStyle;
begin
  vStyle := ARichData.Style;
  vStyle.TextStyles[TextStyleNo].ApplyStyle(vStyle.DefCanvas);
  vH := vStyle.DefCanvas.TextHeight('��');
  vTopW := Max(vStyle.DefCanvas.TextWidth(FTopText), FPadding);
  vBottomW := Max(vStyle.DefCanvas.TextWidth(FBottomText), FPadding);
  // ����ߴ�
  if vTopW > vBottomW then  // ����������
    Width := vTopW + 4 * FPadding
  else
    Width := vBottomW + 4 * FPadding;

  Height := vH * 2 + 4 * FPadding;

  // ������ַ���λ��
  FTopRect := Bounds(FPadding + (Width - FPadding - FPadding - vTopW) div 2,
    FPadding, vTopW, vH);
  FBottomRect := Bounds(FPadding + (Width - FPadding - FPadding - vBottomW) div 2,
    Height - FPadding - vH, vBottomW, vH);
end;

procedure THCFractionItem.GetCaretInfo(var ACaretInfo: TCaretInfo);
begin
  if FActiveArea <> TExpressArea.ceaNone then
  begin
    OwnerData.Style.TextStyles[TextStyleNo].ApplyStyle(OwnerData.Style.DefCanvas);
    case FActiveArea of
      ceaTop:
        begin
          ACaretInfo.Height := FTopRect.Bottom - FTopRect.Top;
          ACaretInfo.X := FTopRect.Left + OwnerData.Style.DefCanvas.TextWidth(Copy(FTopText, 1, FCaretOffset));
          ACaretInfo.Y := FTopRect.Top;
        end;
      ceaBottom:
        begin
          ACaretInfo.Height := FBottomRect.Bottom - FBottomRect.Top;
          ACaretInfo.X := FBottomRect.Left + OwnerData.Style.DefCanvas.TextWidth(Copy(FBottomText, 1, FCaretOffset));
          ACaretInfo.Y := FBottomRect.Top;
        end;
    end;
  end
  else
    ACaretInfo.Visible := False;
end;

function THCFractionItem.GetExpressArea(const X, Y: Integer): TExpressArea;
var
  vPt: TPoint;
begin
  Result := TExpressArea.ceaNone;
  vPt := Point(X, Y);
  if PtInRect(FTopRect, vPt) then
    Result := TExpressArea.ceaTop
  else
  if PtInRect(FBottomRect, vPt) then
    Result := TExpressArea.ceaBottom;
end;

function THCFractionItem.GetOffsetAt(const X: Integer): Integer;
begin
  if FOutSelectInto then
    Result := inherited GetOffsetAt(X)
  else
  begin
    if X <= 0 then
      Result := OffsetBefor
    else
    if X >= Width then
      Result := OffsetAfter
    else
      Result := OffsetInner;
  end;
end;

function THCFractionItem.InsertText(const AText: string): Boolean;
begin
  if FActiveArea <> ceaNone then
  begin
    case FActiveArea of
      ceaTop: System.Insert(AText, FTopText, FCaretOffset + 1);
      ceaBottom: System.Insert(AText, FBottomText, FCaretOffset + 1);
    end;
    Inc(FCaretOffset, System.Length(AText));

    Self.SizeChanged := True;
  end;
end;

procedure THCFractionItem.KeyDown(var Key: Word; Shift: TShiftState);

  procedure BackspaceKeyDown;

    procedure BackDeleteChar(var S: string);
    begin
      if FCaretOffset > 0 then
      begin
        System.Delete(S, FCaretOffset, 1);
        Dec(FCaretOffset);
      end;
    end;

  begin
    case FActiveArea of
      ceaTop: BackDeleteChar(FTopText);
      ceaBottom: BackDeleteChar(FBottomText);
    end;

    Self.SizeChanged := True;
  end;

  procedure LeftKeyDown;
  begin
    if FCaretOffset > 0 then
      Dec(FCaretOffset);
  end;

  procedure RightKeyDown;
  var
    vS: string;
  begin
    case FActiveArea of
      ceaTop: vS := FTopText;
      ceaBottom: vS := FBottomText;
    end;
    if FCaretOffset < System.Length(vS) then
      Inc(FCaretOffset);
  end;

  procedure DeleteKeyDown;

    procedure DeleteChar(var S: string);
    begin
      if FCaretOffset < System.Length(S) then
        System.Delete(S, FCaretOffset + 1, 1);
    end;

  begin
    case FActiveArea of
      ceaTop: DeleteChar(FTopText);
      ceaBottom: DeleteChar(FBottomText);
    end;

    Self.SizeChanged := True;
  end;

  procedure HomeKeyDown;
  begin
    FCaretOffset := 0;
  end;

  procedure EndKeyDown;
  var
    vS: string;
  begin
    case FActiveArea of
      ceaTop: vS := FTopText;
      ceaBottom: vS := FBottomText;
    end;
    FCaretOffset := System.Length(vS);
  end;

begin
  case Key of
    VK_BACK: BackspaceKeyDown;  // ��ɾ
    VK_LEFT: LeftKeyDown;       // �����
    VK_RIGHT: RightKeyDown;     // �ҷ����
    VK_DELETE: DeleteKeyDown;   // ɾ����
    VK_HOME: HomeKeyDown;       // Home��
    VK_END: EndKeyDown;         // End��
  end;
end;

procedure THCFractionItem.KeyPress(var Key: Char);
begin
  if FActiveArea <> ceaNone then
    InsertText(Key)
  else
    Key := #0;
end;

procedure THCFractionItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);

  procedure LoadPartText(var S: string);
  var
    vSize: Word;
    vBuffer: TBytes;
  begin
    AStream.ReadBuffer(vSize, SizeOf(vSize));
    if vSize > 0 then
    begin
      SetLength(vBuffer, vSize);
      AStream.Read(vBuffer[0], vSize);
      S := StringOf(vBuffer);
    end
    else
      S := '';
  end;

begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  LoadPartText(FTopText);
  LoadPartText(FBottomText);
end;

procedure THCFractionItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vS: string;
  vX: Integer;
  vOffset: Integer;
begin
  inherited;
  FMouseLBDowning := (Button = mbLeft) and (Shift = [ssLeft]);
  FOutSelectInto := False;

  if FMouseMoveArea <> FActiveArea then
  begin
    FActiveArea := FMouseMoveArea;
    OwnerData.Style.UpdateInfoReCaret;
  end;

  case FActiveArea of
    //ceaNone: ;

    ceaTop:
      begin
        vS := FTopText;
        vX := X - FTopRect.Left;
      end;

    ceaBottom:
      begin
        vS := FBottomText;
        vX := X - FBottomRect.Left;
      end;
  end;

  if FActiveArea <> TExpressArea.ceaNone then
  begin
    OwnerData.Style.TextStyles[TextStyleNo].ApplyStyle(OwnerData.Style.DefCanvas);
    vOffset := GetCharOffsetByX(OwnerData.Style.DefCanvas, vS, vX)
  end
  else
    vOffset := -1;

  if vOffset <> FCaretOffset then
  begin
    FCaretOffset := vOffset;
    OwnerData.Style.UpdateInfoReCaret;
  end;
end;

procedure THCFractionItem.MouseLeave;
begin
  inherited MouseLeave;
  FMouseMoveArea := ceaNone;
end;

procedure THCFractionItem.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vArea: TExpressArea;
begin
  if (not FMouseLBDowning) and (Shift = [ssLeft]) then
    FOutSelectInto := True;

  if not FOutSelectInto then
  begin
    vArea := GetExpressArea(X, Y);
    if vArea <> FMouseMoveArea then
    begin
      FMouseMoveArea := vArea;
      OwnerData.Style.UpdateInfoRePaint;
    end;
  end
  else
    FMouseMoveArea := ceaNone;

  inherited MouseMove(Shift, X, Y);
end;

procedure THCFractionItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FMouseLBDowning := False;
  FOutSelectInto := False;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure THCFractionItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);

  procedure SavePartText(const S: string);
  var
    vBuffer: TBytes;
    vSize: Word;
  begin
    vBuffer := BytesOf(S);
    if System.Length(vBuffer) > MAXWORD then
      raise Exception.Create(HCS_EXCEPTION_TEXTOVER);
    vSize := System.Length(vBuffer);
    AStream.WriteBuffer(vSize, SizeOf(vSize));
    if vSize > 0 then
      AStream.WriteBuffer(vBuffer[0], vSize);
  end;

begin
  inherited SaveToStream(AStream, AStart, AEnd);
  SavePartText(FTopText);
  SavePartText(FBottomText);
end;

procedure THCFractionItem.SetActive(const Value: Boolean);
begin
  inherited SetActive(Value);
  if not Value then
    FActiveArea := ceaNone;
end;

function THCFractionItem.WantKeyDown(const Key: Word;
  const Shift: TShiftState): Boolean;
begin
  Result := True;
end;

end.