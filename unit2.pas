unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, Grids, ValEdit, Menus;

type

  { TfrmCompose }

  TfrmCompose = class(TForm)
    ComboGroup: TComboBox;
    eManual: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblCharCount: TLabel;
    listKategori: TListBox;
    Memo1: TMemo;
    radioCombo: TRadioButton;
    radioManual: TRadioButton;
    SpeedButton1: TSpeedButton;
    btnAdd: TSpeedButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure listKategoriDblClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure radioComboChange(Sender: TObject);
    procedure radioManualChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmCompose: TfrmCompose;

implementation

{$R *.lfm}

{ TfrmCompose }

procedure TfrmCompose.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TfrmCompose.FormCreate(Sender: TObject);
begin
  eManual.Enabled:=FALSE;

end;

procedure TfrmCompose.listKategoriDblClick(Sender: TObject);
var
  i, tinggi: integer;
begin
  tinggi:=listKategori.Height;
  For i := listKategori.Items.Count - 1 downto 0 do
      // if we found a selected item...
      if listKategori.Selected [i] then
         begin
        // ...delete it
        listKategori.Items.Delete (i);
        if listKategori.Items.Count<11 then
           listKategori.Height:=tinggi-16;
         end;
end;

procedure TfrmCompose.Memo1Change(Sender: TObject);
begin
  lblCharCount.Caption := IntToStr (Length(Memo1.Text))+' characters';
end;

procedure TfrmCompose.radioComboChange(Sender: TObject);
begin
  eManual.Enabled:=FALSE;
  comboGroup.Enabled:=TRUE;
  listKategori.Enabled:=TRUE;
  btnAdd.Enabled:=TRUE;
end;

procedure TfrmCompose.radioManualChange(Sender: TObject);
begin
  eManual.Enabled:=TRUE;
  comboGroup.Enabled:=FALSE;
  listKategori.Enabled:=FALSE;
  btnAdd.Enabled:=FALSE;

end;

procedure TfrmCompose.btnAddClick(Sender: TObject);
var
  tinggi : integer;
begin
  tinggi := listkategori.Height;
  listKategori.Items.Add(Combogroup.Text);
  if (listKategori.height<>176) then
     listKategori.Height:=tinggi+16;

end;

end.

