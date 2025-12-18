
const

cfg_key_PlayerName      = 'player_name';
cfg_key_SoundVolume     = 'sound_volume';
cfg_key_MusicVolume     = 'music_volume';
cfg_key_MusicListSize   = 'music_list_size';
cfg_key_NetServerAddr   = 'net_server_addr';
cfg_key_NetServerPort   = 'net_server_port';
cfg_key_NetQuality      = 'net_quality';
cfg_key_UICamScrollSpeed= 'ui_cam_scroll_speed';
cfg_key_UICamMouseScroll= 'ui_mouse_scroll';
cfg_key_UIColoredShadows= 'ui_colored_shadows';
cfg_key_UILanguage      = 'ui_language';
cfg_key_UIRMBAction     = 'ui_right_mouse_action';
cfg_key_UICtrlPanelPos  = 'ui_ctrl_panel_pos';
cfg_key_UIHealthBars    = 'ui_health_bars';
cfg_key_UIPlayersColor  = 'ui_players_color';
cfg_key_UIShowAPM       = 'ui_show_APM';
cfg_key_VidResolutionW  = 'vid_width';
cfg_key_VidResolutionH  = 'vid_height';
cfg_key_VidWindowed     = 'vid_windowed';
cfg_key_VidShowFPS      = 'vid_show_FPS';
cfg_key_MapGenerators   = 'map_generators';
cfg_key_GFixedSpawns    = 'g_fixed_positions';
cfg_key_GAISlots        = 'g_AI_slots';
cfg_key_GRecord         = 'g_record';
cfg_key_GRecordQuality  = 'g_record_quality';
cfg_key_menuScalse      = 'menu_scale';
cfg_key_menuScaleSmooth = 'menu_scale_smooth';


function b2si1(b:byte  ):single;begin b2si1:=b/255;       end;
function si12b(b:single):byte  ;begin si12b:=trunc(b*255);end;

procedure cfg_setval(vr,vl:shortstring);
var vlw:word;
    vli:integer;
begin
   vlw:=s2w(vl);
   vli:=s2i(vl);

   case vr of
cfg_key_PlayerName      : PlayerName         := vl;
cfg_key_SoundVolume     : snd_SoundVolume    := vlw;
cfg_key_MusicVolume     : snd_MusicVolume    := vlw;
cfg_key_MusicListSize   : snd_musicListSize  := vlw;
cfg_key_NetServerAddr   : menu_ClientAddress := vl;
cfg_key_NetServerPort   : menu_ServerPort    := vl;
cfg_key_menuScalse      : menu_scale         :=(vl=b2c[true]);
cfg_key_menuScaleSmooth : menu_ScaleSmooth   :=(vl=b2c[true]);
cfg_key_NetQuality      : net_cl_Quality     := vlw;
cfg_key_UICamScrollSpeed: ui_CamSpeed        := vli;
cfg_key_UICamMouseScroll: ui_MouseScroll     :=(vl=b2c[true]);
cfg_key_UIColoredShadows: ui_ColoredShadow   :=(vl=b2c[true]);
cfg_key_UILanguage      : ui_language        :=(vl=b2c[true]);
cfg_key_UICtrlPanelPos  : ui_ControlPanelPos := vlw;
cfg_key_UIHealthBars    : ui_HealthBars      := vlw;
cfg_key_UIPlayersColor  : ui_PlayersColor    := vlw;
cfg_key_UIShowAPM       : ui_ShowAPM         :=(vl=b2c[true]);
cfg_key_UIRMBAction     : m_RightClickAct    :=(vl=b2c[true]);
cfg_key_VidResolutionW  : vid_vw             := vli;
cfg_key_VidResolutionH  : vid_vh             := vli;
cfg_key_VidWindowed     : vid_windowed       :=(vl=b2c[true]);
cfg_key_VidShowFPS      : vid_ShowFPS        :=(vl=b2c[true]);
cfg_key_GFixedSpawns    : g_FixedPositions   :=(vl=b2c[true]);
cfg_key_GAISlots        : g_AISlots          := vlw;
cfg_key_MapGenerators   : map_generators     := vlw;
cfg_key_GRecord         : rpls_Record        :=(vl=b2c[true]);
cfg_key_GRecordQuality  : rpls_Quality       := vlw;
   end;

end;

procedure cfg_parse_str(s:shortstring);
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
   if(FileExists(str_ConfigFName))then
   begin
      assign(f,str_ConfigFName);
      {$I-}reset(f);{$I+} if (ioresult<>0) then exit;
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_str(s);
      end;
      close(f);

      if(snd_SoundVolume>snd_MaxSoundVolume)then snd_SoundVolume:=snd_MaxSoundVolume;
      if(snd_MusicVolume>snd_MaxSoundVolume)then snd_MusicVolume:=snd_MaxSoundVolume;
      snd_svolume1:=snd_SoundVolume/snd_MaxSoundVolume;
      snd_mvolume1:=snd_MusicVolume/snd_MaxSoundVolume;

      if(snd_musicListSize=0)
      then snd_musicListSize:=1
      else
        if(snd_musicListSize>snd_MaxMusicListSize)then snd_musicListSize:=snd_MaxMusicListSize;
      ui_CamSpeed:=byte(mm3i(1,ui_CamSpeed,ui_MaxCamSpeed));

      if(length(PlayerName)>MaxPlayerNameLen)then SetLength(PlayerName,MaxPlayerNameLen);

      vid_vw:=max2i(vid_minw,vid_vw);
      vid_vh:=max2i(vid_minh,vid_vh);

      if(g_AISlots      >g_MaxAISlots     )then g_AISlots     :=g_MaxAISlots;
      if(map_generators >map_MaxGenerators)then map_generators:=map_MaxGenerators;

      if(rpls_Quality   >rpls_MaxQuality  )then rpls_Quality  :=rpls_MaxQuality;
      if(net_cl_Quality >net_MaxQuality   )then net_cl_Quality:=net_MaxQuality;

      if(ui_ControlPanelPos>ui_MaxControlPanelPos)then ui_ControlPanelPos:=0;
      if(ui_HealthBars     >ui_MaxHealthBars     )then ui_HealthBars     :=0;
      if(ui_PlayersColor   >ui_MaxPlayersColor   )then ui_PlayersColor   :=0;
   end;
   menu_ResolutionWi:=vid_vw;
   menu_ResolutionHi:=vid_vh;
   menu_GetClientAddress;
   menu_GetServerPort;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,str_ConfigFName);
{$I-}rewrite(f);{$I+} if (ioresult<>0) then exit;

   writeln(f,cfg_key_PlayerName      ,'=',PlayerName            );
   writeln(f,cfg_key_SoundVolume     ,'=',snd_SoundVolume       );
   writeln(f,cfg_key_MusicVolume     ,'=',snd_MusicVolume       );
   writeln(f,cfg_key_MusicListSize   ,'=',snd_musicListSize     );
   writeln(f,cfg_key_NetServerAddr   ,'=',menu_ClientAddress    );
   writeln(f,cfg_key_NetServerPort   ,'=',menu_ServerPort       );
   writeln(f,cfg_key_NetQuality      ,'=',net_cl_Quality        );
   writeln(f,cfg_key_UICamScrollSpeed,'=',ui_CamSpeed           );
   writeln(f,cfg_key_UICamMouseScroll,'=',b2c[ui_MouseScroll]   );
   writeln(f,cfg_key_UIColoredShadows,'=',b2c[ui_ColoredShadow] );
   writeln(f,cfg_key_UILanguage      ,'=',b2c[ui_language]      );
   writeln(f,cfg_key_UIRMBAction     ,'=',b2c[m_RightClickAct]  );
   writeln(f,cfg_key_UICtrlPanelPos  ,'=',ui_ControlPanelPos    );
   writeln(f,cfg_key_UIHealthBars    ,'=',ui_HealthBars         );
   writeln(f,cfg_key_UIPlayersColor  ,'=',ui_PlayersColor       );
   writeln(f,cfg_key_UIShowAPM       ,'=',b2c[ui_ShowAPM]       );
   writeln(f,cfg_key_VidResolutionW  ,'=',vid_vw                );
   writeln(f,cfg_key_VidResolutionH  ,'=',vid_vh                );
   writeln(f,cfg_key_VidWindowed     ,'=',b2c[vid_windowed]     );
   writeln(f,cfg_key_VidShowFPS      ,'=',b2c[vid_ShowFPS]      );
   writeln(f,cfg_key_MapGenerators   ,'=',map_generators        );
   writeln(f,cfg_key_GRecord         ,'=',b2c[rpls_Record]      );
   writeln(f,cfg_key_GRecordQuality  ,'=',rpls_Quality          );
   writeln(f,cfg_key_GFixedSpawns    ,'=',b2c[g_FixedPositions]);
   writeln(f,cfg_key_GAISlots        ,'=',g_AISlots            );
   writeln(f,cfg_key_menuScalse      ,'=',b2c[menu_scale]       );
   writeln(f,cfg_key_menuScaleSmooth ,'=',b2c[menu_ScaleSmooth] );

   close(f);
end;



