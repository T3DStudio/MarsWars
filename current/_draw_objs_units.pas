
procedure unit_DrawMinimap(pu:PTUnit);
begin
   with pu^  do
   with uid^ do
   begin
      with player^ do
        if(team=g_players[UIPlayer].team)then
          if(_ability=uab_UACScan)and(reload>radar_vision_time)then
            if(r_minimap_scan_blink)
            then filledCircleColor(r_gminimap,trunc(ua_x  *map_mm_cx),
                                              trunc(ua_y  *map_mm_cx),
                                              trunc(srange*map_mm_cx),ShadowColor(PlayerColorScheme[pnum]));

      if(uid^._ukbuilding)and(mmr>0)
      then boxColor  (r_gminimap,mmx-mmr,mmy-mmr,mmx+mmr,mmy+mmr,PlayerColorScheme[player^.pnum])
      else pixelColor(r_gminimap,mmx,mmy,                        PlayerColorScheme[player^.pnum]);
   end;
end;

procedure fog_RevealScreenCircle(x,y,r:integer);
var ix,iy:integer;
procedure SetFog(tx,ty:integer);
begin if(0<=tx)and(0<=ty)and(tx<=vid_fog_vfw)and(ty<=vid_fog_vfh)then vid_fog_grid[tx,ty]:=true;end;
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
   fog_IfInScreen:=((vid_fog_sx-r)<=x)and(x<=(vid_fog_ex+r))
                and((vid_fog_sy-r)<=y)and(y<=(vid_fog_ey+r));
end;

procedure unit_UpdateFogXY(pu:PTUnit);
begin
   with pu^ do
   begin
      fx :=x div fog_CellW;
      fy :=y div fog_CellW;
   end;
end;

function UnitCheckVisionType(pu:PTUnit):byte;
begin
   UnitCheckVisionType:=0;
   if(ui_CheckUnitUIPlayerVision(pu,false))
   then UnitCheckVisionType:=2
   else
     with pu^ do
      if(CheckUnitTeamVision(g_players[UIPlayer].team,pu,false))then
       if(player^.team=g_players[UIPlayer].team)
       then UnitCheckVisionType:=2
       else UnitCheckVisionType:=1;
end;

function unit_FogReveal(pu:PTUnit):boolean;
begin
   unit_FogReveal:=false;
   if(not sys_fog)
   then unit_FogReveal:=true
   else
     with pu^     do
     with uid^    do
     with player^ do
       if(ui_CheckUnitFullFogVision(pu))then
       begin
          if(fog_IfInScreen(fx,fy,fsr))then fog_RevealScreenCircle(fx-vid_fog_sx,fy-vid_fog_sy,fsr);
          if(_ability=uab_UACScan)and(reload>radar_vision_time)then fog_RevealScreenCircle((ua_x div fog_CellW)-vid_fog_sx,
                                                                                           (ua_y div fog_CellW)-vid_fog_sy,fsr);
          unit_FogReveal:=true
       end
       else
         if(TeamVision[g_players[UIPlayer].team]>0)then unit_FogReveal:=true;

       {case UnitCheckVisionType(pu) of
     1:begin
          //if(fog_IfInScreen(fx,fy,_fr))then fog_RevealScreenCircle(fx-vid_fog_sx,fy-vid_fog_sy,_fr);
          unit_FogReveal:=true;
       end;
     2:begin
          if(fog_IfInScreen(fx,fy,fsr))then fog_RevealScreenCircle(fx-vid_fog_sx,fy-vid_fog_sy,fsr);
          unit_FogReveal:=true;

       end;
       end;}
end;


procedure ui_ProductionCounters(pu:PTUnit;pn:integer);
var i,t:byte;
    pcurrent:boolean;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(_isbarrack)then
      begin
         pcurrent:=(s_barracks<=0)or(isselected);
         if(pcurrent)then ui_uprod_max+=1;

         if(uprod_r[pn]>0)then
         begin
            if(pcurrent)then ui_uprod_cur+=1;
            i:=uprod_u[pn];
            if(ui_uprod_first      <=0)or(uprod_r[pn]<ui_uprod_first      )then ui_uprod_first      :=uprod_r[pn];
            if(ui_uprod_uid_time[i]<=0)or(uprod_r[pn]<ui_uprod_uid_time[i])then ui_uprod_uid_time[i]:=uprod_r[pn];
         end
         else
           for t:=1 to 255 do
            if(pcurrent)then
             if(t in ups_units)then ui_uprod_uid_max[t]+=1; // possible productions count of each unit type
      end;

      if(_issmith)then
      begin
         for t:=1 to 255 do
          if(s_smiths<=0)or(isselected)then
           if(t in ups_upgrades)then ui_pprod_max[t]+=1;    // possible productions count of each upgrade type

         if(pprod_r[pn]>0)then
         begin
            i:=pprod_u[pn];
            if(ui_pprod_first  <=0)or(pprod_r[pn]<  ui_pprod_first)then ui_pprod_first  :=pprod_r[pn];
            if(ui_pprod_time[i]<=0)or(pprod_r[pn]<ui_pprod_time[i])then ui_pprod_time[i]:=pprod_r[pn];
         end;
      end;
   end;
end;

procedure ui_IncGroupCounter(x,y:integer;i,uidi:byte);
var d:integer;
begin
   if(i>MaxUnitGroups)then exit;
   if(ui_groups_n[i]=0)then
   begin
      ui_groups_x[i]:=x;
      ui_groups_y[i]:=y;
      ui_groups_d[i]:=point_dist_int(x,y,vid_cam_x+vid_cam_hw,vid_cam_y+vid_cam_hh);
   end
   else
   begin
      d:=point_dist_int(x,y,vid_cam_x+vid_cam_hw,vid_cam_y+vid_cam_hh);
      if(d<ui_groups_d[i])then
      begin
         ui_groups_x[i]:=x;
         ui_groups_y[i]:=y;
         ui_groups_d[i]:=d;
      end;
   end;
   ui_groups_n[i]+=1;
   with g_uids[uidi] do
     ui_groups_uids[i,_ukbuilding]+=[uidi];
end;

procedure ui_counters(pu:PTUnit);
var i:byte;
    t:integer;
begin
   with pu^ do
   if(playeri=UIPlayer)then
   with uid^ do
   with player^ do
   begin
      if(group<MaxUnitGroups)then ui_IncGroupCounter(x,y,group,uidi);
      if(UnitF2Select(pu))then ui_IncGroupCounter(x,y,MaxUnitGroups,uidi); // all battle units

      if(_ukbuilding)then
      begin
         if(iscomplete)then
         begin
            if(n_builders>0)and(isbuildarea)then
            begin
               ui_bprod_possible+=ups_builder;
               if(0<m_brush)and(m_brush<=255)then
                if(m_brush in ups_builder)then
                 if(RectInCam(x,y,srange,srange,0))then UnitsInfoAddCircle(x,y,srange,ui_blink_color1[r_blink2_colorb]);
            end;

            for i:=0 to MaxUnitLevel do
             if(i>level)
             then break
             else ui_ProductionCounters(pu,i);
         end;
         if(isselected)and(UnitHaveRPoint(pu^.uidi))then SpriteListAddMarker(ua_x,ua_y,@spr_mp[_urace]);
      end;

      if(iscomplete)then
      begin
         if(reload<ui_uid_reload [uidi])or(ui_uid_reload [uidi]<0)then ui_uid_reload [uidi]:=reload;
         if(_ukbuilding)then
           if(reload<ui_bucl_reload[_ucl])or(ui_bucl_reload[_ucl]<0)then ui_bucl_reload[_ucl]:=reload;

         if(isselected)then
         begin
            if(speed>0)then ui_uibtn_move+=1;
            if(ua_id<>ua_psability)
            and((unit_canAbility(pu)=0)or(transportM>0))
                                     then ui_uibtn_sability+=1;
            if(unit_canRebuild(pu)=0)then ui_uibtn_rebuild +=1;
         end;
      end
      else
      begin
         t:=min2i(_btime,((_mhits-hits+_bstep) div _bstep) div 2);
         if(t>0)then
         begin
            if(ui_bprod_ucl_time[_ucl]<=0)
            or(ui_bprod_ucl_time[_ucl]> t)then ui_bprod_ucl_time[_ucl]:=t;
            if(ui_bprod_first<=0)
            or(ui_bprod_first> t)then ui_bprod_first:=t;
         end;
         ui_bprod_uid_count[uidi]+=1;
         ui_bprod_ucl_count[_ucl]+=1;
         ui_bprod_all            +=1;
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
   EID2Spr:=@spr_dummy;

   with g_eids[eid] do
    if(smodel<>nil)then
     if(smodel^.sm_listn>0)then
      EID2Spr:=@smodel^.sm_list[0];
end;

procedure unit_UpdateStatusStrings(pu:PTUnit);
var i,
al,wl,sl:integer;
   atset:TSoB;
procedure WeaponUpgrInc(upgr:byte);
begin
   if not(upgr in atset)then
   begin
      wl+=pu^.player^.upgr[upgr];
      atset+=[upgr];
   end;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      // buffs and level
      lvlstr_b:='';
      if(buff[ub_Detect  ]>0)then lvlstr_b+=char_detect;

      lvlstr_l:='';
      if(not _ukbuilding)then
       case level of
       1: lvlstr_l:='>';
       2: lvlstr_l:='||';
       3: lvlstr_l:='* * *';
       end
      else
        if(level>0)then lvlstr_b+=char_advanced;

      // reload
      if(reload>0)
      then lvlstr_r:=tc_aqua+i2s(it2s(reload))
      else lvlstr_r:='';

      // weapon/attack
      sl      :=0;
      wl      :=0;
      atset   :=[];
      for i:=0 to MaxUnitWeapons do
       with _a_weap[i] do
        if(aw_reload>0)then
        begin
           if(aw_dupgr>0)then WeaponUpgrInc(aw_dupgr);
           if(aw_type=wpt_missle)then
            if(aw_oid=MID_SShot )
            or(aw_oid=MID_SSShot)then WeaponUpgrInc(upgr_uac_ssgup);
           if(aw_rupgr>0)and(aw_rupgr_l<=upgr[aw_rupgr])then sl+=1;
        end;
      lvlstr_w:=i2s6(wl,(_attack>atm_none)and(_attack<>atm_bunker));
      if(length(lvlstr_w)>0)then lvlstr_w:=tc_red+lvlstr_w;

      // armor
      al:=upgr[_upgr_armor];
      if(_ukbuilding)
      then al+=upgr[upgr_race_armor_build[_urace]]
      else
        if(_ukmech)
        then al+=upgr[upgr_race_armor_mech[_urace]]
        else al+=upgr[upgr_race_armor_bio [_urace]];
      lvlstr_a:=tc_lime+i2s6(al,true);

      // other
      sl+=integer(upgr[_upgr_regen]+upgr[_upgr_srange]);
      if(_ukbuilding)
      then sl+=integer(upgr[upgr_race_regen_build[_urace]])
      else
      begin
         sl+=upgr[upgr_race_unit_srange[_urace]];
         if(_ukmech)
         then sl+=integer(upgr[upgr_race_regen_mech [_urace]]+upgr[upgr_race_mspeed_mech[_urace]])
         else
         begin
            sl+=integer(upgr[upgr_race_regen_bio[_urace]]+upgr[upgr_race_mspeed_bio [_urace]]);
            if(_urace=r_hell)then sl+=upgr[upgr_hell_pains];
         end;
      end;
      lvlstr_s:=tc_yellow+i2s6(sl,true);
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
const _btnas: array[0..MaxUnitLevel] of integer = (0,vid_hBW,vid_BW,vid_BW+vid_hBW);
var spr : PTMWTexture;
depth,
alphab,
alpha,t : integer;
ColorShadow,
ColorAura    : cardinal;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      ui_counters(pu);

      if(unit_FogReveal(pu))then
      begin
         if(mmap_order=vid_panel_timer)
         then unit_DrawMinimap(pu);

         if(_ability=uab_HKeepBlink)then
          if(buff[ub_CCast]>0)then exit;

         wanim:=false;
         if(G_Status=gs_running)then
          if(unit_canMove(pu))then
           wanim:=(x<>moveCurr_x)or(y<>moveCurr_y)or(x<>vx)or(y<>vy);

         spr:=sm_unit2MWTexture(pu);

         if(spr=pspr_dummy)then exit;

         depth:=_unit_CalcShadowZ(pu)-shadow;
         t:=sign(depth);
         if(depth<-1)then t*=2;
         shadow+=t;

         if(RectInCam(vx,vy,spr^.hw,spr^.hh,shadow))then
         begin
            if((unum mod vid_blink_period2)=vid_blink_timer2)
            then unit_UpdateStatusStrings(pu);

            depth:=unit_SpriteDepth(pu);
            alpha:=255;
            ColorAura :=0;

            if(wanim)then unit_FootEffects(pu);

            UnitsInfoAddUnit(pu,un_smodel[level]);

            if(buff[ub_Invis ]>0 )then alpha:=128;

            if(buff[ub_Invuln]>fr_fpsd6)
            then ColorAura:=c_awhite;

            if(un_eid_summon_spr[level]<>nil)then
             if(buff[ub_Summoned]>0)then
              SpriteListAddUnit(vx,vy,depth+1,0,0,ColorAura,un_eid_summon_spr[level],mm3i(0,buff[ub_Summoned]*4,255));

            if(buff[ub_ArchFire]>0)then
             with spr_h_p6 do
              if(sm_listn>0)then SpriteListAddUnit(vx,vy,depth+1,0,0,0,@sm_list[(G_Step div 4) mod cardinal(sm_listn)],255);

            if(_ukbuilding)then
             if(iscomplete)then
             begin
                if(a_reload<=0)and(noanim=false)then
                 if(uidi in [UID_UGTurret,UID_UATurret])then
                 begin
                    dir+=_animw;
                    dir:=dir mod 360;
                 end;

                if(playeri=UIPlayer)then
                begin
                   for t:=0 to MaxUnitLevel do
                   begin
                      if(_isbarrack)and(uprod_r[t]>0)then UnitsInfoAddUSprite(vx-_btnas[level]+vid_BW*t,vy,c_lime  ,@g_uids [uprod_u[t]]. un_btn,i2s(it2s(uprod_r[t])),'','','','');
                      if(_issmith  )and(pprod_r[t]>0)then UnitsInfoAddUSprite(vx-_btnas[level]+vid_BW*t,vy,c_yellow,@g_upids[pprod_u[t]]._up_btn,i2s(it2s(pprod_r[t])),'','','','');
                   end;
                end;

                case uidi of
UID_UGTurret      : if(upgr[upgr_uac_turarm]>0)then
                     if(level=0)
                     then SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b4_a,alpha)
                     else SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b7_a,alpha);
UID_UATurret      : if(upgr[upgr_uac_turarm]>0)then SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b9_a,alpha);
UID_UACommandCenter,
UID_UCommandCenter: if(upgr[upgr_uac_ccturr]>0)then SpriteListAddUnit(vx+3,vy-65,depth,0,0,0,@spr_ptur,alpha);
                end;
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

            if(vid_ColoredShadow)
            then ColorShadow:=ShadowColor(PlayerColorScheme[playeri])
            else ColorShadow:=c_ablack;

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

       if(spr=pspr_dummy)then exit;

       if(unit_FogReveal(pu))then
        if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then
         SpriteListAddDoodad(vx,vy,unit_SpriteDepth(pu),-32000,spr,mm3i(0,abs(hits-fdead_hits) div 4,255));
    end;
end;

procedure unit_sprites(noanim:boolean);
var u:integer;
pu,tu:PTUnit;
begin
   for u:=0 to 255 do
   begin
      ui_uid_reload [u]:=-1;
      ui_bucl_reload[u]:=-1;
   end;
   FillChar(ui_bprod_uid_count  ,SizeOf(ui_bprod_uid_count  ),0);
   FillChar(ui_bprod_ucl_count  ,SizeOf(ui_bprod_ucl_count  ),0);
   FillChar(ui_bprod_ucl_time   ,SizeOf(ui_bprod_ucl_time   ),0);
   FillChar(ui_uprod_uid_time   ,SizeOf(ui_uprod_uid_time   ),0);
   FillChar(ui_uprod_uid_max    ,SizeOf(ui_uprod_uid_max    ),0);
   FillChar(ui_pprod_max        ,SizeOf(ui_pprod_max        ),0);
   FillChar(ui_groups_uids      ,SizeOf(ui_groups_uids      ),0);
   FillChar(ui_pprod_time       ,SizeOf(ui_pprod_time       ),0);
   FillChar(ui_units_InTransport,SizeOf(ui_units_InTransport),0);
   FillChar(ui_groups_n         ,SizeOf(ui_groups_n         ),0);
   FillChar(ui_groups_d         ,SizeOf(ui_groups_d         ),0);
   FillChar(ui_groups_x         ,SizeOf(ui_groups_x         ),0);
   FillChar(ui_groups_y         ,SizeOf(ui_groups_y         ),0);
   ui_uprod_max      :=0;
   ui_uprod_cur      :=0;
   ui_uprod_first    :=0;
   ui_pprod_first    :=0;
   ui_uibtn_sability :=0;
   ui_uibtn_rebuild  :=0;
   ui_uibtn_move     :=0;
   ui_bprod_possible :=[];
   ui_bprod_first    :=0;
   ui_bprod_all      :=0;

   if(ui_umark_t>0)then
   begin
      ui_umark_t-=1;
      if(ui_umark_t=0)then ui_umark_u:=0;
   end;

   for u:=1 to MaxUnits do
   begin
      pu:=@g_units[u];
      with pu^ do
       if(IsUnitRange(transport,@tu))then
       begin
          if(tu^.isselected)and(G_Status=gs_running)and(playeri=UIPlayer)then ui_units_InTransport[uidi]+=1;
       end
       else
         if(hits<=0)
         then unit_SpriteDead(pu)
         else unit_SpriteAlive(pu,noanim);
   end;
end;



