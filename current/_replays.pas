
const camXYt1b = 5;

procedure replay_MenuSelectedInfo;
var  f: file;
    fn: shortstring;
vbyte1: byte;
begin
   rpls_str_info1:='';
   rpls_str_info2:='';

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   if(length(rpls_list[rpls_list_sel])=0)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;
   if(not FileExists(fn))then
   begin
      rpls_str_info1:=str_FileError_NExists;
      exit;
   end;

   assign(f,fn);
   {$I-}
   reset (f,1);
   {$I+}
   if(ioresult<>0)then
   begin
      rpls_str_info1:=str_FileError_Open;
      exit;
   end;
   if(FileSize(f)<rpls_file_head_size)then
   begin
      close(f);
      rpls_str_info1:=str_FileError_WData;
      exit;
   end;

   vbyte1:=0;
   {$I-}
   BlockRead(f,vbyte1,SizeOf(g_version));
   if(vbyte1<>g_version)
   then rpls_str_info1:=str_FileError_WVer
   else
     if(not FileReadBaseGameInfo(f,@rpls_str_info1,@rpls_str_info2))then rpls_str_info1:=str_FileError_WData;

   {$I+}
   if(IOResult<>0)then rpls_str_info1:=str_FileError_WData;
   close(f);
end;

procedure replay_MakeReplayHeaderData;
var p:byte;
procedure AddItem(pdata:pointer;sdata:cardinal);
begin
   rpls_head_itemn+=1;
   setlength(rpls_head_items,rpls_head_itemn);
   with rpls_head_items[rpls_head_itemn-1] do
   begin
      data_p:=pdata;
      data_s:=sdata;
   end;
   rpls_file_head_size+=sdata;
end;
begin
   rpls_head_itemn:=0;
   setlength(rpls_head_items,0);
   rpls_file_head_size:=0;

   AddItem(@g_version           ,SizeOf(g_version        ));
   AddItem(@map_scenario        ,SizeOf(map_scenario     ));
   AddItem(@map_generators      ,SizeOf(map_generators   ));
   AddItem(@map_seed            ,SizeOf(map_seed         ));
   AddItem(@map_Size            ,SizeOf(map_Size         ));
   AddItem(@map_ObstaclesF       ,SizeOf(map_ObstaclesF    ));
   AddItem(@map_Symmetry        ,sizeof(map_Symmetry     ));
   AddItem(@theme_i             ,SizeOf(theme_i          ));
   AddItem(@rpls_player         ,SizeOf(rpls_player      ));
   AddItem(@g_tick              ,SizeOf(g_tick           ));
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
     begin
        AddItem(@state   ,SizeOf(state   ));
        AddItem(@name    ,SizeOf(name    ));
        AddItem(@mrace   ,SizeOf(mrace   ));
        AddItem(@team    ,SizeOf(team    ));
        AddItem(@observer,SizeOf(observer));
     end;

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       AddItem(@race,SizeOf(race));
   AddItem(@g_FixedPositions,SizeOf(g_FixedPositions));
end;

function replay_GetProgress:single;
begin
   replay_GetProgress:=0;

   if(rpls_pstate=rpls_read)and(rpls_fstate=rpls_read)and(rpls_file_size>0)then
   begin
      replay_GetProgress:=FilePos(rpls_file)/rpls_file_size;
      if(replay_GetProgress>1)then replay_GetProgress:=1;
      if(replay_GetProgress<0)then replay_GetProgress:=0;
   end;
end;

procedure replay_SavePlayPosition;
begin
   if(rpls_fstate<>rpls_read)
   or(rpls_pstate<>rpls_read)then exit;

   if(rpls_ReadPosN>0)then
     with rpls_ReadPosL[rpls_ReadPosN-1] do
     begin
        if( g_tick<=rp_gtick)then exit;
        if((g_tick -rp_gtick)<fr_fps2)then exit;
     end;

   rpls_ReadPosN+=1;
   setlength(rpls_ReadPosL,rpls_ReadPosN);
   with rpls_ReadPosL[rpls_ReadPosN-1] do
   begin
      rp_gtick:=g_tick;
      rp_fpos :=FilePos(rpls_file);
   end;
end;
function replay_SetPlayPosition(timetick,mindist:int64):boolean;
var ni,i :cardinal;
    vi,vt:int64;
begin
   replay_SetPlayPosition:=false;
   if(rpls_ReadPosN=0)
   or(rpls_fstate<>rpls_read)
   or(rpls_pstate<>rpls_read)then exit;

   if(timetick<g_Tick)then
   begin
      with rpls_ReadPosL[0] do
        if(timetick<rp_gtick)then timetick:=rp_gtick;
      with rpls_ReadPosL[rpls_ReadPosN-1] do
        if(rp_gtick<timetick)then timetick:=rp_gtick;
   end;

   ni:=cardinal.MaxValue;
   vi:=0;
   for i:=0 to rpls_ReadPosN-1 do
     with rpls_ReadPosL[i] do
       if(rp_gtick<=timetick)then
       begin
          vt:=abs(rp_gtick-timetick);
          if(mindist<0)or(vt<=mindist)then
            if(vt<vi)or(ni=cardinal.MaxValue)then
            begin
               ni:=i;
               vi:=vt;
            end;
       end;

   if(ni=cardinal.MaxValue)then exit;

   replay_SetPlayPosition:=true;

   with rpls_ReadPosL[ni] do
   begin
      g_tick:=rp_gtick;
      Seek(rpls_file,rp_fpos);
   end;
   rpls_ForwardSkip:=2;
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
      if(rpls_pstate=rpls_write)
      or(rpls_fstate=rpls_write)then GameLogCommon(0,255,str_gmsg_RecordStop+rpls_str_path);
   end;
   if(rpls_fstate>rpls_none)then
   begin
      close(rpls_file);
      rpls_fstate:=rpls_none;
   end;
   rpls_str_path:='';
   rpls_pstate  :=rpls_none;
   rpls_ReadPosN:=0;
   setlength(rpls_ReadPosl,rpls_ReadPosN);
end;

// REPLAY WRITE
procedure replay_WriteHead;
var p:byte;
begin
   replay_Abort;

   rpls_str_path:=str_f_rpls+rpls_NamePrefix+'_'+str_replay_ScenarioL[map_scenario]+'_'+str_DateTime+str_e_rpls;

   assign (rpls_file,rpls_str_path);
   {$I-}
   rewrite(rpls_file,1);
   {$I+}

   if(ioresult<>0)then
   begin
      replay_Abort;
      rpls_pstate:=rpls_none;
   end
   else
   begin
      rpls_fstate :=rpls_write;
      rpls_pstate :=rpls_write;
      rpls_u      :=0;
      rpls_player :=LocalPlayer;
      rpls_log_c  :=0;
      rpls_POVRecorder:=false;
      rpls_ticks  :=0;

      {$I-}
      if(rpls_head_itemn>0)then
        for p:=0 to rpls_head_itemn-1 do
          with rpls_head_items[p] do
            BlockWrite(rpls_file,data_p^,data_s);
      {$I+}

      if(ioresult<>0)then
      begin
         replay_Abort;
         rpls_pstate:=rpls_none;
      end;

      GameLogCommon(0,255,str_gmsg_RecordStart+rpls_str_path);
   end;
end;

procedure replay_WriteGameFrame;
var
i,gs,
camx,
camy: byte;
begin
   camx:=byte(ui_cam_cx shr camXYt1b);
   camy:=byte(ui_cam_cy shr camXYt1b);

   gs:=G_Status and %00111111;
   i :=gs;
   if(rpls_log_c>0)then i:=i or %10000000;
   if(rpls_vidx<>camx)
   or(rpls_vidy<>camy)then
     if(gs=gs_running)then i:=i or %01000000;

   if((i and %11000000)>0)or(gs=gs_running)then
   begin
      {$I-}
      BlockWrite(rpls_file,i,sizeof(i));
      {$I+}
      if((i and %10000000)>0)then wudata_log(rpls_player,@rpls_log_c,true);
      if((i and %01000000)>0)then
      begin
         rpls_vidx:=camx;
         rpls_vidy:=camy;
         {$I-}
         BlockWrite(rpls_file,rpls_vidx,sizeof(rpls_vidx));
         BlockWrite(rpls_file,rpls_vidy,sizeof(rpls_vidy));
         {$I+}
      end;

      if(gs=gs_running)then wclinet_gframe(rpls_player,true);
   end;

   if(ioresult<>0)then
   begin
      replay_Abort;
      rpls_pstate:=rpls_none;
   end;
end;

// REPLAY READ
procedure replay_ReadHead;
var p,i:byte;
begin
   replay_Abort;

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then
   begin
      rpls_pstate   :=rpls_none;
      g_started     :=false;
      rpls_str_info1:='';
      rpls_str_info2:='';
      exit;
   end;

   rpls_str_path:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(not FileExists(rpls_str_path))then
   begin
      rpls_pstate   :=rpls_none;
      g_started     :=false;
      rpls_str_info1:=str_FileError_NExists;
      rpls_str_info2:='';
      exit;
   end;

   assign(rpls_file,rpls_str_path);
   {$I-}
   reset (rpls_file,1);
   {$I+}

   if(ioresult<>0)then
   begin
      replay_Abort;
      g_started     :=false;
      rpls_str_info1:=str_FileError_Open;
      rpls_str_info2:='';
   end
   else
   begin
      rpls_file_size:=FileSize(rpls_file);

      if(rpls_file_size<rpls_file_head_size)then
      begin
         replay_Abort;
         g_started     :=false;
         rpls_str_info1:=str_FileError_WData;
         rpls_str_info2:='';
         exit;
      end;

      i:=0;
      {$I-}
      BlockRead(rpls_file,i,SizeOf(g_version));
      {$I+}

      if(i<>g_version)then
      begin
         replay_Abort;
         g_started     :=false;
         rpls_str_info1:=str_FileError_WVer;
         rpls_str_info2:='';
      end
      else
      begin
         GameDefaultAll;

         {$I-}
         if(rpls_head_itemn>1)then
          for p:=1 to rpls_head_itemn-1 do
           with rpls_head_items[p] do
            BlockRead(rpls_file,byte(data_p^),data_s);
         {$I+}

         if(ioresult<>0)then
         begin
            replay_Abort;
            rpls_str_info1:=str_FileError_WVer;
            rpls_str_info2:='';
            GameDefaultAll;
            exit;
         end;

         if(map_Size<map_MinSize)or(map_Size>map_MaxSize)
         or(map_ObstaclesF>map_MaxObstacles)
         or(map_Generators>map_MaxGenerators)
         or not(map_scenario in allmapscenarios)
         or(rpls_player>LastPlayer)then
         begin
            replay_Abort;
            g_started:=false;
            rpls_str_info1:=str_FileError_WVer;
            rpls_str_info2:='';
            GameDefaultAll;
            exit;
         end;

         for p:=0 to LastPlayer do
           with g_gplayers[p] do
             if(length(name)>MaxPlayerNameLen)
             or not(state in [ps_None,ps_human,ps_AI])
             or(race >r_cnt)
             or(mrace>r_cnt)
             or(team >LastPlayer)then
             begin
                replay_Abort;
                rpls_str_info1:=str_FileError_WVer;
                rpls_str_info2:='';
                GameDefaultAll;
                exit;
             end;

         if(rpls_pnu=0)then rpls_pnu:=NetTickN;
         UnitStepTicks:=trunc(MaxUnits/rpls_pnu)*NetTickN;
         if(UnitStepTicks=0)then UnitStepTicks:=1;

         rpls_fstate:=rpls_read;
         rpls_pstate:=rpls_read;
         rpls_pnu   :=0;
         rpls_ticks :=0;
         LocalPlayer:=rpls_player;
         UIPlayer   :=LocalPlayer;

         rpls_POVRecorder:=false;

         Map_Make;
         ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer]);

         ui_Camera_Bounds;
         ui_tab    :=tab_controls;
         G_Started :=true;
         MainMenu  :=false;
         ServerSide:=false;
      end;
   end;
end;
procedure replay_ReadGameFrame;
var
i,gs: byte;
begin
   if(eof(rpls_file))then
   begin
      G_Status        :=gs_replayend;
      sys_uncappedFPS :=false;
      rpls_ForwardSkip:=0;
      ioresult; // clear error
      exit;
   end;

   if(ioresult<>0)then
   begin
      replay_Abort;
      G_Status   :=gs_replayerror;
      sys_uncappedFPS:=false;
      exit;
   end;

   //gs_replaypause
   gs:=G_Status;
   if(rpls_ForwardSkip>1)then rpls_FastSkip:=true;
   if(rpls_ForwardSkip<=0)and(G_Status=gs_running)and(not MainMenu)then rpls_ForwardSkip:=1;
   while(rpls_ForwardSkip>0)do
   begin
      replay_SavePlayPosition;

      i:=0;
      {$I-}
      BlockRead(rpls_file,i,SizeOf(i));
      {$I+}
      G_Status:=i and %00111111;

      if((i and %10000000)>0)then rudata_log(rpls_player,true);
      if((i and %01000000)>0)then
      begin
         {$I-}
         BlockRead(rpls_file,rpls_vidx,sizeof(rpls_vidx));
         BlockRead(rpls_file,rpls_vidy,sizeof(rpls_vidy));
         {$I+}
      end;

      if(G_Status=gs_running)then rclinet_gframe(rpls_player,true,rpls_FastSkip);

      if(rpls_FastSkip)then effects_sprites(false);
      rpls_ForwardSkip-=1;
   end;
   if(rpls_ForwardSkip=0)then rpls_FastSkip:=false;

   if(rpls_POVRecorder)then
   begin
      ui_cam_x:=(ui_cam_x+integer(rpls_vidx shl camXYt1b)-ui_cam_hw) div 2;
      ui_cam_y:=(ui_cam_y+integer(rpls_vidy shl camXYt1b)-ui_cam_hh) div 2;
      ui_Camera_Bounds;
   end;

   if(gs=gs_replaypause)then G_Status:=gs;
end;

procedure replay_Code;
begin
   if(rpls_RecordTryPause>0)
   then rpls_RecordTryPause-=1
   else
     if(rpls_Record)then
     begin
        if(g_Started)and(rpls_pstate=rpls_none)then rpls_pstate:=rpls_write;
        rpls_RecordTryPause:=fr_fps2;
     end
     else
       if(rpls_pstate=rpls_write)then replay_Abort;

   if(not G_Started)or(rpls_pstate=rpls_none)or(g_type=gt_campaing)
   then replay_Abort
   else
     if(G_Started)then
     begin
        rpls_ticks+=1;
        case rpls_pstate of
rpls_write : if(rpls_fstate<>rpls_write)
             then replay_WriteHead
             else
               if((rpls_ticks mod 2)<>0)then
                 replay_WriteGameFrame;
rpls_read  : if(rpls_fstate<>rpls_read)
             then replay_Readhead
             else
               if((rpls_ticks mod 2)<>0)then
                 replay_ReadGameFrame;
        else replay_Abort;
        end;
     end;
end;

procedure replay_Select;
begin
   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)
   then replay_MenuSelectedInfo
   else
     if(not g_started)then
     begin
        rpls_str_info1:='';
        rpls_str_info2:='';
     end;
end;

procedure replay_MakeFolderList;
var Info : TSearchRec;
       s : shortstring;
begin
   rpls_list_scroll:=0;
   rpls_list_size  :=0;
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

function replay_Play(check:boolean):boolean;
begin
   replay_Play:=false;

   if(g_started)
   or(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)then exit;

   replay_Play:=true;
   if(check)then exit;

   MenuBack(true,false);

   g_type     :=gt_scirmish;
   rpls_pstate:=rpls_read;
   g_started  :=true;
end;

function replay_Delete(check:boolean):boolean;
var fn:shortstring;
begin
   replay_Delete:=false;

   if(g_started)
   or(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)then exit;

   replay_Delete:=true;
   if(check)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      replay_MakeFolderList;
   end;
end;

function replay_IsPaused:boolean;
begin
   replay_IsPaused:=(G_Status=gs_replaypause)or(G_Status<MaxPlayers);
end;

function replay_Pause(check:boolean):boolean;
begin
   replay_Pause:=false;

   if(G_Status=gs_running)then
   begin
      replay_Pause:=true;
      if(check)then exit;

      G_Status:=gs_replaypause;
      rpls_ForwardSkip:=0;
   end
   else
     if(G_Status=gs_replaypause)or(G_Status<MaxPlayers)then
     begin
        replay_Pause:=true;
        if(check)then exit;

        G_Status:=gs_running;
        rpls_ForwardSkip:=0;
     end;
end;


