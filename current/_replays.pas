

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
         BlockRead(f,vr,sizeof(g_start_base ));vr:=0;
         BlockRead(f,vr,sizeof(g_show_positions  ));vr:=0;
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
      close(rpls_file);
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
                      assign(rpls_file,str_f_rpls+_rpls_lrname+str_e_rpls);
                      rewrite(rpls_file,1);
                      {$I+}

                      if(ioresult<>0)
                      then rpl_abort
                      else
                      begin
                         _rpls_rst  :=rpl_wunit;
                         _rpls_fileo:=true;
                         rpls_u    :=MaxPlayerUnits+1;
                         _rpls_nwrch:=true;
                         _rpls_vidm :=false;

                         {$I-}
                         BlockWrite(rpls_file,ver        ,SizeOf(ver     ));
                         BlockWrite(rpls_file,map_seed   ,SizeOf(map_seed));
                         BlockWrite(rpls_file,map_mw     ,SizeOf(map_mw  ));
                         BlockWrite(rpls_file,map_liq    ,SizeOf(map_liq ));
                         BlockWrite(rpls_file,map_obs    ,SizeOf(map_obs ));
                         BlockWrite(rpls_file,map_sym    ,SizeOf(map_sym ));

                         BlockWrite(rpls_file,g_addon    ,SizeOf(g_addon ));
                         BlockWrite(rpls_file,g_mode     ,SizeOf(g_mode  ));
                         BlockWrite(rpls_file,g_start_base   ,SizeOf(g_start_base));
                         BlockWrite(rpls_file,g_show_positions    ,SizeOf(g_show_positions ));
                         BlockWrite(rpls_file,HPlayer    ,sizeof(HPlayer ));

                         for i:=1 to MaxPlayers do
                          with _Players[i] do
                          begin
                             BlockWrite(rpls_file,name ,sizeof(name ));
                             BlockWrite(rpls_file,state,sizeof(state));
                             BlockWrite(rpls_file,race ,sizeof(race ));
                             BlockWrite(rpls_file,mrace,sizeof(mrace));
                             BlockWrite(rpls_file,team ,sizeof(team ));
                          end;
                         {$I+}

                         if(ioresult<>0)then rpl_abort;
                      end;
                   end;
     rpl_wunit   : if((vid_rtui mod 2)=0) then
                   begin
                      _vx:=byte(vid_cam_x shr vxyc);
                      _vy:=byte(vid_cam_y shr vxyc);

                      i:=0;
                      if(_rpls_nwrch    )then i:=i or %10000000;
                      if(_rpls_vidx<>_vx)
                      or(_rpls_vidy<>_vy)then i:=i or %01000000;
                      i:=i or (G_Paused and %00111111);

                      if((i and %11000000)>0)or(G_Paused=0)then
                      begin
                         {$I-}
                         BlockWrite(rpls_file,i,sizeof(i));
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
                            BlockWrite(rpls_file,_rpls_vidx,sizeof(_rpls_vidx));
                            BlockWrite(rpls_file,_rpls_vidy,sizeof(_rpls_vidy));
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
                      assign(rpls_file,fn);
                      reset(rpls_file,1);
                      {$I+}

                      if(ioresult<>0)then
                      begin
                         rpl_abort;
                         g_started  :=false;
                         _rpls_stat :=str_svld_errors[2];
                      end
                      else
                      begin
                         fs:=FileSize(rpls_file);

                         if(fs<rpl_hsize)then
                         begin
                            rpl_abort;
                            g_started  :=false;
                            _rpls_stat :=str_svld_errors[3];
                            exit;
                         end;

                         i:=0;
                         {$I-}
                         BlockRead(rpls_file,i,SizeOf(Ver));
                         {$I+}

                         if(i<>ver)then
                         begin
                            rpl_abort;
                            g_started  :=false;
                            _rpls_stat:=str_svld_errors[4];
                         end
                         else
                         begin
                            GameDefaultAll;

                            {$I-}
                            BlockRead(rpls_file,map_seed ,SizeOf(map_seed ));
                            BlockRead(rpls_file,map_mw   ,SizeOf(map_mw   ));
                            BlockRead(rpls_file,map_liq  ,SizeOf(map_liq  ));
                            BlockRead(rpls_file,map_obs  ,SizeOf(map_obs  ));
                            BlockRead(rpls_file,map_sym  ,SizeOf(map_sym  ));
                            BlockRead(rpls_file,g_addon  ,SizeOf(g_addon  ));
                            BlockRead(rpls_file,g_mode   ,SizeOf(g_mode   ));
                            BlockRead(rpls_file,g_start_base ,SizeOf(g_start_base ));
                            BlockRead(rpls_file,g_show_positions  ,SizeOf(g_show_positions  ));
                            BlockRead(rpls_file,HPlayer  ,sizeof(HPlayer  ));
                            {$I+}

                            if(map_mw<MinSMapW)or(map_mw>MaxSMapW)
                            or(map_liq>7)or(map_obs>7)
                            or not(g_mode in gamemodes)or(g_start_base>gms_g_startb)or(HPlayer>MaxPlayers)then
                            begin
                               rpl_abort;
                               g_started  :=false;
                               _rpls_stat:=str_svld_errors[4];
                               GameDefaultAll;
                               exit;
                            end;

                            {$I-}
                            for i:=1 to MaxPlayers do
                             with _Players[i] do
                             begin
                                BlockRead(rpls_file,name ,sizeof(name));
                                BlockRead(rpls_file,state,sizeof(state));
                                BlockRead(rpls_file,race ,sizeof(race));
                                BlockRead(rpls_file,mrace,sizeof(mrace));
                                BlockRead(rpls_file,team ,sizeof(team));
                             end;
                            {$I+}

                            if(_rpls_pnu=0)then _rpls_pnu:=NetTickN;
                            UnitStepTicks:=trunc(MaxUnits/_rpls_pnu)*NetTickN;
                            if(UnitStepTicks=0)then UnitStepTicks:=1;

                            _rpls_fileo :=true;
                            _rpls_rst   :=rpl_runit;
                            _rpls_pnu   :=0;
                            _rpls_vidm  :=false;
                            _rpls_player:=HPlayer;

                            map_premap;
                            MoveCamToPoint(map_psx[Hplayer] , map_psy[Hplayer]);

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
                       if(eof(rpls_file)or(ioresult<>0))then
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
                          BlockRead(rpls_file,i,SizeOf(i));
                          {$I+}
                          G_Paused:=i and %00111111;

                          if((i and %10000000)>0)then
                          begin
                             _rudata_chat(_rpls_player,true);
                             net_chat_shlm:=chat_shlm_t;
                             vid_menu_redraw  :=true;
                             //PlaySNDM(snd_chat);
                          end;
                          if((i and %01000000)>0)then
                          begin
                             {$I-}
                             BlockRead(rpls_file,_rpls_vidx,sizeof(_rpls_vidx));
                             BlockRead(rpls_file,_rpls_vidy,sizeof(_rpls_vidy));
                             {$I+}
                          end;

                          if(G_Paused=0)then _rclinet_gframe(0,true);

                          if (_rpls_step>1)then effects_sprites(false,false);
                          _rpls_step-=1;
                       end;
                       _rpls_step:=1;

                       if(_rpls_vidm)then
                       begin
                          vid_cam_x:=(vid_cam_x+integer(_rpls_vidx shl vxyc)) div 2;
                          vid_cam_y:=(vid_cam_y+integer(_rpls_vidy shl vxyc)) div 2;
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
          _rpls_ln+=1;
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


