
const

cfg_key_PlayerName     = 'player_name';
cfg_key_SoundVolume    = 'sound_volume';
cfg_key_MusicBolume    = 'music_volume';
cfg_key_ScrollSpeed    = 'scroll_speed';
cfg_key_FullScreen     = 'fullscreen';
cfg_key_MouseScroll    = 'mouse_scroll';
cfg_key_ShadowsMode    = 'colored_shadows';
cfg_key_ServerAddr     = 'server_addr';
cfg_key_ServerPort     = 'server_port';
cfg_key_Language       = 'language';
cfg_key_RMBAction      = 'right_mouse_action';
cfg_key_VidWidth       = 'vid_width';
cfg_key_VidHeight      = 'vid_height';
cfg_key_g_FixedPos     = 'g_fixed_positions';
cfg_key_g_AISlots      = 'g_default_ai';
cfg_key_g_Generators   = 'g_generators';
cfg_key_ReplayQuality  = 'replay_quality';
cfg_key_ReplayName     = 'replay_name';
cfg_key_ReplayRecord   = 'replay_record';
cfg_key_ClientQuality  = 'cleint_quality';
cfg_key_PanelPos       = 'vid_panelPos';
cfg_key_MiniMapPos     = 'vid_MiniiMapPos';
cfg_key_HealthBars     = 'vid_health_bars';
cfg_key_ColorScheme    = 'vid_player_colors';
cfg_key_APM            = 'vid_APM';
cfg_key_FPS            = 'vid_FPS';

function b2si1(b:byte  ):single;begin b2si1:=b/255;       end;
function si12b(b:single):byte  ;begin si12b:=trunc(b*255);end;

procedure cfg_setval(vr,vl:string);
var vlw:word;
    vli:integer;
begin
   vlw:=s2w(vl);
   vli:=s2i(vl);

   case vr of
cfg_key_PlayerName    : PlayerName       := vl;
cfg_key_SoundVolume   : snd_svolume1     := b2si1(vlw);
cfg_key_MusicBolume   : snd_mvolume1     := b2si1(vlw);
cfg_key_ScrollSpeed   : vid_CamSpeed     := vli;
cfg_key_FullScreen    : vid_fullscreen   :=(vl=str_b2c[true]);
cfg_key_MouseScroll   : vid_CamMSEScroll   :=(vl=str_b2c[true]);
cfg_key_ShadowsMode   : vid_ColoredShadow:=(vl=str_b2c[true]);
cfg_key_ServerAddr    : net_cl_svaddr    := vl;
cfg_key_ServerPort    : net_sv_pstr      := vl;
cfg_key_Language      : ui_language      :=(vl=str_b2c[true]);
cfg_key_RMBAction     : m_action         :=(vl=str_b2c[true]);
cfg_key_VidWidth      : vid_vw           := vli;
cfg_key_VidHeight     : vid_vh           := vli;
cfg_key_g_FixedPos    : g_fixed_positions:=(vl=str_b2c[true]);
cfg_key_g_AISlots     : g_ai_slots       := vlw;
cfg_key_g_Generators  : g_generators     := vlw;
cfg_key_ReplayName    : rpls_str_name    := vl;
cfg_key_ReplayRecord  : rpls_Recording   :=(vl=str_b2c[true]);
cfg_key_ReplayQuality : rpls_Quality     := vlw;
cfg_key_ClientQuality : net_Quality      := vlw;
cfg_key_PanelPos      : vid_PannelPos    := vlw;
cfg_key_MiniMapPos    : vid_MiniMapPos   :=(vl=str_b2c[true]);
cfg_key_HealthBars    : vid_uhbars       := vlw;
cfg_key_ColorScheme   : vid_plcolors     := vlw;
cfg_key_APM           : vid_APM          :=(vl=str_b2c[true]);
cfg_key_FPS           : vid_FPS          :=(vl=str_b2c[true]);
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
         cfg_parse_str(s);
      end;
      close(f);

      if(snd_svolume1<0)then snd_svolume1:=0 else if(snd_svolume1>1)then snd_svolume1:=1;
      if(snd_mvolume1<0)then snd_svolume1:=0 else if(snd_mvolume1>1)then snd_mvolume1:=1;
      vid_CamSpeed:=mm3i(1,vid_CamSpeed,max_CamSpeed);

      PlayerName:=txt_ValidateStr(PlayerName,PlayerNameLen,@k_pname);
      if(length(PlayerName)=0)then PlayerName:=str_defaultPlayerName;

      vid_vw:=mm3i(vid_minw,vid_vw,vid_maxw);
      vid_vh:=mm3i(vid_minh,vid_vh,vid_maxh);

      if(g_ai_slots  >gms_g_maxai       )then g_ai_slots   :=gms_g_maxai;
      if(g_generators>gms_g_maxgens     )then g_generators :=gms_g_maxgens;

      if(rpls_Quality>cl_UpT_arrayN_RPLs)then rpls_Quality :=cl_UpT_arrayN_RPLs;
      if(net_Quality >cl_UpT_arrayN     )then net_Quality  :=cl_UpT_arrayN;

      if(vid_PannelPos>3                )then vid_PannelPos:=0;
      if(vid_uhbars   >2                )then vid_uhbars   :=0;
      if(vid_plcolors >vid_maxplcolors  )then vid_plcolors :=0;
   end;
   menu_res_w:=vid_vw;
   menu_res_h:=vid_vh;

   txt_ValidateServerAddr;
   txt_ValidateServerPort;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,cfgfn);
{$I-}rewrite(f);{$I+} if (ioresult<>0) then exit;

   writeln(f,cfg_key_PlayerName    ,'=',PlayerName                );
   writeln(f,cfg_key_SoundVolume   ,'=',si12b(snd_svolume1)       );
   writeln(f,cfg_key_MusicBolume   ,'=',si12b(snd_mvolume1)       );
   writeln(f,cfg_key_FullScreen    ,'=',str_b2c[vid_fullscreen]   );
   writeln(f,cfg_key_ScrollSpeed   ,'=',vid_CamSpeed              );
   writeln(f,cfg_key_MouseScroll   ,'=',str_b2c[vid_CamMSEScroll]   );
   writeln(f,cfg_key_ShadowsMode   ,'=',str_b2c[vid_ColoredShadow]);
   writeln(f,cfg_key_ServerAddr    ,'=',net_cl_svaddr             );
   writeln(f,cfg_key_ServerPort    ,'=',net_sv_pstr               );
   writeln(f,cfg_key_Language      ,'=',str_b2c[ui_language]      );
   writeln(f,cfg_key_RMBAction     ,'=',str_b2c[m_action]         );
   writeln(f,cfg_key_VidWidth      ,'=',vid_vw                    );
   writeln(f,cfg_key_VidHeight     ,'=',vid_vh                    );
   writeln(f,cfg_key_ReplayQuality ,'=',rpls_Quality              );
   writeln(f,cfg_key_ReplayName    ,'=',rpls_str_name             );
   writeln(f,cfg_key_ReplayRecord  ,'=',str_b2c[rpls_Recording]   );
   writeln(f,cfg_key_ClientQuality ,'=',net_Quality               );
   writeln(f,cfg_key_g_FixedPos    ,'=',str_b2c[g_fixed_positions]);
   writeln(f,cfg_key_g_AISlots     ,'=',g_ai_slots                );
   writeln(f,cfg_key_g_Generators  ,'=',g_generators              );
   writeln(f,cfg_key_PanelPos      ,'=',vid_PannelPos             );
   writeln(f,cfg_key_MiniMapPos    ,'=',str_b2c[vid_MiniMapPos]   );
   writeln(f,cfg_key_HealthBars    ,'=',vid_uhbars                );
   writeln(f,cfg_key_ColorScheme   ,'=',vid_plcolors              );
   writeln(f,cfg_key_APM           ,'=',str_b2c[vid_APM]          );
   writeln(f,cfg_key_FPS           ,'=',str_b2c[vid_FPS]          );

   close(f);
end;



