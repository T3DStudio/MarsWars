
procedure unit_DrawMinimap(pu:PTUnit);
begin
   with pu^  do
   with uid^ do
   begin
      draw_set_target(tex_ui_MiniMap0);

      draw_set_color(PlayerColorNormal[player^.pnum]);
      if(_ukbuilding)and(_mmr>0)
      then draw_frect(mmx-_mmr,mmy-_mmr,mmx+_mmr,mmy+_mmr)
      else draw_pixel(mmx,mmy                            );

      with player^ do
      begin
         if(ui_player<=LastPlayer)then
           if(team<>g_players[ui_player].team)then
           begin
              draw_set_target(nil);
              exit;
           end;

         if(_ability=ua_UScan)and(reload>radar_vision_time)and(ui_minimap_scan_blink)then
         begin
            draw_set_color(PlayerColorShadow[pnum]);
            draw_fcircle(trunc(ua_x  *map_mm_cx),
                         trunc(ua_y  *map_mm_cx),
                         trunc(srange*map_mm_cx));
         end;
      end;
      draw_set_target(nil);
   end;
end;

procedure fog_RevealScreenCircle(x,y,r:integer);
var ix,iy:integer;
procedure SetFog(tx,ty:integer);
begin if(0<=tx)and(0<=ty)and(tx<=ui_FogView_cw)and(ty<=ui_FogView_ch)then ui_FogView_grid[tx,ty]:=true;end;
begin
   if(r<0    )then r:=0;
   if(r>MFogM)then r:=MFogM;
   for ix:=0 to r do
    for iy:=0 to _RX2Y[r,ix] do
    begin
       SetFog(x-ix,y-iy);
       SetFog(x-ix,y+iy);
       if(ix>0)then
       begin
          SetFog(x+ix,y-iy);
          SetFog(x+ix,y+iy);
       end;
    end;
end;

function fog_IfInScreen(x,y,r:integer):boolean;
begin
   fog_IfInScreen:=((ui_FogView_sx-r)<=x)and(x<=(ui_FogView_ex+r))
                and((ui_FogView_sy-r)<=y)and(y<=(ui_FogView_ey+r));
end;

procedure unit_UpdateFogXY(pu:PTUnit);
begin
   with pu^ do
   begin
      fx :=x div fog_CellW;
      fy :=y div fog_CellW;
   end;
end;

function unit_FogReveal(pu:PTUnit):boolean;
begin
   unit_FogReveal:=false;
   if(not ui_fog)
   then unit_FogReveal:=true
   else
     with pu^     do
     with uid^    do
     with player^ do
       if(ui_CheckUnitFullFogVision(pu))then
       begin
          if(fog_IfInScreen(fx,fy,fsr))then fog_RevealScreenCircle(fx-ui_FogView_sx,fy-ui_FogView_sy,fsr);
          if(_ability=ua_UScan)and(reload>radar_vision_time)then fog_RevealScreenCircle((ua_x div fog_CellW)-ui_FogView_sx,
                                                                                        (ua_y div fog_CellW)-ui_FogView_sy,fsr);
          unit_FogReveal:=true
       end
       else
         if(ui_player>LastPlayer)
         then unit_FogReveal:=true
         else
           if(TeamVision[g_players[ui_player].team]>0)then unit_FogReveal:=true;
end;


procedure ui_ProductionCounters(pu:PTUnit;prod_line:integer);
var i   :byte;
pcurrent:boolean;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(_isbarrack)then
      begin
         pcurrent:=(s_barracks<=0)or(isselected);
         if(pcurrent)then
         begin
            ui_uprod_all_max+=1;
            for i:=1 to 255 do
              if(i in ups_units)then ui_uprod_uid_max[i]+=1; // possible productions count of each unit type

            if(uprod_r[prod_line]>0)then
            begin
               ui_uprod_all_now+=1;
               i:=uprod_u[prod_line];
               ui_uprod_uid_now[i]+=1;
               if(ui_uprod_first_time <=0)or(uprod_r[prod_line]<ui_uprod_first_time )then ui_uprod_first_time :=uprod_r[prod_line];
               if(ui_uprod_uid_time[i]<=0)or(uprod_r[prod_line]<ui_uprod_uid_time[i])then ui_uprod_uid_time[i]:=uprod_r[prod_line];
            end;
         end;
      end;

      if(_issmith)then
      begin
         pcurrent:=(s_smiths<=0)or(isselected);
         if(pcurrent)then
         begin
            ui_pprod_all_max+=1;
            for i:=1 to 255 do
              if(i in ups_upgrades)then
                if(g_upids[i]._up_multi)then
                  ui_pprod_pid_max[i]+=1;

            if(pprod_r[prod_line]>0)then
            begin
               ui_pprod_all_now+=1;
               i:=pprod_u[prod_line];
               if(ui_pprod_first_time <=0)or(pprod_r[prod_line]<ui_pprod_first_time )then ui_pprod_first_time :=pprod_r[prod_line];
               if(ui_pprod_pid_time[i]<=0)or(pprod_r[prod_line]<ui_pprod_pid_time[i])then ui_pprod_pid_time[i]:=pprod_r[prod_line];
            end;
         end;
      end;
   end;
end;

procedure ui_IncGroupCounter(ugroup:pTUnitGroup;x,y:integer;uidi:byte);
var d:integer;
begin
   with ugroup^ do
   begin
      if(ugroup_n=0)then
      begin
         ugroup_x:=x;
         ugroup_y:=y;
         ugroup_d:=point_dist_int(x,y,vid_cam_x+vid_cam_hw,vid_cam_y+vid_cam_hh);
      end
      else
      begin
         d:=point_dist_int(x,y,vid_cam_x+vid_cam_hw,vid_cam_y+vid_cam_hh);
         if(d<ugroup_d)then
         begin
            ugroup_x:=x;
            ugroup_y:=y;
            ugroup_d:=d;
         end;
      end;
      ugroup_n+=1;
      with g_uids[uidi] do
        ugroup_uids[_ukbuilding]+=[uidi];
   end;
end;

procedure ui_counters(pu:PTUnit);
var i:byte;
    t:integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(group<=MaxUnitGroups)then ui_IncGroupCounter(@ui_groups_d[group],x,y,uidi);
      if(UnitF2Select(pu)    )then ui_IncGroupCounter(@ui_groups_f2      ,x,y,uidi); // all battle units
      if(UnitF1Select(pu)    )then ui_IncGroupCounter(@ui_groups_f1      ,x,y,uidi); // all builders

      if(_ukbuilding)then
      begin
         if(iscomplete)then
         begin
            if(n_builders>0)and(isbuildarea)then
              if(s_builders<=0)or(isselected)then
              begin
                 ui_bprod_possible+=ups_builder;
                 if(0<m_brush)and(m_brush<=255)then
                   if(m_brush in ups_builder)then
                     if(RectInCam(x,y,srange,srange,0))then UIInfoItemAddCircle(x,y,srange,ui_color_blink1[ui_blink2_colorb]);
              end;

            if(_issmith)then
              for i:=1 to 255 do
                if(i in ups_upgrades)then
                  if(not g_upids[i]._up_multi)then
                    ui_pprod_pid_max[i]:=1;

            if(_isbarrack)or(_issmith)then
              for i:=0 to MaxUnitLevel do
                if(i>level)
                then break
                else ui_ProductionCounters(pu,i);
         end;
         if(isselected)and(UnitHaveRPoint(pu^.uidi))then SpriteListAddMarker(ua_x,ua_y,spr_mp[_urace]);
      end;

      if(iscomplete)then
      begin
         if(reload<ui_uid_reload[uidi])or(ui_uid_reload[uidi]<0)then ui_uid_reload[uidi]:=reload;
         if(_ukbuilding)then
           if(reload<ui_bucl_reload[_ucl])or(ui_bucl_reload[_ucl]<0)then ui_bucl_reload[_ucl]:=reload;

         if(isselected)then
         begin
            if(speed>0)then ui_uibtn_move+=1;
            {if(ua_id<>ua_ability1)
            and(ua_id<>ua_ability2)
            and(ua_id<>ua_ability3)
            and(unit_canAbility(pu)=0)then ui_uibtn_abilityu :=pu; }
         end;
      end
      else
      begin
         t:=min2i(_btime,((_mhits-hits+_bstep) div _bstep) div 2);
         if(t>0)then
         begin
            if(ui_bprod_first_ucl[_ucl]<=0)
            or(ui_bprod_first_ucl[_ucl]> t)then ui_bprod_first_ucl[_ucl]:=t;
            if(ui_bprod_first_time<=0)
            or(ui_bprod_first_time> t)then ui_bprod_first_time:=t;
         end;
         ui_bprod_ucl_now[_ucl]+=1;
         ui_bprod_all          +=1;
      end;
   end;
end;

procedure unit_FootEffects(pu:PTUnit);
begin
   with pu^ do
    with uid^ do
     if(un_foot_anim>0)then
     begin
        animf-=1;
        if(animf<=0)then
        begin
           SoundPlayUnit(un_eid_snd_foot,nil,nil);
           animf:=un_foot_anim;
        end;
     end;
end;

function EID2Spr(eid:byte):PTMWTexture;
begin
   EID2Spr:=ptex_dummy;

   with g_eids[eid] do
    if(eid_smodel<>nil)then
     if(eid_smodel^.sm_listn>0)then
      EID2Spr:=eid_smodel^.sm_list[0];
end;

procedure unit_UpdateStatusStrings(pu:PTUnit);
var i,
alevel,
wlevel,
slevel:integer;
 apset,
 wpset,
 spset:TSoB;
procedure UpgrInc(upgr:byte;plevel_var:pinteger;pupgrades_var:PTSoB);
begin
   if not(upgr in pupgrades_var^)then
   begin
      plevel_var^+=pu^.player^.upgr[upgr];
      pupgrades_var^+=[upgr];
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      // buffs and level
      statstr_Buffs:='';
      if(buff[ub_Detect]>0)then statstr_Buffs+=char_detect;

      statstr_Level:='';
      case level of
      1: statstr_Level:='>';
      2: statstr_Level:='||';
      3: statstr_Level:='* * *';
      end;

      // reload
      if(reload>0)
      then statstr_Reload:=tc_aqua+i2s(it2s(reload))
      else statstr_Reload:='';

      alevel:=0;
      slevel:=0;
      wlevel:=0;
      apset :=[];
      spset :=[];
      wpset :=[];

      // weapon
      for i:=0 to MaxUnitWeapons do
        with _a_weap[i] do
          if(aw_reload>0)then
          begin
             if(aw_dupgr>0)then UpgrInc(aw_dupgr,@wlevel,@wpset);
             if(aw_rupgr>0)and(upgr[aw_rupgr]>=aw_rupgr_l)then UpgrInc(aw_dupgr,@slevel,@spset);
          end;
      statstr_WeaponUpgr:=i2s6(wlevel,_attack);
      if(length(statstr_WeaponUpgr)>0)then statstr_WeaponUpgr:=tc_red+statstr_WeaponUpgr;

      // armor
      UpgrInc(_upgr_armor,@alevel,@apset);
      if(_ukbuilding)
      then UpgrInc(upgr_race_armor_build[_urace],@alevel,@apset)
      else
        if(_ukmech)
        then UpgrInc(upgr_race_armor_mech[_urace],@alevel,@apset)
        else UpgrInc(upgr_race_armor_bio [_urace],@alevel,@apset);
      statstr_ArmorUpgr:=tc_lime+i2s6(alevel,true);

      // other
      UpgrInc(_upgr_regen ,@slevel,@spset);
      UpgrInc(_upgr_srange,@slevel,@spset);
      if(_ukbuilding)
      then UpgrInc(upgr_race_regen_build[_urace],@slevel,@spset)
      else
      begin
         UpgrInc(upgr_race_unit_srange[_urace],@slevel,@spset);
         if(_ukmech)then
         begin
            UpgrInc(upgr_race_regen_mech [_urace],@slevel,@spset);
            UpgrInc(upgr_race_mspeed_mech[_urace],@slevel,@spset);
         end
         else
         begin
            UpgrInc(upgr_race_regen_bio [_urace],@slevel,@spset);
            UpgrInc(upgr_race_mspeed_bio[_urace],@slevel,@spset);
            if(_urace=r_hell)then UpgrInc(upgr_hell_pains,@slevel,@spset);
         end;
      end;
      statstr_OtherUpgr:=tc_yellow+i2s6(slevel,true);
   end;
end;

function r_AlphaGlows(amplitudo:byte;shift:cardinal):byte;
var amplitudoH,t:cardinal;
begin
   r_AlphaGlows:=0;
   if(amplitudo=0)then exit;
   amplitudoH:=amplitudo div 2;
   t:=(g_step+shift) mod amplitudo;
   if(t>amplitudoH)
   then r_AlphaGlows:=amplitudo-t
   else r_AlphaGlows:=t;
end;

procedure unit_SpriteAlive(pu:PTUnit;noanim:boolean);
const ProdIcoX: array[0..MaxUnitLevel] of integer = (0,ui_pButtonWh,ui_pButtonW1,ui_pButtonW1+ui_pButtonWh);
var
spr        : PTMWTexture;
depth,
alphab,
alpha,t    : integer;
ColorShadow,
ColorAura  : cardinal;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(playeri=ui_player)then ui_counters(pu);

      if(unit_FogReveal(pu))then
      begin
         if(mmap_TickOrder=ui_PanelUpdTimer)
         then unit_DrawMinimap(pu);

         if(_ability=ua_HKeepBlink)then
           if(buff[ub_CCast]>0)then exit;

         anim_isMoving:=false;
         if(G_Status=gs_running)then
           if(unit_canMove(pu))then
             anim_isMoving:=(x<>moveDest_x)or(y<>moveDest_y)or(x<>vx)or(y<>vy);

         spr:=sm_unit2MWTexture(pu);

         if(spr=ptex_dummy)then exit;

         depth:=_unit_CalcShadowZ(pu)-shadow;
         t:=sign(depth);
         if(depth<-1)then t*=2;
         shadow+=t;

         if(RectInCam(vx,vy,spr^.hw,spr^.hh,shadow))then
         begin
            if((unum mod ui_blink_period2)=ui_blink_timer2)
            then unit_UpdateStatusStrings(pu);

            depth:=unit_SpriteDepth(pu);
            alpha:=255;
            ColorAura :=0;

            if(anim_isMoving)then unit_FootEffects(pu);

            UIInfoItemsAddUnit(pu,un_smodel[level]);

            if(buff[ub_Invis ]>0 )then alpha:=128;

            {if(buff[ub_Invuln]>fr_fpsd6)
            then ColorAura:=c_awhite;
                                        }
            {if(un_eid_summon_spr[level]<>nil)then
             if(buff[ub_Summoned]>0)then
              SpriteListAddUnit(vx,vy,depth+1,0,0,ColorAura,un_eid_summon_spr[level],mm3i(0,buff[ub_Summoned]*4,255)); }

            {if(buff[ub_ArchFire]>0)then
             with spr_h_p6 do
              if(sm_listn>0)then SpriteListAddUnit(vx,vy,depth+1,0,0,0,@sm_list[(G_Step div 4) mod cardinal(sm_listn)],255);}

            if(_ukbuilding)then
             if(iscomplete)then
             begin
                if(a_reload<=0)and(noanim=false)then
                 if(uidi in [UID_UGTurret,UID_UATurret])then
                 begin
                    dir+=_animw;
                    dir:=dir mod 360;
                 end;

                if(playeri=ui_player)then
                begin
                   for t:=0 to MaxUnitLevel do
                   begin
                    //  if(_isbarrack)and(uprod_r[t]>0)then UIInfoItemAddUSprite(vx-ProdIcoX[level]+ui_pButtonW1*t,vy,c_lime  ,@g_uids [uprod_u[t]]. uid_ui_button,i2s(it2s(uprod_r[t])),'','','','');
                   //   if(_issmith  )and(pprod_r[t]>0)then UIInfoItemAddUSprite(vx-ProdIcoX[level]+ui_pButtonW1*t,vy,c_yellow,@g_upids[pprod_u[t]]._up_btn,i2s(it2s(pprod_r[t])),'','','','');
                   end;
                end;

                {case uidi of
UID_UGTurret      : if(upgr[upgr_uac_turarm]>0)then
                     if(level=0)
                     then SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b4_a,alpha)
                     else SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b7_a,alpha);
UID_UATurret      : if(upgr[upgr_uac_turarm]>0)then SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b9_a,alpha);
UID_UCommandCenter: if(upgr[upgr_uac_ccturr]>0)then SpriteListAddUnit(vx+3,vy-65,depth,0,0,0,@spr_ptur,alpha);
                end;}
             end
             else
              if(un_eid_bcrater>0)and(un_build_amode>0)then
              begin
                 if(un_build_amode>1)then
                 begin
                    alpha:=r_AlphaGlows(255,cardinal(unum));
                    alphab:=255-alpha;
                 end
                 else alphab:=255;

                 if(buff[ub_Invis]>0)then alphab:=alphab shr 1;

                 SpriteListAddEffect(vx,vy+un_eid_bcrater_y,sd_liquid+un_eid_bcrater_y+y,0,EID2Spr(un_eid_bcrater),alphab);
              end
              else
                if(buff[ub_Invis]>0)then alpha:=alpha shr 1;

            if(ui_ColoredShadow)
            then ColorShadow:=PlayerColorShadow[playeri]
            else ColorShadow:=c_black;

            SpriteListAddUnit(vx,vy,depth,shadow,ColorShadow,ColorAura,spr,alpha);
         end;
      end;
   end;
end;

procedure unit_SpriteDead(pu:PTUnit);
var spr:PTMWTexture;
begin
   with pu^ do
   with uid^ do
   with player^ do
    if(hits>fdead_hits)then
    begin
       spr:=sm_unit2MWTexture(pu);

       if(spr=ptex_dummy)then exit;

       if(unit_FogReveal(pu))then
         if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then
           SpriteListAddDoodad(vx,vy,unit_SpriteDepth(pu),-32000,spr,mm3i(0,abs(hits-fdead_hits)*4,255),false);
    end;
end;

procedure d_SpriteListAddUnits(noanim:boolean);
var u:integer;
pu,tu:PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=g_punits[u];
      with pu^ do
       if(IsIntUnitRange(transport,@tu))then
       begin
          if(tu^.isselected)and(G_Status=gs_running)and(playeri=ui_player)then ui_units_InTransport[uidi]+=1;
       end
       else
         if(hits<=0)
         then unit_SpriteDead(pu)
         else unit_SpriteAlive(pu,noanim);
   end;
end;



