
procedure replay_MenuSelectedInfo;
var  f: file;
    fn: shortstring;
vbyte1: byte;
ioer  : word;
begin
   rpls_str_info1:='';
   rpls_str_info2:='';
   rpls_str_info3:='';

   if(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)then exit;
   if(length(rpls_list[rpls_list_sel])=0)then exit;

   fn:=folder_replay+rpls_list[rpls_list_sel]+fileExt_Replay;

   if(not FileExists(fn))then
   begin
      rpls_str_info1:=str_FileError_NExists;
      exit;
   end;

   assign(f,fn);
   {$I-}
   reset (f,1);
   {$I+}
   ioer:=ioresult;
   if(ioer<>0)then
   begin
      rpls_str_info1:=str_FileError_Open+'('+w2s(ioer)+')';
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
     if(not FileReadBaseGameInfo(f,@rpls_str_info1,@rpls_str_info2,@rpls_str_info3))then rpls_str_info1:=str_FileError_WData;
   {$I+}
   ioer:=IOResult;
   if(ioer<>0)then rpls_str_info1:=str_FileError_WData+'('+w2s(ioer)+')';
   close(f);
end;

procedure replay_WriteBlock(count:cardinal;pData:pointer);
begin
   if(rpls_file_LastErr<>0)then exit;
   rpls_file_LastErr:=0;
   IOResult;
   {$I-}
   BlockWrite(rpls_file,pData^,count);
   {$I+}
   rpls_file_LastErr:=IOResult;
   if(rpls_file_LastErr<>0)then exit;

   rpls_file_pos+=count;
end;

function replay_ReadBlock(count:cardinal;pResult:pointer):boolean;
begin
   replay_ReadBlock:=false;
   if(rpls_file_pos>=rpls_file_Size)then exit;
   if((rpls_file_Size-rpls_file_pos)<count)then exit;
   if(rpls_file_LastErr<>0)then exit;

   rpls_file_LastErr:=0;
   IOResult;
   {$I-}
   BlockRead(rpls_file,byte(pResult^),count);
   {$I+}
   rpls_file_LastErr:=IOResult;
   if(rpls_file_LastErr<>0)then exit;

   rpls_file_pos+=count;
   replay_ReadBlock:=true;
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

   AddItem(@g_version           ,SizeOf(g_version     ));
   AddItem(@map_scenario        ,SizeOf(map_scenario  ));
   AddItem(@map_GeneratorT      ,SizeOf(map_GeneratorT));
   AddItem(@map_seed            ,SizeOf(map_seed      ));
   AddItem(@map_Size1           ,SizeOf(map_Size1     ));
   AddItem(@map_Template        ,SizeOf(map_Template  ));
   AddItem(@map_Symmetry        ,sizeof(map_Symmetry  ));
   AddItem(@theme_i             ,SizeOf(theme_i       ));
   AddItem(@rpls_player         ,SizeOf(rpls_player   ));
   AddItem(@g_tick              ,SizeOf(g_tick        ));
   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
     begin
        AddItem(@state     ,SizeOf(state     ));
        AddItem(@name      ,SizeOf(name      ));
        AddItem(@mrace     ,SizeOf(mrace     ));
        AddItem(@team      ,SizeOf(team      ));
        AddItem(@isobserver,SizeOf(isobserver));
     end;

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       AddItem(@race,SizeOf(race));
   AddItem(@g_FixedPositions,SizeOf(g_FixedPositions));
   AddItem(@g_royal_Rx      ,SizeOf(g_royal_Rx      ));
   AddItem(@g_royal_Ry      ,SizeOf(g_royal_Ry      ));
end;

function replay_GetProgress:single;
begin
   replay_GetProgress:=0;

   if(rpls_pstate=rpls_read)and(rpls_fstate=rpls_read)and(rpls_file_size>0)then
   begin
      {$I-}
      if(rpls_file_pos>=rpls_file_size)
      then replay_GetProgress:=1
      else replay_GetProgress:=rpls_file_pos/rpls_file_size;
      {$I+}
      if(replay_GetProgress>1)then replay_GetProgress:=1;
      if(replay_GetProgress<0)then replay_GetProgress:=0;
   end;
end;

procedure replay_SavePlayPosition;
var fpos:int64;
begin
   if(rpls_fstate<>rpls_read)
   or(rpls_pstate<>rpls_read)then exit;

   if(rpls_ReadPosN>0)then
     with rpls_ReadPosL[rpls_ReadPosN-1] do
     begin
        if( g_tick<=rp_gtick)then exit;
        if((g_tick -rp_gtick)<fr_fps2)then exit;
     end;

   IOResult;
   {$I-}
   fpos:=FilePos(rpls_file);
   {$I+}
   if(IOResult<>0)then exit;

   rpls_ReadPosN+=1;
   setlength(rpls_ReadPosL,rpls_ReadPosN);
   with rpls_ReadPosL[rpls_ReadPosN-1] do
   begin
      rp_gtick:=g_tick;
      rp_fpos :=fpos;
   end;
end;
function replay_SetPlayPosition(target_Tick,minGap:int64;check:boolean):boolean;
var ni,i :cardinal;
    vi,vt:int64;
begin
   replay_SetPlayPosition:=false;
   if(rpls_ReadPosN=0)
   or(rpls_fstate<>rpls_read)
   or(rpls_pstate<>rpls_read)then exit;

   if(target_Tick<g_Tick)then
   begin
      with rpls_ReadPosL[0] do
        if(target_Tick<rp_gtick)then target_Tick:=rp_gtick;
      with rpls_ReadPosL[rpls_ReadPosN-1] do
        if(rp_gtick<target_Tick)then target_Tick:=rp_gtick;
   end
   else
     if(g_Tick<target_Tick)then
       if(rpls_file_pos>=rpls_file_size)then exit;

   if(check)then
   begin
      replay_SetPlayPosition:=true;
      exit;
   end;

   ni:=cardinal.MaxValue;
   vi:=0;
   for i:=0 to rpls_ReadPosN-1 do
     with rpls_ReadPosL[i] do
       if(rp_gtick<=target_Tick)then
       begin
          vt:=abs(rp_gtick-target_Tick);
          if(minGap<0)or(vt<=minGap)then
            if(vt<vi)or(ni=cardinal.MaxValue)then
            begin
               ni:=i;
               vi:=vt;
            end;
       end;

   if(ni=cardinal.MaxValue)then
   begin
      if(target_Tick>g_Tick)then
      begin
         vi:=(target_Tick-g_Tick) div 2;
         if(vi>rpls_ForwardSkip.MaxValue)
         then rpls_ForwardSkip:=rpls_ForwardSkip.MaxValue
         else rpls_ForwardSkip:=integer(vi);
      end;
      exit;
   end;

   replay_SetPlayPosition:=true;

   with rpls_ReadPosL[ni] do
   begin
      IOResult;
      {$I-}
      Seek(rpls_file,rp_fpos);
      {$I+}

      if(IOResult<>0)then exit;

      g_tick:=rp_gtick;
      rpls_file_pos:=rp_fpos;
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
      or(rpls_fstate=rpls_write)then GameLogRecStop(rpls_str_path);
   end;
   if(rpls_fstate>rpls_none)then
   begin
      close(rpls_file);
      rpls_fstate   :=rpls_none;
      rpls_file_Pos :=0;
      rpls_file_Size:=0;
   end;
   rpls_str_path:='';
   rpls_pstate  :=rpls_none;
   rpls_ReadPosN:=0;
   setlength(rpls_ReadPosl,rpls_ReadPosN);
end;

// REPLAY WRITE
procedure replay_WriteHead;
var p:byte;
fname:shortstring;
begin
   replay_Abort;

   fname:=rpls_NamePrefix+'_'+str_fileinfo_ScenarioL[map_scenario]+'_'+str_DateTime+fileExt_Replay;
   rpls_str_path:=folder_replay+fname;

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
      rpls_file_Pos :=0;
      rpls_file_Size:=0;
      rpls_file_LastErr:=0;

      rpls_fstate      :=rpls_write;
      rpls_pstate      :=rpls_write;
      rpls_u           :=0;
      rpls_player      :=LocalPlayer;
      rpls_log_c       :=0;
      rpls_Ticks       :=0;
      rpls_GameStatus  :=255;
      rpls_PlayersScore:=false;
      ui_playerPOV     :=false;

      if(rpls_head_itemn>0)then
        for p:=0 to rpls_head_itemn-1 do
          with rpls_head_items[p] do
            replay_WriteBlock(data_s,data_p);

      if(rpls_file_LastErr<>0)then
      begin
         replay_Abort;
         rpls_pstate:=rpls_none;
         GameLogRecError(fname+rpls_file_LastErrS);
      end
      else GameLogRecStart(fname);
   end;
end;

procedure replay_WriteGameFrame;
var
i,gs,
camx,
camy: byte;
begin
   camx:=byte(ui_cam_cx shr rpls_UIcamXYt1b);
   camy:=byte(ui_cam_cy shr rpls_UIcamXYt1b);

   gs:=g_status and %00011111;
   i :=gs;
   if(rpls_log_c>0)then i:=i or %10000000;
   if(rpls_vidx<>camx)
   or(rpls_vidy<>camy)then
     if(gs=gs_running)then i:=i or %01000000;
   if(not rpls_PlayersScore)then
     if(game_IsEnded)then i:=i or %00100000;

   if((i and %11100000)>0)
   or(gs=gs_running)
   or(rpls_GameStatus<>gs)then
   begin
      wudata_byte(i,true);
      if((i and %10000000)>0)then wudata_log(rpls_player,@rpls_log_c,true);
      if((i and %01000000)>0)then
      begin
         rpls_vidx:=camx;
         rpls_vidy:=camy;
         wudata_byte(rpls_vidx,true);
         wudata_byte(rpls_vidy,true);
      end;
      if((i and %00100000)>0)then
      begin
         rpls_PlayersScore:=true;
         //g_PlayersScore
      end;
      rpls_GameStatus:=gs;

      if(gs=gs_running)
      then wclinet_gframe(rpls_player,rpls_WriteTimeServer,true);
   end;

   if(rpls_file_LastErr<>0)then
   begin
      replay_Abort;
      rpls_pstate:=rpls_none;
      GameLogRecError(rpls_str_path+rpls_file_LastErrS);
   end;
end;

// REPLAY READ
procedure replay_ReadHead;
var
p,i  :byte;
ioerr:word;
begin
   replay_Abort;

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then
   begin
      rpls_pstate   :=rpls_none;
      g_started     :=false;
      rpls_str_info1:='';
      rpls_str_info2:='';
      rpls_str_info3:='';
      exit;
   end;

   rpls_str_path:=folder_replay+rpls_list[rpls_list_sel]+fileExt_Replay;
   if(not FileExists(rpls_str_path))then
   begin
      rpls_pstate   :=rpls_none;
      g_started     :=false;
      rpls_str_info1:=str_FileError_NExists;
      rpls_str_info2:='';
      rpls_str_info3:='';
      exit;
   end;

   assign(rpls_file,rpls_str_path);
   {$I-}
   reset (rpls_file,1);
   {$I+}

   ioerr:=ioresult;
   if(ioerr<>0)then
   begin
      replay_Abort;
      g_started     :=false;
      menu_page     :=mi_replays;
      rpls_str_info1:=str_FileError_Open+'('+w2s(ioerr)+')';
      rpls_str_info2:='';
      rpls_str_info3:='';
   end
   else
   begin
      rpls_fstate   :=rpls_read;
      rpls_file_pos :=0;
      rpls_file_size:=FileSize(rpls_file);
      rpls_file_LastErr:=0;

      if(rpls_file_size<rpls_file_head_size)then
      begin
         replay_Abort;
         g_started     :=false;
         menu_page     :=mi_replays;
         rpls_str_info1:=str_FileError_WData;
         rpls_str_info2:='';
         rpls_str_info3:='';
         exit;
      end;

      i:=0;
      replay_ReadBlock(rpls_head_items[0].data_s,@i);

      if(i<>g_version)then
      begin
         replay_Abort;
         g_started     :=false;
         menu_page     :=mi_replays;
         rpls_str_info1:=str_FileError_WVer;
         rpls_str_info2:='';
         rpls_str_info3:='';
      end
      else
      begin
         Game_DefaultAll;

         if(rpls_head_itemn>1)then
          for p:=1 to rpls_head_itemn-1 do
           with rpls_head_items[p] do
            replay_ReadBlock(data_s,data_p);

         if(rpls_file_LastErr<>0)then
         begin
            replay_Abort;
            g_started     :=false;
            menu_page     :=mi_replays;
            rpls_str_info1:=str_FileError_WVer+rpls_file_LastErrS;
            rpls_str_info2:='';
            rpls_str_info3:='';
            Game_DefaultAll;
            exit;
         end;

         if(map_Size1<map_MinSize)or(map_Size1>map_MaxSize)
         or(map_Template  >mapt_Last)
         or(map_GeneratorT>mapg_Last)
         or not(map_scenario in allmapscenarios)
         or(rpls_player>LastPlayer)then
         begin
            replay_Abort;
            g_started     :=false;
            menu_page     :=mi_replays;
            rpls_str_info1:=str_FileError_WVer;
            rpls_str_info2:='';
            rpls_str_info3:='';
            Game_DefaultAll;
            exit;
         end;

         for p:=0 to LastPlayer do
           with g_PlayersGame[p] do
             if not(state in [ps_None,ps_human,ps_AI])
             or(race >r_count)
             or(mrace>r_count)
             or(team >LastPlayer)then
             begin
                replay_Abort;
                g_started     :=false;
                menu_page     :=mi_replays;
                rpls_str_info1:=str_FileError_WVer;
                rpls_str_info2:='';
                rpls_str_info3:='';
                Game_DefaultAll;
                exit;
             end;

         for p:=0 to LastPlayer do
           with g_PlayersGame[p] do
             if(length(name)>MaxPlayerNameLen)then setlength(name,MaxPlayerNameLen);

         if(rpls_pnu=0)then rpls_pnu:=net_SendTimeServer;
         UnitStepTicks:=trunc(MaxUnits/rpls_pnu)*net_SendTimeServer;
         if(UnitStepTicks=0)then UnitStepTicks:=1;

         rpls_pstate:=rpls_read;
         rpls_pnu   :=0;
         rpls_Ticks :=0;
         LocalPlayer:=rpls_player;
         UIPlayer   :=LocalPlayer;

         ui_playerPOV:=false;

         Map_Make;
         menu_mseed:=c2s(map_seed);
         ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer]);

         ui_Camera_Bounds;
         ui_tab    :=tab_controls;
         g_started :=true;
         MenuBack(true,false);
         ServerSide:=false;
      end;
   end;
end;
procedure replay_ReadGameFrame;
var
i,gs: byte;
begin
   if(rpls_file_pos>=rpls_file_size)then
   begin
      if(g_status=gs_running)then
        g_status:=gs_replayend;
      sys_uncappedFPS :=false;
      rpls_ForwardSkip:=0;
      exit;
   end;

   if(rpls_file_LastErr<>0)then
   begin
      rpls_file_LastErrS:='('+w2s(rpls_file_LastErr)+')';
      g_status        :=gs_replayerror;
      sys_uncappedFPS :=false;
      rpls_ForwardSkip:=0;
      exit;
   end;

   gs:=g_status;
   if(rpls_ForwardSkip>1)then rpls_FastSkip:=true;
   if(rpls_ForwardSkip<=0)and(g_status=gs_running)and(not MainMenu)then rpls_ForwardSkip:=1;
   while(rpls_ForwardSkip>0)do
   begin
      replay_SavePlayPosition;

      i:=rudata_byte(true,0);
      g_status:=i and %00011111;

      if((i and %10000000)>0)then rudata_log(rpls_player,true);
      if((i and %01000000)>0)then
      begin
         rpls_vidx:=rudata_byte(true,0);
         rpls_vidy:=rudata_byte(true,0);
      end;
      if((i and %00100000)>0)then ;// read players scores

      if(g_status=gs_running)then rclinet_gframe(rpls_player,rpls_WriteTimeServer,true,rpls_FastSkip);

      if(rpls_FastSkip)then effects_AddSprites(false);
      rpls_ForwardSkip-=1;
      if(rpls_file_pos>=rpls_file_size)then
      begin
         rpls_ForwardSkip:=0;
         break;
      end;
   end;
   if(rpls_ForwardSkip=0)then rpls_FastSkip:=false;

   if(ui_playerPOV)then
   begin
      ui_cam_x:=(ui_cam_x+integer(rpls_vidx shl rpls_UIcamXYt1b)-ui_cam_hw) div 2;
      ui_cam_y:=(ui_cam_y+integer(rpls_vidy shl rpls_UIcamXYt1b)-ui_cam_hh) div 2;
      ui_Camera_Bounds;
   end;

   if(gs=gs_replaypause)then g_status:=gs;
end;

procedure replay_Code;
begin
   if(rpls_Record)then
   begin
      if(rpls_RecordTryPause>0)
      then rpls_RecordTryPause-=1
      else
      begin
         if(g_started)and(not Game_IsEnded)and(rpls_pstate=rpls_none)then rpls_pstate:=rpls_write;
         rpls_RecordTryPause:=fr_fps1;
      end;
   end
   else
     if(rpls_pstate=rpls_write)then replay_Abort;

   if(not g_started)or(rpls_pstate=rpls_none)or(g_type=gt_campaing)
   then replay_Abort
   else
     if(g_started)then
     begin
        rpls_Ticks+=1;
        case rpls_pstate of
        rpls_write : if(rpls_fstate<>rpls_write)
                     then replay_WriteHead
                     else
                       if((rpls_Ticks mod rpls_WriteTimeServer)=0)then
                         replay_WriteGameFrame;
        rpls_read  : if(rpls_fstate=rpls_read)then
                       if((rpls_Ticks mod rpls_WriteTimeServer)=0)then
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
        rpls_str_info3:='';
     end;
end;

procedure replay_MakeFolderList;
var Info : TSearchRec;
       s : shortstring;
begin
   rpls_list_scroll:=0;
   rpls_list_size  :=0;
   setlength(rpls_list,rpls_list_size);
   if(FindFirst(folder_replay+'*'+fileExt_Replay,faReadonly,info)=0)then
     repeat
        s:=info.Name;
        delete(s,length(s)-(length(fileExt_Replay)-1),length(fileExt_Replay));
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
var fn:shortstring;
begin
   replay_Play:=false;

   if(g_started)
   or(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)
   or(menu_msg_type<>mmbt_none)then exit;

   replay_Play:=true;
   if(check)then exit;

   fn:=folder_replay+rpls_list[rpls_list_sel]+fileExt_Replay;
   if(not FileExists(fn))then
   begin
      menu_msgBox_Set(str_FileError_NExists,rpls_list[rpls_list_sel],mmbt_nothing);
      exit;
   end;

   g_type     :=gt_scirmish;
   rpls_pstate:=rpls_read;

   replay_ReadHead;
end;

procedure replay_DeleteFile(fn:shortstring);
begin
   fn:=folder_replay+fn+fileExt_Replay;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      if(rpls_list_size>1)then
        if(rpls_list_sel=(rpls_list_size-1))then rpls_list_sel-=1;
      replay_MakeFolderList;
   end;
end;

function replay_DeleteInit(check:boolean):boolean;
var fn:shortstring;
begin
   replay_DeleteInit:=false;

   if(g_started)
   or(rpls_list_sel<0)
   or(rpls_list_sel>=rpls_list_size)
   or(menu_msg_type<>mmbt_none)then exit;

   replay_DeleteInit:=true;
   if(check)then exit;

   fn:=folder_replay+rpls_list[rpls_list_sel]+fileExt_Replay;
   if(not FileExists(fn))then
   begin
      menu_msgBox_Set(str_FileError_NExists,rpls_list[rpls_list_sel],mmbt_nothing);
      exit;
   end;

   menu_msgBox_Set(str_FileDelete,rpls_list[rpls_list_sel],mmbt_DeleteReplay);
end;

function replay_IsPaused:boolean;
begin
   replay_IsPaused:=(g_status=gs_replaypause)or((gs_paused0<=g_status)and(g_status<=gs_paused7));
end;

function replay_TogglePause(check:boolean):boolean;
begin
   replay_TogglePause:=false;

   if(rpls_file_pos>=rpls_file_size)then exit;

   if(g_status=gs_running)then
   begin
      replay_TogglePause:=true;
      if(check)then exit;

      g_status:=gs_replaypause;
      rpls_ForwardSkip:=0;
   end
   else
     if(replay_IsPaused)then
     begin
        replay_TogglePause:=true;
        if(check)then exit;

        g_status:=gs_running;
        rpls_ForwardSkip:=0;
     end;
end;



