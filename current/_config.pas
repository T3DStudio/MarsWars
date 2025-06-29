
const

cfg_key_PlayerName     = 'player_name';
cfg_key_SoundVolume    = 'sound_volume';
cfg_key_MusicBolume    = 'music_volume';
cfg_key_PlayListSize   = 'music_playListSize';
cfg_key_ScrollSpeed    = 'ui_scroll_speed';
cfg_key_MouseScroll    = 'ui_mouse_scroll';
cfg_key_ShadowsMode    = 'ui_colored_shadows';
cfg_key_Language       = 'ui_language';
cfg_key_RMBAction      = 'ui_right_mouse_action';
cfg_key_PanelPos       = 'ui_CtrlBarPos';
cfg_key_MiniMapPos     = 'ui_MiniMapPos';
cfg_key_HealthBars     = 'ui_health_bars';
cfg_key_ColorScheme    = 'ui_player_colors';
cfg_key_APM            = 'ui_APM';
cfg_key_FPS            = 'ui_FPS';
cfg_key_CtrlBarScale   = 'ui_CBar_scale';
cfg_key_MiniMapScale   = 'ui_MiniMap_scale';
cfg_key_VidWidth       = 'vid_width';
cfg_key_VidHeight      = 'vid_height';
cfg_key_Renderer       = 'vid_SDLRenderer';
cfg_key_FullScreen     = 'vid_fullscreen';
cfg_key_g_FixedPos     = 'g_fixed_positions';
cfg_key_g_AISlots      = 'g_default_ai';
cfg_key_ReplayQuality  = 'replay_quality';
cfg_key_ReplayName     = 'replay_name';
cfg_key_ReplayRecord   = 'replay_record';
cfg_key_NetQuality     = 'net_client_quality';
cfg_key_ServerAddr     = 'net_server_addr';
cfg_key_ServerPort     = 'net_server_port';


function b2si1(b:byte  ):single;begin b2si1:=b/255;       end;
function si12b(b:single):byte  ;begin si12b:=trunc(b*255);end;

procedure cfg_setval(vr,vl:string);
var vlw:word;
    vli:integer;
begin
   vlw:=s2w(vl);
   vli:=s2i(vl);

   case vr of
cfg_key_PlayerName    : PlayerName            := vl;
cfg_key_SoundVolume   : snd_svolume1          := b2si1(vlw);
cfg_key_MusicBolume   : snd_mvolume1          := b2si1(vlw);
cfg_key_PlayListSize  : snd_PlayListSize      := vlw;
cfg_key_ScrollSpeed   : ui_CamSpeedBase       := vli;
cfg_key_MouseScroll   : ui_CamMSEScroll       :=(vl=str_b2c[true]);
cfg_key_ShadowsMode   : ui_ColoredShadow      :=(vl=str_b2c[true]);
cfg_key_Language      : ui_language           :=(vl=str_b2c[true]);
cfg_key_PanelPos      : ui_CBarPos            := enum_val2TUIControlBarPos(vli);
cfg_key_MiniMapPos    : ui_MiniMapPos         :=(vl=str_b2c[true]);
cfg_key_HealthBars    : ui_UnitHealthBars     := enum_val2TUIUnitHBarsOption (vli);
cfg_key_ColorScheme   : ui_PlayersColorSchema := enum_val2TPlayersColorSchema(vli);
cfg_key_APM           : ui_ShowAPM            :=(vl=str_b2c[true]);
cfg_key_FPS           : ui_ShowFPS            :=(vl=str_b2c[true]);
cfg_key_CtrlBarScale  : ui_ControlBar_msc     := vli;
cfg_key_MiniMapScale  : ui_MiniMap_msc        := vli;
cfg_key_ServerAddr    : net_cl_svaddr         := vl;
cfg_key_ServerPort    : net_sv_pstr           := vl;
cfg_key_NetQuality    : net_Quality           := vlw;
cfg_key_RMBAction     : m_action              :=(vl=str_b2c[true]);
cfg_key_VidWidth      : vid_vw                := vli;
cfg_key_VidHeight     : vid_vh                := vli;
cfg_key_Renderer      : if(length(vid_SDLRendererName)=0)
                   then vid_SDLRendererName   := vl;
cfg_key_FullScreen    : vid_fullscreen        :=(vl=str_b2c[true]);
cfg_key_g_FixedPos    : g_fixed_positions     :=(vl=str_b2c[true]);
cfg_key_g_AISlots     : g_ai_slots            := vlw;
cfg_key_ReplayName    : rpls_str_prefix       := vl;
cfg_key_ReplayRecord  : rpls_Recording        :=(vl=str_b2c[true]);
cfg_key_ReplayQuality : rpls_Quality          := vlw;
   end;

end;

procedure cfg_parse_line(s:shortstring);
var vr,vl:shortstring;
    i:byte;
begin
   vr:='';
   vl:='';
   i :=pos('=',s);
   if(i>0)then
   begin
      vr:=copy(s,1,i-1);
      delete(s,1,i);
      vl:=s;
   end;
   cfg_setval(vr,vl);
end;

procedure cfg_read;
var f:text;
    s:shortstring;
begin
   if FileExists(cfgfn) then
   begin
      assign(f,cfgfn);
      {$I-}
      reset(f);
      {$I+}
      if(ioresult<>0)then exit;
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_line(s);
      end;
      close(f);

      if(snd_svolume1<0)then snd_svolume1:=0 else if(snd_svolume1>1)then snd_svolume1:=1;
      if(snd_mvolume1<0)then snd_svolume1:=0 else if(snd_mvolume1>1)then snd_mvolume1:=1;
      if(snd_PlayListSize>snd_PlayListSizeMax)then snd_PlayListSize:=snd_PlayListSizeMax;
      ui_CamSpeedBase:=mm3i(1,ui_CamSpeedBase,max_CamSpeed);

      PlayerName:=txt_ValidateStr(PlayerName,PlayerNameLen,@k_pname);
      if(length(PlayerName)=0)then PlayerName:=str_defaultPlayerName;

      ui_ControlBar_msc     := mm3i(min_CBarScalePrc,ui_ControlBar_msc,max_CBarScalePrc);
      ui_MiniMap_msc        := mm3i(min_MMapScalePrc,ui_MiniMap_msc   ,max_MMapScalePrc);

      if(g_ai_slots    >gms_g_maxai       )then g_ai_slots    :=gms_g_maxai;
      if(map_generators>gms_g_maxgens     )then map_generators:=gms_g_maxgens;

      if(rpls_Quality>cl_UpT_arrayN_RPLs)then rpls_Quality :=cl_UpT_arrayN_RPLs;
      if(net_Quality >cl_UpT_arrayN     )then net_Quality  :=cl_UpT_arrayN;
   end;

   txt_ValidateServerAddr;
   txt_ValidateServerPort;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,cfgfn);
{$I-}rewrite(f);{$I+}if(ioresult<>0)then exit;

   writeln(f,cfg_key_PlayerName    ,'=',PlayerName                );
   writeln(f,cfg_key_SoundVolume   ,'=',si12b(snd_svolume1)       );
   writeln(f,cfg_key_MusicBolume   ,'=',si12b(snd_mvolume1)       );
   writeln(f,cfg_key_PlayListSize  ,'=',snd_PlayListSize          );
   writeln(f,cfg_key_FullScreen    ,'=',str_b2c[vid_fullscreen]   );
   writeln(f,cfg_key_ScrollSpeed   ,'=',ui_CamSpeedBase           );
   writeln(f,cfg_key_MouseScroll   ,'=',str_b2c[ui_CamMSEScroll]  );
   writeln(f,cfg_key_ShadowsMode   ,'=',str_b2c[ui_ColoredShadow] );
   writeln(f,cfg_key_ServerAddr    ,'=',net_cl_svaddr             );
   writeln(f,cfg_key_ServerPort    ,'=',net_sv_pstr               );
   writeln(f,cfg_key_Language      ,'=',str_b2c[ui_language]      );
   writeln(f,cfg_key_RMBAction     ,'=',str_b2c[m_action]         );
   writeln(f,cfg_key_VidWidth      ,'=',vid_vw                    );
   writeln(f,cfg_key_VidHeight     ,'=',vid_vh                    );
   writeln(f,cfg_key_ReplayQuality ,'=',rpls_Quality              );
   writeln(f,cfg_key_ReplayName    ,'=',rpls_str_prefix           );
   writeln(f,cfg_key_ReplayRecord  ,'=',str_b2c[rpls_Recording]   );
   writeln(f,cfg_key_NetQuality    ,'=',net_Quality               );
   writeln(f,cfg_key_g_FixedPos    ,'=',str_b2c[g_fixed_positions]);
   writeln(f,cfg_key_g_AISlots     ,'=',g_ai_slots                );
   writeln(f,cfg_key_PanelPos      ,'=',ord(ui_CBarPos)           );
   writeln(f,cfg_key_MiniMapPos    ,'=',str_b2c[ui_MiniMapPos]    );
   writeln(f,cfg_key_HealthBars    ,'=',ord(ui_UnitHealthBars)    );
   writeln(f,cfg_key_ColorScheme   ,'=',ord(ui_PlayersColorSchema));
   writeln(f,cfg_key_APM           ,'=',str_b2c[ui_ShowAPM]       );
   writeln(f,cfg_key_FPS           ,'=',str_b2c[ui_ShowFPS]       );
   writeln(f,cfg_key_Renderer      ,'=',vid_SDLRendererName       );
   writeln(f,cfg_key_CtrlBarScale  ,'=',ui_ControlBar_msc         );
   writeln(f,cfg_key_MiniMapScale  ,'=',ui_MiniMap_msc            );

   close(f);
end;



