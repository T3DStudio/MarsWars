

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
      BlockRead(f,vr,SizeOf(ver));
      if(vr=ver)then
      begin
         BlockRead(f,vr,sizeof(menu_s2));
         if(vr=ms2_camp)then
         begin
            BlockRead(f,vr,sizeof(cmp_sel));
            if(0<=vr)and(vr<=LastMission)then
            begin
               svld_str_info:=str_camp_name[vr];
               vr:=0;
               BlockRead(f,vr,sizeof(cmp_skill));
               if(0<=vr)and(vr<=CMPMaxSkills)then
               begin
                  svld_str_info+=tc_nl1+str_cmpdif+tc_nl1+str_cmpd[vr];
                  BlockRead(f,vr,sizeof(cmp_data_b1));
                  BlockRead(f,vr,sizeof(cmp_data_b2));
                  BlockRead(f,vr,sizeof(cmp_data_b3));
                  BlockRead(f,vr,sizeof(cmp_data_c1));
               end
               else svld_str_info:=str_svld_errors_wver;
            end
            else svld_str_info:=str_svld_errors_wver;
         end
         else
         begin
            BlockRead(f,vr,sizeof(cmp_sel     ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_skill   ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_data_b1 ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_data_b2 ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_data_b3 ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_data_c1 ));vr:=0;

            BlockRead(f,ms,sizeof(map_seed    ));svld_str_info:=str_map+': '+c2s(ms)+tc_nl3+' ';
            BlockRead(f,vr,sizeof(map_iseed   ));vr:=0;
            BlockRead(f,mw,sizeof(map_mw      ));svld_str_info+=str_m_siz+w2s(mw)+tc_nl3+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_obs     ));
            if(vr>7)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end
                    else       svld_str_info+=str_m_obs+_str_mx(vr)+tc_nl3+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_symmetry));svld_str_info+=str_m_sym+b2cc[vr>0]+tc_nl3+' ';mw:=0;
            BlockRead(f,vr,sizeof(theme_i     ));
            if(vr>=theme_n)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end;  vr:=0;
            BlockRead(f,vr,sizeof(g_mode      ));
            if not(vr in allgamemodes)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end
                                      else       svld_str_info+=str_gmode[vr  ]+tc_nl3+tc_default;

            vr:=0;
            BlockRead(f,vr,sizeof(g_fixed_positions));vr:=0;
            BlockRead(f,vr,sizeof(g_generators    ));vr:=0;

            BlockRead(f,hp,sizeof(HPlayer  ));

            BlockRead(f,pls,SizeOf(TPList));

            for vr:=1 to MaxPlayers do
            begin
               if(vr=hp)
               then svld_str_info+=chr(vr)+'*'+tc_default
               else svld_str_info+=chr(vr)+'#'+tc_default;

               if(pls[vr].state>PS_None)then
                 if(pls[vr].team=0)
                 then svld_str_info+=str_observer[1]           +','+t2c(pls[vr].team)+','
                 else svld_str_info+=str_race[pls[vr].mrace][2]+','+t2c(pls[vr].team)+',';
               svld_str_info+=pls[vr].name+tc_nl3
            end;
         end;
      end
      else svld_str_info:=str_svld_errors_wver;
      close(f);
   end
   else svld_str_info:=str_svld_errors_file;
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
   SizeOf(ver              )+
   SizeOf(menu_s2          )+
   SizeOf(cmp_sel          )+
   SizeOf(cmp_skill        )+
   SizeOf(cmp_data_b1      )+
   SizeOf(cmp_data_b2      )+
   SizeOf(cmp_data_b3      )+
   SizeOf(cmp_data_c1      )+
   SizeOf(map_seed         )+
   SizeOf(map_iseed        )+
   SizeOf(map_mw           )+
   SizeOf(map_obs          )+
   SizeOf(theme_i          )+
   SizeOf(g_mode           )+
   SizeOf(g_fixed_positions)+
   SizeOf(g_generators     )+
   SizeOf(HPlayer          )+
   SizeOf(TPList           )+
   SizeOf(g_units          )+
   SizeOf(g_missiles       )+
   SizeOf(g_effects         )+
   SizeOf(map_dds          )+
   SizeOf(vid_cam_x        )+
   SizeOf(vid_cam_y        )+
   SizeOf(PlayerColor      )+
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
   SizeOf(map_psx          )+
   SizeOf(map_psy          )+
   SizeOf(map_rpos         )+
   SizeOf(theme_map_lqt    )+
   SizeOf(theme_map_blqt   )+
   SizeOf(theme_map_trt    )+
   SizeOf(theme_map_crt    )+1;
end;

function saveload_Save(check:boolean):boolean;
var f:file;
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

   BlockWrite(f,ver              ,SizeOf(ver              ));
   BlockWrite(f,menu_s2          ,SizeOf(menu_s2          ));
   BlockWrite(f,cmp_sel          ,SizeOf(cmp_sel          ));
   BlockWrite(f,cmp_skill        ,SizeOf(cmp_skill        ));
   BlockWrite(f,cmp_data_b1      ,sizeof(cmp_data_b1      ));
   BlockWrite(f,cmp_data_b2      ,sizeof(cmp_data_b2      ));
   BlockWrite(f,cmp_data_b3      ,sizeof(cmp_data_b3      ));
   BlockWrite(f,cmp_data_c1      ,sizeof(cmp_data_c1      ));
   BlockWrite(f,map_seed         ,SizeOf(map_seed         ));
   BlockWrite(f,map_iseed        ,SizeOf(map_iseed        ));
   BlockWrite(f,map_mw           ,SizeOf(map_mw           ));
   BlockWrite(f,map_obs          ,SizeOf(map_obs          ));
   BlockWrite(f,map_symmetry     ,sizeof(map_symmetry     ));
   BlockWrite(f,theme_i          ,SizeOf(theme_i          ));
   BlockWrite(f,g_mode           ,SizeOf(g_mode           ));
   BlockWrite(f,g_fixed_positions,SizeOf(g_fixed_positions));
   BlockWrite(f,g_generators     ,SizeOf(g_generators     ));
   BlockWrite(f,HPlayer          ,SizeOf(HPlayer          ));
   BlockWrite(f,g_players        ,SizeOf(TPList           ));
   BlockWrite(f,g_units          ,SizeOf(g_units          ));
   BlockWrite(f,g_missiles       ,SizeOf(g_missiles       ));
   BlockWrite(f,g_effects        ,SizeOf(g_effects        ));
   BlockWrite(f,map_dds          ,SizeOf(map_dds          ));
   BlockWrite(f,vid_cam_x        ,SizeOf(vid_cam_x        ));
   BlockWrite(f,vid_cam_y        ,SizeOf(vid_cam_y        ));
   BlockWrite(f,PlayerColor      ,SizeOf(PlayerColor      ));
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
   BlockWrite(f,map_psx          ,SizeOf(map_psx          ));
   BlockWrite(f,map_psy          ,SizeOf(map_psy          ));
   BlockWrite(f,map_rpos         ,SizeOf(map_rpos         ));
   BlockWrite(f,theme_map_lqt    ,SizeOf(theme_map_lqt    ));
   BlockWrite(f,theme_map_blqt   ,SizeOf(theme_map_blqt   ));
   BlockWrite(f,theme_map_trt    ,SizeOf(theme_map_trt    ));
   BlockWrite(f,theme_map_crt    ,SizeOf(theme_map_crt    ));

   close(f);

   if(MainMenu)
   then ToggleMenu;

   saveload_MakeFolderList;

   GameLogChat(HPlayer,log_to_all,str_gsaved,true);
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
   or(not menu_SaveLoadTab)then exit;

   saveload_Load:=true;

   if(check)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
  if(length(svld_list[svld_list_sel])>0)then
   if(FileExists(fn))then
   begin
      assign(f,fn);
      {$I-}reset(f,1);{$I+} if (ioresult<>0) then exit;
      if(FileSize(f)<>svld_file_size)then begin close(f); exit; end;
      BlockRead(f,vr,SizeOf(ver));
      if(vr=ver)then
      begin
         GameDefaultAll;

         BlockRead(f,menu_s2          ,SizeOf(menu_s2          ));
         BlockRead(f,cmp_sel          ,SizeOf(cmp_sel          ));
         BlockRead(f,cmp_skill        ,SizeOf(cmp_skill        ));
         BlockRead(f,cmp_data_b1      ,sizeof(cmp_data_b1      ));
         BlockRead(f,cmp_data_b2      ,sizeof(cmp_data_b2      ));
         BlockRead(f,cmp_data_b3      ,sizeof(cmp_data_b3      ));
         BlockRead(f,cmp_data_c1      ,sizeof(cmp_data_c1      ));
         BlockRead(f,map_seed         ,SizeOf(map_seed         ));
         BlockRead(f,map_iseed        ,SizeOf(map_iseed        ));
         BlockRead(f,map_mw           ,SizeOf(map_mw           ));
         BlockRead(f,map_obs          ,SizeOf(map_obs          ));
         BlockRead(f,map_symmetry     ,sizeof(map_symmetry     ));
         BlockRead(f,theme_i          ,SizeOf(theme_i          ));map_seed2theme;
         BlockRead(f,g_mode           ,SizeOf(g_mode           ));
         BlockRead(f,g_fixed_positions,SizeOf(g_fixed_positions));
         BlockRead(f,g_generators     ,SizeOf(g_generators     ));
         BlockRead(f,HPlayer          ,SizeOf(HPlayer          ));
         BlockRead(f,g_players        ,SizeOf(TPList           ));
         BlockRead(f,g_units          ,SizeOf(g_units          ));
         BlockRead(f,g_missiles       ,SizeOf(g_missiles       ));
         BlockRead(f,g_effects        ,SizeOf(g_effects        ));
         BlockRead(f,map_dds          ,SizeOf(map_dds          ));
         BlockRead(f,vid_cam_x        ,SizeOf(vid_cam_x        ));
         BlockRead(f,vid_cam_y        ,SizeOf(vid_cam_y        ));
         BlockRead(f,PlayerColor      ,SizeOf(PlayerColor      ));
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
         BlockRead(f,map_psx          ,SizeOf(map_psx          ));
         BlockRead(f,map_psy          ,SizeOf(map_psy          ));
         BlockRead(f,map_rpos         ,SizeOf(map_rpos         ));
         BlockRead(f,theme_map_lqt    ,SizeOf(theme_map_lqt    ));
         BlockRead(f,theme_map_blqt   ,SizeOf(theme_map_blqt   ));
         BlockRead(f,theme_map_trt    ,SizeOf(theme_map_trt    ));
         BlockRead(f,theme_map_crt    ,SizeOf(theme_map_crt    ));

         for u:=1 to MaxUnits do
          with g_units[u] do
          begin
             player:=@g_players[playeri];
             uid   :=@g_uids[uidi];
          end;

         cmp_minfo_lpage:=str_camp_infon[cmp_sel] div vid_campi_scrlstep;

         map_vars;
         if(menu_s2=ms2_camp)then SetThemeCampaing(cmp_sel);

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
   or(not menu_SaveLoadTab)then exit;

   saveload_Delete:=true;

   if(check)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      saveload_MakeFolderList;
   end;
end;




