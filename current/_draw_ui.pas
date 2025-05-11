
////////////////////////////////////////////////////////////////////////////////
//
//   base
//

function it2s(r:integer):integer;
begin
   if(r>0)
   then it2s:=(r+fr_ifps) div fr_fps1
   else it2s:=0;
end;
function ct2s(r:cardinal):cardinal;
begin
   if(r>0)
   then ct2s:=(r+fr_ifps) div fr_fps1
   else ct2s:=0;
end;
function ir2s(r:integer):shortstring;
begin
   if(r<=0)
   then ir2s:=''
   else ir2s:=i2s(it2s(r))
end;
function cr2s(r:cardinal):shortstring;
begin
   if(r<=0)
   then cr2s:=''
   else cr2s:=c2s(ct2s(r))
end;

////////////////////////////////////////////////////////////////////////////////
//
//   Mini Map
//

procedure d_MinimapAlarms;
var i,r:byte;
begin
   for i:=0 to ui_max_alarms do
    with ui_alarms[i] do
     if(al_t>0)then
     begin
        //r:=(al_t*2) mod vid_uialrm_t;
        r:=(g_step+cardinal(i+al_t)) mod ui_alarm_time;

        {case al_v of
aummat_attacked_b,
aummat_created_b,
aummat_upgrade    : RectangleColor(r_gminimap,al_mx-r,al_my-r,al_mx+r,al_my+r, al_c);
aummat_advance,
aummat_attacked_u,
aummat_created_u,
aummat_info       : CircleColor   (r_gminimap,al_mx  ,al_my  ,              r, al_c);
        end;   }

        al_t-=2;
     end;

  { for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCaptureR>0)then
      if(cpenergy>0)
      then map_MinimapSpot(r_gminimap,cpmx,cpmy,cpmr,char_gen,GetCPColor(i))
      else map_MinimapSpot(r_gminimap,cpmx,cpmy,cpmr,char_cp ,GetCPColor(i));  }

   case g_mode of
gm_royale   : ;//circleColor(r_gminimap,ui_hwp,ui_hwp,trunc(g_royal_r*map_mm_cx)+1,ui_color_max[vid_blink2_colorb]);
   end;
end;

procedure d_UpdateMinimap(tar:pSDL_Surface);
var i:byte;
begin
   //rectangleColor(r_gminimap,vid_mmvx,vid_mmvy,vid_mmvx+map_mm_CamW,vid_mmvy+map_mm_CamH, c_white);

   d_MinimapAlarms;

   {$IFDEF DTEST}
   if(test_mode>1)then
    if(UIPlayer<=LastPlayer)then
     with g_players[UIPlayer] do
      for i:=0 to LastPlayer do
       with ai_alarms[i] do
        if(aia_enemy_limit>0)then
         ;//circleColor(r_gminimap,round(aia_x*map_mm_cx),round(aia_y*map_mm_cx),5,c_orange);
   {$ENDIF}

   //draw_surf(tar       ,1,1,r_gminimap);
   //draw_surf(r_gminimap,0,0,r_bminimap); // clear minimap for next cycle

   vid_minimap_scan_blink:=not vid_minimap_scan_blink;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   Other UI
//

procedure d_UIMouseMapBrush(tar:pSDL_Surface;lx,ly:integer);
var spr:PTMWTexture;
      i:integer;
  dunit:TUnit;
 pdunit:PTUnit;
begin
   mbrush_x-=vid_cam_x-lx;
   mbrush_y-=vid_cam_y-ly;

   with g_players[PlayerClient]do
   case m_brush of
 1.. 255: begin
             with g_uids[m_brush] do
             begin
                spr:=sm_uid2MWTexture(m_brush,270,0);
                {SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA,128);
                draw_surf(tar,mbrush_x-spr^.hw,mbrush_y-spr^.hh,spr^.apidata);
                SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA or SDL_RLEACCEL,255);  }

                //circleColor(tar,mbrush_x,mbrush_y,_r,m_brushc);

                //sight range
                FillChar(dunit,SizeOf(dunit),0);
                pdunit:=@dunit;
                with dunit do
                begin
                   uidi      :=m_brush;
                   playeri   :=PlayerClient;
                   player    :=@g_players[playeri];
                   iscomplete:=true;
                   hits      :=_mhits;
                end;
                unit_apllyUID(pdunit);
                unit_Bonuses (pdunit);
                {if(UIUnitDrawRangeConditionals(pdunit))then
                begin
                   circleColor(tar,mbrush_x,mbrush_y,dunit.srange,vid_blink2_color_BG);
                end; }
             end;
             // points areas
             {for i:=1 to MaxCPoints do
              with g_cpoints[i] do
               if(cpCaptureR>0)and(cpNoBuildR>0)then
                circleColor(tar,
                lx+cpx-vid_cam_x,
                ly+cpy-vid_cam_y,
                cpNoBuildR,c_blue); }
         end;
-255..-1: ;
   {for i:=0 to 255 do
    if(uid_s[i]>0)and(IsIntUnitRange(uid_x[i],nil))then
     with g_uids[i] do
      case _ability of
ua_UACStrike     : if(upgr[upgr_uac_rstrike]>0)then circleColor(tar,mouse_x,mouse_y,blizzard_sr,c_gray);
ua_UACScan       : circleColor(tar,mouse_x,mouse_y,g_units[uid_x[i]].srange,c_gray);
ua_RebuildInPoint: begin
                    spr:=sm_uid2MWTexture(_rebuild_uid,270,0);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA,128);
                    draw_surf(tar,mbrush_x-spr^.hw,mbrush_y-spr^.hh,spr^.apidata);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA or SDL_RLEACCEL,255);

                    circleColor(tar,mbrush_x,mbrush_y,g_uids[_rebuild_uid]._r,c_gray);
                    end;
ua_HTowerBlink,
ua_HKeepBlink,
ua_CCFly         : begin
                    spr:=sm_uid2MWTexture(i,270,0);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA,128);
                    draw_surf(tar,mbrush_x-spr^.hw,mbrush_y-spr^.hh,spr^.apidata);
                    SDL_SetAlpha(spr^.apidata,SDL_SRCALPHA or SDL_RLEACCEL,255);

                    circleColor(tar,mbrush_x,mbrush_y,_r,c_gray);
                    end;
        end; }
   end;

   mbrush_x+=vid_cam_x-lx;
   mbrush_y+=vid_cam_y-ly;
end;

procedure ui_DrawGroupsIcons(tar:pSDL_Surface);
const rown = 6;
var  x,y,y0:integer;
     c,i,n :byte;
     b     :boolean;
begin
   y:=ui_texty+vid_oihw;
   //draw_line(tar,ui_oicox-4,y+2,str_uiHint_UGroups,ta_RU,255,c_white);
   y+=vid_oiw;
   if(MaxUnitGroups>1)then
   for i:=1 to MaxUnitGroups-1 do
   with ui_groups_d[i] do
   begin
      n  :=0;
      y0 :=-1;
      x  :=ui_oicox;
      for b:=false to true do
      for c:=0 to 255 do
      if(c in ugroup_uids[b])then
      begin
         if(y0=-1)then y0:=y+4;
         if((n mod rown)=0)then
         begin
            if(n>0)then y+=vid_oisw;
            x:=ui_oicox-vid_oips;
         end;
        // with g_uids[c] do draw_surf(tar,x,y,un_sbtn.apidata);

         x-=vid_oisw;
         n+=1;
      end;
      if(y0=-1)then y0:=y+4;
      if(ugroup_n>0)then
      begin
         //draw_line(tar,ui_oicox,y0   ,b2s(i)       ,ta_RU,255,c_white );
         //draw_line(tar,ui_oicox,y0+10,i2s(ugroup_n),ta_RU,255,c_orange);
      end;
      y+=vid_oihw;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   Panel
//

procedure ui_Btn2XY(x,y,sx,sy:integer;px,py:pinteger;turnBlock:boolean);
begin
   case vid_PannelPos of
vpp_left,
vpp_right  : begin
                px^:=(sx+x)*vid_BW;
                py^:=(sy+y)*vid_BW;
             end;
vpp_top,
vpp_bottom : begin
                if(turnBlock)then
                begin
                   px^:=x*vid_BW+vid_BW*vid_panel_bw*(y div vid_panel_bw);
                   py^:=y*vid_BW-vid_BW*vid_panel_bw*(y div vid_panel_bw);
                end
                else
                begin
                   px^:=y*vid_BW;
                   py^:=x*vid_BW;
                end;
                px^+=sy*vid_BW;
                py^+=sx*vid_BW;
             end;
   end;
end;

procedure ui_BtnSprite(tar:pSDL_Surface;ux,uy:integer;surf:pSDL_Surface;sel,dsbl:boolean);
begin
   ui_Btn2XY(ux,uy,0,1,@ux,@uy,true);
   ux+=1;
   uy+=1;
   //draw_surf(tar,ux,uy,surf);
   if(sel)then
   begin
     // rectangleColor(tar,ux+1,uy+1,ux+vid_BW-3,uy+vid_BW-3,c_lime);
     // rectangleColor(tar,ux+2,uy+2,ux+vid_BW-4,uy+vid_BW-4,c_lime);
   end
   else
     if(dsbl)then ;//boxColor(tar,ux,uy,ux+vid_BW-2,uy+vid_BW-2,c_ablack);
end;

procedure ui_BtnText(tar:pSDL_Surface;ux,uy:integer;
                      lu1 ,lu2 ,ru ,rd ,ld  :shortstring;
                      clu1,clu2,cru,crd,cld :TMWColor;
                      ms                    :shortstring);
function cs(ps:pshortstring):boolean;begin cs:=(length(ps^)>0)and(ps^[1]<>'0'); end;
begin
   ui_Btn2XY(ux,uy,0,1,@ux,@uy,true);
   ux+=1;
   uy+=1;
   {if(cs(@lu1))then draw_line(tar,ux+3       ,uy+4            ,lu1,ta_LU,5,clu1);
   if(cs(@lu2))then draw_line(tar,ux+3       ,uy+6+basefont_w1,lu2,ta_LU,5,clu2);
   if(cs(@ru ))then draw_line(tar,ux+vid_BW-4,uy+4            ,ru ,ta_RU,5,cru );
   if(cs(@rd ))then draw_line(tar,ux+vid_BW-4,uy+vid_BW-1     ,rd ,ta_RD,5,crd );
   if(cs(@ld ))then draw_line(tar,ux+3       ,uy+vid_BW-1     ,ld ,ta_LD,5,cld );     }

   //if(cs(@ms ))then draw_line(tar,ux+vid_hBW,uy+vid_hBW  ,ms ,ta_MU,5,c_red );
end;

procedure d_BTNStr(tar:pSDL_Surface;ux,uy:integer;txt:pshortstring;c:cardinal);
begin
   ui_Btn2XY(ux,uy,0,0,@ux,@uy,false);
   //draw_line(tar,ux+vid_hBW,uy+vid_hhBW,txt^,ta_MU,6,c);
end;

procedure ui_BtnTab(tar,btn   :pSDL_Surface;
                   ucl,
                   i1,i2,i3,i4:integer;
                   c1,c2,c3,c4:cardinal;
                   selected   :boolean);
var bx,by:integer;
begin
   case vid_PannelPos of
vpp_left,
vpp_right  : begin
                bx:=ucl*vid_tBW+1;
                by:=1;
              //  draw_surf(tar,bx,by+5,btn);
                if(selected)then
                begin
                  // rectangleColor(tar,bx+1,by+1,bx+vid_tBW-3,by+vid_BW-3,c_lime);
                  // rectangleColor(tar,bx+2,by+2,bx+vid_tBW-4,by+vid_BW-4,c_lime);
                end;
      {    by+=3;if(i1>0)then draw_line(tar,bx+4,by,i2s(i1),ta_LU,255,c1);by+=basefont_w1+3;
                if(i2>0)then draw_line(tar,bx+4,by,i2s(i2),ta_LU,255,c2);by+=basefont_w1+3;
                if(i3>0)then draw_line(tar,bx+4,by,i2s(i3),ta_LU,255,c3);by+=basefont_w1+3;
                if(i4>0)then draw_line(tar,bx+4,by,i2s(i4),ta_LU,255,c4);    }
             end;

vpp_top,
vpp_bottom : begin
                bx:=1;
                by:=ucl*vid_tBW+1;
              //  draw_surf(tar,bx+5,by,btn);
                if(selected)then
                begin
                  { rectangleColor(tar,bx+1,by+1,bx+vid_BW-3,by+vid_tBW-3,c_lime);
                   rectangleColor(tar,bx+2,by+2,bx+vid_BW-4,by+vid_tBW-4,c_lime);  }
                end;
       {   by+=3;if(i1>0)then draw_line(tar,bx+3,by              ,i2s(i1),ta_LU,255,c1);
                if(i2>0)then draw_line(tar,bx+3,by+basefont_w1+3,i2s(i2),ta_LU,255,c2);

                if(i3>0)then draw_line(tar,bx+vid_BW-4,by              ,i2s(i3),ta_RU,255,c3);
                if(i4>0)then draw_line(tar,bx+vid_BW-4,by+basefont_w1+3,i2s(i4),ta_RU,255,c4);     }
             end;
   end;
end;

procedure d_UpdatePanel(tar:pSDL_Surface;POVPlayer:byte);
var
tab       : TTabType;
ucl,
uid,
ux,uy     : integer;
req       : cardinal;
pPOVPlayer: PTPlayer;
procedure PlayersButtoms;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      //ui_BtnText  (tar,ux,uy,g_players[p].name,'','','','',PlayerColorNormal[p],0,0,0,0,'');
      //ui_BtnSprite(tar,ux,uy,r_empty,p=POVPlayer,not GetBBit(@g_player_astatus,p));

      ux+=1;
      if(ux>2)then
      begin
         ux:=0;
         uy+=1;
      end;
   end;
   //ui_BtnText  (tar,ux,uy,str_panelHint_all,'','','','',c_white,0,0,0,0,'');
   //ui_BtnSprite(tar,ux,uy,r_empty,LastPlayer<POVPlayer,false);
end;
begin
   if(POVPlayer>LastPlayer)
   then pPOVPlayer:=@ui_dPlayer
   else pPOVPlayer:=@g_players[POVPlayer];
   with pPOVPlayer^ do
   begin
      // panel background
     { boxColor(tar,0,0,tar^.w-1,tar^.h-1,c_black);
      case vid_PannelPos of
vpp_left,
vpp_right  : begin
                ux:=vid_tBW;while(ux<vid_panel_pw )do begin vlineColor(tar,ux    ,0          ,vid_BW     ,c_white);ux+=vid_tBW;end;
                ux:=vid_BW ;while(ux<vid_panel_pw )do begin vlineColor(tar,ux    ,vid_BW     ,vid_panel_phi,c_white);ux+=vid_BW; end;
                uy:=0      ;while(uy<vid_panel_phi)do begin hlineColor(tar,0     ,vid_panel_pw ,uy         ,c_white);uy+=vid_BW; end;
                vlineColor(tar,0         ,0,vid_panel_phi,c_white);
                vlineColor(tar,vid_panel_pw,0,vid_panel_phi,c_white);
                hlineColor(tar,0,vid_panel_pw,vid_panel_phi,c_white);
             end;
vpp_top,
vpp_bottom : begin
                uy:=vid_tBW;while(uy<vid_panel_pw )do begin hlineColor(tar,0     ,vid_BW     ,uy         ,c_white);uy+=vid_tBW;end;
                uy:=vid_BW ;while(uy<vid_panel_pw )do begin hlineColor(tar,vid_BW,vid_panel_phi,uy         ,c_white);uy+=vid_BW; end;
                ux:=0      ;while(ux<vid_panel_phi)do begin vlineColor(tar,ux    ,0          ,vid_panel_pw ,c_white);ux+=vid_BW; end;
                hlineColor(tar,0,vid_panel_phi,0         ,c_white);
                hlineColor(tar,0,vid_panel_phi,vid_panel_pw,c_white);
                vlineColor(tar,vid_panel_phi,0,vid_panel_pw,c_white);
             end;
      end;     }

      // tabs
      {for tab in TTabType do
        case tab of
tt_buildings: ui_BtnTab(tar,spr_tabs[ord(tab)],ord(tab), ui_bprod_first      ,ui_bprod_all,ucl_cs[true ],ucl_c[true ],c_white,c_yellow,c_lime,c_orange, tab=ui_tab);
tt_units    : ui_BtnTab(tar,spr_tabs[ord(tab)],ord(tab), it2s(ui_uprod_first),uproda      ,ucl_cs[false],ucl_c[false],c_white,c_yellow,c_lime,c_orange, tab=ui_tab);
tt_upgrades : ui_BtnTab(tar,spr_tabs[ord(tab)],ord(tab), it2s(ui_pprod_first),upproda     ,0            ,0           ,c_white,c_yellow,0     ,0       , tab=ui_tab);
tt_controls : ui_BtnTab(tar,spr_tabs[ord(tab)],ord(tab), 0                   ,0           ,0            ,0           ,0      ,0       ,0     ,0       , tab=ui_tab);
        end;     }

      // bottom line buttons
     { d_BTNStr(tar,0,vid_panel_bh,@str_panelHint_menu,c_white);
      if(net_status>ns_single)then
      d_BTNStr(tar,2,vid_panel_bh,@str_pause,GetPlayerColor(g_status,c_white));

      // main buttons
      case ui_tab of
tt_buildings: if(POVPlayer<=LastPlayer)then
                for ucl:=0 to ui_ubtns do  // buildings
                begin
                   uid:=ui_panel_uids[race ,ord(ui_tab),ucl];
                   if(uid=0)then continue;

                   with g_uids[uid] do
                   begin
                      if(a_units[uid]<=0)and(uid_e[uid]<=0)and(ucl_e[_ukbuilding,_ucl]<=0)then continue;

                      ux:=(ucl mod vid_panel_bw);
                      uy:=(ucl div vid_panel_bw);

                      req:=uid_CheckRequirements(pPOVPlayer,uid);

                      ui_BtnSprite(tar,ux,uy,un_btn.sdlSurface,m_brush=uid,(req>0) or not(uid in ui_bprod_possible));
                      ui_BtnText  (tar,ux,uy,
                      i2s(ui_bprod_ucl_time[_ucl]),i2s(ui_bprod_ucl_count[ucl]),i2s(ucl_s[true,ucl]),i2s(ucl_e[true,ucl])                       ,ir2s(ui_bucl_reload[ucl]),
                      ui_color_cenergy[cenergy<0]       ,c_dyellow                   ,c_lime              ,ui_color_max[ucl_e[true,ucl]>=a_units[uid]],c_aqua                   ,ir2s(build_cd));

                      ui_uid_reload [uid]:=-1;
                      ui_bucl_reload[ucl]:=-1;
                   end;
                end;

tt_units    : if(POVPlayer<=LastPlayer)then
                for ucl:=0 to ui_ubtns do  // units
                begin
                   uid:=ui_panel_uids[race ,ord(ui_tab),ucl];
                   if(uid=0)then continue;

                   with g_uids[uid] do
                   begin
                      if(a_units[uid]<=0)and(uid_e[uid]<=0)and(ucl_e[_ukbuilding,_ucl]<=0)then continue;

                      ux:=(ucl mod vid_panel_bw);
                      uy:=(ucl div vid_panel_bw);

                      req:=uid_CheckRequirements(pPOVPlayer,uid);

                      ui_BtnSprite(tar,ux,uy,un_btn.sdlSurface,false,(req>0) or (uproda>=uprodm) or (ui_uprod_cur>=ui_uprod_max) or(ui_uprod_uid_max[uid]<=0));
                      ui_BtnText  (tar,ux,uy,
                      ir2s(ui_uprod_uid_time[uid]),i2s(uprodu[uid]),i2s(uid_s[uid]),i2s(   uid_e[uid])                    ,i2s(ui_units_InTransport[uid]),
                      ui_color_cenergy[cenergy<0]       ,c_dyellow       ,c_lime         ,ui_color_max[uid_e[uid]>=a_units[uid]],c_purple                      ,'');
                   end;
                end;

tt_upgrades : if(POVPlayer<=LastPlayer)then
                for ucl:=0 to ui_ubtns do  // upgrades
                begin
                   uid:=ui_panel_uids[race ,ord(ui_tab),ucl];

                   if(a_upgrs[uid]<=0)then continue;

                   ux:=(ucl mod vid_panel_bw);
                   uy:=(ucl div vid_panel_bw);

                   ui_BtnSprite(tar,ux,uy,g_upids[uid]._up_btn.apidata,ui_pprod_time[uid]>0,
                   (upid_CheckRequirements(pPOVPlayer,uid)>0)or(upproda>=upprodm) or (upprodu[uid]>=ui_pprod_max[uid]) );
                   ui_BtnText  (tar,ux,uy,
                   ir2s(ui_pprod_time[uid]),i2s(upprodu[uid]),'',b2s(   upgr[uid])                            ,'',
                   ui_color_cenergy[cenergy<0]  ,c_dyellow         ,0 ,ui_color_max[upgr[uid]>=g_upids[uid]._up_max],0 ,'');
                end;

tt_controls : case tab3PageType of   // actions
              t3pt_replay  : begin
                             ui_BtnSprite(tar,0,0,spr_b_rfast,sys_uncappedFPS,false);
                             ui_BtnSprite(tar,1,0,spr_b_rback,false          ,false);
                             ui_BtnSprite(tar,2,0,spr_b_rskip,false          ,false);
                             ui_BtnSprite(tar,0,1,spr_b_rstop,g_status>0     ,false);
                             ui_BtnSprite(tar,1,1,spr_b_rvis ,rpls_POVCam    ,false);
                             ui_BtnSprite(tar,2,1,spr_b_rlog ,rpls_showlog   ,false);
                             ui_BtnSprite(tar,0,2,spr_b_rfog ,sys_fog        ,false);

                             ux:=2;
                             uy:=2;
                             PlayersButtoms;
                             end;
              t3pt_observer: begin
                             ui_BtnSprite(tar,0,0,spr_b_rfog ,sys_fog    ,false);

                             ux:=2;
                             uy:=0;
                             PlayersButtoms;
                             end;
              t3pt_actions : begin
                             // добавить проверку на каждую икноку - имеет ли юнит абилку и может ли ее применять
                             //ui_BtnSprite(tar,0,0,spr_b_action ,false   ,unit_CheckAbility(ui_uibtn_abilityu));
                             //ui_BtnSprite(tar,1,0,spr_b_paction,false   ,ui_uibtn_abilityu=nil);
                             //ui_BtnSprite(tar,2,0,spr_b_rebuild,false   ,ui_uibtn_rebuild <=0 );

                             ui_BtnSprite(tar,0,1,spr_b_attack ,false   ,ui_uibtn_move<=0   );
                             ui_BtnSprite(tar,1,1,spr_b_stop   ,false   ,ui_uibtn_move<=0   );
                             ui_BtnSprite(tar,2,1,spr_b_apatrol,false   ,ui_uibtn_move<=0   );

                             ui_BtnSprite(tar,0,2,spr_b_move   ,false   ,ui_uibtn_move<=0   );
                             ui_BtnSprite(tar,1,2,spr_b_hold   ,false   ,ui_uibtn_move<=0   );
                             ui_BtnSprite(tar,2,2,spr_b_patrol ,false   ,ui_uibtn_move<=0   );

                             ui_BtnSprite(tar,0,3,spr_b_cancel ,false   ,false              );
                             ui_BtnSprite(tar,1,3,spr_tabs[0]  ,false   ,ui_groups_f1.ugroup_n<=0);
                             ui_BtnSprite(tar,2,3,spr_b_selall ,false   ,ui_groups_f2.ugroup_n<=0);

                             ui_BtnSprite(tar,0,4,spr_b_delete ,false   ,(ucl_cs[false]+ucl_cs[true])<=0);
                             ui_BtnSprite(tar,1,4,spr_b_mmark  ,false   ,false              );
                             ui_BtnSprite(tar,2,4,spr_b_rclck  ,m_action,false              );
                             end;
              end;
      end;    }
   end;
end;

procedure d_UIMouseMapClick(tar:pSDL_Surface;lx,ly:integer);
var sx,sy,i,r:integer;
begin
   if(ui_mc_a>0)then //click effect
   begin
      sx:=ui_mc_a;
      sy:=sx shr 1;
     // ellipseColor(tar,ui_mc_x-vid_cam_x,ui_mc_y-vid_cam_y,sx,sy,ui_mc_c);

      ui_mc_a-=1;
   end;

   //
   for i:=0 to ui_max_alarms do
     with ui_alarms[i] do
       if(al_t>0)then
       begin
          case al_v of
aummat_info     : ;
          else continue;
          end;

          sx:=al_x-vid_cam_x+lx;
          sy:=al_y-vid_cam_y+ly;

          r:=(fr_fpsd2-(g_step mod fr_fpsd2))*4;

        //  circleColor(tar,sx,sy,r,c_white);
       end;
end;

procedure d_Hints(tar:pSDL_Surface;POVPlayer:byte);
var uid:byte;
i,bx,by:integer;
     s1:shortstring;
    hs1,
    hs2,
    hs3,
    hs4:pshortstring;
    tu :PTUnit;
begin
   //str_panelHint_a
   {if(0<=m_panelBtn_x)and(m_panelBtn_x<3)and(3<=m_panelBtn_y)and(m_panelBtn_y<=ui_panel_LastB)then
   begin
      hs1:=nil;
      hs2:=nil;
      hs3:=nil;
      hs4:=nil;
      if(m_panelBtn_y=ui_panel_LastB)then // menu/pause line hints
      begin
         if(m_panelBtn_x=2)then
          if(net_status=ns_single)then exit;
         hs1:=@str_panelHint_Common[m_panelBtn_x];
      end
      else
      case m_panelBtn_y of  // tab hints
      3  : case (vid_PannelPos<2) of
           true :if(mouse_y>vid_panel_pw)then hs1:=@str_panelHint_Tab[(mouse_x-vid_panelx) div vid_tBW];
           false:if(mouse_x>vid_panel_pw)then hs1:=@str_panelHint_Tab[(mouse_y-vid_panely) div vid_tBW];
           end;
      else
        if(vid_PannelPos<2)then
        begin
           bx:= m_panelBtn_x;
           by:= m_panelBtn_y-4;
        end
        else
        begin
           bx:=(m_panelBtn_y-4);
           by:= m_panelBtn_x   ;
           by+=3*(bx div 3);
           bx-=3*(bx div 3);
        end;
        i :=(by*vid_panel_bw)+(bx mod vid_panel_bw);

        if(0<=i)and(i<=ui_ubtns)then
        begin
           if(ui_tab=3)then
           begin
              if(i<=HotKeysArraySize)then
                case tab3PageType of
                1: hs1:=@str_panelHint_r[i];
                2: hs1:=@str_panelHint_o[i];
                3: hs1:=@str_panelHint_a[i];
                end;
           end
           else
             if(POVPlayer<=LastPlayer)then
               with g_players[POVPlayer] do
               begin
                  uid:=ui_panel_uids[race,ui_tab,i];
                  if(uid>0)then
                    case ui_tab of
                    0,1: begin
                            with g_uids[uid] do
                              if(uid_e[uid]=0)and(ucl_e[_ukbuilding,_ucl]<=0)and(a_units[uid]<=0)then exit;
                            hs1:=@g_uids[uid].un_txt_uihint1;
                            hs2:=@g_uids[uid].un_txt_uihint2;
                            hs3:=@g_uids[uid].un_txt_uihint3;
                            hs4:=@g_uids[uid].un_txt_uihint4;
                         end;
                    2  : begin
                            if(a_upgrs[uid]<=0)then exit;
                            s1 :=_makeUpgrBaseHint(uid,upgr[uid]+1);
                            hs1:=@s1;
                            hs4:=@g_upids[uid]._up_hint;
                         end;
                    end;
               end;
        end;
      end;
      if(hs1<>nil)then draw_line(tar,ui_textx,ui_hinty1,hs1^,ta_LU,ui_ingamecl,c_white);
      if(hs2<>nil)then draw_line(tar,ui_textx,ui_hinty2,hs2^,ta_LU,ui_ingamecl,c_white);
      if(hs3<>nil)then draw_line(tar,ui_textx,ui_hinty3,hs3^,ta_LU,ui_ingamecl,c_white);
      if(hs4<>nil)then draw_line(tar,ui_textx,ui_hinty4,hs4^,ta_LU,ui_ingamecl,c_white);
   end
   else
     if(IsIntUnitRange(ui_uhint,@tu))then
       with tu^ do
       with uid^ do
       with player^ do
       begin
          draw_line(tar,ui_textx,ui_hinty1,un_txt_uihintS+txt_makeAttributeStr(tu,0),ta_LU,ui_ingamecl,c_white);

          s1:='';
          _ADDSTR(@s1,lvlstr_w,sep_wdash);
          _ADDSTR(@s1,lvlstr_a,sep_wdash);
          _ADDSTR(@s1,lvlstr_s,sep_wdash);
          if(length(s1)>0)then draw_line(tar,ui_textx,ui_hinty2,str_uhint_UnitLevel+s1,ta_LU,ui_ingamecl,c_white);

          draw_line(tar,ui_textx,ui_hinty3,tc_white+'('+tc_default+name+tc_white+')',ta_LU,ui_ingamecl,PlayerColorNormal[pnum]);
     end;}
end;

procedure D_ReplayProgress(tar:pSDL_Surface);
var x,y,
    w:integer;
    cx :single;
begin
   {x:=vid_mapx;
   y:=vid_mapy+vid_cam_h-basefont_w1h;

   cx:=replay_GetProgress;

   w:=round(vid_cam_w*cx);

   boxColor(tar,x,y,x+w,y+basefont_w1h,c_yellow);
   draw_line(tar,x,y,rpls_list[rpls_list_sel]+' '+i2s(round(cx*100))+'%',ta_LU,255,c_white);}
end;

procedure D_UIText(tar:pSDL_Surface;lx,ly:integer;POVPlayer:byte);
var i,
limit:integer;
  str:shortstring;
  col:cardinal;
function ChatString:shortstring;
begin
   case ingame_chat of
chat_all     : ChatString:=str_chat_all;
chat_allies  : ChatString:=str_chat_allies;
0..LastPlayer: ChatString:=g_players[ingame_chat].name+':';
   end;
end;
begin
   // replay progress bar
   //if(rpls_rstate=rpls_state_read)then D_ReplayProgress(tar);

   // LOG and HINTs
   {if(log_LastMesTimer>0)then log_LastMesTimer-=1;
   if(ingame_chat>0)or(rpls_showlog)then
   begin
      if(net_status=ns_client)
      then MakeLogListForDraw(PlayerClient ,ui_ingamecl,ui_GameLogHeight,lmts_menu_chat)
      else MakeLogListForDraw(UIPlayer     ,ui_ingamecl,ui_GameLogHeight,lmts_menu_chat);
      if(ui_log_n>0)then
       for i:=0 to ui_log_n-1 do
        if(ui_log_c[i]>0)then draw_line(tar,ui_textx,ui_logy-basefont_w1h*i,ui_log_s[i],ta_LU,255,ui_log_c[i]);
      if(ingame_chat>0)then draw_line(tar,ui_textx,ui_chaty,ChatString+net_chat_str+chat_type[vid_blink1_colorb],ta_LU,ui_ingamecl,c_white);
   end
   else
     if(log_LastMesTimer>0)then // last messages
     begin
        if(net_status=ns_client)
        then MakeLogListForDraw(PlayerClient ,ui_ingamecl,(log_LastMesTimer div log_LastMesTime)+1,lmts_last_messages)
        else MakeLogListForDraw(UIPlayer     ,ui_ingamecl,(log_LastMesTimer div log_LastMesTime)+1,lmts_last_messages);
        if(ui_log_n>0)then
         for i:=0 to ui_log_n-1 do
          if(ui_log_c[i]>0)then draw_line(tar,ui_textx,ui_logy-basefont_w1h*i,ui_log_s[i],ta_LU,255,ui_log_c[i]);
     end;
   d_Hints(tar,POVPlayer);}

   // resources
   {if(POVPlayer<=LastPlayer)then
     with g_players[POVPlayer] do
     begin
        limit:=armylimit+uprodl;
        draw_line(tar,ui_energx,ui_energy,tc_aqua  +str_uiHint_Energy+tc_default+i2s(cenergy           )+tc_white+' / '+tc_aqua  +i2s(menergy),ta_LU,255,ui_color_cenergy[cenergy<=0]);
        draw_line(tar,ui_armyx ,ui_armyy ,tc_orange+str_uiHint_Army  +tc_default+l2s(limit,MinUnitLimit)+tc_white+' / '+tc_orange+ui_limitstr ,ta_LU,255,ui_color_limit[limit>=MaxPlayerLimit]);

        if(ui_armyx<mouse_x)and(mouse_x<=(ui_armyx+140))and(ui_armyy<=mouse_y)and(mouse_y<=(ui_armyy+basefont_w1))then
        begin
        draw_line(tar,ui_armyx,ui_armyy+draw_font_lhq  ,str_attr_building+tc_default+': '+l2s(ucl_l[true ]       ,MinUnitLimit),ta_LU,255,c_white);
        draw_line(tar,ui_armyx,ui_armyy+draw_font_lhq*2,str_attr_unit    +tc_default+': '+l2s(ucl_l[false]+uprodl,MinUnitLimit),ta_LU,255,c_white);
        end;
     end;

   // GAME STATUS
   if(GameGetStatus(@str,@col,POVPlayer))then draw_line(tar,ui_uiuphx,ui_uiuphy,str,ta_MU,255,col);

   if(POVPlayer<>PlayerClient)or(rpls_rstate>=rpls_state_read)then
     if(POVPlayer<=LastPlayer)
     then draw_line(tar,ui_uiuphx,ui_uiplayery,g_players[POVPlayer].name,ta_MU,255,PlayerColorNormal[POVPlayer])
     else draw_line(tar,ui_uiuphx,ui_uiplayery,str_panelHint_all                  ,ta_MU,255,c_white           );

   // TIMER
   D_Timer(tar,ui_textx,ui_texty,g_step,ta_LU,str_uiHint_Time,c_white);

   // Game mode specific info
   {case g_mode of
gm_koth    : with g_cpoints[1] do
              if(g_step<g_step_koth_pause)
              then D_Timer(tar,ui_textx,ui_texty+basefont_w1h,g_step_koth_pause-g_step,ta_LU,str_uiHint_KotHTimeAct,c_gray)
              else
                if(cpOwnerPlayer<=LastPlayer)
                then draw_line(tar,ui_textx,ui_texty+basefont_w1h,g_players[cpOwnerPlayer].name+str_uiHint_KotHWinner,ta_LU,255,PlayerColorNormal[cpOwnerPlayer])
                else
                  if(cpTimer<=0)
                  then draw_line(tar,ui_textx,ui_texty+basefont_w1h,str_uiHint_KotHTime+'---',ta_LU,255,c_white)
                  else
                    if(vid_blink2_colorb)
                    then D_Timer(tar,ui_textx,ui_texty+basefont_w1h,cpCaptureTime-cpTimer,ta_LU,str_uiHint_KotHTime,c_white)
                    else D_Timer(tar,ui_textx,ui_texty+basefont_w1h,cpCaptureTime-cpTimer,ta_LU,str_uiHint_KotHTime,PlayerColorNormal[cpTimerOwnerPlayer]);
   end;}

   //if(test_mode>0)then draw_line(tar,vid_mapx+vid_cam_hw,vid_mapy+vid_cam_hh,'TEST MODE '+b2s(test_mode),ta_MU,255,c_white);

   //if(vid_APM)then draw_line(tar,ui_apmx,ui_apmy,'APM: '+player_APMdata[POVPlayer].APM_Str                ,ta_LU,255,c_white);
   if(vid_FPS)then draw_line(tar,ui_fpsx,ui_fpsy,'FPS: '+c2s(fr_FPSSecondC)+'('+c2s(fr_FPSSecondU)+')',ta_LU,255,c_white);

   ui_DrawGroupsIcons(tar);   }
end;

procedure d_UIMouseCursor(tar:pSDL_Surface);   //cursor/brash
var c:cardinal;
begin
   c:=0;
  { case m_brush of
-255..-1    : with g_uability[-m_brush] do c:=ua_mbrush_c;
mb_mark     : c:=c_white;
   else
   end;
   if(c<>0)then
   begin
      circleColor(tar,mouse_x   ,mouse_y,10,           c);
      hlineColor (tar,mouse_x-12,mouse_x+12,mouse_y   ,c);
      vlineColor (tar,mouse_x   ,mouse_y-12,mouse_y+12,c);
   end
   else draw_surf(tar,mouse_x,mouse_y,spr_cursor);  }
end;





