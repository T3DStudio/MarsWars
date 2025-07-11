

procedure saveload_MenuSelectedInfo;
var     f : file;
 filename : shortstring;
 pdstr    : pshortstring;
    i,
    dbyte : byte;
    dcard : cardinal;
 dplayers : TPList;
 dpslots  : TPlayerSlots;
begin
   FillChar(dplayers,Sizeof(dplayers),0);
   FillChar(dpslots ,Sizeof(dpslots ),0);

   svld_str_info1:='';
   svld_str_info2:='';
   svld_str_info3:='';
   svld_str_info4:='';

   if(svld_list_sel<0)or(svld_list_sel>=svld_list_size)then exit;
   if(length(svld_list[svld_list_sel])=0)then exit;

   filename:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
   if(FileExists(filename))then
   begin
      assign(f,filename);
      {$I-}
      reset(f,1);
      {$I+}
      if(ioresult<>0)then
      begin
         svld_str_info1:=str_error_OpenFile;
         close(f);
         exit;
      end;
      if(FileSize(f)<>svld_file_size)then
      begin
         svld_str_info1:=str_error_WrongData;
         close(f);
         exit;
      end;
      dbyte:=0;
      dcard:=0;
      BlockRead(f,dbyte,SizeOf(g_version));
      if(dbyte=g_version)then
      begin
         BlockRead(f,dbyte,sizeof(campain_mission));
         if(dbyte<=MaxMissions)then
         begin
            svld_str_info1:='camp';//str_camp_t[vr];
            //BlockRead(f,dbyte,sizeof(campain_skill));dbyte:=0;
            //BlockRead(f,dcard,sizeof(campain_seed ));dcard:=0;
            {if(0<=vr)and(vr<=CMPMaxSkills)
            then svld_str_info+=tc_nl1+str_cmpdif+tc_nl1+str_cmpd[vr]
            else svld_str_info:=str_error_WrongVersion;}
         end
         else
         begin
            BlockRead(f,dbyte,sizeof(campain_skill));
            BlockRead(f,dcard,sizeof(campain_seed ));

            if(not FileReadBaseGameInfo(f,@svld_str_info1,@svld_str_info2))then exit;

            // PLAYERS info
            BlockRead(f,dbyte   ,sizeof(PlayerClient  ));

            BlockRead(f,dplayers,SizeOf(dplayers      ));
            BlockRead(f,dpslots ,SizeOf(dpslots       ));

            for i:=0 to LastPlayer do
            with dplayers[i] do
            begin
               if(i<5)
               then pdstr:=@svld_str_info3
               else pdstr:=@svld_str_info4;

               pdstr^+=chr(i)+b2s(i+1)+tc_default+pl_n_ch[dbyte=i];

               case dpslots[i] of
               pss_closed    : pdstr^+=str_SpaceSize(str_menu_PlayerSlots[dpslots[i]],PlayerNameLen);
               pss_observer  : if(player_type=pt_none)
                               then pdstr^+=str_SpaceSize(''  ,PlayerNameLen)+' '+str_observer
                               else pdstr^+=str_SpaceSize(name,PlayerNameLen)+' '+str_observer;
               pss_opened,
               pss_AI_1..
               pss_AI_11     : if(isobserver)and(player_type>pt_none)
                               then pdstr^+=str_SpaceSize(name,PlayerNameLen)+' '+
                                            str_SpaceSize(str_observer    ,8)+' '+
                                            b2s(team+1)
                               else
                                 if(isdefeated)
                                 then pdstr^+=str_SpaceSize(name,PlayerNameLen)+' '+
                                              str_SpaceSize(str_defeated    ,8)+' '+
                                              b2s(team+1)
                                 else pdstr^+=str_SpaceSize(name,PlayerNameLen)    +' '+
                                              str_SpaceSize(str_racel[slot_race],8)+' '+
                                              b2s(team+1);

               else
                   svld_str_info1:=str_error_WrongData;
                   svld_str_info2:='';
                   svld_str_info3:='';
                   svld_str_info4:='';
                   close(f);
                   exit;
               end;

               if(i<>4)then pdstr^+=tc_nl2;
            end;
         end;
      end
      else svld_str_info1:=str_error_WrongVersion;
      close(f);
   end
   else svld_str_info1:=str_error_FileExists;
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
      svld_str_info1:='';
      svld_str_info2:='';
      svld_str_info3:='';
   end;
end;

procedure saveload_SelectByName(name:shortstring);
var i:integer;
begin
   svld_list_sel :=-1;
   svld_str_info1:='';
   svld_str_info2:='';
   svld_str_info3:='';
   if(svld_list_size>0)then
    for i:=0 to svld_list_size-1 do
     if(svld_list[i]=name)then
     begin
        svld_list_sel:=i;
        svld_str_fname:=svld_list[svld_list_sel];
        saveload_MenuSelectedInfo;
        break;
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
    until(FindNext(info)<>0);
   FindClose(info);

   if(svld_list_size>0)then
     svld_list_sel:=mm3i(0,svld_list_sel,svld_list_size-1);
   saveload_Select;
end;

procedure saveload_MakeSaveData;
procedure AddItem(pdata:pointer;sdata:cardinal);
begin
   svld_itemn+=1;
   setlength(svld_items,svld_itemn);
   with svld_items[svld_itemn-1] do
   begin
      data_p:=pdata;
      data_s:=sdata;
   end;
   svld_file_size+=sdata;
end;
begin
   svld_itemn:=0;
   setlength(svld_items,0);
   svld_file_size:=0;

   // 'CAPTION' part
   AddItem(@g_version        ,SizeOf(g_version        ));
   AddItem(@campain_mission  ,SizeOf(campain_mission  ));
   AddItem(@campain_skill    ,SizeOf(campain_skill    ));
   AddItem(@campain_seed     ,SizeOf(campain_seed     ));
   AddItem(@G_Step           ,SizeOf(G_Step           ));
   AddItem(@map_preset_cur   ,SizeOf(map_preset_cur   ));
   AddItem(@map_scenario     ,SizeOf(map_scenario     ));
   AddItem(@map_generators   ,SizeOf(map_generators   ));
   AddItem(@map_seed         ,SizeOf(map_seed         ));
   AddItem(@map_psize        ,SizeOf(map_psize        ));
   AddItem(@map_type         ,SizeOf(map_type         ));
   AddItem(@map_symmetry     ,SizeOf(map_type         ));
   AddItem(@theme_cur        ,SizeOf(theme_cur        ));
   AddItem(@g_fixed_positions,SizeOf(g_fixed_positions));
   AddItem(@g_deadobservers  ,SizeOf(g_deadobservers  ));
   AddItem(@g_ai_slots       ,SizeOf(g_ai_slots       ));
   AddItem(@PlayerClient     ,SizeOf(PlayerClient     ));
   AddItem(@g_slot_state     ,SizeOf(g_slot_state     ));
   // other
   AddItem(@g_players        ,SizeOf(g_players        ));
   AddItem(@g_units          ,SizeOf(g_units          ));
   AddItem(@g_missiles       ,SizeOf(g_missiles       ));
   AddItem(@g_effects        ,SizeOf(g_effects        ));
   AddItem(@g_random_i       ,SizeOf(g_random_i       ));
   AddItem(@g_random_p       ,SizeOf(g_random_p       ));
   AddItem(@vid_cam_x        ,SizeOf(vid_cam_x        ));
   AddItem(@vid_cam_y        ,SizeOf(vid_cam_y        ));
   AddItem(@ui_blink_timer1 ,SizeOf(ui_blink_timer1 ));
   AddItem(@ui_blink_timer2 ,SizeOf(ui_blink_timer2 ));
   AddItem(@m_brush          ,SizeOf(m_brush          ));
   AddItem(@g_KeyPoints        ,SizeOf(g_KeyPoints        ));
   AddItem(@g_RoyalBattle_r        ,SizeOf(g_RoyalBattle_r        ));
   AddItem(@g_status         ,SizeOf(g_status         ));
   AddItem(@g_timer_UnitCycle    ,SizeOf(g_timer_UnitCycle    ));
   AddItem(@g_timer_UnitRegen    ,SizeOf(g_timer_UnitRegen    ));
   AddItem(@ui_alarms        ,SizeOf(ui_alarms        ));
   AddItem(@map_PlayerStartX ,SizeOf(map_PlayerStartX ));
   AddItem(@map_PlayerStartY ,SizeOf(map_PlayerStartY ));

   AddItem(@theme_cur_liquid_tas      ,SizeOf(theme_cur_liquid_tas      ));
   AddItem(@theme_cur_liquid_tasPeriod,SizeOf(theme_cur_liquid_tasPeriod));
   AddItem(@theme_cur_liquid_mmcolor  ,SizeOf(theme_cur_liquid_mmcolor  ));
   AddItem(@theme_cur_tile_terrain_id ,SizeOf(theme_cur_tile_terrain_id ));
   AddItem(@theme_cur_tile_crater_id  ,SizeOf(theme_cur_tile_crater_id  ));
   AddItem(@theme_cur_tile_liquid_id  ,SizeOf(theme_cur_tile_liquid_id  ));
end;

function saveload_Save(Check:boolean):boolean;
var f:file;
    i:integer;
begin
   saveload_Save:=false;

   if(not g_Started)
   or(length(svld_str_fname)=0)
   or(net_status>ns_single)
   or(rpls_rstate=rpls_state_read)then exit;

   saveload_Save:=true;
   if(Check)then exit;

   assign(f,str_f_svld+svld_str_fname+str_e_svld);
   {$I-}
   rewrite(f,1);
   {$I+}
   if(ioresult<>0)then exit;

   if(svld_itemn>0)then
    for i:=0 to svld_itemn-1 do
     with svld_items[i] do
      BlockWrite(f,data_p^,data_s);

   close(f);

   if(menu_state)then menu_Escape(true);

   saveload_MakeFolderList;

   GameLogChat(PlayerClient,log_to_all,str_msg_GameSaved,true);
end;


function saveload_Load(Check:boolean):boolean;
var f:file;
   fn:shortstring;
   vr:byte=0;
   u :integer;
begin
   saveload_Load:=false;

   if(svld_list_sel<0)or(svld_list_sel>=svld_list_size)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
  if(length(svld_list[svld_list_sel])>0)then
   if(FileExists(fn))then
   begin
      saveload_Load:=true;
      if(Check)then exit;

      assign(f,fn);
      {$I-}reset(f,1);{$I+}
      if(ioresult<>0)then exit;
      if(FileSize(f)<>svld_file_size)then begin close(f); exit; end;
      BlockRead(f,vr,SizeOf(g_version));
      if(vr=g_version)then
      begin
         GameDefaultAll;

         if(svld_itemn>1)then
          for u:=1 to svld_itemn-1 do
           with svld_items[u] do
            BlockRead(f,byte(data_p^),data_s);

         for u:=1 to MaxUnits do
           with g_units[u] do
           begin
              player:=@g_players[playeri];
              uid   :=@g_uids[uidi];
           end;

         PlayersValidateName;
         writeln('loadgame map make start');
         map_Make1Scirmish(true);
         map_Make2;
         GameCameraBounds;

         g_Started:=true;

         if(menu_state)then menu_Escape(true);

         menu_page1:=mp_scirmish;
      end;
      close(f);
   end;
end;

function saveload_Delete(Check:boolean):boolean;
var fn:shortstring;
begin
   saveload_Delete:=false;
   if(svld_list_sel<0)or(svld_list_sel>=svld_list_size)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
   if(FileExists(fn))then
   begin
      saveload_Delete:=true;
      if(Check)then exit;

      DeleteFile(fn);
      saveload_MakeFolderList;
   end;
end;




