
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON

procedure D_menu_Panel(x0,y0,x1,y1:integer;width:byte);
begin
   draw_set_color(c_black);
   draw_frect(x0+1,y0+1,x1-1,y1-1);
   if(width=255)then
     if((y1-y0)>menu_main_mp_bhh)
     then width:=2
     else width:=1;
   while(width>0)do
   begin
      draw_set_color(c_ltgray);
      draw_vline(x0  ,y0  ,y1);
      draw_hline(x0+1,x1  ,y0);
      draw_set_color(c_gray);
      draw_vline(x1  ,y0+1,y1 );
      draw_hline(x0+1,x1  ,y1 );
      x0-=1;
      y0-=1;
      x1+=1;
      y1+=1;
      width-=1;
   end;
end;

procedure D_menu_ScrollBar(mi:byte;scrolli,scrolls,scrollmax:integer);
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

      draw_set_color(c_lime);
      draw_vline(mi_x0+1,posCY,posCY+barh);
      draw_vline(mi_x0+2,posCY,posCY+barh);
   end;
end;

function menu_ItemColor(enable,selected:boolean):TMWColor;
begin
   menu_ItemColor:=c_white;
   if(not enable)then menu_ItemColor:=c_gray
   else
     if(selected)then menu_ItemColor:=c_yellow;
end;
procedure D_menu_EText(mi:byte;alignment:TAlignment;text:shortstring;listarrow:boolean;selected:byte;color:TMWColor;multiLine:boolean=false);
var tx,tx1,ty:integer;
begin
   with menu_items[mi] do
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

      if(color=c_none)
      then color:=menu_ItemColor(mi_enabled,((selected>0) or listarrow)and((menu_item=mi)or(selected>1)));

      draw_set_color(color);
      if(multiLine)
      then draw_text(tx,ty,text,alignment,255,c_none)
      else draw_text_line(tx,ty,text,alignment,255,c_none);

      if(listarrow)then draw_char(tx1+draw_font_wh,ty,#31,c_none);
   end;
end;

procedure D_menu_FileInfo(mi:byte;str1,str2,str3,str4:shortstring);
var x,y:integer;
begin

   with menu_items[mi] do
   if(mi_x0>0)or(mi_y0>0)then
   begin
      x:=mi_x0+basefont_wq3;

      y:=mi_y0+basefont_w3;

      draw_text(x,y,str1,ta_LU,255,c_none);
      y+=str_linesCount(str1)*draw_font_lhh+draw_font_lhh;

      draw_text(x,y,str2,ta_LU,255,c_none);
      y+=str_linesCount(str2)*draw_font_lhh+draw_font_lhh;

      draw_text(x,y,str3,ta_LU,255,c_none);
      y+=str_linesCount(str3)*draw_font_lhh+draw_font_lhh;

      draw_text(x,y,str4,ta_LU,255,c_none);
   end;
end;

procedure D_menu_ValBar(mi:byte;val,max:integer;percentage:boolean);
var tx0,tx1,ty:integer;
begin
   with menu_items[mi] do
   begin
      tx1:=mi_x1-basefont_w2;
      tx0:=tx1-max;
      ty:=(mi_y0+mi_y1) div 2;
      draw_set_color(c_white);
      draw_line(tx0-basefont_w2+basefont_wh,ty,tx0-basefont_wq3,mi_y0+basefont_wq3);
      draw_line(tx0-basefont_w2+basefont_wh,ty,tx0-basefont_wq3,mi_y1-basefont_wq3);
      draw_line(tx1+basefont_wq3,mi_y0+basefont_wq3,mi_x1-basefont_wh,ty);
      draw_line(tx1+basefont_wq3,mi_y1-basefont_wq3,mi_x1-basefont_wh,ty);

      draw_set_color(c_gray);
      draw_vline(tx0,mi_y0+1,mi_y1);
      draw_vline(tx1,mi_y0+1,mi_y1);
      draw_vline(tx0-basefont_w2,mi_y0+1,mi_y1);

      draw_set_color(c_lime);
      draw_frect(tx0,mi_y0+basefont_w1+1,tx0+val,mi_y1-basefont_w1);

      draw_set_color(c_white);
      tx0-=basefont_w2+basefont_wh;
      if(percentage)
      then draw_text_line(tx0,ty,i2s(round(100*val/max))+'%',ta_RM,255,c_none)
      else draw_text_line(tx0,ty,i2s(val)                   ,ta_RM,255,c_none);
   end;
end;
procedure D_menu_ETextD(mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:TMWColor);
begin
   D_menu_EText(mi,ta_LM ,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(mi,ta_RM ,r_text,listarrow,selected                ,color);
end;
procedure D_menu_ETextN(mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:TMWColor);
begin
   D_menu_EText(mi,ta_LM ,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(mi,ta_MMR,r_text,listarrow,selected                ,color);
   with menu_items[mi] do
   begin
      draw_set_color(c_gray);
      draw_vline((mi_x0+mi_x1) div 2,mi_y0+1,mi_y1);
   end;
end;

//////////////////
procedure D_menu_MButton(mi:byte;text:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MM,text,false,0,c_none);
end;
procedure D_menu_PlayerSlot(mi,playeri:byte);
var tstr:shortstring;
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(playeri=0)then  // captions above first player line
      begin
         draw_set_color(c_white);
         draw_text_line(mi_x0+draw_font_wh,mi_y0-draw_font_w1,str_menu_Name,ta_LM,255,c_none);
         draw_text_line(mi_x1-draw_font_wh,mi_y0-draw_font_w1,str_menu_Slot,ta_RM,255,c_none);
      end;
   end;
   with g_players[playeri]    do
     case g_slot_state[playeri] of
       pss_closed   : D_menu_EText(mi,ta_RM ,str_menu_PlayerSlots[g_slot_state[playeri]],true,0,c_white);
       pss_observer,
       pss_opened   : if(player_type>pt_none)then
                      begin
                         D_menu_EText(mi,ta_LM ,name,true,0,c_white);
                         if(player_type=pt_human)and(net_status<>ns_single)then
                         begin
                            if(playeri=PlayerLobby)
                            then tstr:=str_menu_server
                            else
                              if(isready)
                              then tstr:=str_menu_ready
                              else tstr:=str_menu_nready;
                            D_menu_EText(mi,ta_RM,tstr,true,0,c_ltgray);
                         end
                         else
                           if(g_slot_state[playeri]=pss_observer)then D_menu_EText(mi,ta_RM,str_menu_PlayerSlots[g_slot_state[playeri]],true ,0,c_white);
                      end
                      else
                      begin
                         if(g_ai_slots >0)and(g_slot_state[playeri]=pss_opened)then
                         begin
                         draw_set_alpha(127);
                         D_menu_EText(mi,ta_LM,str_menu_PlayerSlots[pss_AI_1+g_ai_slots-1],false,0,c_white);
                         draw_set_alpha(255);
                         end;

                         D_menu_EText(mi,ta_RM,str_menu_PlayerSlots[g_slot_state[playeri]],true ,0,c_white);
                      end;
       pss_AI_1..
       pss_AI_11    : if(player_type>pt_none)
                      then D_menu_EText(mi,ta_LM,name,true,0,c_none);
     end;
end;
procedure D_menu_PlayerRace(mi,p1:byte);
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(p1=0)then
      begin
         draw_set_color(c_white);
         draw_text_line((mi_x0+mi_x1) div 2,mi_y0-draw_font_w1,str_menu_Race,ta_MM,255,c_none);
      end;
   end;
   with g_players[p1] do
     D_menu_EText(mi,ta_MM,str_racel[slot_race],true,0,c_none);
end;
procedure D_menu_PlayerTeam(mi,p1:byte);
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(p1=0)then
      begin
         draw_set_color(c_white);
         draw_text_line((mi_x0+mi_x1) div 2,mi_y0-draw_font_w1,str_menu_Team,ta_MM,255,c_none);
      end;
   end;
   with g_players[p1] do
     if(isobserver)or(g_slot_state[p1]=pss_observer)
     then D_menu_EText(mi,ta_MM,str_observer,true,0,c_none)        //str_teams[]
     else D_menu_EText(mi,ta_RM,b2s(PlayerSlotGetTeam(p1,team)+1),true,0,c_none);
end;
procedure D_menu_PlayerColor(mi,p1:byte);
begin
   with menu_items[mi] do
   begin
      D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
      if(p1=0)then
      begin
         draw_set_color(c_white);
         draw_text_line((mi_x0+mi_x1) div 2,mi_y0-draw_font_w1,str_menu_Color,ta_MM,255,c_none);
      end;
      with g_players[p1] do
        if(not isobserver)and(g_slot_state[p1]<>pss_observer)then
        begin
           draw_set_color(PlayerColorNormal[p1]);
           draw_frect(mi_x0+basefont_w1,mi_y0+basefont_w1,
                      mi_x1-basefont_w1,mi_y1-basefont_w1);
        end;
   end;
end;

procedure D_menu_MButtonS(mi:byte;text:shortstring;selected:boolean);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MM,text,false,byte(selected)*2,c_none);
end;
procedure D_menu_MButtonT(mi:byte;text:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MU,text,false,0,c_none);
end;
procedure D_menu_MButtonD(mi:byte;text1,text2:shortstring;listarrow:boolean);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(mi,text1,text2,listarrow,0,c_none);
end;
procedure D_menu_MButtonM(mi:byte;text:shortstring;listarrow:boolean);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MM,text,listarrow,0,c_none);
end;
procedure D_menu_MButtonB(mi:byte;text:shortstring;val,max:integer;percentage:boolean);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(mi,text,'',false,0,c_none);
   D_menu_ValBar(mi,val,max,percentage);
end;
procedure D_menu_MButtonN(mi:byte;text1,text2:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextN(mi,text1,text2+chat_type[menu_item<>mi],false,1,c_none);
end;
procedure D_menu_MButtonU(mi:byte;text1,text2:shortstring);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(mi,text1,text2+chat_type[menu_item<>mi],false,1,c_none);
end;

procedure D_menu_List(mi:byte;list_size,list_scroll,selected_i,lineh,listh:integer;plist:PTArrayOfsString);
var ty,i:integer;
     pmi:PTMenuItem;
begin
   pmi:=@menu_items[mi];
   with pmi^ do
   begin
      D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,2);

      draw_set_color(c_white);
      draw_hline(mi_x0,mi_x1,mi_y0);
      draw_hline(mi_x0,mi_x1,mi_y1);

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
            if(i=selected_i)then
            begin
               draw_set_color(c_dgray);
               draw_frect(mi_x0+1,mi_y0,mi_x1-1,mi_y1);
            end;
         end;

         D_menu_EText(0,ta_LU,i2s(i+1)+'] '+plist^[i],false,0,c_none);

         i+=1;
         ty+=lineh;
         if(ty>=pmi^.mi_y1)then break;

         draw_set_color(c_white);
         draw_hline(pmi^.mi_x0,pmi^.mi_x1,ty);
      end;
   end;

   D_menu_ScrollBar(mi,list_scroll,listh,list_size);
end;

procedure D_menu_Chat(mi:byte);
begin
   with menu_items[mi] do D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,1);
end;

procedure d_UpdateMenu;
var i:byte;
begin
   draw_set_color(c_white);
   draw_set_alpha(255);
   draw_mwtexture2(0,0,spr_mback,menu_w,menu_h);

   // x2 FONT ELEMENTS
   draw_set_font(font_Base,basefont_w2);
   for i:=0 to 255 do
     with menu_items[i] do
       if(mi_x1>0)then
         case i of
mi_title_Campaings         : D_menu_MButtonS(i,str_menu_Campaings     ,true);
mi_title_Scirmish          : D_menu_MButtonS(i,str_menu_Scirmish      ,true);
mi_title_SaveLoad          : D_menu_MButtonS(i,str_menu_SaveLoad      ,true);
mi_title_LoadReplay        : D_menu_MButtonS(i,str_menu_LoadReplay    ,true);
mi_title_Settings          : D_menu_MButtonS(i,str_menu_Settings      ,true);
mi_title_AboutGame         : D_menu_MButtonS(i,str_menu_AboutGame     ,true);
mi_title_ReplayPlayback    : D_menu_MButtonS(i,str_menu_ReplayPlayback,true);
         end;

   // x1.5 FONT ELEMENTS
   draw_set_font(font_Base,basefont_w1h);
   for i:=0 to 255 do
     with menu_items[i] do
       if(mi_x1>0)then
         case i of
mi_settings_game           : D_menu_MButtonS(i,str_menu_settingsGame    ,menu_settings_page=i);
mi_settings_replay         : D_menu_MButtonS(i,str_menu_settingsReplay  ,menu_settings_page=i);
mi_settings_network        : D_menu_MButtonS(i,str_menu_settingsNetwork ,menu_settings_page=i);
mi_settings_video          : D_menu_MButtonS(i,str_menu_settingsVideo   ,menu_settings_page=i);
mi_settings_sound          : D_menu_MButtonS(i,str_menu_settingsSound   ,menu_settings_page=i);

mi_StartGame               : D_menu_MButtonD(i,str_menu_StartGame,'',true);
mi_EndGame                 : D_menu_MButtonD(i,str_menu_EndGame  ,'',true);
mi_SaveLoad                : D_menu_MButton (i,str_menu_SaveLoad         );
mi_Settings                : D_menu_MButton (i,str_menu_Settings         );
mi_AboutGame               : D_menu_MButton (i,str_menu_AboutGame        );

mi_back                    : D_menu_MButton (i,str_menu_Back             );
mi_exit                    : D_menu_MButton (i,str_menu_Exit             );
mi_StartScirmish,
mi_StartCampaing           : D_menu_MButton (i,str_menu_Start            );

mi_settings_ColoredShadows : D_menu_MButtonD(i,str_menu_ColoredShadow   ,str_bool[vid_ColoredShadow]           ,false);
mi_settings_ShowAPM        : D_menu_MButtonD(i,str_menu_APM             ,str_bool[vid_APM]                     ,false);
mi_settings_HitBars        : D_menu_MButtonD(i,str_menu_unitHBar        ,str_menu_unitHBarl[vid_UnitHealthBars],true );
mi_settings_MRBAction      : D_menu_MButtonD(i,str_menu_maction         ,str_menu_mactionl[m_action]           ,true );
mi_settings_ScrollSpeed    : D_menu_MButtonB(i,str_menu_ScrollSpeed     ,vid_CamSpeedBase,max_CamSpeed             ,false);
mi_settings_MouseScroll    : D_menu_MButtonD(i,str_menu_MouseScroll     ,str_bool[vid_CamMSEScroll]            ,false);
mi_settings_PlayerName     : D_menu_MButtonN(i,str_menu_PlayerName      ,PlayerName                                  );
mi_settings_Langugage      : D_menu_MButtonD(i,str_menu_language        ,str_menu_lang[ui_language]            ,true );
mi_settings_PanelPosition  : D_menu_MButtonD(i,str_menu_PanelPos        ,str_menu_PanelPosl[vid_PannelPos]     ,true );
mi_settings_MMapPosition   : D_menu_MButtonD(i,str_menu_MiniMapPos      ,str_menu_MiniMapPosl[vid_PannelPos in VPPSet_Vertical][vid_MiniMapPos],true );
mi_settings_PlayerColors   : D_menu_MButtonD(i,str_menu_PlayersColor    ,str_menu_PlayersColorl[vid_PlayersColorSchema]  ,true );

{
if(rpls_rstate>rpls_state_none)and(g_cl_units>0)
then D_menu_ETextD(mi_game_RecordQuality ,str_replay_Quality ,i2s(min2i(cl_UpT_array[rpls_Quality]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_pnua[rpls_Quality]
                                                                                           ,true ,0,0)
else D_menu_ETextD(mi_game_RecordQuality ,str_replay_Quality ,str_pnua[rpls_Quality]           ,true ,0,0);
}

//
mi_settings_Replaying      : D_menu_MButtonD(i,str_menu_Recording       ,str_bool[rpls_Recording]             ,false);
mi_settings_ReplayName     : D_menu_MButtonN(i,str_menu_ReplayName      ,rpls_str_prefix                            );
mi_settings_ReplayQuality  : D_menu_MButtonD(i,str_menu_ReplayQuality   ,str_menu_NetQuality[rpls_Quality]    ,true );

mi_settings_Client         : D_menu_EText   (i,ta_MM,str_menu_Client,false,0,c_white);
mi_settings_ClientQuality  : D_menu_MButtonD(i,str_menu_clientQuality   ,str_menu_NetQuality[net_Quality]     ,true );

mi_settings_Resolution     : D_menu_MButtonD(i,str_menu_ResolutionWidth ,i2s(menu_vid_vw)+'x'+i2s(menu_vid_vh),true );
mi_settings_ResApply       : D_menu_MButton (i,str_menu_Apply           );
mi_settings_Fullscreen     : D_menu_MButtonD(i,str_menu_fullscreen      ,str_bool[not vid_fullscreen]         ,false);
mi_settings_SDLRenderer    : begin
                             D_menu_MButtonD(i,str_menu_SDLRenderer     ,vid_SDLRendererName                  ,true );
                             if(vid_SDLRendererName<>vid_SDLRendererNameConfig)then
                             D_menu_EText   (i,ta_MM,str_menu_RestartReq,false,0,c_gray);
                             end;
mi_settings_ShowFPS        : D_menu_MButtonD(i,str_menu_FPS             ,str_bool[vid_fps]                    ,false);

mi_settings_SoundVol       : D_menu_MButtonB(i,str_menu_SoundVolume     ,round(snd_svolume1*snd_MaxSoundVolume),snd_MaxSoundVolume,true);
mi_settings_MusicVol       : D_menu_MButtonB(i,str_menu_MusicVolume     ,round(snd_mvolume1*snd_MaxSoundVolume),snd_MaxSoundVolume,true);
mi_settings_NextTrack      : D_menu_MButton (i,str_menu_NextTrack       );
mi_settings_PlayListSize   : D_menu_MButtonB(i,str_menu_PlayListSize    ,snd_PlayListSize,snd_PlayListSizeMax,false);
mi_settings_MusicReload    : D_menu_MButton (i,str_menu_MusicReload     );

mi_title_players           : D_menu_MButtonT(i,str_menu_players         );
mi_title_map               : D_menu_MButtonT(i,str_menu_map             );
mi_title_GameOptions       : D_menu_MButtonT(i,str_menu_GameOptions     );
mi_title_multiplayer       : D_menu_MButtonT(i,str_menu_multiplayer     );
mi_title_ReplayInfo1,
mi_title_ReplayInfo2       : D_menu_MButtonT(i,str_menu_ReplayInfo      );
mi_title_SaveInfo          : D_menu_MButtonT(i,str_menu_SaveInfo        );

mi_mplay_NetSearchCaption  : D_menu_MButtonT(i,str_menu_LANSearching    );
mi_mplay_NetSearchCon      : D_menu_MButton (i,str_menu_clientConnect   );
mi_mplay_NetSearchStop     : D_menu_MButton (i,str_menu_LANSearchStop   );

mi_replays_play            : D_menu_MButton (i,str_menu_ReplayPlay      );
mi_replays_delete          : D_menu_MButton (i,str_menu_DeleteFile      );

mi_saveload_save           : D_menu_MButton (i,str_menu_save            );
mi_saveload_load           : D_menu_MButton (i,str_menu_load            );
mi_saveload_delete         : D_menu_MButton (i,str_menu_DeleteFile      );
         end;

   // x1 FONT ELEMENTS
   draw_set_font(font_Base,basefont_w1);
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
mi_player_status7          : D_menu_PlayerSlot(i,i-mi_player_status0);

mi_player_race0,
mi_player_race1,
mi_player_race2,
mi_player_race3,
mi_player_race4,
mi_player_race5,
mi_player_race6,
mi_player_race7            : D_menu_PlayerRace(i,i-mi_player_race0  );

mi_player_team0,
mi_player_team1,
mi_player_team2,
mi_player_team3,
mi_player_team4,
mi_player_team5,
mi_player_team6,
mi_player_team7            : D_menu_PlayerTeam(i,i-mi_player_team0  );

mi_player_color0,
mi_player_color1,
mi_player_color2,
mi_player_color3,
mi_player_color4,
mi_player_color5,
mi_player_color6,
mi_player_color7           : D_menu_PlayerColor(i,i-mi_player_color0);

mi_map_Map                 : D_menu_MButtonD(i,str_map_Map       ,map_presets[map_preset_cur].mapp_name,true );
mi_map_Scenario            : D_menu_MButtonD(i,str_map_scenario  ,str_map_scenariol[map_scenario]      ,true );
mi_map_Generators          : D_menu_MButtonD(i,str_map_Generators,str_map_Generatorsl[map_generators]  ,true );
mi_map_Seed                : D_menu_MButtonU(i,str_map_seed      ,c2s(map_seed)                              );
mi_map_Size                : D_menu_MButtonD(i,str_map_size      ,i2s(RoundN(map_psize,100))           ,true );
mi_map_Type                : D_menu_MButtonD(i,str_map_type      ,str_map_typel[map_type   ]           ,true );
mi_map_Sym                 : D_menu_MButtonD(i,str_map_sym       ,str_map_syml[map_symmetry]           ,true );
mi_map_Theme               : D_menu_MButtonD(i,str_map_theme     ,theme_name[theme_cur]                ,false);
mi_map_Random              : D_menu_MButton (i,str_map_random);
mi_map_MiniMap             : with menu_items[i] do
                             begin
                             D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,2);
                             draw_set_alpha(255);
                             draw_set_color(c_white);
                             draw_mwtexture2(mi_x0,mi_y0,tex_map_mMiniMap,mi_x1-mi_x0,mi_y1-mi_y0);
                             end;

mi_game_FixStarts          : D_menu_MButtonD(i,str_menu_FixedStarts  ,str_bool[g_fixed_positions]       ,false);
mi_game_DeadPbserver       : D_menu_MButtonD(i,str_menu_DeadObservers,str_bool[g_deadobservers]         ,false);
mi_game_EmptySlots         : D_menu_MButtonD(i,str_menu_AISlots      ,ai_name(g_ai_slots)               ,true );
mi_game_RandomSkrimish     : D_menu_MButton (i,str_menu_RandomScirmish );


mi_mplay_ServerCaption     : D_menu_EText   (i,ta_MM,str_menu_Server ,false,0,c_none);
mi_mplay_ServerPort        : D_menu_MButtonU(i,str_menu_serverPort   ,net_sv_pstr);
mi_mplay_ServerStart       : D_menu_MButton (i,str_menu_serverStart);
mi_mplay_ServerStop        : D_menu_MButton (i,str_menu_serverStop );

mi_mplay_ClientCaption     : D_menu_EText   (i,ta_MM,str_menu_Client,false,0,c_none);
mi_mplay_ClientStatus      : D_menu_EText   (i,ta_MM,net_status_str ,false,0,c_none);
mi_mplay_ClientAddress     : D_menu_MButtonU(i,str_menu_clientAddress   ,net_cl_svaddr);
mi_mplay_ClientConnect     : D_menu_MButton (i,str_menu_clientConnect   );
mi_mplay_ClientDisconnect  : D_menu_MButton (i,str_menu_clientDisconnect);


mi_mplay_ChatCaption       : D_menu_EText   (i,ta_MM,str_menu_chat,false,0,c_none);
mi_mplay_Chat              : D_menu_Chat    (i);

mi_mplay_NetSearchStart    : D_menu_MButton (i,str_menu_LANSearchStart );
mi_mplay_NetSearchList     : D_menu_List(i,net_svsearch_listn,net_svsearch_scroll,net_svsearch_sel,menu_netsearch_lineh,menu_netsearch_listh,@net_svsearch_lists); //D_menu_LANSearchList(i);

mi_replays_list            : D_menu_List (i,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_replays_lineh,menu_replays_listh,@rpls_list); //D_menu_ReplaysList(i);
mi_title_ReplayInfo1       : D_menu_FileInfo(i,rpls_str_info1,rpls_str_info2,rpls_str_info3,rpls_str_info4);
mi_title_ReplayInfo2       : D_menu_EText(i,ta_LM,rpls_str_infoS,false,0,c_none);

mi_saveload_list           : D_menu_List (i,svld_list_size,svld_list_scroll,svld_list_sel,menu_saveload_lineh,menu_saveload_listh,@svld_list);
mi_saveload_fname          : with menu_items[i] do
                             begin
                             D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,2);
                             D_menu_EText(i,ta_LU,svld_str_fname+chat_type[false],false,2,c_none);
                             end;
mi_title_SaveInfo          : D_menu_FileInfo(i,svld_str_info1,svld_str_info2,svld_str_info3,svld_str_info4);

{
if(g_cl_units>0)
then D_menu_ETextD(mi_settings_ClientQuality,str_net_Quality    ,i2s(min2i(cl_UpT_array[net_Quality]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_menu_NetQuality[net_Quality]
                                                                                           ,true ,0,0)
else D_menu_ETextD(mi_settings_ClientQuality,str_net_Quality    ,str_menu_NetQuality[net_Quality]            ,true ,0,0);
}
         end;

   draw_set_color(c_white);
   draw_set_alpha(255);
   draw_mwtexture1(menu_hw-(spr_mlogo^.w div 2),0,spr_mlogo,1,1);

   draw_text_line(menu_w ,menu_h,str_ver ,ta_RD,255,c_none);
   if(test_mode>0)then
     draw_text_line(menu_hw,0,'TEST MODE #'+b2s(test_mode),ta_MU,255,c_none);
   draw_text_line(menu_hw,menu_h,str_cprt,ta_MD,255,c_none);
end;

procedure D_Menu_List;
var i,y:integer;
  color:TMWColor;
begin
   y:=menu_list_y+(menu_list_item_H*menu_list_n);
   draw_set_color(c_black);
   draw_frect(menu_list_x-menu_list_w,menu_list_y,menu_list_x,y);
   draw_set_color(c_white);
   draw_rect(menu_list_x-menu_list_w,menu_list_y,menu_list_x,y);
   draw_set_font(font_base,menu_list_fontS);
   for i:=0 to menu_list_n-1 do
   with menu_list_items[i] do
   begin
      y:=menu_list_y+(menu_list_item_H*i);
      color:=c_black;
      if(i=menu_list_selected)
      then color:=c_dgray
      else
        if(i=menu_list_current)
        then color:=c_gray;

      draw_set_color(color);
      draw_frect(menu_list_x-menu_list_w+1,y+1,menu_list_x-1,y+menu_list_item_H);

      if(mli_enabled)
      then color:=c_white
      else color:=c_gray;

      draw_set_color(color);
      if(menu_list_aleft)
      then draw_text_line(menu_list_x+basefont_wq3-menu_list_w ,y+menu_list_item_hh,mli_caption,ta_LM,255,c_black)
      else draw_text_line(menu_list_x-basefont_wq3             ,y+menu_list_item_hh,mli_caption,ta_RM,255,c_black);
      draw_set_color(c_white);
      draw_hline(menu_list_x-menu_list_w+1,menu_list_x-1,y+menu_list_item_H);
   end;
   draw_set_font(font_base,basefont_w1);
end;

procedure D_Menu;
var i:integer;
begin
   if(menu_redraw)then
   begin
      writeln('menu_redraw');

      map_RedrawMenuMinimap;

      draw_set_target(tex_menu);

      d_UpdateMenu;
      menu_redraw:=false;

      if(menu_list_n>0)then
       with menu_items[menu_item] do
       begin
          draw_set_color(c_black);
          draw_set_alpha(100);
          draw_frect(0      ,0    ,mi_x0      ,tex_menu^.h);
          draw_frect(mi_x1  ,0    ,tex_menu^.w,tex_menu^.h);
          draw_frect(mi_x0+1,0    ,mi_x1-1    ,mi_y0      );
          draw_frect(mi_x0+1,mi_y1,mi_x1-1    ,tex_menu^.h);
          draw_set_color(c_white);
          draw_set_alpha(255);
          D_Menu_List;
       end;
      //if false then
      {for i:=0 to 255 do
       with menu_items[i] do
        if(x0>0)then
         rectangleColor(x0,y0,x1,y1,gfx_MakeTMWColor(128+random(128),128+random(128),128+random(128),255));}
      draw_set_target(nil);
   end;

   draw_set_color(c_white);
   draw_mwtexture2(menu_tex_x,menu_tex_y,tex_menu,menu_tex_w,menu_tex_h);

   //draw_mwtexture1(0,100,theme_tile_terrain,1,1);
   //draw_mwtexture1(0,200,theme_tile_crater ,1,1);  draw_mwtexture1(100,200,theme_tileset_crater^[0]   ,1,1);
   //draw_mwtexture1(0,300,theme_tile_liquid ,1,1);  draw_mwtexture1(100,300,theme_tileset_liquid[0]^[0],1,1);

   draw_mwtexture1(0,0            ,spr_b_up[r_hell,0],1,1);
   draw_mwtexture1(0,ui_buttonw1  ,spr_b_up[r_hell,1],1,1);
   draw_mwtexture1(0,ui_buttonw1*2,spr_b_up[r_uac ,2],1,1);
   draw_mwtexture1(0,ui_buttonw1*3,spr_b_up[r_uac ,3],1,1);



   //draw_DebugTileSet();

   {draw_set_fontS(font_Base,3);
   draw_text(300,300,'12345'+tc_nl1+'67890',ta_LU,6,c_black);
   draw_text(500,300,'12345'+tc_nl2+'67890',ta_LU,6,c_black);}

   if(vid_FPS)then
   begin
      draw_set_font(font_Base,basefont_w1);
      draw_set_color(c_white);  //
      draw_text_line(menu_tex_x-draw_font_wq+menu_tex_w,
                     menu_tex_y+draw_font_wq,
                     'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_RU,255,c_none);
   end;
end;


