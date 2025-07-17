

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
         BlockRead(f,vr,sizeof(map_obs     ));
         if(vr<=7)then begin rpls_str_info+=str_m_obs+_str_mx(vr)+tc_nl3+' ';  end
                  else begin rpls_str_info:=str_svld_errors_wver;close(f);exit;end;
         BlockRead(f,vr,sizeof(map_symmetry));rpls_str_info+=str_m_sym+b2cc[vr>0]+tc_nl3+' ';mw:=0;

         BlockRead(f,vr,sizeof(g_mode      ));
         if(vr in allgamemodes)then begin rpls_str_info+=str_gmode[vr]+tc_nl3;              end
                               else begin rpls_str_info:=str_svld_errors_wver;close(f);exit;end;
         BlockRead(f,vr,sizeof(g_fixed_positions));vr:=0;
         BlockRead(f,vr,sizeof(g_generators    ));vr:=0;
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
                  +SizeOf(map_obs          )
                  +SizeOf(map_symmetry     )

                  +SizeOf(g_mode           )
                  +SizeOf(g_fixed_positions)
                  +SizeOf(g_generators     )
                  +sizeof(rpls_player      );
   with g_players[0] do
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

   if(rpls_state=rpls_read)and(rpls_fstatus=rpls_read)and(rpls_file_size>0)then
   begin
      replay_GetProgress:=FilePos(rpls_file)/rpls_file_size;
      if(replay_GetProgress>1)then replay_GetProgress:=1;
      if(replay_GetProgress<0)then replay_GetProgress:=0;
   end;
end;

procedure replay_SavePlayPosition;
begin
   if(rpls_fstatus<>rpls_read)
   or(rpls_state  <>rpls_read)then exit;

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
   or(rpls_fstatus<>rpls_read)
   or(rpls_state  <>rpls_read)then exit;

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
   for i:=1 to MaxUnits do
    with g_units[i] do
    begin
       vx:=x;
       vy:=y;
    end;
end;

procedure replay_Abort;
begin
   if(length(rpls_str_path)>0)then
   begin
      if(rpls_state=rpls_write)
      or(rpls_fstatus=rpls_write)then GameLogCommon(0,255,str_RecordingStop+rpls_str_path,true);
   end;
   if(rpls_fstatus>rpls_none)then
   begin
      close(rpls_file);
      rpls_fstatus:=rpls_none;
   end;
   rpls_str_path:='';
   if(rpls_state>=rpls_read)then rpls_state:=rpls_none;
   rpls_ReadPosN:=0;
   setlength(rpls_ReadPosl,rpls_ReadPosN);
end;

procedure replay_Code;
const vxyc = 5;
var  i,gs,
      _vx,
      _vy  : byte;

// WRITE
procedure replay_WriteHead;
var p:byte;
begin
   replay_Abort;

   rpls_str_path:=str_f_rpls+rpls_str_name+'_'+str_DateTime+str_e_rpls;

   assign (rpls_file,rpls_str_path);
   {$I-}
   rewrite(rpls_file,1);
   {$I+}

   if(ioresult<>0)then
   begin
      replay_Abort;
      rpls_state:=rpls_none;
   end
   else
   begin
      rpls_fstatus:=rpls_write;
      rpls_state  :=rpls_write;
      rpls_u      :=MaxPlayerUnits+1;
      rpls_player :=HPlayer;
      rpls_log_c  :=0;
      rpls_plcam  :=false;
      rpls_ticks  :=0;

      {$I-}
      BlockWrite(rpls_file,ver              ,SizeOf(ver              ));
      BlockWrite(rpls_file,map_seed         ,SizeOf(map_seed         ));
      BlockWrite(rpls_file,map_mw           ,SizeOf(map_mw           ));
      BlockWrite(rpls_file,map_obs          ,SizeOf(map_obs          ));
      BlockWrite(rpls_file,map_symmetry     ,SizeOf(map_symmetry     ));

      BlockWrite(rpls_file,g_mode           ,SizeOf(g_mode           ));
      BlockWrite(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
      BlockWrite(rpls_file,g_generators     ,SizeOf(g_generators     ));
      BlockWrite(rpls_file,rpls_player      ,sizeof(rpls_player      ));
      {$I+}

      for p:=1 to MaxPlayers do
       with g_players[p] do
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
         rpls_state:=rpls_none;
      end;

      GameLogCommon(0,255,str_RecordingStart+rpls_str_path,true);
   end;
end;
procedure replay_WriteGameFrame;
begin
   if((rpls_ticks mod 2)<>0)then exit;

   _vx:=byte((vid_cam_x+vid_cam_hw) shr vxyc);
   _vy:=byte((vid_cam_y+vid_cam_hh) shr vxyc);

   gs:=G_Status and %00111111;
   i :=gs;
   if(rpls_log_c>0)then i:=i or %10000000;
   if(rpls_vidx<>_vx)or(rpls_vidy<>_vy)then
    if(gs=gs_running)then i:=i or %01000000;

   if((i and %11000000)>0)or(gs=gs_running)then
   begin
      {$I-}
      BlockWrite(rpls_file,i,sizeof(i));
      {$I+}
      if((i and %10000000)>0)then _wudata_log(rpls_player,@rpls_log_c,true);
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
      rpls_state:=rpls_none;
   end;
end;


// READ
procedure replay_Readhead;
var p:byte;
begin
   replay_Abort;

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then
   begin
      rpls_state   :=rpls_none;
      g_started    :=false;
      rpls_str_info:='';
      exit;
   end;

   rpls_str_path:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(not FileExists(rpls_str_path))then
   begin
      rpls_state   :=rpls_none;
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
      g_started    :=false;
      rpls_str_info:=str_svld_errors_open;
   end
   else
   begin
      rpls_file_size:=FileSize(rpls_file);

      if(rpls_file_size<rpls_file_head_size)then
      begin
         replay_Abort;
         g_started    :=false;
         rpls_str_info:=str_svld_errors_wdata;
         exit;
      end;

      i:=0;
      {$I-}
      BlockRead(rpls_file,i,SizeOf(Ver));
      {$I+}

      if(i<>ver)then
      begin
         replay_Abort;
         g_started    :=false;
         rpls_str_info:=str_svld_errors_wver;
      end
      else
      begin
         GameDefaultAll;

         {$I-}
         BlockRead(rpls_file,map_seed         ,SizeOf(map_seed         ));
         BlockRead(rpls_file,map_mw           ,SizeOf(map_mw           ));
         BlockRead(rpls_file,map_obs          ,SizeOf(map_obs          ));
         BlockRead(rpls_file,map_symmetry     ,SizeOf(map_symmetry     ));
         BlockRead(rpls_file,g_mode           ,SizeOf(g_mode           ));
         BlockRead(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
         BlockRead(rpls_file,g_generators     ,SizeOf(g_generators     ));
         BlockRead(rpls_file,rpls_player      ,sizeof(rpls_player      ));
         {$I+}

         if(map_mw<MinSMapW)or(map_mw>MaxSMapW)
         or(map_obs>7)
         or not(g_mode in allgamemodes)
         or(rpls_player>MaxPlayers)then
         begin
            replay_Abort;
            g_started:=false;
            rpls_str_info:=str_svld_errors_wver;
            GameDefaultAll;
            exit;
         end;

         for p:=1 to MaxPlayers do
          with g_players[p] do
          begin
             {$I-}
             BlockRead(rpls_file,name ,sizeof(name ));
             BlockRead(rpls_file,state,sizeof(state));
             BlockRead(rpls_file,race ,sizeof(race ));
             BlockRead(rpls_file,mrace,sizeof(mrace));
             BlockRead(rpls_file,team ,sizeof(team ));
             {$I+}
          end;

         if(ioresult<>0)then
         begin
            replay_Abort;
            rpls_str_info:=str_svld_errors_wver;
            GameDefaultAll;
            exit;
         end;

         if(rpls_pnu=0)then rpls_pnu:=NetTickN;
         UnitStepTicks:=trunc(MaxUnits/rpls_pnu)*NetTickN;
         if(UnitStepTicks=0)then UnitStepTicks:=1;

         rpls_fstatus:=rpls_read;
         rpls_state  :=rpls_read;
         rpls_pnu    :=0;
         rpls_ticks  :=0;
         HPlayer     :=rpls_player;
         UIPlayer    :=HPlayer;

         rpls_plcam  :=false;

         map_premap;
         MoveCamToPoint(map_psx[HPlayer],map_psy[HPlayer]);

         CameraBounds;
         ui_tab    :=3;
         G_Started :=true;
         MainMenu     :=false;
         ServerSide:=false;
      end;
   end;
end;
procedure replay_ReadGameFrame;
begin
   if((rpls_ticks mod 2)<>0)then exit;

   if(ioresult<>0)then
   begin
      replay_Abort;
      G_Status   :=gs_replayerror;
      uncappedFPS:=false;
      exit;
   end;

   if(eof(rpls_file))then
   begin
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
      {if(G_Status>26)then
      begin
         writeln('unknown game status ',G_Status);
         readln;
      end; }

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
      vid_cam_x:=(vid_cam_x+integer(rpls_vidx shl vxyc)-vid_cam_hw) div 2;
      vid_cam_y:=(vid_cam_y+integer(rpls_vidy shl vxyc)-vid_cam_hh) div 2;
      CameraBounds;
   end;

   if(gs=gs_replaypause)then G_Status:=gs;
end;


begin
   rpls_ticks+=1;
   if(not G_Started)or(rpls_state=rpls_none)or(menu_s2=ms2_camp)
   then replay_Abort
   else
     if(G_Started)then
       case rpls_state of
rpls_write : if(rpls_fstatus<>rpls_write)
             then replay_WriteHead
             else replay_WriteGameFrame;
rpls_read  : if(rpls_fstatus<>rpls_read)
             then replay_Readhead
             else replay_ReadGameFrame;
       else replay_Abort;
       end;
end;

procedure replay_Select;
begin
   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)
   then replay_MenuSelectedInfo
   else
     if(not g_started)then rpls_str_info:='';
end;

procedure replay_MakeFolderList(resetSelect:boolean=true);
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

   if(resetSelect)then
   begin
      rpls_list_sel:=-1;
      rpls_str_info:='';
   end;
   if(not G_Started)then
     replay_Select;
end;

function replay_Play(check:boolean):boolean;
begin
   replay_Play:=false;

   if(not menu_ReplaysTab)
   or(g_started)
   or(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)then exit;

   replay_Play:=true;
   if(check)then exit;

   menu_s2:=ms2_scir;
   rpls_state:=rpls_read;
   g_started:=true;
end;

function replay_Delete(check:boolean):boolean;
var fn:shortstring;
begin
   replay_Delete:=false;

   if(not menu_ReplaysTab)
   or(g_started)
   or(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)then exit;

   replay_Delete:=true;
   if(check)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      replay_MakeFolderList(false);
   end;
end;


