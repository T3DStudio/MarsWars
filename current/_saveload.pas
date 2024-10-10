

procedure saveload_MenuSelectedInfo;
var f :file;
   hp :byte;
   vr :integer=0;
   fn :shortstring;
   ms :cardinal;
   mw :word;
   pls:TPList;
begin
   ms:=0;
   vr:=0;
   mw:=0;
   hp:=0;
   FillChar(pls,Sizeof(pls),0);

   svld_str_info:='';

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
   if(length(svld_list[svld_list_sel])>0)then
   if(FileExists(fn))then
   begin
      assign(f,fn);
      {$I-}
      reset(f,1);
      {$I+}
      if(ioresult<>0)then
      begin
         svld_str_info:=str_error_OpenFile;
         close(f);
         exit;
      end;
      if(FileSize(f)<>svld_file_size)then
      begin
         svld_str_info:=str_error_WrongData;
         close(f);
         exit;
      end;
      BlockRead(f,vr,SizeOf(g_version));
      if(vr=g_version)then
      begin
         {BlockRead(f,vr,sizeof(menu_s2));
         if(vr=ms2_camp)then
         begin
            BlockRead(f,vr,sizeof(campain_mission_n));
            if(0<=vr)and(vr<=MaxMissions)then
            begin
               svld_str_info:='';//str_camp_t[vr];
               BlockRead(f,vr,sizeof(campain_skill));
               if(0<=vr)and(vr<=CMPMaxSkills)
               then svld_str_info+=tc_nl1+str_cmpdif+tc_nl1+str_cmpd[vr]
               else svld_str_info:=str_error_WrongVersion;
            end
            else svld_str_info:=str_error_WrongVersion;
         end
         else}
         begin
            BlockRead(f,vr,sizeof(campain_mission_n));vr:=0;
            BlockRead(f,vr,sizeof(campain_skill    ));vr:=0;

            BlockRead(f,ms,sizeof(map_seed         ));svld_str_info:=str_map+': '+c2s(ms)+tc_nl2+' ';
            BlockRead(f,vr,sizeof(g_random_i       ));vr:=0;
            BlockRead(f,vr,sizeof(map_size         ));
            if(vr<MinMapSize)and(MaxMapSize<vr)
                                      then begin svld_str_info:=str_error_WrongVersion;close(f);exit; end
                                      else       svld_str_info+=str_map_size+i2s(vr)+tc_nl2+' ';
            vr:=0;

            BlockRead(f,vr,sizeof(map_type         ));
            if(vr>gms_m_types        )then begin svld_str_info:=str_error_WrongVersion;close(f);exit; end
                                      else       svld_str_info+=str_map_type+str_map_typel[vr]+tc_default+tc_nl2+' ';
            vr:=0;

            BlockRead(f,vr,sizeof(map_symmetry     ));
            if(vr>gms_m_symm         )then begin svld_str_info:=str_error_WrongVersion;close(f);exit; end
                                      else       svld_str_info+=str_map_sym+str_map_syml[vr]+tc_nl2+' ';
            vr:=0;

            BlockRead(f,vr,sizeof(theme_cur        ));
            if(vr>=theme_n           )then begin svld_str_info:=str_error_WrongVersion;close(f);exit; end;
            vr:=0;

            BlockRead(f,vr,sizeof(g_mode           ));
            if not(vr in allgamemodes)then begin svld_str_info:=str_error_WrongVersion;close(f);exit; end
                                      else       svld_str_info+=str_emnu_GameModel[vr  ]+tc_nl2+tc_default;
            vr:=0;

            BlockRead(f,vr,sizeof(g_start_base     ));vr:=0;
            BlockRead(f,vr,sizeof(g_fixed_positions));vr:=0;
            BlockRead(f,vr,sizeof(g_generators     ));vr:=0;

            BlockRead(f,hp,sizeof(PlayerClient));

            BlockRead(f,pls,SizeOf(TPList));
            svld_str_info+=tc_nl2;

            for vr:=1 to MaxPlayers do
            begin
               if(vr=hp)
               then svld_str_info+=chr(vr)+'*'+tc_default
               else svld_str_info+=chr(vr)+'#'+tc_default;

               if(pls[vr].player_type>pt_none)then
                 if(pls[vr].team=0)
                 then svld_str_info+=str_observer[1]                +','+t2c(pls[vr].team)+','
                 else svld_str_info+=str_racel[pls[vr].slot_race][2]+','+t2c(pls[vr].team)+',';
               svld_str_info+=pls[vr].name+tc_nl2
            end;
         end;
      end
      else svld_str_info:=str_error_WrongVersion;
      close(f);
   end
   else svld_str_info:=str_error_FileExists;
end;

procedure saveload_Select;
begin
   if(0<=svld_list_sel)and(svld_list_sel<svld_list_size)then
   begin
      svld_str_fname:=svld_list[svld_list_sel];
      saveload_MenuSelectedInfo;
   end
   else
   begin
      svld_str_fname:='';
      svld_str_info :='';
   end;
end;

procedure saveload_MakeFolderList;
var Info : TSearchRec;
       s : shortstring;
begin
   svld_list_scroll:=0;
   svld_list_size  :=0;
   setlength(svld_list,0);
   if(FindFirst(str_f_svld+'*'+str_e_svld,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       delete(s,length(s)-(length(str_e_svld)-1),length(str_e_svld));
       if(length(s)>0)then
       begin
          svld_list_size+=1;
          setlength(svld_list,svld_list_size);
          svld_list[svld_list_size-1]:=s;
       end;
    until (FindNext(info)<>0);
   FindClose(info);

   saveload_Select;
end;

procedure saveload_CalcSaveSize;
begin
   svld_file_size:=
   SizeOf(g_version        )+
   //SizeOf(menu_s2          )+
   SizeOf(campain_mission_n)+
   SizeOf(campain_skill    )+
   SizeOf(map_seed         )+
   SizeOf(g_random_i       )+
   SizeOf(map_size         )+
   SizeOf(map_type         )+
   SizeOf(theme_cur        )+
   SizeOf(g_mode           )+
   SizeOf(g_start_base     )+
   SizeOf(g_fixed_positions)+
   SizeOf(g_generators     )+
   SizeOf(PlayerClient     )+
   SizeOf(TPList           )+
   SizeOf(g_slot_state     )+
   SizeOf(g_units          )+
   SizeOf(g_missiles       )+
   SizeOf(g_effects        )+
   SizeOf(vid_cam_x        )+
   SizeOf(vid_cam_y        )+
   SizeOf(G_Step           )+
   SizeOf(vid_blink_timer1 )+
   SizeOf(vid_blink_timer2 )+
   SizeOf(m_brush          )+
   SizeOf(g_inv_wave_n     )+
   SizeOf(g_inv_wave_t_next)+
   SizeOf(g_inv_wave_t_curr)+
   SizeOf(g_cpoints        )+
   SizeOf(g_royal_r        )+
   SizeOf(g_status         )+
   SizeOf(g_cycle_order    )+
   SizeOf(g_cycle_regen    )+
   SizeOf(ui_alarms        )+
   SizeOf(map_PlayerStartX )+
   SizeOf(map_PlayerStartY )+
   SizeOf(map_grid         )+
   SizeOf(g_random_p       );
   //SizeOf(theme_map_liquid    )+
   //SizeOf(theme_map_terrain2   )+
   //SizeOf(theme_map_terrain1    );
   //SizeOf(theme_map_crt    )+1;
end;

procedure saveload_Save;
var f:file;
begin
   assign(f,str_f_svld+svld_str_fname+str_e_svld);
   {$I-}
   rewrite(f,1);
   {$I+}
   if(ioresult<>0)then exit;

   BlockWrite(f,g_version        ,SizeOf(g_version        ));
  // BlockWrite(f,menu_s2          ,SizeOf(menu_s2          ));
   BlockWrite(f,campain_mission_n,SizeOf(campain_mission_n));
   BlockWrite(f,campain_skill    ,SizeOf(campain_skill    ));
   BlockWrite(f,map_seed         ,SizeOf(map_seed         ));
   BlockWrite(f,g_random_i       ,SizeOf(g_random_i       ));
   BlockWrite(f,map_size         ,SizeOf(map_size         ));
   BlockWrite(f,map_type         ,SizeOf(map_type         ));
   BlockWrite(f,map_symmetry     ,sizeof(map_symmetry     ));
   BlockWrite(f,theme_cur        ,SizeOf(theme_cur        ));
   BlockWrite(f,g_mode           ,SizeOf(g_mode           ));
   BlockWrite(f,g_start_base     ,SizeOf(g_start_base     ));
   BlockWrite(f,g_fixed_positions,SizeOf(g_fixed_positions));
   BlockWrite(f,g_generators     ,SizeOf(g_generators     ));
   BlockWrite(f,PlayerClient     ,SizeOf(PlayerClient     ));
   BlockWrite(f,g_players        ,SizeOf(TPList           ));
   BlockWrite(f,g_slot_state     ,SizeOf(g_slot_state     ));
   BlockWrite(f,g_units          ,SizeOf(g_units          ));
   BlockWrite(f,g_missiles       ,SizeOf(g_missiles       ));
   BlockWrite(f,g_effects        ,SizeOf(g_effects        ));
   BlockWrite(f,vid_cam_x        ,SizeOf(vid_cam_x        ));
   BlockWrite(f,vid_cam_y        ,SizeOf(vid_cam_y        ));
   BlockWrite(f,G_Step           ,SizeOf(G_Step           ));
   BlockWrite(f,vid_blink_timer1 ,SizeOf(vid_blink_timer1 ));
   BlockWrite(f,vid_blink_timer2 ,SizeOf(vid_blink_timer2 ));
   BlockWrite(f,m_brush          ,SizeOf(m_brush          ));
   BlockWrite(f,g_inv_wave_n     ,SizeOf(g_inv_wave_n     ));
   BlockWrite(f,g_inv_wave_t_next,SizeOf(g_inv_wave_t_next));
   BlockWrite(f,g_inv_wave_t_curr,SizeOf(g_inv_wave_t_curr));
   BlockWrite(f,g_cpoints        ,SizeOf(g_cpoints        ));
   BlockWrite(f,g_royal_r        ,SizeOf(g_royal_r        ));
   BlockWrite(f,g_status         ,SizeOf(g_status         ));
   BlockWrite(f,g_cycle_order    ,SizeOf(g_cycle_order    ));
   BlockWrite(f,g_cycle_regen    ,SizeOf(g_cycle_regen    ));
   BlockWrite(f,ui_alarms        ,SizeOf(ui_alarms        ));
   BlockWrite(f,map_PlayerStartX ,SizeOf(map_PlayerStartX ));
   BlockWrite(f,map_PlayerStartY ,SizeOf(map_PlayerStartY ));
   BlockWrite(f,map_grid         ,SizeOf(map_grid         ));
   BlockWrite(f,g_random_p       ,SizeOf(g_random_p       ));
   //BlockWrite(f,theme_map_liquid    ,SizeOf(theme_map_liquid    ));
   //BlockWrite(f,theme_map_terrain2   ,SizeOf(theme_map_terrain2   ));
   //BlockWrite(f,theme_map_terrain1    ,SizeOf(theme_map_terrain1    ));
   //BlockWrite(f,theme_map_crt    ,SizeOf(theme_map_crt    ));

   close(f);

   if(menu_state)
   then menu_Toggle;

   saveload_MakeFolderList;

   GameLogChat(PlayerClient,log_to_all,str_msg_GameSaved,true);
end;


procedure saveload_Load;
var f:file;
   fn:shortstring;
   vr:byte=0;
   u:integer;
begin
   if(svld_list_sel<0)or(svld_list_sel>=svld_list_size)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
  if(length(svld_list[svld_list_sel])>0)then
   if(FileExists(fn))then
   begin
      assign(f,fn);
      {$I-}reset(f,1);{$I+} if (ioresult<>0) then exit;
      if(FileSize(f)<>svld_file_size)then begin close(f); exit; end;
      BlockRead(f,vr,SizeOf(g_version));
      if(vr=g_version)then
      begin
         GameDefaultAll;

         //BlockRead(f,menu_s2          ,SizeOf(menu_s2          ));
         BlockRead(f,campain_mission_n,SizeOf(campain_mission_n));
         BlockRead(f,campain_skill    ,SizeOf(campain_skill    ));
         BlockRead(f,map_seed         ,SizeOf(map_seed         ));
         BlockRead(f,g_random_i       ,SizeOf(g_random_i       ));
         BlockRead(f,map_size         ,SizeOf(map_size         ));
         BlockRead(f,map_type         ,SizeOf(map_type         ));
         BlockRead(f,map_symmetry     ,sizeof(map_symmetry     ));
         BlockRead(f,theme_cur        ,SizeOf(theme_cur        ));
         BlockRead(f,g_mode           ,SizeOf(g_mode           ));
         BlockRead(f,g_start_base     ,SizeOf(g_start_base     ));
         BlockRead(f,g_fixed_positions,SizeOf(g_fixed_positions));
         BlockRead(f,g_generators     ,SizeOf(g_generators     ));
         BlockRead(f,PlayerClient     ,SizeOf(PlayerClient     ));
         BlockRead(f,g_players        ,SizeOf(TPList           ));
         BlockRead(f,g_slot_state     ,SizeOf(g_slot_state     ));
         BlockRead(f,g_units          ,SizeOf(g_units          ));
         BlockRead(f,g_missiles       ,SizeOf(g_missiles       ));
         BlockRead(f,g_effects        ,SizeOf(g_effects        ));
         BlockRead(f,vid_cam_x        ,SizeOf(vid_cam_x        ));
         BlockRead(f,vid_cam_y        ,SizeOf(vid_cam_y        ));
         BlockRead(f,G_Step           ,SizeOf(G_Step           ));
         BlockRead(f,vid_blink_timer1 ,SizeOf(vid_blink_timer1 ));
         BlockRead(f,vid_blink_timer2 ,SizeOf(vid_blink_timer2 ));
         BlockRead(f,m_brush          ,SizeOf(m_brush          ));
         BlockRead(f,g_inv_wave_n     ,SizeOf(g_inv_wave_n     ));
         BlockRead(f,g_inv_wave_t_next,SizeOf(g_inv_wave_t_next));
         BlockRead(f,g_inv_wave_t_curr,SizeOf(g_inv_wave_t_curr));
         BlockRead(f,g_cpoints        ,SizeOf(g_cpoints        ));
         BlockRead(f,g_royal_r        ,SizeOf(g_royal_r        ));
         BlockRead(f,g_status         ,SizeOf(g_status         ));
         BlockRead(f,g_cycle_order    ,SizeOf(g_cycle_order    ));
         BlockRead(f,g_cycle_regen    ,SizeOf(g_cycle_regen    ));
         BlockRead(f,ui_alarms        ,SizeOf(ui_alarms        ));
         BlockRead(f,map_PlayerStartX ,SizeOf(map_PlayerStartX ));
         BlockRead(f,map_PlayerStartY ,SizeOf(map_PlayerStartY ));
         BlockRead(f,map_grid         ,SizeOf(map_grid         ));
         BlockRead(f,g_random_p       ,SizeOf(g_random_p       ));
         //BlockRead(f,theme_map_liquid    ,SizeOf(theme_map_liquid    ));
         //BlockRead(f,theme_map_terrain2   ,SizeOf(theme_map_terrain2   ));
         //BlockRead(f,theme_map_terrain1    ,SizeOf(theme_map_terrain1    ));
         //BlockRead(f,theme_map_crt    ,SizeOf(theme_map_crt    ));

         for u:=1 to MaxUnits do
           with g_units[u] do
           begin
              player:=@g_players[playeri];
              uid   :=@g_uids[uidi];
           end;

         PlayersValidateName;
         map_Vars;
         map_seed2theme;
         gfx_MakeThemeTiles;
        // map_RefreshDoodadsCells;
         //map_RedrawMenuMinimap;
         //map_DoodadsDrawData;
         //pf_MakeZoneGrid;
         GameCameraBounds;

         G_Started:=true;
         vid_map_RedrawBack:=true;

         if(menu_state)
         then menu_Toggle;
      end;
      close(f);
   end;
end;

procedure saveload_Delete;
var fn:shortstring;
begin
   if(svld_list_sel<0)or(svld_list_sel>=svld_list_size)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      saveload_MakeFolderList;
   end;
end;




