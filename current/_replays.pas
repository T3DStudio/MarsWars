

procedure replay_MenuSelectedInfo;
const pl_n_ch : array[false..true] of char = ('#','*');
var   f:file;
vr,t,hp,tm:byte;
     fn:shortstring;
     mw:integer;
     wr:cardinal;
begin
   rpls_str_info1:='';

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
         rpls_str_info1:=str_error_OpenFile;
         exit;
      end;
      if(FileSize(f)<rpls_file_head_size)then
      begin
         close(f);
         rpls_str_info1:=str_error_WrongData;
         exit;
      end;
      vr:=0;
      BlockRead(f,vr,SizeOf(g_version));
      if(vr=g_version)then
      begin
         hp:=0;
         vr:=0;
         mw:=0;
         wr:=0;
         rpls_str_info1:=str_menu_map+tc_nl2+' ';
         rpls_str_info2:=rpls_list[rpls_list_sel]+tc_nl2;

         BlockRead(f,wr,sizeof(map_seed    ));rpls_str_info1+=str_map_seed+c2s(wr)+tc_nl2+' ';wr:=0;
         BlockRead(f,mw,SizeOf(map_size    ));rpls_str_info1+=str_map_size+i2s(mw)+tc_nl2+' ';mw:=0;
         BlockRead(f,vr,sizeof(map_type    ));
         if(vr>gms_m_types)then begin rpls_str_info1:=str_error_WrongVersion;close(f);exit;     end
                           else       rpls_str_info1+=str_map_type+str_map_typel[vr]+tc_default+tc_nl2+' '; vr:=0;
         BlockRead(f,vr,sizeof(map_symmetry));
         if(vr>gms_m_symm )then begin rpls_str_info1:=str_error_WrongVersion;close(f);exit;     end
                           else       rpls_str_info1+=str_map_sym+str_map_syml[vr]+tc_nl2+' '; vr:=0;

         BlockRead(f,vr,sizeof(g_mode      ));
         if(vr in allgamemodes)then begin rpls_str_info1+=str_emnu_GameModel[vr]+tc_nl2;        end
                               else begin rpls_str_info1:=str_error_WrongVersion;close(f);exit; end;
         BlockRead(f,vr,sizeof(g_start_base     ));vr:=0;
         BlockRead(f,vr,sizeof(g_fixed_positions));vr:=0;
         BlockRead(f,vr,sizeof(g_generators     ));vr:=0;
         BlockRead(f,hp,SizeOf(PlayerClient     ));

         rpls_str_info1+=tc_nl2+str_menu_players+tc_nl2;

         for vr:=1 to MaxPlayers do
         begin
            BlockRead(f,fn,sizeof(fn));   // name

            rpls_str_info1+=chr(vr)+pl_n_ch[vr=hp]+tc_default;
            if(vr=hp)then rpls_str_info2+=pl_n_ch[vr=hp]+fn;

            t :=0;
            tm:=0;
            BlockRead(f,t ,1);  // state
            if(t=pt_none)then
            begin
               rpls_str_info1+=fn;
               BlockRead(f,mw,5);
            end
            else
            begin
               BlockRead(f,t ,1); // race
               BlockRead(f,tm,1); // slot_race
               BlockRead(f,t ,1); // team
               BlockRead(f,tm,1); // slot_state

               if(t=0)
               then rpls_str_info1+=str_observer[1]
               else
                 if(tm<=r_cnt)
                 then rpls_str_info1+=str_racel[tm][2]
                 else rpls_str_info1+='?';
               rpls_str_info1+=','+t2c(t)+','+fn;
            end;
            if(vr<MaxPlayers)then rpls_str_info1+=tc_nl2;
         end;
      end
      else rpls_str_info1:=str_error_WrongVersion;
      close(f);
   end
   else rpls_str_info1:=str_error_FileExists;
end;

procedure replay_CalcHeaderSize;
begin
   rpls_file_head_size
                 :=SizeOf(g_version        )
                  +SizeOf(map_seed         )
                  +SizeOf(map_size         )
                  +SizeOf(map_type         )
                  +SizeOf(map_symmetry     )

                  +SizeOf(g_mode           )
                  +SizeOf(g_start_base     )
                  +SizeOf(g_fixed_positions)
                  +SizeOf(g_generators     )
                  +sizeof(rpls_POVPlayer   );
   with g_players[0] do
   rpls_file_head_size
                 +=cardinal((sizeof(name       )
                            +sizeof(player_type)
                            +sizeof(race       )
                            +sizeof(slot_race  )
                            +sizeof(team       )
                            +g_slot_state[0]   )*MaxPlayers);
end;

function replay_GetProgress:single;
begin
   replay_GetProgress:=0;

   if(rpls_state=rpls_state_read)and(rpls_fstatus=rpls_file_read)and(rpls_file_size>0)then
   begin
      replay_GetProgress:=FilePos(rpls_file)/rpls_file_size;
      if(replay_GetProgress>1)then replay_GetProgress:=1;
      if(replay_GetProgress<0)then replay_GetProgress:=0;
   end;
end;

procedure replay_SavePlayPosition;
begin
   if(rpls_fstatus<>rpls_file_read)
   or(rpls_state  <>rpls_state_read)then exit;

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
function replay_SetPlayPosition(timetick,mindist:int64):boolean;
var ni,i :cardinal;
    vi,vt:int64;
begin
   replay_SetPlayPosition:=false;
   if(rpls_ReadPosN=0)
   or(rpls_fstatus<>rpls_file_read)
   or(rpls_state  <>rpls_state_read)then exit;

   ni:=cardinal.MaxValue;
   vi:=0;
   for i:=0 to rpls_ReadPosN-1 do
    with rpls_ReadPosL[i] do
     if(rp_gtick<=timetick)then
     begin
        vt:=abs(rp_gtick-timetick);
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
      g_Step:=rp_gtick;
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
   if(rpls_fstatus>rpls_file_none)then
   begin
      close(rpls_file);
      rpls_fstatus:=rpls_file_none;
   end;
   if(rpls_state>=rpls_state_read)then rpls_state:=rpls_state_none;
   rpls_ReadPosN:=0;
   setlength(rpls_ReadPosl,rpls_ReadPosN);
end;


function str_DateTime:shortstring;
var YY,MM,DD,H,M,S,MS:word;
begin
   DeCodeDate(Date,YY,MM,DD);
   DeCodeTime(Time,H,M,S,MS);
   str_DateTime:=w2s(YY)+'_'+w2s(MM)+'_'+w2s(DD)+' '+w2s(H)+'-'+w2s(M)+'-'+w2s(S)+'-'+w2s(MS);
end;


procedure replay_MakeNewReplayPath;
const
replay_template_n = '%N%';
var    p: byte;
       i: integer;
tmp_strt: shortstring;
begin
   // rpls_str_path:=str_f_rpls+rpls_str_name+str_e_rpls;
   tmp_strt:='';

{
i:=0;
repeat
   i+=1;
   s:=str_screenshot+i2s(i)+'.bmp';
until not FileExists(s);
}
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

   rpls_str_path:=str_f_rpls+rpls_str_name+str_e_rpls;

   assign (rpls_file,rpls_str_path);
   {$I-}
   rewrite(rpls_file,1);
   {$I+}

   if(ioresult<>0)then
   begin
      replay_Abort;
      rpls_state:=rpls_state_none;
      GameLogChat(PlayerClient,log_to_all,str_msg_ReplayFail+str_error_OpenFile,true);
   end
   else
   begin
      rpls_fstatus  :=rpls_file_write;
      rpls_state    :=rpls_state_write;
      rpls_u        :=MaxPlayerUnits+1;
      rpls_POVPlayer:=PlayerClient;
      rpls_log_n    :=g_players[rpls_POVPlayer].log_n;
      rpls_plcam    :=false;
      rpls_ticks    :=0;

      {$I-}
      BlockWrite(rpls_file,g_version        ,SizeOf(g_version        ));
      BlockWrite(rpls_file,map_seed         ,SizeOf(map_seed         ));
      BlockWrite(rpls_file,map_size         ,SizeOf(map_size         ));
      BlockWrite(rpls_file,map_type         ,SizeOf(map_type         ));
      BlockWrite(rpls_file,map_symmetry     ,SizeOf(map_symmetry     ));

      BlockWrite(rpls_file,g_mode           ,SizeOf(g_mode           ));
      BlockWrite(rpls_file,g_start_base     ,SizeOf(g_start_base     ));
      BlockWrite(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
      BlockWrite(rpls_file,g_generators     ,SizeOf(g_generators     ));
      BlockWrite(rpls_file,rpls_POVPlayer   ,sizeof(rpls_POVPlayer   ));
      {$I+}

      for p:=1 to MaxPlayers do
        with g_players[p] do
        begin
           {$I-}
           BlockWrite(rpls_file,name       ,sizeof(name       ));
           BlockWrite(rpls_file,player_type,sizeof(player_type));
           BlockWrite(rpls_file,race       ,sizeof(race       ));
           BlockWrite(rpls_file,slot_race  ,sizeof(slot_race  ));
           BlockWrite(rpls_file,team       ,sizeof(team       ));
           BlockWrite(rpls_file,g_slot_state[p],sizeof(g_slot_state[p]));
           {$I+}
        end;

      if(ioresult<>0)then
      begin
         replay_Abort;
         rpls_state:=rpls_state_none;
         GameLogChat(PlayerClient,log_to_all,str_msg_ReplayFail+str_error_FileWrite,true);
      end;
   end;
end;
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
      rpls_state:=rpls_state_none;
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
      rpls_state    :=rpls_state_none;
      G_Started     :=false;
      rpls_str_info1:='';
      rpls_str_info2:='';
      exit;
   end;

   rpls_str_path:=str_f_rpls+rpls_list[rpls_list_sel]+str_e_rpls;

   if(not FileExists(rpls_str_path))then
   begin
      rpls_state   :=rpls_state_none;
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
         BlockRead(rpls_file,map_seed         ,SizeOf(map_seed         ));
         BlockRead(rpls_file,map_size         ,SizeOf(map_size         ));
         BlockRead(rpls_file,map_type         ,SizeOf(map_type         ));
         BlockRead(rpls_file,map_symmetry     ,SizeOf(map_symmetry     ));
         BlockRead(rpls_file,g_mode           ,SizeOf(g_mode           ));
         BlockRead(rpls_file,g_start_base     ,SizeOf(g_start_base     ));
         BlockRead(rpls_file,g_fixed_positions,SizeOf(g_fixed_positions));
         BlockRead(rpls_file,g_generators     ,SizeOf(g_generators     ));
         BlockRead(rpls_file,rpls_POVPlayer   ,sizeof(rpls_POVPlayer   ));
         {$I+}

         if(map_size<MinMapSize)or(map_size>MaxMapSize)
         or(map_type      >gms_m_types  )
         or(map_symmetry  >gms_m_symm   )
         or(g_mode        >gms_count    )
         or(g_start_base  >gms_g_startb )
         or(g_generators  >gms_g_maxgens)
         or(rpls_POVPlayer>MaxPlayers   )then
         begin
            replay_Abort;
            G_Started:=false;
            rpls_str_info1:=str_error_WrongVersion;
            GameDefaultAll;
            exit;
         end;

         for p:=1 to MaxPlayers do
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

         rpls_fstatus:=rpls_file_read;
         rpls_state  :=rpls_state_read;
         rpls_pnu    :=0;
         rpls_ticks  :=0;
         PlayerClient:=rpls_POVPlayer;
         UIPlayer    :=PlayerClient;

         rpls_plcam  :=false;

         map_premap;
         vid_map_RedrawBack:=true;
         GameCameraMoveToPoint(map_PlayerStartX[PlayerClient],map_PlayerStartY[PlayerClient]);

         GameCameraBounds;
         ui_tab    :=3;
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

      if(rpls_ForwardStep>1)then effects_sprites(false,false);
      rpls_ForwardStep-=1;
   end;

   if(rpls_plcam)then
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
     if(rpls_Recording)and(G_Started)and(rpls_state=rpls_state_none)then
     begin
        rpls_state:=rpls_state_write;
        rpls_StartRecordPause:=fr_fps2;
        GameLogChat(PlayerClient,log_to_all,str_msg_ReplayStart+rpls_str_name,true);
     end;

   if(not G_Started)or(rpls_state=rpls_state_none)//or(menu_s2=ms2_camp)
   then replay_Abort
   else
     if(G_Started)then
     begin
        rpls_ticks+=1;
        case rpls_state of
rpls_state_write : if(rpls_fstatus<>rpls_file_write)
                   then replay_WriteHead
                   else replay_WriteGameFrame;
rpls_state_read  : if(rpls_fstatus<>rpls_file_read)
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
     if(G_Started=false)then rpls_str_info1:='';
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

   rpls_state:=rpls_state_read;
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


