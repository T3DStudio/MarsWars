{$IFDEF _FULLGAME}


procedure debug_printDriverInfo(rinfo:PSDL_RendererInfo);
var t:integer;
begin
   with rinfo^ do
   begin
      writeln('name ',name);
      writeln('flags ',flags);
      writeln('num_texture_formats ',num_texture_formats);
      if(num_texture_formats>0)then
      for t:=0 to num_texture_formats-1 do write(texture_formats[t],' ');
      writeln;
      writeln('max_texture_width ',max_texture_width,' max_texture_height ',max_texture_height);
   end;
end;

procedure debug_printAllDriversInfo;
var i,c:integer;
  rinfo:TSDL_RendererInfo;
begin
   c:=SDL_GetNumRenderDrivers;
   if(c<0)then WriteSDLError('SDL_GetNumRenderDrivers');
   if(c>0)then
   for i:=0 to c-1 do
   begin
      SDL_GetRenderDriverInfo(i,@rinfo);
      writeln(i+1,'  ---------------------');
      debug_printDriverInfo(@rinfo);
   end;
end;

function InitVideo:boolean;
const sdl_windows_flags   = SDL_WINDOW_RESIZABLE; // or SDL_WINDOW_FULLSCREEN_DESKTOP
      sdl_windows_flags_f : array[false..true] of cardinal = (sdl_windows_flags,sdl_windows_flags+SDL_WINDOW_FULLSCREEN);
var i:integer;
begin
   InitVideo:=false;

   if(SDL_Init(SDL_INIT_VIDEO)<>0)then
   begin
      WriteSDLError('SDL_Init(SDL_INIT_VIDEO)');
      exit;
   end;

   new(vid_RECT);
   for i:=0 to vid_MaxScreenSprites-1 do
     new(vid_Sprites_l[i]);

   vid_window := SDL_CreateWindow(@str_wcaption[1], SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, menu_w, menu_h, sdl_windows_flags_f[vid_fullscreen]);
   if(vid_window=nil)then
   begin
      WriteSDLError('SDL_CreateWindow');
      exit;
   end;

   vid_renderer := SDL_CreateRenderer(vid_window, -1,SDL_RENDERER_ACCELERATED or SDL_RENDERER_TARGETTEXTURE);
   if(vid_renderer=nil)then
   begin
      WriteSDLError('SDL_CreateRenderer');
      exit;
   end;

   SDL_RenderSetLogicalSize(vid_renderer,menu_w,menu_h);

   SDL_ShowCursor(0);
   SDL_StartTextInput;

   gfx_InitColors;
   gfx_LoadGraphics;

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



procedure InitGame;
begin
   GameCycle:=false;

   fr_init;

   StartParams;
   randomize;

   GameObjectsInit;
   InitGamePresets;

   {$IFDEF _FULLGAME}

   input_InitDefaultActionHotkeys;

   cfg_read;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   draw_LoadingScreen(str_loading_ini,c_red);

   saveload_MakeSaveData;
   replay_MakeReplayHeaderData;
   menu_ReBuild;
   InitRX2Y;
   language_ENG;
   language_Switch;
   InitUIDDataCL;
   missile_InitCLData;
  { MakeUnitIcons;      }
   FillChar(ui_dPlayer,SizeOf(ui_dPlayer),0);

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(sys_EVENT);

   GameCycle:=true;

   {$IFNDEF _FULLGAME}
   Dedicated_Init;
   {$ELSE}
  // campaings_InitData;
   {$ENDIF}
end;
