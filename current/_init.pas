{$IFDEF _FULLGAME}

function InitVideo:boolean;
begin
   InitVideo:=false;

   if(SDL_Init(SDL_INIT_VIDEO)<>0)then begin WriteSDLError; exit; end;

   NEW(r_RECT);

   SDL_putenv('SDL_VIDEO_WINDOW_POS');
   SDL_putenv('SDL_VIDEO_CENTERED=1');
   SDL_ShowCursor(0);
   SDL_enableUNICODE(1);

   SDL_WM_SetCaption(@str_wcaption[1], nil );

   _GfxColors;
   _MakeScreen;
   _LoadingScreen;
   _LoadGraphics(true);
   _cmp_Init;

   InitVideo:=true;
end;

procedure StartParams;
var t,i:integer;
    s:string;
begin
   t:=ParamCount;
   for i:=1 to t do
   begin
      s:=ParamStr(i);

      if(s='test' )then _testmode:=1;
      if(s='testD')then _testmode:=2;
   end;
end;

{$ELSE}

procedure StartParams;
var t:integer;
begin
   t:=ParamCount;
   net_port:=10666;
   if(t>0)then
   begin
      net_port:=s2w(ParamStr(1));
      if(net_port=0)then net_port:=10666;
   end;
end;

{$ENDIF}


procedure InitGame;
begin
   _CYCLE:=false;

   fr_init;

   StartParams;
   randomize;

   GameObjectsInit;

   {$IFDEF _FULLGAME}

   lng_eng;
   cfg_read;

   saveload_CalcSaveSize;
   replay_CalcHeaderSize;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   InitRX2Y;
   InitMissiles;
   SwitchLanguage;
   InitUIDDataCL;
   MakeUnitIcons;

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(_event);

   _CYCLE:=true;

   {$IFNDEF _FULLGAME}
   _dedInit;
   {$ENDIF}
end;
