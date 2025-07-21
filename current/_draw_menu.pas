

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
                 case net_status of
                 ns_none  : begin
                               t:=ui_menu_csm_y0+ui_menu_csm_ys;

                               while (t<ui_menu_csm_y1) do
                               begin
                                  t+=ui_menu_csm_ys;
                                  hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,t,c_gray);
                               end;

                               y:=_yt(2);
                               draw_text(tar,ui_menu_csm_xt1, y, str_server, ta_left,255, c_white);
                               draw_text(tar,ui_menu_csm_xt2, y,str_svup[net_status=ns_server]        , ta_right ,255, mic(menu_NetServer(net_status<>ns_server,true),false));
                               vlineColor(tar,ui_menu_csm_xc, _yl(2),_yl(2)+ui_menu_csm_ys, c_gray);
                               y:=_yt(3);
                               draw_text(tar,ui_menu_csm_xt0, y,str_udpport                           , ta_left  ,255 ,mic((net_status=ns_none),menu_item=87));
                               draw_text(tar,ui_menu_csm_xt2, y,net_sv_pstr+chat_type[menu_item<>87]  , ta_right ,255 ,mic((net_status=ns_none),menu_item=87));

                               y:=_yt(5);
                               draw_text(tar,ui_menu_csm_xt1, y, str_client , ta_left,255, c_white);
                               draw_text(tar,ui_menu_csm_xt2, y, str_connect[net_status=ns_client]    , ta_right ,255, mic(menu_NetClient(net_status<>ns_client,true),false));
                               vlineColor(tar,ui_menu_csm_xc, _yl(5),_yl(5)+ui_menu_csm_ys, c_gray);

                               y:=_yt(6);
                               draw_text(tar,ui_menu_csm_xt0, y, net_cl_svstr+chat_type[menu_item<>90], ta_left  ,255, mic((net_status=ns_none),menu_item=90));
                               y:=_yt(7);
                               draw_text(tar,ui_menu_csm_xt0, y, str_npnu+str_npnua[net_pnui]         , ta_left  ,255, mic((net_status<>ns_server),false));
                               if(g_cl_units>0)then
                               draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                                        ta_right ,255, c_white);
                            end;
                 ns_server: begin
                               for t:=2 to 4 do hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(t),c_gray);

                               y:=_yt(1);
                               draw_text(tar,ui_menu_csm_xt0, y,str_svup[net_status=ns_server]        , ta_left  ,255, mic(menu_NetServer(net_status<>ns_server,true),false));
                               draw_text(tar,ui_menu_csm_xt2, y,str_udpport+net_sv_pstr               , ta_right ,255 ,mic(false        ,false));
                            end;
                 ns_client: begin
                               for t:=2 to 4 do hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(t),c_gray);

                               y:=_yt(1);
                               draw_text(tar,ui_menu_csm_xt0, y, str_connect[net_status=ns_client]    , ta_left ,255, mic(menu_NetClient(net_status<>ns_client,true),false));
                               draw_text(tar,ui_menu_csm_xt2, y, net_cl_svstr                         , ta_right,255, mic(false        ,false));

                               y:=_yt(2);
                               draw_text(tar,ui_menu_csm_xt0, y, str_npnu+str_npnua[net_pnui]         , ta_left  ,255, mic((net_status<>ns_server),false));
                               if(g_cl_units>0)then
                               draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[net_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units),
                                                                                                        ta_right ,255, c_white);
                            end;
                 end;
                 // chat
                 case net_status of
                 ns_server,
                 ns_client: begin
                               draw_text(tar,ui_menu_csm_xc, _yt(3), str_menu_chat, ta_middle,255, mic((net_status<>ns_none),menu_item=100));

                               y:=_yt(11)+1;
                               MakeLogListForDraw(HPlayer,ui_menu_chat_width,ui_menu_chat_height,lmts_menu_chat);
                               if(ui_log_n>0)then
                                 for t:=0 to ui_log_n-1 do
                                   if(ui_log_c[t]>0)then draw_text(tar,ui_menu_csm_xct,y-t*ui_menu_csm_ycs,ui_log_s[t],ta_left,255,ui_log_c[t]);

                               hlineColor(tar,ui_menu_csm_x0,ui_menu_csm_x1,_yl(12),c_gray);
                               draw_text(tar,ui_menu_csm_xct, _yt(12), net_chat_str+chat_type[menu_item<>100] , ta_chat,ui_menu_chat_width, c_white);
                            end;
                 end;
              end;
   end;
end;  }

procedure vid_MakeBigMenu;
var
cx,cy:single;
begin
   if(r_menusc<>nil)and(r_menusc<>r_menu)then sdl_FreeSurface(r_menusc);

   if(menu_scale)then
   begin
      cx:=vid_vw/r_menu^.w;
      cy:=vid_vh/r_menu^.h;
      if(cx>cy)
      then r_menusc_s:=cy
      else r_menusc_s:=cx;
      r_menusc  :=zoomSurface(r_menu,r_menusc_s,r_menusc_s,byte(menu_ScaleSmooth));
      r_menusc_s:=1/r_menusc_s;
   end
   else
   begin
      r_menusc_s:=1;
      r_menusc  :=r_menu;
   end;

   r_menusc_x:=(vid_vw-r_menusc^.w) div 2;
   r_menusc_y:=(vid_vh-r_menusc^.h) div 2;
end;

procedure d_MenuItemPanel(tar:pSDL_Surface;mi,border:byte);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        boxColor(tar,mi_x0,mi_y0,mi_x1,mi_y1,c_black);
        while(border>0)do
        begin
           rectangleColor(tar,mi_x0-border,mi_y0-border,
                              mi_x1+border,mi_y1+border,c_ltgray);
           border-=1;
        end;
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

        rectangleColor(tar,mi_xc-menu_ItemCaptionhW,mi_y0-1,
                           mi_xc+menu_ItemCaptionhW,mi_y0+menu_BigButtonhH,c_ltgray);
        draw_text(tar,mi_xc,mi_y0+font_hw ,text,ta_middle,255,color);
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

      barh-=2;
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
              y:=mi_y0+i*lineH;

              draw_text(tar,mi_x0+font_hw,y+font_hw,str_Trim(b2s(i+1)+'] '+plist^[i],lineWChars),ta_left,255,mic(mi_state>1,i=selected));
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

procedure d_MenuItemInfo(tar:pSDL_Surface;mi:byte;text:shortstring);
var color:cardinal;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        if(mi_state=1)
        then color:=c_gray
        else color:=c_white;

        draw_text(tar,mi_x0+font_hw,mi_y0+menu_BigButtonH,text,ta_left,255,color);
     end;
end;
procedure d_MenuItemTextC(tar:pSDL_Surface;mi,pos:byte;text:shortstring;color:cardinal);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        case pos of
        ta_left  : draw_text(tar,mi_x0+font_hw,mi_yc-font_hw ,text,pos      ,255,color);
        ta_right : draw_text(tar,mi_x1-font_hw,mi_yc-font_hw ,text,pos      ,255,color);
        ta_middle: draw_text(tar,mi_xc        ,mi_yc-font_hw ,text,pos      ,255,color);
        ta_miMU  : draw_text(tar,mi_xc        ,mi_y0+font_hw ,text,ta_middle,255,color);
        ta_miMD  : draw_text(tar,mi_xc        ,mi_y1-font_3hw,text,ta_middle,255,color);
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
       d_MenuItemText(tar,mi,ta_middle,text,selectedVal);
end;
procedure d_menuItemText2(tar:pSDL_Surface;mi:byte;text1,text2:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        d_MenuItemText(tar,mi,ta_left ,text1,selectedVal);
        d_MenuItemText(tar,mi,ta_right,text2,selectedVal);
     end;
end;

procedure d_menuItemText2L(tar:pSDL_Surface;mi:byte;text1,text2:shortstring;selectedVal:byte);
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        d_MenuItemText(tar,mi ,ta_miMU   ,text1 ,selectedVal);
        d_MenuItemText(tar,mi ,ta_miMD   ,text2 ,selectedVal);
     end;
end;


procedure d_MenuItemTextBar(tar:pSDL_Surface;mi:byte;text:shortstring;vcur,vmin,vmax:integer;selectedVal:byte);
var tx:integer;
begin
   with menu_items[mi] do
     if(mi_state>0)then
     begin
        d_MenuItemText(tar,mi,ta_left  ,text     ,selectedVal);

        tx:=mi_x1-menu_BarStepX;
        vlineColor(tar,tx+1,mi_y0,mi_y1-1,c_ltgray);
        draw_text(tar,tx+font_hw,mi_yc-font_hw ,'>',ta_left ,255,c_white);

        tx-=vmax-vmin;
        draw_text(tar,tx-font_hw,mi_yc-font_hw ,i2s(vcur)+' <',ta_right ,255,c_white);
        vlineColor(tar,tx-1,mi_y0,mi_y1-1,c_ltgray);
        boxColor(tar,tx,mi_yc-font_hw,tx+vcur-vmin,mi_yc+font_hw,c_lime);
     end;
end;

procedure d_updmenu(tar:pSDL_Surface);
var i,p:byte;
// short name function for string editing char
function vc(mi:byte):char;
begin
   vc:=chat_type[menu_item<>mi];
end;
begin
   draw_sdlsurface(tar,0,0,spr_mback);
   draw_sdlsurface(tar,menu_hw-(spr_mlogo^.w div 2),0,spr_mlogo);

   draw_text(tar,menu_w,menu_h-font_w,str_ver,ta_right,255,c_white);

   if(TestMode>0)then
   draw_text(tar,menu_hw,0,'TEST MODE '+b2s(TestMode)    ,ta_middle,255,c_white);

   //draw_text(tar,menu_hw,menu_h-font_3w,str_menu_controls,ta_middle,255,c_white);

   draw_text(tar,menu_hw,menu_h-font_w, str_cprt         ,ta_middle,255,c_white);

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
   d_menuItemText2L(tar,mi_caption_Campaings,str_menu_Campaings,
                                             str_menu_Tutorials  ,255);

   if(rpls_state=rpls_read)
then d_menuItemText1(tar,mi_caption_Scirmish,str_menu_Playback   ,255)
else d_menuItemText1(tar,mi_caption_Scirmish,str_menu_Scirmish   ,255);

   if(g_started)
then d_menuItemText1(tar,mi_caption_SaveLoad,str_menu_SaveLoad   ,255)
else d_menuItemText1(tar,mi_caption_SaveLoad,str_menu_LoadGame   ,255);

   d_menuItemText1(tar,mi_caption_Replays   ,str_menu_Replays    ,255);
   d_menuItemText1(tar,mi_caption_Settings  ,str_menu_Settings   ,255);

   /////////////////////////////////////////////////////////////////////////////
   // Main buttons
   d_MenuItemText2L(tar,mi_Campaings        ,str_menu_Campaings  ,
                                             str_menu_Tutorials  ,0);

   d_menuItemText1(tar,mi_Scirmish          ,str_menu_Scirmish   ,0);

   if(g_started)
then d_menuItemText1(tar,mi_SaveLoad        ,str_menu_SaveLoad   ,0)
else d_menuItemText1(tar,mi_SaveLoad        ,str_menu_LoadGame   ,0);

   d_menuItemText1(tar,mi_Replays           ,str_menu_Replays    ,0);
   d_menuItemText1(tar,mi_Settings          ,str_menu_Settings   ,0);

   if(rpls_state=rpls_read)
then d_menuItemText1(tar,mi_Break           ,str_menu_PlaybackStop,0)
else d_menuItemText1(tar,mi_Break           ,str_menu_Break      ,0);

   d_menuItemText1(tar,mi_Back              ,str_menu_Back       ,0);
   d_menuItemText1(tar,mi_Exit              ,str_menu_Exit       ,0);
   d_menuItemText1(tar,mi_Start             ,str_menu_Start      ,0);
   d_menuItemText1(tar,mi_Surrender         ,str_menu_Surrender  ,0);

   // SETTINGS LIST
   d_menuItemText1(tar,mi_settings_Game     ,str_menu_SetGame    ,menu_settings);
   d_menuItemText1(tar,mi_settings_Record   ,str_menu_SetReplay  ,menu_settings);
   d_menuItemText1(tar,mi_settings_Video    ,str_menu_SetVideo   ,menu_settings);
   d_menuItemText1(tar,mi_settings_Sound    ,str_menu_SetSound   ,menu_settings);

   // SETTINGS  GAME

   d_menuItemText2(tar,mi_SG_ColoredShadows  ,str_SG_ColoredShadow  ,b2cc[ui_ColoredShadow]                     ,0);
   d_MenuItemText2(tar,mi_SG_ShowAPM         ,str_SG_ShowAPM        ,b2cc[ui_ShowAPM          ]                 ,0);
   d_MenuItemText2(tar,mi_SG_HealthBars      ,str_SG_HealthBars     ,str_SG_HealthBarsL[ui_HealthBars ]         ,0);
   d_MenuItemText2(tar,mi_SG_RightClickAction,str_SG_RightClickAct  ,str_SG_RightClickActL[m_RightClickAct]     ,0);
   d_MenuItemText2(tar,mi_SG_MouseScroll     ,str_SG_MouseScroll    ,b2cc[ui_MouseScroll]                       ,0);
   d_MenuItemText2(tar,mi_SG_PlayerName      ,str_SG_PlayerName     ,PlayerName+vc(mi_SG_PlayerName)            ,menu_item);
   d_MenuItemText2(tar,mi_SG_Language        ,str_SG_Language       ,str_SG_LanguageL[ui_language]              ,0);
   d_MenuItemText2(tar,mi_SG_ControlPanelPos ,str_SG_ControlPanelPos,str_SG_ControlPanelPosL[ui_ControlPanelPos],0);
   d_MenuItemText2(tar,mi_SG_PlayersColor    ,str_SG_PlayersColor   ,str_SG_PlayersColorL[ui_PlayersColor]      ,0);

   d_MenuItemTextBar(tar,mi_SG_ScrollSpeed   ,str_SG_ScrollSpeed    ,ui_CamSpeed,1,vid_MaxCamSpeed,0);  //

   // SETTINGS  GAME RECORDING
   d_menuItemText2(tar,mi_SR_RecordGames     ,str_SR_RecordGames    ,b2cc[rpls_Record]                          ,0);
   d_menuItemText2(tar,mi_SR_RecordPrefix    ,str_SR_ReplayPrefix   ,rpls_NamePrefix+vc(mi_SR_RecordPrefix)     ,menu_item);
   d_menuItemText2(tar,mi_SR_RecordQuality   ,str_SR_Quality        ,str_ReplayQualityL[rpls_Quality]                 ,0);

   // SETTINGS  VIDEO
   d_menuItemText2(tar,mi_SV_ResolutionW     ,str_SV_ResolutionW    ,i2s(menu_ResolutionWi)+vc(mi_SV_ResolutionW),menu_item);
   d_menuItemText2(tar,mi_SV_ResolutionH     ,str_SV_ResolutionH    ,i2s(menu_ResolutionHi)+vc(mi_SV_ResolutionH),menu_item);
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
   d_MenuItemInfo   (tar,mi_SaveLoad_info,svld_str_info);

   d_menuItemText (tar,mi_SaveLoad_fname,ta_left,svld_str_fname+vc(mi_SaveLoad_fname),menu_item);
   d_menuItemText1(tar,mi_SaveLoad_save      ,str_FileSave  ,0);
   d_menuItemText1(tar,mi_SaveLoad_load      ,str_FileLoad  ,0);
   d_menuItemText1(tar,mi_SaveLoad_delete    ,str_FileDelete,0);

   // REPLAYS
   d_MenuItemList(tar,mi_Replays_list,@rpls_list,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_ListLineH,menu_ListLineWChars,menu_BaseListH);

   d_MenuItemCaption(tar,mi_Replays_info,str_FileInfo );
   d_MenuItemInfo   (tar,mi_Replays_info,rpls_str_info);

   d_menuItemText1(tar,mi_Replays_play       ,str_ReplayPlay,0);
   d_menuItemText1(tar,mi_Replays_delete     ,str_FileDelete,0);

   // SCIRMISH PLAYERS
   d_MenuItemCaption(tar,mi_Players_Panel,str_Caption_Players);

   d_MenuItemTextC(tar,mi_Players_NameC ,ta_left  ,str_PT_Player,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_StateC,ta_middle,str_PT_State ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_RaceC ,ta_middle,str_PT_Race  ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_TeamC ,ta_middle,str_PT_Team  ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_ColorC,ta_middle,str_PT_Color ,c_ltgray);
   d_MenuItemTextC(tar,mi_Players_PingC ,ta_middle,str_PT_Ping  ,c_ltgray);

   d_MenuItemText (tar,mi_Players_Ready ,ta_left  ,str_NetReady+b2cc[PlayerReady],0);

   for i:=0 to MaxPlayers-1 do
     with g_players[i+1] do
       if(state<>ps_none)then
       begin
          p:=i+1;
          d_MenuItemTextC(tar,mi_Players_Name1 +i,ta_left  ,name               ,mic(menu_items[mi_Players_Name1 +i].mi_state>1,p=LocalPlayer));
          d_MenuItemTextC(tar,mi_Players_State1+i,ta_middle,PlayerGetStatus(p) ,mic(menu_items[mi_Players_State1+i].mi_state>1,p=LocalPlayer));

     if(team=0)
     then d_MenuItemTextC(tar,mi_Players_Race1+i ,ta_middle,str_observer       ,c_gray)
     else d_MenuItemTextC(tar,mi_Players_Race1+i ,ta_middle,str_race[mrace]    ,mic(menu_items[mi_Players_Race1 +i].mi_state>1,false    ));

          d_MenuItemTextC(tar,mi_Players_Team1+i ,ta_middle,t2c(team)          ,mic(menu_items[mi_Players_Team1 +i].mi_state>1,false    ));

          if(not GetBBit(@g_player_astatus,p))and(G_Started)then
            with menu_items[mi_Players_Name1+i] do
              if(mi_state>0)then
                hlineColor(tar,mi_x0+2,mi_x1-2,mi_yc,c_red);
       end
       else
       begin
          if(g_AISlots>0)then
          begin
             d_MenuItemTextC(tar,mi_Players_Name1+i,ta_left  ,str_ps_comp+' '+b2s(g_AISlots)     ,c_gray);
             d_MenuItemTextC(tar,mi_Players_Race1+i,ta_middle,str_race[r_random]                  ,c_gray);
             d_MenuItemTextC(tar,mi_Players_Team1+i,ta_middle,b2s(PlayerGetFixedTeams(map_scenario,i+1)),c_gray);
          end;
          if(not g_started)then
            d_MenuItemTextC(tar,mi_Players_State1+i,ta_middle,'+',c_lime);
       end;

   for i:=0 to MaxPlayers-1 do
     with menu_items[mi_Players_Ping1+i] do
       if(mi_state>0)then
         if(net_status=ns_none)
         then boxColor(tar,mi_x0+font_hw,mi_y0+font_hw,
                           mi_x1-font_hw,mi_y1-font_hw,PlayerGetColor(i+1))
         else ;

   // SCIRMISH MAP
   d_MenuItemCaption(tar,mi_Map_Panel,str_Caption_Map);

   with menu_items[mi_Map_Map] do
   if(mi_state>0)then
   draw_sdlsurface(tar,mi_x0+1,mi_y0+1,r_mminimap);

   d_menuItemText2(tar,mi_Map_Scenario  ,str_map_Scenario  ,str_map_ScenarioL[map_scenario]    ,0);
   d_menuItemText2(tar,mi_Map_Generators,str_map_Generators,str_map_GeneratorsL[map_generators],0);
   d_menuItemText2(tar,mi_Map_Seed      ,str_map_Seed      ,menu_mseed+vc(mi_Map_Seed)         ,menu_item);
   d_menuItemText2(tar,mi_Map_Size      ,str_map_Size      ,i2s(map_Size)                      ,0);
   d_menuItemText2(tar,mi_Map_Obstacles ,str_map_Obstacles ,strMX(map_Obstacles)               ,0);
   d_menuItemText2(tar,mi_Map_Symmetry  ,str_map_Symmetry  ,b2cc[map_Symmetry]                 ,0);

   d_menuItemText1(tar,mi_Map_Theme     ,theme_name[theme_i],0);
   d_menuItemText1(tar,mi_Map_Random    ,str_map_Random     ,0);

   // SCIRMISH GAME
   d_MenuItemCaption(tar,mi_Game_Panel,str_Caption_GOptions);

   d_menuItemText2(tar,mi_Game_FixedPositions,str_GO_FixedStarts,b2cc[g_FixedPositions]      ,0);
   d_menuItemText2(tar,mi_Game_AISlots       ,str_GO_AISlots    ,ai_name(g_AISlots)          ,0);
   d_menuItemText2(tar,mi_Game_DefeatedObs   ,str_GO_DefeatedObs,b2cc[g_DefeatedObs]        ,0);
   d_menuItemText1(tar,mi_Game_Random        ,str_GO_Random     ,0);

   // SCIRMISH MULTIPLAYER
   d_MenuItemCaption(tar,mi_MP_Panel,str_Caption_Multiplayer);


   // SCIRMISH REPLAY
   d_MenuItemCaption(tar,mi_ReplayInfo_Panel,str_FileInfo);

   if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)then
   d_MenuItemInfo   (tar,mi_ReplayInfo_Panel,rpls_list[rpls_list_sel]);

   //mi_ReplayInfo_Panel

    {

   // replays
   draw_text(tar,ui_menu_csm_xt1, y, str_replay             , ta_left  ,255, c_white);
   draw_text(tar,ui_menu_csm_xt2, y, str_rstatus[rpls_state], ta_right ,255, mic( menu_ReplayStatusToggleEnabled ,rpls_state>rpls_none));

   if(rpls_state>rpls_none)and(g_cl_units>0)then
   draw_text(tar,ui_menu_csm_xt2, y, i2s(min2(_cl_pnua[rpls_pnui]*4,g_cl_units))+'/'+i2s(g_cl_units), ta_right,255, c_white);


   if(menu_ihint>0)then
   begin
      if(menu_ihintpi<=menu_ihintn)then
        draw_text(tar,menu_ihintlx[menu_ihintpi],menu_ihintly[menu_ihintpi],str_menu_hint[menu_ihint],ta_middle,255,c_white);
   end;

   case G_Started of
false: begin
          draw_text(tar, 70,554, str_menu_Exit , ta_middle,255, c_white);
          case net_status  of
          ns_server,
          ns_none   : draw_text(tar,730,554, str_menu_Start, ta_middle,255, mic(PlayersReadyStatus,false));
          ns_client : ;
          end;
       end;
true : begin
          draw_text(tar, 70,554, str_menu_Back , ta_middle,255, c_white);

          if(menu_surrender(true))then
          begin
             draw_sdlsurface(tar,360,542,spr_mbtn);
             draw_text(tar,400,554,str_menu_Surrender,ta_middle,255, c_white);
          end;

          draw_text(tar,730,554, str_menu_Break     , ta_middle,255, c_white);
       end;
   end;

   D_MMap    (tar);
   D_MPlayers(tar);
   D_M1      (tar);
   D_M2      (tar); }
end;

procedure D_Menu;
begin
   if(menu_redraw)then
   begin
      d_updmenu(r_menu);
      vid_MakeBigMenu;
      menu_redraw:=false;
   end;

   draw_sdlsurface(r_screen,r_menusc_x,r_menusc_y,r_menusc);

   if(vid_ShowFPS)then draw_text(r_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_right,255,c_white);

   draw_sdlsurface(r_screen,mouse_x,mouse_y,spr_cursor);
end;


