

procedure saveload_MenuSelectedInfo;
var f :file;
   fn :shortstring;
vbyte1:byte;
vint  :integer=0;
vcard :cardinal;
begin
   svld_str_info:='';

   if(length(svld_str_fname)=0)then exit;

   fn:=str_f_svld+svld_str_fname+str_e_svld;

   if(not FileExists(fn))then
   begin
      svld_str_info:=str_svld_errors_file;
      exit;
   end;
   assign(f,fn);
   {$I-}
   reset(f,1);
   {$I+}
   if(ioresult<>0)then
   begin
      svld_str_info:=str_svld_errors_open;
      close(f);
      exit;
   end;
   if(FileSize(f)<>svld_file_size)then
   begin
      svld_str_info:=str_svld_errors_wdata;
      close(f);
      exit;
   end;

   vcard :=0;
   vbyte1:=255;
   {$I-}
   BlockRead(f,vbyte1,SizeOf(g_version));
   if(vbyte1=g_version)then
   begin
      vbyte1:=255;
      BlockRead(f,vbyte1,sizeof(g_type));
      case vbyte1 of
      gt_campaing : begin
                       vbyte1:=255;
                       vint  :=-1;
                       BlockRead(f,vint,sizeof(cmp_sel));

                       if(vint<0)
                       or(LastMission<vint)
                       then svld_str_info:=str_svld_errors_wver
                       else
                       begin
                          BlockRead(f,vbyte1,sizeof(cmp_skill));
                          if(CMPMaxSkills<vbyte1)
                          then svld_str_info:=str_svld_errors_wver
                          else svld_str_info:=str_camp_MissionName[vint]+tc_nl1+str_Camp_Difficulty+tc_nl1+str_Camp_DifficultyL[vbyte1];

                          BlockRead(f,vbyte1,sizeof(cmp_data_b1));
                          BlockRead(f,vbyte1,sizeof(cmp_data_b2));
                          BlockRead(f,vbyte1,sizeof(cmp_data_b3));
                          BlockRead(f,vcard ,sizeof(cmp_data_c1));
                       end;

                    end;
      gt_scirmish : begin
                       BlockRead(f,vint  ,sizeof(cmp_sel    ));
                       BlockRead(f,vbyte1,sizeof(cmp_skill  ));
                       BlockRead(f,vbyte1,sizeof(cmp_data_b1));
                       BlockRead(f,vbyte1,sizeof(cmp_data_b2));
                       BlockRead(f,vbyte1,sizeof(cmp_data_b3));
                       BlockRead(f,vcard ,sizeof(cmp_data_c1));

                       if(not FileReadBaseGameInfo(f,@svld_str_info))then svld_str_info:=str_svld_errors_wdata;
                    end;
      else svld_str_info:=str_svld_errors_wver;
      end;
   end
   else svld_str_info:=str_svld_errors_wver;
   {$I+}
   if(IOResult<>0)then svld_str_info:=str_svld_errors_wdata;

   close(f);
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
var Info:TSearchRec;
       s:shortstring;
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

procedure saveload_MakeSaveData;
var p:byte;
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
   AddItem(@g_version           ,SizeOf(g_version        ));
   AddItem(@g_type              ,SizeOf(g_type           ));
   AddItem(@cmp_sel             ,SizeOf(cmp_sel          ));
   AddItem(@cmp_skill           ,SizeOf(cmp_skill        ));
   AddItem(@cmp_data_b1         ,sizeof(cmp_data_b1      ));
   AddItem(@cmp_data_b2         ,sizeof(cmp_data_b2      ));
   AddItem(@cmp_data_b3         ,sizeof(cmp_data_b3      ));
   AddItem(@cmp_data_c1         ,sizeof(cmp_data_c1      ));
   AddItem(@map_scenario        ,SizeOf(map_scenario     ));
   AddItem(@map_generators      ,SizeOf(map_generators   ));
   AddItem(@map_seed            ,SizeOf(map_seed         ));
   AddItem(@map_Size            ,SizeOf(map_Size         ));
   AddItem(@map_Obstacles       ,SizeOf(map_Obstacles    ));
   AddItem(@map_Symmetry        ,sizeof(map_Symmetry     ));
   AddItem(@theme_i             ,SizeOf(theme_i          ));
   AddItem(@LocalPlayer         ,SizeOf(LocalPlayer      ));
   AddItem(@G_Step              ,SizeOf(G_Step           ));
   for p:=1 to MaxPlayers do
     with g_players[p] do
     begin
        AddItem(@state,SizeOf(state));
        AddItem(@name ,SizeOf(name ));
        AddItem(@mrace,SizeOf(mrace));
        AddItem(@team ,SizeOf(team ));
     end;

   // other
   AddItem(@g_FixedPositions    ,SizeOf(g_FixedPositions ));
   AddItem(@g_players           ,SizeOf(TPList           ));
   AddItem(@g_units             ,SizeOf(g_units          ));
   AddItem(@g_missiles          ,SizeOf(g_missiles       ));
   AddItem(@g_effects           ,SizeOf(g_effects        ));
   AddItem(@g_random_i          ,SizeOf(g_random_i       ));
   AddItem(@g_random_p          ,SizeOf(g_random_p       ));
   AddItem(@g_inv_wave_n        ,SizeOf(g_inv_wave_n     ));
   AddItem(@g_inv_wave_t_next   ,SizeOf(g_inv_wave_t_next));
   AddItem(@g_inv_wave_t_curr   ,SizeOf(g_inv_wave_t_curr));
   AddItem(@g_KeyPoints         ,SizeOf(g_KeyPoints      ));
   AddItem(@g_royal_r           ,SizeOf(g_royal_r        ));
   AddItem(@g_status            ,SizeOf(g_status         ));
   AddItem(@g_cycle_order       ,SizeOf(g_cycle_order    ));
   AddItem(@g_cycle_regen       ,SizeOf(g_cycle_regen    ));
   AddItem(@map_dds             ,SizeOf(map_dds          ));
   AddItem(@map_psx             ,SizeOf(map_psx          ));
   AddItem(@map_psy             ,SizeOf(map_psy          ));
   AddItem(@ui_cam_x            ,SizeOf(ui_cam_x         ));
   AddItem(@ui_cam_y            ,SizeOf(ui_cam_y         ));
   AddItem(@ui_blink_timer1     ,SizeOf(ui_blink_timer1  ));
   AddItem(@ui_blink_timer2     ,SizeOf(ui_blink_timer2  ));
   AddItem(@ui_alarms           ,SizeOf(ui_alarms        ));
   AddItem(@PlayerColors        ,SizeOf(PlayerColors     ));
   AddItem(@m_brush             ,SizeOf(m_brush          ));
   AddItem(@theme_map_Liquid    ,SizeOf(theme_map_Liquid    ));
   AddItem(@theme_map_LiquidBack,SizeOf(theme_map_LiquidBack));
   AddItem(@theme_map_Terrain   ,SizeOf(theme_map_Terrain   ));
   AddItem(@theme_map_Crater    ,SizeOf(theme_map_Crater    ));
end;

function saveload_Save(check:boolean):boolean;
var f:file;
    i:integer;
begin
   saveload_Save:=false;

   if(not G_Started)
   or(net_status<>ns_none)
   or(length(svld_str_fname)=0)
   or(not menu_SaveLoadTab)then exit;

   saveload_Save:=true;

   if(check)then exit;

   assign(f,str_f_svld+svld_str_fname+str_e_svld);
   {$I-}
   rewrite(f,1);
   {$I+}
   if(ioresult<>0)then exit;

   {$I-}
   if(svld_itemn>0)then
    for i:=0 to svld_itemn-1 do
     with svld_items[i] do
      BlockWrite(f,data_p^,data_s);
   {$I+}

   close(f);

   if(MainMenu)
   then ToggleMenu;

   saveload_MakeFolderList;

   GameLogChat(LocalPlayer,log_to_all,str_gsaved,true);
end;


function saveload_Load(check:boolean):boolean;
var f:file;
   fn:shortstring;
   vr:byte=0;
   u:integer;
begin
   saveload_Load:=false;

   if(svld_list_sel<0)
   or(svld_list_sel>=svld_list_size)
   or(length(svld_str_fname)=0)
   or(not menu_SaveLoadTab)then exit;

   saveload_Load:=true;

   if(check)then exit;

   fn:=str_f_svld+svld_str_fname+str_e_svld;
   if(FileExists(fn))then
   begin
      assign(f,fn);
      {$I-}
      reset(f,1);
      {$I+}
      if(ioresult<>0)then exit;
      if(FileSize(f)<>svld_file_size)then
      begin
         close(f);
         exit;
      end;
      {$I-}
      BlockRead(f,vr,SizeOf(g_version));
      {$I+}
      if(vr=g_version)then
      begin
         GameDefaultAll;

         {$I-}
         if(svld_itemn>1)then
          for u:=1 to svld_itemn-1 do
           with svld_items[u] do
            BlockRead(f,byte(data_p^),data_s);
         {$I+}

         for u:=1 to MaxUnits do
          with g_units[u] do
          begin
             player:=@g_players[playeri];
             uid   :=@g_uids[uidi];
          end;

         if(ioresult<>0)then
         begin
            GameDefaultAll;
            svld_str_info:=str_svld_errors_open;
            exit;
         end;

         map_vars;
         if(g_type=gt_campaing)then SetThemeCampaing(cmp_sel);

         map_MakeThemeSprites;
         map_RefreshDoodadsCells;
         map_RedrawMenuMinimap;
         map_DoodadsDrawData;
         pf_MakeZoneGrid;
         CameraBounds;

         G_Started:=true;

         if(MainMenu)
         then ToggleMenu;
      end;
      close(f);
   end;
end;

function saveload_Delete(check:boolean):boolean;
var fn:shortstring;
begin
   saveload_Delete:=false;

   if(svld_list_sel<0)
   or(svld_list_sel>=svld_list_size)
   or(length(svld_str_fname)=0)
   or(not menu_SaveLoadTab)then exit;

   saveload_Delete:=true;

   if(check)then exit;

   fn:=str_f_svld+svld_str_fname+str_e_svld;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      saveload_MakeFolderList;
   end;
end;




