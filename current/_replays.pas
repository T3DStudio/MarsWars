

procedure replay_MenuSelectedInfo;
const pl_n_ch : array[false..true] of char = ('#','*');
var    f : file;
   dstr  : shortstring;
   i,
   dbyte1,
   dbyte2: byte;
   dint  : integer;
   dcard : cardinal;
begin
   rpls_str_info1:='';
   rpls_str_info2:='';
   rpls_str_info3:='';
   rpls_str_infoS:='';

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   dstr:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(length(rpls_list[rpls_list_sel])>0)then
   if(FileExists(dstr))then
   begin
      {$I-}
      assign(f,dstr);
      reset (f,1);
      {$I+}
      if(ioresult<>0)then
      begin
         rpls_str_info1:=str_error_OpenFile;
         exit;
      end;
      if(FileSize(f)<rpls_file_head_size)then
      begin
         close(f);
         rpls_str_info1:=str_error_WrongData;
         exit;
      end;
      dbyte1:=0;
      dint :=0;
      dcard:=0;
      BlockRead(f,dbyte1,SizeOf(g_version));
      if(dbyte1=g_version)then
      begin
         rpls_str_infoS:=rpls_list[rpls_list_sel]+tc_nl2;

         if(not FileReadBaseGameInfo(f,@rpls_str_info1,@rpls_str_info2))then exit;

         BlockRead(f,dbyte1,SizeOf(PlayerClient));

         rpls_str_info3+=tc_nl2+str_menu_players+tc_nl2;

         for i:=0 to LastPlayer do
         begin
            BlockRead(f,dstr,sizeof(dstr));   // name

            rpls_str_info3+=chr(i)+pl_n_ch[i=dbyte1]+tc_default;
            if(i=dbyte1)then rpls_str_infoS+=pl_n_ch[i=dbyte1]+dstr;

            if(i<LastPlayer)then rpls_str_info3+=tc_nl2;
         end;
      end
      else rpls_str_info1:=str_error_WrongVersion;
      close(f);
   end
   else rpls_str_info1:=str_error_FileExists;
end;

procedure replay_MakeReplayHeaderData;
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

   AddItem(@g_version        ,SizeOf(g_version        ));
   AddItem(@G_Step           ,SizeOf(G_Step           ));
   AddItem(@map_seed         ,SizeOf(map_seed         ));
   AddItem(@map_psize         ,SizeOf(map_psize         ));
   AddItem(@map_type         ,SizeOf(map_type         ));
   AddItem(@map_symmetry     ,SizeOf(map_type         ));
   AddItem(@theme_cur        ,SizeOf(theme_cur        ));
   AddItem(@g_mode           ,SizeOf(g_mode           ));
   AddItem(@g_generators     ,SizeOf(g_generators     ));
   AddItem(@g_fixed_positions,SizeOf(g_fixed_positions));
   AddItem(@g_deadobservers  ,SizeOf(g_deadobservers  ));
   AddItem(@g_ai_slots       ,SizeOf(g_ai_slots       ));
   AddItem(@rpls_POVPlayer   ,SizeOf(rpls_POVPlayer   ));

   with g_players[0] do
   rpls_file_head_size
                 +=cardinal((sizeof(name       )
                            +sizeof(player_type)
                            +sizeof(race       )
                            +sizeof(slot_race  )
                            +sizeof(team       )
                            +g_slot_state[0]    )*MaxPlayer);
end;

function replay_GetProgress:single;
begin
   replay_GetProgress:=0;

   if (rpls_rstate=rpls_state_read)
   and(rpls_fstate=rpls_state_read)
   and(rpls_file_size>0)then
   begin
      replay_GetProgress:=FilePos(rpls_file)/rpls_file_size;
      if(replay_GetProgress>1)then replay_GetProgress:=1;
      if(replay_GetProgress<0)then replay_GetProgress:=0;
   end;
end;

procedure replay_SavePlayPosition;
begin
   if(rpls_fstate<>rpls_state_read)
   or(rpls_rstate<>rpls_state_read)then exit;

   if(rpls_ReadPosN>0)then
     with rpls_ReadPosL[rpls_ReadPosN-1] do
     begin
        if( g_Step<=rp_gstep)then exit;
        if((g_Step -rp_gstep)<fr_fps2)then exit;
     end;

   rpls_ReadPosN+=1;
   setlength(rpls_ReadPosL,rpls_ReadPosN);
   with rpls_ReadPosL[rpls_ReadPosN-1] do
   begin
      rp_gstep:=g_Step;
      rp_fpos :=FilePos(rpls_file);
   end;
end;
function replay_SetPlayPosition(timetick,mindist:int64):boolean;
var ni,i :cardinal;
    vi,vt:int64;
begin
   replay_SetPlayPosition:=false;
   if(rpls_ReadPosN=0)
   or(rpls_fstate<>rpls_state_read)
   or(rpls_rstate<>rpls_state_read)then exit;

   ni:=cardinal.MaxValue;
   vi:=0;
   for i:=0 to rpls_ReadPosN-1 do
    with rpls_ReadPosL[i] do
     if(rp_gstep<=timetick)then
     begin
        vt:=abs(rp_gstep-timetick);
        if(mindist<0)or(vt<=mindist)then
          if(vt<vi)or(ni=0)then
          begin
             ni:=i;
             vi:=vt;
          end;
     end;

   if(ni=cardinal.MaxValue)then exit;

   replay_SetPlayPosition:=true;

   with rpls_ReadPosL[ni] do
   begin
      g_Step:=rp_gstep;
      Seek(rpls_file,rp_fpos);
   end;
   rpls_ForwardStep:=2;
   for i:=1 to MaxUnits do
     with g_units[i] do
     begin
        vx:=x;
        vy:=y;
     end;
end;

procedure replay_Abort;
begin
   if(rpls_fstate>rpls_state_none)then
   begin
      close(rpls_file);
      rpls_fstate:=rpls_state_none;
   end;
   rpls_rstate:=rpls_state_none;
   rpls_ReadPosN:=0;
   setlength(rpls_ReadPosl,rpls_ReadPosN);
end;


procedure replay_MakeNewReplayPath;
const
replay_template_n = '%N%';
var    p: byte;
       i: integer;
tmp_strt: shortstring;
begin
   // rpls_str_path:=str_f_rpls+rpls_str_prefix+str_e_rpls;
   tmp_strt:='';

{
i:=0;
repeat
   i+=1;
   s:=str_screenshot+i2s(i)+'.bmp';
until not FileExists(s);
}
end;

procedure replay_WriteHead;
var p:byte;
begin
   replay_Abort;

   rpls_str_path:=str_f_rpls+rpls_str_prefix+str_e_rpls;

   assign (rpls_file,rpls_str_path);
   {$I-}
   rewrite(rpls_file,1);
   {$I+}

   if(ioresult<>0)then
   begin
      replay_Abort;
      rpls_rstate:=rpls_state_none;
      GameLogChat(PlayerClient,log_to_all,str_msg_ReplayFail+str_error_OpenFile,true);
   end
   else
   begin
      rpls_fstate   :=rpls_state_write;
      rpls_rstate   :=rpls_state_write;
      rpls_u        :=MaxPlayerUnits+1;
      rpls_POVPlayer:=PlayerClient;
      rpls_log_n    :=g_players[rpls_POVPlayer].log_n;
      rpls_POVCam   :=false;
      rpls_ticks    :=0;

      {$I-}
      if(rpls_head_itemn>0)then
       for p:=0 to rpls_head_itemn-1 do
        with rpls_head_items[p] do
         BlockWrite(rpls_file,data_p^,data_s);
      {$I+}

      for p:=0 to LastPlayer do
        with g_players[p] do
        begin
           {$I-}
           BlockWrite(rpls_file,name           ,sizeof(name           ));
           BlockWrite(rpls_file,player_type    ,sizeof(player_type    ));
           BlockWrite(rpls_file,race           ,sizeof(race           ));
           BlockWrite(rpls_file,slot_race      ,sizeof(slot_race      ));
           BlockWrite(rpls_file,team           ,sizeof(team           ));
           BlockWrite(rpls_file,g_slot_state[p],sizeof(g_slot_state[p]));
           {$I+}
        end;

      if(ioresult<>0)then
      begin
         replay_Abort;
         rpls_rstate:=rpls_state_none;
         GameLogChat(PlayerClient,log_to_all,str_msg_ReplayFail+str_error_FileWrite,true);
      end;
   end;
end;

procedure replay_Code;
const vxyc = 5;
var  i,gs,
      _vx,
      _vy  : byte;
// WRITE

procedure replay_WriteGameFrame;
begin
   if((rpls_ticks mod 2)<>0)then exit;

   _vx:=byte(vid_cam_x shr vxyc);
   _vy:=byte(vid_cam_y shr vxyc);

   gs:=G_Status and %00111111;
   i :=gs;
   if(g_players[rpls_POVPlayer].log_n<>rpls_log_n)then i:=i or %10000000;
   if(rpls_vidx<>_vx)or(rpls_vidy<>_vy)then
    if(gs=gs_running)then i:=i or %01000000;

   if((i and %11000000)>0)or(gs=gs_running)then
   begin
      {$I-}
      BlockWrite(rpls_file,i,sizeof(i));
      {$I+}
      if((i and %10000000)>0)then wudata_log(rpls_POVPlayer,@rpls_log_n,true);
      if((i and %01000000)>0)then
      begin
         rpls_vidx:=_vx;
         rpls_vidy:=_vy;
         {$I-}
         BlockWrite(rpls_file,rpls_vidx,sizeof(rpls_vidx));
         BlockWrite(rpls_file,rpls_vidy,sizeof(rpls_vidy));
         {$I+}
      end;

      if(gs=gs_running)then wclinet_gframe(rpls_POVPlayer,true);
   end;

   if(ioresult<>0)then
   begin
      replay_Abort;
      rpls_rstate:=rpls_state_none;
      GameLogChat(PlayerClient,log_to_all,str_msg_ReplayFail+str_error_FileWrite,true);
   end;
end;

// READ
procedure replay_Readhead;
var p:byte;
begin
   replay_Abort;

   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then
   begin
      rpls_rstate   :=rpls_state_none;
      G_Started     :=false;
      rpls_str_info1:='';
      rpls_str_info2:='';
      rpls_str_info3:='';
      rpls_str_infoS:='';
      exit;
   end;

   rpls_str_path:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(not FileExists(rpls_str_path))then
   begin
      rpls_rstate   :=rpls_state_none;
      G_Started    :=false;
      rpls_str_info1:=str_error_FileExists;
      //GameLogChat(PlayerClient,log_to_all,str_error_FileExists+' '+rpls_list[rpls_list_sel],true);
      exit;
   end;

   assign(rpls_file,rpls_str_path);
   {$I-}
   reset (rpls_file,1);
   {$I+}

   if(ioresult<>0)then
   begin
      replay_Abort;
      G_Started    :=false;
      rpls_str_info1:=str_error_OpenFile;
      //GameLogChat(PlayerClient,log_to_all,str_error_OpenFile+' '+rpls_list[rpls_list_sel],true);
   end
   else
   begin
      rpls_file_size:=FileSize(rpls_file);

      if(rpls_file_size<rpls_file_head_size)then
      begin
         replay_Abort;
         G_Started    :=false;
         rpls_str_info1:=str_error_WrongData;
         exit;
      end;

      i:=0;
      {$I-}
      BlockRead(rpls_file,i,SizeOf(g_version));
      {$I+}

      if(i<>g_version)then
      begin
         replay_Abort;
         G_Started    :=false;
         rpls_str_info1:=str_error_WrongVersion;
      end
      else
      begin
         GameDefaultAll;

         {$I-}
         {BlockRead(rpls_file,G_Step           ,SizeOf(G_Step           ));
         BlockRead(rpls_file,map_seed         ,SizeOf(map_seed         ));
         BlockRead(rpls_file,map_psize         ,SizeOf(map_psize         ));
         BlockRead(rpls_file,map_type         ,SizeOf(map_type         ));
         BlockRead(rpls_file,map_symmetry     ,SizeOf(map_type         ));
         BlockRead(rpls_file,theme_cur        ,SizeOf(theme_cur        ));
         BlockRead(rpls_file,g_mode           ,SizeOf(g_mode           ));
         BlockRead(rpls_file,g_start_base     ,SizeOf(g_start_base     ));
         BlockRead(rpls_file,g_generators     ,SizeOf(g_generators     ));
         BlockRead(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
         BlockRead(rpls_file,g_deadobservers  ,SizeOf(g_deadobservers  ));
         BlockRead(rpls_file,g_ai_slots       ,SizeOf(g_ai_slots       ));
         BlockRead(rpls_file,rpls_POVPlayer   ,SizeOf(rpls_POVPlayer   ));}
         if(rpls_head_itemn>1)then
          for p:=1 to rpls_head_itemn-1 do
           with rpls_head_items[p] do
            BlockRead(rpls_file,byte(data_p^),data_s);
         {$I+}

         if(map_psize<MinMapSize)or(map_psize>MaxMapSize)
         or(map_type      >gms_m_types  )
         or(map_symmetry  >gms_m_symm   )
         or(g_mode        >gms_count    )
         or(g_generators  >gms_g_maxgens)
         or(g_ai_slots    >gms_g_maxai  )
         or(rpls_POVPlayer>LastPlayer   )then
         begin
            replay_Abort;
            G_Started:=false;
            rpls_str_info1:=str_error_WrongVersion;
            GameDefaultAll;
            exit;
         end;

         for p:=0 to LastPlayer do
          with g_players[p] do
          begin
             {$I-}
             BlockRead(rpls_file,name       ,sizeof(name       ));
             BlockRead(rpls_file,player_type,sizeof(player_type));
             BlockRead(rpls_file,race       ,sizeof(race       ));
             BlockRead(rpls_file,slot_race  ,sizeof(slot_race  ));
             BlockRead(rpls_file,team       ,sizeof(team       ));

             BlockRead(rpls_file,g_slot_state[p],sizeof(g_slot_state[p]));
             {$I+}
          end;

         if(ioresult<>0)then
         begin
            replay_Abort;
            rpls_str_info1:=str_error_WrongVersion;
            GameDefaultAll;
            //GameLogChat(PlayerClient,log_to_all,str_error_WrongVersion+' '+rpls_list[rpls_list_sel],true);
            exit;
         end;

         PlayersValidateName;

         if(rpls_pnu=0)then rpls_pnu:=NetTickN;
         UnitMoveStepTicks:=trunc(MaxUnits/rpls_pnu)*NetTickN;
         if(UnitMoveStepTicks=0)then UnitMoveStepTicks:=1;

         rpls_fstate :=rpls_state_read;
         rpls_rstate :=rpls_state_read;
         rpls_pnu    :=0;
         rpls_ticks  :=0;
         PlayerClient:=rpls_POVPlayer;
         UIPlayer    :=PlayerClient;

         rpls_POVCam  :=false;

         map_Make1;
         //vid_map_RedrawBack:=true;
         GameCameraMoveToPoint(map_PlayerStartX[PlayerClient],map_PlayerStartY[PlayerClient]);

         GameCameraBounds;
         ui_tab    :=tt_controls;
         G_Started :=true;
         menu_state:=false;
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
      sys_uncappedFPS:=false;
      exit;
   end;

   if(eof(rpls_file))then
   begin
      G_Status        :=gs_replayend;
      sys_uncappedFPS :=false;
      rpls_ForwardStep:=0;
      exit;
   end;

   //gs_replaypause
   gs:=G_Status;
   if(rpls_ForwardStep<=0)and(G_Status=gs_running)then rpls_ForwardStep:=1;
   while(rpls_ForwardStep>0)do
   begin
      replay_SavePlayPosition;

      {$I-}
      BlockRead(rpls_file,i,SizeOf(i));
      {$I+}
      G_Status:=i and %00111111;

      if((i and %10000000)>0)then rudata_log(rpls_POVPlayer,true);
      if((i and %01000000)>0)then
      begin
         {$I-}
         BlockRead(rpls_file,rpls_vidx,sizeof(rpls_vidx));
         BlockRead(rpls_file,rpls_vidy,sizeof(rpls_vidy));
         {$I+}
      end;

      if(G_Status=gs_running)then rclinet_gframe(rpls_POVPlayer,true,rpls_ForwardStep>1);

      if(rpls_ForwardStep>1)then d_SpriteListAddEffects(false,false);
      rpls_ForwardStep-=1;
   end;

   if(rpls_POVCam)then
   begin
      vid_cam_x:=(vid_cam_x+integer(rpls_vidx shl vxyc)) div 2;
      vid_cam_y:=(vid_cam_y+integer(rpls_vidy shl vxyc)) div 2;
      GameCameraBounds;
   end;

   if(gs=gs_replaypause)then G_Status:=gs;
end;

begin
   if(rpls_StartRecordPause>0)
   then rpls_StartRecordPause-=1
   else
     if(rpls_Recording)and(G_Started)and(rpls_rstate=rpls_state_none)then
     begin
        rpls_rstate:=rpls_state_write;
        rpls_StartRecordPause:=fr_fps2;
        GameLogChat(PlayerClient,log_to_all,str_msg_ReplayStart+rpls_str_prefix,true);
     end;

   if(not G_Started)or(rpls_rstate=rpls_state_none)//or(menu_s2=ms2_camp)
   then replay_Abort
   else
     if(G_Started)then
     begin
        rpls_ticks+=1;
        case rpls_rstate of
rpls_state_write : if(rpls_fstate<>rpls_state_write)
                   then replay_WriteHead
                   else replay_WriteGameFrame;
rpls_state_read  : if(rpls_fstate<>rpls_state_read)
                   then replay_Readhead
                   else replay_ReadGameFrame;
        else replay_Abort;
        end;
     end;
end;

procedure replay_Select;
begin
   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)
   then replay_MenuSelectedInfo
   else
   begin
      rpls_str_info1:='';
      rpls_str_info2:='';
      rpls_str_info3:='';
      rpls_str_infoS:='';
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

function replay_Play(Check:boolean):boolean;
begin
   replay_Play:=false;
   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   replay_Play:=true;
   if(Check)then exit;

   rpls_rstate:=rpls_state_read;
   G_Started :=true;
   menu_page1:=mp_scirmish;
end;

function replay_Delete(Check:boolean):boolean;
var fn:shortstring;
begin
   replay_Delete:=false;
   if(rpls_list_sel<0)or(rpls_list_sel>=rpls_list_size)then exit;

   fn:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;
   if(FileExists(fn))then
   begin
      replay_Delete:=true;
      if(Check)then exit;

      DeleteFile(fn);
      replay_MakeFolderList;
   end;
end;


