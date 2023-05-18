

procedure replay_MenuSelectedInfo;
const pl_n_ch : array[false..true] of char = ('#','*');
var   f:file;
vr,t,hp,tm:byte;
     fn:shortstring;
     mw:integer;
     wr:cardinal;
begin
   rpls_str_info:='';

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(length(rpls_list[rpls_list_sel])>0)then
   if(FileExists(fn))then
   begin
      {$I-}
      assign(f,fn);
      reset (f,1);
      {$I+}
      if(ioresult<>0)then
      begin
         rpls_str_info:=str_svld_errors_open;
         exit;
      end;
      if(FileSize(f)<rpls_file_head_size)then
      begin
         close(f);
         rpls_str_info:=str_svld_errors_wdata;
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
         BlockRead(f,wr,sizeof(map_seed    ));rpls_str_info:=str_map+': '+c2s(wr)+tc_nl3+' ';wr:=0;
         BlockRead(f,mw,SizeOf(map_mw      ));rpls_str_info+=str_m_siz+i2s(mw)   +tc_nl3+' ';mw:=0;
         BlockRead(f,vr,sizeof(map_liq     ));
         if(vr<=7)then begin rpls_str_info+=str_m_liq+_str_mx(vr)+tc_nl3+' ';  end
                  else begin rpls_str_info:=str_svld_errors_wver;close(f);exit;end;
         BlockRead(f,vr,sizeof(map_obs     ));
         if(vr<=7)then begin rpls_str_info+=str_m_obs+_str_mx(vr)+tc_nl3+' ';  end
                  else begin rpls_str_info:=str_svld_errors_wver;close(f);exit;end;
         BlockRead(f,vr,sizeof(map_symmetry));rpls_str_info+=str_m_sym+b2cc[vr>0]+tc_nl3+' ';mw:=0;

         BlockRead(f,vr,sizeof(g_mode      ));
         if(vr in allgamemodes)then begin rpls_str_info+=str_gmode[vr]+tc_nl3;              end
                               else begin rpls_str_info:=str_svld_errors_wver;close(f);exit;end;
         BlockRead(f,vr,sizeof(g_start_base     ));vr:=0;
         BlockRead(f,vr,sizeof(g_fixed_positions));vr:=0;
         BlockRead(f,vr,sizeof(g_cgenerators    ));vr:=0;
         BlockRead(f,hp,SizeOf(HPlayer          ));

         for vr:=1 to MaxPlayers do
         begin
            BlockRead(f,fn ,sizeof(fn));

            rpls_str_info+=chr(vr)+pl_n_ch[vr=hp]+tc_default;

            t:=0;
            tm:=0;
            BlockRead(f,t,1);
            if(t=PS_none)then
            begin
               rpls_str_info+=fn+tc_nl3;
               BlockRead(f,mw,3);
            end
            else
            begin
               BlockRead(f,t ,1);
               BlockRead(f,tm,1);
               BlockRead(f,t ,1);

               if(t=0)
               then rpls_str_info+=str_observer[1]
               else
                 if(tm<=r_cnt)
                 then rpls_str_info+=str_race[tm][2]
                 else rpls_str_info+='?';
               rpls_str_info+=','+t2c(t)+','+fn+tc_nl3;
            end;
         end;
      end
      else rpls_str_info:=str_svld_errors_wver;
      if(IOResult<>0)then rpls_str_info:=str_svld_errors_wver;
      {$I+}
      close(f);
   end
   else rpls_str_info:=str_svld_errors_file;
end;

procedure replay_CalcHeaderSize;
begin
   rpls_file_head_size
                 :=SizeOf(ver              )
                  +SizeOf(map_seed         )
                  +SizeOf(map_mw           )
                  +SizeOf(map_liq          )
                  +SizeOf(map_obs          )
                  +SizeOf(map_symmetry     )

                  +SizeOf(g_mode           )
                  +SizeOf(g_start_base     )
                  +SizeOf(g_fixed_positions)
                  +SizeOf(g_cgenerators    )
                  +sizeof(rpls_player      );
   with _players[0] do
   rpls_file_head_size
                 +=(sizeof(name )
                   +sizeof(state)
                   +sizeof(race )
                   +sizeof(mrace)
                   +sizeof(team ))*MaxPlayers;
end;

function replay_GetProgress:single;
begin
   replay_GetProgress:=0;

   if(rpls_fstatus=rpls_file_read)and(rpls_file_size>0)then
     if(rpls_state=rpls_state_rhead)
     or(rpls_state=rpls_state_runit)then
     begin
        replay_GetProgress:=FilePos(rpls_file)/rpls_file_size;
        if(replay_GetProgress>1)then replay_GetProgress:=1;
        if(replay_GetProgress<0)then replay_GetProgress:=0;
     end;
end;

procedure replay_SavePlayPosition;
begin
   if(rpls_fstatus<>rpls_file_read)
   or(rpls_state  <>rpls_state_runit)then exit;

   if(rpls_ReadPosN>0)then
    with rpls_ReadPosL[rpls_ReadPosN-1] do
    begin
       if( g_Step<=rp_gtick)then exit;
       if((g_Step -rp_gtick)<fr_fps2)then exit;
    end;

   rpls_ReadPosN+=1;
   setlength(rpls_ReadPosL,rpls_ReadPosN);
   with rpls_ReadPosL[rpls_ReadPosN-1] do
   begin
      rp_gtick:=g_Step;
      rp_fpos :=FilePos(rpls_file);
   end;
end;
procedure replay_SetPlayPosition(timetick:int64);
var ni,i :cardinal;
    vi,vt:int64;
begin
   if(rpls_ReadPosN=0)
   or(rpls_fstatus<>rpls_file_read)
   or(rpls_state  <>rpls_state_runit)then exit;

   ni:=0;
   vi:=0;
   for i:=0 to rpls_ReadPosN-1 do
    with rpls_ReadPosL[i] do
     if(rp_gtick<=timetick)then
     begin
        vt:=abs(rp_gtick-timetick);
        if(vt<vi)or(ni=0)then
        begin
           ni:=i;
           vi:=vt;
        end;
     end;

   with rpls_ReadPosL[ni] do
   begin
      g_Step:=rp_gtick;
      Seek(rpls_file,rp_fpos);
   end;
   rpls_step:=2;
end;

procedure replay_Abort;
begin
   if(rpls_fstatus>rpls_file_none)then
   begin
      close(rpls_file);
      rpls_fstatus:=rpls_file_none;
   end;
   if(rpls_state>=rpls_state_rhead)then rpls_state:=rpls_state_none;
   rpls_ReadPosN:=0;
   setlength(rpls_ReadPosl,rpls_ReadPosN);
end;

procedure replay_Code;
const vxyc = 5;
var  i,gs,
      _vx,
      _vy  : byte;
begin
   rpls_ticks+=1;
   if(G_Started=false)or(rpls_state=rpls_state_none)or(menu_s2=ms2_camp)
   then replay_Abort
   else
     if(G_Started)then
       case rpls_state of
rpls_state_whead : begin
                      replay_Abort;

                      rpls_str_path:=str_f_rpls+rpls_str_name+str_e_rpls;

                      assign (rpls_file,rpls_str_path);
                      {$I-}
                      rewrite(rpls_file,1);
                      {$I+}

                      if(ioresult<>0)then
                      begin
                         replay_Abort;
                         rpls_state:=rpls_state_none;
                      end
                      else
                      begin
                         rpls_state  :=rpls_state_wunit;
                         rpls_fstatus:=rpls_file_write;
                         rpls_u      :=MaxPlayerUnits+1;
                         rpls_player :=HPlayer;
                         rpls_log_n  :=_players[rpls_player].log_n;
                         rpls_plcam  :=false;
                         rpls_ticks  :=0;

                         {$I-}
                         BlockWrite(rpls_file,ver              ,SizeOf(ver              ));
                         BlockWrite(rpls_file,map_seed         ,SizeOf(map_seed         ));
                         BlockWrite(rpls_file,map_mw           ,SizeOf(map_mw           ));
                         BlockWrite(rpls_file,map_liq          ,SizeOf(map_liq          ));
                         BlockWrite(rpls_file,map_obs          ,SizeOf(map_obs          ));
                         BlockWrite(rpls_file,map_symmetry     ,SizeOf(map_symmetry     ));

                         BlockWrite(rpls_file,g_mode           ,SizeOf(g_mode           ));
                         BlockWrite(rpls_file,g_start_base     ,SizeOf(g_start_base     ));
                         BlockWrite(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
                         BlockWrite(rpls_file,g_cgenerators    ,SizeOf(g_cgenerators    ));
                         BlockWrite(rpls_file,rpls_player      ,sizeof(rpls_player      ));
                         {$I+}

                         for i:=1 to MaxPlayers do
                          with _Players[i] do
                          begin
                             {$I-}
                             BlockWrite(rpls_file,name ,sizeof(name ));
                             BlockWrite(rpls_file,state,sizeof(state));
                             BlockWrite(rpls_file,race ,sizeof(race ));
                             BlockWrite(rpls_file,mrace,sizeof(mrace));
                             BlockWrite(rpls_file,team ,sizeof(team ));
                             {$I+}
                          end;

                         if(ioresult<>0)then
                         begin
                            replay_Abort;
                            rpls_state:=rpls_state_none;
                         end;
                      end;
                   end;
rpls_state_wunit : if(rpls_fstatus<>rpls_file_write)
                   then replay_Abort
                   else
                     if((rpls_ticks mod 2)=0)then
                     begin
                        _vx:=byte(vid_cam_x shr vxyc);
                        _vy:=byte(vid_cam_y shr vxyc);

                        gs:=G_Status and %00111111;
                        i :=gs;
                        if(_players[rpls_player].log_n<>rpls_log_n)then i:=i or %10000000;
                        if(rpls_vidx<>_vx)or(rpls_vidy<>_vy)then
                         if(gs=gs_running)then i:=i or %01000000;

                        if((i and %11000000)>0)or(gs=gs_running)then
                        begin
                           {$I-}
                           BlockWrite(rpls_file,i,sizeof(i));
                           {$I+}
                           if((i and %10000000)>0)then _wudata_log(rpls_player,@rpls_log_n,true);
                           if((i and %01000000)>0)then
                           begin
                              rpls_vidx:=_vx;
                              rpls_vidy:=_vy;
                              {$I-}
                              BlockWrite(rpls_file,rpls_vidx,sizeof(rpls_vidx));
                              BlockWrite(rpls_file,rpls_vidy,sizeof(rpls_vidy));
                              {$I+}
                           end;

                           if(gs=gs_running)then _wclinet_gframe(rpls_player,true);
                        end;

                        if(ioresult<>0)then
                        begin
                           replay_Abort;
                           rpls_state:=rpls_state_none;
                        end;
                     end;
rpls_state_rhead : begin
                      replay_Abort;

                      if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then
                      begin
                         rpls_state   :=rpls_state_none;
                         g_started    :=false;
                         rpls_str_info:='';
                         exit;
                      end;

                      rpls_str_path:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

                      if(not FileExists(rpls_str_path))then
                      begin
                         rpls_state   :=rpls_state_none;
                         g_started    :=false;
                         rpls_str_info:=str_svld_errors_file;
                         exit;
                      end;


                      assign(rpls_file,rpls_str_path);
                      {$I-}
                      reset (rpls_file,1);
                      {$I+}

                      if(ioresult<>0)then
                      begin
                         replay_Abort;
                         g_started :=false;
                         rpls_str_info :=str_svld_errors_open;
                      end
                      else
                      begin
                         rpls_file_size:=FileSize(rpls_file);

                         if(rpls_file_size<rpls_file_head_size)then
                         begin
                            replay_Abort;
                            g_started :=false;
                            rpls_str_info :=str_svld_errors_wdata;
                            exit;
                         end;

                         i:=0;
                         {$I-}
                         BlockRead(rpls_file,i,SizeOf(Ver));
                         {$I+}

                         if(i<>ver)then
                         begin
                            replay_Abort;
                            g_started  :=false;
                            rpls_str_info:=str_svld_errors_wver;
                         end
                         else
                         begin
                            GameDefaultAll;

                            {$I-}
                            BlockRead(rpls_file,map_seed         ,SizeOf(map_seed         ));
                            BlockRead(rpls_file,map_mw           ,SizeOf(map_mw           ));
                            BlockRead(rpls_file,map_liq          ,SizeOf(map_liq          ));
                            BlockRead(rpls_file,map_obs          ,SizeOf(map_obs          ));
                            BlockRead(rpls_file,map_symmetry     ,SizeOf(map_symmetry     ));
                            BlockRead(rpls_file,g_mode           ,SizeOf(g_mode           ));
                            BlockRead(rpls_file,g_start_base     ,SizeOf(g_start_base     ));
                            BlockRead(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
                            BlockRead(rpls_file,g_cgenerators    ,SizeOf(g_cgenerators    ));
                            BlockRead(rpls_file,rpls_player      ,sizeof(rpls_player      ));
                            {$I+}

                            if(map_mw<MinSMapW)or(map_mw>MaxSMapW)
                            or(map_liq>7)or(map_obs>7)
                            or not(g_mode in allgamemodes)
                            or(g_start_base>gms_g_startb)
                            or(rpls_player>MaxPlayers)then
                            begin
                               replay_Abort;
                               g_started:=false;
                               rpls_str_info:=str_svld_errors_wver;
                               GameDefaultAll;
                               exit;
                            end;

                            for i:=1 to MaxPlayers do
                             with _Players[i] do
                             begin
                                {$I-}
                                BlockRead(rpls_file,name ,sizeof(name ));
                                BlockRead(rpls_file,state,sizeof(state));
                                BlockRead(rpls_file,race ,sizeof(race ));
                                BlockRead(rpls_file,mrace,sizeof(mrace));
                                BlockRead(rpls_file,team ,sizeof(team ));
                                {$I+}
                             end;

                            if(rpls_pnu=0)then rpls_pnu:=NetTickN;
                            UnitStepTicks:=trunc(MaxUnits/rpls_pnu)*NetTickN;
                            if(UnitStepTicks=0)then UnitStepTicks:=1;

                            rpls_fstatus:=rpls_file_read;
                            rpls_state  :=rpls_state_runit;
                            rpls_pnu    :=0;
                            rpls_ticks  :=0;
                            HPlayer     :=rpls_player;
                            UIPlayer    :=HPlayer;

                            rpls_plcam  :=false;

                            map_premap;
                            MoveCamToPoint(map_psx[HPlayer],map_psy[HPlayer]);

                            CamBounds;
                            ui_tab    :=3;
                            G_Started :=true;
                            _menu     :=false;
                            ServerSide:=false;
                         end;
                      end;
                   end;
rpls_state_runit : if(rpls_fstatus<>rpls_file_read)
                   then replay_Abort
                   else
                     if((rpls_ticks mod 2)=0)then
                     begin
                         if(ioresult<>0)then
                         begin
                            replay_Abort;
                            //rpls_state :=rpls_state_end;
                            G_Status   :=gs_replayerror;
                            uncappedFPS:=false;
                            exit;
                         end;

                         if(eof(rpls_file))then
                         begin
                            //replay_Abort;
                            //
                            //rpls_state :=rpls_state_end;
                            G_Status   :=gs_replayend;
                            uncappedFPS:=false;
                            rpls_step  :=0;
                            exit;
                         end;

                         //gs_replaypause
                         gs:=G_Status;
                         if(rpls_step<=0)and(G_Status=gs_running)then rpls_step:=1;
                         while(rpls_step>0)do
                         begin
                            replay_SavePlayPosition;

                            {$I-}
                            BlockRead(rpls_file,i,SizeOf(i));
                            {$I+}
                            G_Status:=i and %00111111;

                            if((i and %10000000)>0)then _rudata_log(rpls_player,true);
                            if((i and %01000000)>0)then
                            begin
                               {$I-}
                               BlockRead(rpls_file,rpls_vidx,sizeof(rpls_vidx));
                               BlockRead(rpls_file,rpls_vidy,sizeof(rpls_vidy));
                               {$I+}
                            end;

                            if(G_Status=gs_running)then _rclinet_gframe(rpls_player,true,rpls_step>1);

                            if(rpls_step>1)then effects_sprites(false,false);
                            rpls_step-=1;
                         end;

                         if(rpls_plcam)then
                         begin
                            vid_cam_x:=(vid_cam_x+integer(rpls_vidx shl vxyc)) div 2;
                            vid_cam_y:=(vid_cam_y+integer(rpls_vidy shl vxyc)) div 2;
                            CamBounds;
                         end;

                         if(gs=gs_replaypause)then G_Status:=gs;
                     end;
       end;
end;

procedure replay_Select;
begin
   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)
   then replay_MenuSelectedInfo
   else
     if(g_started=false)then rpls_str_info:='';
end;

procedure replay_MakeFolderList;
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
       if(length(s)>0)then
       begin
          rpls_list_size+=1;
          setlength(rpls_list,rpls_list_size);
          rpls_list[rpls_list_size-1]:=s;
       end;
    until (FindNext(info)<>0);
   FindClose(info);

   replay_Select;
end;

procedure replay_Delete;
var fn:shortstring;
begin
   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      replay_MakeFolderList;
   end;
end;


