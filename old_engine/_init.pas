{$IFDEF _FULLGAME}


function InitVideo:boolean;
begin
   InitVideo:=false;

   if SDL_Init(SDL_INIT_VIDEO)<>0 then begin WriteError; exit; end;

   NEW(_rect);

   SDL_putenv('SDL_VIDEO_WINDOW_POS');
   SDL_putenv('SDL_VIDEO_CENTERED=1');

   SDL_WM_SetCaption(@str_wcaption[1], nil );

   c_dred    :=rgba2c(190,  0,  0,255);
   c_red     :=rgba2c(255,  0,  0,255);
   c_ared    :=rgba2c(255,  0,  0,42 );
   c_orange  :=rgba2c(255,140,  0,255);
   c_dorange :=rgba2c(230, 96,  0,255);
   c_brown   :=rgba2c(140, 90, 10,255);
   c_yellow  :=rgba2c(255,255,  0,255);
   c_dyellow :=rgba2c(220,220,  0,255);
   c_lime    :=rgba2c(  0,255,  0,255);
   c_aqua    :=rgba2c(  0,255,255,255);
   c_purple  :=rgba2c(255,0  ,255,255);
   c_green   :=rgba2c(  0,150,  0,255);
   c_dblue   :=rgba2c(100,100,192,255);
   c_blue    :=rgba2c( 50,50 ,255,255);
   c_ablue   :=rgba2c( 50,50 ,255,24 );
   c_white   :=rgba2c(255,255,255,255);
   c_awhite  :=rgba2c(255,255,255,40 );
   c_gray    :=rgba2c(120,120,120,255);
   c_dgray   :=rgba2c(70 ,70 ,70 ,255);
   c_agray   :=rgba2c(80 , 80, 80,128);
   c_black   :=rgba2c(0  ,  0,  0,255);
   c_ablack  :=rgba2c(0  ,  0,  0,128);
   c_lava    :=rgba2c(222,80 ,  0,255);

   _MakeScreen;

   InitVideo:=true;

   LoadingScreen;

   SDL_ShowCursor(0);
   SDL_enableUNICODE(1);

   LoadGraphics;
   _cmp_initmap;
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

   if not(InitVideo) then exit;
   if not(InitSound) then exit;

   {$ENDIF}

   NEW(_event);

   if not(InitNET)   then exit;

   Map_randommap;
   DefGameObjects;

   _CYCLE:=true;

   {$IFNDEF _FULLGAME}
   str_player_def        := ' was terminated!';
   str_plout             := ' left the game';
   str_starta            := 'Starting base:';
   str_startat[0]        := '1 builder';
   str_startat[1]        := '1 builder+ 1 gen.';
   str_startat[2]        := '1 builder+ 2 gen.';
   str_startat[3]        := '1 b.+ 2 gen.+ 2 b.';
   str_startat[4]        := '2 builders';
   str_startat[5]        := '1 b.+ 100 energy';
   str_sstarts           := 'Show player starts:';
   str_gmodet            := 'Game mode:';
   str_gmode[gm_scir ]   := 'Skirmish';
   str_gmode[gm_2fort]   := 'Two bases';
   str_gmode[gm_3fort]   := 'Three bases';
   str_gmode[gm_ct   ]   := 'Capturing points';
   str_gmode[gm_inv  ]   := 'Invasion';
   str_gmode[gm_coop ]   := 'Assault';
   str_gaddon            := 'Game:';
   str_addon[false]      := 'UDOOM';
   str_addon[true ]      := 'DOOM 2';
   str_race[r_random]    := 'RANDOM';
   str_race[r_hell  ]    := 'HELL';
   str_race[r_uac   ]    := 'UAC';
   str_plname            := 'Player name';
   str_plstat            := 'State';
   str_team              := 'Team';
   str_srace             := 'Race';
   str_ready             := 'Ready';
   str_aislots           := 'Fill empty slots:';
   str_m_seed            := 'Seed';
   str_m_liq             := 'Lakes';
   str_m_siz             := 'Size';
   str_m_obs             := 'Obstacles';

   SDL_ShowCursor(SDL_ENABLE);
   net_nstat:=ns_srvr;
   if(net_UpSocket=false)then
   begin
      net_dispose;
      net_nstat:=ns_none;
      _CYCLE:=false;
   end
   else
   begin
      HPlayer:=0;
      DefPlayers;
   end;
   vid_mredraw:=true;
   {$ENDIF}
end;
