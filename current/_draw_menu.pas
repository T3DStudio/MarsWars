
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

procedure D_menu_ValBar(mi:byte;val,min,max:integer;percentage:boolean);
var tx0,tx1,ty:integer;
begin
   with menu_items[mi] do
   if(mi_x1<=0)
   then exit
   else
   begin
      tx1:=mi_x1-basefont_w2;
      tx0:=tx1-(max-min);
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
      draw_frect(tx0,mi_y0+basefont_w1+1,tx0+val-min,mi_y1-basefont_w1);

      draw_set_color(c_white);
      tx0-=basefont_w2+basefont_wh;
      if(percentage)
      then draw_text_line(tx0,ty,i2s(round(100*val/max))+'%',ta_RM,255,c_none)
      else draw_text_line(tx0,ty,i2s(val)                   ,ta_RM,255,c_none);
   end;
end;
procedure D_menu_ETextD(mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:TMWColor);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit;

   D_menu_EText(mi,ta_LM ,l_text,false    ,byte(listarrow)+selected,color);
   D_menu_EText(mi,ta_RM ,r_text,listarrow,selected                ,color);
end;
procedure D_menu_ETextN(mi:byte;l_text,r_text:shortstring;listarrow:boolean;selected:byte;color:TMWColor);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit;

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
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MM,text,false,0,c_none);
end;
procedure D_menu_PlayerSlot(mi,playeri:byte);
var tstr:shortstring;
begin
   with menu_items[mi] do
   if(mi_x1<=0)
   then exit
   else
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
   if(mi_x1<=0)
   then exit
   else
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
   if(mi_x1<=0)
   then exit
   else
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
   if(mi_x1<=0)
   then exit
   else
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
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MM,text,false,byte(selected)*2,c_none);
end;
procedure D_menu_MButtonT(mi:byte;text:shortstring);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MU,text,false,0,c_none);
end;
procedure D_menu_MButtonD(mi:byte;text1,text2:shortstring;listarrow:boolean);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(mi,text1,text2,listarrow,0,c_none);
end;
procedure D_menu_MButtonM(mi:byte;text:shortstring;listarrow:boolean);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_EText(mi,ta_MM,text,listarrow,0,c_none);
end;
procedure D_menu_MButtonB(mi:byte;text:shortstring;min,val,max:integer;percentage:boolean);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(mi,text,'',false,0,c_none);
   D_menu_ValBar(mi,val,min,max,percentage);
end;
procedure D_menu_MButtonN(mi:byte;text1,text2:shortstring);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextN(mi,text1,text2+chat_type[menu_item<>mi],false,1,c_none);
end;
procedure D_menu_MButtonU(mi:byte;text1,text2:shortstring);
begin
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,255);
   D_menu_ETextD(mi,text1,text2+chat_type[menu_item<>mi],false,1,c_none);
end;

procedure D_menu_List(mi:byte;list_size,list_scroll,selected_i,lineh,listh:integer;plist:PTArrayOfsString);
var ty,i:integer;
     pmi:PTMenuItem;
begin
   pmi:=@menu_items[mi];
   with pmi^ do
   begin
      if(mi_x1<=0)
      then exit;

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
   with menu_items[mi] do
     if(mi_x1<=0)
     then exit
     else D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,1);
end;

procedure d_UpdateMenu;
begin
   draw_set_color(c_white);
   draw_set_alpha(255);
   draw_mwtexture2(0,0,spr_mback,menu_w,menu_h);

   // font Doom Menu Titles
   draw_set_font(font_Doom,fontSize_DoomTitle);

   D_menu_MButtonS(mi_title_Campaings        ,str_menu_Campaings     ,true);
   D_menu_MButtonS(mi_title_Scirmish         ,str_menu_Scirmish      ,true);

   if(g_Started)
then D_menu_MButtonS(mi_title_SaveLoad       ,str_menu_SaveLoad      ,true)
else D_menu_MButtonS(mi_title_SaveLoad       ,str_menu_LoadGame      ,true);
   D_menu_MButtonS(mi_title_LoadReplay       ,str_menu_LoadReplay    ,true);
   D_menu_MButtonS(mi_title_Settings         ,str_menu_Settings      ,true);
   D_menu_MButtonS(mi_title_AboutGame        ,str_menu_AboutGame     ,true);
   D_menu_MButtonS(mi_title_ReplayPlayback   ,str_menu_ReplayPlayback,true);

   // font Doom Big Font
   draw_set_font(font_Doom,fontSize_DoomSubTitle);

   D_menu_MButtonD(mi_StartGame              ,str_menu_StartGame  ,'',true);
   D_menu_MButtonD(mi_EndGame                ,str_menu_EndGame    ,'',true);
   D_menu_MButton (mi_SaveLoad               ,str_menu_SaveLoad           );
   D_menu_MButton (mi_Settings               ,str_menu_Settings           );
   D_menu_MButton (mi_AboutGame              ,str_menu_AboutGame          );

   D_menu_MButton (mi_back                   ,str_menu_Back               );
   D_menu_MButton (mi_exit                   ,str_menu_Exit               );
   D_menu_MButton (mi_StartScirmish          ,str_menu_Start              );
   D_menu_MButton (mi_StartCampaing          ,str_menu_Start              );

   D_menu_MButtonT(mi_mplay_NetSearchCaption ,str_menu_LANSearching       );
   D_menu_MButton (mi_mplay_NetSearchCon     ,str_menu_clientConnect      );
   D_menu_MButton (mi_mplay_NetSearchStop    ,str_menu_LANSearchStop      );

   D_menu_MButton (mi_replays_play           ,str_menu_ReplayPlay         );
   D_menu_MButton (mi_replays_delete         ,str_menu_DeleteFile         );

   D_menu_MButton (mi_saveload_save          ,str_menu_save               );
   D_menu_MButton (mi_saveload_load          ,str_menu_load               );
   D_menu_MButton (mi_saveload_delete        ,str_menu_DeleteFile         );


   // font Doom SubTitles
   draw_set_font(font_Doom,fontSize_DoomMedium);

   D_menu_MButtonS(mi_settings_game          ,str_menu_settingsGame    ,menu_settings_page=mi_settings_game   );
   D_menu_MButtonS(mi_settings_replay        ,str_menu_settingsReplay  ,menu_settings_page=mi_settings_replay );
   D_menu_MButtonS(mi_settings_network       ,str_menu_settingsNetwork ,menu_settings_page=mi_settings_network);
   D_menu_MButtonS(mi_settings_video         ,str_menu_settingsVideo   ,menu_settings_page=mi_settings_video  );
   D_menu_MButtonS(mi_settings_sound         ,str_menu_settingsSound   ,menu_settings_page=mi_settings_sound  );

   D_menu_MButtonT(mi_title_players          ,str_menu_players         );
   D_menu_MButtonT(mi_title_map              ,str_menu_map             );
   D_menu_MButtonT(mi_title_GameOptions      ,str_menu_GameOptions     );
   D_menu_MButtonT(mi_title_multiplayer      ,str_menu_multiplayer     );
   D_menu_MButtonT(mi_title_ReplayInfo1      ,str_menu_ReplayInfo      );
   D_menu_MButtonT(mi_title_ReplayInfo2      ,str_menu_ReplayInfo      );
   D_menu_MButtonT(mi_title_SaveInfo         ,str_menu_SaveInfo        );


   // font base big
   draw_set_font(font_Base,fontSize_BaseBig);

   D_menu_MButtonD(mi_settings_ColoredShadows,str_menu_ColoredShadow   ,str_bool[ui_ColoredShadow]           ,false);
   D_menu_MButtonD(mi_settings_ShowAPM       ,str_menu_APM             ,str_bool[ui_ShowAPM]                 ,false);
   D_menu_MButtonD(mi_settings_HitBars       ,str_menu_unitHBar        ,str_menu_unitHBarl[ui_UnitHealthBars],true );
   D_menu_MButtonD(mi_settings_MRBAction     ,str_menu_maction         ,str_menu_mactionl[m_action]          ,true );
   D_menu_MButtonB(mi_settings_ScrollSpeed   ,str_menu_ScrollSpeed     ,1,ui_CamSpeedBase,max_CamSpeed       ,false);
   D_menu_MButtonD(mi_settings_MouseScroll   ,str_menu_MouseScroll     ,str_bool[ui_CamMSEScroll]            ,false);
   D_menu_MButtonN(mi_settings_PlayerName    ,str_menu_PlayerName      ,PlayerName                                 );
   D_menu_MButtonD(mi_settings_Langugage     ,str_menu_language        ,str_menu_lang[ui_language]           ,true );
   D_menu_MButtonD(mi_settings_CBarPosition  ,str_menu_CtrlBarPos      ,str_menu_PanelPosl[ui_CBarPos]       ,true );
   D_menu_MButtonB(mi_settings_CBarScale     ,str_menu_CtrlBarScale    ,min_CBarScalePrc,ui_ControlBar_msc,max_CBarScalePrc               ,false);
   D_menu_MButtonD(mi_settings_MMapPosition  ,str_menu_MiniMapPos      ,str_menu_MiniMapPosl[ui_CBarPos in VPPSet_Vertical][ui_MiniMapPos],true );
   D_menu_MButtonB(mi_settings_MMapScale     ,str_menu_MiniMapScale    ,min_MMapScalePrc,ui_MiniMap_msc,max_MMapScalePrc                  ,false);
   D_menu_MButtonD(mi_settings_PlayerColors  ,str_menu_PlayersColor    ,str_menu_PlayersColorl[ui_PlayersColorSchema]   ,true );

{
if(rpls_rstate>rpls_state_none)and(g_cl_units>0)
then D_menu_ETextD(mi_game_RecordQuality ,str_replay_Quality ,i2s(min2i(cl_UpT_array[rpls_Quality]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_pnua[rpls_Quality]
                                                                                           ,true ,0,0)
else D_menu_ETextD(mi_game_RecordQuality ,str_replay_Quality ,str_pnua[rpls_Quality]           ,true ,0,0);
}

   D_menu_MButtonD(mi_settings_Replaying     ,str_menu_Recording       ,str_bool[rpls_Recording]             ,false);
   D_menu_MButtonN(mi_settings_ReplayName    ,str_menu_ReplayName      ,rpls_str_prefix                            );
   D_menu_MButtonD(mi_settings_ReplayQuality ,str_menu_ReplayQuality   ,str_menu_NetQuality[rpls_Quality]    ,true );

   D_menu_EText   (mi_settings_Client,ta_MM  ,str_menu_Client          ,false,0,c_white);
   D_menu_MButtonD(mi_settings_ClientQuality ,str_menu_clientQuality   ,str_menu_NetQuality[net_Quality]     ,true );

   D_menu_MButtonD(mi_settings_Resolution    ,str_menu_Resolution      ,i2s(menu_vid_vw)+'x'+i2s(menu_vid_vh),true );
   D_menu_MButton (mi_settings_ResApply      ,str_menu_Apply           );
   D_menu_MButtonD(mi_settings_Fullscreen    ,str_menu_fullscreen      ,str_bool[not vid_fullscreen]         ,false);
   with menu_items[mi_settings_SDLRenderer] do
     if(mi_x1>0)then
     begin
   D_menu_MButtonD(mi_settings_SDLRenderer   ,str_menu_SDLRenderer     ,vid_SDLRendererName                  ,true );
   if(vid_SDLRendererName<>vid_SDLRendererNameConfig)then
   D_menu_EText   (mi_settings_SDLRenderer,ta_MM,str_menu_RestartReq,false,0,c_gray);
     end;

   D_menu_MButtonD(mi_settings_ShowFPS       ,str_menu_FPS             ,str_bool[ui_ShowFPS]                 ,false);

   D_menu_MButtonB(mi_settings_SoundVol      ,str_menu_SoundVolume     ,0,round(snd_svolume1*snd_MaxSoundVolume),snd_MaxSoundVolume,true);
   D_menu_MButtonB(mi_settings_MusicVol      ,str_menu_MusicVolume     ,0,round(snd_mvolume1*snd_MaxSoundVolume),snd_MaxSoundVolume,true);
   D_menu_MButton (mi_settings_NextTrack     ,str_menu_NextTrack       );
   D_menu_MButtonB(mi_settings_PlayListSize  ,str_menu_PlayListSize    ,0,snd_PlayListSize,snd_PlayListSizeMax,false);
   D_menu_MButton (mi_settings_MusicReload   ,str_menu_MusicReload     );


   // x1 BASE FONT ELEMENTS
   draw_set_font(font_Base,fontSize_BaseDefault);

   D_menu_PlayerSlot(mi_player_status0,0);
   D_menu_PlayerSlot(mi_player_status1,1);
   D_menu_PlayerSlot(mi_player_status2,2);
   D_menu_PlayerSlot(mi_player_status3,3);
   D_menu_PlayerSlot(mi_player_status4,4);
   D_menu_PlayerSlot(mi_player_status5,5);
   D_menu_PlayerSlot(mi_player_status6,6);
   D_menu_PlayerSlot(mi_player_status7,7);

   D_menu_PlayerRace(mi_player_race0  ,0);
   D_menu_PlayerRace(mi_player_race1  ,1);
   D_menu_PlayerRace(mi_player_race2  ,2);
   D_menu_PlayerRace(mi_player_race3  ,3);
   D_menu_PlayerRace(mi_player_race4  ,4);
   D_menu_PlayerRace(mi_player_race5  ,5);
   D_menu_PlayerRace(mi_player_race6  ,6);
   D_menu_PlayerRace(mi_player_race7  ,7);

   D_menu_PlayerTeam(mi_player_team0  ,0);
   D_menu_PlayerTeam(mi_player_team1  ,1);
   D_menu_PlayerTeam(mi_player_team2  ,2);
   D_menu_PlayerTeam(mi_player_team3  ,3);
   D_menu_PlayerTeam(mi_player_team4  ,4);
   D_menu_PlayerTeam(mi_player_team5  ,5);
   D_menu_PlayerTeam(mi_player_team6  ,6);
   D_menu_PlayerTeam(mi_player_team7  ,7);

   D_menu_PlayerColor(mi_player_color0,0);
   D_menu_PlayerColor(mi_player_color1,1);
   D_menu_PlayerColor(mi_player_color2,2);
   D_menu_PlayerColor(mi_player_color3,3);
   D_menu_PlayerColor(mi_player_color4,4);
   D_menu_PlayerColor(mi_player_color5,5);
   D_menu_PlayerColor(mi_player_color6,6);
   D_menu_PlayerColor(mi_player_color7,7);

   D_menu_MButtonD(mi_map_Map                ,str_map_Map              ,map_preset_l[map_preset_cur].mapp_name,true );
   D_menu_MButtonD(mi_map_Scenario           ,str_map_scenario         ,str_map_scenariol[map_scenario]       ,true );
   D_menu_MButtonD(mi_map_Generators         ,str_map_Generators       ,str_map_Generatorsl[map_generators]   ,true );
   D_menu_MButtonU(mi_map_Seed               ,str_map_seed             ,c2s(map_seed)                               );
   D_menu_MButtonD(mi_map_Size               ,str_map_size             ,i2s(RoundN(map_psize,100))            ,true );
   D_menu_MButtonD(mi_map_Type               ,str_map_type             ,str_map_typel[map_type   ]            ,true );
   D_menu_MButtonD(mi_map_Sym                ,str_map_sym              ,str_map_syml[map_symmetry]            ,true );
   D_menu_MButtonD(mi_map_Theme              ,str_map_theme            ,theme_name[theme_cur]                 ,false);
   D_menu_MButton (mi_map_Random             ,str_map_random);
   with menu_items[mi_map_MiniMap] do
     if(mi_x1>0)then
     begin
   D_menu_Panel(mi_x0,mi_y0,mi_x1,mi_y1,2);
   draw_set_alpha(255);
   draw_set_color(c_white);
   draw_mwtexture2(mi_x0,mi_y0,tex_map_mMiniMap,mi_x1-mi_x0,mi_y1-mi_y0);
     end;

   D_menu_MButtonD(mi_game_FixStarts         ,str_menu_FixedStarts     ,str_bool[g_fixed_positions]       ,false);
   D_menu_MButtonD(mi_game_DeadPbserver      ,str_menu_DeadObservers   ,str_bool[g_deadobservers]         ,false);
   D_menu_MButtonD(mi_game_EmptySlots        ,str_menu_AISlots         ,ai_name(g_ai_slots)               ,true );
   D_menu_MButton (mi_game_RandomSkrimish    ,str_menu_RandomScirmish );

   D_menu_EText   (mi_mplay_ServerCaption,ta_MM,str_menu_Server ,false,0,c_none);
   D_menu_MButtonU(mi_mplay_ServerPort       ,str_menu_serverPort  ,net_sv_pstr);
   D_menu_MButton (mi_mplay_ServerStart      ,str_menu_serverStart);
   D_menu_MButton (mi_mplay_ServerStop       ,str_menu_serverStop );

   D_menu_EText   (mi_mplay_ClientCaption    ,ta_MM,str_menu_Client,false,0,c_none);
   D_menu_EText   (mi_mplay_ClientStatus     ,ta_MM,net_status_str ,false,0,c_none);
   D_menu_MButtonU(mi_mplay_ClientAddress    ,str_menu_clientAddress   ,net_cl_svaddr);
   D_menu_MButton (mi_mplay_ClientConnect    ,str_menu_clientConnect   );
   D_menu_MButton (mi_mplay_ClientDisconnect ,str_menu_clientDisconnect);


   D_menu_EText   (mi_mplay_ChatCaption,ta_MM,str_menu_chat,false,0,c_none);
   D_menu_Chat    (mi_mplay_Chat);

   D_menu_MButton (mi_mplay_NetSearchStart   ,str_menu_LANSearchStart );
   D_menu_List    (mi_mplay_NetSearchList    ,net_svsearch_listn,net_svsearch_scroll,net_svsearch_sel,menu_netsearch_lineh,menu_netsearch_listh,@net_svsearch_lists); //D_menu_LANSearchList(i);

   D_menu_List    (mi_replays_list           ,rpls_list_size,rpls_list_scroll,rpls_list_sel,menu_replays_lineh,menu_replays_listh,@rpls_list); //D_menu_ReplaysList(i);
   D_menu_FileInfo(mi_title_ReplayInfo1      ,rpls_str_info1,rpls_str_info2,rpls_str_info3,rpls_str_info4);
   D_menu_EText   (mi_title_ReplayInfo2,ta_LM,rpls_str_infoS,false,0,c_none);

   D_menu_List    (mi_saveload_list,svld_list_size,svld_list_scroll,svld_list_sel,menu_saveload_lineh,menu_saveload_listh,@svld_list);
   with menu_items[mi_saveload_fname] do
     if(mi_x1>0)then
     begin
   D_menu_Panel   (mi_x0,mi_y0,mi_x1,mi_y1,2);
   D_menu_EText   (mi_saveload_fname,ta_LU   ,svld_str_fname+chat_type[false],false,2,c_none);
     end;
   D_menu_FileInfo(mi_title_SaveInfo         ,svld_str_info1,svld_str_info2,svld_str_info3,svld_str_info4);

{
if(g_cl_units>0)
then D_menu_ETextD(mi_settings_ClientQuality,str_net_Quality    ,i2s(min2i(cl_UpT_array[net_Quality]*4,g_cl_units))+'/'+i2s(g_cl_units)+' '+str_menu_NetQuality[net_Quality]
                                                                                           ,true ,0,0)
else D_menu_ETextD(mi_settings_ClientQuality,str_net_Quality    ,str_menu_NetQuality[net_Quality]            ,true ,0,0);
}

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
   draw_set_font(menu_list_font,menu_list_fontS);
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

   {with spr_HSymbol1^ do
     if(sm_listn>0)then
       for i:=0 to sm_listi do draw_mwtexture1(0,i*100,sm_list[i],1,1);    }

   {
   draw_mwtexture1(0,ui_pButtonW1  ,g_uids[UID_Cyberdemon].uid_ui_button,1,1);
   draw_mwtexture1(0,ui_pButtonW1*2,g_uids[UID_Mastermind].uid_ui_button,1,1);
   draw_mwtexture1(0,ui_pButtonW1*3,g_uids[UID_ENgineer].uid_ui_button,1,1);
   draw_mwtexture1(0,ui_pButtonW1*4,g_uids[UID_Flyer].uid_ui_button,1,1);}



   //draw_DebugTileSet();

   {draw_set_fontS(font_Base,3);
   draw_text(300,300,'12345'+tc_nl1+'67890',ta_LU,6,c_black);
   draw_text(500,300,'12345'+tc_nl2+'67890',ta_LU,6,c_black);}

   if(ui_ShowFPS)then
   begin
      draw_set_font(font_Base,basefont_w1);
      draw_set_color(c_white);  //
      draw_text_line(menu_tex_x-draw_font_wq+menu_tex_w,
                     menu_tex_y+draw_font_wq,
                     'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_RU,255,c_none);
   end;
end;


