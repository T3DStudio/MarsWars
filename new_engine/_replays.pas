
procedure _rpls_pre;
var   f : file;
     fn : string;
     vr,
     ml,
     mo,
     gm : byte;
     mw : integer;
     ms : cardinal;
     pls:TPList;
begin
   ms:=0;
   vr:=0;
   mw:=0;
   ml:=0;
   mo:=0;
   gm:=0;

   _rpls_stat:='';

   fn:=str_f_rpl+_rpls_l[_rpls_ls]+str_e_rpl;
   if(_rpls_l[_rpls_ls]<>'')then
    if(FileExists(fn)=false)
    then _rpls_stat:=str_svld_errors[1]
    else
    begin
       {$I-}
       assign(f,fn);
       reset(f,1);
       {$I+}
       if(ioresult<>0)
       then _rpls_stat:=str_svld_errors[2]
       else
       begin
         if(FileSize(f)<rpl_size)
         then _rpls_stat:=str_svld_errors[3]
         else
         begin
            {$I-}
            vr:=0;
            BlockRead(f,vr,SizeOf(ver));
            if(vr<>ver)
            then _rpls_stat:=str_svld_errors[4]
            else
            begin
                BlockRead(f,ms,sizeof(map_seed ));_rpls_stat:=str_map+c2s(ms)+#13+' ';

                BlockRead(f,mw,sizeof(map_mw   ));

                vr:=0;
                BlockRead(f,vr,SizeOf(vr));
                ml:=(vr and %00000111);
                mo:=(vr and %00111000) shr 3;
                gm:=(vr and %11000000) shr 6;

                if(mw<MinSMapW)or(mw>MaxSMapW)
                or(ml>4)or(mo>4)or(gm>1)
                then _rpls_stat:=str_svld_errors[4]
                else
                begin
                   _rpls_stat:=_rpls_stat+str_m_siz+w2s(mw)   +#13+' ';
                   _rpls_stat:=_rpls_stat+str_m_liq+str_xN[ml]+#13+' ';
                   _rpls_stat:=_rpls_stat+str_m_obs+str_xN[mo]+#13+' ';
                   _rpls_stat:=_rpls_stat+str_gmode[gm]       +#13    ;

                   _rpls_stat:=_rpls_stat+str_players+':'+#13;

                   gm:=0;
                   BlockRead(f,gm,SizeOf(gm));

                   FillChar(pls,SizeOf(pls),0);

                   for vr:=1 to MaxPlayers do
                    with pls[vr] do
                    begin
                       BlockRead(f,state,SizeOf(state));
                       BlockRead(f,name ,SizeOf(name ));
                       BlockRead(f,race ,SizeOf(race ));
                       BlockRead(f,mrace,SizeOf(mrace));
                       BlockRead(f,team ,SizeOf(team ));

                       ms:=0;
                       mw:=length(name);
                       while(mw>0)do
                       begin
                          if(name[mw] in k_kbstr)then inc(ms,1);
                          dec(mw,1);
                       end;
                       while(ms<NameLen)do
                       begin
                          name:=name+' ';
                          inc(ms,1);
                       end;

                       if(vr=gm)
                       then _rpls_stat:=_rpls_stat+chr(vr)+'#='+#25+name
                       else _rpls_stat:=_rpls_stat+chr(vr)+'# '+#25+name;

                       if(state<>PS_None)
                       then _rpls_stat:=_rpls_stat+' '+str_race[mrace][1]+str_race[mrace][2]+#25+' '+b2s(team)+#13
                       else _rpls_stat:=_rpls_stat+#13;
                    end;

                   if(vr>0)
                   then _rpls_cor:=true
                   else _rpls_stat:=str_svld_errors[4];
                end;
             end;
            {$I+}
          end;
          if(ioresult<>0)then
          begin
             _rpls_stat:=str_svld_errors[4];
             _rpls_cor:=false;
          end;
       end;

       close(f);
    end;
end;

procedure _rpls_sel;
begin
   _rpls_cor:=false;
   if(_rpls_ls<_rpls_ln)
   then _rpls_pre
   else
     if(g_started=false)then _rpls_stat:='';
end;

procedure rpl_abort;
begin
   if(_rpls_fileo)then
   begin
      close(_rpls_file);
      _rpls_fileo:=false;
   end;
   if(_rpls_rst>=rpl_rhead)then _rpls_rst  :=rpl_none;
end;

procedure _rpls_code;
var  i   : byte;
     fn  : string;
begin
   if(G_Started=false)or(_rpls_rst=rpl_none)then
   begin
      rpl_abort;
   end
   else
    if(G_Started)then
     case _rpls_rst of
     rpl_whead   : begin
                      if(menu_s2=ms2_camp)then
                      begin
                         _rpls_rst  :=rpl_none;
                         g_started  :=false;
                         _menu      :=true;
                      end;

                      {$I-}
                      assign(_rpls_file,str_f_rpl+_rpls_lrname+str_e_rpl);
                      rewrite(_rpls_file,1);
                      {$I+}
                      if(ioresult<>0)
                      then rpl_abort
                      else
                      begin
                         _rpls_rst   := rpl_wunit;
                         _rpls_fileo := true;
                         _rpls_u     := 1;
                         _rpls_nwrch := true;
                         _rpls_ic    := 0;

                         {$I-}
                         BlockWrite(_rpls_file,ver        ,SizeOf(ver     ));
                         BlockWrite(_rpls_file,map_seed   ,SizeOf(map_seed));
                         BlockWrite(_rpls_file,map_mw     ,SizeOf(map_mw  ));

                         i:=byte(map_liq and %00000111)+byte((map_obs shl 3) and %00111000)+byte((g_mode shl 6) and %11000000);
                         BlockWrite(_rpls_file,i,SizeOf(i));
                         BlockWrite(_rpls_file,HPlayer,SizeOf(HPlayer));

                         for i:=1 to MaxPlayers do
                          with _players[i] do
                          begin
                             BlockWrite(_rpls_file,state,SizeOf(state));
                             BlockWrite(_rpls_file,name ,SizeOf(name ));
                             BlockWrite(_rpls_file,race ,SizeOf(race ));
                             BlockWrite(_rpls_file,mrace,SizeOf(mrace));
                             BlockWrite(_rpls_file,team ,SizeOf(team ));
                          end;
                         {$I+}

                         if(ioresult<>0)then rpl_abort;
                      end;

                   end;
     rpl_wunit   : if(G_Status=0)or(_rpls_nwrch)then
                   begin
                      inc(_rpls_ic,1);
                      _rpls_ic:=_rpls_ic mod NetTickN;

                      if(_rpls_ic=0)then
                      begin

                         i:=0;
                         if(_rpls_nwrch)then i:=%10000000;
                         i:=i+(G_Status and %01111111);

                         {$I-}
                         BlockWrite(_rpls_file,i,sizeof(i));
                         if(_rpls_nwrch)then
                         begin
                            BlockWrite(_rpls_file,net_clchatm,sizeof(net_clchatm));
                            _rpls_nwrch:=false;
                         end;
                         {$I+}

                         if(G_Status=0)then _wclinet_gframe(HPlayer,true);

                         if(ioresult<>0)then rpl_abort;
                      end;
                   end;
     rpl_rhead   : begin
                      fn:=str_f_rpl+_rpls_l[_rpls_ls]+str_e_rpl;

                      _rpls_sel;
                      if(_rpls_cor=false)then
                      begin
                         G_Started:=false;
                         _menu:=true;
                         _rpls_rst:=rpl_none;
                         exit;
                      end;

                      {$I-}
                      assign(_rpls_file,fn);
                      reset(_rpls_file,1);
                      {$I+}
                      if(ioresult<>0)then
                      begin
                         g_started  :=false;
                         _rpls_stat :=str_svld_errors[2];
                         rpl_abort;
                      end
                      else
                      begin
                         DefGameObjects;

                         {$I-}
                         BlockRead(_rpls_file,i,SizeOf(Ver));

                         BlockRead(_rpls_file,map_seed ,SizeOf(map_seed));
                         BlockRead(_rpls_file,map_mw   ,SizeOf(map_mw  ));

                         BlockRead(_rpls_file,i,SizeOf(i));
                         map_liq:=(i and %00000111);
                         map_obs:=(i and %00111000) shr 3;
                         g_mode :=(i and %11000000) shr 6;

                         BlockRead(_rpls_file,_rpls_who,SizeOf(_rpls_who));

                         for i:=1 to MaxPlayers do
                          with _players[i] do
                          begin
                             BlockRead(_rpls_file,state,SizeOf(state));
                             BlockRead(_rpls_file,name ,SizeOf(name ));
                             BlockRead(_rpls_file,race ,SizeOf(race ));
                             BlockRead(_rpls_file,mrace,SizeOf(mrace));
                             BlockRead(_rpls_file,team ,SizeOf(team ));
                          end;
                         {$I+}

                         if(ioresult<>0)then
                         begin
                            rpl_abort;
                            Map_randommap;
                            DefGameObjects;
                            _rpls_stat:=str_fileerr;
                         end
                         else
                         begin
                            HPlayer:=_rpls_who;

                            _rpls_fileo:= true;
                            _rpls_rst  := rpl_runit;
                            _rpls_pause:= false;

                            Map_premap;

                            G_Started :=true;
                            _menu     :=false;
                            onlySVCode:=false;

                            _moveHumView(map_psx[HPlayer] , map_psy[HPlayer]);
                         end;
                      end;
                   end;
     rpl_runit   : if(_rpls_pause)
                   then G_Status:=17
                   else
                   begin
                      if(_rpls_ic>NetTickN)
                      then dec(_rpls_ic,1)
                      else
                      begin
                         inc(_rpls_ic,1);
                         _rpls_ic:=_rpls_ic mod NetTickN;
                      end;

                      if(_rpls_ic=0)then
                      begin
                         {$I-}

                         if(eof(_rpls_file)or(ioresult<>0))then
                         begin
                            rpl_abort;
                            _rpls_rst:=rpl_end;
                            G_Status :=18;
                            _fsttime:=false;
                         end
                         else
                         begin
                            if(_rpls_step=0)then _rpls_step:=1;

                            while (_rpls_step>0) do
                            begin
                               dec(_rpls_step,1);

                               i:=_rudata_byte(true);
                               {$I-}
                               if(ioresult=0)then
                                if((i and %10000000)>0)then
                                begin
                                   BlockRead(_rpls_file,net_clchatm,sizeof(net_clchatm));
                                   ui_chat_shlm:=chat_shlm_t;
                                   PlayGSND(snd_chat);
                                end;
                               {$I+}

                               G_Status:=(i and %01111111);

                               if(ioresult=0)then
                                if(G_Status=0)
                                then _rclinet_gframe(HPlayer,true)
                                else
                                  if(_rpls_step=0)then _rpls_ic:=vid_fps;

                               if(_rpls_step>1)then _effectsCycle(false);
                               if(ioresult<>0)then break;
                            end;

                            _rpls_step:=1;
                         end;
                      end;
                   end;

     rpl_end     : G_Status:=18;
     end;
end;

procedure _rpls_make_lst;
var Info : TSearchRec;
       s : string;
begin
   _rpls_sm:=0;
   _rpls_ln:=0;
   setlength(_rpls_l,0);
   if(FindFirst(str_f_rpl+'*'+str_e_rpl,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       delete(s,length(s)-3,4);
       if(s<>'')then
       begin
          inc(_rpls_ln,1);
          setlength(_rpls_l,_rpls_ln);
          _rpls_l[_rpls_ln-1]:=s;
       end;
    until (FindNext(info)<>0);
   FindClose(info);

   _rpls_sel;
end;

procedure _rpls_delete;
var fn:string;
begin
   fn:=str_f_rpl+_rpls_l[_rpls_ls]+str_e_rpl;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      _rpls_make_lst;
   end;
end;


