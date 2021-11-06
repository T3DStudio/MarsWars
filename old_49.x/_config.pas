

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
   if (vr='mai'  )then m_a_inv     :=(vl=b2pm[true,2]);
   if (vr='vidmw')then vid_mw      :=vlb;
   if (vr='vidmh')then vid_mh      :=vlb;
   if (vr='gsb'  )then G_startb    :=vlb;
   if (vr='gsp'  )then G_shpos     :=(vl=b2pm[true,2]);
   if (vr='gai'  )then G_aislots   :=vlb;
   if (vr='rpnui')then _rpls_pnui  :=vlb;
   if (vr='npnui')then net_pnui    :=vlb;
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

      if(snd_svolume>127) then snd_svolume:=127;
      if(snd_mvolume>127) then snd_mvolume:=127;
      if(vid_vmspd  >127) then vid_vmspd  :=127;

      if(length(PlayerName)>NameLen)then SetLength(PlayerName,NameLen);

      if(vid_mw<vid_minw)then vid_mw:=vid_minw;
      if(vid_mh<vid_minh)then vid_mh:=vid_minh;
      if(vid_mw>vid_maxw)then vid_mw:=vid_maxw;
      if(vid_mh>vid_maxh)then vid_mh:=vid_maxh;

      if(G_aislots>7)then G_aislots:=7;
      if(G_startb >5)then G_startb :=5;

      if(_rpls_pnui>9)then  _rpls_pnui:=9;
      if(net_pnui  >9)then  net_pnui  :=9;
   end;
   swLNG;
   m_vrx:=vid_mw;
   m_vry:=vid_mh;
   net_cl_saddr;
   net_sv_sport;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,cfgfn);
   {$I-}rewrite(f);{$I+} if (ioresult<>0) then exit;

   writeln(f,'sndv' ,'=',snd_svolume    );
   writeln(f,'mscv' ,'=',snd_mvolume    );
   writeln(f,'name' ,'=',PlayerName     );
   writeln(f,'fscr' ,'=',b2pm[_fscr,2]  );
   writeln(f,'vspd' ,'=',vid_vmspd      );
   writeln(f,'vmm'  ,'=',b2pm[vid_vmm,2]);
   writeln(f,'saddr','=',net_cl_svstr   );
   writeln(f,'sport','=',net_sv_pstr    );
   writeln(f,'lng'  ,'=',b2pm[_lng,2]   );
   writeln(f,'mai'  ,'=',b2pm[m_a_inv,2]);
   writeln(f,'vidmw','=',vid_mw         );
   writeln(f,'vidmh','=',vid_mh         );
   writeln(f,'rpnui','=',_rpls_pnui     );
   writeln(f,'npnui','=',net_pnui       );
   writeln(f,'gsb'  ,'=',G_startb       );
   writeln(f,'gsp'  ,'=',b2pm[G_shpos,2]);
   writeln(f,'gai'  ,'=',G_aislots      );

   close(f);
end;



