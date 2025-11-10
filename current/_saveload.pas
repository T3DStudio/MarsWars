

procedure saveload_MenuSelectedInfo;
var f :file;
   fn :shortstring;
vbyte1:byte;
vint  :integer=0;
vcard :cardinal;
begin
   svld_str_info1:='';
   svld_str_info2:='';

   if(length(svld_str_fname)=0)then exit;

   fn:=folder_save+svld_str_fname+fileExt_save;

   if(not FileExists(fn))then
   begin
      svld_str_info1:=str_FileError_NExists;
      exit;
   end;
   assign(f,fn);
   {$I-}
   reset(f,1);
   {$I+}
   if(ioresult<>0)then
   begin
      svld_str_info1:=str_FileError_Open;
      close(f);
      exit;
   end;
   if(FileSize(f)<>svld_file_size)then
   begin
      svld_str_info1:=str_FileError_WData;
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
                       then svld_str_info1:=str_FileError_WVer
                       else
                       begin
                          BlockRead(f,vbyte1,sizeof(cmp_skill));
                          if(CMPMaxSkills<vbyte1)
                          then svld_str_info1:=str_FileError_WVer
                          else svld_str_info1:=str_camp_MissionName[vint]+tc_nl1+str_Camp_Difficulty+tc_nl1+str_Camp_DifficultyL[vbyte1];

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

                       if(not FileReadBaseGameInfo(f,@svld_str_info1,@svld_str_info2))then svld_str_info1:=str_FileError_WData;
                    end;
      else svld_str_info1:=str_FileError_WVer;
      end;
   end
   else svld_str_info1:=str_FileError_WVer;
   {$I+}
   if(IOResult<>0)then svld_str_info1:=str_FileError_WData;

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
      svld_str_info1:='';
      svld_str_info2:='';
   end;
end;

procedure saveload_MakeFolderList;
var Info:TSearchRec;
       s:shortstring;
begin
   svld_list_scroll:=0;
   svld_list_size  :=0;
   setlength(svld_list,0);
   if(FindFirst(folder_save+'*'+fileExt_save,faReadonly,info)=0)then
     repeat
        s:=info.Name;
        delete(s,length(s)-(length(fileExt_save)-1),length(fileExt_save));
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
   AddItem(@map_ObstaclesF      ,SizeOf(map_ObstaclesF   ));
   AddItem(@map_Symmetry        ,sizeof(map_Symmetry     ));
   AddItem(@theme_i             ,SizeOf(theme_i          ));
   AddItem(@LocalPlayer         ,SizeOf(LocalPlayer      ));
   AddItem(@g_tick              ,SizeOf(g_tick           ));
   for p:=0 to LastPlayer do
     with g_gplayers[p] do
     begin
        AddItem(@state   ,SizeOf(state   ));
        AddItem(@name    ,SizeOf(name    ));
        AddItem(@mrace   ,SizeOf(mrace   ));
        AddItem(@team    ,SizeOf(team    ));
        AddItem(@isobserver,SizeOf(isobserver));
     end;

   // other
   AddItem(@g_FixedPositions    ,SizeOf(g_FixedPositions   ));
   AddItem(@g_gplayers          ,SizeOf(TPList             ));
   AddItem(@g_units             ,SizeOf(g_units            ));
   AddItem(@g_missiles          ,SizeOf(g_missiles         ));
   AddItem(@g_effects           ,SizeOf(g_effects          ));
   AddItem(@g_random_i          ,SizeOf(g_random_i         ));
   AddItem(@g_random_p          ,SizeOf(g_random_p         ));
   AddItem(@g_KeyPoints         ,SizeOf(g_KeyPoints        ));
   AddItem(@g_royal_r           ,SizeOf(g_royal_r          ));
   AddItem(@g_status            ,SizeOf(g_status           ));
   AddItem(@g_cycle_order       ,SizeOf(g_cycle_order      ));
   AddItem(@g_cycle_regen       ,SizeOf(g_cycle_regen      ));
   AddItem(@map_ObstaclesL      ,SizeOf(map_ObstaclesL     ));
   AddItem(@map_PlayerStartX    ,SizeOf(map_PlayerStartX   ));
   AddItem(@map_PlayerStartY    ,SizeOf(map_PlayerStartY   ));
   AddItem(@ui_cam_x            ,SizeOf(ui_cam_x           ));
   AddItem(@ui_cam_y            ,SizeOf(ui_cam_y           ));
   AddItem(@ui_blink_timer1     ,SizeOf(ui_blink_timer1    ));
   AddItem(@ui_blink_timer2     ,SizeOf(ui_blink_timer2    ));
   AddItem(@ui_alarms           ,SizeOf(ui_alarms          ));
   AddItem(@PlayerColorsDefault ,SizeOf(PlayerColorsDefault));
   AddItem(@m_brush             ,SizeOf(m_brush            ));
end;

function saveload_Allowed:boolean;
begin
   saveload_Allowed:=false;

   if(net_status<>ns_none)
   or(rpls_pstate=rpls_read)then exit;

   saveload_Allowed:=true;
end;

procedure saveload_SaveWrite(fn:shortstring);
var f:file;
    i:integer;
begin
   fn:=folder_save+fn+fileExt_save;

   assign(f,fn);
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

   MenuBack(true,false);

   saveload_MakeFolderList;

   GameLogChat(LocalPlayer,log_to_all,str_gmsg_GameSaved);
end;

function saveload_Save(check:boolean):boolean;
begin
   saveload_Save:=false;

   if(not G_Started)
   or(not saveload_Allowed)
   or(length(svld_str_fname)=0)
   or(menu_msg_type<>mmbt_none)then exit;

   saveload_Save:=true;

   if(check)then exit;

   if(FileExists(folder_save+svld_str_fname+fileExt_save))
   then menu_msgBox_Set(str_FileSave+': '+str_FileReWrite,svld_str_fname,mmbt_SaveRewrite)
   else saveload_SaveWrite(svld_str_fname);
end;

function saveload_Load(check:boolean):boolean;
var f:file;
   fn:shortstring;
   vr:byte=0;
   u:integer;
begin
   saveload_Load:=false;

   if(not saveload_Allowed)
   or(length(svld_str_fname)=0)
   or(menu_msg_type<>mmbt_none)then exit;

   saveload_Load:=true;

   if(check)then exit;

   fn:=folder_save+svld_str_fname+fileExt_save;
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
              player:=@g_gplayers[playeri];
              uid   :=@g_uids[uidi];
           end;

         if(ioresult<>0)then
         begin
            GameDefaultAll;
            svld_str_info1:=str_FileError_Open;
            svld_str_info2:='';
            exit;
         end;

         map_BaseVars;
         case g_type of
         gt_campaing: SetThemeCampaing(cmp_sel);
         gt_scirmish: map_seed2theme;
         end;

         map_MakeThemeSprites;
         map_RefreshDoodadsCells;
         map_RedrawMenuMinimap;
         map_DoodadsDrawData;
         ui_Camera_Bounds;

         G_Started:=true;

         MenuBack(true,false);

         GameLogChat(LocalPlayer,log_to_all,str_gmsg_GameLoaded);
      end;
      close(f);
   end;
end;

procedure saveload_DeleteFile(fn:shortstring);
begin
   fn:=folder_save+fn+fileExt_save;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      if(svld_list_size>1)then
        if(svld_list_sel=(svld_list_size-1))then svld_list_sel-=1;
      saveload_MakeFolderList;
   end;
end;

function saveload_DeleteInit(check:boolean):boolean;
begin
   saveload_DeleteInit:=false;

   if(rpls_pstate<>rpls_none)
   or(length(svld_str_fname)=0)
   or(menu_msg_type<>mmbt_none)then exit;

   saveload_DeleteInit:=true;

   if(check)then exit;

   menu_msgBox_Set(str_FileDelete,svld_str_fname,mmbt_DeleteSave);
end;

