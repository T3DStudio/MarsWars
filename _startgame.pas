{$IFDEF _FULLGAME}

procedure InitFogR;
var r,x:byte;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _fcx[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
end;

procedure _InitVideo;
begin
   if SDL_Init(SDL_INIT_VIDEO)<>0 then
   begin
      WriteError(SDL_GetError);
      HALT;
   end;

   SDL_WM_SetCaption(str_wcaption, nil );
   SDL_putenv('SDL_VIDEO_WINDOW_POS');
   SDL_putenv('SDL_VIDEO_CENTERED=1');

   SDL_ShowCursor(0);
   SDL_enableUNICODE(1);

   c_dred    :=rgba2c(190,  0,  0,255);
   c_red     :=rgba2c(255,  0,  0,255);
   c_ared    :=rgba2c(255,  0,  0,42 );
   c_orange  :=rgba2c(255,140,  0,255);
   c_dorange :=rgba2c(230, 96,  0,255);
   c_brown   :=rgba2c(140, 90, 10,255);
   c_yellow  :=rgba2c(255,255,  0,255);
   c_dyellow :=rgba2c(220,220,  0,255);
   c_lava    :=rgba2c(222,80 ,  0,255);
   c_lime    :=rgba2c(  0,255,  0,255);
   c_green   :=rgba2c(  0,150,  0,255);
   c_aqua    :=rgba2c(  0,255,255,255);
   c_dblue   :=rgba2c(100,100,192,255);
   c_blue    :=rgba2c( 50,50 ,255,255);
   c_ablue   :=rgba2c( 50,50 ,255,24 );
   c_purple  :=rgba2c(255,0  ,255,255);
   c_white   :=rgba2c(255,255,255,255);
   c_awhite  :=rgba2c(255,255,255,40 );
   c_lgray   :=rgba2c(192,192,192,255);
   c_gray    :=rgba2c(120,120,120,255);
   c_dgray   :=rgba2c(70 ,70 ,70 ,255);
   c_agray   :=rgba2c(80 , 80, 80,128);
   c_black   :=rgba2c(0  ,  0,  0,255);
   c_ablack  :=rgba2c(0  ,  0,  0,128);
   c_aablack :=rgba2c(0  ,  0,  0,80 );
end;

procedure StartParams;
var t,i:integer;
    s:string;
begin
   t:=ParamCount;
   for i:=1 to t do
   begin
      s:=ParamStr(i);

      if(s='test')then _testmode:=true;
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
      net_sv_pstr:=w2s(net_sv_port);
   end;
end;
{$ENDIF}

procedure _StartGame;
begin
   randomize;
   _CYCLE:=false;

   new(_EVENT);
   {$IFDEF _FULLGAME}
   new(_RECT);
   fps_ns:=0;
   {$ENDIF}

   StartParams;

   FillChar(_tuids ,sizeof(_tuids ),0);
   FillChar(_toids ,SizeOf(_toids ),0);
   FillChar(_tupids,SizeOf(_tupids),0);

   {$IFDEF _FULLGAME}
   cfg_read;

   _InitVideo;
   _InitSound;
   _MakeScreen;
   _LoadingScreen;
   _loadGfx;
   calcVRV;
   InitFogR;

   {$ENDIF}

   InitGameData;
   _InitNET;
   Map_randommap;
   DefGameObjects;

   _CYCLE:=true;

   {$IFNDEF _FULLGAME}
   str_plout             := ' left the game';
   str_m_liq             := 'Lakes: ';
   str_m_siz             := 'Size: ';
   str_m_obs             := 'Obstacles: x';
   str_race[r_random]    := 'random';
   str_race[r_hell  ]    := 'HELL';
   str_race[r_uac   ]    := 'UAC';

   net_nstat:=ns_srvr;
   if(net_UpSocket=false)then
   begin
      net_dispose;
      net_nstat:=ns_none;
      _CYCLE:=false;
   end
   else HPlayer:=0;
   {$ELSE}
   _MakeUnitBtn;
   _LoadUIPanelBTNs;
   if(_lng)then lng_eng;
   swLNG;
   {$ENDIF}
end;




