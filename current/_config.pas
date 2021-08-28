
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
cfg_key_rpnui   : shortstring = 'UPT_replay';
cfg_key_npnui   : shortstring = 'UPT_network';
cfg_key_ppos    : shortstring = 'vid_panel';
cfg_key_uhbar   : shortstring = 'vid_health_bars';
cfg_key_plcol   : shortstring = 'vid_player_colors';



procedure cfg_setval(vr,vl:string);
var vlb:word;
begin
   vlb:=s2w(vl);

   if (vr=cfg_key_name )then PlayerName  := vl;
   if (vr=cfg_key_sndv )then snd_svolume := vlb;
   if (vr=cfg_key_mscv )then snd_mvolume := vlb;
   if (vr=cfg_key_vspd )then vid_vmspd   := vlb;
   if (vr=cfg_key_fscr )then _fscr       :=(vl=b2pm[true,2]);
   if (vr=cfg_key_vmm  )then vid_vmm     :=(vl=b2pm[true,2]);
   if (vr=cfg_key_saddr)then net_cl_svstr:= vl;
   if (vr=cfg_key_sport)then net_sv_pstr := vl;
   if (vr=cfg_key_lng  )then _lng        :=(vl=b2pm[true,2]);
   if (vr=cfg_key_mai  )then m_a_inv     :=(vl=b2pm[true,2]);
   if (vr=cfg_key_vidvw)then vid_vw      :=vlb;
   if (vr=cfg_key_vidvh)then vid_vh      :=vlb;
   if (vr=cfg_key_gsb  )then G_startb    :=vlb;
   if (vr=cfg_key_gsp  )then G_shpos     :=(vl=b2pm[true,2]);
   if (vr=cfg_key_gai  )then G_aislots   :=vlb;
   if (vr=cfg_key_rpnui)then _rpls_pnui  :=vlb;
   if (vr=cfg_key_npnui)then net_pnui    :=vlb;
   if (vr=cfg_key_ppos )then vid_ppos    :=vlb;
   if (vr=cfg_key_uhbar)then vid_uhbars  :=vlb;
   if (vr=cfg_key_plcol)then vid_plcolors:=vlb;
end;

procedure cfg_parse_str(s:string);
var vr,vl:string;
    i:byte;
begin
   vr:='';
   vl:='';
   i :=pos('=',s);
   vr:=copy(s,1,i-1);
   delete(s,1,i);
   vl:=s;
   cfg_setval(vr,vl);
end;

procedure cfg_read;
var f:text;
    s:string;
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

      if(snd_svolume>127) then snd_svolume:=127;
      if(snd_mvolume>127) then snd_mvolume:=127;
      if(vid_vmspd  >127) then vid_vmspd  :=127;

      if(length(PlayerName)>NameLen)then SetLength(PlayerName,NameLen);

      vid_vw:=mm3(vid_minw,vid_vw,vid_maxw);
      vid_vh:=mm3(vid_minh,vid_vh,vid_maxh);

      if(G_aislots>gms_g_maxai )then G_aislots:=gms_g_maxai;
      if(G_startb >gms_g_startb)then G_startb :=gms_g_startb;

      if(_rpls_pnui  >9)then _rpls_pnui  :=9;
      if(net_pnui    >9)then net_pnui    :=9;
      if(vid_ppos    >3)then vid_ppos    :=0;
      if(vid_uhbars  >2)then vid_uhbars  :=0;
      if(vid_plcolors>4)then vid_plcolors:=0;
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

   writeln(f,cfg_key_name ,'=',PlayerName     );
   writeln(f,cfg_key_sndv ,'=',snd_svolume    );
   writeln(f,cfg_key_mscv ,'=',snd_mvolume    );
   writeln(f,cfg_key_fscr ,'=',b2pm[_fscr,2]  );
   writeln(f,cfg_key_vspd ,'=',vid_vmspd      );
   writeln(f,cfg_key_vmm  ,'=',b2pm[vid_vmm,2]);
   writeln(f,cfg_key_saddr,'=',net_cl_svstr   );
   writeln(f,cfg_key_sport,'=',net_sv_pstr    );
   writeln(f,cfg_key_lng  ,'=',b2pm[_lng,2]   );
   writeln(f,cfg_key_mai  ,'=',b2pm[m_a_inv,2]);
   writeln(f,cfg_key_vidvw,'=',vid_vw         );
   writeln(f,cfg_key_vidvh,'=',vid_vh         );
   writeln(f,cfg_key_rpnui,'=',_rpls_pnui     );
   writeln(f,cfg_key_npnui,'=',net_pnui       );
   writeln(f,cfg_key_gsb  ,'=',G_startb       );
   writeln(f,cfg_key_gsp  ,'=',b2pm[G_shpos,2]);
   writeln(f,cfg_key_gai  ,'=',G_aislots      );
   writeln(f,cfg_key_ppos ,'=',vid_ppos       );
   writeln(f,cfg_key_uhbar,'=',vid_uhbars     );
   writeln(f,cfg_key_plcol,'=',vid_plcolors   );

   close(f);
end;



