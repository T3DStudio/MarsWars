

procedure cfg_setval(vr,vl:shortstring);
var vlb:word;
begin
   vlb:=s2w(vl);

   if (vr='name' )then PlayerName  := vl;
   if (vr='sndv' )then snd_svolume := vlb;
   if (vr='mscv' )then snd_mvolume := vlb;
   if (vr='vspd' )then vid_vmspd   := vlb;
   if (vr='fscr' )then _fscr       :=(vl=b2pm[true,2]);
   if (vr='vmm'  )then vid_vmm     :=(vl=b2pm[true,2]);
   if (vr='saddr')then net_cl_svstr:= vl;
   if (vr='sport')then net_sv_pstr := vl;
   if (vr='lng'  )then _lng        :=(vl=b2pm[true,2]);
   if (vr='vidmw')then vid_mw      :=vlb;
   if (vr='vidmh')then vid_mh      :=vlb;
   if (vr='right')then m_a_inv     :=(vl=b2pm[true,2]);
end;

procedure cfg_parse_str(s:shortstring);
var vr,vl:shortstring;
    i:byte;
begin
   vr:='';
   vl:='';
   i :=pos('=',s);
   if(i=0)then exit;
   vr:=copy(s,1,i-1);
   delete(s,1,i);
   vl:=s;
   cfg_setval(vr,vl);
end;

procedure cfg_read;
var f:text;
    s:shortstring;
    i:byte;
begin
   if FileExists(cfgfn) then
   begin
      {$I-}
      assign(f,cfgfn);
      reset(f);
      if (ioresult<>0) then exit;
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_str(s);
      end;
      close(f);
      {$I+}

      if(snd_svolume>127) then snd_svolume:=127;
      if(snd_mvolume>127) then snd_mvolume:=127;
      if(vid_vmspd>175)then vid_vmspd:=175;

      s:=PlayerName;
      PlayerName:='';
      for i:=1 to length(s) do
       if(s[i] in k_kbstr)then
       begin
          PlayerName:=PlayerName+s[i];
          if(length(PlayerName)=NameLen)then break;
       end;

      if(vid_mw<vid_minw)then vid_mw:=vid_minw;
      if(vid_mw>vid_maxw)then vid_mw:=vid_maxw;
      if(vid_mh<vid_minh)then vid_mh:=vid_minh;
      if(vid_mh>vid_maxh)then vid_mh:=vid_maxh;
   end;
   m_vrx:=vid_mw;
   m_vry:=vid_mh;
   net_cl_saddr;
   net_sv_sport;
end;

procedure cfg_write;
var f:text;
begin
   {$I-}
   assign(f,cfgfn);
   rewrite(f);
   if (ioresult<>0) then exit;

   writeln(f,'sndv' ,'=',snd_svolume);
   writeln(f,'mscv' ,'=',snd_mvolume);
   writeln(f,'name' ,'=',PlayerName);
   writeln(f,'fscr' ,'=',b2pm[_fscr,2]);
   writeln(f,'vspd' ,'=',vid_vmspd);
   writeln(f,'vmm'  ,'=',b2pm[vid_vmm,2]);
   writeln(f,'saddr','=',net_cl_svstr);
   writeln(f,'sport','=',net_sv_pstr);
   writeln(f,'lng'  ,'=',b2pm[_lng,2]);
   writeln(f,'vidmw','=',vid_mw);
   writeln(f,'vidmh','=',vid_mh);
   writeln(f,'right','=',b2pm[m_a_inv,2]);

   close(f);
   {$I+}
end;



