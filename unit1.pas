unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls,LCLType, Buttons, ComCtrls, Unit3, sqldb, db, mysql55conn,
  odbcconn,INIFiles;

type

  { TmainForm }

  TmainForm = class(TForm)
    CoolBar1: TCoolBar;
    ePassword: TEdit;
    eUsername: TEdit;
    imgLogin: TImage;
    Label3: TLabel;
    Label4: TLabel;
    PanelLogin: TPanel;
    Source1: TDataSource;
    Label1: TLabel;
    menuDashboard: TMenuItem;
    menuTray: TMenuItem;
    DLLConn: TMySQL55Connection;
    ODBCConn: TODBCConnection;
    Panel1: TPanel;
    btnCompose: TSpeedButton;
    btnInbox: TSpeedButton;
    btnOutbox: TSpeedButton;
    btnSent: TSpeedButton;
    btnPhonebook: TSpeedButton;
    btnSetting: TSpeedButton;
    PopupMenu1: TPopupMenu;
    btnDashboard: TSpeedButton;
    Q1: TSQLQuery;
    Qauth: TSQLQuery;
    Timer1: TTimer;
    Trans: TSQLTransaction;
    StatusBar: TStatusBar;
    procedure btnComposeClick(Sender: TObject);
    procedure btnDashboardClick(Sender: TObject);
    procedure btnInboxClick(Sender: TObject);
    procedure btnOutboxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgLoginClick(Sender: TObject);
    procedure menuDashboardClick(Sender: TObject);
    procedure ePasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure eUsernameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
     procedure MoveAnimation(moveobj: TComponent; leftfrom: Integer;
      leftto: Integer; topfrom: Integer; topto: Integer);
  public
    { public declarations }
  end;

var
  mainForm: TmainForm;

implementation

{$R *.lfm}

{ TmainForm }
uses unit2, unit5, konekMySQL, md5;
var
  buttonAktif, conn, username, password : string;
  INI:TINIFile;

procedure tutup(formu:string);
begin
  CASE formu OF
      'compose' : frmCompose.Destroy;
      'outbox'  : frmOutbox.Destroy;
  //ELSE
    //mainForm.Close;
  END;
end;

procedure TmainForm.MoveAnimation(moveobj: TComponent;
  leftfrom: Integer; leftto: Integer;
  topfrom: Integer; topto: Integer);

var
  i: Integer;
  step: Integer=7;
  moveareax, moveareay: integer;

begin
  i := 1;
  moveareax := leftto - leftfrom;
  moveareay := topto - topfrom;

  while i <= 100 do begin

    tbutton(moveobj).Left := round(leftfrom + (moveareax * i / 100));
    tbutton(moveobj).Top := round(topfrom + (moveareay * i / 100));
    Repaint;

    Sleep(1);

    // we exit the while...do loop when our work is done
    if i >= 100 then
      Exit;

    Inc(i, step);
    if (100 - i) < step then
      i := 100;

  end;

end;

procedure TmainForm.btnComposeClick(Sender: TObject);
begin
  if buttonAktif<>'compose' then
  begin
       tutup(buttonAktif);
       frmCompose := TfrmCompose.Create(nil);  // Instantiate the form
       frmCompose.Parent := Panel1;        // Who's your Daddy ?
       frmCompose.Show;
       buttonAktif:='compose';
  end;
  statusbar.Panels[1].Text:=buttonAktif ;
end;

procedure TmainForm.btnDashboardClick(Sender: TObject);
begin
  tutup(buttonAktif);
  buttonAktif:='';
  statusbar.Panels[1].Text:=buttonAktif;
end;

procedure TmainForm.btnInboxClick(Sender: TObject);
begin
  if buttonAktif<>'inbox' then
  begin
       tutup(buttonAktif);
       buttonAktif:='inbox';
  end;
  statusbar.Panels[1].Text:=buttonAktif;
end;

procedure TmainForm.btnOutboxClick(Sender: TObject);
begin
  if buttonAktif<>'outbox' then
  begin
       tutup(buttonAktif);
       frmOutbox := TfrmOutbox.Create(nil);  // Instantiate the form
       frmOutbox.Parent := Panel1;        // Who's your Daddy ?
       frmOutbox.Show;
       buttonAktif:='outbox';
  end;
  statusbar.Panels[1].Text:=buttonAktif;
end;

procedure TmainForm.FormCreate(Sender: TObject);
begin
  mainForm.Width:=679;
  mainForm.Height:=376;
  PanelLogin.Width:=679;
  PanelLogin.Height:=376;
  PanelLogin.Left:=0;
  panelLogin.Top:=0;
  statusbar.Panels[1].Text:=buttonAktif ;

  TRY
   conn := Koneksi('connection');
   if (conn='ODBC') then
     begin
       ODBCConn.Connected:=FALSE;
       Trans.DataBase:=ODBCConn;
       Q1.DataBase:=ODBCConn;
       Qauth.DataBase:=ODBCConn;
       ODBCConn.Driver := 'MYSQL ODBC 3.51 DRIVER';
       ODBCConn.UserName := Koneksi('username');
       ODBCConn.Password := Koneksi('password');
       ODBCConn.Params.Add('SERVER='+Koneksi('server'));
       ODBCConn.Params.Add('PORT=3306');
       ODBCConn.Params.Add('DATABASE='+Koneksi('database'));
       ODBCConn.Connected:=TRUE;
     end
   else
     begin
          DLLConn.Connected:=FALSE;
          Trans.DataBase:=DLLConn;
          Q1.DataBase:=DLLConn;
          Qauth.DataBase:=DLLConn;
          DLLConn.HostName:=Koneksi('server');
          DLLConn.UserName:=Koneksi('username');
          DLLConn.Password:=Koneksi('password');
          DLLConn.DatabaseName:=Koneksi('database');
          DLLConn.Connected:=TRUE;
     end;
   EXCEPT
         MessageDlg('Gagal terhubung dengan server!!', mtWarning,[mbOK],0);
         Application.Terminate;
   end;
end;

procedure TmainForm.imgLoginClick(Sender: TObject);
var
  passCode : string;
begin
  Qauth.active:=FALSE;
  Qauth.SQL.Clear;
  Qauth.SQL.Text:='SELECT * FROM tb_user WHERE username="'+eUsername.text+'" LIMIT 1';
  Qauth.active:=true;
  password:=Qauth.FieldByName('password').AsString;
  username:=eUsername.text;
  passCode:= MD5Print(MD5String(MD5Print(MD5String(ePassword.Text))));
  //update tb_user set password=md5(md5(' ')) where username='hekta';
   if(password = passCode) AND (eUsername.Text<>'') AND (ePassword.Text<>'') then
      begin
       // PanelLogin.Hide;
        MoveAnimation(PanelLogin, 0, 0, 40, 400);
        PanelLogin.Visible:=FALSE;

      end
   else
      begin
        MessageDlg('Username atau Password Salah!!', mtWarning,[mbOK],0);
      end;

   Qauth.active:=FALSE;
end;

procedure TmainForm.menuDashboardClick(Sender: TObject);
begin
  tutup(buttonAktif);
  buttonAktif:='';
end;

procedure TmainForm.ePasswordKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then mainForm.imgLoginClick(imgLogin);
end;

procedure TmainForm.eUsernameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then SelectNext(ActiveControl,true,true);
end;

procedure TmainForm.Timer1Timer(Sender: TObject);
begin
  statusbar.Panels[0].Text:=formatdatetime('dddd, dd mmm yyyy', Now);
  statusbar.Panels[2].Text:=formatdatetime('hh:mm:ss', Now);
end;

end.

