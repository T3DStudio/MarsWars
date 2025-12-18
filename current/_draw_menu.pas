
////////////////////////////////////////////////////////////////////////////////
//
//   MENU COMMON
//

function mic(enabled,selected:boolean):cardinal;
begin
   mic:=c_white;
   if(not enabled)
   then mic:=c_gray
   else
     if(selected)then mic:=c_yellow;
end;

function vc(mi:byte):char;
begin
   vc:=chat_type[menu_ItemSelected<>mi];
end;

procedure vid_MakeBigMenu;
var
cx,cy:single;
begin
   if(menu_SurfaceSC<>nil)and(menu_SurfaceSC<>menu_Surface)then sdl_FreeSurface(menu_SurfaceSC);

   if(menu_scale)then
   begin
      cx:=vid_vw/menu_Surface^.w;
      cy:=vid_vh/menu_Surface^.h;
      if(cx>cy)
      then menu_sc_cx:=cy
      else menu_sc_cx:=cx;
      menu_SurfaceSC :=zoomSurface(menu_Surface,menu_sc_cx,menu_sc_cx,byte(menu_ScaleSmooth));
      menu_sc_cx:=1/menu_sc_cx;
   end
   else
   begin
      menu_sc_cx:=1;
      menu_SurfaceSC  :=menu_Surface;
   end;

  // menu_sc_hw:=menu_SurfaceSC^.w div 2;
   //menu_sc_hh:=menu_SurfaceSC^.h div 2;
   menu_sc_x:=(vid_vw-menu_SurfaceSC^.w) div 2;
   menu_sc_y:=(vid_vh-menu_SurfaceSC^.h) div 2;
end;

procedure d_MenuItemPanel(tar:pSDL_Surface;mi,border:byte);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        boxColor(tar,mi_x0,mi_y0,mi_x1,mi_y1,c_black);
        draw_rectw(tar,mi_x0+1,mi_y0+1,mi_x1-1,mi_y1-1,border,-1,c_ltgray);
     end;
end;

procedure d_MenuItemCaption(tar:pSDL_Surface;mi:byte;text:shortstring;docCaption:boolean=false);
var color:cardinal;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        case mi_state of
        as_disabled: color:=c_gray;
        as_enabled : color:=c_white;
        end;

        if(not docCaption)then
        begin
           rectangleColor(tar,mi_xc-menu_ItemCaptionhW,mi_y0,
                              mi_xc+menu_ItemCaptionhW,mi_y0+menu_BigButtonhH,c_ltgray);
           draw_text(tar,mi_xc,mi_y0+font_wh ,text,ta_MU,255,color);
        end
        else draw_text(tar,mi_x0,mi_y0-font_wq,text,ta_LB,255,color);
     end;
end;

procedure d_menu_ScrollBar(tar:pSDL_Surface;mi:byte;scrolli,listH,listSize:integer;reverse:boolean=false);
var posCY,
    barh:integer;
begin
   with menu_items[mi] do
   begin
      barh :=(mi_y1-mi_y0);
      if(listH<listSize)then
      begin
         barh :=mm3i(1,round((mi_y1-mi_y0)*(listH/listSize)),barh);
         if(reverse)
         then posCY:=mi_y1-round((mi_y1-mi_y0-barh)*(scrolli/(listSize-listH)))-barh
         else posCY:=mi_y0+round((mi_y1-mi_y0-barh)*(scrolli/(listSize-listH)));
      end
      else posCY:=mi_y0;

      boxColor(tar,mi_x0+1,posCY,mi_x0+2,posCY+barh,c_lime);
   end;
end;
procedure d_MenuItemList(tar:pSDL_Surface;mi:byte;plist:PTStringArray;listSize:integer;scroll,selected,lineH,lineWChars,listH:integer;docText:boolean=false);
var
t,i,y:integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)and(listH>0)then
     begin
        if(lineWChars<0)then lineWChars:=mi_charw;
        for t:=0 to listH-1 do
        begin
           i:=t+scroll;
           if(0<=i)and(i<listSize)then
           begin
              y:=mi_y0+t*lineH;

              if(docText)
              then draw_text(tar,mi_x0+font_wh,y+font_wh,plist^[i],ta_LU,mi_charw,c_white)
              else
              begin
                 if(i=selected)then
                   boxColor(tar,mi_x0+1,y+1,mi_x1-1,y+lineH-2,c_dgray);

                 draw_text(tar,mi_x0+font_wh,y+font_wh,str_CutEnd(b2s(i+1)+'] '+plist^[i],lineWChars),ta_LU,mi_charw,mic(mi_state=as_enabled,i=selected));

                 if(mi_y0<y)then
                 hlineColor(tar,mi_x0+1,mi_x1-1,y,c_gray);

                 y+=lineH-1;
                 if(y<mi_y1)then
                 hlineColor(tar,mi_x0+1,mi_x1-1,y,c_gray);
              end;
           end;
        end;

        d_menu_ScrollBar(tar,mi,scroll,listH,listSize);
     end;
end;

procedure d_menuMultiplayerChat(tar:pSDL_Surface;mi:byte);
var
i,y:integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        d_menu_ScrollBar(tar,mi,menu_ChatScroll,menu_ChatListH,menu_ChatSize,true);
        MakeLogListForDraw(LocalPlayer,mi_charw,menu_ChatListH,menu_ChatScroll,lmts_menu_chat);
        y:=mi_y1-font_wh-font_wq;
        if(ui_log_n>0)then
          for i:=0 to ui_log_n-1 do
            if(ui_log_color[i]>0)then
            begin
               draw_text(tar,mi_x0+font_wq,y,ui_log_lines[i],ta_LB,255,ui_log_color[i]);
               y-=txt_line_h1;
            end;
     end;
end;

procedure d_MenuItemInfo(tar:pSDL_Surface;mi:byte;text1,text2:shortstring);
var
color:cardinal;
y    :integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        case mi_state of
        as_disabled: color:=c_gray;
        as_enabled : color:=c_white;
        end;

        draw_text(tar,mi_x0+font_wh,mi_y0+menu_BigButtonH,text1,ta_LU,mi_charw,color,@y);
        if(length(text2)>0)then
        draw_text(tar,mi_x0+font_wh,y                    ,text2,ta_LU,mi_charw,color);
     end;
end;
procedure d_MenuItemTextC(tar:pSDL_Surface;mi,pos:byte;text:shortstring;color:cardinal);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
       case pos of
       ta_LU: draw_text(tar,mi_x0+font_wh,mi_y0+font_wh,text,pos,mi_charw,color);
       ta_MU: draw_text(tar,mi_xc        ,mi_y0+font_wh,text,pos,mi_charw,color);
       ta_RU: draw_text(tar,mi_x1-font_wh,mi_y0+font_wh,text,pos,mi_charw,color);

       ta_LM: draw_text(tar,mi_x0+font_wh,mi_yc        ,text,pos,mi_charw,color);
       ta_MM: draw_text(tar,mi_xc        ,mi_yc        ,text,pos,mi_charw,color);
       ta_RM: draw_text(tar,mi_x1-font_wh,mi_yc        ,text,pos,mi_charw,color);

       ta_LB: draw_text(tar,mi_x0+font_wh,mi_y1-font_wh,text,pos,mi_charw,color);
       ta_MB: draw_text(tar,mi_xc        ,mi_y1-font_wh,text,pos,mi_charw,color);
       ta_RB: draw_text(tar,mi_x1-font_wh,mi_y1-font_wh,text,pos,mi_charw,color);
       end;
end;

procedure d_MenuItemText(tar:pSDL_Surface;mi,pos:byte;text:shortstring;selectedVal:byte);
var color:cardinal;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        if(mi_state=as_disabled)
        then color:=c_gray
        else
          if(selectedVal=mi)
          or(selectedVal=255)
          then color:=c_yellow
          else color:=c_white;
        d_MenuItemTextC(tar,mi,pos,text,color);
     end;
end;
procedure d_menuItemText1(tar:pSDL_Surface;mi:byte;text:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
       d_MenuItemText(tar,mi,ta_MM,text,selectedVal);
end;
procedure d_menuItemText2(tar:pSDL_Surface;mi:byte;text1,text2:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        d_MenuItemText(tar,mi,ta_LM,text1,selectedVal);
        d_MenuItemText(tar,mi,ta_RM,text2,selectedVal);
     end;
end;

procedure d_MenuItemTextBar(tar:pSDL_Surface;mi:byte;text:shortstring;vcur,vmin,vmax:integer;selectedVal:byte);
var tx:integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        d_MenuItemText(tar,mi,ta_LM  ,text     ,selectedVal);

        tx:=mi_x1-menu_BarStepX;
        vlineColor(tar,tx+1,mi_y0,mi_y1-1,c_ltgray);
        draw_text(tar,tx+font_wh,mi_yc ,'>',ta_LM ,255,c_white);

        tx-=vmax-vmin;
        draw_text(tar,tx-font_wh,mi_yc ,i2s(vcur)+' <',ta_RM ,255,c_white);
        vlineColor(tar,tx-1,mi_y0,mi_y1-1,c_ltgray);
        boxColor(tar,tx,mi_yc-font_wh,tx+vcur-vmin,mi_yc+font_wh,c_lime);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MENU UPDATE
//

procedure d_MenuBlockSettings(tar:pSDL_Surface); // SETTINGS
begin
   d_menuItemText1(tar,mi_caption_Settings   ,str_menu_Settings      ,255);

   // SETTINGS LIST
   d_menuItemText1(tar,mi_settings_Game      ,str_S_Game            ,menu_SettingsPage);
   d_menuItemText1(tar,mi_settings_Record    ,str_S_Replay          ,menu_SettingsPage);
   d_menuItemText1(tar,mi_settings_Video     ,str_S_Video           ,menu_SettingsPage);
   d_menuItemText1(tar,mi_settings_Sound     ,str_S_Sound           ,menu_SettingsPage);

   // SETTINGS  GAME

   d_menuItemText2(tar,mi_SG_ColoredShadows  ,str_SG_ColoredShadow  ,str_YesNoC[ui_ColoredShadow]               ,0);
   d_MenuItemText2(tar,mi_SG_ShowAPM         ,str_SG_ShowAPM        ,str_YesNoC[ui_ShowAPM]                     ,0);
   d_MenuItemText2(tar,mi_SG_HealthBars      ,str_SG_HealthBars     ,str_SG_HealthBarsL[ui_HealthBars]          ,0);
   d_MenuItemText2(tar,mi_SG_RightClickAction,str_SG_RightClickAct  ,str_SG_RightClickActL[m_RightClickAct]     ,0);
   d_MenuItemText2(tar,mi_SG_MouseScroll     ,str_SG_MouseScroll    ,str_YesNoC[ui_MouseScroll]                 ,0);
   d_MenuItemText2(tar,mi_SG_PlayerName      ,str_SG_PlayerName     ,PlayerName+vc(mi_SG_PlayerName)            ,menu_ItemSelected);
   d_MenuItemText2(tar,mi_SG_Language        ,str_SG_Language       ,str_SG_LanguageL[ui_language]              ,0);
   d_MenuItemText2(tar,mi_SG_ControlPanelPos ,str_SG_ControlPanelPos,str_SG_ControlPanelPosL[ui_ControlPanelPos],0);
   d_MenuItemText2(tar,mi_SG_PlayersColor    ,str_SG_PlayersColor   ,str_SG_PlayersColorL[ui_PlayersColor]      ,0);

   d_MenuItemTextBar(tar,mi_SG_ScrollSpeed   ,str_SG_ScrollSpeed    ,ui_CamSpeed,1,ui_MaxCamSpeed,0);

   // SETTINGS  GAME RECORDING
   d_menuItemText2(tar,mi_SR_RecordGames     ,str_SR_RecordGames    ,str_YesNoC[rpls_Record]                    ,0);
   d_menuItemText2(tar,mi_SR_RecordPrefix    ,str_SR_ReplayPrefix   ,rpls_NamePrefix+vc(mi_SR_RecordPrefix)     ,menu_ItemSelected);
   d_menuItemText2(tar,mi_SR_RecordQuality   ,str_SR_Quality        ,str_ReplayQualityL[rpls_Quality]           ,0);

   // SETTINGS  VIDEO
   d_menuItemText2(tar,mi_SV_ResolutionW     ,str_SV_ResolutionW    ,i2s(menu_ResolutionWi)+vc(mi_SV_ResolutionW),menu_ItemSelected);
   d_menuItemText2(tar,mi_SV_ResolutionH     ,str_SV_ResolutionH    ,i2s(menu_ResolutionHi)+vc(mi_SV_ResolutionH),menu_ItemSelected);
   d_menuItemText1(tar,mi_SV_ResolutionApply ,str_SV_ResolutionApply,0);

   d_menuItemText2(tar,mi_SV_Windowed        ,str_SV_Windowed       ,str_YesNoC[vid_windowed]    ,0);
   d_menuItemText2(tar,mi_SV_ShowFPS         ,str_SV_ShowFPS        ,str_YesNoC[vid_ShowFPS ]    ,0);
   d_menuItemText2(tar,mi_SV_MenuScaling     ,str_SV_MenuScale      ,str_YesNoC[menu_scale  ]    ,0);
   d_menuItemText2(tar,mi_SV_SmoothScaled    ,str_SV_MenuScaleSmooth,str_YesNoC[menu_ScaleSmooth],0);

   // SETTINGS  SOUNDS
   d_MenuItemTextBar(tar,mi_SS_SoundVolume   ,str_SS_SoundVolume,snd_SoundVolume,0,snd_MaxSoundVolume,0);
   d_MenuItemTextBar(tar,mi_SS_MusicVolume   ,str_SS_MusicVolume,snd_MusicVolume,0,snd_MaxSoundVolume,0);

   d_menuItemText1(tar,mi_SS_PlayerNext      ,str_SS_NextTrack      ,0);
   d_menuItemText1(tar,mi_SS_ReloadPlaylist  ,str_SS_ReloadMusic    ,0);

   d_menuItemText2(tar,mi_SS_PlaylistSize    ,str_SS_MusicListSize  ,b2s(snd_musicListSize),0);
end;

procedure d_MenuBlockSaveLoad(tar:pSDL_Surface); // SAVE LOAD
begin
   if(g_started)
   then d_menuItemText1(tar,mi_caption_SaveLoad,str_menu_SaveLoad   ,255)
   else d_menuItemText1(tar,mi_caption_SaveLoad,str_menu_LoadGame   ,255);

   d_MenuItemList   (tar,mi_SaveLoad_list,@svld_list,svld_list_size,svld_list_scroll,svld_list_sel,menu_ListLineH,menu_ListLineWChars1,menu_BaseList1H);

   d_MenuItemCaption(tar,mi_SaveLoad_info,str_FileInfo );
   d_MenuItemInfo   (tar,mi_SaveLoad_info,svld_str_info1,svld_str_info2);

   d_menuItemText   (tar,mi_SaveLoad_fname,ta_LM,svld_str_fname+vc(mi_SaveLoad_fname),menu_ItemSelected);
   d_menuItemText1  (tar,mi_SaveLoad_save       ,str_FileSave  ,0);
   d_menuItemText1  (tar,mi_SaveLoad_load       ,str_FileLoad  ,0);
   d_menuItemText1  (tar,mi_SaveLoad_delete     ,str_FileDelete,0);
end;

procedure d_MenuBlockReplays(tar:pSDL_Surface); // REPLAYS
begin
   d_menuItemText1  (tar,mi_caption_Replays,str_menu_Replays       ,255);

   d_MenuItemList   (tar,mi_Replays_list   ,@rpls_list,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_ListLineH,menu_ListLineWChars1,menu_BaseList1H);

   d_MenuItemCaption(tar,mi_Replays_info   ,str_FileInfo );
   d_MenuItemInfo   (tar,mi_Replays_info   ,rpls_str_info1,rpls_str_info2);

   d_menuItemText1  (tar,mi_Replays_play   ,str_FilePlay,0);
   d_menuItemText1  (tar,mi_Replays_delete ,str_FileDelete,0);
end;

procedure d_MenuBlockHelpUnitsInfo(tar:pSDL_Surface);    // HELP
var
tx,ty:integer;
u    :byte;
begin
   with g_uids[menu_HelpUID] do
     if(uid_r>0)then
     begin
        d_MenuItemCaption(tar,mi_help_InfoList,uid_str_name,true);
        with uid_HintDoc do
        d_MenuItemList(tar,mi_help_InfoList,@slist_l,slist_n,menu_HelpScroll,-1,txt_line_h1,-1,ui_DocListH,true);
     end;

   with menu_items[mi_help_InfoPanel] do
   begin
      tx:=mi_x0;
      ty:=mi_y0;
      for u:=1 to 255 do
        with g_uids[u] do
          if(uid_r>0)then
          begin
             draw_sdlsurface(tar,tx,ty,uid_BTNDoc.surf);
             if(u=menu_HelpUID)then
             rectangleColor(tar,tx+1,ty+1,tx+ui_ButtonWh-1,ty+ui_ButtonWh-1,c_lime);

             tx+=ui_ButtonWh;
             if(tx>=mi_x1)then
             begin
                tx:=mi_x0;
                ty+=ui_ButtonWh;
             end;
          end;
   end;
end;

procedure d_MenuBlockScirmish(tar:pSDL_Surface);
var
p    :byte;
color:cardinal;
function TeamChar(p:byte):char;
begin
   if(map_scenario in mc_fixed_teams)
   then TeamChar:=b2s(PlayerGetFixedTeams(map_scenario,p)+1)[1]
   else TeamChar:=b2s(g_gplayers[p].team+1)[1]
end;
function AISlotsSOpt:shortstring;
begin
   if(g_AISlots=0)
   then AISlotsSOpt:=str_YesNoG[false]
   else AISlotsSOpt:=ai_name(g_AISlots)
end;
begin
   if(rpls_pstate=rpls_read)
   then d_menuItemText1(tar,mi_caption_Scirmish,str_menu_Playback    ,255)
   else
     case net_status of
     ns_none  : d_menuItemText1(tar,mi_caption_Scirmish,str_menu_Scirmish,255);
     ns_server,
     ns_client: d_menuItemText1(tar,mi_caption_Scirmish,str_Caption_Multiplayer+' '+str_menu_Scirmish,255);
     end;

   // SCIRMISH REPLAY INFO
   if(rpls_pstate=rpls_read)then
       if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)then
         d_menuItemText1(tar,mi_SubCaptionInfoLine,rpls_list[rpls_list_sel],0);

   // SCIRMISH PLAYERS
   d_MenuItemCaption(tar,mi_Players_Panel,str_Caption_Players);

   d_MenuItemTextC(tar,mi_Players_CState,ta_LM,str_PT_State ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_CName ,ta_MM,str_PT_Player,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_CRace ,ta_MM,str_PT_Race  ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_CTeam ,ta_MM,str_PT_Team  ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_CObs  ,ta_MM,str_PT_Obs   ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_CColor,ta_MM,str_PT_Color ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_CPing ,ta_MM,str_PT_Ping  ,c_ltgray);


   for p:=0 to LastPlayer do
     with g_gplayers[p] do
       if(state<>ps_None)then
       begin
          if(p=LocalPlayer)
          then color:=c_yellow
          else color:=mic(menu_items[mi_Players_AIskil0+p].mi_state=as_enabled,false);

          if(state=ps_AI)and(menu_items[mi_Players_State0 +p].mi_state=as_enabled)
     then d_MenuItemTextC(tar,mi_Players_State0 +p,ta_MM,'-'+str_ps_AI       ,color)
     else d_MenuItemTextC(tar,mi_Players_State0 +p,ta_MM,PlayerStateString(p),color);

          d_MenuItemTextC(tar,mi_Players_AIskil0+p,ta_LM,name                ,color);
          if(G_Started)and(isdefeated)then
            with menu_items[mi_Players_AIskil0+p] do
              if(mi_state>as_off)then
                hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_red);

          d_MenuItemTextC(tar,mi_Players_Race0+p,ta_MM,str_race[mrace],mic( menu_items[mi_Players_Race0+p].mi_state=as_enabled,false));
          d_MenuItemTextC(tar,mi_Players_Team0+p,ta_MM,TeamChar(p)    ,mic( menu_items[mi_Players_Team0+p].mi_state=as_enabled,false));

          if(p>=map_MaxPlayers)
          then d_MenuItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[true]      ,c_gray)
          else
            case state of
            ps_human: d_MenuItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[isobserver],mic( menu_items[mi_Players_Obs0 +p].mi_state=as_enabled,false));
            ps_AI   : d_MenuItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[false]     ,c_gray);
            end;
       end
       else
       begin
          if(not g_started)and(p<map_MaxPlayers)then
            if(menu_items[mi_Players_State0+p].mi_state=as_enabled)then
              d_MenuItemTextC(tar,mi_Players_State0+p,ta_MM,'+'+str_ps_AI,c_white);
          if(g_AISlots>0)and(p<map_MaxPlayers)and(not g_started)then
          begin
             d_MenuItemTextC(tar,mi_Players_Slot0+p,ta_LM,str_ps_AI+' '+b2s(g_AISlots)              ,c_gray);
             d_MenuItemTextC(tar,mi_Players_Race0+p,ta_MM,str_race[r_random]                        ,c_gray);
             d_MenuItemTextC(tar,mi_Players_Team0+p,ta_MM,b2s(PlayerGetFixedTeams(map_scenario,p)+1),c_gray);
             d_MenuItemTextC(tar,mi_Players_Obs0 +p,ta_MM,str_YesNoG[false]                         ,c_gray);
          end;
          if(g_started)then
          begin
             d_MenuItemTextC(tar,mi_Players_AIskil0+p,ta_LM,name,c_gray);
             if(isdefeated)then
               with menu_items[mi_Players_AIskil0+p] do
                 if(mi_state>as_off)then
                   hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_red);
          end;
          if(p>=map_MaxPlayers)then
          d_MenuItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[true],c_gray);
       end;

   for p:=0 to LastPlayer do
     with g_gplayers[p] do
     with menu_items[mi_Players_Ping0+p] do
       if(mi_state>as_off)then
         if(net_status=ns_none)or(state<>ps_Human)
         then boxColor(tar,mi_x0+font_wh,mi_y0+font_wh,
                           mi_x1-font_wh,mi_y1-font_wh,PlayerGetColor(p,false))
         else
           with g_nplayers[p] do
             if((net_status<>ns_client)and(p=LocalPlayer  ))
             or((net_status= ns_client)and(p=net_cl_Hoster))
             then draw_text(tar,mi_xc,mi_yc,str_ps_Host,ta_MM,255,PlayerGetColor(p,false))
             else
               if(net_ping<=999)
               then draw_text(tar,mi_xc,mi_yc,w2s(net_ping),ta_MM,255,PlayerGetColor(p,false))
               else draw_text(tar,mi_xc,mi_yc,'999'        ,ta_MM,255,PlayerGetColor(p,false));

   // SCIRMISH MAP
   d_MenuItemCaption(tar,mi_Map_Panel,str_Caption_Map);

   with menu_items[mi_Map_Map] do
   if(mi_state>as_off)then
   draw_sdlsurface(tar,mi_x0+1,mi_y0+1,ui_mminimap);

   d_menuItemText2(tar,mi_Map_Scenario  ,str_map_Scenario  ,str_map_ScenarioL[map_scenario]    ,0);
   d_menuItemText2(tar,mi_Map_Generators,str_map_Generators,str_map_GeneratorsL[map_generators],0);
   d_menuItemText2(tar,mi_Map_Seed      ,str_map_Seed      ,menu_mseed+vc(mi_Map_Seed)         ,menu_ItemSelected);
   d_menuItemText2(tar,mi_Map_Size      ,str_map_Size      ,i2s(map_Size1)                      ,0);
   d_menuItemText2(tar,mi_Map_Obstacles ,str_map_Obstacles ,strMX(map_ObstaclesF)              ,0);
   d_menuItemText2(tar,mi_Map_Symmetry  ,str_map_Symmetry  ,str_YesNoC[map_Symmetry]           ,0);

   d_menuItemText1(tar,mi_Map_Theme     ,theme_name[theme_i],0);
   d_menuItemText1(tar,mi_Map_Random    ,str_map_Random     ,0);

   // SCIRMISH GAME
   d_MenuItemCaption(tar,mi_Game_Panel,str_Caption_GOptions);

   d_menuItemText2(tar,mi_Game_FixedPositions,str_GO_FixedStarts,str_YesNoC[g_FixedPositions],0);
   d_menuItemText2(tar,mi_Game_AISlots       ,str_GO_AISlots    ,AISlotsSOpt                 ,0);
   d_menuItemText2(tar,mi_Game_DefeatedObs   ,str_GO_DefeatedObs,str_YesNoC[g_DefeatedObs]   ,0);
   d_menuItemText1(tar,mi_Game_Random        ,str_GO_Random     ,0);

   if(not g_started)and(g_LobbyTimer>0)then
   d_menuItemText1(tar,mi_UnderBottomInfoLine,str_lobby_GameStartIn+ir2s(g_LobbyTimer),0);

   // SCIRMISH MULTIPLAYER
   //
   case net_status of
   ns_none  : begin
              d_MenuItemCaption(tar,mi_MP_Panel          ,str_Caption_Multiplayer  );
              d_menuItemText1  (tar,mi_MP_ServerToggle   ,str_net_ServerStart    ,0);
              d_menuItemText1  (tar,mi_MP_Connect        ,str_net_Connect        ,0);
              d_menuItemText1  (tar,mi_MP_ClientLANSearch,str_net_LANSearch      ,0);
              end;
   ns_server: begin
              d_MenuItemCaption(tar,mi_MP_Panel          ,str_Caption_Multiplayer+': '+str_Caption_Server);
              d_menuItemText1  (tar,mi_MP_ServerToggle   ,str_net_ServerStop     ,0);

              end;
   ns_client: begin
              d_MenuItemCaption(tar,mi_MP_Panel          ,str_Caption_Multiplayer+': '+str_Caption_Client);

              d_menuItemText2  (tar,mi_MP_ClientQuality  ,str_net_Quality        ,str_NetQualityL[net_cl_Quality],0);

              if(net_cl_Hoster=255)and(net_cl_svttl<TTLServer)then
              d_menuItemText1(tar,mi_SubCaptionInfoLine,str_net_ConnectedToDed,0);
              end;
   end;

   d_menuItemText1(tar,mi_MP_Disconnect   ,str_net_DisConnect  ,0);
   d_menuItemText2(tar,mi_MP_ServerPort   ,str_net_UDPPort     ,menu_ServerPort   +vc(mi_MP_ServerPort   ),menu_ItemSelected);
   d_menuItemText2(tar,mi_MP_ServerLANVis ,str_net_ServerLANVis,str_YesNoC[net_svLanAdv],0);
   d_menuItemText2(tar,mi_MP_ClientAddress,str_net_Address     ,menu_ClientAddress+vc(mi_MP_ClientAddress),menu_ItemSelected);
   d_MenuItemText2(tar,mi_Players_Ready   ,str_net_Ready       ,str_YesNoC[PlayerReady ],0);

   d_menuMultiplayerChat(tar,mi_MP_ChatList);
   with menu_items[mi_MP_ChatLine] do
   begin
      d_MenuItemTextC(tar,mi_MP_ChatLine,ta_RM,str_menu_Chat,c_dgray);
      d_menuItemText2(tar,mi_MP_ChatLine,str_CutLast(net_chat_str+chat_type[false],mi_charw),'',0);
   end;
end;

procedure d_MenuBlockCampaings(tar:pSDL_Surface);
begin
   d_menuItemText1(tar,mi_caption_Campaings  ,str_menu_Campaings     ,255);
end;

function menu_ItemActsStr:shortstring;
begin
   menu_ItemActsStr:='';
   if(GetBBit(@menu_ItemActs,miat_BtnLeft ))then STRADD(@menu_ItemActsStr,str_doc_LMB,sep_slash);
   if(GetBBit(@menu_ItemActs,miat_BtnRight))then STRADD(@menu_ItemActsStr,str_doc_RMB,sep_slash);
   if(GetBBit(@menu_ItemActs,miat_MWhell  ))then STRADD(@menu_ItemActsStr,str_doc_MWH,sep_slash);
{
if(GetBBit(@menu_ItemActs,miat_TextEdit))then
}
end;

procedure d_MenuUpdate(tar:pSDL_Surface); //////////////////////////////////////
var i:byte;
begin
   // COMMON
   if(menu_DarkBack)
   then draw_sdlsurface(tar,0,0,spr_MenuBackgroundD)
   else draw_sdlsurface(tar,0,0,spr_MenuBackgroundL);

   if(TestMode>0)then
   draw_text(tar,menu_hw,0,'TEST MODE '+b2s(TestMode),ta_MU,255,c_white);

   // MENU ITEMS

   /////////////////////////////////////////////////////////////////////////////
   // draw pannels
   for i in byte do
     case i of
     mi_Players_CName,
     mi_Players_CState,
     mi_Players_CRace,
     mi_Players_CTeam,
     mi_Players_CPing,
     mi_Players_CColor,
     mi_Players_CObs,
     mi_Map_Theme,
     mi_SubCaptionInfoLine,
     mi_UnderBottomInfoLine
                          :;
     mi_caption_Campaings,
     mi_caption_Scirmish,
     mi_caption_SaveLoad,
     mi_caption_Replays,
     mi_caption_Settings,
     mi_caption_SVSearch
                          : d_MenuItemPanel(tar,i,3);
     else                   d_MenuItemPanel(tar,i,1);
     end;

   /////////////////////////////////////////////////////////////////////////////
   // Main buttons
   d_MenuItemText1(tar,mi_Campaings          ,str_menu_Campaings    ,0);
   d_menuItemText1(tar,mi_Scirmish           ,str_menu_Scirmish     ,0);

   if(g_started)
then d_menuItemText1(tar,mi_SaveLoad         ,str_menu_SaveLoad     ,0)
else d_menuItemText1(tar,mi_SaveLoad         ,str_menu_LoadGame     ,0);

   d_menuItemText1(tar,mi_Replays            ,str_menu_Replays      ,0);
   d_menuItemText1(tar,mi_Settings           ,str_menu_Settings     ,0);
   d_menuItemText1(tar,mi_Help               ,str_menu_Help         ,0);

   if(rpls_pstate=rpls_read)
then d_menuItemText1(tar,mi_Break            ,str_menu_PlaybackStop ,0)
else d_menuItemText1(tar,mi_Break            ,str_menu_Abort        ,0);

   d_menuItemText1(tar,mi_Back               ,str_menu_Back         ,0);
   d_menuItemText1(tar,mi_Exit               ,str_menu_Exit         ,0);
   d_menuItemText1(tar,mi_Surrender          ,str_menu_Surrender    ,0);
   d_menuItemText1(tar,mi_StartNow           ,str_menu_Start        ,0);
   d_menuItemText1(tar,mi_StartTimer         ,str_menu_Start        ,0);
   d_menuItemText1(tar,mi_StopTimer          ,str_menu_Cancel       ,0);

   // MAIN BLOCKs
   if(net_svsearch)then
   begin
      d_menuItemText1(tar,mi_caption_SVSearch   ,str_Caption_NetSVSearch,255);
      // Net search
      with menu_items[mi_NetSearch_List] do
      d_MenuItemList(tar,mi_NetSearch_List ,@net_svsearch_lists,net_svsearch_size,net_svsearch_scroll,net_svsearch_sel,menu_ListLineH2,mi_charw*3,menu_SvSearchListH);
      d_menuItemText1(tar,mi_NetSearch_Connect,str_net_Connect,0);
   end
   else
     case menu_page of
     mi_SaveLoad  : d_MenuBlockSaveLoad(tar);
     mi_Replays   : d_MenuBlockReplays (tar);
     mi_Settings  : d_MenuBlockSettings(tar);
     mi_Help      : begin
                       d_menuItemText1(tar,mi_caption_Help,str_menu_Help,255);

                       d_menuItemText1(tar,mi_help_Basics      ,str_help_Basics      ,menu_HelpPage);
                       d_menuItemText1(tar,mi_help_HotKeys     ,str_help_HotKeys     ,menu_HelpPage);
                       d_menuItemText1(tar,mi_help_UnitsInfo   ,str_help_UnitsInfo   ,menu_HelpPage);
                       d_menuItemText1(tar,mi_help_UnitsBalance,str_help_BalanceTable,menu_HelpPage);

                       case menu_HelpPage of
                       mi_help_Basics,
                       mi_help_HotKeys     : if(menu_HelpIList<>nil)then
                                             with menu_HelpIList^ do
                                             d_MenuItemList(tar,mi_help_InfoList,@slist_l,slist_n,menu_HelpScroll,-1,txt_line_h1,-1,ui_DocListH,true);
                       mi_help_UnitsInfo   : d_MenuBlockHelpUnitsInfo(tar);
                       mi_help_UnitsBalance: ;
                       end;
                    end;
     else
       case g_type of
       gt_scirmish: d_MenuBlockScirmish (tar);
       gt_campaing: d_MenuBlockCampaings(tar);
       end;
     end;

   if(menu_hint_pos[menu_ItemTarget]>0)then
     with menu_items[menu_hint_pos[menu_ItemTarget]] do
       draw_text(tar,mi_x1-font_w1,mi_y0-font_wh,menu_ItemActsStr+str_menu_hint[menu_ItemTarget],ta_RB,255,c_white);

   // MESSAGE BOX
   if(menu_msg_type<>mmbt_none)then
   begin
      boxColor(tar,0,0,menu_w,menu_h,c_ablack);

      boxColor      (tar,menu_msg_x0,menu_msg_y0,
                         menu_msg_x1,menu_msg_y1,c_black);
      rectangleColor(tar,menu_msg_x0,menu_msg_y0,
                         menu_msg_x1,menu_msg_y1,c_white);

      draw_text(tar,menu_msg_textx,menu_msg_captiony,menu_msg_Caption,ta_MU,menu_ListLineWChars1,c_red   );
      draw_text(tar,menu_msg_textx,menu_msg_bodyy   ,menu_msg_Body   ,ta_MM,menu_ListLineWChars1,c_yellow);

      case menu_msg_type of
      mmbt_none         :;
      mmbt_nothing,
      mmbt_netPortBlock : draw_text(tar,menu_msg_textx,menu_msg_btny,str_menuMsg_HintDefault,ta_MB,menu_ListLineWChars1,c_gray  );
      mmbt_netWaitServer: draw_text(tar,menu_msg_textx,menu_msg_btny,str_menuMsg_HintClient ,ta_MB,menu_ListLineWChars1,c_gray  );
      mmbt_SaveRewrite,
      mmbt_DeleteSave,
      mmbt_DeleteReplay : begin
                             hlineColor(tar,menu_msg_x0,menu_msg_x1,menu_msg_btn1y0,c_white);
                             vlineColor(tar,menu_msg_btn1x1,menu_msg_btn1y0,menu_msg_btn1y1,c_white);
                             draw_text(tar,menu_msg_btn1tx,menu_msg_btny,str_YesNoC[true ],ta_MM,menu_ListLineWCharsh,c_gray);
                             draw_text(tar,menu_msg_btn2tx,menu_msg_btny,str_YesNoC[false],ta_MM,menu_ListLineWCharsh,c_gray);
                          end;
      end;
   end;


    {
   // replays
   draw_text(tar,ui_menu_csm_xt1, y, str_replay             , ta_LU  ,255, c_white);
   draw_text(tar,ui_menu_csm_xt2, y, str_rstatus[rpls_pstate], ta_RU ,255, mic( menu_ReplayStatusToggleEnabled ,rpls_pstate>rpls_none));

   // replay data units
   if(rpls_pstate>rpls_none)and(g_cl_units>0)then
   draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units), ta_RU,255, c_white);
 }
end;

procedure D_Menu;
var tx,ty:integer;
begin
   if(menu_redraw_pause>0)then menu_redraw_pause-=1;
   if(menu_redraw)and(menu_redraw_pause=0)then
   begin
      PlayersUpdateColorSchema(LocalPlayer);
      d_MenuUpdate(menu_Surface);

      vid_MakeBigMenu;
      menu_redraw:=false;
      menu_redraw_pause:=fr_fpss;
   end;

   draw_sdlsurface(vid_screen,menu_sc_x,menu_sc_y,menu_SurfaceSC);

   if(vid_ShowFPS)then draw_text(vid_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_RU,255,c_white);

   draw_sdlsurface(vid_screen,mouse_x,mouse_y,spr_cursor);
   if(menu_ItemActs>0)then
   begin
      tx:=mouse_x+(spr_cursor^.w div 2);
      ty:=mouse_y+(spr_cursor^.w div 2);
      if GetBBit(@menu_ItemActs,miat_BtnLeft )
      or GetBBit(@menu_ItemActs,miat_MWhell  )
      or GetBBit(@menu_ItemActs,miat_BtnRight)then
      begin
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_MLB[GetBBit(@menu_ItemActs,miat_BtnLeft )]);
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_MMB[GetBBit(@menu_ItemActs,miat_MWhell  )]);
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_MRB[GetBBit(@menu_ItemActs,miat_BtnRight)]);
         tx+=spr_CursorHint_MLB[true]^.w;
      end;
      if(GetBBit(@menu_ItemActs,miat_TextEdit))then
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_Edit);
   end;
end;


