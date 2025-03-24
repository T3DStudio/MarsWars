
const

cfg_key_name    = 'player_name';
cfg_key_sndv    = 'sound_volume';
cfg_key_mlistn  = 'music_list_size';
cfg_key_mscv    = 'music_volume';
cfg_key_vspd    = 'scroll_speed';
cfg_key_fscr    = 'fullscreen';
cfg_key_vmm     = 'mouse_scroll';
cfg_key_shdws   = 'colored_shadows';
cfg_key_saddr   = 'server_addr';
cfg_key_sport   = 'server_port';
cfg_key_lng     = 'language';
cfg_key_mai     = 'right_mouse_action';
cfg_key_vidvw   = 'vid_width';
cfg_key_vidvh   = 'vid_height';
cfg_key_gsp     = 'g_show_positions';
cfg_key_gai     = 'g_default_ai';
cfg_key_gcg     = 'g_generators';
cfg_key_rpnui   = 'UPT_replay';
cfg_key_npnui   = 'UPT_network';
cfg_key_ppos    = 'vid_panel';
cfg_key_uhbar   = 'vid_health_bars';
cfg_key_plcol   = 'vid_player_colors';
cfg_key_APM     = 'vid_APM';
cfg_key_FPS     = 'vid_FPS';


function b2si1(b:byte  ):single;begin b2si1:=b/255;       end;
function si12b(b:single):byte  ;begin si12b:=trunc(b*255);end;

procedure cfg_setval(vr,vl:string);
var vlw:word;
    vli:integer;
begin
   vlw:=s2w(vl);
   vli:=s2i(vl);

   case vr of
cfg_key_name  : PlayerName       := vl;
cfg_key_sndv  : snd_svolume1     := b2si1(vlw);
cfg_key_mscv  : snd_mvolume1     := b2si1(vlw);
cfg_key_mlistn: snd_musicListSize:= vlw;
cfg_key_vspd  : vid_CamSpeed     := vli;
cfg_key_fscr  : vid_fullscreen   :=(vl=b2c[true]);
cfg_key_vmm   : vid_CamMScroll   :=(vl=b2c[true]);
cfg_key_shdws : vid_ColoredShadow:=(vl=b2c[true]);
cfg_key_saddr : net_cl_svstr     := vl;
cfg_key_sport : net_sv_pstr      := vl;
cfg_key_lng   : ui_language      :=(vl=b2c[true]);
cfg_key_mai   : m_action         :=(vl=b2c[true]);
cfg_key_vidvw : vid_vw           := vli;
cfg_key_vidvh : vid_vh           := vli;
cfg_key_gsp   : g_fixed_positions:=(vl=b2c[true]);
cfg_key_gai   : g_ai_slots       := vlw;
cfg_key_gcg   : g_generators    := vlw;
cfg_key_rpnui : rpls_pnui        := vlw;
cfg_key_npnui : net_pnui         := vlw;
cfg_key_ppos  : vid_ppos         := vlw;
cfg_key_uhbar : vid_uhbars       := vlw;
cfg_key_plcol : vid_plcolors     := vlw;
cfg_key_APM   : vid_APM          :=(vl=b2c[true]);
cfg_key_FPS   : vid_FPS          :=(vl=b2c[true]);
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
      {$I-}reset(f);{$I+} if (ioresult<>0) then exit;
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_str(s);
      end;
      close(f);

      if(snd_svolume1<0  )then snd_svolume1:=0 else if(snd_svolume1>1)then snd_svolume1:=1;
      if(snd_mvolume1<0  )then snd_svolume1:=0 else if(snd_mvolume1>1)then snd_mvolume1:=1;
      if(snd_musicListSize=0)
      then snd_musicListSize:=1
      else
        if(snd_musicListSize>snd_musicListSizeMax)then snd_musicListSize:=snd_musicListSizeMax;
      vid_CamSpeed:=mm3(1,vid_CamSpeed,127);

      if(length(PlayerName)>NameLen)then SetLength(PlayerName,NameLen);

      vid_vw:=mm3(vid_minw,vid_vw,vid_maxw);
      vid_vh:=mm3(vid_minh,vid_vh,vid_maxh);

      if(g_ai_slots   >gms_g_maxai  )then g_ai_slots   :=gms_g_maxai;
      if(g_generators >gms_g_maxgens)then g_generators :=gms_g_maxgens;

      if(rpls_pnui   >_cl_pnun_rpls  )then rpls_pnui   :=_cl_pnun_rpls;
      if(net_pnui    >_cl_pnun       )then net_pnui    :=_cl_pnun;

      if(vid_ppos    >3              )then vid_ppos    :=0;
      if(vid_uhbars  >2              )then vid_uhbars  :=0;
      if(vid_plcolors>vid_maxplcolors)then vid_plcolors:=0;
   end;
   m_vrx:=vid_vw;
   m_vry:=vid_vh;
   net_cl_saddr;
   net_sv_sport;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,cfgfn);
{$I-}rewrite(f);{$I+} if (ioresult<>0) then exit;

   writeln(f,cfg_key_name  ,'=',PlayerName            );
   writeln(f,cfg_key_sndv  ,'=',si12b(snd_svolume1)   );
   writeln(f,cfg_key_mscv  ,'=',si12b(snd_mvolume1)   );
   writeln(f,cfg_key_mlistn,'=',snd_musicListSize     );
   writeln(f,cfg_key_fscr  ,'=',b2c[vid_fullscreen]   );
   writeln(f,cfg_key_vspd  ,'=',vid_CamSpeed          );
   writeln(f,cfg_key_vmm   ,'=',b2c[vid_CamMScroll]   );
   writeln(f,cfg_key_shdws ,'=',b2c[vid_ColoredShadow]);
   writeln(f,cfg_key_saddr ,'=',net_cl_svstr          );
   writeln(f,cfg_key_sport ,'=',net_sv_pstr           );
   writeln(f,cfg_key_lng   ,'=',b2c[ui_language]      );
   writeln(f,cfg_key_mai   ,'=',b2c[m_action]         );
   writeln(f,cfg_key_vidvw ,'=',vid_vw                );
   writeln(f,cfg_key_vidvh ,'=',vid_vh                );
   writeln(f,cfg_key_rpnui ,'=',rpls_pnui             );
   writeln(f,cfg_key_npnui ,'=',net_pnui              );
   writeln(f,cfg_key_gsp   ,'=',b2c[g_fixed_positions]);
   writeln(f,cfg_key_gai   ,'=',g_ai_slots            );
   writeln(f,cfg_key_gcg   ,'=',g_generators          );
   writeln(f,cfg_key_ppos  ,'=',vid_ppos              );
   writeln(f,cfg_key_uhbar ,'=',vid_uhbars            );
   writeln(f,cfg_key_plcol ,'=',vid_plcolors          );
   writeln(f,cfg_key_APM   ,'=',b2c[vid_APM]          );
   writeln(f,cfg_key_FPS   ,'=',b2c[vid_FPS]          );

   close(f);
end;



