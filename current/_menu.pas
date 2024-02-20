

////////////////////////////////////////////////////////////////////////////////
//  MENU COMMON

procedure Menu_ReInit;
var tx0,
    tx1,
    ty0,
    ty1,i:integer;
 enable:boolean;

procedure SetItem(item:byte;ax0,ay0,ax1,ay1:integer;aenabled:boolean);
begin
   with menu_items[item] do
   begin
      x0:=min2(ax0,ax1);
      y0:=min2(ay0,ay1);
      x1:=max2(ax0,ax1);
      y1:=max2(ay0,ay1);
      enabled:=aenabled;
   end;
end;
begin
   FillChar(menu_items,SizeOf(menu_items),0);

   // main buttons
   if(G_Started)
   then SetItem(mi_back,ui_menu_mbutton_lx0,ui_menu_mbutton_y0,ui_menu_mbutton_lx1,ui_menu_mbutton_y1,true)
   else SetItem(mi_exit,ui_menu_mbutton_lx0,ui_menu_mbutton_y0,ui_menu_mbutton_lx1,ui_menu_mbutton_y1,true);

   //enable:=(net_status<>ns_client)and(G_Started or PlayersReadyStatus);
   // mi_ready - net game
   // me_surrender - net play/break
   if(G_Started)
   then SetItem(mi_break,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,net_status<>ns_client)
   else SetItem(mi_start,ui_menu_mbutton_rx0,ui_menu_mbutton_y0,ui_menu_mbutton_rx1,ui_menu_mbutton_y1,PlayersReadyStatus);

   // map section
   enable:=(not G_Started)and((PlayerLobby=PlayerClient)or(PlayerLobby=255));
   ty0:=0;
   ty1:=0;
   while(ty1<ui_menu_map_ph)do
   begin
   SetItem(mi_map_params1+ty0,ui_menu_map_px0,ui_menu_map_py0+ty1,ui_menu_map_px1,ui_menu_map_py0+ty1+ui_menu_map_lh,enable);
   ty0+=1;
   ty1+=ui_menu_map_lh;
   end;

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

             menu_items[mi_settings_PlayerName].enabled:=(net_status=ns_single)and(not G_Started);
             menu_items[mi_settings_ResApply  ].enabled:=(m_vrx<>vid_vw)or(m_vry<>vid_vh);
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

   for i:=0 to MaxPlayers-1 do
   begin
      ty0:=ui_menu_pls_pby0+i*ui_menu_pls_lh;

      SetItem(mi_player_status1+i,ui_menu_pls_pbx0   ,ty0,ui_menu_pls_cx_race ,ty0+ui_menu_pls_lh,PlayerSlotChangeState(PlayerClient,i+1,0,true));
      SetItem(mi_player_race1  +i,ui_menu_pls_cx_race,ty0,ui_menu_pls_cx_team ,ty0+ui_menu_pls_lh,PlayerSlotChangeRace (PlayerClient,i+1,0,true));
      SetItem(mi_player_team1  +i,ui_menu_pls_cx_team,ty0,ui_menu_pls_cx_color,ty0+ui_menu_pls_lh,PlayerSlotChangeTeam (PlayerClient,i+1,0,true));
   end;


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
                SetItem(mi_game_Caption+ty1,ui_menu_cgm_zx0,ty0,ui_menu_cgm_zx1,ty0+ui_menu_cgm_lh,true);

                ty0+=ui_menu_cgm_lh;
                ty1+=1;
             end;

             enable:=(G_Started=false)and(net_status<>ns_client);
             for ty1:=mi_game_Caption to mi_game_RandomSkrimish do menu_items[ty1].enabled:=enable;

             menu_items[mi_game_Record       ].enabled:=rpls_state<rpls_state_read;
             menu_items[mi_game_RecordName   ].enabled:=rpls_state=rpls_state_none;
             menu_items[mi_game_RecordQuality].enabled:=menu_items[mi_game_RecordName].enabled;
          end;
ms2_mult: begin
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
end;

function StringApplyInput(s:shortstring;charset:TSoc;ms:byte):shortstring;
var i:byte;
    c:char;
begin
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
          if(c in charset)then s:=s+c;
   end;
   k_keyboard_string:='';
   StringApplyInput:=s;
end;

procedure Menu_SelectItem;
var i:byte;
begin
   menu_item:=0;
   mouse_x-=mv_x;
   mouse_y-=mv_y;

   for i:=1 to 255 do
     with menu_items[i] do
       if(enabled)and(x0<=mouse_x)and(mouse_x<=x1)and(y0<=mouse_y)and(mouse_y<=y1)then
       begin
          menu_item:=i;
          break;
       end;

   mouse_x+=mv_x;
   mouse_y+=mv_y;
end;


////////////////////////////////////////////////////////////////////////////////
//  MENU LIST

procedure Menu_List_SelectItem;
var x,y:integer;
begin
   x:=menu_list_x-menu_list_w+mv_x;
   y:=menu_list_y+mv_y;
   mouse_x-=x;
   mouse_y-=y;
   if(0<=mouse_x)and(mouse_x<=menu_list_w)and(0<=mouse_y)then menu_list_s:=mouse_y div ui_menu_list_item_H;
   if(menu_list_s>=menu_list_n)then menu_list_s:=-1;
   mouse_x+=x;
   mouse_y+=y;
end;
procedure Menu_List_Clear;
begin
   menu_list_n:=0;
   setlength(menu_list,menu_list_n);
   menu_item:=0;
end;

procedure Menu_listCommon(mi:byte;MinWidth:pinteger);
begin
   with menu_items[mi] do
   begin
      if(MinWidth^=-1)then MinWidth^:= x1-x0;
      if(MinWidth^=-2)then MinWidth^:=(x1-x0) div 2;
      if(MinWidth^=-3)then MinWidth^:=(x1-x0) div 3;
      menu_list_x:=x1;
      menu_list_y:=y1;
   end;
end;

procedure Menu_list_MakeFromStr(mi:byte;pfstring:pshortstring;size,CurrVal,MinWidth:integer);
var i:integer;
begin
   Menu_listCommon(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_c:=CurrVal;
      menu_list_w:=0;
      menu_list_n:=size div SizeOf(shortstring);
      setlength(menu_list,menu_list_n);
      if(menu_list_n>0)then
        for i:=0 to menu_list_n-1 do
        begin
           menu_list_w:=max3(MinWidth,menu_list_w,font_w*length(pfstring^)+font_w);
           menu_list[i]:=pfstring^;
           pfstring+=1;
        end;
   end;
end;
procedure Menu_list_MakeFromInts(mi:byte;maxI,minI,StepI,CurrVal,MinWidth:integer);
begin
   Menu_listCommon(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_c:=-1;
      menu_list_w:=0;
      menu_list_n:=0;
      if(minI>maxI)then exit;
      setlength(menu_list,menu_list_n);
      while(minI<=maxI)do
      begin
         if(CurrVal=minI)then menu_list_c:=menu_list_n;
         setlength(menu_list,menu_list_n+1);
         menu_list[menu_list_n]:=i2s(minI);
         menu_list_w:=max3(MinWidth,menu_list_w,font_w*length(menu_list[menu_list_n])+font_w);
         menu_list_n+=1;
         minI+=StepI;
      end;
   end;
end;
procedure Menu_list_MakeFromIntAr(mi:byte;pfint:pinteger;size,CurrVal,MinWidth:integer);
var i:integer;
    t:shortstring;
begin
   Menu_listCommon(mi,@MinWidth);
   with menu_items[mi] do
   begin
      menu_list_c:=-1;
      menu_list_w:=0;
      menu_list_n:=size div SizeOf(integer);
      setlength(menu_list,menu_list_n);
      if(menu_list_n>0)then
        for i:=0 to menu_list_n-1 do
        begin
           if(pfint^=CurrVal)then menu_list_c:=i;
           t:=i2s(pfint^);
           menu_list_w:=max3(MinWidth,menu_list_w,font_w*length(t));
           menu_list[i]:=t;
           pfint+=1;
        end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//  MENU BASE

procedure Menu_map_SetNewSize(new_size:integer);
begin
   Menu_List_Clear;
   if(new_size<MinSMapW)or(MaxSMapW<new_size)then exit;
   // if lobby master or serverside
   map_mw:=new_size;
   // else send to server new info
   Map_premap;
end;
procedure Menu_map_SetNewType(new_type:integer);
begin
   Menu_List_Clear;
   if(new_type<0)or(gms_m_types<new_type)then exit;
   // if lobby master or serverside
   map_type:=new_type;
   // else send to server new info
   Map_premap;
end;
procedure Menu_map_SetNewSymmetry(new_symmetry:integer);
begin
   Menu_List_Clear;
   if(new_symmetry<0)or(gms_m_symm<new_symmetry)then exit;
   // if lobby master or serverside
   map_symmetry:=new_symmetry;
   // else send to server new info
   Map_premap;
end;

function Menu_GetBarVal(mi:byte;max:integer):integer;
var tx0,tx1:integer;
begin
   Menu_GetBarVal:=0;
   with menu_items[mi] do
   begin
      tx1:=x1-font_w;
      tx0:=tx1-max;
      mouse_x-=mv_x+tx0;
      mouse_y-=mv_y;

      if(y0<mouse_y)and(mouse_y<y1)then Menu_GetBarVal:=mm3(1,mouse_x,max);

      mouse_x+=mv_x+tx0;
      mouse_y+=mv_y;
   end;
end;
procedure Menu_Item2List(mi:byte;svar:pinteger;scroll,lineh:integer);
begin
   with menu_items[mi] do
   begin
      mouse_x-=mv_x;
      mouse_y-=mv_y;

      if (x0<mouse_x)and(mouse_x<x1)
      and(y0<mouse_y)and(mouse_y<y1)then
      begin
         svar^:=scroll+((mouse_y-y0) div lineh);
      end;

      mouse_x+=mv_x;
      mouse_y+=mv_y;
   end;
end;

procedure menu_mouse;
var UpdateItems:boolean;
    p:integer;
begin
   menu_list_s:=-1;
   if(menu_list_n>0)then
   begin
      Menu_List_SelectItem;
      if(ks_mleft=1)and(menu_list_s=-1)then
      begin
         menu_item:=0;
         Menu_List_Clear;
         menu_update:=true;
      end;
   end
   else
     if(ks_mleft=1)then   //right or left click
     begin
        {if(menu_item=91)then net_cl_saddr;  }
        if(menu_item=mi_settings_PlayerName)then g_players[PlayerClient].name:=PlayerName;
        Menu_SelectItem;
        menu_update:=true;
        SoundPlayUI(snd_click);
     end;

   if(ks_mleft=1)then        // left button pressed
   begin
      UpdateItems:=true;

      case menu_item of
mi_exit           : GameCycle:=false;
mi_back           : ToggleMenu;
mi_start          ,
mi_break          : GameMakeReset;

//////////////////////////////////////////    MAP
mi_map_params1    : ;// preset
mi_map_params2    : ;// seed;
mi_map_params3    : if(menu_list_s>-1)
                    then Menu_map_SetNewSize(MinSMapW+(StepSMap*menu_list_s))
                    else Menu_list_MakeFromInts(menu_item,MaxSMapW,MinSMapW,StepSMap,map_mw,-2);
mi_map_params4    : if(menu_list_s>-1)
                    then Menu_map_SetNewType(menu_list_s)
                    else Menu_list_MakeFromStr(menu_item,@str_mapt[0],SizeOf(str_mapt),map_type,-2);
mi_map_params5    : if(menu_list_s>-1)
                    then Menu_map_SetNewSymmetry(menu_list_s)
                    else Menu_list_MakeFromStr(menu_item,@str_m_symt[0],SizeOf(str_m_symt),map_symmetry,-2);
mi_map_params6    : begin
                       Map_randommap;
                       Map_premap;
                    end;

//////////////////////////////////////////    TABS
mi_tab_settings   : menu_s1:=ms1_sett;
mi_tab_saveload   : begin menu_s1:=ms1_svld; saveload_MakeFolderList; end;
mi_tab_replays    : begin menu_s1:=ms1_reps; if(not G_Started)then replay_MakeFolderList; end;

//////////////////////////////////////////    SETTINGS TABS
mi_settings_game  : menu_s3:=ms3_game;
mi_settings_video : begin
                    menu_s3:=ms3_vido;
                    m_vrx:=vid_vw;
                    m_vry:=vid_vh;
                    end;
mi_settings_sound : menu_s3:=ms3_sond;

//////////////////////////////////////////    SETTINGS  GAME
mi_settings_ColoredShadows: vid_ColoredShadow:=not vid_ColoredShadow;
mi_settings_ShowAPM       : vid_APM:=not vid_APM;
mi_settings_HitBars       : if(menu_list_s>-1)
                            then begin vid_uhbars:=menu_list_s;Menu_List_Clear; end
                            else Menu_list_MakeFromStr(menu_item,@str_uhbars[0],SizeOf(str_uhbars),vid_uhbars,-2);
mi_settings_MRBAction     : if(menu_list_s>-1)
                            then begin m_action:=menu_list_s>0;Menu_List_Clear; end
                            else Menu_list_MakeFromStr(menu_item,@str_maction2[false],SizeOf(str_maction2),integer(m_action),-2);
mi_settings_ScrollSpeed   : vid_CamSpeed:=Menu_GetBarVal(menu_item,max_CamSpeed);
mi_settings_MouseScroll   : vid_CamMScroll:=not vid_CamMScroll;
mi_settings_PlayerName    : ;   // playername
mi_settings_Langugage     : if(menu_list_s>-1)then
                            begin
                               ui_language:=menu_list_s>0;
                               Menu_List_Clear;
                               SwitchLanguage;
                            end
                            else Menu_list_MakeFromStr(menu_item,@str_lng[false],SizeOf(str_lng),integer(ui_language),-3);
mi_settings_PanelPosition : if(menu_list_s>-1)then
                            begin
                               vid_ppos:=menu_list_s;
                               Menu_List_Clear;
                               vid_ScreenSurfaces;
                               theme_map_ptrt:=255;
                               MakeTerrain;
                            end
                            else Menu_list_MakeFromStr(menu_item,@str_panelposp[0],SizeOf(str_panelposp),integer(vid_ppos),-2);
mi_settings_PlayerColors  : if(menu_list_s>-1)
                            then begin vid_plcolors:=menu_list_s;Menu_List_Clear; end
                            else Menu_list_MakeFromStr(menu_item,@str_pcolors[0],SizeOf(str_pcolors),integer(vid_plcolors),-2);
mi_settings_game11        : ;

//////////////////////////////////////////    SETTINGS  VIDEO
mi_settings_ResWidth  : if(menu_list_s>-1)
                        then begin m_vrx:=vid_rw_list[menu_list_s];Menu_List_Clear;end
                        else Menu_list_MakeFromIntAr(menu_item,@vid_rw_list[0],SizeOf(vid_rw_list),m_vrx,-3);
mi_settings_ResHeight : if(menu_list_s>-1)
                        then begin m_vry:=vid_rh_list[menu_list_s];Menu_List_Clear;end
                        else Menu_list_MakeFromIntAr(menu_item,@vid_rh_list[0],SizeOf(vid_rh_list),m_vry,-3);
mi_settings_ResApply  : begin
                        vid_vw:=m_vrx;
                        vid_vh:=m_vry;
                        vid_MakeScreen;
                        theme_map_ptrt:=255;
                        MakeTerrain;
                        end;

mi_settings_Fullscreen: begin vid_fullscreen:=not vid_fullscreen; vid_MakeScreen;end;
mi_settings_ShowFPS   : vid_FPS:=not vid_FPS;

//////////////////////////////////////////    SETTINGS  SOUND
mi_settings_SoundVol  : begin
                        snd_svolume1:=Menu_GetBarVal(menu_item,max_svolume)/max_svolume;
                        SoundSourceUpdateGainAll;
                        end;
mi_settings_MusicVol  : begin
                        snd_mvolume1:=Menu_GetBarVal(menu_item,max_svolume)/max_svolume;
                        SoundSourceUpdateGainAll;
                        end;
mi_settings_NextTrack : SoundMusicControll(true);

//////////////////////////////////////////    SAVE LOAD

mi_saveload_save  : saveload_Save;
mi_saveload_load  : saveload_Load;
mi_saveload_delete: saveload_Delete;
mi_saveload_list  : begin
                    Menu_Item2List(menu_item,@svld_list_sel,svld_list_scroll,ui_menu_ssr_lh);
                    saveload_Select;
                    end;

//////////////////////////////////////////    REPLAYS PLAYER
mi_replays_list   : begin
                    Menu_Item2List(menu_item,@rpls_list_sel,rpls_list_scroll,ui_menu_ssr_lh);
                    replay_Select;
                    end;
mi_replays_play   : begin
                       menu_s2:=ms2_game;
                       rpls_state:=rpls_state_read;
                       g_started:=true;
                    end;
mi_replays_delete : replay_Delete;

//////////////////////////////////////////    PLAYERS
mi_player_status1,
mi_player_status2,
mi_player_status3,
mi_player_status4,
mi_player_status5,
mi_player_status6 : begin
                       p:=menu_item-mi_player_status1+1;
                       if(menu_list_s>-1)then
                       begin
                          // if server or single
                          PlayerSlotChangeState(PlayerClient,p,menu_list_s,false);
                          // else send to server
                          Menu_List_Clear;
                       end
                       else Menu_list_MakeFromStr(menu_item,@str_PlayerSlots[0],SizeOf(str_PlayerSlots),g_players[p].slot_state,-1);
                    end;
mi_player_race1,
mi_player_race2,
mi_player_race3,
mi_player_race4,
mi_player_race5,
mi_player_race6   : begin
                       p:=menu_item-mi_player_race1+1;
                       if(menu_list_s>-1)then
                       begin
                          // if server or single
                          PlayerSlotChangeRace(PlayerClient,p,menu_list_s,false);
                          // else send to server
                          Menu_List_Clear;
                       end
                       else Menu_list_MakeFromStr(menu_item,@str_race[0],SizeOf(str_race),g_players[p].slot_race,-1);
                    end;
mi_player_team1,
mi_player_team2,
mi_player_team3,
mi_player_team4,
mi_player_team5,
mi_player_team6  : begin
                       p:=menu_item-mi_player_team1+1;
                       if(menu_list_s>-1)then
                       begin
                          // if server or single
                          PlayerSlotChangeTeam(PlayerClient,p,menu_list_s,false);
                          // else send to server
                          Menu_List_Clear;
                       end
                       else Menu_list_MakeFromStr(menu_item,@str_teams[0],SizeOf(str_teams),g_players[p].team,-1);
                    end;

//////////////////////////////////////////    campaings game multiplayer  tabs
mi_tab_campaing        : menu_s2:=ms2_camp;
mi_tab_game            : menu_s2:=ms2_game;
mi_tab_multiplayer     : menu_s2:=ms2_mult;

mi_game_mode           : if(menu_list_s>-1)then
                         begin
                            g_mode:=menu_list_s;
                            Map_premap;
                            Menu_List_Clear;
                         end
                         else Menu_list_MakeFromStr(menu_item,@str_gmode[0],SizeOf(str_gmode),integer(g_mode),-2);
mi_game_builders       : if(menu_list_s>-1)then
                         begin
                            g_start_base:=menu_list_s;
                            Menu_List_Clear;
                         end
                         else Menu_list_MakeFromInts(menu_item,gms_g_startb+1,1,1,integer(g_start_base),-2);

mi_game_generators     : if(menu_list_s>-1)then
                         begin
                            g_generators:=menu_list_s;
                            Map_premap;
                            Menu_List_Clear;
                         end
                         else Menu_list_MakeFromStr(menu_item,@str_generatorsO[0],SizeOf(str_generatorsO),integer(g_generators),-2);
mi_game_FixStarts      : begin g_fixed_positions:=not g_fixed_positions;          Map_premap;end;
mi_game_DeadPbserver   : g_deadobservers:=not g_deadobservers;
mi_game_EmptySlots     : if(menu_list_s>-1)then
                         begin
                            g_ai_slots:=menu_list_s;
                            Map_premap;
                            Menu_List_Clear;
                         end     нужен ai skill массив со строками
                         else Menu_list_MakeFromStr(menu_item,@str_PlayerSlots[ps_AI_1],SizeOf(str_PlayerSlots)-(SizeOf(str_PlayerSlots[0])*ps_AI_1),integer(g_ai_slots),-2);
                         //Menu_list_MakeFromInts(menu_item,gms_g_maxai,0,1,integer(g_ai_slots),-2);
mi_game_RandomSkrimish : MakeRandomSkirmish(false);

mi_game_Record         : if(rpls_state=rpls_state_none)
                         then rpls_state:=rpls_state_write
                         else rpls_state:=rpls_state_none;
mi_game_RecordName     : ;
mi_game_RecordQuality  : ScrollByte(@rpls_pnui,true,0,_cl_pnun_rpls);


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
                then PlayerSetState(p,PS_None)
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
      86 : if(net_status<ns_client)and(not G_Started)and(mouse_x>ui_menu_csm_xc)then
             if(net_status=ns_server)then
             begin
                net_dispose;
                GameDefaultAll;
                g_started:=false;
                net_status:=ns_single;
             end
             else
             begin
                net_sv_sport;
                if(net_UpSocket(net_port))then
                begin
                   menu_s1:=ms1_sett;
                   PlayersSetDefault;
                   net_status:=ns_server;
                end
                else net_dispose;
             end;
      87 : if(net_status<>ns_single)then menu_item:=0; // port

      // client
      91 : if(net_status<>ns_server)and(G_Started=false)then
           if(net_status=ns_client)then
           begin
              if(net_svsearch)then
              begin
                 net_svsearch:=false;
                 net_dispose;
                 net_status :=ns_single;
                 net_m_error:='';
              end;
           end
           else
             if(net_UpSocket(net_svlsearch_port))then
             begin
                net_m_error :=str_netsearching;
                net_status  :=ns_client;
                net_svsearch:=true;
                menu_s1     :=ms1_sett;
                SetLength(net_svsearch_list,0);
                net_svsearch_listn :=0;
                net_svsearch_scroll:=0;
                net_svsearch_sel   :=0;
             end
             else net_dispose;

      101: if(net_status<>ns_server)and(not net_svsearch)then
           if(net_status=ns_client)or(G_Started=false)then
           begin
              if(net_status=ns_client)then
              begin
                 net_disconnect;
                 net_dispose;
                 GameDefaultAll;
                 G_started  :=false;
                 PlayerReady:=false;
                 net_status :=ns_single;
              end
              else
                if(net_UpSocket(0))then
                begin
                   net_m_error:=str_connecting;
                   net_status :=ns_client;
                   net_cl_saddr;
                   rpls_pnu:=0;
                   menu_s1 :=ms1_sett;
                end
                else net_dispose;
           end;
      102: if(net_status=ns_client)and(not G_Started)and(net_svsearch)and(net_svsearch_listn>0)then
             net_svsearch_sel:=net_svsearch_scroll+((mouse_y-ui_menu_pls_zy0)div ui_menu_pls_ys3);
      103: if(net_status=ns_client)and(not G_Started)and(net_svsearch)and(net_svsearch_listn>0)then
           if(0<=net_svsearch_sel)and(net_svsearch_sel<net_svsearch_listn)then
           begin
              net_svsearch:=false;
              net_dispose;
              net_status :=ns_single;
              net_m_error:='';
              if(net_UpSocket(0))then
              begin
                 with net_svsearch_list[net_svsearch_sel] do net_cl_svstr:=c2ip(ip)+':'+w2s(swap(port));
                 net_cl_saddr;
                 net_m_error:=str_connecting;
                 net_status :=ns_client;
                 net_cl_saddr;
                 rpls_pnu:=0;
                 menu_s1 :=ms1_sett;
              end
              else net_dispose;
           end;
      92 : if(net_status<>ns_single)then menu_item:=0; // addr
      93 : if(net_status<>ns_server)then ScrollByte(@net_pnui,true,0,_cl_pnun);
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
      97 : ScrollByte(@cmp_skill,true,0,6);
      98 : begin
              _cmp_sel:=_cmp_sm+((mouse_y-ui_menu_csm_y0) div ui_menu_csm_ys)-2;
              if(_cmp_sel>=MaxMissions)then _cmp_sel:=MaxMissions-1;
           end; }
      else UpdateItems:=false;
      end;

      if(UpdateItems)then menu_update:=true;
   end;

   {if(ks_mright=1)then    // right button pressed
   begin
      case menu_item of
      // MAP
      51 : begin Map_randomseed;                                  Map_premap;end;
      52 : begin ScrollInt (@map_mw      ,-StepSMap,MinSMapW,MaxSMapW   );Map_premap;end;
      53 : begin ScrollByte(@map_type    ,false    ,0       ,gms_m_types);Map_premap;end;
      54 : begin ScrollByte(@map_symmetry,false    ,0       ,2          );Map_premap;end;

      60 : if(not net_svsearch)then
           begin
              p:=((mouse_y-ui_menu_pls_zy0) div ui_menu_pls_ys)+1;
              if(net_status=ns_client)
              then net_swapp(p)
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

      97 : ScrollByte(@cmp_skill,false,0,CMPMaxSkills);
      end;
   end;}
end;

procedure menu_keyborad;
var UpdateItems:boolean;
begin
   UpdateItems:=true;
   if(length(k_keyboard_string)>0)then
   begin
      case menu_item of
mi_map_params2        : begin
                           map_seed   :=s2c(StringApplyInput(c2s(map_seed),k_kbdig,10));
                           map_premap;
                        end;
mi_settings_PlayerName: PlayerName    :=StringApplyInput(PlayerName    ,k_kbstr,NameLen);
mi_saveload_fname     : svld_str_fname:=StringApplyInput(svld_str_fname,k_kbstr,SvRpLen);
mi_game_RecordName    : rpls_str_name :=StringApplyInput(rpls_str_name ,k_kbstr,SvRpLen);
      {
      87 : begin
              net_sv_pstr:=StringApplyInput(net_sv_pstr,k_kbdig,5);
              net_sv_sport;
           end;
      92 : net_cl_svstr:=StringApplyInput(net_cl_svstr,k_kbaddr,21);
      100: net_chat_str:=StringApplyInput(net_chat_str,k_kbstr ,255); }
      else
         UpdateItems:=false;
      end;

      if(UpdateItems)then menu_update:=true;
   end;
end;



