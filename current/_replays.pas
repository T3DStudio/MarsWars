

procedure _rpls_pre;
const pl_n_ch : array[false..true] of char = ('#','*');
var   f:file;
vr,t,hp:byte;
     fn:shortstring;
     mw:integer;
     wr:cardinal;
begin
   rpls_str_data:='';

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(rpls_list[rpls_list_sel]<>'')then
   if(FileExists(fn))then
   begin
      {$I-}
      assign(f,fn);
      reset (f,1);
      {$I+}
      if(ioresult<>0)then
      begin
         rpls_str_data:=str_svld_errors[2];
         exit;
      end;
      if(FileSize(f)<rpl_hsize)then
      begin
         close(f);
         rpls_str_data:=str_svld_errors[3];
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
         BlockRead(f,wr,sizeof(map_seed ));rpls_str_data:=str_map+': '+c2s(wr)           +#13+' ';wr:=0;
         BlockRead(f,mw,SizeOf(map_mw   ));rpls_str_data:=rpls_str_data+str_m_siz+i2s(mw)+#13+' ';mw:=0;
         BlockRead(f,vr,sizeof(map_liq  ));
         if(vr<=7)then begin rpls_str_data:=rpls_str_data+str_m_liq+_str_mx(vr)+#13+' '; end
                  else begin rpls_str_data:=str_svld_errors[4];close(f);exit;            end;
         BlockRead(f,vr,sizeof(map_obs  ));
         if(vr<=7)then begin rpls_str_data:=rpls_str_data+str_m_obs+_str_mx(vr)+#13+' '; end
                  else begin rpls_str_data:=str_svld_errors[4];close(f);exit;            end;
         BlockRead(f,vr,sizeof(map_sym  ));
         BlockRead(f,vr,sizeof(g_addon  ));rpls_str_data:=rpls_str_data+str_addon[vr>0]+#13+' ';
         BlockRead(f,vr,sizeof(g_mode   ));
         if(vr in gamemodes)then begin rpls_str_data:=rpls_str_data+str_gmode[vr]+#13; end
                            else begin rpls_str_data:=str_svld_errors[4];close(f);exit;end;
         BlockRead(f,vr,sizeof(g_start_base ));vr:=0;
         BlockRead(f,vr,sizeof(g_show_positions  ));vr:=0;
         BlockRead(f,hp,SizeOf(HPlayer  ));

         //rpls_str_data:=rpls_str_data+str_players+':'+#13;

         for vr:=1 to MaxPlayers do
         begin
            BlockRead(f,fn ,sizeof(fn));

            rpls_str_data:=rpls_str_data+chr(vr)+pl_n_ch[vr=hp]+#25+fn;

            t:=0;
            BlockRead(f,t,1);
            if(t=PS_none)then
            begin
               rpls_str_data:=rpls_str_data+#13;
               BlockRead(f,mw,3);
            end
            else
            begin
               BlockRead(f,t ,1);
               BlockRead(f,t ,1);
               if(t<=r_cnt)
               then rpls_str_data:=rpls_str_data+','+str_race[t][2]
               else rpls_str_data:=rpls_str_data+',?';
               BlockRead(f,t ,1); rpls_str_data:=rpls_str_data+','+b2s(t)+#13;
            end;
         end;
      end
      else rpls_str_data:=str_svld_errors[4];
      if(IOResult<>0)then rpls_str_data:=str_svld_errors[4];
      {$I+}
      close(f);
   end
   else rpls_str_data:=str_svld_errors[1];
end;

procedure rpl_abort;
begin
   if(rpls_fstatus>rpls_file_none)then
   begin
      close(rpls_file);
      rpls_fstatus:=rpls_file_none;
   end;
   if(rpls_state>=rpl_rhead)then rpls_state:=rpl_none;
end;


procedure _rpls_code;
const vxyc = 5;
var  i :byte;
     fs:cardinal;
_vx,_vy:byte;
begin
   if(G_Started=false)or(rpls_state=rpl_none)or(menu_s2=ms2_camp)
   then rpl_abort
   else
    if(G_Started)and(g_paused=0)then
     case rpls_state of
     rpl_whead   : begin
                      rpl_abort;

                      rpls_str_path:=str_f_rpls+rpls_str_name+str_e_rpls;
                      {$I-}
                      assign (rpls_file,rpls_str_path);
                      rewrite(rpls_file,1);
                      {$I+}

                      if(ioresult<>0)
                      then rpl_abort
                      else
                      begin
                         rpls_state  :=rpl_wunit;
                         rpls_fstatus:=rpls_file_write;
                         rpls_u      :=MaxPlayerUnits+1;
                         rpls_player :=HPlayer;
                         rpls_log_n  :=_players[rpls_player].log_n;

                         rpls_plcam  :=false;

                         {$I-}
                         BlockWrite(rpls_file,ver        ,SizeOf(ver     ));
                         BlockWrite(rpls_file,map_seed   ,SizeOf(map_seed));
                         BlockWrite(rpls_file,map_mw     ,SizeOf(map_mw  ));
                         BlockWrite(rpls_file,map_liq    ,SizeOf(map_liq ));
                         BlockWrite(rpls_file,map_obs    ,SizeOf(map_obs ));
                         BlockWrite(rpls_file,map_sym    ,SizeOf(map_sym ));

                         BlockWrite(rpls_file,g_addon    ,SizeOf(g_addon ));
                         BlockWrite(rpls_file,g_mode     ,SizeOf(g_mode  ));
                         BlockWrite(rpls_file,g_start_base    ,SizeOf(g_start_base    ));
                         BlockWrite(rpls_file,g_show_positions,SizeOf(g_show_positions));
                         BlockWrite(rpls_file,rpls_player     ,sizeof(rpls_player     ));


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
     rpl_wunit   : if(rpls_fstatus<>rpls_file_write)
                   then rpl_abort
                   else
                     if((vid_rtui mod 2)=0)then
                     begin
                        _vx:=byte(vid_cam_x shr vxyc);
                        _vy:=byte(vid_cam_y shr vxyc);

                        i:=0;
                        if(_players[rpls_player].log_n<>rpls_log_n)then i:=i or %10000000;
                        if(rpls_vidx<>_vx)or(rpls_vidy<>_vy)       then i:=i or %01000000;
                        i:=i or (G_Paused and %00111111);

                        if((i and %11000000)>0)or(G_Paused=0)then
                        begin
                           {$I-}
                           BlockWrite(rpls_file,i,sizeof(i));
                           {$I+}
                           if((i and %10000000)>0)then _wudata_chat(rpls_player,@rpls_log_n,true);
                           if((i and %01000000)>0)then
                           begin
                              rpls_vidx:=_vx;
                              rpls_vidy:=_vy;
                              {$I-}
                              BlockWrite(rpls_file,rpls_vidx,sizeof(rpls_vidx));
                              BlockWrite(rpls_file,rpls_vidy,sizeof(rpls_vidy));
                              {$I+}
                           end;

                           if((i and %00111111)=0)then _wclinet_gframe(rpls_player,true);
                        end;

                        if(IOResult<>0)then rpl_abort;
                     end;
     rpl_rhead   : begin
                      rpl_abort;

                      if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then
                      begin
                         rpls_state   :=rpl_none;
                         g_started    :=false;
                         rpls_str_data:='';
                         exit;
                      end;

                      rpls_str_path:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

                      if(not FileExists(rpls_str_path))then
                      begin
                         rpls_state   :=rpl_none;
                         g_started    :=false;
                         rpls_str_data:=str_svld_errors[1];
                         exit;
                      end;

                      {$I-}
                      assign(rpls_file,rpls_str_path);
                      reset (rpls_file,1);
                      {$I+}

                      if(ioresult<>0)then
                      begin
                         rpl_abort;
                         g_started :=false;
                         rpls_str_data :=str_svld_errors[2];
                      end
                      else
                      begin
                         fs:=FileSize(rpls_file);

                         if(fs<rpl_hsize)then
                         begin
                            rpl_abort;
                            g_started :=false;
                            rpls_str_data :=str_svld_errors[3];
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
                            rpls_str_data:=str_svld_errors[4];
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
                            BlockRead(rpls_file,g_start_base    ,SizeOf(g_start_base    ));
                            BlockRead(rpls_file,g_show_positions,SizeOf(g_show_positions));
                            BlockRead(rpls_file,rpls_player,sizeof(rpls_player));
                            {$I+}

                            if(map_mw<MinSMapW)or(map_mw>MaxSMapW)
                            or(map_liq>7)or(map_obs>7)
                            or not(g_mode in gamemodes)
                            or(g_start_base>gms_g_startb)
                            or(rpls_player>MaxPlayers)then
                            begin
                               rpl_abort;
                               g_started:=false;
                               rpls_str_data:=str_svld_errors[4];
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

                            if(rpls_pnu=0)then rpls_pnu:=NetTickN;
                            UnitStepTicks:=trunc(MaxUnits/rpls_pnu)*NetTickN;
                            if(UnitStepTicks=0)then UnitStepTicks:=1;

                            rpls_fstatus:=rpls_file_read;
                            rpls_state  :=rpl_runit;
                            rpls_pnu    :=0;
                            HPlayer     :=rpls_player;

                            //observer    :=true;
                            rpls_plcam  :=false;

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
     rpl_runit   : if(rpls_fstatus<>rpls_file_read)
                   then rpl_abort
                   else
                     if((vid_rtui mod 2)=0)then
                     begin
                         if(eof(rpls_file)or(ioresult<>0))then
                         begin
                            rpl_abort;
                            rpls_state:=rpl_end;
                            G_Paused  :=1;
                            _fsttime  :=false;
                            exit;
                         end;

                         if(rpls_step<=0)then rpls_step:=1;
                         while(rpls_step>0)do
                         begin
                            {$I-}
                            BlockRead(rpls_file,i,SizeOf(i));
                            {$I+}
                            G_Paused:=i and %00111111;

                            if((i and %10000000)>0)then _rudata_chat(rpls_player,true);
                            if((i and %01000000)>0)then
                            begin
                               {$I-}
                               BlockRead(rpls_file,rpls_vidx,sizeof(rpls_vidx));
                               BlockRead(rpls_file,rpls_vidy,sizeof(rpls_vidy));
                               {$I+}
                            end;

                            if(G_Paused=0)then _rclinet_gframe(0,true);

                            if(rpls_step>1)then effects_sprites(false,false);
                            rpls_step-=1;
                         end;
                         rpls_step:=1;

                         if(rpls_plcam)then
                         begin
                            vid_cam_x:=(vid_cam_x+integer(rpls_vidx shl vxyc)) div 2;
                            vid_cam_y:=(vid_cam_y+integer(rpls_vidy shl vxyc)) div 2;
                            _view_bounds;
                         end;
                     end;

     rpl_end     : begin G_Paused:=1; end;
     end;
end;

procedure _rpls_sel;
begin
   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)
   then _rpls_pre
   else
     if(g_started=false)then rpls_str_data:='';
end;

procedure _rpls_make_lst;
var Info : TSearchRec;
       s : shortstring;
begin
   rpls_list_scroll:=0;
   rpls_list_size:=0;
   setlength(rpls_list,0);
   if(FindFirst(str_f_rpls+'*'+str_e_rpls,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       delete(s,length(s)-(length(str_e_rpls)-1),length(str_e_rpls));
       if(s<>'')then
       begin
          rpls_list_size+=1;
          setlength(rpls_list,rpls_list_size);
          rpls_list[rpls_list_size-1]:=s;
       end;
    until (FindNext(info)<>0);
   FindClose(info);

   _rpls_sel;
end;

procedure _rpls_delete;
var fn:shortstring;
begin
   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      _rpls_make_lst;
   end;
end;


