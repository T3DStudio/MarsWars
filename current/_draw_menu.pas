
////////////////////////////////////////////////////////////////////////////////
//
//   MENU COMMON
//

function mic(enabled,selected:boolean):TMWColor;
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

procedure drawmenu_MakeBig;
var
cx,cy:single;
begin
   if(menu_BackgroundSC<>nil)and(menu_BackgroundSC<>menu_Background)then sdl_FreeSurface(menu_BackgroundSC);

   if(menu_scale)then
   begin
      cx:=vid_vw/menu_Surface^.w;
      cy:=vid_vh/menu_Surface^.h;
      if(cx>cy)
      then menu_Surface_sc:=cy
      else menu_Surface_sc:=cx;
      menu_Surface_x   :=(vid_vw-round(menu_w*menu_Surface_sc)) div 2;
      menu_Surface_y   :=(vid_vh-round(menu_h*menu_Surface_sc)) div 2;
      menu_BackgroundSC:=zoomSurface(menu_Background,menu_Surface_sc,menu_Surface_sc,0);
      menu_Surface_sc  :=1/menu_Surface_sc;
   end
   else
   begin
      menu_Surface_sc:=1;
      menu_Surface_x   :=(vid_vw-menu_w) div 2;
      menu_Surface_y   :=(vid_vh-menu_h) div 2;
      menu_BackgroundSC:=menu_Background;
   end;
   menu_Background_x:=(vid_vw-menu_BackgroundSC^.w) div 2;
   menu_Background_y:=(vid_vh-menu_BackgroundSC^.h) div 2;
end;

procedure drawmenu_ItemPanel(tar:pSDL_Surface;mi,border:byte);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        boxColor(tar,mi_x0,mi_y0,mi_x1,mi_y1,c_black);
        draw_rectw(tar,mi_x0+1,mi_y0+1,mi_x1-1,mi_y1-1,border,-1,c_ltgray);
     end;
end;

procedure drawmenu_ItemCaption(tar:pSDL_Surface;mi:byte;text:shortstring);
var color:TMWColor;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        case mi_state of
        as_disabled: color:=c_gray;
        as_enabled : color:=c_white;
        end;

        rectangleColor(tar,mi_xc-menu_ItemCaptionhW,mi_y0,
                           mi_xc+menu_ItemCaptionhW,mi_y0+menu_BigButtonHh,c_ltgray);
        draw_text(tar,mi_xc,mi_y0+font_wh ,text,ta_MU,255,color);
     end;
end;

procedure drawmenu_ScrollBar(tar:pSDL_Surface;mi:byte;scrolli,listH,listSize:integer;reverse:boolean=false);
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
      rectangleColor(tar,mi_x1-1,posCY,mi_x1-3,posCY+barh,c_aqua);
   end;
end;
procedure drawmenu_StringArray(tar:pSDL_Surface;mi:byte;plist:PTStringArray;listSize:integer;scroll,selected,lineH,lineWChars,listH:integer;numbered:boolean;docText:boolean=false);
var
t,i,y:integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)and(listH>0)then
     begin
        if(lineWChars<0)then lineWChars:=mi_charw;
        y:=mi_y0;
        for t:=0 to listH-1 do
        begin
           i:=t+scroll;
           if(0<=i)and(i<listSize)then
             if(docText)then
             begin
                if((y+font_w1)>=mi_y1)then break;
                draw_text(tar,mi_x0+font_wh,y+font_wh,plist^[i],ta_LU,lineWChars,c_white,@y,mi_y1);
                y+=lineH-font_wh;
             end
             else
             begin
                if(i=selected)then
                  boxColor(tar,mi_x0+1,y+1,mi_x1-1,y+lineH-2,c_dgray);

                if(numbered)
                then draw_text(tar,mi_x0+font_wh,y+font_wh,str_CutEnd(b2s(i+1)+'] '+plist^[i],lineWChars),ta_LU,mi_charw,mic(mi_state=as_enabled,i=selected))
                else draw_text(tar,mi_x0+font_wh,y+font_wh,str_CutEnd(              plist^[i],lineWChars),ta_LU,mi_charw,mic(mi_state=as_enabled,i=selected));

                if(mi_y0<y)then
                hlineColor(tar,mi_x0+1,mi_x1-1,y,c_gray);

                y+=lineH-1;
                if(y<mi_y1)then
                hlineColor(tar,mi_x0+1,mi_x1-1,y,c_gray);

                y+=1;
             end;
        end;

        drawmenu_ScrollBar(tar,mi,scroll,listH,listSize);
     end;
end;

procedure drawmenu_MultiplayerChat(tar:pSDL_Surface;mi:byte);
var
i,y:integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        drawmenu_ScrollBar(tar,mi,menu_ChatScroll,menu_ChatListH,menu_ChatSize,true);
        MakeLogListForDraw(LocalPlayer,mi_charw,menu_ChatListH,menu_ChatScroll,lmts_menu_chat);

        //ui_log_n
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

procedure drawmenu_ItemInfo(tar:pSDL_Surface;mi:byte;text1,text2,text3:shortstring);
var
color:TMWColor;
y    :integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        case mi_state of
        as_disabled: color:=c_gray;
        as_enabled : color:=c_white;
        end;

        draw_text(tar,mi_x0+font_wh,mi_y0+menu_BigButtonH1,text1,ta_LU,mi_charw,color,@y);
        if(length(text2)>0)then
        draw_text(tar,mi_x0+font_wh,y                    ,text2,ta_LU,mi_charw,color,@y);
        if(length(text3)>0)then
        draw_text(tar,mi_x0+font_wh,y                    ,text3,ta_LU,mi_charw,color,@y);
     end;
end;
procedure drawmenu_ItemTextC(tar:pSDL_Surface;mi,pos:byte;text:shortstring;color:TMWColor);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
       case pos of
       ta_LA: draw_text(tar,mi_x0+font_wh,mi_y0-font_wh,text,ta_LB,mi_charw,color);
       ta_MA: draw_text(tar,mi_xc        ,mi_y0-font_wh,text,ta_MB,mi_charw,color);

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

procedure drawmenu_ItemText(tar:pSDL_Surface;mi,pos:byte;text:shortstring;selectedVal:byte);
var color:TMWColor;
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
        drawmenu_ItemTextC(tar,mi,pos,text,color);
     end;
end;
procedure drawmenu_ItemText1(tar:pSDL_Surface;mi:byte;text:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
       drawmenu_ItemText(tar,mi,ta_MM,text,selectedVal);
end;
procedure drawmenu_ItemText2(tar:pSDL_Surface;mi:byte;text1,text2:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        drawmenu_ItemText(tar,mi,ta_LM,text1,selectedVal);
        drawmenu_ItemText(tar,mi,ta_RM,text2,selectedVal);
     end;
end;

procedure drawmenu_ItemTextBar(tar:pSDL_Surface;mi:byte;text:shortstring;vcur,vmin,vmax:integer;selectedVal:byte);
var tx:integer;
begin
   with menu_items[mi] do
     if(mi_state>as_off)then
     begin
        drawmenu_ItemText(tar,mi,ta_LM  ,text     ,selectedVal);

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

procedure drawmenu_BlockSettings(tar:pSDL_Surface); // SETTINGS
begin
   drawmenu_ItemText1(tar,mi_caption_Settings   ,str_menu_Settings      ,255);

   // SETTINGS LIST
   drawmenu_ItemText1(tar,mi_settings_Game      ,str_S_Game             ,menu_SettingsPage);
   drawmenu_ItemText1(tar,mi_settings_Record    ,str_S_Replay           ,menu_SettingsPage);
   drawmenu_ItemText1(tar,mi_settings_Video     ,str_S_Video            ,menu_SettingsPage);
   drawmenu_ItemText1(tar,mi_settings_Sound     ,str_S_Sound            ,menu_SettingsPage);

   // SETTINGS  GAME

   drawmenu_ItemText2(tar,mi_SG_PlayerName      ,str_SG_PlayerName      ,PlayerName+vc(mi_SG_PlayerName)            ,menu_ItemSelected);
   drawmenu_ItemText2(tar,mi_SG_Language        ,str_SG_Language        ,str_SG_LanguageL[ui_language]              ,0);
   drawmenu_ItemText2(tar,mi_SG_ColoredShadows  ,str_SG_ColoredShadow   ,str_YesNoC[ui_ColoredShadow]               ,0);
   drawmenu_ItemText2(tar,mi_SG_PlayersColor    ,str_SG_PlayersColor    ,str_SG_PlayersColorL[ui_PlayersColor  ]    ,0);
   drawmenu_ItemText2(tar,mi_SG_ShowAPM         ,str_SG_ShowAPM         ,str_YesNoC[ui_ShowAPM]                     ,0);
   drawmenu_ItemText2(tar,mi_SG_HealthBars      ,str_SG_HealthBars      ,str_SG_HealthBarsL[ui_HealthBars]          ,0);
   drawmenu_ItemText2(tar,mi_SG_RightClickAction,str_SG_RightClickAct   ,str_SG_RightClickActL[m_RightClickAct]     ,0);
   drawmenu_ItemText2(tar,mi_SG_MouseScroll     ,str_SG_MouseScroll     ,str_YesNoC[ui_MouseScroll]                 ,0);
   drawmenu_ItemText2(tar,mi_SG_ControlPanelPos ,str_SG_ControlPanelPos ,str_SG_ControlPanelPosL[ui_ControlPanelPos],0);
   drawmenu_ItemText2(tar,mi_SG_ControlPanelAuto,str_SG_ControlPanelAuto,str_YesNoC[ui_tab_Auto]                    ,0);
   drawmenu_ItemText2(tar,mi_SG_ShowPlayerScrns ,str_SG_ShowPlayerScrns ,str_YesNoC[ui_PlayersScreens]              ,0);

   drawmenu_ItemTextBar(tar,mi_SG_ScrollSpeed   ,str_SG_ScrollSpeed     ,ui_CamSpeed,1,ui_MaxCamSpeed,0);

   // SETTINGS  GAME RECORDING
   drawmenu_ItemText2(tar,mi_SR_RecordGames     ,str_SR_RecordGames     ,str_YesNoC[rpls_Record]                    ,0);
   drawmenu_ItemText2(tar,mi_SR_RecordPrefix    ,str_SR_ReplayPrefix    ,rpls_NamePrefix+vc(mi_SR_RecordPrefix)     ,menu_ItemSelected);
   drawmenu_ItemText2(tar,mi_SR_RecordQuality   ,str_SR_Quality         ,str_ReplayQualityL[rpls_Quality]           ,0);

   // SETTINGS  VIDEO
   drawmenu_ItemText2(tar,mi_SV_ResolutionW     ,str_SV_ResolutionW     ,i2s(menu_ResolutionWi)+vc(mi_SV_ResolutionW),menu_ItemSelected);
   drawmenu_ItemText2(tar,mi_SV_ResolutionH     ,str_SV_ResolutionH     ,i2s(menu_ResolutionHi)+vc(mi_SV_ResolutionH),menu_ItemSelected);
   drawmenu_ItemText1(tar,mi_SV_ResolutionApply ,str_SV_ResolutionApply ,0);

   drawmenu_ItemText2(tar,mi_SV_Windowed        ,str_SV_Windowed        ,str_YesNoC[vid_windowed]    ,0);
   drawmenu_ItemText2(tar,mi_SV_ShowFPS         ,str_SV_ShowFPS         ,str_YesNoC[vid_ShowFPS ]    ,0);
   drawmenu_ItemText2(tar,mi_SV_MenuScaling     ,str_SV_MenuScale       ,str_YesNoC[menu_scale  ]    ,0);

   // SETTINGS  SOUNDS
   drawmenu_ItemTextBar(tar,mi_SS_SoundVolume   ,str_SS_SoundVolume     ,snd_SoundVolume,0,snd_MaxSoundVolume,0);
   drawmenu_ItemTextBar(tar,mi_SS_MusicVolume   ,str_SS_MusicVolume     ,snd_MusicVolume,0,snd_MaxSoundVolume,0);

   drawmenu_ItemText1(tar,mi_SS_PlayerNext      ,str_SS_NextTrack       ,0);
   drawmenu_ItemText1(tar,mi_SS_ReloadPlaylist  ,str_SS_ReloadMusic     ,0);

   drawmenu_ItemText2(tar,mi_SS_RenewPlaylist   ,str_SS_RenewMusicList  ,str_YesNoC[snd_RenewMusicList],0);
   drawmenu_ItemText2(tar,mi_SS_PlaylistSize    ,str_SS_MusicListSize   ,b2s(snd_musicListSize),0);
end;

procedure drawmenu_BlockSaveLoad(tar:pSDL_Surface); // SAVE LOAD
begin
   if(g_started)
   then drawmenu_ItemText1(tar,mi_caption_SaveLoad,str_menu_SaveLoad   ,255)
   else drawmenu_ItemText1(tar,mi_caption_SaveLoad,str_menu_LoadGame   ,255);

   drawmenu_StringArray(tar,mi_SaveLoad_list,@svld_list,svld_list_size,svld_list_scroll,svld_list_sel,menu_ListLineH,menu_ListLineWChars1,menu_BaseList1H,true);

   drawmenu_ItemCaption(tar,mi_SaveLoad_info,str_FileInfo );
   drawmenu_ItemInfo   (tar,mi_SaveLoad_info,svld_str_info1,svld_str_info2,svld_str_info3);

   with menu_items[mi_SaveLoad_fname] do
   drawmenu_ItemText   (tar,mi_SaveLoad_fname,ta_LM,str_CutLast(svld_str_fname+vc(mi_SaveLoad_fname),mi_charw),menu_ItemSelected);
   drawmenu_ItemText1  (tar,mi_SaveLoad_save       ,str_FileSave  ,0);
   drawmenu_ItemText1  (tar,mi_SaveLoad_load       ,str_FileLoad  ,0);
   drawmenu_ItemText1  (tar,mi_SaveLoad_delete     ,str_FileDelete,0);
end;

procedure drawmenu_BlockReplays(tar:pSDL_Surface); // REPLAYS
begin
   drawmenu_ItemText1  (tar,mi_caption_Replays,str_menu_Replays       ,255);

   drawmenu_StringArray(tar,mi_Replays_list   ,@rpls_list,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_ListLineH,menu_ListLineWChars1,menu_BaseList1H,true);

   drawmenu_ItemCaption(tar,mi_Replays_info   ,str_FileInfo );
   drawmenu_ItemInfo   (tar,mi_Replays_info   ,rpls_str_info1,rpls_str_info2,rpls_str_info3);

   drawmenu_ItemText1  (tar,mi_Replays_play   ,str_FilePlay,0);
   drawmenu_ItemText1  (tar,mi_Replays_delete ,str_FileDelete,0);
end;

procedure drawmenu_BlockHelpInfo(tar:pSDL_Surface);   // HELP INFO
begin
   if(menu_HelpIList<>nil)then
     with menu_HelpIList^ do
       drawmenu_StringArray(tar,mi_help_InfoList,@slist_l,slist_n,menu_HelpILScroll,-1,txt_line_h1,-1,ui_DocListH,false,true);
   if(menu_HelpPage=mi_help_GameUI)then
     drawmenu_ItemText1(tar,mi_help_ImgUI,str_help_ImgUI,0);

   drawmenu_ItemText1(tar,mi_help_ImgUI        ,str_help_ImgUI        ,0);
   drawmenu_ItemText1(tar,mi_help_ImgUUpgrade  ,str_help_ImgUUpgrade  ,0);
   drawmenu_ItemText1(tar,mi_help_ImgGenerators,str_help_ImgGenerators,0);
   drawmenu_ItemText1(tar,mi_help_ImgKeyPoints ,str_help_ImgKeyPoints ,0);
   drawmenu_ItemText1(tar,mi_help_ImgKotH      ,str_help_ImgKotH      ,0);
end;

procedure drawmenu_BlockHelpObjInfo(tar:pSDL_Surface);  // HELP UNITS TABLE
var
tx,ty:integer;
u    :byte;
begin
   if(menu_HelpUID>0)then
     case menu_HelpPage of
     mi_help_UnitsInfo,
     mi_help_UnitsBalance: with g_uids [menu_HelpUID] do drawmenu_ItemTextC(tar,mi_help_InfoList,ta_MA,uid_str_name ,c_white);
     mi_help_UpgradesInfo: with g_upgrs[menu_HelpUID] do drawmenu_ItemTextC(tar,mi_help_InfoList,ta_MA,upgr_str_name,c_white);
     end;

   with menu_items[mi_help_InfoPanel] do
   begin
      tx:=mi_x0;
      ty:=mi_y0-menu_HelpUIDScroll;
      for u:=1 to 255 do
      begin
         case menu_HelpPage of
         mi_help_UnitsInfo,
         mi_help_UnitsBalance: with g_uids[u] do
                                 if(not menudoc_ValidForTableUnit(u,mi_help_UnitsBalance=menu_HelpPage))
                                 then continue
                                 else
                                   if(ty>=mi_y0)then draw_sdlsurface(tar,tx,ty,uid_BTNBig.surf);
         mi_help_UpgradesInfo: with g_upgrs[u] do
                                 if(not menudoc_ValidForTableUpgrade(u))
                                 then continue
                                 else
                                   if(ty>=mi_y0)then draw_sdlsurface(tar,tx,ty,upgr_BTNBig.surf);
         end;

         if(u=menu_HelpUID)and(ty>=mi_y0)then
           rectangleColor(tar,tx+1,ty+1,tx+menu_HelpIDBTNw-1,ty+menu_HelpIDBTNw-1,c_lime);

         tx+=menu_HelpIDBTNw;
         if(tx>=mi_x1)then
         begin
            tx:=mi_x0;
            ty+=menu_HelpIDBTNw;
            if(ty>=mi_y1)then exit;
         end;
      end;
   end;
end;

procedure drawmenu_BlockHelpUnitsBalance(tar:pSDL_Surface);
var
tx,ty:integer;
procedure DrawTSoBUnits(caption,hint:shortstring;psob:PTSoB);
var u:byte;
begin
   tx:=menu_items[mi_help_InfoList].mi_x0+font_wh;
   draw_text(tar,tx,ty,caption,ta_LU,255,c_white);
   ty+=txt_line_h2;
   for u in psob^ do
   begin
      draw_sdlsurface(tar,tx,ty,g_uids[u].uid_BTNDoc.surf);
      tx+=ui_ButtonWh;
      with menu_items[mi_help_InfoList] do
        if((tx+ui_ButtonWh)>=mi_x1)then
        begin
           tx:=mi_x0+font_wh;
           ty+=ui_ButtonWh;
        end;
   end;
   tx:=menu_items[mi_help_InfoList].mi_x0+font_wh;
   if(psob^<>[])then
     ty+=ui_ButtonWh;
   if(length(hint)>0)then
   begin
      ty+=font_w1;
      draw_text(tar,tx,ty,hint,ta_LU,menu_items[mi_help_InfoList].mi_charw,c_ltgray,@ty);
      ty+=txt_line_h1;
   end;
   ty+=txt_line_h1+font_w1;
end;
begin
   if(menu_HelpUID=0)then exit;

   with g_uids[menu_HelpUID] do
     drawmenu_ItemTextC(tar,mi_help_InfoList,ta_MA,uid_str_name,c_white);

   with menu_items[mi_help_InfoList] do
     with g_uids[menu_HelpUID] do
     begin
        ty:=mi_y0+font_wh;

        DrawTSoBUnits(str_doc_BalanceGood   ,uid_str_balance_Good   ,@uid_balance_Good   );
        DrawTSoBUnits(str_doc_BalanceBad    ,uid_str_balance_Bad    ,@uid_balance_Bad    );
        DrawTSoBUnits(str_doc_BalanceUseless,uid_str_balance_Useless,@uid_balance_Useless);

        drawmenu_ItemTextC(tar,mi_help_InfoList,ta_LB,str_doc_NoteUnitBalance,c_ltgray);
     end;
end;

procedure drawmenu_BlockScirmish(tar:pSDL_Surface);
var
p    :byte;
color:TMWColor;
function TeamChar(p:byte):char;
begin
   if(map_scenario in mc_fixed_teams)
   then TeamChar:=b2s(PlayerGetFixedTeams(map_scenario,p)+1)[1]
   else TeamChar:=b2s(g_PlayersGame[p].team+1)[1]
end;
function AISlotsSOpt:shortstring;
begin
   if(g_AISlots=0)
   then AISlotsSOpt:=str_YesNoG[false]
   else AISlotsSOpt:=ai_name(g_AISlots,255)
end;
begin
   if(rpls_pstate=rpls_read)
   then drawmenu_ItemText1(tar,mi_caption_Scirmish,str_menu_Playback    ,255)
   else
     case net_status of
     ns_none  : drawmenu_ItemText1(tar,mi_caption_Scirmish,str_menu_Scirmish,255);
     ns_server,
     ns_client: drawmenu_ItemText1(tar,mi_caption_Scirmish,str_Caption_Multiplayer+' '+str_menu_Scirmish,255);
     end;

   // SCIRMISH REPLAY INFO
   if(rpls_pstate=rpls_read)then
       if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)then
         drawmenu_ItemText1(tar,mi_SubCaptionInfoLine,rpls_list[rpls_list_sel],0);

   // SCIRMISH PLAYERS
   drawmenu_ItemCaption(tar,mi_Players_Panel,str_Caption_Players);

   drawmenu_ItemTextC(tar,mi_Players_CState,ta_LM,str_PT_State ,c_ltgray);
   drawmenu_ItemTextC(tar,mi_Players_CName ,ta_MM,str_PT_Player,c_ltgray);
   drawmenu_ItemTextC(tar,mi_Players_CRace ,ta_MM,str_PT_Race  ,c_ltgray);
   drawmenu_ItemTextC(tar,mi_Players_CTeam ,ta_MM,str_PT_Team  ,c_ltgray);
   drawmenu_ItemTextC(tar,mi_Players_CObs  ,ta_MM,str_PT_Obs   ,c_ltgray);
   drawmenu_ItemTextC(tar,mi_Players_CColor,ta_MM,str_PT_Color ,c_ltgray);
   drawmenu_ItemTextC(tar,mi_Players_CPing ,ta_MM,str_PT_Ping  ,c_ltgray);

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
       if(state<>ps_None)then
       begin
          if(p=LocalPlayer)
          then color:=c_yellow
          else color:=mic(menu_items[mi_Players_AIskil0+p].mi_state=as_enabled,false);

          if(state=ps_AI)and(menu_items[mi_Players_State0 +p].mi_state=as_enabled)
     then drawmenu_ItemTextC(tar,mi_Players_State0 +p,ta_MM,'-'+str_ps_AI       ,color)
     else drawmenu_ItemTextC(tar,mi_Players_State0 +p,ta_MM,PlayerStateString(p),color);

          drawmenu_ItemTextC(tar,mi_Players_AIskil0+p,ta_LM,name                ,color);
          if(g_started)and(length(name)>0)then
            with menu_items[mi_Players_AIskil0+p] do
              if(mi_state>as_off)then
                if(isdefeated)
                then hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_red)
                else   
                  if(isrevealed)
                  then hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_ltgray);

          drawmenu_ItemTextC(tar,mi_Players_Race0+p,ta_MM,str_race[mrace],mic( menu_items[mi_Players_Race0+p].mi_state=as_enabled,false));
          drawmenu_ItemTextC(tar,mi_Players_Team0+p,ta_MM,TeamChar(p)    ,mic( menu_items[mi_Players_Team0+p].mi_state=as_enabled,false));

          if(p>=map_MaxPlayers)
          then drawmenu_ItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[true]      ,c_gray)
          else
            case state of
            ps_human: drawmenu_ItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[isobserver],mic( menu_items[mi_Players_Obs0 +p].mi_state=as_enabled,false));
            ps_AI   : drawmenu_ItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[false]     ,c_gray);
            end;
       end
       else
       begin
          if(not g_started)and(p<map_MaxPlayers)then
            if(menu_items[mi_Players_State0+p].mi_state=as_enabled)then
              drawmenu_ItemTextC(tar,mi_Players_State0+p,ta_MM,'+'+str_ps_AI,c_white);
          if(g_AISlots>0)and(p<map_MaxPlayers)and(not g_started)then
          begin
             drawmenu_ItemTextC(tar,mi_Players_Slot0+p,ta_LM,ai_name(g_AISlots,p)                      ,c_gray);
             drawmenu_ItemTextC(tar,mi_Players_Race0+p,ta_MM,str_race[r_random]                        ,c_gray);
             drawmenu_ItemTextC(tar,mi_Players_Team0+p,ta_MM,b2s(PlayerGetFixedTeams(map_scenario,p)+1),c_gray);
             drawmenu_ItemTextC(tar,mi_Players_Obs0 +p,ta_MM,str_YesNoG[false]                         ,c_gray);
          end;
          if(g_started)then
          begin
             drawmenu_ItemTextC(tar,mi_Players_AIskil0+p,ta_LM,name,c_gray);
             if(length(name)>0)then
               with menu_items[mi_Players_AIskil0+p] do
                 if(mi_state>as_off)then
                   if(isdefeated)
                   then hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_red)
                   else
                     if(isrevealed)
                     then hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_gray);
          end;
          if(p>=map_MaxPlayers)then
          drawmenu_ItemTextC(tar,mi_Players_Obs0+p,ta_MM,str_YesNoG[true],c_gray);
       end;

   for p:=0 to LastPlayer do
     with g_PlayersGame[p] do
     with menu_items[mi_Players_Ping0+p] do
       if(mi_state>as_off)then
       begin
          //layerGetColorDef(p)
          color:=PlayerGetColorCur(p,false);
          if(net_status=ns_none)or(state<>ps_Human)
          then boxColor(tar,mi_x0+font_wh,mi_y0+font_wh,
                            mi_x1-font_wh,mi_y1-font_wh,color)
          else
            with g_PlayersTemp[p] do
              if((net_status<>ns_client)and(p=LocalPlayer  ))
              or((net_status= ns_client)and(p=net_cl_Hoster))
              then draw_text(tar,mi_xc,mi_yc,str_ps_Host,ta_MM,255,color)
              else
                if(net_ping<=999)
                then draw_text(tar,mi_xc,mi_yc,w2s(net_ping),ta_MM,255,color)
                else draw_text(tar,mi_xc,mi_yc,'999'        ,ta_MM,255,color);
       end;

   // SCIRMISH MAP
   drawmenu_ItemCaption(tar,mi_Map_Panel,str_Caption_Map);

   with menu_items[mi_Map_Map] do
   if(mi_state>as_off)then
   draw_sdlsurface(tar,mi_x0+1,mi_y0+1,ui_mminimap);

   drawmenu_ItemText2(tar,mi_Map_Scenario  ,str_map_Scenario  ,str_map_ScenarioL[map_scenario]    ,0);
   drawmenu_ItemText2(tar,mi_Map_Generators,str_map_Generators,str_map_GeneratorsL[map_GeneratorT],0);
   drawmenu_ItemText2(tar,mi_Map_Seed      ,str_map_Seed      ,menu_mseed+vc(mi_Map_Seed)         ,menu_ItemSelected);
   drawmenu_ItemText2(tar,mi_Map_Size      ,str_map_Size      ,i2s(map_Size1)                     ,0);
   drawmenu_ItemText2(tar,mi_Map_Template  ,str_map_Template  ,str_map_TemplateL[map_Template]    ,0);
   drawmenu_ItemText2(tar,mi_Map_Symmetry  ,str_map_Symmetry  ,str_map_SymmertyL[map_Symmetry]    ,0);

   drawmenu_ItemText1(tar,mi_Map_Theme     ,str_themes[theme_i],0);
   drawmenu_ItemText1(tar,mi_Map_Random    ,str_map_Random     ,0);

   // SCIRMISH GAME
   drawmenu_ItemCaption(tar,mi_Game_Panel,str_Caption_GOptions);

   drawmenu_ItemText2(tar,mi_Game_FixedPositions,str_GO_FixedStarts ,str_YesNoC[g_FixedPositions],0);
   drawmenu_ItemText2(tar,mi_Game_AISlots       ,str_GO_AISlots     ,AISlotsSOpt                 ,0);
   drawmenu_ItemText2(tar,mi_Game_NewObservers  ,str_GO_NewObservers,str_YesNoC[g_NewObservers]  ,0);
   drawmenu_ItemText1(tar,mi_Game_Random        ,str_GO_Random      ,0);

   if(not g_started)and(g_LobbyTimer>0)then
   drawmenu_ItemText1(tar,mi_UnderBottomInfoLine,str_lobby_GameStartIn+ir2s(g_LobbyTimer),0);

   // SCIRMISH MULTIPLAYER
   //
   case net_status of
   ns_none  : begin
              drawmenu_ItemCaption(tar,mi_MP_Panel           ,str_Caption_Multiplayer  );
              drawmenu_ItemText1  (tar,mi_MP_ServerToggle    ,str_net_ServerStart    ,0);
              drawmenu_ItemText1  (tar,mi_MP_Connect         ,str_net_Connect        ,0);
              drawmenu_ItemText1  (tar,mi_MP_ClientServerList,str_net_ServerList     ,0);
              end;
   ns_server: begin
              drawmenu_ItemCaption(tar,mi_MP_Panel           ,str_Caption_Multiplayer+': '+str_Caption_Server);
              drawmenu_ItemText1  (tar,mi_MP_ServerToggle    ,str_net_ServerStop     ,0);

              end;
   ns_client: begin
              drawmenu_ItemCaption(tar,mi_MP_Panel           ,str_Caption_Multiplayer+': '+str_Caption_Client);

              drawmenu_ItemText2  (tar,mi_MP_ClientQuality   ,str_net_Quality        ,str_NetQualityL[net_cl_Quality],0);

              if(net_cl_Hoster=255)and(net_cl_svttl<TTLServer)then
              drawmenu_ItemText1(tar,mi_SubCaptionInfoLine,str_net_ConnectedToDed,0);
              end;
   end;

   drawmenu_ItemText1(tar,mi_MP_Disconnect   ,str_net_DisConnect  ,0);
   drawmenu_ItemText2(tar,mi_MP_ServerPort   ,str_net_UDPPort     ,menu_ServerPort   +vc(mi_MP_ServerPort   ),menu_ItemSelected);
   drawmenu_ItemText2(tar,mi_MP_ServerLANVis ,str_net_ServerLANAdv,str_YesNoC[net_svLanAdv],0);
   drawmenu_ItemText2(tar,mi_MP_ClientAddress,str_net_Address     ,str_CutLast(menu_ClientAddress+vc(mi_MP_ClientAddress),30),menu_ItemSelected); //
   drawmenu_ItemText2(tar,mi_Players_Ready   ,str_net_Ready       ,str_YesNoC[PlayerReady ],0);

   drawmenu_MultiplayerChat(tar,mi_MP_ChatList);
   with menu_items[mi_MP_ChatLine] do
   begin
      drawmenu_ItemTextC(tar,mi_MP_ChatLine,ta_RM,str_menu_Chat,c_dgray);
      drawmenu_ItemText2(tar,mi_MP_ChatLine,str_CutLast(net_chat_str+vc(mi_MP_ChatLine),mi_charw),'',0);
   end;
end;

procedure drawmenu_BlockCampaings(tar:pSDL_Surface);
begin
   drawmenu_ItemText1(tar,mi_caption_Campaings  ,str_menu_Campaings     ,255);

   drawmenu_ItemTextC(tar,mi_camp_Difficulty,ta_LA,str_Camp_Difficulty            ,c_white);
   drawmenu_ItemTextC(tar,mi_camp_Difficulty,ta_MM,str_Camp_DifficultyL[camp_diff],c_white);

   drawmenu_ItemTextC(tar,mi_camp_Campaigns ,ta_LA,str_Camp_Campaign              ,c_white);
   drawmenu_ItemTextC(tar,mi_camp_Missions  ,ta_LA,str_Camp_Mission               ,c_white);

   drawmenu_ItemCaption(tar,mi_camp_MissionInfo,str_ui_objectives);


   drawmenu_StringArray(tar,mi_camp_Campaigns,@camp_list,camp_size,camp_scroll,camp_sel,menu_CampLineH,-1,menu_CampListSize,false);

   if(0<=camp_sel)and(camp_sel<camp_size)then
     drawmenu_StringArray(tar,mi_camp_Missions,@camp_mis_list[camp_sel],camp_mis_size[camp_sel],camp_mis_scroll,camp_mis_sel,menu_MissLineH,-1,menu_MissListSize,false);

   {
   mi_camp_MissionInfo    = 248;
   }
end;

function drawmenu_ItemActsStr:shortstring;
begin
   drawmenu_ItemActsStr:='';
   if(GetBBit(@menu_ItemActs,miat_BtnLeft ))then STRADD(@drawmenu_ItemActsStr,str_doc_LMB,sep_slash);
   if(GetBBit(@menu_ItemActs,miat_BtnRight))then STRADD(@drawmenu_ItemActsStr,str_doc_RMB,sep_slash);
   if(GetBBit(@menu_ItemActs,miat_MWhell  ))then STRADD(@drawmenu_ItemActsStr,str_doc_MWH,sep_slash);
{
if(GetBBit(@menu_ItemActs,miat_TextEdit))then
}
end;

procedure drawmenu_SvList(tar:pSDL_Surface);
begin
   drawmenu_ItemText1(tar,mi_caption_SVSearch   ,str_Caption_NetSvList,255);
   // Net search
   with menu_items[mi_NetServers_List] do
   drawmenu_StringArray(tar,mi_NetServers_List ,@net_SvList_lists,net_SvList_Size,net_SvList_scroll,net_SvList_sel,menu_ServerLineH,mi_charw*2,menu_ServerListH,true);

   drawmenu_ItemText1(tar,mi_NetServers_Connect,str_net_Connect      ,0);
   drawmenu_ItemText1(tar,mi_NetServers_Add    ,str_net_ServerListAdd,0);
   drawmenu_ItemText1(tar,mi_NetServers_Delete ,str_FileDelete       ,0);

   drawmenu_ItemText2(tar,mi_MP_ClientAddress,menu_ClientAddress+vc(mi_MP_ClientAddress),'',menu_ItemSelected);
end;

procedure drawmenu_Update(tar:pSDL_Surface); //////////////////////////////////////
var i:byte;
ix,iy:integer;
begin
   // COMMON
   //if(menu_DarkBack)
   //then draw_sdlsurface(tar,(tar^.w div 2)-(spr_MenuBackgroundL^.w div 2),0,spr_MenuBackgroundD)
   //else draw_sdlsurface(tar,(tar^.w div 2)-(spr_MenuBackgroundL^.w div 2),0,spr_MenuBackgroundL);

   boxColor(tar,0,0,spr_MenuBackgroundL^.w,spr_MenuBackgroundL^.h,c_menuback);

   //vlineColor(tar,0     ,0,menu_h,c_white);
   //vlineColor(tar,menu_w-1,0,menu_h,c_white);
   //vlineColor(tar,400,0,600,c_yellow);

   {$IFDEF TESTMODE}
   if(TestMode>0)then
   draw_text(tar,menu_hw,0,'TEST MODE '+b2s(TestMode),ta_MU,255,c_white);
   {$ENDIF}

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
                          : drawmenu_ItemPanel(tar,i,3);
     else                   drawmenu_ItemPanel(tar,i,1);
     end;

   /////////////////////////////////////////////////////////////////////////////
   // Main buttons
   drawmenu_ItemText1(tar,mi_Campaings          ,str_menu_Campaings    ,0);
   drawmenu_ItemText1(tar,mi_Scirmish           ,str_menu_Scirmish     ,0);

   if(g_started)
then drawmenu_ItemText1(tar,mi_SaveLoad         ,str_menu_SaveLoad     ,0)
else drawmenu_ItemText1(tar,mi_SaveLoad         ,str_menu_LoadGame     ,0);

   drawmenu_ItemText1(tar,mi_Replays            ,str_menu_Replays      ,0);
   drawmenu_ItemText1(tar,mi_Settings           ,str_menu_Settings     ,0);
   drawmenu_ItemText1(tar,mi_Help               ,str_menu_Help         ,0);

   if(rpls_pstate=rpls_read)
then drawmenu_ItemText1(tar,mi_Break            ,str_menu_PlaybackStop ,0)
else drawmenu_ItemText1(tar,mi_Break            ,str_menu_Abort        ,0);

   drawmenu_ItemText1(tar,mi_Back               ,str_menu_Back         ,0);
   drawmenu_ItemText1(tar,mi_Exit               ,str_menu_Exit         ,0);
   drawmenu_ItemText1(tar,mi_Surrender          ,str_menu_Surrender    ,0);
   drawmenu_ItemText1(tar,mi_StartNow           ,str_menu_Start        ,0);
   drawmenu_ItemText1(tar,mi_StartTimer         ,str_menu_Start        ,0);
   drawmenu_ItemText1(tar,mi_StopTimer          ,str_menu_Cancel       ,0);

   // MAIN BLOCKs
   if(net_SvList)
   then drawmenu_SvList(tar)
   else
     case menu_page of
     mi_SaveLoad  : drawmenu_BlockSaveLoad(tar);
     mi_Replays   : drawmenu_BlockReplays (tar);
     mi_Settings  : drawmenu_BlockSettings(tar);
     mi_Help      : begin
                       drawmenu_ItemText1(tar,mi_caption_Help,str_menu_Help,255);

                       drawmenu_ItemText1(tar,mi_help_Credits      ,str_help_Credits      ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_GameControls ,str_help_GameControls ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_GameHotKeys  ,str_help_GameHotKeys  ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_GameUI       ,str_help_GameUI       ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_GameMechanics,str_help_GameMechanics,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_UnitsInfo    ,str_help_UnitsInfo    ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_UnitsBalance ,str_help_BalanceTable ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_UpgradesInfo ,str_help_UpgradesInfo ,menu_HelpPage);
                       drawmenu_ItemText1(tar,mi_help_Other        ,str_help_Other        ,menu_HelpPage);

                       case menu_HelpPage of
                       mi_help_GameControls,
                       mi_help_GameMechanics,
                       mi_help_GameHotKeys,
                       mi_help_GameUI,
                       mi_help_Other,
                       mi_help_Credits     : drawmenu_BlockHelpInfo(tar);
                       mi_help_UpgradesInfo,
                       mi_help_UnitsInfo   : begin
                                             drawmenu_BlockHelpObjInfo(tar);
                                             drawmenu_BlockHelpInfo(tar);
                                             drawmenu_ScrollBar(tar,mi_help_InfoPanel,menu_HelpUIDScroll,menu_HelpIDBlockH,menu_HelpUIDH+menu_HelpIDBlockH);
                                             end;
                       mi_help_UnitsBalance: begin
                                             drawmenu_BlockHelpObjInfo(tar);
                                             drawmenu_BlockHelpUnitsBalance(tar);
                                             drawmenu_ScrollBar(tar,mi_help_InfoPanel,menu_HelpUIDScroll,menu_HelpIDBlockH,menu_HelpUIDH+menu_HelpIDBlockH);
                                             end;
                       end;
                    end;
     else
       case g_type of
       gt_scirmish: drawmenu_BlockScirmish (tar);
       gt_campaing: drawmenu_BlockCampaings(tar);
       end;
     end;

   if(menu_hint_pos[menu_ItemTarget]>0)then
     with menu_items[menu_hint_pos[menu_ItemTarget]] do
       draw_text(tar,mi_x1-font_w1,mi_y0-font_wh,drawmenu_ItemActsStr+str_menu_hint[menu_ItemTarget],ta_RB,255,c_white);

   //menu_image
   if(menu_image<>nil)then
   begin
      boxColor(tar,0,0,menu_w,menu_h,c_iblack);
      ix:=menu_hw-(menu_image^.w div 2);
      iy:=menu_hh-(menu_image^.h div 2);
      draw_text(tar,ix+(menu_image^.w div 2),iy                      ,menu_image_caption ,ta_MB,255,c_white);
      draw_text(tar,ix+(menu_image^.w div 2),iy+menu_image^.h+font_wh,str_menuMsg_HintImg,ta_MU,255,c_white);
      draw_sdlsurface(tar,ix,iy,menu_image);
      rectangleColor(tar,ix,iy,
                         ix+menu_image^.w,iy+menu_image^.h,c_white);
   end;

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
      mmbt_DeleteReplay,
      mmbt_DeleteServer : begin
                             hlineColor(tar,menu_msg_x0,menu_msg_x1,menu_msg_btn1y0,c_white);
                             vlineColor(tar,menu_msg_btn1x1,menu_msg_btn1y0,menu_msg_btn1y1,c_white);
                             draw_text(tar,menu_msg_btn1tx,menu_msg_btny,str_YesNoC[true ]+'('+str_ActionHotKey(iAct_Return)+')'
                                                                                          ,ta_MM,menu_ListLineWCharsh,c_gray);
                             draw_text(tar,menu_msg_btn2tx,menu_msg_btny,str_YesNoC[false],ta_MM,menu_ListLineWCharsh,c_gray);
                          end;
      end;
   end;
end;

procedure draw_Menu;
var tx,ty:integer;
begin
   if(menu_redraw_pause>0)then menu_redraw_pause-=1;
   if(menu_redraw)and(menu_redraw_pause=0)then
   begin
      PlayersUpdateColorSchema(LocalPlayer);
      if(g_FixedPositions)and(not g_Started)and(menu_items[mi_Map_Map].mi_state>as_off)then
        map_RedrawMenuMinimap;
      drawmenu_Update(menu_Surface);

      if(menu_DarkBack)
      then draw_sdlsurface(menu_Background,0,0,spr_MenuBackgroundD)
      else draw_sdlsurface(menu_Background,0,0,spr_MenuBackgroundL);
      draw_sdlsurface(menu_Background,(menu_Background^.w div 2)-menu_hw,
                                      (menu_Background^.h div 2)-menu_hh,menu_Surface);

      drawmenu_MakeBig;
      menu_redraw:=false;
      menu_redraw_pause:=fr_fpsd10;
   end;

   draw_sdlsurface(vid_screen,menu_Background_x,menu_Background_y,menu_BackgroundSC);

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


