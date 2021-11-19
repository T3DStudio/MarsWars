{$IFDEF _FULLGAME}

function InitVideo:boolean;
begin
   InitVideo:=false;

   if SDL_Init(SDL_INIT_VIDEO)<>0 then begin WriteSDLError; exit; end;

   NEW(r_RECT);

   SDL_putenv('SDL_VIDEO_WINDOW_POS');
   SDL_putenv('SDL_VIDEO_CENTERED=1');
   SDL_ShowCursor(0);
   SDL_enableUNICODE(1);

   SDL_WM_SetCaption(@str_wcaption[1], nil );

   _InitFogR;
   _GfxColors;
   _MakeScreen;
   _LoadingScreen;
   _LoadGraphics(true);
   _cmp_initmap;

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
   net_sv_port:=10666;
   if(t>0)then
   begin
      net_sv_port:=s2w(ParamStr(1));
      if(net_sv_port=0)then net_sv_port:=10666;
   end;
end;

{$ENDIF}


procedure InitGame;
begin
   _CYCLE:=false;

   StartParams;
   randomize;
   ObjTbl;

   {$IFDEF _FULLGAME}
   fps_cs:=0;
   fps_ns:=0;

   lng_eng;
   cfg_read;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   initMissiles;
   swLNG;
   InitUIDDataCL;
   _icons;

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
