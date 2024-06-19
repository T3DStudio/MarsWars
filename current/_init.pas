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

   gfx_InitColors;
   vid_MakeScreen;
   gfx_LoadGraphics(true);

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

      if(s='test' )then test_mode:=1;
      {$IFDEF DTEST}
      if(s='testD')then test_mode:=2;
      {$ENDIF}
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

procedure InitGamePresets;
procedure SetPreset(pid:byte;mseed:cardinal;msize:integer;mtype,msym,gmode,t1,t2,t3,t4,t5,t6:byte);
begin
   if(g_preset_n<=pid)then
   begin
      if(g_preset_n=255)then exit;
      while(g_preset_n<=pid)do
      begin
         g_preset_n+=1;
         setlength(g_presets,g_preset_n);
      end;
   end;

   with g_presets[pid] do
   begin
      gp_map_seed    := mseed;
      gp_map_mw      := msize;
      gp_map_type    := mtype;
      gp_map_symmetry:= msym;
      gp_g_mode      := gmode;
      FillChar(gp_player_team,SizeOf(gp_player_team),0);
      gp_player_team[1]:=t1;
      gp_player_team[2]:=t2;
      gp_player_team[3]:=t3;
      gp_player_team[4]:=t4;
      gp_player_team[5]:=t5;
      gp_player_team[6]:=t6;
   end;
end;
begin
   g_preset_cur:=0;
   g_preset_n  :=0;
   setlength(g_presets,g_preset_n);

   SetPreset(gp_1x1_plane   , 667,4000,mapt_steppe,1,gm_scirmish,1,2,0,0,0,0);
   SetPreset(gp_1x1_lake    ,6667,4000,mapt_clake  ,1,gm_scirmish,1,2,0,0,0,0);
   SetPreset(gp_1x1_cave    , 667,4000,mapt_canyon  ,1,gm_scirmish,1,2,0,0,0,0);

   {$IFNDEF _FULLGAME}
   g_presets[gp_custom].gp_name:= 'custom preset';
   MakeGamePresetsNames(@str_gmodel[0],@str_m_typel[0]);
   {$ENDIF}
end;

procedure InitGame;
begin
   GameCycle:=false;

   fr_init;

   StartParams;
   randomize;

   GameObjectsInit;
   InitGamePresets;

   {$IFDEF _FULLGAME}

   cfg_read;

   saveload_CalcSaveSize;
   replay_CalcHeaderSize;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   menu_ReInit;
   InitRX2Y;
   language_eng;
   SwitchLanguage;
   InitUIDDataCL;
   missile_InitCLData;
   MakeUnitIcons;

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(sys_EVENT);

   GameCycle:=true;

   {$IFNDEF _FULLGAME}
   Dedicated_Init;
   {$ELSE}
   campaings_InitData;
   {$ENDIF}
end;
