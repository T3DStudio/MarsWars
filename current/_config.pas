
const

cfg_key_name    = 'player_name';
cfg_key_sndv    = 'sound_volume';
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
cfg_key_gsb     = 'g_start_base';
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
cfg_key_vspd  : vid_CamSpeed     := vli;
cfg_key_fscr  : vid_fullscreen   :=(vl=str_b2c[true]);
cfg_key_vmm   : vid_CamMScroll   :=(vl=str_b2c[true]);
cfg_key_shdws : vid_ColoredShadow:=(vl=str_b2c[true]);
cfg_key_saddr : net_cl_svstr     := vl;
cfg_key_sport : net_sv_pstr      := vl;
cfg_key_lng   : ui_language      :=(vl=str_b2c[true]);
cfg_key_mai   : m_action         :=(vl=str_b2c[true]);
cfg_key_vidvw : vid_vw           := vli;
cfg_key_vidvh : vid_vh           := vli;
cfg_key_gsb   : g_start_base     := vlw;
cfg_key_gsp   : g_fixed_positions:=(vl=str_b2c[true]);
cfg_key_gai   : g_ai_slots       := vlw;
cfg_key_gcg   : g_generators     := vlw;
cfg_key_rpnui : rpls_pnui        := vlw;
cfg_key_npnui : net_pnui         := vlw;
cfg_key_ppos  : vid_PannelPos    := vlw;
cfg_key_uhbar : vid_uhbars       := vlw;
cfg_key_plcol : vid_plcolors     := vlw;
cfg_key_APM   : vid_APM          :=(vl=str_b2c[true]);
cfg_key_FPS   : vid_FPS          :=(vl=str_b2c[true]);
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
      vid_CamSpeed:=mm3(1,vid_CamSpeed,max_CamSpeed);

      PlayerName:=ValidateStr(PlayerName,NameLen,@k_kbstr);

      vid_vw:=mm3(vid_minw,vid_vw,vid_maxw);
      vid_vh:=mm3(vid_minh,vid_vh,vid_maxh);

      if(g_ai_slots  >gms_g_maxai    )then g_ai_slots  :=gms_g_maxai;
      if(g_start_base>gms_g_startb   )then g_start_base:=gms_g_startb;
      if(g_generators>gms_g_maxgens  )then g_generators:=gms_g_maxgens;

      if(rpls_pnui   >cl_UpT_arrayN_RPLs)then rpls_pnui:=cl_UpT_arrayN_RPLs;
      if(net_pnui    >cl_UpT_arrayN     )then net_pnui :=cl_UpT_arrayN;

      if(vid_PannelPos>3              )then vid_PannelPos    :=0;
      if(vid_uhbars   >2              )then vid_uhbars  :=0;
      if(vid_plcolors >vid_maxplcolors)then vid_plcolors:=0;
   end;
   menu_res_w:=vid_vw;
   menu_res_h:=vid_vh;
   net_cl_saddr;
   net_sv_sport;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,cfgfn);
{$I-}rewrite(f);{$I+} if (ioresult<>0) then exit;

   writeln(f,cfg_key_name  ,'=',PlayerName                );
   writeln(f,cfg_key_sndv  ,'=',si12b(snd_svolume1)       );
   writeln(f,cfg_key_mscv  ,'=',si12b(snd_mvolume1)       );
   writeln(f,cfg_key_fscr  ,'=',str_b2c[vid_fullscreen]   );
   writeln(f,cfg_key_vspd  ,'=',vid_CamSpeed              );
   writeln(f,cfg_key_vmm   ,'=',str_b2c[vid_CamMScroll]   );
   writeln(f,cfg_key_shdws ,'=',str_b2c[vid_ColoredShadow]);
   writeln(f,cfg_key_saddr ,'=',net_cl_svstr              );
   writeln(f,cfg_key_sport ,'=',net_sv_pstr               );
   writeln(f,cfg_key_lng   ,'=',str_b2c[ui_language]      );
   writeln(f,cfg_key_mai   ,'=',str_b2c[m_action]         );
   writeln(f,cfg_key_vidvw ,'=',vid_vw                    );
   writeln(f,cfg_key_vidvh ,'=',vid_vh                    );
   writeln(f,cfg_key_rpnui ,'=',rpls_pnui                 );
   writeln(f,cfg_key_npnui ,'=',net_pnui                  );
   writeln(f,cfg_key_gsb   ,'=',g_start_base              );
   writeln(f,cfg_key_gsp   ,'=',str_b2c[g_fixed_positions]);
   writeln(f,cfg_key_gai   ,'=',g_ai_slots                );
   writeln(f,cfg_key_gcg   ,'=',g_generators              );
   writeln(f,cfg_key_ppos  ,'=',vid_PannelPos             );
   writeln(f,cfg_key_uhbar ,'=',vid_uhbars                );
   writeln(f,cfg_key_plcol ,'=',vid_plcolors              );
   writeln(f,cfg_key_APM   ,'=',str_b2c[vid_APM]          );
   writeln(f,cfg_key_FPS   ,'=',str_b2c[vid_FPS]          );

   close(f);
end;



