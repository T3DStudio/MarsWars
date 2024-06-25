

////////////////////////////////////////////////////////////////////////////////
//  MENU COMMON


procedure menu_ReInit;
var tx0,
    tx1,
    ty0,
    ty1,i:integer;
 enable  :boolean;
procedure SetItem(item:byte;ax0,ay0,ax1,ay1:integer;aenabled:boolean);
begin
   with menu_items[item] do
   begin
      mi_x0:=min2i(ax0,ax1);
      mi_y0:=min2i(ay0,ay1);
      mi_x1:=max2i(ax0,ax1);
      mi_y1:=max2i(ay0,ay1);
      mi_enabled:=aenabled;
   end;
end;
function NeedColumnRace(p:byte):boolean;
begin
   NeedColumnRace:=false;
   if(p<=MaxPlayers)then
     case g_slot_state[p] of
ps_opened   : with g_players[p] do NeedColumnRace:=((state=ps_none)and(g_ai_slots>0))or((state>ps_none)and(team>0));
ps_AI_1..
ps_AI_11    : NeedColumnRace:=true;
     end;
end;
function NeedColumnTeam(p:byte):boolean;
begin
   NeedColumnTeam:=false;
   if(p<=MaxPlayers)then
     case g_slot_state[p] of
ps_opened   : with g_players[p] do NeedColumnTeam:=((state=ps_none)and(g_ai_slots>0))or(state>ps_none);
ps_observer,
ps_AI_1..
ps_AI_11    : NeedColumnTeam:=true;
     end;
end;
begin
   //menu_List_Clear;
   FillChar(menu_items,SizeOf(menu_items),0);

   // main buttons
   if(G_Started)
   then SetItem(mi_back,ui_menu_mbutton_lx0,ui_menu_mbutton_y0,ui_menu_mbutton_lx1,ui_menu_mbutton_y1,true)
   else SetItem(mi_exit,ui_menu_mbutton_lx0,ui_menu_mbutton_y0,ui_menu_mbutton_lx1,ui_menu_mbutton_y1,true);

   //enable:=(net_status<>ns_client)and(G_Started or PlayersReadyStatus);
   if(not G_Started)then
   begin
      if(PlayerClient=PlayerLobby)or(PlayerLobby=0)
      then SetItem(mi_start    ,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,GameStart(PlayerClient,true));
      //else SetItem(mi_surrender,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,false             );
   end
   else
     if(PlayerSpecialDefeat(PlayerClient,true,true))
     then SetItem(mi_surrender,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,true)
     else SetItem(mi_break    ,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,GameBreak(PlayerClient,true));

   {  if(net_status=ns_single)
     then SetItem(mi_break    ,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,net_status<>ns_client)
     else SetItem(mi_surrender,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,true);}

   // map section
   ty0:=0;
   ty1:=0;
   while(ty1<ui_menu_map_ph)do
   begin
   SetItem(mi_map_params1+ty0,ui_menu_map_px0,ui_menu_map_py0+ty1,ui_menu_map_px1,ui_menu_map_py0+ty1+ui_menu_map_lh,true);
   ty0+=1;
   ty1+=ui_menu_map_lh;
   end;

   menu_items[mi_map_params1].mi_enabled:=GameLoadPreset(PlayerClient,0,true);
   menu_items[mi_map_params2].mi_enabled:=map_SetSetting(PlayerClient,nmid_lobbby_mapseed ,0,true);
   menu_items[mi_map_params3].mi_enabled:=map_SetSetting(PlayerClient,nmid_lobbby_mapsize ,MinMapSize,true);
   menu_items[mi_map_params4].mi_enabled:=map_SetSetting(PlayerClient,nmid_lobbby_type    ,0,true);
   menu_items[mi_map_params5].mi_enabled:=map_SetSetting(PlayerClient,nmid_lobbby_symmetry,0,true);
   menu_items[mi_map_params6].mi_enabled:=menu_items[mi_map_params5].mi_enabled;
   menu_items[mi_map_params7].mi_enabled:=true;

   // settings block

   tx0:=ui_menu_ssr_zx0;
   ty0:=ui_menu_ssr_zy0;

   SetItem(mi_tab_settings,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);
   tx0+=ui_menu_ssr_cw;
   SetItem(mi_tab_saveload,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(net_status=ns_single)and(rpls_state<rpls_state_read));
   tx0+=ui_menu_ssr_cw;
   SetItem(mi_tab_replays ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(net_status=ns_single));

   tx0:=ui_menu_ssr_zx0;
   ty0+=ui_menu_ssr_lh;
   case menu_s1 of
ms1_sett: begin
             SetItem(mi_settings_game ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_settings_video,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_settings_sound,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,true);

             ty0+=ui_menu_ssr_lh;
             ty1:=0;
             while(ty0<ui_menu_ssr_zy1)do
             begin
                case menu_s3 of
                ms3_game : SetItem(mi_settings_ColoredShadows+ty1,ui_menu_ssr_zx0,ty0,ui_menu_ssr_zx1,ty0+ui_menu_ssr_lh,true);
                ms3_vido : SetItem(mi_settings_video1        +ty1,ui_menu_ssr_zx0,ty0,ui_menu_ssr_zx1,ty0+ui_menu_ssr_lh,true);
                ms3_sond : SetItem(mi_settings_sound1        +ty1,ui_menu_ssr_zx0,ty0,ui_menu_ssr_zx1,ty0+ui_menu_ssr_lh,true);
                end;

                ty0+=ui_menu_ssr_lh;
                ty1+=1;
             end;

             menu_items[mi_settings_PlayerName].mi_enabled:=(net_status=ns_single)and(not G_Started);
             menu_items[mi_settings_ResApply  ].mi_enabled:=(menu_res_w<>vid_vw)or(menu_res_h<>vid_vh);
          end;
ms1_svld: begin
             tx0:=ui_menu_ssr_zx0;
             ty0:=ui_menu_ssr_zy0+ui_menu_ssr_lh*12;

             SetItem(mi_saveload_save  ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(G_Started)and(length(svld_str_fname)>0));
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_saveload_load  ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(svld_list_size>0)and(0<=svld_list_sel)and(svld_list_sel<svld_list_size));
             tx0+=ui_menu_ssr_cw;
             SetItem(mi_saveload_delete,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,(svld_list_size>0)and(0<=svld_list_sel)and(svld_list_sel<svld_list_size));

             ty0:=ui_menu_ssr_zy0+ui_menu_ssr_lh*11;
             SetItem(mi_saveload_fname ,ui_menu_ssr_zx0,ty0,ui_menu_ssr_cx,ty0+ui_menu_ssr_lh,G_Started);

             SetItem(mi_saveload_list  ,ui_menu_ssr_zx0,ui_menu_ssr_zy0+ui_menu_ssr_lh*1,ui_menu_ssr_cx,ui_menu_ssr_zy0+ui_menu_ssr_lh*11,svld_list_size>0);
          end;
ms1_reps: begin
             tx0:=ui_menu_ssr_zx0;
             ty0:=ui_menu_ssr_zy0+ui_menu_ssr_lh*12;

             enable:=(not G_Started)and(rpls_list_size>0)and(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size);

             SetItem(mi_replays_play  ,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,enable);
             tx0+=ui_menu_ssr_cw*2;
             SetItem(mi_replays_delete,tx0,ty0,tx0+ui_menu_ssr_cw,ty0+ui_menu_ssr_lh,enable);

             SetItem(mi_replays_list  ,ui_menu_ssr_zx0,ui_menu_ssr_zy0+ui_menu_ssr_lh*1,ui_menu_ssr_cx,ui_menu_ssr_zy0+ui_menu_ssr_lh*12,(rpls_list_size>0)and(rpls_state<rpls_state_read));
          end;
   end;

   // players block

   if(net_status=ns_client)and(net_svsearch)then
   begin
      SetItem(mi_mplay_NetSearchList,ui_menu_nsrch_zx0,ui_menu_nsrch_zy0,ui_menu_nsrch_zx1,ui_menu_nsrch_zy1,true);
      SetItem(mi_mplay_NetSearchCon ,ui_menu_nsrch_zx0,ui_menu_nsrch_zy1,ui_menu_nsrch_zx1,ui_menu_pls_zy1,(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn));
   end
   else
     for i:=0 to MaxPlayers-1 do
     begin
        ty0:=ui_menu_pls_pby0+i*ui_menu_pls_lh;
        SetItem(mi_player_status1+i,ui_menu_pls_pbx0   ,ty0,ui_menu_pls_cx_race ,ty0+ui_menu_pls_lh,PlayerSlotChangeState(PlayerClient,i+1,255,true));
        if(NeedColumnRace(i+1))then
        SetItem(mi_player_race1  +i,ui_menu_pls_cx_race,ty0,ui_menu_pls_cx_team ,ty0+ui_menu_pls_lh,PlayerSlotChangeRace (PlayerClient,i+1,255,true));
        if(NeedColumnTeam(i+1))then
        SetItem(mi_player_team1  +i,ui_menu_pls_cx_team,ty0,ui_menu_pls_cx_color,ty0+ui_menu_pls_lh,PlayerSlotChangeTeam (PlayerClient,i+1,255,true));
     end;


   // campaing scirmish game multiplayer
   tx0:=ui_menu_cgm_zx0;
   ty0:=ui_menu_cgm_zy0;

   SetItem(mi_tab_campaing   ,tx0,ty0,tx0+ui_menu_cgm_cw,ty0+ui_menu_cgm_lh,false and(not g_started)and(net_status=ns_single));
   tx0+=ui_menu_cgm_cw;
   SetItem(mi_tab_game       ,tx0,ty0,tx0+ui_menu_cgm_cw,ty0+ui_menu_cgm_lh,(menu_s2<>ms2_camp)or(not g_started));
   tx0+=ui_menu_cgm_cw;
   SetItem(mi_tab_multiplayer,tx0,ty0,tx0+ui_menu_cgm_cw,ty0+ui_menu_cgm_lh,(menu_s2<>ms2_camp)or(not g_started));

   case menu_s2 of
ms2_camp: begin
          end;
ms2_game: begin
             ty0+=ui_menu_cgm_lh;
             ty1:=0;
             while(ty0<ui_menu_cgm_zy1)do
             begin
                SetItem(mi_game_GameCaption+ty1,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,true);

                ty0+=ui_menu_cgm_lh;
                ty1+=1;
             end;

             menu_items[mi_game_mode         ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_gamemode    ,0,true);
             menu_items[mi_game_builders     ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_builders    ,0,true);
             menu_items[mi_game_generators   ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_generators  ,0,true);
             menu_items[mi_game_FixStarts    ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_FixStarts   ,0,true);
             menu_items[mi_game_DeadPbserver ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_DeadPbserver,0,true);
             menu_items[mi_game_EmptySlots   ].mi_enabled:=GameSetCommonSetting(PlayerClient,nmid_lobbby_EmptySlots  ,0,true);

             menu_items[mi_game_RecordStatus ].mi_enabled:=rpls_state<rpls_state_read;
             menu_items[mi_game_RecordName   ].mi_enabled:=rpls_state=rpls_state_none;
             menu_items[mi_game_RecordQuality].mi_enabled:=true;
          end;
ms2_mult: begin
             ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_ServerCaption,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,(net_status<>ns_client)                     );ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_ServerPort   ,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh, net_status<>ns_server                      );ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_ServerToggle ,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,(net_status<>ns_client)and(not G_Started)   );ty0+=ui_menu_cgm_lh;

             SetItem(mi_mplay_ClientCaption,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,(net_status<>ns_server)                     );ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_NetSearch    ,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,(net_status<>ns_server)and(not G_Started)   );ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_ClientAddress,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh, net_status<>ns_client                      );ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_ClientConnect,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,(net_status<>ns_server)and(not net_svsearch)
                                                                                                   and((net_status=ns_client)or(not G_Started)));ty0+=ui_menu_cgm_lh;
             SetItem(mi_mplay_ClientQuality,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh, net_status<>ns_server);
{
mi_mplay_Chat           : ;
}
          end;
   end;

   {
   if(ui_menu_ssr_zx0<mouse_x)and(mouse_x<ui_menu_ssr_zx1)and(ui_menu_ssr_zy0<mouse_y)and(mouse_y<ui_menu_ssr_zy1)then
   begin
      // SETTINGS
      // 3 4 5
      // 6 ...14
      // 15...23
      // 24...32
      // 33...35
      menu_item:=(mouse_y-ui_menu_ssr_zy0) div ui_menu_ssr_ys;
      if(menu_item=0)then
      begin
         menu_item:=3+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs);

         case menu_item of
         4: if not ((net_status=ns_single)and(rpls_state<rpls_state_read))then menu_item:=0;
         5: if (net_status<>ns_single)then menu_item:=0;
         end;
      end
      else
      begin
         if(menu_s1=ms1_sett)then
         begin
            if(menu_item=1)
            then menu_item:=33+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs)
            else
              case menu_s3 of
              ms3_game: menu_item:=4 +menu_item;
              ms3_vido: menu_item:=13+menu_item;
              ms3_sond: menu_item:=22+menu_item;
              end;
         end;
         if(menu_s1=ms1_svld)then  // 36..40
         begin
            if(menu_item in [1..8])and(mouse_x<ui_menu_ssl_x0)then menu_item:=36
            else
              if(menu_item=9)and(mouse_x<ui_menu_ssl_x0)
              then menu_item:=37
              else
                if(menu_item=10)
                then menu_item:=38+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs)
                else menu_item:=0;
         end;
         if(menu_s1=ms1_reps)then  // 41..44
         begin
            if(menu_item in [1..9])and(mouse_x<ui_menu_ssl_x0)then menu_item:=41
            else
              if(menu_item=10)
              then menu_item:=42+((mouse_x-ui_menu_ssr_zx0) div ui_menu_ssr_xs)
              else menu_item:=0;
         end;
      end;
   end;

   if(G_Started=false)then
   begin
      if(net_status<ns_client)then
      begin
         // MAP
         if(menu_s2<>ms2_camp)then
          if(ui_menu_map_rx0<mouse_x)and(mouse_x<ui_menu_map_rx1)and(ui_menu_map_y0 <mouse_y)and(mouse_y<ui_menu_map_y1)then
           menu_item:=50+((mouse_y-ui_menu_map_y0) div ui_menu_map_ys);
      end;

      // PLAYERS
      if(menu_s2<>ms2_camp)and(not net_svsearch)then
      if(ui_menu_pls_zy0<mouse_y)and(mouse_y<ui_menu_pls_zy1)then
      begin
         if(ui_menu_pls_zxn<mouse_x)and(mouse_x<ui_menu_pls_zxs)then menu_item:=60;
         if(ui_menu_pls_zxs<mouse_x)and(mouse_x<ui_menu_pls_zxr)then menu_item:=61;
         if(ui_menu_pls_zxr<mouse_x)and(mouse_x<ui_menu_pls_zxt)then menu_item:=62;
         if(ui_menu_pls_zxt<mouse_x)and(mouse_x<ui_menu_pls_zxc)then menu_item:=63;
      end;

      //Net Search
      if(net_status=ns_client)and(net_svsearch)then
      if (ui_menu_pls_zx0<mouse_x)and(mouse_x<ui_menu_pls_zx1)then
      begin
         if(ui_menu_pls_zy0<mouse_y)and(mouse_y<ui_menu_pls_ye)then menu_item:=102;
         if(ui_menu_pls_ye<mouse_y)and(mouse_y<ui_menu_pls_zy1)then menu_item:=103;
      end;
   end;

   if(ui_menu_csm_x0<mouse_x)and(mouse_x<ui_menu_csm_x1)and(ui_menu_csm_y0<mouse_y)and(mouse_y<ui_menu_csm_y1)then
   begin
      menu_item:=(mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys;
      if(menu_item=0)
      then menu_item:=70+((mouse_x-ui_menu_csm_x0) div ui_menu_csm_xs)
      else
      begin
         if(menu_s2=ms2_game)then
         begin
            menu_item:=72+menu_item;  // 73..84
            if(menu_item=83)and(mouse_x<ui_menu_csm_xc)then menu_item:=0;
         end;
         if(menu_s2=ms2_mult)then
         begin
            menu_item:=84+menu_item;  // 85..96
            if(m_chat)and(menu_item<>96)then menu_item:=100;
            if(menu_item=92)then
              if(mouse_x>ui_menu_csm_x3)then menu_item:=101;
         end;
         if(menu_s2=ms2_camp)then
          if(menu_item=1)
          then menu_item:=97
          else menu_item:=98;
      end;
   end;    }

   if(menu_list_n>0)then
    with menu_items[menu_item] do
     if(not mi_enabled)then menu_List_Clear;
end;

function StringApplyInput(s:shortstring;charset:TSoc;ms:byte;ChangedResult:pBoolean):shortstring;
var i:byte;
    c:char;
begin
   StringApplyInput:=s;
   if(length(k_keyboard_string)>0)then
    for i:=1 to length(k_keyboard_string) do
    begin
       c:=k_keyboard_string[i];
       if(c=#8)   // backspace
       then delete(s,length(s),1)
       else
        if(length(s)>=ms)
        then break
        else
          if(c in charset)then s+=c;
   end;
   k_keyboard_string:='';
   if(ChangedResult<>nil)then
     ChangedResult^:=StringApplyInput<>s;
   StringApplyInput:=s;
end;

function menu_UnderCursor(mi:byte):boolean;
begin
   mouse_x-=menu_x;
   mouse_y-=menu_y;
   menu_UnderCursor:=false;
   with menu_items[mi] do
     menu_UnderCursor:=(mi_enabled)and(mi_x0<=mouse_x)and(mouse_x<=mi_x1)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1);
   mouse_x+=menu_x;
   mouse_y+=menu_y;
end;

procedure menu_SelectItem;
var i:byte;
begin
   menu_item:=0;
   mouse_x-=menu_x;
   mouse_y-=menu_y;
   for i:=1 to 255 do
     with menu_items[i] do
       if(mi_enabled)and(mi_x0<=mouse_x)and(mouse_x<=mi_x1)and(mi_y0<=mouse_y)and(mouse_y<=mi_y1)then
       begin
          menu_item:=i;
          break;
       end;
   mouse_x+=menu_x;
   mouse_y+=menu_y;
end;

////////////////////////////////////////////////////////////////////////////////
//  MENU LIST

procedure menu_list_SelectItem;
var x,y:integer;
begin
   x:=menu_list_x-menu_list_w+menu_x;
   y:=menu_list_y+menu_y;
   mouse_x-=x;
   mouse_y-=y;
   if(0<=mouse_x)and(mouse_x<=menu_list_w)and(0<=mouse_y)then menu_list_selected:=mouse_y div ui_menu_list_item_H;
   if(menu_list_selected>=menu_list_n)
   or(menu_list_selected< 0)
   then menu_list_selected:=-1;
   if(not menu_list_items[menu_list_selected].mli_enabled)
   then menu_list_selected:=-1;
   mouse_x+=x;
   mouse_y+=y;
end;


procedure menu_list_SetCommonSettings(mi:byte;MinWidth:pinteger);
begin
   with menu_items[mi] do
   begin
      if(MinWidth^<0)then MinWidth^:=(mi_x1-mi_x0) div abs(MinWidth^);
      menu_list_x:=mi_x1;
      menu_list_y:=mi_y1;
   end;
   menu_list_w:=0;
   menu_list_n:=0;
   setlength(menu_list_items,menu_list_n);
end;
procedure menu_list_AddItem(acaption:shortstring;avalue:integer;aenabled:boolean;MinWidth:integer);
begin
   menu_list_n+=1;
   setlength(menu_list_items,menu_list_n);
   with menu_list_items[menu_list_n-1] do
   begin
      mli_caption:=acaption;
      mli_value  :=avalue;
      mli_enabled:=aenabled;
   end;
   menu_list_w:=max3i(MinWidth,menu_list_w,font_w*length(acaption)+font_w);
end;

procedure menu_list_MakeFromStr(mi:byte;pfstring:pshortstring;size,CurrVal,MinWidth:integer);
var n:integer;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=CurrVal;
      n:=size div SizeOf(shortstring);
      while(n>0)do
      begin
         menu_list_AddItem(pfstring^,menu_list_n,true,MinWidth);
         pfstring+=1;
         n-=1;
      end;
   end;
end;
procedure menu_list_MakeFromInts(mi:byte;maxI,minI,StepI,CurrVal,MinWidth:integer);
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      if(minI>maxI)then exit;
      while(minI<=maxI)do
      begin
         if(CurrVal=minI)then menu_list_current:=menu_list_n;
         menu_list_AddItem(i2s(minI),menu_list_n,menu_list_current<>menu_list_n,MinWidth);
         minI+=StepI;
      end;
   end;
end;
procedure menu_list_MakeFromIntAr(mi:byte;pfint:pinteger;size,CurrVal,MinWidth:integer);
var n:integer;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      n:=size div SizeOf(integer);
      while(n>0)do
      begin
         if(pfint^=CurrVal)then menu_list_current:=menu_list_n;
         menu_list_AddItem(i2s(pfint^),menu_list_n,menu_list_current<>menu_list_n,MinWidth);
         pfint+=1;
         n-=1;
      end;
   end;
end;
procedure menu_list_MakePlayerSlot(mi:byte;PlayerTarget:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      for i:=0 to ps_states_n-1 do
        if(PlayerSlotChangeState(PlayerClient,PlayerTarget,i,true))then
        begin
           if(g_slot_state[PlayerTarget]=i)then
             menu_list_current:=menu_list_n;
           menu_list_AddItem(str_PlayerSlots[i],i,true,MinWidth);
        end;
   end;
end;
procedure menu_list_MakePlayerTeam(mi:byte;PlayerTarget:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=-1;
      for i:=0 to MaxPlayers do
        if(PlayerSlotChangeTeam(PlayerClient,PlayerTarget,i,true))then
        begin
           with g_players[PlayerTarget] do
             if(team=i)then
               menu_list_current:=menu_list_n;
           menu_list_AddItem(str_teams[i],i,true,MinWidth);
        end;
   end;
end;
procedure menu_list_MakeAISlots(mi:byte;CurVal,MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=CurVal;
      menu_list_AddItem(str_ps_none,0,true,MinWidth);
      for i:=ps_AI_1 to ps_AI_11 do
        menu_list_AddItem(str_PlayerSlots[i],i-ps_AI_1+1,true,MinWidth);
   end;
end;
procedure menu_list_MakeGamePresets(mi:byte;MinWidth:integer);
var i:byte;
begin
   menu_list_SetCommonSettings(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_current:=g_preset_cur;
      if(g_preset_n>0)then
       for i:=0 to g_preset_n-1 do
         menu_list_AddItem(g_presets[i].gp_name,i,true,MinWidth);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//  MENU BASE

procedure menu_nsearch_connect;
begin
   if(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn)then ;
   begin
      net_svsearch:=false;
      net_dispose;
      net_status    :=ns_single;
      net_status_str:='';
      if(net_UpSocket(0))then
      begin
         with net_svsearch_list[net_svsearch_sel] do net_cl_svstr:=c2ip(ip)+':'+w2s(swap(port));
         net_cl_saddr;
         net_status_str:=str_connecting;
         net_status    :=ns_client;
         rpls_pnu      :=0;
         menu_s1       :=ms1_sett;
      end
      else net_dispose;
   end;
end;

function menu_GetBarVal(mi:byte;max:integer):integer;
var tx0,tx1:integer;
begin
   menu_GetBarVal:=0;
   with menu_items[mi] do
   begin
      tx1:=mi_x1-font_w;
      tx0:=tx1-max;
      mouse_x-=menu_x+tx0;
      mouse_y-=menu_y;

      if(mi_y0<mouse_y)and(mouse_y<mi_y1)then menu_GetBarVal:=mm3i(1,mouse_x,max);

      mouse_x+=menu_x+tx0;
      mouse_y+=menu_y;
   end;
end;
procedure menu_item_ListLine(mi:byte;svar:pinteger;scroll,lineh:integer);
begin
   with menu_items[mi] do
   begin
      mouse_x-=menu_x;
      mouse_y-=menu_y;

      if (mi_x0<mouse_x)and(mouse_x<mi_x1)
      and(mi_y0<mouse_y)and(mouse_y<mi_y1)
      then svar^:=scroll+((mouse_y-mi_y0) div lineh);

      mouse_x+=menu_x;
      mouse_y+=menu_y;
   end;
end;


procedure menu_mouse;
var
UpdateItems:boolean;
menu_list_SIndex,
p          :integer;
begin
   menu_list_selected:=-1;
   if(menu_list_n>0)then
   begin
      menu_list_SelectItem;
      if(ks_mleft=1)and(menu_list_selected=-1)
      then menu_List_Clear
   end
   else
     if(ks_mleft=1)then
     begin
        case menu_item of
mi_mplay_ClientAddress : net_cl_saddr;
mi_settings_PlayerName : begin
                         if(length(PlayerName)=0)then PlayerName:=str_defaultPlayerName;
                         g_players[PlayerClient].name:=PlayerName;
                         end;
        end;
        menu_SelectItem;
        menu_remake:=true;
        SoundPlayUI(snd_click);
     end;

   if(ks_mleft=1)then        // left button pressed
   begin
      UpdateItems:=true;

      if(-1<menu_list_selected)and(menu_list_selected<menu_list_n)
      then menu_list_SIndex:=menu_list_items[menu_list_selected].mli_value;

      case menu_item of
mi_exit                   : GameCycle:=false;
mi_back                   : menu_Toggle;
mi_start                  : if(net_status=ns_client)
                            then net_send_byte(nmid_start)
                            else GameStart(PlayerClient,false);
mi_break                  : if(net_status=ns_client)
                            then net_send_byte(nmid_break)
                            else GameBreak(PlayerClient,false);
mi_surrender              : begin
                            if(net_status=ns_client)
                            then net_send_byte(nmid_surrender)
                            else
                              if(net_status=ns_server)then
                              begin
                                 PlayerSpecialDefeat(PlayerClient,true,false);
                                 if(g_started)then menu_Toggle;
                              end
                              else GameBreak(PlayerClient,false);
                            end;

//////////////////////////////////////////    MAP
mi_map_params1            : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(nmid_lobbby_preset,byte(menu_list_selected))
                               else GameLoadPreset(PlayerClient,byte(menu_list_selected),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeGamePresets(menu_item,-2);
mi_map_params2            : ;// seed;
mi_map_params3            : if(menu_list_selected>-1)then
                            begin
                               p:=MinMapSize+(StepMapSize*menu_list_SIndex);
                               if(net_status=ns_client)
                               then net_send_MIDInt(             nmid_lobbby_mapsize,p)
                               else map_SetSetting (PlayerClient,nmid_lobbby_mapsize,p,false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromInts(menu_item,MaxMapSize,MinMapSize,StepMapSize,map_size,-2);
mi_map_params4            : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_lobbby_type,byte(menu_list_selected))
                               else map_SetSetting  (PlayerClient,nmid_lobbby_type,byte(menu_list_selected),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_typel[0],SizeOf(str_map_typel),map_type,-2);
mi_map_params5            : if(menu_list_selected>-1)then
                            begin
                               menu_List_Clear;
                               if(net_status=ns_client)
                               then net_send_MIDByte(             nmid_lobbby_symmetry,byte(menu_list_selected))
                               else map_SetSetting  (PlayerClient,nmid_lobbby_symmetry,byte(menu_list_selected),false);
                            end
                            else menu_list_MakeFromStr(menu_item,@str_map_syml[0],SizeOf(str_map_syml),map_symmetry,-2);
mi_map_params6            : begin
                               Map_randommap;
                               Map_premap;
                            end;

//////////////////////////////////////////    TABS
mi_tab_settings           :       menu_s1:=ms1_sett;
mi_tab_saveload           : begin menu_s1:=ms1_svld; saveload_MakeFolderList; end;
mi_tab_replays            : begin menu_s1:=ms1_reps; if(not G_Started)then replay_MakeFolderList; end;

//////////////////////////////////////////    SETTINGS TABS
mi_settings_game          : menu_s3:=ms3_game;
mi_settings_video         : begin
                            menu_s3:=ms3_vido;
                            menu_res_w:=vid_vw;
                            menu_res_h:=vid_vh;
                            end;
mi_settings_sound         : menu_s3:=ms3_sond;

//////////////////////////////////////////    SETTINGS  GAME
mi_settings_ColoredShadows: vid_ColoredShadow:=not vid_ColoredShadow;
mi_settings_ShowAPM       : vid_APM:=not vid_APM;
mi_settings_HitBars       : if(menu_list_selected>-1)
                            then begin vid_uhbars:=menu_list_SIndex;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_uhbars[0],SizeOf(str_uhbars),vid_uhbars,-2);
mi_settings_MRBAction     : if(menu_list_selected>-1)
                            then begin m_action:=menu_list_SIndex>0;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_mactionl[false],SizeOf(str_mactionl),integer(m_action),-2);
mi_settings_ScrollSpeed   : vid_CamSpeed:=menu_GetBarVal(menu_item,max_CamSpeed);
mi_settings_MouseScroll   : vid_CamMScroll:=not vid_CamMScroll;
mi_settings_PlayerName    : ;   // playername
mi_settings_Langugage     : if(menu_list_selected>-1)then
                            begin
                               ui_language:=menu_list_SIndex>0;
                               menu_List_Clear;
                               SwitchLanguage;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_lng[false],SizeOf(str_lng),integer(ui_language),-3);
mi_settings_PanelPosition : if(menu_list_selected>-1)then
                            begin
                               vid_PannelPos:=menu_list_SIndex;
                               menu_List_Clear;
                               vid_ScreenSurfaces;
                               //theme_map_pterrain1:=255;
                               //gfx_MakeTerrain;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_panelposp[0],SizeOf(str_panelposp),integer(vid_PannelPos),-2);
mi_settings_PlayerColors  : if(menu_list_selected>-1)
                            then begin vid_plcolors:=menu_list_SIndex;menu_List_Clear; end
                            else menu_list_MakeFromStr(menu_item,@str_pcolors[0],SizeOf(str_pcolors),integer(vid_plcolors),-2);
mi_settings_game11        : ;

//////////////////////////////////////////    SETTINGS  VIDEO
mi_settings_ResWidth      : if(menu_list_selected>-1)
                            then begin menu_res_w:=vid_rw_list[menu_list_SIndex];menu_List_Clear;end
                            else menu_list_MakeFromIntAr(menu_item,@vid_rw_list[0],SizeOf(vid_rw_list),menu_res_w,-3);
mi_settings_ResHeight     : if(menu_list_selected>-1)
                            then begin menu_res_h:=vid_rh_list[menu_list_SIndex];menu_List_Clear;end
                            else menu_list_MakeFromIntAr(menu_item,@vid_rh_list[0],SizeOf(vid_rh_list),menu_res_h,-3);
mi_settings_ResApply      : begin
                            vid_vw:=menu_res_w;
                            vid_vh:=menu_res_h;
                            vid_MakeScreen;
                            ///theme_map_pterrain1:=255;
                            //gfx_MakeTerrain;
                            end;

mi_settings_Fullscreen    : begin vid_fullscreen:=not vid_fullscreen; vid_MakeScreen;end;
mi_settings_ShowFPS       : vid_FPS:=not vid_FPS;

//////////////////////////////////////////    SETTINGS  SOUND
mi_settings_SoundVol      : begin
                            snd_svolume1:=menu_GetBarVal(menu_item,max_svolume)/max_svolume;
                            SoundSourceUpdateGainAll;
                            end;
mi_settings_MusicVol      : begin
                            snd_mvolume1:=menu_GetBarVal(menu_item,max_svolume)/max_svolume;
                            SoundSourceUpdateGainAll;
                            end;
mi_settings_NextTrack     : SoundMusicControll(true);

//////////////////////////////////////////    SAVE LOAD

mi_saveload_save          : saveload_Save;
mi_saveload_load          : saveload_Load;
mi_saveload_delete        : saveload_Delete;
mi_saveload_list          : begin
                            menu_item_ListLine(menu_item,@svld_list_sel,svld_list_scroll,ui_menu_ssr_lh);
                            saveload_Select;
                            end;

//////////////////////////////////////////    REPLAYS PLAYER
mi_replays_list           : begin
                            menu_item_ListLine(menu_item,@rpls_list_sel,rpls_list_scroll,ui_menu_ssr_lh);
                            replay_Select;
                            end;
mi_replays_play           : begin
                               menu_s2:=ms2_game;
                               rpls_state:=rpls_state_read;
                               g_started:=true;
                            end;
mi_replays_delete         : replay_Delete;

//////////////////////////////////////////    PLAYERS
mi_player_status1,
mi_player_status2,
mi_player_status3,
mi_player_status4,
mi_player_status5,
mi_player_status6         : begin
                               p:=menu_item-mi_player_status1+1;
                               if(menu_list_selected>-1)then
                               begin
                                  if(PlayerSlotChangeState(PlayerClient,p,menu_list_SIndex,true))then
                                    if(net_status=ns_client)
                                    then net_send_PlayerSlot(p,menu_list_SIndex)
                                    else PlayerSlotChangeState(PlayerClient,p,menu_list_SIndex,false);
                                  menu_List_Clear;
                               end
                               else menu_list_MakePlayerSlot(menu_item,p,-1);
                            end;
mi_player_race1,
mi_player_race2,
mi_player_race3,
mi_player_race4,
mi_player_race5,
mi_player_race6           : begin
                               p:=menu_item-mi_player_race1+1;
                               if(menu_list_selected>-1)then
                               begin
                                  if(PlayerSlotChangeRace(PlayerClient,p,menu_list_SIndex,true))then
                                    if(net_status=ns_client)
                                    then net_send_PlayerRace(p,menu_list_SIndex)
                                    else PlayerSlotChangeRace(PlayerClient,p,menu_list_SIndex,false);
                                  menu_List_Clear;
                               end
                               else menu_list_MakeFromStr(menu_item,@str_racel[0],SizeOf(str_racel),g_players[p].slot_race,-1);
                            end;
mi_player_team1,
mi_player_team2,
mi_player_team3,
mi_player_team4,
mi_player_team5,
mi_player_team6           : begin
                               p:=menu_item-mi_player_team1+1;
                               if(menu_list_selected>-1)then
                               begin
                                  if(PlayerSlotChangeTeam(PlayerClient,p,menu_list_SIndex,true))then
                                    if(net_status=ns_client)
                                    then net_send_PlayerTeam(p,menu_list_SIndex)
                                    else PlayerSlotChangeTeam(PlayerClient,p,menu_list_SIndex,false);
                                  menu_List_Clear;
                               end
                               else menu_list_MakePlayerTeam(menu_item,p,-1);
                            end;

//////////////////////////////////////////    campaings game multiplayer  tabs
mi_tab_campaing           : menu_s2:=ms2_camp;
mi_tab_game               : menu_s2:=ms2_game;
mi_tab_multiplayer        : menu_s2:=ms2_mult;

//////////////////////////////////////////    GAME SETTINGS
mi_game_mode              : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_gamemode,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_gamemode,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_gmode[0],SizeOf(str_gmode),integer(g_mode),-2);
mi_game_builders          : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_builders,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_builders,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromInts(menu_item,gms_g_startb+1,1,1,integer(g_start_base)+1,-4);

mi_game_generators        : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_generators,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_generators,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_generatorsO[0],SizeOf(str_generatorsO),integer(g_generators),-2);
mi_game_FixStarts         : if(net_status=ns_client)
                            then net_send_MIDByte    (             nmid_lobbby_FixStarts   ,byte(not g_fixed_positions))
                            else GameSetCommonSetting(PlayerClient,nmid_lobbby_FixStarts   ,byte(not g_fixed_positions),false);
mi_game_DeadPbserver      : if(net_status=ns_client)
                            then net_send_MIDByte    (             nmid_lobbby_DeadPbserver,byte(not g_deadobservers))
                            else GameSetCommonSetting(PlayerClient,nmid_lobbby_DeadPbserver,byte(not g_deadobservers),false);
mi_game_EmptySlots        : if(menu_list_selected>-1)then
                            begin
                               if(net_status=ns_client)
                               then net_send_MIDByte    (             nmid_lobbby_EmptySlots,byte(menu_list_SIndex))
                               else GameSetCommonSetting(PlayerClient,nmid_lobbby_EmptySlots,byte(menu_list_SIndex),false);
                               menu_List_Clear;
                            end
                            else menu_list_MakeAISlots(menu_item,integer(g_ai_slots),-2);
mi_game_RandomSkrimish    : MakeRandomSkirmish(false);

mi_game_RecordStatus      : if(rpls_state=rpls_state_none)
                            then rpls_state:=rpls_state_write
                            else rpls_state:=rpls_state_none;
mi_game_RecordName        : ;
mi_game_RecordQuality     : if(menu_list_selected>-1)then
                            begin
                               rpls_pnui:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_pnua[0],SizeOf(str_pnua[0])*(cl_UpT_arrayN_RPLs+1),integer(rpls_pnui),-3);

//////////////////////////////////////////    MULTIPLAYER

mi_mplay_ServerPort       : ;
mi_mplay_ServerToggle     : if(net_status=ns_server)then
                            begin
                               net_dispose;
                               GameDefaultAll;
                               g_started :=false;
                               net_status:=ns_single;
                            end
                            else
                            begin
                               net_sv_sport;
                               if(net_UpSocket(net_port))then
                               begin
                                  menu_s1   :=ms1_sett;
                                  PlayersSetDefault;
                                  net_status:=ns_server;
                               end
                               else net_dispose;
                            end;

mi_mplay_ClientConnect    : if(net_status=ns_client)
                            then GameBreakClientGame
                            else
                              if(net_UpSocket(0))then
                              begin
                                 net_status_str:=str_connecting;
                                 net_status :=ns_client;
                                 net_cl_saddr;
                                 rpls_pnu:=0;
                                 menu_s1 :=ms1_sett;
                              end
                              else net_dispose;
mi_mplay_ClientAddress    : ;
mi_mplay_Chat             : ;

mi_mplay_NetSearch        : if(net_status=ns_client)then
                            begin
                               if(net_svsearch)then
                               begin
                                  net_svsearch:=false;
                                  net_dispose;
                                  net_status :=ns_single;
                                  net_status_str:='';
                               end;
                            end
                            else
                              if(net_UpSocket(net_svlsearch_port))then
                              begin
                                 net_status_str:=str_netsearching;
                                 net_status  :=ns_client;
                                 net_svsearch:=true;
                                 menu_s1     :=ms1_sett;
                                 SetLength(net_svsearch_list,0);
                                 net_svsearch_listn :=0;
                                 net_svsearch_scroll:=0;
                                 net_svsearch_sel   :=0;
                              end
                              else net_dispose;
mi_mplay_NetSearchList    : if(mleft_dbl_click>0)
                            then menu_nsearch_connect
                            else menu_item_ListLine(menu_item,@net_svsearch_sel,net_svsearch_scroll,ui_menu_nsrch_lh3);
mi_mplay_NetSearchCon     : menu_nsearch_connect;
mi_mplay_ClientQuality    : if(menu_list_selected>-1)then
                            begin
                               net_pnui:=menu_list_SIndex;
                               menu_List_Clear;
                            end
                            else menu_list_MakeFromStr(menu_item,@str_pnua[0],SizeOf(str_pnua),integer(net_pnui),-3);


{

     /// SETTINGS SAVE REPLAYS
      11 : if not ((net_status=ns_single)and(G_Started=false))then menu_item:=0;


      // save load
      36 : if(svld_list_size>0)then
           begin
               svld_list_sel:=svld_list_scroll+((mouse_y-ui_menu_ssr_zy0-ui_menu_ssr_ys)div ui_menu_ssr_ys);
              saveload_Select;
           end;
      37 : if(G_Started=false)then menu_item:=0;
      38 : if(G_Started)and(svld_str_fname<>'')then
      39 : if(0<=svld_list_sel)and(svld_list_sel<svld_list_size)then ;
      40 : if(0<=svld_list_sel)and(svld_list_sel<svld_list_size)then ;

      // replays
      41 : if(rpls_list_size>0)and(rpls_state<rpls_state_read)then
           begin
              rpls_list_sel :=rpls_list_scroll+((mouse_y-ui_menu_ssr_zy0)div ui_menu_ssr_ys)-1;
              replay_Select;
           end;
      42 : if(0<=rpls_list_sel)and(rpls_list_sel<rpls_list_size)and(G_Started=false)then
           begin
              menu_s2:=ms2_game;
              rpls_state:=rpls_state_read;
              g_started:=true;
           end;
      43 : ;
      44 : if(rpls_list_size>0)and(rpls_list_sel<rpls_list_size)and(G_Started=false)then replay_Delete;


      // PLAYERS table
      60 : if(net_status<ns_client)then PlayerSwitchAILevel( ((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys) +1);
      61 : if(net_status<ns_client)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(p<>PlayerClient)then
               with g_players[p] do
                if (state<>ps_none)
                then PlayerSetState(p,ps_none)
                else
                begin
                   PlayerSetState(p,PS_Comp);
                   if(team=0)then team:=p;
                end;
           end;
      62 : if(net_status<ns_client)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with g_players[p] do
               if(team>0)then
                if(state=ps_comp)or(p=PlayerClient)then
                begin
                   race+=1;
                   race:=race mod 3;
                   mrace:=race;
                end;
           end;
      63 : if(net_status<ns_client)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with g_players[p] do
               if(state=ps_comp)or(p=PlayerClient)then
                if(team<MaxPlayers)then team+=1;
           end;

      // CAMP SCIRMISH MULTIPLAY
      //70 : if not(G_Started)then menu_s2:=ms2_camp;
      71 : if not(G_Started and(menu_s2=ms2_camp))then begin p:=menu_s2;menu_s2:=ms2_game;if(p=ms2_camp)then Map_premap;end;
      72 : if not(G_Started and(menu_s2=ms2_camp))then begin menu_s2:=ms2_mult; if(m_chat)then menu_item:=100; end;



      //// multiplayer
      // server
      86 :
      87 : if(net_status<>ns_single)then menu_item:=0; // port

      // client
      91 :

      101:
      102: if(net_status=ns_client)and(not G_Started)and(net_svsearch)and(net_svsearch_listn>0)then
             net_svsearch_sel:=net_svsearch_scroll+((mouse_y-ui_menu_pls_zy0)div ui_menu_pls_ys3);
      103: if(net_status=ns_client)and(not G_Started)and(net_svsearch)and(net_svsearch_listn>0)then
           if(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn)then
           begin
              net_svsearch:=false;
              net_dispose;
              net_status :=ns_single;
              net_status_str:='';
              if(net_UpSocket(0))then
              begin
                 with net_svsearch_list[net_svsearch_sel] do net_cl_svstr:=c2ip(ip)+':'+w2s(swap(port));
                 net_cl_saddr;
                 net_status_str:=str_connecting;
                 net_status :=ns_client;
                 net_cl_saddr;
                 rpls_pnu:=0;
                 menu_s1 :=ms1_sett;
              end
              else net_dispose;
           end;
      92 : if(net_status<>ns_single)then menu_item:=0; // addr
      93 : if(net_status<>ns_server)then ScrollByte(@net_pnui,true,0,cl_UpT_arrayN);
      94 : if(G_Started=false)and(net_status<>ns_server)then
            if(mouse_x<ui_menu_csm_x2)
            then ScrollByte(@PlayerTeam,true,0,MaxPlayers)
            else
              if(mouse_x<ui_menu_csm_x3)
              then begin if(PlayerTeam>0)then PlayerRace+=1; PlayerRace:=PlayerRace mod 3;end
              else PlayerReady:=not PlayerReady;
      96 : if(net_status<>ns_single)and(not net_svsearch)then
           begin
              m_chat:=not m_chat;
              if(m_chat)then menu_item:=100;
           end;

      // camps
      97 : ScrollByte(@campain_skill,true,0,6);
      98 : begin
              campain_mission_n:=_cmp_sm+((mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(campain_mission_n>=MaxMissions)then campain_mission_n:=MaxMissions-1;
           end; }
      else UpdateItems:=false;
      end;

      if(UpdateItems)then menu_remake:=true;
   end;

   {if(ks_mright=1)then    // right button pressed
   begin
      case menu_item of
      // MAP
      51 : begin Map_randomseed;                                  Map_premap;end;
      52 : begin ScrollInt (@map_size      ,-StepMapSize,MinMapSize,MaxMapSize   );Map_premap;end;
      53 : begin ScrollByte(@map_type    ,false    ,0       ,gms_m_types);Map_premap;end;
      54 : begin ScrollByte(@map_symmetry,false    ,0       ,2          );Map_premap;end;

      60 : if(not net_svsearch)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(net_status=ns_client)
              then net_send_SwapSlot(p)
              else PlayersSwap(p,PlayerClient);
           end;
      63 : if(net_status<ns_client)and(not G_Started)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              with g_players[p] do
               if(state=ps_comp)or(p=PlayerClient)then
                if(team>byte(state=ps_comp))then team-=1;
           end;

      74 : if(net_status<ns_client)and(not G_Started)then begin ScrollByteSet(@g_mode,false,@allgamemodes        );Map_premap;end;
      75 : if(net_status<ns_client)and(not G_Started)then       ScrollByte   (@g_start_base,false,0,gms_g_startb );
      77 : if(net_status<ns_client)and(not G_Started)then       ScrollByte   (@g_ai_slots  ,false,0,gms_g_maxai  );
      78 : if(net_status<ns_client)and(not G_Started)then begin ScrollByte   (@g_generators,false,0,gms_g_maxgens);Map_premap;end;

      80 : if(net_status<ns_client)and(not G_Started)then MakeRandomSkirmish(true);

      84 : ScrollByte(@rpls_pnui,false,0,9);

      93 : if(net_status<>ns_server)then ScrollByte(@net_pnui,false,0,9);
      94 : if(G_Started=false)and(net_status<>ns_server)then
            if(mouse_x<ui_menu_csm_x2)then ScrollByte(@PlayerTeam,false,0,MaxPlayers);

      97 : ScrollByte(@campain_skill,false,0,CMPMaxSkills);
      end;
   end;}
end;

procedure menu_keyborad;
var UpdateItems:boolean;
begin
   UpdateItems:=false;
   if(length(k_keyboard_string)>0)then
   begin
      case menu_item of
mi_map_params2        : begin
                        map_seed  :=s2c(StringApplyInput(c2s(map_seed) ,k_kbdig ,10     ,@UpdateItems));
                        if(UpdateItems)then
                          if(net_status=ns_client)
                          then net_send_MIDCard(             nmid_lobbby_mapseed,map_seed)
                          else map_SetSetting  (PlayerClient,nmid_lobbby_mapseed,map_seed,false);
                        end;
mi_settings_PlayerName: PlayerName    :=StringApplyInput(PlayerName    ,k_kbstr ,NameLen,@UpdateItems);
mi_saveload_fname     : svld_str_fname:=StringApplyInput(svld_str_fname,k_kbstr ,SvRpLen,@UpdateItems);
mi_game_RecordName    : rpls_str_name :=StringApplyInput(rpls_str_name ,k_kbstr ,SvRpLen,@UpdateItems);
mi_mplay_ServerPort   : begin
                        net_sv_pstr   :=StringApplyInput(net_sv_pstr   ,k_kbdig ,5      ,@UpdateItems);
                        net_sv_sport;
                        end;
mi_mplay_ClientAddress: net_cl_svstr  :=StringApplyInput(net_cl_svstr  ,k_kbaddr,21     ,@UpdateItems);
mi_mplay_Chat         : net_chat_str  :=StringApplyInput(net_chat_str  ,k_kbstr ,255    ,@UpdateItems);
      else
      end;

      if(UpdateItems)then menu_remake:=true;
   end;
end;



