
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON

procedure D_menu_Panel(tar:pSDL_Surface;x0,y0,x1,y1:integer;width:byte);
begin
   boxColor(tar,x0+1,y0+1,x1-1,y1-1,c_black);
   if(width=255)then
     if((y1-y0)>menu_main_mp_bhh)
     then width:=2
     else width:=1;
   while(width>0)do
   begin
      vlineColor(tar,x0  ,y0  ,y1,c_ltgray);
      hlineColor(tar,x0+1,x1  ,y0,c_ltgray);
      vlineColor(tar,x1  ,y0+1,y1,c_gray );
      hlineColor(tar,x0+1,x1  ,y1,c_gray );
      x0-=1;
      y0-=1;
      x1+=1;
      y1+=1;
      width-=1;
   end;
end;

procedure D_menu_ScrollBar(tar:pSDL_Surface;mi:byte;scrolli,scrolls,scrollmax:integer);
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

      vlineColor(tar,mi_x0+1,posCY,posCY+barh,c_lime);
      vlineColor(tar,mi_x0+2,posCY,posCY+barh,c_lime);
   end;
end;

function menu_ItemColor(enable,selected:boolean):cardinal;
begin
   menu_ItemColor:=c_white;
   if(not enable)then menu_ItemColor:=c_gray
   else
     if(selected)then menu_ItemColor:=c_yellow;
end;
procedure D_menu_EText(tar:pSDL_Surface;me,alignment:byte;text:shortstring;listarrow:boolean;selected:byte;color:cardinal);
var tx,tx1,ty:integer;
begin
   with menu_items[me] do
   if(mi_x0>0)or(mi_y0>0)then
   begin
      tx:=mi_x0;
      ty:=mi_y0;
      if(listarrow)
      then tx1:=max2i(mi_x0,mi_x1-draw_font_w1h)
      else tx1:=mi_x1;
      if(not mi_enabled)then listarrow:=false;

      case alignment of // x hor
      ta_LU,
      ta_LM,
      ta_LD    : tx:=mi_x0+basefont_wq3;
      ta_MU,
      ta_MM,
      ta_MD    : tx:=(mi_x0+tx1) div 2;
      ta_RU,
      ta_RM,
      ta_RD    : tx:=tx1-basefont_wq3;
      ta_MMR   : begin
                 tx:=((mi_x0+mi_x1) div 2)+basefont_wq3;
                 alignment:=ta_LM;
                 end;
      end;

      case alignment of // y ver
      ta_LU,
      ta_MU,
      ta_RU    : ty:= mi_y0+basefont_wq3;
      ta_MMR,
      ta_LM,
      ta_MM,
      ta_RM    : ty:=((mi_y0+mi_y1) div 2);
      ta_LD,
      ta_MD,
      ta_RD    : ty:= mi_y1-basefont_wq3;
      end;

      if(color=0)
      then color:=menu_ItemColor(mi_enabled,((selected>0) or listarrow)and((menu_item=me)or(selected>1)));

      draw_text(tar,tx,ty,text,alignment,255,color);

      if(listarrow)then draw_text(tar,tx1+draw_font_wh,ty,#31,ta_MM,(abs(mi_x0-tx1)-basefont_wq3*2) div basefont_w1,c_white);
      //characterColor(tar,tx1+larrow_hw-basefont_wh,ty,#31,c_white);
   end;
end;

procedure D_menu_ValBar(tar:pSDL_Surface;mi:byte;val,max:integer;percentage:boolean);
var tx0,tx1,ty:integer;
begin
   with menu_items[mi] do
   begin
      tx1:=mi_x1-basefont_w2;
      tx0:=tx1-max;
      ty:=(mi_y0+mi_y1) div 2;
      lineColor(tar,tx0-basefont_w2+basefont_wh,ty,tx0-basefont_wq3,mi_y0+basefont_wq3,c_white);
      lineColor(tar,tx0-basefont_w2+basefont_wh,ty,tx0-basefont_wq3,mi_y1-basefont_wq3,c_white);

      lineColor(tar,tx1+basefont_wq3,mi_y0+basefont_wq3,mi_x1-basefont_wh,ty,c_white);
      lineColor(tar,tx1+basefont_wq3,mi_y1-basefont_wq3,mi_x1-basefont_wh,ty,c_white);

      vlineColor(tar,tx0,mi_y0+1,mi_y1,c_gray);
      vlineColor(tar,tx1,mi_y0+1,mi_y1,c_gray);
      vlineColor(tar,tx0-basefont_w2,mi_y0+1,mi_y1,c_gray);

      boxColor  (tar,tx0,mi_y0+basefont_w1+1,tx0+val,mi_y1-basefont_w1,c_lime);

      tx0-=basefont_w2+basefont_wh;
      if(percentage)
      then draw_text(tar,tx0,ty,i2s(round(100*val/max))+'%',ta_RM,255,c_white)
      else draw_text(tar,tx0,ty,i2s(val),ta_RM,255,c_white);
   end;
end;
procedure D_menu_ETextD(tar:pSDL_Surface;mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:cardinal);
begin
   D_menu_EText(tar,mi,ta_LM ,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(tar,mi,ta_RM ,r_text,listarrow,selected                ,color);
end;
procedure D_menu_ETextN(tar:pSDL_Surface;mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:cardinal);
begin
   D_menu_EText(tar,mi,ta_LM ,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(tar,mi,ta_MMR,r_text,listarrow,selected                ,color);
   with menu_items[mi] do vlineColor(tar,(mi_x0+mi_x1) div 2,mi_y0+1,mi_y1,c_gray);
end;

//////////////////
procedure D_menu_MButton(tar:pSDL_Surface;mi:byte;text:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(tar,mi,ta_MM,text,false,0,0);
end;
procedure D_menu_PlayerSlot(tar:pSDL_Surface;mi,playeri:byte);
var tstr:shortstring;
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(playeri=0)then  // captions above first player line
      begin
         draw_text(tar,mi_x0+draw_font_wh,mi_y0-draw_font_w1,str_menu_Name,ta_LM,255,c_white);
         draw_text(tar,mi_x1-draw_font_wh,mi_y0-draw_font_w1,str_menu_Slot,ta_RM,255,c_white);
      end;
   end;
   with g_players[playeri]    do
     case g_slot_state[playeri] of
       pss_closed   : D_menu_EText(tar,mi,ta_RM ,str_menu_PlayerSlots[g_slot_state[playeri]],true,0,c_white);
       pss_observer,
       pss_opened   : if(player_type>pt_none)then
                      begin
                         D_menu_EText(tar,mi,ta_LM ,name,true,0,c_white);
                         if(player_type=pt_human)and(net_status<>ns_single)then
                         begin
                            if(playeri=PlayerLobb1)
                            then tstr:=str_menu_server
                            else
                              if(isready)
                              then tstr:=str_menu_ready
                              else tstr:=str_menu_nready;
                            D_menu_EText(tar,mi,ta_RM,tstr,true,0,c_ltgray);
                         end
                         else
                           if(g_slot_state[playeri]=pss_observer)then D_menu_EText(tar,mi,ta_RM,str_menu_PlayerSlots[g_slot_state[playeri]],true ,0,c_ltgray);
                      end
                      else
                      begin
                         if(g_ai_slots >0)and(g_slot_state[playeri]=pss_opened)then
                         D_menu_EText(tar,mi,ta_LM,str_menu_PlayerSlots[pss_AI_1+g_ai_slots-1],false,0,c_ltgray);

                         D_menu_EText(tar,mi,ta_RM,str_menu_PlayerSlots[g_slot_state[playeri]],true ,0,c_ltgray);
                      end;
       pss_AI_1..
       pss_AI_11    : if(player_type>pt_none)
                      then D_menu_EText(tar,mi,ta_LM,name,true,0,0);
     end;
end;
procedure D_menu_PlayerRace(tar:pSDL_Surface;mi,p1:byte);
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(p1=0)then draw_text(tar,(mi_x0+mi_x1) div 2,mi_y0-draw_font_w1,str_menu_Race,ta_MM,255,c_white);
   end;
   with g_players[p1] do
     D_menu_EText(tar,mi,ta_MM,str_racel[slot_race],true,0,0);
end;
procedure D_menu_PlayerTeam(tar:pSDL_Surface;mi,p1:byte);
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(p1=0)then draw_text(tar,(mi_x0+mi_x1) div 2,mi_y0-draw_font_w1,str_menu_Team,ta_MM,255,c_white);
   end;
   with g_players[p1] do
     if(isobserver)or(g_slot_state[p1]=pss_observer)
     then D_menu_EText(tar,mi,ta_MM,str_observer,true,0,0)
     else D_menu_EText(tar,mi,ta_MM,str_teams[PlayerSlotGetTeam(g_mode,p1,255)],true,0,0);
end;
procedure D_menu_PlayerColor(tar:pSDL_Surface;mi,p1:byte);
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(p1=0)then draw_text(tar,(mi_x0+mi_x1) div 2,mi_y0-draw_font_w1,str_menu_Color,ta_MM,255,c_white);
      boxColor(tar,mi_x0+basefont_wh,mi_y0+basefont_wh,
                   mi_x1-basefont_wh,mi_y1-basefont_wh,PlayerColorNormal[p1]);
   end;
end;

procedure D_menu_MButtonS(tar:pSDL_Surface;mi:byte;text:shortstring;selected:boolean);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(tar,mi,ta_MM,text,false,byte(selected)*2,0);
end;
procedure D_menu_MButtonT(tar:pSDL_Surface;mi:byte;text:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(tar,mi,ta_MU,text,false,0,0);
end;
procedure D_menu_MButtonD(tar:pSDL_Surface;mi:byte;text1,text2:shortstring;listarrow:boolean);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(tar,mi,text1,text2,listarrow,0,0);
end;
procedure D_menu_MButtonM(tar:pSDL_Surface;mi:byte;text:shortstring;listarrow:boolean);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(tar,mi,ta_MM,text,listarrow,0,0);
end;
procedure D_menu_MButtonB(tar:pSDL_Surface;mi:byte;text:shortstring;val,max:integer;percentage:boolean);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(tar,mi,text,'',false,0,0);
   D_menu_ValBar(tar,mi,val,max,percentage);
end;
procedure D_menu_MButtonN(tar:pSDL_Surface;mi:byte;text1,text2:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextN(tar,mi,text1,text2+chat_type[menu_item<>mi],false,1,0);
end;
procedure D_menu_MButtonU(tar:pSDL_Surface;mi:byte;text1,text2:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(tar,mi,text1,text2+chat_type[menu_item<>mi],false,1,0);
end;

procedure D_menu_List(tar:pSDL_Surface;mi:byte;list_size,list_scroll,selected_i,lineh,listh:integer;plist:PTArrayOfsString);
var ty,i:integer;
     pmi:PTMenuItem;
begin
   pmi:=@menu_items[mi];
   with pmi^ do
   begin
      D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,2);

      hlineColor(tar,mi_x0,mi_x1,mi_y0,c_white);
      hlineColor(tar,mi_x0,mi_x1,mi_y1,c_white);

      menu_items[0].mi_x0     :=mi_x0;
      menu_items[0].mi_x1     :=mi_x1;
      menu_items[0].mi_enabled:=true;
   end;

   if(list_size>0)then
   begin
      ty:=pmi^.mi_y0;
      i :=list_scroll;
      while(true) do
      begin
         if(i>=list_size)then break;

         with menu_items[0] do
         begin
            mi_y0:=ty;
            mi_y1:=ty+lineh;
            if(i=selected_i)then boxColor(tar,mi_x0+1,mi_y0,mi_x1-1,mi_y1,c_dgray);
         end;

         D_menu_EText(tar,0,ta_LU,i2s(i+1)+'] '+plist^[i],false,0,0);

         i+=1;
         ty+=lineh;
         if(ty>=pmi^.mi_y1)then break;

         hlineColor(tar,pmi^.mi_x0,pmi^.mi_x1,ty,c_white);
      end;
   end;

   D_menu_ScrollBar(tar,mi,list_scroll,listh,list_size);
end;

procedure D_menu_Chat(tar:pSDL_Surface;mi:byte);
begin
   with menu_items[mi] do D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,1);
end;

procedure d_MenuBack(tar:pSDL_Surface);
begin
   draw_surf(tar,0,0,r_mback);

   draw_surf(tar,vid_vhw-(spr_mlogo^.w div 2),0,spr_mlogo);

   draw_text(tar,vid_vw ,vid_vh,str_ver ,ta_RD,255,c_white);

   if(test_mode>0)then
     draw_text(tar,vid_vhw,0,'TEST MODE #'+b2s(test_mode),ta_MU,255,c_white);

   draw_text(tar,vid_vhw,vid_vh,str_cprt,ta_MD,255,c_white);
end;

procedure d_MenuCommon;
begin
   if(vid_FPS)then draw_text(r_screen,vid_vw,2,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_RU,255,c_white);

   draw_surf(r_screen,mouse_x,mouse_y,spr_cursor);
end;

procedure d_UpdateMenu(tar:pSDL_Surface);
var i:byte;
begin
   d_MenuBack(tar);

   // x2 FONT ELEMENTS
   draw_set_FontSize1(20);
   for i:=0 to 255 do
     with menu_items[i] do
       if(mi_x1>0)then
         case i of
mi_title_Campaings         : D_menu_MButtonS(tar,i,str_menu_Campaings     ,true);
mi_title_Scirmish          : D_menu_MButtonS(tar,i,str_menu_Scirmish      ,true);
mi_title_SaveLoad          : D_menu_MButtonS(tar,i,str_menu_SaveLoad      ,true);
mi_title_LoadReplay        : D_menu_MButtonS(tar,i,str_menu_LoadReplay    ,true);
mi_title_Settings          : D_menu_MButtonS(tar,i,str_menu_Settings      ,true);
mi_title_AboutGame         : D_menu_MButtonS(tar,i,str_menu_AboutGame     ,true);
mi_title_ReplayPlayback    : D_menu_MButtonS(tar,i,str_menu_ReplayPlayback,true);
         end;

   // x1.5 FONT ELEMENTS
   draw_set_FontSize1(15);
   for i:=0 to 255 do
     with menu_items[i] do
       if(mi_x1>0)then
         case i of
mi_settings_game           : D_menu_MButtonS(tar,i,str_menu_settingsGame    ,menu_settings_page=i);
mi_settings_replay         : D_menu_MButtonS(tar,i,str_menu_settingsReplay  ,menu_settings_page=i);
mi_settings_network        : D_menu_MButtonS(tar,i,str_menu_settingsNetwork ,menu_settings_page=i);
mi_settings_video          : D_menu_MButtonS(tar,i,str_menu_settingsVideo   ,menu_settings_page=i);
mi_settings_sound          : D_menu_MButtonS(tar,i,str_menu_settingsSound   ,menu_settings_page=i);

mi_StartGame               : D_menu_MButtonD(tar,i,str_menu_StartGame,'',true);
mi_EndGame                 : D_menu_MButtonD(tar,i,str_menu_EndGame  ,'',true);
mi_SaveLoad                : D_menu_MButton (tar,i,str_menu_SaveLoad         );
mi_Settings                : D_menu_MButton (tar,i,str_menu_Settings         );
mi_AboutGame               : D_menu_MButton (tar,i,str_menu_AboutGame        );

mi_back                    : D_menu_MButton (tar,i,str_menu_Back             );
mi_exit                    : D_menu_MButton (tar,i,str_menu_Exit             );
mi_StartScirmish,
mi_StartCampaing           : D_menu_MButton (tar,i,str_menu_Start            );

mi_settings_ColoredShadows : D_menu_MButtonD(tar,i,str_menu_ColoredShadow   ,str_bool[vid_ColoredShadow]         ,false);
mi_settings_ShowAPM        : D_menu_MButtonD(tar,i,str_menu_APM             ,str_bool[vid_APM]                   ,false);
mi_settings_HitBars        : D_menu_MButtonD(tar,i,str_menu_unitHBar        ,str_menu_unitHBarl[vid_uhbars]      ,true );
mi_settings_MRBAction      : D_menu_MButtonD(tar,i,str_menu_maction         ,str_menu_mactionl[m_action]         ,true );
mi_settings_ScrollSpeed    : D_menu_MButtonB(tar,i,str_menu_ScrollSpeed     ,vid_CamSpeed,max_CamSpeed           ,false);
mi_settings_MouseScroll    : D_menu_MButtonD(tar,i,str_menu_MouseScroll     ,str_bool[vid_CamMSEScroll]          ,false);
mi_settings_PlayerName     : D_menu_MButtonN(tar,i,str_menu_PlayerName      ,PlayerName                                );
mi_settings_Langugage      : D_menu_MButtonD(tar,i,str_menu_language        ,str_menu_lang[ui_language]          ,true );
mi_settings_PanelPosition  : D_menu_MButtonD(tar,i,str_menu_PanelPos        ,str_menu_PanelPosl[vid_PannelPos]   ,true );
mi_settings_MMapPosition   : D_menu_MButtonD(tar,i,str_menu_MiniMapPos      ,str_menu_MiniMapPosl[vid_PannelPos<2][vid_MiniMapPos],true );
mi_settings_PlayerColors   : D_menu_MButtonD(tar,i,str_menu_PlayersColor    ,str_menu_PlayersColorl[vid_plcolors],true );

{
if(rpls_rstate>rpls_state_none)and(g_cl_units>0)
then D_menu_ETextD(tar,mi_game_RecordQuality ,str_replay_Quality ,i2s(min2i(cl_UpT_array[rpls_Quality]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_pnua[rpls_Quality]
                                                                                           ,true ,0,0)
else D_menu_ETextD(tar,mi_game_RecordQuality ,str_replay_Quality ,str_pnua[rpls_Quality]           ,true ,0,0);
}

//
mi_settings_Replaying      : D_menu_MButtonD(tar,i,str_menu_Recording       ,str_bool[rpls_Recording]             ,false);
mi_settings_ReplayName     : D_menu_MButtonN(tar,i,str_menu_ReplayName      ,rpls_str_name                              );
mi_settings_ReplayQuality  : D_menu_MButtonD(tar,i,str_menu_ReplayQuality   ,str_menu_NetQuality[rpls_Quality]    ,true );

mi_settings_Client         : D_menu_EText   (tar,i,ta_MM,str_menu_Client,false,0,0);
mi_settings_ClientQuality  : D_menu_MButtonD(tar,i,str_menu_clientQuality   ,str_menu_NetQuality[net_Quality]     ,true );

mi_settings_ResWidth       : D_menu_MButtonD(tar,i,str_menu_ResolutionWidth ,i2s(menu_res_w)                      ,true );
mi_settings_ResHeight      : D_menu_MButtonD(tar,i,str_menu_ResolutionHeight,i2s(menu_res_h)                      ,true );
mi_settings_ResApply       : D_menu_MButton (tar,i,str_menu_Apply           );
mi_settings_Fullscreen     : D_menu_MButtonD(tar,i,str_menu_fullscreen      ,str_bool[not vid_fullscreen]         ,false);
mi_settings_ShowFPS        : D_menu_MButtonD(tar,i,str_menu_FPS             ,str_bool[vid_fps]                    ,false);

mi_settings_SoundVol       : D_menu_MButtonB(tar,i,str_menu_SoundVolume     ,round(snd_svolume1*snd_MaxSoundVolume),snd_MaxSoundVolume,true);
mi_settings_MusicVol       : D_menu_MButtonB(tar,i,str_menu_MusicVolume     ,round(snd_mvolume1*snd_MaxSoundVolume),snd_MaxSoundVolume,true);
mi_settings_NextTrack      : D_menu_MButton (tar,i,str_menu_NextTrack       );
mi_settings_PlayListSize   : D_menu_MButtonB(tar,i,str_menu_PlayListSize    ,snd_PlayListSize,snd_PlayListSizeMax,false);
mi_settings_MusicReload    : D_menu_MButton (tar,i,str_menu_MusicReload     );

mi_title_players           : D_menu_MButtonT(tar,i,str_menu_players         );
mi_title_map               : D_menu_MButtonT(tar,i,str_menu_map             );
mi_title_GameOptions       : D_menu_MButtonT(tar,i,str_menu_GameOptions     );
mi_title_multiplayer       : D_menu_MButtonT(tar,i,str_menu_multiplayer     );
mi_title_ReplayInfo1,
mi_title_ReplayInfo2       : D_menu_MButtonT(tar,i,str_menu_ReplayInfo      );
mi_title_SaveInfo          : D_menu_MButtonT(tar,i,str_menu_SaveInfo        );

mi_mplay_NetSearchCaption  : D_menu_MButtonT(tar,i,str_menu_LANSearching    );
mi_mplay_NetSearchCon      : D_menu_MButton (tar,i,str_menu_clientConnect   );
mi_mplay_NetSearchStop     : D_menu_MButton (tar,i,str_menu_LANSearchStop   );

mi_replays_play            : D_menu_MButton (tar,i,str_menu_ReplayPlay      );
mi_replays_delete          : D_menu_MButton (tar,i,str_menu_DeleteFile      );

mi_saveload_save           : D_menu_MButton (tar,i,str_menu_save            );
mi_saveload_load           : D_menu_MButton (tar,i,str_menu_load            );
mi_saveload_delete         : D_menu_MButton (tar,i,str_menu_DeleteFile      );
         end;

   // x1 FONT ELEMENTS
   draw_set_FontSize1(10);
   for i:=0 to 255 do
     with menu_items[i] do
       if(mi_x1>0)then
         case i of
mi_player_status0,
mi_player_status1,
mi_player_status2,
mi_player_status3,
mi_player_status4,
mi_player_status5,
mi_player_status6,
mi_player_status7          : D_menu_PlayerSlot(tar,i,i-mi_player_status0);

mi_player_race0,
mi_player_race1,
mi_player_race2,
mi_player_race3,
mi_player_race4,
mi_player_race5,
mi_player_race6,
mi_player_race7            : D_menu_PlayerRace(tar,i,i-mi_player_race0  );

mi_player_team0,
mi_player_team1,
mi_player_team2,
mi_player_team3,
mi_player_team4,
mi_player_team5,
mi_player_team6,
mi_player_team7            : D_menu_PlayerTeam(tar,i,i-mi_player_team0  );

mi_player_color0,
mi_player_color1,
mi_player_color2,
mi_player_color3,
mi_player_color4,
mi_player_color5,
mi_player_color6,
mi_player_color7           : D_menu_PlayerColor(tar,i,i-mi_player_color0);

mi_map_Preset              : D_menu_MButtonD(tar,i,g_presets[g_preset_cur].gp_name,''     ,true );
mi_map_Seed                : D_menu_MButtonU(tar,i,str_map_seed,c2s(map_seed)                   );
mi_map_Size                : D_menu_MButtonD(tar,i,str_map_size,i2s(RoundN(map_psize,100)) ,true );
mi_map_Type                : D_menu_MButtonD(tar,i,str_map_type,str_map_typel[map_type   ],true );
mi_map_Sym                 : D_menu_MButtonD(tar,i,str_map_sym ,str_map_syml[map_symmetry],true );
mi_map_Random              : D_menu_MButton (tar,i,str_map_random);
mi_map_Theme               : D_menu_MButton (tar,i,theme_name[theme_cur]);
mi_map_MiniMap             : with menu_items[i] do
                             begin
                             D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,2);
                             draw_surf(tar,mi_x0,mi_y0,r_mminimap);
                             end;

mi_game_mode               : D_menu_MButtonD(tar,i,str_menu_GameMode     ,str_emnu_GameModel[g_mode]        ,true );
mi_game_generators         : D_menu_MButtonD(tar,i,str_menu_Generators   ,str_menu_Generatorsl[g_generators],true );
mi_game_FixStarts          : D_menu_MButtonD(tar,i,str_menu_FixedStarts  ,str_bool[g_fixed_positions]       ,false);
mi_game_DeadPbserver       : D_menu_MButtonD(tar,i,str_menu_DeadObservers,str_bool[g_deadobservers]         ,false);
mi_game_EmptySlots         : D_menu_MButtonD(tar,i,str_menu_AISlots      ,ai_name(g_ai_slots)               ,true );
mi_game_RandomSkrimish     : D_menu_MButton (tar,i,str_menu_RandomScirmish );


mi_mplay_ServerCaption     : D_menu_EText   (tar,i,ta_MM,str_menu_Server ,false,0,0);
mi_mplay_ServerPort        : D_menu_MButtonU(tar,i,str_menu_serverPort   ,net_sv_pstr);
mi_mplay_ServerStart       : D_menu_MButton (tar,i,str_menu_serverStart);
mi_mplay_ServerStop        : D_menu_MButton (tar,i,str_menu_serverStop );

mi_mplay_ClientCaption     : D_menu_EText   (tar,i,ta_MM,str_menu_Client,false,0,0);
mi_mplay_ClientStatus      : D_menu_EText   (tar,i,ta_MM,net_status_str ,false,0,0);
mi_mplay_ClientAddress     : D_menu_MButtonU(tar,i,str_menu_clientAddress   ,net_cl_svaddr);
mi_mplay_ClientConnect     : D_menu_MButton (tar,i,str_menu_clientConnect   );
mi_mplay_ClientDisconnect  : D_menu_MButton (tar,i,str_menu_clientDisconnect);


mi_mplay_ChatCaption       : D_menu_EText   (tar,i,ta_MM,str_menu_chat,false,0,0);
mi_mplay_Chat              : D_menu_Chat    (tar,i);

mi_mplay_NetSearchStart    : D_menu_MButton (tar,i,str_menu_LANSearchStart );
mi_mplay_NetSearchList     : D_menu_List(tar,i,net_svsearch_listn,net_svsearch_scroll,net_svsearch_sel,menu_netsearch_lineh,menu_netsearch_listh,@net_svsearch_lists); //D_menu_LANSearchList(tar,i);

mi_replays_list            : D_menu_List (tar,i,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_replays_lineh,menu_replays_listh,@rpls_list); //D_menu_ReplaysList(tar,i);
mi_title_ReplayInfo1       : begin
                             D_menu_EText(tar,i,ta_LU,rpls_str_info1,false,0,0);
                             D_menu_EText(tar,i,ta_LM,rpls_str_info2,false,0,0);
                             D_menu_EText(tar,i,ta_LD,rpls_str_info3,false,0,0);
                             writeln('replay info');
                             end;
mi_title_ReplayInfo2       : D_menu_EText(tar,i,ta_LM,rpls_str_infoS,false,0,0);

mi_saveload_list           : D_menu_List (tar,i,svld_list_size,svld_list_scroll,svld_list_sel,menu_saveload_lineh,menu_saveload_listh,@svld_list);
mi_saveload_fname          : with menu_items[i] do
                             begin
                             D_menu_Panel(tar,mi_x0,mi_y0,mi_x1,mi_y1,2);
                             D_menu_EText(tar,i,ta_LU,svld_str_fname+chat_type[false],false,2,0);
                             end;
mi_title_SaveInfo          : begin
                             D_menu_EText(tar,i,ta_LU,svld_str_info1,false,0,0);
                             D_menu_EText(tar,i,ta_LM,svld_str_info2,false,0,0);
                             D_menu_EText(tar,i,ta_LD,svld_str_info3,false,0,0);
                             writeln('save info');
                             end;


{
if(g_cl_units>0)
then D_menu_ETextD(tar,mi_settings_ClientQuality,str_net_Quality    ,i2s(min2i(cl_UpT_array[net_Quality]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_menu_NetQuality[net_Quality]
                                                                                           ,true ,0,0)
else D_menu_ETextD(tar,mi_settings_ClientQuality,str_net_Quality    ,str_menu_NetQuality[net_Quality]            ,true ,0,0);
}
         end;
end;

procedure D_Menu_List;
var i,y:integer;
  color:cardinal;
begin
   y:=menu_list_y+(menu_list_item_H*menu_list_n);
   boxColor      (r_screen,menu_list_x-menu_list_w,menu_list_y,menu_list_x,y,c_black);
   RectangleColor(r_screen,menu_list_x-menu_list_w,menu_list_y,menu_list_x,y,c_white);
   draw_set_FontSize1(menu_list_font);
   for i:=0 to menu_list_n-1 do
   with menu_list_items[i] do
   begin
      y:=menu_list_y+(menu_list_item_H*i);
      color:=0;
      if(i=menu_list_selected)
      then color:=c_dgray
      else
        if(i=menu_list_current)
        then color:=c_gray;

      if(color<>0)
      then boxColor(r_screen,menu_list_x-menu_list_w+1,y+1,menu_list_x-1,y+menu_list_item_H,color);

      if(mli_enabled)
      then color:=c_white
      else color:=c_gray;

      if(menu_list_aleft)
      then draw_text (r_screen,menu_list_x+basefont_wq3-menu_list_w ,y+menu_list_item_hh,mli_caption,ta_LM,255,color)
      else draw_text (r_screen,menu_list_x-basefont_wq3             ,y+menu_list_item_hh,mli_caption,ta_RM,255,color);
      hlineColor(r_screen,menu_list_x-menu_list_w+1,menu_list_x-1,y+menu_list_item_H,c_white);
   end;
   draw_set_FontSize1(10);
end;

procedure D_Menu;
var i:integer;
begin
   if(menu_redraw)then
   begin
      //map_RedrawMenuMinimap(r_mminimap,true);
      d_UpdateMenu(r_menu);
      menu_redraw:=false;

      if(menu_list_n>0)then
       with menu_items[menu_item] do
       begin
          boxColor(r_menu,0      ,0    ,mi_x0    ,r_menu^.h,c_ablack);
          boxColor(r_menu,mi_x1  ,0    ,r_menu^.w,r_menu^.h,c_ablack);
          boxColor(r_menu,mi_x0+1,0    ,mi_x1-1  ,mi_y0    ,c_ablack);
          boxColor(r_menu,mi_x0+1,mi_y1,mi_x1-1  ,r_menu^.h,c_ablack);
       end;
      //if false then
      {for i:=0 to 255 do
       with menu_items[i] do
        if(x0>0)then
         rectangleColor(r_menu,x0,y0,x1,y1,rgba2c(128+random(128),128+random(128),128+random(128),255));}

      {tstr:='';
      for i:=1 to 255 do
        tstr+=chr(i);
      writeln(length(tstr),' ',tstr);
      draw_set_FontSize1(10);
      draw_text(r_menu,0,0,tstr,ta_LU,50,c_white);
      draw_set_FontSize1(15);
      draw_text(r_menu,0,100,tstr,ta_LU,45,c_white);
      draw_set_FontSize1(20);
      draw_text(r_menu,0,300,tstr,ta_LU,45,c_white); }
   end;

   draw_surf(r_screen,0,0,r_menu);

   if(menu_list_n>0)then D_Menu_List;

   {draw_set_font(2);
   draw_text(r_screen,400,420,'Test text 1234',ta_LU,255,c_white);
   draw_set_font(3);
   draw_text(r_screen,400,450,'Test text 1234',ta_LU,255,c_white);
   draw_set_font(1); }

   d_MenuCommon;
end;


