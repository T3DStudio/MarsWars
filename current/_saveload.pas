

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
            BlockRead(f,vr,sizeof(_cmp_sel));
            if(0<=vr)and(vr<=MaxMissions)then
            begin
               svld_str_info:='';//str_camp_t[vr];
               BlockRead(f,vr,sizeof(cmp_skill));
               if(0<=vr)and(vr<=CMPMaxSkills)
               then svld_str_info+=tc_nl1+str_cmpdif+tc_nl1+str_cmpd[vr]
               else svld_str_info:=str_svld_errors_wver;
            end
            else svld_str_info:=str_svld_errors_wver;
         end
         else
         begin
            BlockRead(f,vr,sizeof(_cmp_sel ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_skill));vr:=0;

            BlockRead(f,ms,sizeof(map_seed ));svld_str_info:=str_map+': '+c2s(ms)+tc_nl3+' ';
            BlockRead(f,vr,sizeof(map_iseed));vr:=0;
            BlockRead(f,mw,sizeof(map_mw   ));svld_str_info+=str_m_siz+w2s(mw)+tc_nl3+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_liq  ));
            if(vr>7)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end
                    else       svld_str_info+=str_m_liq+_str_mx(vr)+tc_nl3+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_obs  ));
            if(vr>7)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end
                    else       svld_str_info+=str_m_obs+_str_mx(vr)+tc_nl3+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_symmetry));   ////////
            BlockRead(f,vr,sizeof(theme_i     ));
            if(vr>=theme_n)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end;  vr:=0;
            BlockRead(f,vr,sizeof(g_mode   ));
            if not(vr in allgamemodes)then begin svld_str_info:=str_svld_errors_wver;close(f);exit; end
                                      else       svld_str_info+=str_gmode[vr  ]+tc_nl3+tc_default;

            vr:=0;
            BlockRead(f,vr,sizeof(g_start_base     ));vr:=0;
            BlockRead(f,vr,sizeof(g_fixed_positions));vr:=0;
            BlockRead(f,vr,sizeof(g_cgenerators    ));vr:=0;

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

{
ver
menu_s2
_cmp_sel
cmp_skill
map_seed
map_iseed
map_mw
map_lqt
map_obs
map_sym
theme_i
g_mode
g_starta
g_sstart
PlayerHuman
_players
_units
_missiles
_effects
map_dds
vid_vx
vid_vy
PlayerColor
G_Step
vid_rtui
m_sbuild
g_inv_wn
g_inv_t
g_inv_wt
g_ct_pl
g_royal_r
G_Status
ai_bx
ai_by
_uclord_c
_uregen_c
team_army
ui_alrms
map_psx
map_psy
map_rpos
theme_map_lqt
theme_map_blqt
theme_map_trt
theme_map_crt
}

procedure saveload_CalcSaveSize;
begin
   svld_file_size:=
   SizeOf(ver              )+
   SizeOf(menu_s2          )+
   SizeOf(_cmp_sel         )+
   SizeOf(cmp_skill        )+
   SizeOf(map_seed         )+
   SizeOf(map_iseed        )+
   SizeOf(map_mw           )+
   SizeOf(map_liq          )+
   SizeOf(map_obs          )+
   SizeOf(theme_i          )+
   SizeOf(g_mode           )+
   SizeOf(g_start_base     )+
   SizeOf(g_fixed_positions)+
   SizeOf(g_cgenerators    )+
   SizeOf(HPlayer          )+
   SizeOf(TPList           )+
   SizeOf(_units           )+
   SizeOf(_missiles        )+
   SizeOf(_effects         )+
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
   SizeOf(_cycle_order     )+
   SizeOf(_cycle_regen     )+
   SizeOf(ui_alarms        )+
   SizeOf(map_psx          )+
   SizeOf(map_psy          )+
   SizeOf(map_rpos         )+
   SizeOf(theme_map_lqt    )+
   SizeOf(theme_map_blqt   )+
   SizeOf(theme_map_trt    )+
   SizeOf(theme_map_crt    )+1;
end;

procedure saveload_Save;
var f:file;
begin
   assign(f,str_f_svld+svld_str_fname+str_e_svld);
   {$I-}
   rewrite(f,1);
   {$I+}
   if(ioresult<>0)then exit;

   BlockWrite(f,ver              ,SizeOf(ver              ));
   BlockWrite(f,menu_s2          ,SizeOf(menu_s2          ));
   BlockWrite(f,_cmp_sel         ,SizeOf(_cmp_sel         ));
   BlockWrite(f,cmp_skill        ,SizeOf(cmp_skill        ));
   BlockWrite(f,map_seed         ,SizeOf(map_seed         ));
   BlockWrite(f,map_iseed        ,SizeOf(map_iseed        ));
   BlockWrite(f,map_mw           ,SizeOf(map_mw           ));
   BlockWrite(f,map_liq          ,SizeOf(map_liq          ));
   BlockWrite(f,map_obs          ,SizeOf(map_obs          ));
   BlockWrite(f,map_symmetry     ,sizeof(map_symmetry     ));
   BlockWrite(f,theme_i          ,SizeOf(theme_i          ));
   BlockWrite(f,g_mode           ,SizeOf(g_mode           ));
   BlockWrite(f,g_start_base     ,SizeOf(g_start_base     ));
   BlockWrite(f,g_fixed_positions,SizeOf(g_fixed_positions));
   BlockWrite(f,g_cgenerators    ,SizeOf(g_cgenerators    ));
   BlockWrite(f,HPlayer          ,SizeOf(HPlayer          ));
   BlockWrite(f,_players         ,SizeOf(TPList           ));
   BlockWrite(f,_units           ,SizeOf(_units           ));
   BlockWrite(f,_missiles        ,SizeOf(_missiles        ));
   BlockWrite(f,_effects         ,SizeOf(_effects         ));
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
   BlockWrite(f,_cycle_order     ,SizeOf(_cycle_order     ));
   BlockWrite(f,_cycle_regen     ,SizeOf(_cycle_regen     ));
   BlockWrite(f,ui_alarms        ,SizeOf(ui_alarms        ));
   BlockWrite(f,map_psx          ,SizeOf(map_psx          ));
   BlockWrite(f,map_psy          ,SizeOf(map_psy          ));
   BlockWrite(f,map_rpos         ,SizeOf(map_rpos         ));
   BlockWrite(f,theme_map_lqt    ,SizeOf(theme_map_lqt    ));
   BlockWrite(f,theme_map_blqt   ,SizeOf(theme_map_blqt   ));
   BlockWrite(f,theme_map_trt    ,SizeOf(theme_map_trt    ));
   BlockWrite(f,theme_map_crt    ,SizeOf(theme_map_crt    ));

   close(f);

   if(_menu)
   then ToggleMenu;

   saveload_MakeFolderList;

   GameLogChat(HPlayer,log_to_all,str_gsaved,true);
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
      BlockRead(f,vr,SizeOf(ver));
      if(vr=ver)then
      begin
         GameDefaultAll;

         BlockRead(f,menu_s2          ,SizeOf(menu_s2          ));
         BlockRead(f,_cmp_sel         ,SizeOf(_cmp_sel         ));
         BlockRead(f,cmp_skill        ,SizeOf(cmp_skill        ));
         BlockRead(f,map_seed         ,SizeOf(map_seed         ));
         BlockRead(f,map_iseed        ,SizeOf(map_iseed        ));
         BlockRead(f,map_mw           ,SizeOf(map_mw           ));
         BlockRead(f,map_liq          ,SizeOf(map_liq          ));
         BlockRead(f,map_obs          ,SizeOf(map_obs          ));
         BlockRead(f,map_symmetry     ,sizeof(map_symmetry     ));
         BlockRead(f,theme_i          ,SizeOf(theme_i          ));map_seed2theme;
         BlockRead(f,g_mode           ,SizeOf(g_mode           ));
         BlockRead(f,g_start_base     ,SizeOf(g_start_base     ));
         BlockRead(f,g_fixed_positions,SizeOf(g_fixed_positions));
         BlockRead(f,g_cgenerators    ,SizeOf(g_cgenerators    ));
         BlockRead(f,HPlayer          ,SizeOf(HPlayer          ));
         BlockRead(f,_players         ,SizeOf(TPList           ));
         BlockRead(f,_units           ,SizeOf(_units           ));
         BlockRead(f,_missiles        ,SizeOf(_missiles        ));
         BlockRead(f,_effects         ,SizeOf(_effects         ));
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
         BlockRead(f,_cycle_order     ,SizeOf(_cycle_order     ));
         BlockRead(f,_cycle_regen     ,SizeOf(_cycle_regen     ));
         BlockRead(f,ui_alarms        ,SizeOf(ui_alarms        ));
         BlockRead(f,map_psx          ,SizeOf(map_psx          ));
         BlockRead(f,map_psy          ,SizeOf(map_psy          ));
         BlockRead(f,map_rpos         ,SizeOf(map_rpos         ));
         BlockRead(f,theme_map_lqt    ,SizeOf(theme_map_lqt    ));
         BlockRead(f,theme_map_blqt   ,SizeOf(theme_map_blqt   ));
         BlockRead(f,theme_map_trt    ,SizeOf(theme_map_trt    ));
         BlockRead(f,theme_map_crt    ,SizeOf(theme_map_crt    ));

         for u:=1 to MaxUnits do
          with _units[u] do
          begin
             player:=@_players[playeri];
             uid   :=@_uids[uidi];
          end;

         map_vars;
         map_MakeThemeSprites;
         map_RefreshDoodadsCells;
         map_RedrawMenuMinimap;
         map_DoodadsDrawData;
         pf_make_grid;
         CamBounds;

         G_Started:=true;

         if(_menu)
         then ToggleMenu;
      end;
      close(f);
   end;
end;

procedure saveload_Delete;
var fn:string;
begin
   if(svld_list_sel<0)or(svld_list_sel>=svld_list_size)then exit;

   fn:=str_f_svld+svld_list[svld_list_sel]+str_e_svld;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      saveload_MakeFolderList;
   end;
end;




