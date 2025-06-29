{$IFDEF _FULLGAME}

procedure UpdateDisplayModes;
var i,
curDisplay:integer;
begin
   curDisplay:=SDL_GetWindowDisplayIndex(vid_SDLWindow);
   vid_SDLDisplayModeN:=SDL_GetNumDisplayModes(curDisplay);
   setlength(vid_SDLDisplayModes,vid_SDLDisplayModeN);
   for i:=0 to vid_SDLDisplayModeN-1 do
   begin
      SDL_GetDisplayMode(curDisplay,i,@vid_SDLDisplayModes[i]);

      vid_MinW:= min2i(vid_MinW,vid_SDLDisplayModes[i].w);
      vid_MinH:= min2i(vid_MinH,vid_SDLDisplayModes[i].h);
      vid_MaxW:= max2i(vid_MaxW,vid_SDLDisplayModes[i].w);
      vid_MaxH:= max2i(vid_MaxH,vid_SDLDisplayModes[i].h);
   end;
   SDL_GetDisplayBounds(curDisplay,vid_SDLRect);
   vid_SDLDisplayModeC.w:=vid_SDLRect^.w;
   vid_SDLDisplayModeC.h:=vid_SDLRect^.h;

   vid_vw:=mm3i(vid_minw,vid_vw,vid_maxw);
   vid_vh:=mm3i(vid_minh,vid_vh,vid_maxh);
   menu_vid_vw:=vid_vw;
   menu_vid_vh:=vid_vh;
end;

function InitVideo:boolean;
const sdl_windows_flags   = SDL_WINDOW_RESIZABLE; // or SDL_WINDOW_FULLSCREEN_DESKTOP
      sdl_windows_flags_f : array[false..true] of cardinal = (sdl_windows_flags,sdl_windows_flags+SDL_WINDOW_FULLSCREEN);
var i: integer;
rInfo: TSDL_RendererInfo;
begin
   InitVideo:=false;

   if(SDL_Init(SDL_INIT_VIDEO)<0)then
   begin
      WriteSDLError('SDL_Init(SDL_INIT_VIDEO)');
      exit;
   end;

   new(vid_SDLRect);
   for i:=0 to ui_MaxScreenSprites-1 do
     new(ui_Sprites_l[i]);

   // SDL Renderer info
   vid_SDLRenderersN:=SDL_GetNumRenderDrivers;
   if(vid_SDLRenderersN<0)then
   begin
      WriteSDLError('SDL_GetNumRenderDrivers: '+i2s(vid_SDLRenderersN));
      exit;
   end;
   WriteLog('SDL_GetNumRenderDrivers: '+i2s(vid_SDLRenderersN));
   if(vid_SDLRenderersN>0)then
   begin
      if(length(vid_SDLRendererName)=1)then
        if(pos(vid_SDLRendererName,'0123456789')>0)then
          vid_SDLRendererI:=s2i(vid_SDLRendererName);

      for i:=0 to vid_SDLRenderersN-1 do
        if(SDL_GetRenderDriverInfo(i,@rInfo)<0)
        then begin WriteSDLError('SDL_GetRenderDriverInfo '+i2s(i));exit;end
        else
        begin
           WriteLog(i2s(i)+' '+rInfo.name);
           if(vid_SDLRendererI=-1)and(length(vid_SDLRendererName)>0)then
             if(rInfo.name=vid_SDLRendererName)then vid_SDLRendererI:=i;
        end;
   end;

   vid_SDLWindow := SDL_CreateWindow(@str_wcaption[1], SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, vid_vw, vid_vh, sdl_windows_flags_f[vid_fullscreen]);
   if(vid_SDLWindow=nil)then
   begin
      WriteSDLError('SDL_CreateWindow');
      exit;
   end;

   // SDL Display modes info
   UpdateDisplayModes;

   vid_SDLRenderer:= SDL_CreateRenderer(vid_SDLWindow, vid_SDLRendererI,SDL_RENDERER_TARGETTEXTURE);
   if(vid_SDLRenderer=nil)then
   begin
      WriteSDLError('SDL_CreateRenderer');
      exit;
   end;
   if(SDL_GetRendererInfo(vid_SDLRenderer,@rInfo)<0)then
   begin
      WriteSDLError('SDL_GetRendererInfo');
      exit;
   end;
   vid_SDLRendererName:=rInfo.name;
   vid_SDLRendererNameConfig:=vid_SDLRendererName;
   WriteLog('Selected renderer: '+rInfo.name);

   vid_ApplyResolution;

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

      case s of
'-renderer': vid_SDLRendererName:=ParamStr(i+1);
'-test'    : test_mode:=1;
{$IFDEF DTEST}
'-testD'   : test_mode:=2;
{$ENDIF}
      end;
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



procedure MainInit;
begin
   g_GameCycle:=false;

   fr_init;

   StartParams;
   randomize;

   GameObjectsInit;
   InitDefaultMaps;

   {$IFDEF _FULLGAME}

   input_InitDefaultActionHotkeys;

   cfg_read;

   if not(InitVideo)then exit;
   if not(InitSound)then exit;

   draw_LoadingScreen(str_loading_init,c_red);

   saveload_MakeSaveData;
   replay_MakeReplayHeaderData;
   menu_ReBuild;
   InitRX2Y;
   language_ENG;
   language_Switch;
   InitUIDDataCL;
   missile_InitCLData;
   gfx_MakeUnitIcons;
   FillChar(ui_dPlayer,SizeOf(ui_dPlayer),0);

   {$ENDIF}

   if not(InitNET)then exit;

   Map_randommap;
   GameDefaultAll;

   NEW(sys_EVENT);

   g_GameCycle:=true;

   {$IFNDEF _FULLGAME}
   Dedicated_Init;
   {$ELSE}
  // campaings_InitData;
   {$ENDIF}
end;
