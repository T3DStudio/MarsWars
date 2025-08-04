

function mic(enbl,sel:boolean):cardinal;
begin
   mic:=c_white;
   if(enbl=false)then mic:=c_gray
   else
     if(sel)then mic:=c_yellow;
end;

{
   case menu_s2 of
   ms2_camp : begin
                 draw_text(tar,ui_menu_csm_xt0,_yt(1),str_cmpdif+str_cmpd[cmp_skill],ta_left,255,mic(not g_started,false));
                 y:=_yl(2);
                 hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_white);
                 for t:=0 to vid_camp_m do
                 begin
                    i:=t+cmp_scroll;
                    if(i<=LastMission)then
                    begin
                       y:=_yl(t+2);
                       draw_text(tar,ui_menu_csm_xt0,_yt(t+2),str_camp_name[i],ta_left,255,mic(not g_started,i=cmp_sel));
                       if(i=cmp_sel)then
                       begin
                          hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y,c_gray);
                          hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,y+ui_menu_csm_ys,c_gray);
                       end;
                    end;
                 end;
              end;
   ms2_mult : begin

              end;
   end;
end;  }

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
      menu_SurfaceSC  :=zoomSurface(menu_Surface,menu_sc_cx,menu_sc_cx,byte(menu_ScaleSmooth));
      menu_sc_cx:=1/menu_sc_cx;
   end
   else
   begin
      menu_sc_cx:=1;
      menu_SurfaceSC  :=menu_Surface;
   end;

   menu_sc_x:=(vid_vw-menu_SurfaceSC^.w) div 2;
   menu_sc_y:=(vid_vh-menu_SurfaceSC^.h) div 2;
end;

procedure d_MenuItemPanel(tar:pSDL_Surface;mi,border:byte);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        boxColor(tar,mi_x0,mi_y0,mi_x1,mi_y1,c_black);
        draw_rectw(tar,mi_x0+1,mi_y0+1,mi_x1-1,mi_y1-1,border,-1,c_ltgray);
     end;
end;

procedure d_MenuItemCaption(tar:pSDL_Surface;mi:byte;text:shortstring);
var color:cardinal;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        if(mi_state=1)
        then color:=c_gray
        else color:=c_white;

        rectangleColor(tar,mi_xc-menu_ItemCaptionhW,mi_y0,
                           mi_xc+menu_ItemCaptionhW,mi_y0+menu_BigButtonhH,c_ltgray);
        draw_text(tar,mi_xc,mi_y0+font_hw ,text,ta_MU,255,color);
     end;
end;

procedure d_menu_ScrollBar(tar:pSDL_Surface;mi:byte;scrolli,scrolls,scrollmax:integer);
var posCY,
    barh:integer;
begin
   with menu_items[mi] do
   begin
      barh :=(mi_y1-mi_y0);
      if(scrolls<scrollmax)then
      begin
         barh :=mm3i(1,round((mi_y1-mi_y0)*(scrolls/scrollmax)),barh);
         posCY:=mi_y0+round((mi_y1-mi_y0-barh)*(scrolli/(scrollmax-scrolls)));
      end
      else posCY:=mi_y0;

      //barh-=2;
      boxColor(tar,mi_x0+1,posCY,mi_x0+2,posCY+barh,c_lime);
   end;
end;
procedure d_MenuItemList(tar:pSDL_Surface;mi:byte;plist:PTStringList;listSize,scroll,selected,lineH,lineWChars,listH:integer);
var t,i,y:integer;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        if(listH<=0)then exit;

        for t:=0 to listH-1 do
        begin
           i:=t+scroll;
           if(0<=i)and(i<listSize)then
           begin
              y:=mi_y0+t*lineH;

              draw_text(tar,mi_x0+font_hw,y+font_hw,str_Trim(b2s(i+1)+'] '+plist^[i],lineWChars),ta_LU,255,mic(mi_state>1,i=selected));
              if(i=selected)then
              begin
                 hlineColor(tar,mi_x0,mi_x1,y        ,c_gray);
                 hlineColor(tar,mi_x0,mi_x1,y+lineH-1,c_gray);
              end;
           end;
        end;

        d_menu_ScrollBar(tar,mi,scroll,listH,listSize);
     end;
end;

procedure d_MenuItemInfo(tar:pSDL_Surface;mi:byte;text1,text2:shortstring);
var
color:cardinal;
y    :integer;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        if(mi_state=1)
        then color:=c_gray
        else color:=c_white;

        draw_text(tar,mi_x0+font_hw,mi_y0+menu_BigButtonH,text1,ta_LU,mi_charw,color,@y);
        if(length(text2)>0)then
        draw_text(tar,mi_x0+font_hw,y                    ,text2,ta_LU,mi_charw,color);
     end;
end;
procedure d_MenuItemTextC(tar:pSDL_Surface;mi,pos:byte;text:shortstring;color:cardinal);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        case pos of
        ta_LU  : draw_text(tar,mi_x0+font_hw,mi_y0+font_hw,text,pos,mi_charw,color);
        ta_MU  : draw_text(tar,mi_xc        ,mi_y0+font_hw,text,pos,mi_charw,color);
        ta_RU  : draw_text(tar,mi_x1-font_hw,mi_y0+font_hw,text,pos,mi_charw,color);

        ta_LM  : draw_text(tar,mi_x0+font_hw,mi_yc        ,text,pos,mi_charw,color);
        ta_MM  : draw_text(tar,mi_xc        ,mi_yc        ,text,pos,mi_charw,color);
        ta_RM  : draw_text(tar,mi_x1-font_hw,mi_yc        ,text,pos,mi_charw,color);

        ta_LB  : draw_text(tar,mi_x0+font_hw,mi_y1-font_hw,text,pos,mi_charw,color);
        ta_MB  : draw_text(tar,mi_xc        ,mi_y1-font_hw,text,pos,mi_charw,color);
        ta_RB  : draw_text(tar,mi_x1-font_hw,mi_y1-font_hw,text,pos,mi_charw,color);
        end;
     end;
end;

procedure d_MenuItemText(tar:pSDL_Surface;mi,pos:byte;text:shortstring;selectedVal:byte);
var color:cardinal;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        if(mi_state=1)
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
     if(mi_state>0)then
       d_MenuItemText(tar,mi,ta_MM,text,selectedVal);
end;
procedure d_menuItemText2(tar:pSDL_Surface;mi:byte;text1,text2:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        d_MenuItemText(tar,mi,ta_LM,text1,selectedVal);
        d_MenuItemText(tar,mi,ta_RM,text2,selectedVal);
     end;
end;

procedure d_MenuItemTextBar(tar:pSDL_Surface;mi:byte;text:shortstring;vcur,vmin,vmax:integer;selectedVal:byte);
var tx:integer;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        d_MenuItemText(tar,mi,ta_LM  ,text     ,selectedVal);

        tx:=mi_x1-menu_BarStepX;
        vlineColor(tar,tx+1,mi_y0,mi_y1-1,c_ltgray);
        draw_text(tar,tx+font_hw,mi_yc ,'>',ta_LM ,255,c_white);

        tx-=vmax-vmin;
        draw_text(tar,tx-font_hw,mi_yc ,i2s(vcur)+' <',ta_RM ,255,c_white);
        vlineColor(tar,tx-1,mi_y0,mi_y1-1,c_ltgray);
        boxColor(tar,tx,mi_yc-font_hw,tx+vcur-vmin,mi_yc+font_hw,c_lime);
     end;
end;

procedure d_updmenu(tar:pSDL_Surface);
var i,p:byte;
// short name function for string editing char
function vc(mi:byte):char;
begin
   vc:=chat_type[menu_ItemSelected<>mi];
end;
begin
   draw_sdlsurface(tar,0,0,spr_mback);
   draw_sdlsurface(tar,menu_hw-(spr_mlogo^.w div 2),0,spr_mlogo);

   draw_text(tar,menu_w,menu_h,str_ver,ta_RB,255,c_white);

   if(TestMode>0)then
   draw_text(tar,menu_hw,0,'TEST MODE '+b2s(TestMode)    ,ta_MU,255,c_white);

   draw_text(tar,menu_hw,menu_h, str_cprt         ,ta_MB,255,c_white);

   // draw pannels
   for i in byte do
     case i of
mi_Players_NameC,
mi_Players_StateC,
mi_Players_RaceC,
mi_Players_TeamC,
mi_Players_PingC,
mi_Players_ColorC,
mi_Map_Theme
                    :;
mi_caption_Campaings,
mi_caption_Scirmish,
mi_caption_SaveLoad,
mi_caption_Replays,
mi_caption_Settings : d_MenuItemPanel(tar,i,3);
     else             d_MenuItemPanel(tar,i,1);
     end;


   /////////////////////////////////////////////////////////////////////////////
   // Captions
   d_menuItemText1(tar,mi_caption_Campaings ,str_menu_Campaings  ,255);

   if(rpls_pstate=rpls_read)
then d_menuItemText1(tar,mi_caption_Scirmish,str_menu_Playback   ,255)
else d_menuItemText1(tar,mi_caption_Scirmish,str_menu_Scirmish   ,255);

   if(g_started)
then d_menuItemText1(tar,mi_caption_SaveLoad,str_menu_SaveLoad   ,255)
else d_menuItemText1(tar,mi_caption_SaveLoad,str_menu_LoadGame   ,255);

   d_menuItemText1(tar,mi_caption_Replays   ,str_menu_Replays    ,255);
   d_menuItemText1(tar,mi_caption_Settings  ,str_menu_Settings   ,255);

   /////////////////////////////////////////////////////////////////////////////
   // Main buttons
   d_MenuItemText1(tar,mi_Campaings         ,str_menu_Campaings  ,0);

   d_menuItemText1(tar,mi_Scirmish          ,str_menu_Scirmish   ,0);

   if(g_started)
then d_menuItemText1(tar,mi_SaveLoad        ,str_menu_SaveLoad   ,0)
else d_menuItemText1(tar,mi_SaveLoad        ,str_menu_LoadGame   ,0);

   d_menuItemText1(tar,mi_Replays           ,str_menu_Replays    ,0);
   d_menuItemText1(tar,mi_Settings          ,str_menu_Settings   ,0);

   if(rpls_pstate=rpls_read)
then d_menuItemText1(tar,mi_Break           ,str_menu_PlaybackStop,0)
else d_menuItemText1(tar,mi_Break           ,str_menu_Break      ,0);

   d_menuItemText1(tar,mi_Back              ,str_menu_Back       ,0);
   d_menuItemText1(tar,mi_Exit              ,str_menu_Exit       ,0);
   d_menuItemText1(tar,mi_Start             ,str_menu_Start      ,0);
   d_menuItemText1(tar,mi_Surrender         ,str_menu_Surrender  ,0);

   // SETTINGS LIST
   d_menuItemText1(tar,mi_settings_Game     ,str_S_Game    ,menu_SettingsPage);
   d_menuItemText1(tar,mi_settings_Record   ,str_S_Replay  ,menu_SettingsPage);
   d_menuItemText1(tar,mi_settings_Video    ,str_S_Video   ,menu_SettingsPage);
   d_menuItemText1(tar,mi_settings_Sound    ,str_S_Sound   ,menu_SettingsPage);

   // SETTINGS  GAME

   d_menuItemText2(tar,mi_SG_ColoredShadows  ,str_SG_ColoredShadow  ,b2cc[ui_ColoredShadow]                     ,0);
   d_MenuItemText2(tar,mi_SG_ShowAPM         ,str_SG_ShowAPM        ,b2cc[ui_ShowAPM          ]                 ,0);
   d_MenuItemText2(tar,mi_SG_HealthBars      ,str_SG_HealthBars     ,str_SG_HealthBarsL[ui_HealthBars ]         ,0);
   d_MenuItemText2(tar,mi_SG_RightClickAction,str_SG_RightClickAct  ,str_SG_RightClickActL[m_RightClickAct]     ,0);
   d_MenuItemText2(tar,mi_SG_MouseScroll     ,str_SG_MouseScroll    ,b2cc[ui_MouseScroll]                       ,0);
   d_MenuItemText2(tar,mi_SG_PlayerName      ,str_SG_PlayerName     ,PlayerName+vc(mi_SG_PlayerName)            ,menu_ItemSelected);
   d_MenuItemText2(tar,mi_SG_Language        ,str_SG_Language       ,str_SG_LanguageL[ui_language]              ,0);
   d_MenuItemText2(tar,mi_SG_ControlPanelPos ,str_SG_ControlPanelPos,str_SG_ControlPanelPosL[ui_ControlPanelPos],0);
   d_MenuItemText2(tar,mi_SG_PlayersColor    ,str_SG_PlayersColor   ,str_SG_PlayersColorL[ui_PlayersColor]      ,0);

   d_MenuItemTextBar(tar,mi_SG_ScrollSpeed   ,str_SG_ScrollSpeed    ,ui_CamSpeed,1,vid_MaxCamSpeed,0);  //

   // SETTINGS  GAME RECORDING
   d_menuItemText2(tar,mi_SR_RecordGames     ,str_SR_RecordGames    ,b2cc[rpls_Record]                          ,0);
   d_menuItemText2(tar,mi_SR_RecordPrefix    ,str_SR_ReplayPrefix   ,rpls_NamePrefix+vc(mi_SR_RecordPrefix)     ,menu_ItemSelected);
   d_menuItemText2(tar,mi_SR_RecordQuality   ,str_SR_Quality        ,str_ReplayQualityL[rpls_Quality]           ,0);

   // SETTINGS  VIDEO
   d_menuItemText2(tar,mi_SV_ResolutionW     ,str_SV_ResolutionW    ,i2s(menu_ResolutionWi)+vc(mi_SV_ResolutionW),menu_ItemSelected);
   d_menuItemText2(tar,mi_SV_ResolutionH     ,str_SV_ResolutionH    ,i2s(menu_ResolutionHi)+vc(mi_SV_ResolutionH),menu_ItemSelected);
   d_menuItemText1(tar,mi_SV_ResolutionApply ,str_SV_ResolutionApply,0);

   d_menuItemText2(tar,mi_SV_Windowed        ,str_SV_Windowed       ,b2cc[vid_windowed]    ,0);
   d_menuItemText2(tar,mi_SV_ShowFPS         ,str_SV_ShowFPS        ,b2cc[vid_ShowFPS ]    ,0);
   d_menuItemText2(tar,mi_SV_MenuScaling     ,str_SV_MenuScale      ,b2cc[menu_scale  ]    ,0);
   d_menuItemText2(tar,mi_SV_SmoothScaled    ,str_SV_MenuScaleSmooth,b2cc[menu_ScaleSmooth],0);

   // SETTINGS  SOUNDS
   d_MenuItemTextBar(tar,mi_SS_SoundVolume   ,str_SS_SoundVolume,snd_SoundVolume,0,snd_MaxSoundVolume,0);
   d_MenuItemTextBar(tar,mi_SS_MusicVolume   ,str_SS_MusicVolume,snd_MusicVolume,0,snd_MaxSoundVolume,0);

   d_menuItemText1(tar,mi_SS_PlayerNext      ,str_SS_NextTrack  ,0);
   d_menuItemText1(tar,mi_SS_ReloadPlaylist  ,str_SS_ReloadMusic,0);

   d_menuItemText2(tar,mi_SS_PlaylistSize    ,str_SS_MusicListSize  ,b2s(snd_musicListSize),0);

   // SAVE LOAD
   d_MenuItemList(tar,mi_SaveLoad_list,@svld_list,svld_list_size,svld_list_scroll,svld_list_sel,menu_ListLineH,menu_ListLineWChars,menu_BaseListH);

   d_MenuItemCaption(tar,mi_SaveLoad_info,str_FileInfo );
   d_MenuItemInfo   (tar,mi_SaveLoad_info,svld_str_info1,svld_str_info2);

   d_menuItemText (tar,mi_SaveLoad_fname,ta_LM,svld_str_fname+vc(mi_SaveLoad_fname),menu_ItemSelected);
   d_menuItemText1(tar,mi_SaveLoad_save      ,str_FileSave  ,0);
   d_menuItemText1(tar,mi_SaveLoad_load      ,str_FileLoad  ,0);
   d_menuItemText1(tar,mi_SaveLoad_delete    ,str_FileDelete,0);

   // REPLAYS
   d_MenuItemList(tar,mi_Replays_list,@rpls_list,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_ListLineH,menu_ListLineWChars,menu_BaseListH);

   d_MenuItemCaption(tar,mi_Replays_info,str_FileInfo );
   d_MenuItemInfo   (tar,mi_Replays_info,rpls_str_info1,rpls_str_info2);

   d_menuItemText1(tar,mi_Replays_play   ,str_FilePlay,0);
   d_menuItemText1(tar,mi_Replays_delete ,str_FileDelete,0);

   // SCIRMISH PLAYERS
   d_MenuItemCaption(tar,mi_Players_Panel,str_Caption_Players);

   d_MenuItemTextC(tar,mi_Players_StateC,ta_LM,str_PT_State ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_NameC ,ta_MM,str_PT_Player,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_RaceC ,ta_MM,str_PT_Race  ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_TeamC ,ta_MM,str_PT_Team  ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_ColorC,ta_MM,str_PT_Color ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_PingC ,ta_MM,str_PT_Ping  ,c_ltgray);

   d_MenuItemText (tar,mi_Players_Ready ,ta_LM  ,str_net_Ready+b2cc[PlayerReady],0);

   for p:=0 to LastPlayer do
     with g_players[p] do
       if(state<>ps_None)then
       begin
          d_MenuItemTextC(tar,mi_Players_Name0 +p,ta_LM,name               ,mic(menu_items[mi_Players_Name0 +p].mi_state>1,p=LocalPlayer));
          d_MenuItemTextC(tar,mi_Players_State0+p,ta_MM,PlayerStatusChar(p),mic(menu_items[mi_Players_State0+p].mi_state>1,p=LocalPlayer));

          if(observer)or(p>=map_MaxPlayers)then
          begin
          d_MenuItemTextC(tar,mi_Players_Race0 +p,ta_MM,str_observer       ,c_gray);
          d_MenuItemTextC(tar,mi_Players_Team0 +p,ta_MM,'-'                ,mic((menu_items[mi_Players_Team0 +p].mi_state>1)and(p<map_MaxPlayers),false        ));
          end
          else
          begin
          d_MenuItemTextC(tar,mi_Players_Race0 +p,ta_MM,str_race[mrace]    ,mic(menu_items[mi_Players_Race0 +p].mi_state>1,false        ));
          if(map_scenario in mc_fixed_teams)
     then d_MenuItemTextC(tar,mi_Players_Team0 +p,ta_MM,
                                     b2s(PlayerGetFixedTeams(map_scenario,p)+1),mic(menu_items[mi_Players_Team0 +p].mi_state>1,false        ))
     else d_MenuItemTextC(tar,mi_Players_Team0 +p,ta_MM,b2s(team+1)        ,mic(menu_items[mi_Players_Team0 +p].mi_state>1,false        ));
          end;

          if(defeated)and(G_Started)then
            with menu_items[mi_Players_Name0+p] do
              if(mi_state>0)then
                hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_red);
       end
       else
       begin
          if(g_AISlots>0)then
          begin
             if(p<map_MaxPlayers)then
             begin
                d_MenuItemTextC(tar,mi_Players_Name0+p,ta_LM,str_ps_comp+' '+b2s(g_AISlots)            ,c_gray);
                d_MenuItemTextC(tar,mi_Players_Race0+p,ta_MM,str_race[r_random]                        ,c_gray);
                d_MenuItemTextC(tar,mi_Players_Team0+p,ta_MM,b2s(PlayerGetFixedTeams(map_scenario,p)+1),c_gray);
             end
             else
                d_MenuItemTextC(tar,mi_Players_Race0+p,ta_MM,str_observer       ,c_gray);
          end;
          if(not g_started)and(p<map_MaxPlayers)then
            d_MenuItemTextC(tar,mi_Players_State0+p,ta_MM,'+',c_lime);
       end;

   for p:=0 to LastPlayer do
     with menu_items[mi_Players_Ping0+p] do
       if(mi_state>0)then
         if(net_status=ns_none)
         then boxColor(tar,mi_x0+font_hw,mi_y0+font_hw,
                           mi_x1-font_hw,mi_y1-font_hw,PlayerGetColor(p,false))
         else ;

   // SCIRMISH MAP
   d_MenuItemCaption(tar,mi_Map_Panel,str_Caption_Map);

   with menu_items[mi_Map_Map] do
   if(mi_state>0)then
   draw_sdlsurface(tar,mi_x0+1,mi_y0+1,ui_mminimap);

   d_menuItemText2(tar,mi_Map_Scenario  ,str_map_Scenario  ,str_map_ScenarioL[map_scenario]    ,0);
   d_menuItemText2(tar,mi_Map_Generators,str_map_Generators,str_map_GeneratorsL[map_generators],0);
   d_menuItemText2(tar,mi_Map_Seed      ,str_map_Seed      ,menu_mseed+vc(mi_Map_Seed)         ,menu_ItemSelected);
   d_menuItemText2(tar,mi_Map_Size      ,str_map_Size      ,i2s(map_Size)                      ,0);
   d_menuItemText2(tar,mi_Map_Obstacles ,str_map_Obstacles ,strMX(map_ObstaclesF)               ,0);
   d_menuItemText2(tar,mi_Map_Symmetry  ,str_map_Symmetry  ,b2cc[map_Symmetry]                 ,0);

   d_menuItemText1(tar,mi_Map_Theme     ,theme_name[theme_i],0);
   d_menuItemText1(tar,mi_Map_Random    ,str_map_Random     ,0);

   // SCIRMISH GAME
   d_MenuItemCaption(tar,mi_Game_Panel,str_Caption_GOptions);

   d_menuItemText2(tar,mi_Game_FixedPositions,str_GO_FixedStarts,b2cc[g_FixedPositions]      ,0);
   d_menuItemText2(tar,mi_Game_AISlots       ,str_GO_AISlots    ,ai_name(g_AISlots)          ,0);
   d_menuItemText2(tar,mi_Game_DefeatedObs   ,str_GO_DefeatedObs,b2cc[g_DefeatedObs]         ,0);
   d_menuItemText1(tar,mi_Game_Random        ,str_GO_Random     ,0);

   // SCIRMISH MULTIPLAYER
   //
   case net_status of
   ns_none  : begin
              d_MenuItemCaption(tar,mi_MP_Panel        ,str_Caption_Multiplayer);
              d_menuItemText1  (tar,mi_MP_ServerToggle ,str_net_ServerStart  ,0);
              d_menuItemText1  (tar,mi_MP_Connect      ,str_net_Connect      ,0);
              d_menuItemText1  (tar,mi_MP_ClientLANSearch,str_net_LANSearch ,0);
              end;
   ns_server: begin
              d_MenuItemCaption(tar,mi_MP_Panel        ,str_Caption_Server     );
              d_menuItemText1  (tar,mi_MP_ServerToggle ,str_net_ServerStop   ,0);
              d_menuItemText2  (tar,mi_MP_Status       ,str_net_UDPPort      ,menu_ServerPort   ,0);
              end;
   ns_client: begin
              d_MenuItemCaption(tar,mi_MP_Panel        ,str_Caption_Client     );
              d_menuItemText2  (tar,mi_MP_Status       ,net_cl_StatusStr     ,menu_ClientAddress,0);
              d_menuItemText2  (tar,mi_MP_ClientQuality,str_net_Quality     ,str_NetQualityL[net_cl_Quality],0);
              end;
   end;

   d_menuItemText1(tar,mi_MP_Disconnect   ,str_net_DisConnect,0);
   d_menuItemText2(tar,mi_MP_ServerPort   ,str_net_UDPPort  ,menu_ServerPort   +vc(mi_MP_ServerPort   ),menu_ItemSelected);
   d_menuItemText2(tar,mi_MP_ClientAddress,str_net_Address  ,menu_ClientAddress+vc(mi_MP_ClientAddress),menu_ItemSelected);

   {

   mi_MP_Chat             = 189;  net_chat_str

   case net_status of
   ns_none  : begin
                 draw_text(tar,ui_menu_csm_xt1, y, str_Caption_Server, ta_LU,255, c_white);
                 draw_text(tar,ui_menu_csm_xt2, y,str_svup[net_status=ns_server]        , ta_RU ,255, mic(menu_NetServer(net_status<>ns_server,true),false));
                 vlineColor(tar,ui_menu_csm_xc, _yl(2),_yl(2)+ui_menu_csm_ys, c_gray);
                 y:=_yt(3);
                 draw_text(tar,ui_menu_csm_xt0, y,str_net_UDPPort                           , ta_LU  ,255 ,mic((net_status=ns_none),menu_ItemSelected=87));
                 draw_text(tar,ui_menu_csm_xt2, y,net_sv_pstr+chat_type[menu_ItemSelected<>87]  , ta_RU ,255 ,mic((net_status=ns_none),menu_ItemSelected=87));

                 y:=_yt(5);
                 draw_text(tar,ui_menu_csm_xt1, y, str_Caption_Client , ta_LUta_LU,255, c_white);
                 draw_text(tar,ui_menu_csm_xt2, y, str_net_Connect[net_status=ns_client]    , ta_RU ,255, mic(menu_NetClient(net_status<>ns_client,true),false));
                 vlineColor(tar,ui_menu_csm_xc, _yl(5),_yl(5)+ui_menu_csm_ys, c_gray);

                 y:=_yt(6);
                 draw_text(tar,ui_menu_csm_xt0, y, net_cl_svstr+chat_type[menu_ItemSelected<>90], ta_LU  ,255, mic((net_status=ns_none),menu_ItemSelected=90));
                 y:=_yt(7);
                 draw_text(tar,ui_menu_csm_xt0, y, str_net_Quality+str_npnua[net_pnui]         , ta_LU  ,255, mic((net_status<>ns_server),false));
                 if(g_cl_units>0)then
                 draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                          ta_RU ,255, c_white);
              end;
   ns_server: begin
                 for t:=2 to 4 do hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(t),c_gray);

                 y:=_yt(1);
                 draw_text(tar,ui_menu_csm_xt0, y,str_svup[net_status=ns_server]        , ta_LU  ,255, mic(menu_NetServer(net_status<>ns_server,true),false));
                 draw_text(tar,ui_menu_csm_xt2, y,str_net_UDPPort+net_sv_pstr               , ta_RU ,255 ,mic(false        ,false));
              end;
   ns_client: begin
                 for t:=2 to 4 do hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(t),c_gray);

                 y:=_yt(1);
                 draw_text(tar,ui_menu_csm_xt0, y, str_net_Connect[net_status=ns_client]    , ta_LU ,255, mic(menu_NetClient(net_status<>ns_client,true),false));
                 draw_text(tar,ui_menu_csm_xt2, y, net_cl_svstr                         , ta_RU,255, mic(false        ,false));

                 y:=_yt(2);
                 draw_text(tar,ui_menu_csm_xt0, y, str_net_Quality+str_npnua[net_pnui]         , ta_LU  ,255, mic((net_status<>ns_server),false));
                 if(g_cl_units>0)then
                 draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                          ta_RU ,255, c_white);
              end;
   end;
   // chat
   case net_status of
   ns_server,
   ns_client: begin
                 draw_text(tar,ui_menu_csm_xc, _yt(3), str_menu_chat, ta_MU,255, mic((net_status<>ns_none),menu_ItemSelected=100));

                 y:=_yt(11)+1;
                 MakeLogListForDraw(HPlayer,ui_menu_chat_width,ui_menu_chat_height,lmts_menu_chat);
                 if(ui_log_n>0)then
                   for t:=0 to ui_log_n-1 do
                     if(ui_log_color[t]>0)then draw_text(tar,ui_menu_csm_xct,y-t*ui_menu_csm_ycs,ui_log_lines[t],ta_LU,255,ui_log_color[t]);

                 hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(12),c_gray);
                 draw_text(tar,ui_menu_csm_xct, _yt(12), net_chat_str+chat_type[menu_ItemSelected<>100] , ta_chat,ui_menu_chat_width, c_white);
              end;
   end;
   }

   // SCIRMISH REPLAY
   d_MenuItemCaption(tar,mi_ReplayInfo_Panel,str_FileInfo);

   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)then
   d_MenuItemInfo   (tar,mi_ReplayInfo_Panel,rpls_list[rpls_list_sel],'');

   //mi_ReplayInfo_Panel

    {

   // replays
   draw_text(tar,ui_menu_csm_xt1, y, str_replay             , ta_LU  ,255, c_white);
   draw_text(tar,ui_menu_csm_xt2, y, str_rstatus[rpls_pstate], ta_RU ,255, mic( menu_ReplayStatusToggleEnabled ,rpls_pstate>rpls_none));

   if(rpls_pstate>rpls_none)and(g_cl_units>0)then
   draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units), ta_RU,255, c_white);


   if(menu_ihint>0)then
   begin
      if(menu_ihintpi<=menu_ihintn)then
        draw_text(tar,menu_ihintlx[menu_ihintpi],menu_ihintly[menu_ihintpi],str_menu_hint[menu_ihint],ta_MU,255,c_white);
   end;

   case G_Started of
false: begin
          draw_text(tar, 70,554, str_menu_Exit , ta_MU,255, c_white);
          case net_status  of
          ns_server,
          ns_none   : draw_text(tar,730,554, str_menu_Start, ta_MU,255, mic(PlayersReadyStatus,false));
          ns_client : ;
          end;
       end;
true : begin
          draw_text(tar, 70,554, str_menu_Back , ta_MU,255, c_white);

          if(menu_surrender(true))then
          begin
             draw_sdlsurface(tar,360,542,spr_mbtn);
             draw_text(tar,400,554,str_menu_Surrender,ta_MU,255, c_white);
          end;

          draw_text(tar,730,554, str_menu_Break     , ta_MU,255, c_white);
       end;
   end;

   D_MMap    (tar);
   D_MPlayers(tar);
   D_M1      (tar);
   D_M2      (tar); }
end;

procedure D_Menu;
var tx,ty:integer;
begin
   if(menu_redraw)then
   begin
      PlayersUpdateColorSchema(LocalPlayer);

      d_updmenu(menu_Surface);
      vid_MakeBigMenu;
      menu_redraw:=false;
   end;

   draw_sdlsurface(vid_screen,menu_sc_x,menu_sc_y,menu_SurfaceSC);

   if(vid_ShowFPS)then draw_text(vid_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_RU,255,c_white);

   draw_sdlsurface(vid_screen,mouse_x,mouse_y,spr_cursor);
   if(menu_ItemActs>0)then
   begin
      tx:=mouse_x+(spr_cursor^.w div 2);
      ty:=mouse_y+(spr_cursor^.w div 2);
      if((menu_ItemActs and %00000111)>0)then
      begin
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_MLB[GetBBit(@menu_ItemActs,0)]);
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_MMB[GetBBit(@menu_ItemActs,1)]);
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_MRB[GetBBit(@menu_ItemActs,2)]);
         tx+=spr_CursorHint_MLB[true]^.w;
      end;
      if(GetBBit(@menu_ItemActs,3))then
         draw_sdlsurface(vid_screen,tx,ty,spr_CursorHint_Edit);
   end;
end;


