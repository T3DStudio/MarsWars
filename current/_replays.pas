

procedure _rpls_pre;
const pl_n_ch : array[false..true] of char = ('#','*');
var   f:file;
vr,t,hp:byte;
     fn:shortstring;
     mw:integer;
     wr:cardinal;
begin
   _rpls_stat:='';

   fn:=str_f_rpls+_rpls_l[_rpls_ls]+str_e_rpls;

   if(_rpls_l[_rpls_ls]<>'')then
   if(FileExists(fn))then
   begin
      assign(f,fn);
      {$I-}reset(f,1);{$I+}if(ioresult<>0)then
      begin
         _rpls_stat:=str_svld_errors[2];
         exit;
      end;
      if(FileSize(f)<rpl_hsize)then
      begin
         close(f);
         _rpls_stat:=str_svld_errors[3];
         exit;
      end;
      vr:=0;
      {$I-}
      BlockRead(f,vr,SizeOf(Ver));
      if(vr=Ver)then
      begin
         hp:=0;
         vr:=0;
         mw:=0;
         wr:=0;
         BlockRead(f,wr,sizeof(map_seed ));_rpls_stat:=str_map+': '+c2s(wr)        +#13+' ';wr:=0;
         BlockRead(f,mw,SizeOf(map_mw   ));_rpls_stat:=_rpls_stat+str_m_siz+i2s(mw)+#13+' ';mw:=0;
         BlockRead(f,vr,sizeof(map_liq  ));
         if(vr<=7)then begin _rpls_stat:=_rpls_stat+str_m_liq+_str_mx(vr)+#13+' '; end
                  else begin _rpls_stat:=str_svld_errors[4];close(f);exit;         end;
         BlockRead(f,vr,sizeof(map_obs  ));
         if(vr<=7)then begin _rpls_stat:=_rpls_stat+str_m_obs+_str_mx(vr)+#13+' '; end
                  else begin _rpls_stat:=str_svld_errors[4];close(f);exit;         end;
         BlockRead(f,vr,sizeof(map_sym  ));
         BlockRead(f,vr,sizeof(g_addon  ));_rpls_stat:=_rpls_stat+str_addon[vr>0]+#13+' ';
         BlockRead(f,vr,sizeof(g_mode   ));
         if(vr in gamemodes)then begin _rpls_stat:=_rpls_stat+str_gmode[vr]+#13;    end
                            else begin _rpls_stat:=str_svld_errors[4];close(f);exit;end;
         BlockRead(f,vr,sizeof(g_startb ));vr:=0;
         BlockRead(f,vr,sizeof(g_shpos  ));vr:=0;
         BlockRead(f,hp,SizeOf(HPlayer  ));

         //_rpls_stat:=_rpls_stat+str_players+':'+#13;

         for vr:=1 to MaxPlayers do
         begin
            BlockRead(f,fn ,sizeof(fn));

            _rpls_stat:=_rpls_stat+chr(vr)+pl_n_ch[vr=hp]+#25+fn;

            t:=0;
            BlockRead(f,t,1);
            if(t=PS_none)then
            begin
               _rpls_stat:=_rpls_stat+#13;
               BlockRead(f,mw,3);
            end
            else
            begin
               BlockRead(f,t ,1);
               BlockRead(f,t ,1);
               if(t<=r_cnt)
               then _rpls_stat:=_rpls_stat+','+str_race[t][2]
               else _rpls_stat:=_rpls_stat+',?';
               BlockRead(f,t ,1); _rpls_stat:=_rpls_stat+','+b2s(t)+#13;
            end;
         end;
      end
      else _rpls_stat:=str_svld_errors[4];
      if(IOResult<>0)then _rpls_stat:=str_svld_errors[4];
      {$I+}
      close(f);
   end else _rpls_stat:=str_svld_errors[1];
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
const vxyc = 5;
var  i :byte;
     fn:shortstring;
     fs:cardinal;
_vx,_vy:byte;
begin
   if(G_Started=false)or(_rpls_rst=rpl_none)then
   begin
      rpl_abort;
   end
   else
    if(G_Started)and(g_paused=0)then
     case _rpls_rst of
     rpl_whead   : begin
                      if(menu_s2=ms2_camp)then
                      begin
                         rpl_abort;
                         exit;
                      end;

                      {$I-}
                      assign(_rpls_file,str_f_rpls+_rpls_lrname+str_e_rpls);
                      rewrite(_rpls_file,1);
                      {$I+}

                      if(ioresult<>0)
                      then rpl_abort
                      else
                      begin
                         _rpls_rst  :=rpl_wunit;
                         _rpls_fileo:=true;
                         _rpls_u    :=MaxPlayerUnits+1;
                         _rpls_nwrch:=true;
                         _rpls_vidm :=false;

                         {$I-}
                         BlockWrite(_rpls_file,ver        ,SizeOf(ver     ));
                         BlockWrite(_rpls_file,map_seed   ,SizeOf(map_seed));
                         BlockWrite(_rpls_file,map_mw     ,SizeOf(map_mw  ));
                         BlockWrite(_rpls_file,map_liq    ,SizeOf(map_liq ));
                         BlockWrite(_rpls_file,map_obs    ,SizeOf(map_obs ));
                         BlockWrite(_rpls_file,map_sym    ,SizeOf(map_sym ));

                         BlockWrite(_rpls_file,g_addon    ,SizeOf(g_addon ));
                         BlockWrite(_rpls_file,g_mode     ,SizeOf(g_mode  ));
                         BlockWrite(_rpls_file,g_startb   ,SizeOf(g_startb));
                         BlockWrite(_rpls_file,g_shpos    ,SizeOf(g_shpos ));
                         BlockWrite(_rpls_file,HPlayer    ,sizeof(HPlayer ));

                         for i:=1 to MaxPlayers do
                          with _Players[i] do
                          begin
                             BlockWrite(_rpls_file,name ,sizeof(name ));
                             BlockWrite(_rpls_file,state,sizeof(state));
                             BlockWrite(_rpls_file,race ,sizeof(race ));
                             BlockWrite(_rpls_file,mrace,sizeof(mrace));
                             BlockWrite(_rpls_file,team ,sizeof(team ));
                          end;
                         {$I+}

                         if(ioresult<>0)then rpl_abort;
                      end;
                   end;
     rpl_wunit   : if((vid_rtui mod 2)=0) then
                   begin
                      _vx:=byte(vid_vx shr vxyc);
                      _vy:=byte(vid_vy shr vxyc);

                      i:=0;
                      if(_rpls_nwrch    )then i:=i or %10000000;
                      if(_rpls_vidx<>_vx)
                      or(_rpls_vidy<>_vy)then i:=i or %01000000;
                      i:=i or (G_Paused and %00111111);

                      if((i and %11000000)>0)or(G_Paused=0)then
                      begin
                         {$I-}
                         BlockWrite(_rpls_file,i,sizeof(i));
                         {$I+}
                         if(_rpls_nwrch)then
                         begin
                            _wudata_chat(HPlayer,true);
                            _rpls_nwrch:=false;
                         end;
                         if((i and %01000000)>0)then
                         begin
                            _rpls_vidx:=_vx;
                            _rpls_vidy:=_vy;
                            {$I-}
                            BlockWrite(_rpls_file,_rpls_vidx,sizeof(_rpls_vidx));
                            BlockWrite(_rpls_file,_rpls_vidy,sizeof(_rpls_vidy));
                            {$I+}
                         end;

                         if(G_Paused=0)then _wclinet_gframe(HPlayer,true);
                      end;

                      if(IOResult<>0)then rpl_abort;
                   end;
     rpl_rhead   : begin
                      if(_rpls_ls<0)or(_rpls_ls>=_rpls_ln)then
                      begin
                         _rpls_rst  :=rpl_none;
                         g_started  :=false;
                         _rpls_stat :='';
                         exit;
                      end;

                      fn:=str_f_rpls+_rpls_l[_rpls_ls]+str_e_rpls;

                      if(not FileExists(fn))then
                      begin
                         _rpls_rst  :=rpl_none;
                         g_started  :=false;
                         _rpls_stat :=str_svld_errors[1];
                         exit;
                      end;

                      {$I-}
                      assign(_rpls_file,fn);
                      reset(_rpls_file,1);
                      {$I+}

                      if(ioresult<>0)then
                      begin
                         rpl_abort;
                         g_started  :=false;
                         _rpls_stat :=str_svld_errors[2];
                      end
                      else
                      begin
                         fs:=FileSize(_rpls_file);

                         if(fs<rpl_hsize)then
                         begin
                            rpl_abort;
                            g_started  :=false;
                            _rpls_stat :=str_svld_errors[3];
                            exit;
                         end;

                         i:=0;
                         {$I-}
                         BlockRead(_rpls_file,i,SizeOf(Ver));
                         {$I+}

                         if(i<>ver)then
                         begin
                            rpl_abort;
                            g_started  :=false;
                            _rpls_stat:=str_svld_errors[4];
                         end
                         else
                         begin
                            DefGameObjects;

                            {$I-}
                            BlockRead(_rpls_file,map_seed ,SizeOf(map_seed ));
                            BlockRead(_rpls_file,map_mw   ,SizeOf(map_mw   ));
                            BlockRead(_rpls_file,map_liq  ,SizeOf(map_liq  ));
                            BlockRead(_rpls_file,map_obs  ,SizeOf(map_obs  ));
                            BlockRead(_rpls_file,map_sym  ,SizeOf(map_sym  ));
                            BlockRead(_rpls_file,g_addon  ,SizeOf(g_addon  ));
                            BlockRead(_rpls_file,g_mode   ,SizeOf(g_mode   ));
                            BlockRead(_rpls_file,g_startb ,SizeOf(g_startb ));
                            BlockRead(_rpls_file,g_shpos  ,SizeOf(g_shpos  ));
                            BlockRead(_rpls_file,HPlayer  ,sizeof(HPlayer  ));
                            {$I+}

                            if(map_mw<MinSMapW)or(map_mw>MaxSMapW)
                            or(map_liq>7)or(map_obs>7)
                            or not(g_mode in gamemodes)or(g_startb>gms_g_startb)or(HPlayer>MaxPlayers)then
                            begin
                               rpl_abort;
                               g_started  :=false;
                               _rpls_stat:=str_svld_errors[4];
                               DefGameObjects;
                               exit;
                            end;

                            {$I-}
                            for i:=1 to MaxPlayers do
                             with _Players[i] do
                             begin
                                BlockRead(_rpls_file,name ,sizeof(name));
                                BlockRead(_rpls_file,state,sizeof(state));
                                BlockRead(_rpls_file,race ,sizeof(race));
                                BlockRead(_rpls_file,mrace,sizeof(mrace));
                                BlockRead(_rpls_file,team ,sizeof(team));
                             end;
                            {$I+}

                            if(_rpls_pnu=0)then _rpls_pnu:=NetTickN;
                            UnitStepNum:=trunc(MaxUnits/_rpls_pnu)*NetTickN;
                            if(UnitStepNum=0)then UnitStepNum:=1;

                            _rpls_fileo :=true;
                            _rpls_rst   :=rpl_runit;
                            _rpls_pnu   :=0;
                            _rpls_vidm  :=false;
                            _rpls_player:=HPlayer;

                            map_premap;
                            _moveHumView(map_psx[Hplayer] , map_psy[Hplayer]);

                            _view_bounds;
                            ui_tab    :=2;
                            G_Started :=true;
                            _menu     :=false;
                            ServerSide:=false;
                         end;
                      end;
                   end;
     rpl_runit   : if((vid_rtui mod 2)=0)then
                   begin
                       if(eof(_rpls_file)or(ioresult<>0))then
                       begin
                          rpl_abort;
                          _rpls_rst:=rpl_end;
                          G_Paused :=1;
                          _fsttime :=false;
                          exit;
                       end;

                       if(_rpls_step<=0)then _rpls_step:=1;
                       while (_rpls_step>0) do
                       begin
                          {$I-}
                          BlockRead(_rpls_file,i,SizeOf(i));
                          {$I+}
                          G_Paused:=i and %00111111;

                          if((i and %10000000)>0)then
                          begin
                             _rudata_chat(_rpls_player,true);
                             net_chat_shlm:=chat_shlm_t;
                             vid_mredraw  :=true;
                             PlaySNDM(snd_chat);
                          end;
                          if((i and %01000000)>0)then
                          begin
                             {$I-}
                             BlockRead(_rpls_file,_rpls_vidx,sizeof(_rpls_vidx));
                             BlockRead(_rpls_file,_rpls_vidy,sizeof(_rpls_vidy));
                             {$I+}
                          end;

                          if(G_Paused=0)then _rclinet_gframe(0,true);

                          if (_rpls_step>1)then effects_sprites(false,false);
                          dec(_rpls_step,1);
                       end;
                       _rpls_step:=1;

                       if(_rpls_vidm)then
                       begin
                          vid_vx:=(vid_vx+integer(_rpls_vidx shl vxyc)) div 2;
                          vid_vy:=(vid_vy+integer(_rpls_vidy shl vxyc)) div 2;
                          _view_bounds;
                       end;
                   end;

     rpl_end     : begin G_Paused:=1; end;
     end;
end;

procedure _rpls_sel;
begin
   if(0<=_rpls_ls)and(_rpls_ls<_rpls_ln)
   then _rpls_pre
   else
     if(g_started=false)then _rpls_stat:='';
end;

procedure _rpls_make_lst;
var Info : TSearchRec;
       s : string;
begin
   _rpls_sm:=0;
   _rpls_ln:=0;
   setlength(_rpls_l,0);
   if(FindFirst(str_f_rpls+'*'+str_e_rpls,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       delete(s,length(s)-(length(str_e_rpls)-1),length(str_e_rpls));
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
   if(_rpls_ls<0)or(_rpls_ls>=_rpls_ln)then exit;

   fn:=str_f_rpls+_rpls_l[_rpls_ls]+str_e_rpls;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      _rpls_make_lst;
   end;
end;


