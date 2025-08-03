
procedure unit_DrawMiniMap(pu:PTUnit);
begin
   if(ui_blink_timer1=0)and(not MainMenu)and(vid_draw)then
     with pu^  do
     with uid^ do
     begin
        if(uid^._ukbuilding)and(mmr>0)
        then rectangleColor(ui_minimap,mmx-mmr,mmy-mmr,
                                       mmx+mmr,mmy+mmr,PlayerGetColor(player^.pnum,false))
        else pixelColor    (ui_minimap,mmx,mmy,        PlayerGetColor(player^.pnum,false));

        with player^ do
        begin
           if(UIPlayer<=LastPlayer)then
             if(team<>g_players[UIPlayer].team)then exit;

           if(_ability=uab_UACScan)and(rld>radar_vision_time)and(ui_mm_ScanBlink)then
             filledCircleColor(ui_minimap,trunc(uo_x  *map_mmcx),
                                          trunc(uo_y  *map_mmcx),
                                          trunc(srange*map_mmcx),PlayerGetColor(pnum,true));
        end;
     end;
end;


function draw_SpriteDepth(y:integer;f:boolean):integer;
begin
   draw_SpriteDepth:=map_flydepths[f]+y;
end;

function unit_SpriteDepth(pu:PTUnit):integer;
begin
   unit_SpriteDepth:=0;
   with pu^ do
    case uidi of
UID_UPortal,
UID_HTeleport,
UID_HPentagram,
UID_HSymbol1,
UID_HSymbol2,
UID_HSymbol3,
UID_HSymbol4,
UID_HAltar,
UID_UMine     : unit_SpriteDepth:=sd_tcraters+vy;
    else
      if(uid^._ukbuilding)and(iscomplete=false)
      then unit_SpriteDepth:=sd_build+vy
      else
        if(hits>0)or(buffs[ub_Resurect]>0)
        then unit_SpriteDepth:=draw_SpriteDepth(vy,ukfly or (zfall>0))
        else unit_SpriteDepth:=draw_SpriteDepth(vy,ukfly);
    end;
end;


procedure fog_RevealScreenCircle(x,y,r:integer);
var iy,i:integer;
procedure setFOGPoint(tx,ty:integer);
begin if(0<=tx)and(0<=ty)and(tx<ui_fog_gridw)and(ty<ui_fog_gridh)then ui_fog_fgrid[tx,ty]:=true;end;
begin
   if(r<0    )then r:=0;
   if(r>MFogM)then r:=MFogM;
   for i:=0 to r do
     for iy:=0 to _RX2Y[r,i] do
     begin
        setFOGPoint(x-i,y-iy);
        setFOGPoint(x-i,y+iy);
        if(i>0)then
        begin
           setFOGPoint(x+i,y-iy);
           setFOGPoint(x+i,y+iy);
        end;
     end;
end;

function fog_IfInScreen(x,y,r:integer):boolean;
begin
   fog_IfInScreen:=((ui_fog_sx-r)<=x)and(x<=(ui_fog_ex+r))
                and((ui_fog_sy-r)<=y)and(y<=(ui_fog_ey+r));
end;

procedure unit_UpdateFogXY(pu:PTUnit);
begin
   with pu^ do
   begin
      fx :=x div fog_cw;
      fy :=y div fog_cw;
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
       if(ui_CheckUnitFullFogReveal(pu))then
       begin
          if(fog_IfInScreen(fx,fy,fsr))then fog_RevealScreenCircle(fx-ui_fog_sx,fy-ui_fog_sy,fsr);
          if(_ability=uab_UACScan)and(rld>radar_vision_time)then fog_RevealScreenCircle((uo_x div fog_cw)-ui_fog_sx,
                                                                                        (uo_y div fog_cw)-ui_fog_sy,fsr);
          unit_FogReveal:=true
       end
       else
         if(UIplayer>LastPlayer)
         then unit_FogReveal:=true
         else
           if(CheckUnitTeamVision(g_players[UIplayer].team,pu,false))then unit_FogReveal:=true;
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
            if(ui_pprod_first  <=0)or(pprod_r[pn]<ui_pprod_first  )then ui_pprod_first  :=pprod_r[pn];
            if(ui_pprod_time[i]<=0)or(pprod_r[pn]<ui_pprod_time[i])then ui_pprod_time[i]:=pprod_r[pn];
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
         ugroup_d:=point_dist_int(x,y,ui_cam_cx,ui_cam_cy);
      end
      else
      begin
         d:=point_dist_int(x,y,ui_cam_cx,ui_cam_cy);
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
function LowerReload(pu1,pu2:PTUnit):PTUnit;
begin
   if(pu1<>nil)and(pu2=nil)then
   begin
      LowerReload:=pu1;
      exit;
   end;
   if(pu1=nil)and(pu2<>nil)then
   begin
      LowerReload:=pu2;
      exit;
   end;

   if(pu1^.rld>pu2^.rld)
   then LowerReload:=pu2
   else LowerReload:=pu1;
end;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(group<=MaxUnitGroups)then ui_IncGroupCounter(@ui_group_d[group],x,y,uidi);
      if(UnitF2Select(pu)    )then ui_IncGroupCounter(@ui_group_f2      ,x,y,uidi); // all battle units
      if(UnitF1Select(pu)    )then ui_IncGroupCounter(@ui_group_f1      ,x,y,uidi); // all builders

      if(_ukbuilding)then
      begin
         if(iscomplete)then
         begin
            if(_isbuilder)and(not ukfly)then
              if(s_builders=0)or(isselected)then
              begin
                 ui_bprod_possible+=ups_builder;
                 if(0<m_brush)and(m_brush<=255)then
                   if(m_brush in ups_builder)then
                     if(RectInCam(x,y,srange,srange,0))then UnitsInfoAddCircle(x,y,srange,ui_blink_color1[ui_blink2_colorb]);
              end;

            for i:=0 to MaxUnitLevel do
              if(i>level)
              then break
              else ui_ProductionCounters(pu,i);
         end;
         if(isselected)and(UnitHaveRPoint(pu^.uidi))and(uo_x>0)then
         begin
            UnitsInfoAddLine(x,y,uo_x,uo_y,ui_blink_color1[ui_blink2_colorb]);
            SpriteListAddMarker(uo_x,uo_y,@spr_RallyPoint[_urace]);
         end;
      end;

      if(uo_x>0)and((uo_x<>x)or(uo_y<>y))and(speed>0)then // unit is moving
      begin
         if(isselected)and(speed>0)and(rpls_pstate<rpls_read)and(net_status<>ns_client)then
           if(uo_id=ua_move)or(uo_id=ua_amove)then
             if(uo_bx>0)then UnitsInfoAddLine(uo_bx,uo_by,uo_x,uo_y,ui_blink_color1[ui_blink2_colorb]);

         if(uo_id=ua_psability)then
           case _ability of
uab_RebuildInPoint: begin
                    SpriteListAddEffect(uo_x,uo_y,0,0,uid2spr(_rebuild_uid,270,0),128);
                    if(isselected)then UnitsInfoAddLine(vx,vy,uo_x,uo_y,ui_blink_color1[ui_blink2_colorb]);
                    if(ui_DrawEdges)then UnitsInfoAddCircle(uo_x,uo_y,g_uids[_rebuild_uid]._r,ui_blink2_color_BY);
                    end;
uab_CCFly         : begin
                    SpriteListAddEffect(uo_x,uo_y+fly_hz,0,0,uid2spr(uidi,270,0),128);
                    if(isselected)then UnitsInfoAddLine(vx,vy,uo_x,uo_y+fly_hz,ui_blink_color1[ui_blink2_colorb]);
                    if(ui_DrawEdges)then UnitsInfoAddCircle(uo_x,uo_y+fly_hz,_r,ui_blink2_color_BY);
                    end;
           else     if(isselected)then UnitsInfoAddLine(vx,vy,uo_x,uo_y,ui_blink_color1[ui_blink2_colorb]);
           end;
      end;

      if(iscomplete)then
      begin
         if(rld<ui_uid_reload [uidi])or(ui_uid_reload [uidi]<0)then ui_uid_reload [uidi]:=rld;
         if(_ukbuilding)then
           if(rld<ui_bucl_reload[_ucl])or(ui_bucl_reload[_ucl]<0)then ui_bucl_reload[_ucl]:=rld;

         if(isselected)then
         begin
            if(speed  >0)then ui_uibtn_move  +=1;
            if(_attack  )then ui_uibtn_attack+=1;

            if(uo_id<>ua_psability)or(s_all=1)then
            begin
            if(ui_ability(pu,false))then UnitOrderSetNearestTarget(pu,ui_cam_cx,ui_cam_cy,@ui_uibtn_sabilityu,@ui_uibtn_sabilityd,@ui_uibtn_sabilitys,unit_sability(pu       ,true)=0,false,true);
            if(ui_ability(pu,true ))then UnitOrderSetNearestTarget(pu,mouse_x  ,mouse_y  ,@ui_uibtn_pabilityu,@ui_uibtn_pabilityd,@ui_uibtn_pabilitys,unit_pability(pu,-1,0,0,true)=0,false,true);
            end;
            if(ui_rebuild (pu     ))then UnitOrderSetNearestTarget(pu,ui_cam_cx,ui_cam_cy,@ui_uibtn_rebuildu ,@ui_uibtn_rebuildd ,@ui_uibtn_rebuilds ,unit_rebuild(pu        ,true)=0,true ,true);
         end;
      end
      else
      begin
         t:=min2i(_btime,((_mhits-hits+_bstep) div _bstep) div 2);
         if(_ukbuilding)then
         begin
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
         end
         else
         begin
            t*=fr_fps1;
            ui_uprod_cur+=1;
            if(ui_uprod_first         <=0)or(t<ui_uprod_first         )then ui_uprod_first         :=t;
            if(ui_uprod_uid_time[uidi]<=0)or(t<ui_uprod_uid_time[uidi])then ui_uprod_uid_time[uidi]:=t;
         end;
      end;
   end;
end;

procedure unit_FootEffect(pu:PTUnit);
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
     if(smodel^.sm_spritesNum>0)then
      EID2Spr:=@smodel^.sm_spritesL[0];
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
      if(buffs[ub_Detect  ]>0)then lvlstr_b+=char_detect;

      lvlstr_l:='';
      if(not _ukbuilding)or(_isbarrack)or(_issmith)then
       case level of
       1: lvlstr_l:='>';
       2: lvlstr_l:='||';
       3: lvlstr_l:='* * *';
       end;
      //else
      //  if(level>0)then lvlstr_b+=char_advanced;

      // reload
      if(rld>0)
      then lvlstr_r:=tc_aqua+i2s(it2s(rld))
      else lvlstr_r:='';

      // weapon/attack
      sl      :=0;
      wl      :=0;
      atset   :=[];
      for i:=0 to MaxUnitWeapons do
       with _a_weap[i] do
        if(aw_rld>0)then
        begin
           if(aw_dupgr>0)then WeaponUpgrInc(aw_dupgr);
           if(aw_rupgr>0)and(upgr[aw_rupgr]>=aw_rupgr_l)then sl+=1;
        end;
      lvlstr_w:=i2s6(wl,_attack);
      if(length(lvlstr_w)>0)then lvlstr_w:=tc_red+lvlstr_w;

      // armor
      al:=upgr[_upgr_armor];
      if(_ukbuilding)then
      begin
         if(iscomplete)then
           al+=upgr[upgr_race_armor_build[_urace]]
      end
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

function gfx_AlphaGlows(amplitudo:byte;shift:cardinal):byte;
var amplitudoH,t:cardinal;
begin
   gfx_AlphaGlows:=0;
   if(amplitudo=0)then exit;
   amplitudoH:=amplitudo div 2;
   t:=(g_tick+shift) mod amplitudo;
   if(t>amplitudoH)
   then gfx_AlphaGlows:=amplitudo-t
   else gfx_AlphaGlows:=t;
end;

procedure unit_SpriteAlive(pu:PTUnit;noanim:boolean);
const _btnas: array[0..MaxUnitLevel] of integer = (0,ui_ButtonWh,ui_ButtonW1,ui_ButtonW1+ui_ButtonWh);
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
      if(playeri=UIPlayer)then ui_counters(pu);

/////////      Visible in fog of war
      if(not unit_FogReveal(pu))then exit;

      unit_DrawMiniMap(pu);

      if(_ability=uab_HKeepBlink)then
        if(buffs[ub_CCast]>0)then exit;

      wanim:=false;
      if(G_Status=gs_running)then
        if(unit_canMove(pu))then
          wanim:=(x<>mv_x)or(y<>mv_y)or(x<>vx)or(y<>vy);

      spr:=unit_GetSprite(pu);

      if(spr=pspr_dummy)then exit;

      depth:=unit_CalcShadowZ(pu)-shadow;
      t:=sign(depth);
      if(depth<-1)then t*=2;
      shadow+=t;

/////////      Visible in player's view
      if(not RectInCam(vx,vy,spr^.hw,spr^.hh,shadow))then exit;

      if((unum mod ui_blink_period2)=ui_blink_timer2)
      then unit_UpdateStatusStrings(pu);

      depth:=unit_SpriteDepth(pu);
      alpha:=255;
      ColorAura :=0;

      if(wanim)then unit_FootEffect(pu);

      UnitsInfoAddUnit(pu,un_smodel[level]);

      if(buffs[ub_Invis ]>0 )then alpha:=128;

      if(buffs[ub_Invuln]>fr_fpss)
      then ColorAura:=c_awhite;

      if(un_eid_summon_spr[level]<>nil)then
        if(buffs[ub_Summoned]>0)then
          SpriteListAddUnit(vx,vy,depth+1,0,0,ColorAura,un_eid_summon_spr[level],mm3i(0,buffs[ub_Summoned]*4,255));

      if(buffs[ub_ArchFire]>0)then
        with spr_h_p6 do
          if(sm_spritesNum>0)then SpriteListAddUnit(vx-g_randomr(_missile_r),vy-g_randomr(_missile_r),depth+1,0,0,0,@sm_spritesL[(g_tick div 4) mod cardinal(sm_spritesNum)],255);

      if(uidi=UID_UACDron)and(not iscomplete)
      then SpriteListAddEffect(vx,vy,sd_liquid+y,0,@spr_UTurret.sm_spritesL[0],255);

      if(_ukbuilding)then
        if(iscomplete)then
        begin
           if(a_rld<=0)and(not noanim)then
             if(uidi in [UID_UGTurret,UID_UATurret])then
             begin
                dir+=_animw;
                dir:=dir mod 360;
             end;

           if(playeri=UIPlayer)then
           begin
              for t:=0 to MaxUnitLevel do
              begin
                 if(_isbarrack)and(uprod_r[t]>0)then UnitsInfoAddUSprite(vx-_btnas[level]+ui_ButtonW1*t,vy,c_lime  ,@g_uids [uprod_u[t]]. un_btn,i2s(it2s(uprod_r[t])),'','','','');
                 if(_issmith  )and(pprod_r[t]>0)then UnitsInfoAddUSprite(vx-_btnas[level]+ui_ButtonW1*t,vy,c_yellow,@g_upids[pprod_u[t]]._up_btn,i2s(it2s(pprod_r[t])),'','','','');
              end;
           end;

           case uidi of
UID_UGTurret      : if(upgr[upgr_uac_turarm]>0)then
                      if(level=0)
                      then SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b4_a,alpha)
                      else SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b7_a,alpha);
UID_UATurret      : if(upgr[upgr_uac_turarm]>0)then
                           SpriteListAddUnit(vx  ,vy   ,depth,0,0,0,@spr_b9_a,alpha);
UID_UACommandCenter,
UID_UCommandCenter: if(upgr[upgr_uac_ccturr]>0)then
                           SpriteListAddUnit(vx+3,vy-65,depth,0,0,0,@spr_ptur,alpha);
           end;
        end
        else
          if(un_eid_bcrater>0)and(un_build_amode>0)then
          begin
             if(un_build_amode>1)then
             begin
                alpha:=gfx_AlphaGlows(255,cardinal(unum));
                alphab:=255-alpha;
             end
             else alphab:=255;

             if(buffs[ub_Invis]>0)then alphab:=alphab shr 1;

             SpriteListAddEffect(vx,vy+un_eid_bcrater_y,sd_liquid+un_eid_bcrater_y+y,0,EID2Spr(un_eid_bcrater),alphab);
          end
          else
            if(buffs[ub_Invis]>0)then alpha:=alpha shr 1;

      if(ui_ColoredShadow)
      then ColorShadow:=PlayerGetColor(playeri,true)
      else ColorShadow:=c_ablack;

      SpriteListAddUnit(vx,vy,depth,shadow,ColorShadow,ColorAura,spr,alpha);
   end;
end;

procedure unit_SpriteDead(pu:PTUnit);
var spr:PTMWTexture;
begin
   with pu^ do
   with uid^ do
   with player^ do
     if(hits>dead_hits)then
     begin
        if(hits<fdead_hits)then exit;

        spr:=unit_GetSprite(pu);

        if(spr=pspr_dummy)then exit;

        if(unit_FogReveal(pu))then
          if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then
            SpriteListAddDoodad(vx,vy,unit_SpriteDepth(pu),-32000,spr,mm3i(0,abs(hits-fdead_hits)*4,255),0,0);
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
   FillChar(ui_bprod_uid_count,SizeOf(ui_bprod_uid_count),0);
   FillChar(ui_bprod_ucl_count,SizeOf(ui_bprod_ucl_count),0);
   FillChar(ui_bprod_ucl_time ,SizeOf(ui_bprod_ucl_time ),0);
   FillChar(ui_uprod_uid_time ,SizeOf(ui_uprod_uid_time ),0);
   FillChar(ui_uprod_uid_max  ,SizeOf(ui_uprod_uid_max  ),0);
   FillChar(ui_pprod_max      ,SizeOf(ui_pprod_max      ),0);
   FillChar(ui_pprod_time     ,SizeOf(ui_pprod_time     ),0);
   FillChar(ui_units_inapc    ,SizeOf(ui_units_inapc    ),0);
   FillChar(ui_group_d        ,SizeOf(ui_group_d        ),0);
   FillChar(ui_group_f1       ,SizeOf(ui_group_f1       ),0);
   FillChar(ui_group_f2       ,SizeOf(ui_group_f2       ),0);
   ui_uprod_max      :=0;
   ui_uprod_cur      :=0;
   ui_uprod_first    :=0;
   ui_pprod_first    :=0;
   ui_uibtn_sabilityu:=nil;
   ui_uibtn_sabilityd:=integer.MaxValue;
   ui_uibtn_sabilitys:=false;
   ui_uibtn_pabilityu:=nil;
   ui_uibtn_pabilityd:=integer.MaxValue;
   ui_uibtn_pabilitys:=false;
   ui_uibtn_rebuildu :=nil;
   ui_uibtn_rebuildd :=integer.MaxValue;
   ui_uibtn_rebuilds :=false;
   ui_uibtn_move     :=0;
   ui_bprod_possible :=[];
   ui_bprod_first    :=0;
   ui_bprod_all      :=0;

   if(ui_umark_t>0)then begin ui_umark_t-=1;if(ui_umark_t=0)then ui_umark_u:=0;end;
   for u:=1 to MaxUnits do
   begin
      pu:=@g_units[u];
      with pu^ do
       if(IsUnitRange(transport,@tu))then
       begin
          if(tu^.isselected)and(G_Status=gs_running)and(playeri=UIPlayer)then ui_units_inapc[uidi]+=1;
       end
       else
         if(hits<=0)
         then unit_SpriteDead(pu)
         else unit_SpriteAlive(pu,noanim);
   end;
end;



