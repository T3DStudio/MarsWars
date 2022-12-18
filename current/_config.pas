
const

cfg_key_name    : shortstring = 'player_name';
cfg_key_sndv    : shortstring = 'sound_volume';
cfg_key_mscv    : shortstring = 'music_volume';
cfg_key_vspd    : shortstring = 'scroll_speed';
cfg_key_fscr    : shortstring = 'fullscreen';
cfg_key_vmm     : shortstring = 'mouse_scroll';
cfg_key_saddr   : shortstring = 'server_addr';
cfg_key_sport   : shortstring = 'server_port';
cfg_key_lng     : shortstring = 'language';
cfg_key_mai     : shortstring = 'right_mouse_action';
cfg_key_vidvw   : shortstring = 'vid_width';
cfg_key_vidvh   : shortstring = 'vid_height';
cfg_key_gsb     : shortstring = 'g_start_base';
cfg_key_gsp     : shortstring = 'g_show_positions';
cfg_key_gai     : shortstring = 'g_default_ai';
cfg_key_gcg     : shortstring = 'g_generators';
cfg_key_rpnui   : shortstring = 'UPT_replay';
cfg_key_npnui   : shortstring = 'UPT_network';
cfg_key_ppos    : shortstring = 'vid_panel';
cfg_key_uhbar   : shortstring = 'vid_health_bars';
cfg_key_plcol   : shortstring = 'vid_player_colors';


function b2si1(b:byte  ):single;begin b2si1:=b/255;       end;
function si12b(b:single):byte  ;begin si12b:=trunc(b*255);end;

procedure cfg_setval(vr,vl:string);
var vlw:word;
begin
   vlw:=s2w(vl);

   if(vr=cfg_key_name )then PlayerName      := vl;
   if(vr=cfg_key_sndv )then snd_svolume1    := b2si1(vlw);
   if(vr=cfg_key_mscv )then snd_mvolume1    := b2si1(vlw);
   if(vr=cfg_key_vspd )then vid_CamSpeed    := vlw;
   if(vr=cfg_key_fscr )then vid_fullscreen  :=(vl=b2c[true]);
   if(vr=cfg_key_vmm  )then vid_vmm         :=(vl=b2c[true]);
   if(vr=cfg_key_saddr)then net_cl_svstr    := vl;
   if(vr=cfg_key_sport)then net_sv_pstr     := vl;
   if(vr=cfg_key_lng  )then ui_language     :=(vl=b2c[true]);
   if(vr=cfg_key_mai  )then m_action        :=(vl=b2c[true]);
   if(vr=cfg_key_vidvw)then vid_vw          := vlw;
   if(vr=cfg_key_vidvh)then vid_vh          := vlw;
   if(vr=cfg_key_gsb  )then g_start_base    := vlw;
   if(vr=cfg_key_gsp  )then g_fixed_positions:=(vl=b2c[true]);
   if(vr=cfg_key_gai  )then g_ai_slots      := vlw;
   if(vr=cfg_key_gcg  )then g_cgenerators   := vlw;
   if(vr=cfg_key_rpnui)then rpls_pnui       := vlw;
   if(vr=cfg_key_npnui)then net_pnui        := vlw;
   if(vr=cfg_key_ppos )then vid_ppos        := vlw;
   if(vr=cfg_key_uhbar)then vid_uhbars      := vlw;
   if(vr=cfg_key_plcol)then vid_plcolors    := vlw;
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
      if(vid_CamSpeed   >127)then vid_CamSpeed   :=127;

      if(length(PlayerName)>NameLen)then SetLength(PlayerName,NameLen);

      vid_vw:=mm3(vid_minw,vid_vw,vid_maxw);
      vid_vh:=mm3(vid_minh,vid_vh,vid_maxh);

      if(g_ai_slots   >gms_g_maxai  )then g_ai_slots   :=gms_g_maxai;
      if(g_start_base >gms_g_startb )then g_start_base :=gms_g_startb;
      if(g_cgenerators>gms_g_maxgens)then g_cgenerators:=gms_g_maxgens;

      if(rpls_pnui   >_cl_pnun)then rpls_pnui   :=_cl_pnun;
      if(net_pnui    >_cl_pnun)then net_pnui    :=_cl_pnun;
      if(vid_ppos    >3       )then vid_ppos    :=0;
      if(vid_uhbars  >2       )then vid_uhbars  :=0;
      if(vid_plcolors>4       )then vid_plcolors:=0;
   end;
   swLNG;
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

   writeln(f,cfg_key_name ,'=',PlayerName         );
   writeln(f,cfg_key_sndv ,'=',si12b(snd_svolume1));
   writeln(f,cfg_key_mscv ,'=',si12b(snd_mvolume1));
   writeln(f,cfg_key_fscr ,'=',b2c[vid_fullscreen]);
   writeln(f,cfg_key_vspd ,'=',vid_CamSpeed       );
   writeln(f,cfg_key_vmm  ,'=',b2c[vid_vmm]    );
   writeln(f,cfg_key_saddr,'=',net_cl_svstr    );
   writeln(f,cfg_key_sport,'=',net_sv_pstr     );
   writeln(f,cfg_key_lng  ,'=',b2c[ui_language]);
   writeln(f,cfg_key_mai  ,'=',b2c[m_action]   );
   writeln(f,cfg_key_vidvw,'=',vid_vw          );
   writeln(f,cfg_key_vidvh,'=',vid_vh          );
   writeln(f,cfg_key_rpnui,'=',rpls_pnui       );
   writeln(f,cfg_key_npnui,'=',net_pnui        );
   writeln(f,cfg_key_gsb  ,'=',g_start_base    );
   writeln(f,cfg_key_gsp  ,'=',b2c[g_fixed_positions]);
   writeln(f,cfg_key_gai  ,'=',g_ai_slots      );
   writeln(f,cfg_key_gcg  ,'=',g_cgenerators   );
   writeln(f,cfg_key_ppos ,'=',vid_ppos        );
   writeln(f,cfg_key_uhbar,'=',vid_uhbars      );
   writeln(f,cfg_key_plcol,'=',vid_plcolors    );

   close(f);
end;



