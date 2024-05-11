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
   vid_MakeScreen;
   DrawLoadingScreen(@str_loading_gfx,c_yellow);
   _LoadGraphics(true);

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
begin
   g_preset_cur:=0;
   g_preset_n  :=gp_count;
   setlength(g_presets,g_preset_n);

   with g_presets[gp_1x1_plane] do
   begin
      gp_map_seed  := 667;
      gp_map_mw    := 4000;
      gp_map_type  := mapt_steppe;
      gp_map_symmetry
                   := 1;
      gp_g_mode    := gm_scirmish;

      FillChar(gp_player_slot,SizeOf(gp_player_slot),0);
      gp_player_slot[1]:=true;
      gp_player_slot[4]:=true;
   end;
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
