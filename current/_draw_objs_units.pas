
////////////////////////////////////////////////////////////////////////////////
//
//    MINI MAP
//

procedure unit_DrawMiniMap(pu:PTUnit);
begin
   if(ui_blink_timer1=(pu^.unum mod ui_update_period1))and(not MainMenu)and(vid_draw)then
     with pu^  do
     with uid^ do
     begin
        with g_unitsVis[unum] do
          if(uid^.uid_isbuilding)and(uid_MiniMapR>0)
          then rectangleColor(ui_minimap,mmx-uid_MiniMapR,mmy-uid_MiniMapR,
                                         mmx+uid_MiniMapR,mmy+uid_MiniMapR,PlayerGetColorCur(player^.pnum,false))
          else pixelColor    (ui_minimap,mmx,mmy,                          PlayerGetColorCur(player^.pnum,false));

        with player^ do
        begin
           if(UIPlayer<=LastPlayer)then
             if(team<>g_PlayersGame[UIPlayer].team)then exit;

           if(uid_ability_isradar)and(ui_mm_ScanBlink)then
             if(buffs[ub_Cast]>0)then
               filledCircleColor(ui_minimap,trunc(uo_x  *map_MiniMap_cx),
                                            trunc(uo_y  *map_MiniMap_cx),
                                            trunc(srange*map_MiniMap_cx),PlayerGetColorCur(pnum,true));
        end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    SPRITE DEPTH
//

function draw_DefaultSpriteDepth(y:integer;f:boolean):integer;
begin
   draw_DefaultSpriteDepth:=map_flydepths[f]+y;
end;

function unit_GetSpriteDepth(pu:PTUnit):integer;
begin
   unit_GetSpriteDepth:=0;
   with pu^ do
     case uidi of
     UID_UPortal,
     UID_HTeleport,
     UID_HPentagram,
     UID_HAltar    : unit_GetSpriteDepth:=sd_decals+vy;
     else
       if(uid^.uid_isbuilding)and((not iscomplete)or(transformTimer>0))
       then unit_GetSpriteDepth:=sd_build+vy
       else
         if(hits>0)or(buffs[ub_Resurected]>0)
         then unit_GetSpriteDepth:=draw_DefaultSpriteDepth(vy,isfly or (zfall>0))
         else unit_GetSpriteDepth:=draw_DefaultSpriteDepth(vy,isfly);
    end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    FOG
//

procedure fog_RevealScreenCircle(x,y,r:integer);
var iy,i:integer;
procedure setFOGPoint(tx,ty:integer);
begin if(0<=tx)and(0<=ty)and(tx<ui_fog_gridw)and(ty<ui_fog_gridh)then ui_fog_fgrid[tx,ty]:=true;end;
begin
   if(r<0    )then r:=0;
   if(r>fog_MaxR)then r:=fog_MaxR;
   for i:=0 to r do
     for iy:=0 to CircleRX2Y[r,i] do
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
          with g_unitsVis[unum] do
          begin
             if(fog_IfInScreen(fx,fy,fsr))then fog_RevealScreenCircle(fx-ui_fog_sx,fy-ui_fog_sy,fsr);
             if(uid_ability_isradar)then
               if(buffs[ub_Cast]>0)then fog_RevealScreenCircle((uo_x div fog_cw)-ui_fog_sx,
                                                               (uo_y div fog_cw)-ui_fog_sy,fsr);
          end;
          unit_FogReveal:=true
       end
       else
         if(UIplayer>LastPlayer)
         then unit_FogReveal:=true
         else
           if(CheckUnitTeamVision(g_PlayersGame[UIplayer].team,pu,false))then unit_FogReveal:=true;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UI COMMANDER
//

function ui_CommanderGetWeight(pu:PTUnit):word;
begin
   ui_CommanderGetWeight:=0;
   with pu^ do
   with uid^ do
   begin
      if (iscomplete        )
      and(transformTimer<=0 )then ui_CommanderGetWeight+=512;
      if (not uid_isbuilding)then ui_CommanderGetWeight+=256;
      if (uid_HaveAbility   )then ui_CommanderGetWeight+=128;
      if (uid_MSpeed_Base>0 )then ui_CommanderGetWeight+=64;
      if (rld<=0            )then ui_CommanderGetWeight+=32;
      if (uo_id<>ua_ability1)
      and(uo_id<>ua_ability2)
      and(uo_id<>ua_ability3)then ui_CommanderGetWeight+=16;
      if (transportM>0)
      and(transportC>0)      then ui_CommanderGetWeight+=8;
      if(unit_AbilityCheck(pu,uid_ability1,false)=0)then ui_CommanderGetWeight+=1;
      if(unit_AbilityCheck(pu,uid_ability2,false)=0)then ui_CommanderGetWeight+=1;
      if(unit_AbilityCheck(pu,uid_ability3,false)=0)then ui_CommanderGetWeight+=1;
   end;
end;

procedure ui_CommanderSet(pu:PTUnit);
var
curWeight:word;
curDist  :integer;
begin
   curWeight:=ui_CommanderGetWeight(pu);
   curDist  :=point_dist_int(ui_cam_cx,ui_cam_cy,pu^.x,pu^.y);
   if(ui_CommandercPU=nil)
   then
   else
     if(curWeight<ui_CommandercW)
     then exit
     else
       if(curWeight>ui_CommandercW)
       then
       else // equal weight
         case pu^.rld>0 of
         true : if(pu^.rld<ui_CommandercPU^.rld)
                then
                else exit;
         false: if(curDist<ui_CommandercD)
                then
                else exit;
         end;

   ui_CommandercPU:=pu;
   ui_CommandercW :=curWeight;
   ui_CommandercD :=curDist;
end;

procedure ui_CommanderClear;
begin
   ui_CommandercPU:=nil;
   ui_CommandercW :=0;
   ui_CommandercD :=ui_CommandercD.MaxValue;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UI COUNTERS
//

procedure ui_UICountersProductionUID(uidi:byte;time:integer;buffAccelerate:boolean);
var ftime:integer;
begin
   if(time<=0)then exit;

   if(buffAccelerate)
   then ftime:=time div 2
   else ftime:=time;

   with g_uids[uidi] do
     case uid_isbuilding of
     true : begin
               if(ui_bprod_ucl_time[uid_uibtn]<=0)
               or(ui_bprod_ucl_time[uid_uibtn]> ftime)then ui_bprod_ucl_time[uid_uibtn]:=time;
               if(ui_bprod_first<=0    )
               or(ui_bprod_first> ftime)then ui_bprod_first:=time;

               ui_bprod_uid_count[uidi     ]+=1;
               ui_bprod_ucl_count[uid_uibtn]+=1;
               ui_bprod_cur                 +=1;
            end;
     false: begin
               if(ui_uprod_first         <=0)or(ftime<ui_uprod_first         )then ui_uprod_first         :=time;
               if(ui_uprod_uid_time[uidi]<=0)or(ftime<ui_uprod_uid_time[uidi])then ui_uprod_uid_time[uidi]:=time;

               ui_uprod_uid_cur[uidi]+=1;
               ui_uprod_cur+=1;
            end;
     end;
end;

procedure ui_UICountersProduction(pu:PTUnit;pline:integer);
var
i,t:byte;
r  :integer;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(uid_isbarrack)then
        if(units_unitProds_s<=0)or(isselected)then
        begin
           ui_uprod_max+=1;

           if(uprod_r[pline]>0)
           then ui_UICountersProductionUID(uprod_u[pline],uprod_r[pline],buffs[ub_SphereTurbo]>0)
           else
             for t:=1 to 255 do
               if(t in uid_prod_Units)then ui_uprod_uid_max[t]+=1;
        end;

      if(uid_isforge)then
        if(units_upgrProds_s<=0)or(isselected)then
        begin
           ui_pprod_max+=1;

           if(pprod_r[pline]>0)then
           begin
              ui_pprod_cur+=1;
              if(buffs[ub_SphereTurbo]>0)
              then r:=pprod_r[pline] div 2
              else r:=pprod_r[pline];
              i:=pprod_u[pline];
              ui_pprod_upg_cur[i]+=1;
              if(ui_pprod_first      <=0)or(r<ui_pprod_first      )then ui_pprod_first      :=pprod_r[pline];
              if(ui_pprod_upg_time[i]<=0)or(r<ui_pprod_upg_time[i])then ui_pprod_upg_time[i]:=pprod_r[pline];
           end
           else
             for t:=1 to 255 do
               if(t in uid_prod_Upgrades)then ui_pprod_upg_max[t]+=1;
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
        ugroup_uids[uid_isbuilding]+=[uidi];
   end;
end;

procedure unit_UICounters(pu:PTUnit);
var i:byte;
HaveAttack:boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      // UI groups
      if(group<=MaxUnitGroups   )then ui_IncGroupCounter(@ui_group_d[group],x,y,uidi);
      if(unit_F2SelectFilter(pu))then ui_IncGroupCounter(@ui_group_f2      ,x,y,uidi); // all battle units
      if(unit_F1SelectFilter(pu))then ui_IncGroupCounter(@ui_group_f1      ,x,y,uidi); // all builders

      if(isselected)then
      begin
         // UI update the commander
         case m_brush of
         -255..-1: if(unit_OrderCheckAbility(pu,byte(-m_brush)))then
                   UnitOrderSetNearestTarget(pu,mouse_map_x,mouse_map_y,@ui_CommandercPU,@ui_CommandercD,@ui_CommandercW,unit_AbilityCheck(pu,byte(-m_brush),false)=0,false,true );
         else      ui_CommanderSet(pu);
         end;

         // have rally point
         if(uid_HaveRallyPoint)then ui_uibtn_rpoint+=1;

         // cancel production order
         if(unit_OrderCheckProdCancel(pu))then ui_uibtn_ProdCncl+=1;
      end;

      if(iscomplete)then
      begin
         // building area and possible buildings for UI
         if(uid_isbuilder)and(not isfly)and(zfall=0)then
           if(units_builders_s=0)or(isselected)then
             ui_bprod_possible+=uid_prod_Buildings;

         // production counters
         if(transformTimer>0)
         then ui_UICountersProductionUID(transformUID,transformTimer,buffs[ub_SphereTurbo]>0)
         else
           for i:=0 to LastUnitLevel do
             if(i>level)
             then break
             else ui_UICountersProduction(pu,i);

         // reload by uid
         if(rld<ui_uid_reload [uidi])or(ui_uid_reload [uidi]<0)then ui_uid_reload [uidi]:=rld;
         // reload by ucl, only buildings
         if(uid_isbuilding)then
           if(rld<ui_bucl_reload[uid_uibtn])
           or(ui_bucl_reload[uid_uibtn]<0)then ui_bucl_reload[uid_uibtn]:=rld;

         // basic move/attack orders
         if(isselected)and(transformTimer<=0)then
         begin
            HaveAttack:=ui_HaveAttack(pu);
            if (speed>0   )then ui_uibtn_move   +=1;
            if (HaveAttack)then ui_uibtn_attack +=1;
            if (speed>0   )
            and(HaveAttack)then ui_uibtn_apatrol+=1;
         end;
      end
      else
      begin
         // building time
         ui_UICountersProductionUID(uidi,min2i(uid_ProdTimeSec,((uid_MaxHits1-hits+uid_ProdHitStep) div uid_ProdHitStep) div 2)*fr_fps1,buffs[ub_SphereTurbo]>0);
      end;
   end;
end;

procedure unit_UICountersAll;
var
u :integer;
tu,
pu:PTUnit;
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
   FillChar(ui_uprod_uid_cur  ,SizeOf(ui_uprod_uid_cur  ),0);
   FillChar(ui_pprod_upg_time ,SizeOf(ui_pprod_upg_time ),0);
   FillChar(ui_pprod_upg_max  ,SizeOf(ui_pprod_upg_max  ),0);
   FillChar(ui_pprod_upg_cur  ,SizeOf(ui_pprod_upg_cur  ),0);
   FillChar(ui_units_inapc    ,SizeOf(ui_units_inapc    ),0);
   FillChar(ui_group_d        ,SizeOf(ui_group_d        ),0);
   FillChar(ui_group_f1       ,SizeOf(ui_group_f1       ),0);
   FillChar(ui_group_f2       ,SizeOf(ui_group_f2       ),0);
   ui_uprod_max      :=0;
   ui_uprod_cur      :=0;
   ui_uprod_first    :=0;
   ui_pprod_max      :=0;
   ui_pprod_cur      :=0;
   ui_pprod_first    :=0;
   ui_bprod_possible :=[];
   ui_bprod_first    :=0;
   ui_bprod_cur      :=0;

   ui_uibtn_rpoint   :=0;
   ui_uibtn_move     :=0;
   ui_uibtn_attack   :=0;
   ui_uibtn_apatrol  :=0;
   ui_uibtn_ProdCncl :=0;

   ui_CommanderClear;

   for u:=1 to MaxUnits do
   begin
      pu:=@g_units[u];
      with pu^ do
        if(playeri=UIPlayer)and(hits>0)then
          if(IsUnitRange(transportU,@tu))then
          begin
             if(tu^.isselected)then ui_units_inapc[uidi]+=1;
          end
          else unit_UICounters(pu);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UI LAYER UNIT MARKS
//

procedure unit_UIMarks(pu:PTUnit);
var
i:byte;
t:integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_isbuilding)then
      begin
         // building areas
         if(iscomplete)and(uid_isbuilder)and(not isfly)then
           if(units_builders_s=0)or(isselected)then
             case m_brush of
             1..255 : if(m_brush in uid_prod_Buildings)then
                        if(RectInCam(x,y,srange,srange,0))then
                          UnitsInfo_AddCircle(x,y,srange,ui_blink_color1[ui_blink2_colorb]);
             end;
         // rally points
         if(uid_HaveRallyPoint)then
           if(isselected)or(m_UnitTargetN=unum)then
           begin
              UnitsInfo_AddLine(x,y,rpoint_x,rpoint_y,ui_blink_color1[ui_blink2_colorb]);
              SpriteList_AddMarker(rpoint_x,rpoint_y,@spr_RallyPoint[uid_race]);
           end;
      end;

      if(speed>0)then
        if(uo_x<>x)or(uo_y<>y)then // unit is moving or casting
          case uo_id of
          ua_move,
          ua_amove   : if(uo_bx>0)then    // patrol
                         if(isselected)or(m_UnitTargetN=unum)then
                           UnitsInfo_AddLine(uo_bx,uo_by,uo_x,uo_y,ui_blink_color1[ui_blink2_colorb]);
          ua_ability1,
          ua_ability2,
          ua_ability3: begin
                          i:=unit_GetCastingAbility(pu);
                          if(i>0)then
                            with g_aids[i] do
                              case ua_type of
                              uat_point    : begin
                                                SpriteList_AddEffect(uo_x,uo_y,0,0,ui_AbilityGetBrushSpr(i,uidi),128);
                                                if(ui_DrawEdges)then
                                                begin
                                                   t:=ui_AbilityGetBrushR(i,pu);
                                                   if(t>0)then
                                                     UnitsInfo_AddCircle(uo_x,uo_y,t,ui_blink2_color_BY);
                                                end;

                                                if(isselected)or(m_UnitTargetN=unum)then
                                                  UnitsInfo_AddLine(vx,vy,uo_x,uo_y,ui_blink_color1[ui_blink2_colorb]);
                                             end;
                              uat_UnitAny,
                              uat_UnitOwn,
                              uat_UnitAlly,
                              uat_UnitEnemy:;
                              end;
                       end;
          end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UI VISUALs
//

procedure unit_FootEffect(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
     if(uid_AnimStepWalk>0)then
       with g_unitsVis[unum] do
       begin
          if(buffs[ub_SphereTurbo]>0)
          then animf-=2
          else animf-=1;
          if(animf<=0)then
          begin
             snd_SoundPlayUnit(uid_snd_Foot,nil,nil);
             animf:=uid_AnimStepFoot;
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
al,wl,sl:byte;
   atset:TSoB;
procedure WeaponUpgrInc(upgr:byte);
begin
   if not(upgr in atset)then
   begin
      wl+=pu^.player^.upgrs_cur[upgr];
      atset+=[upgr];
   end;
end;
begin
   with pu^     do
   with g_unitsVis[unum] do
   with uid^    do
   with player^ do
   begin
      // buffs and level
      lvlstr_b:='';
      if(buffs[ub_Detector]>0)then lvlstr_b+=char_detect;

      lvlstr_l:='';
      if(not uid_isbuilding)
      or(uid_isbarrack)
      or(uid_isforge)
      or(uid_ability_RldReducByLvl)then
        if(level<=LastUnitLevel)then
          lvlstr_l:=str_UnitLevel[level,uid_race];

      // reload
      if(rld>0)
      then lvlstr_r:=tc_aqua+i2s(it2s(rld))
      else lvlstr_r:='';

      sl:=0;
      wl:=0;
      al:=0;
      // weapon/attack
      lvlstr_w:='';
      atset   :=[];
      for i:=0 to LastUnitArms do
        with uid_arms[i] do
          if(aw_reload>0)then
          begin
             if(aw_impact_upgr>0)then WeaponUpgrInc(aw_impact_upgr);
             if(aw_req_upgr>0)and(upgrs_cur[aw_req_upgr]>0)then sl+=1;
          end;
      if(wl>0)then
        lvlstr_w:=i2s6(wl,uid_CanAttack);
      if(length(lvlstr_w)>0)then lvlstr_w:=tc_red+lvlstr_w+tc_default;

      // armor
      lvlstr_a:='';
      if(iscomplete)then
      begin
         if(uid_Armor_upgr1>0)then al+=upgrs_cur[uid_Armor_upgr1];
         if(uid_Armor_upgr2>0)then al+=upgrs_cur[uid_Armor_upgr2];
      end;
      if(al>0)then
        lvlstr_a:=tc_lime+i2s6(al,true)+tc_default;

      // other
      lvlstr_s:='';
      if(uid_Regen_upgr       >0)then sl+=upgrs_cur[uid_Regen_upgr       ];
      if(uid_SightR_upgr      >0)then sl+=upgrs_cur[uid_SightR_upgr      ];
      if(uid_PainState_upgr   >0)then sl+=upgrs_cur[uid_PainState_upgr   ];
      if(uid_TransportMax_upgr>0)then sl+=upgrs_cur[uid_TransportMax_upgr];
      if(uid_MSpeed_upgr      >0)then sl+=upgrs_cur[uid_MSpeed_upgr      ];
      if(sl>0)then
        lvlstr_s:=tc_yellow+i2s6(sl,true)+tc_default;
   end;
end;

procedure unit_AddSpriteAlive(pu:PTUnit;noanim:boolean);
var
spr        : PTMWTexture;
spr_model  : PTMWSModel;
spr_depth,
spr_alphab,
spr_alpha,t: integer;
ColorShadow,
ColorAura  : TMWColor;
begin
   with pu^     do
   with uid^    do
   with player^ do
   with g_unitsVis[unum] do
   if(unit_FogReveal(pu))then
   begin
/////////      Visible in fog of war
      unit_DrawMiniMap(pu);

      if(uid_ability_HKeepShift)then
        if(buffs[ub_Cast]>0)then exit;

      wanim:=false;
      if(g_status=gs_running)then
        if(unit_canMove(pu))then
          wanim:=(x<>move_x)or(y<>move_y)or(x<>vx)or(y<>vy);

      spr:=unit_GetSprite(pu,@spr_model);

      if(spr=pspr_dummy)then exit;

      // shadow animation
      spr_depth:=unit_CalcShadowZ(pu)-shadowz;
      t:=sign(spr_depth);
      if(spr_depth<-1)then t*=2;
      shadowz+=t;

/////////      Visible in player's cam
      if(not RectInCam(vx,vy,spr^.hw,spr^.hh,shadowz))then exit;

      if((unum mod ui_blink_period2)=ui_blink_timer2)then
        unit_UpdateStatusStrings(pu);

      UnitsInfo_AddFromUnit(pu,spr_model); //uid_SpriteModel[level]

      spr_depth:=unit_GetSpriteDepth(pu);
      spr_alpha:=255;
      ColorAura :=0;

      if(wanim)then unit_FootEffect(pu);

      if(buffs[ub_Invisibility ]>0)then spr_alpha:=128;

      if(buffs[ub_SphereInvuln ]>0)then ColorAura:=c_awhite;
      if(buffs[ub_SphereRDamage]>0)then ColorAura:=c_agray;
      if(buffs[ub_SphereDDamage]>0)then ColorAura:=c_ared;
      if(buffs[ub_SphereTurbo  ]>0)then ColorAura:=c_aorange;

      if(uid_eid_SummonSpr[level]<>nil)then
        if(buffs[ub_Summoned]>0)then
          SpriteList_AddUnit(vx,vy,spr_depth+1,0,0,ColorAura,uid_eid_SummonSpr[level],mm3i(0,buffs[ub_Summoned]*4,255));

      if(iscomplete)and(transformTimer<=0)then
      begin
         if(a_rld<=0)and(not noanim)then
           case uidi of
           UID_UGTurret,
           UID_UATurret: begin
                            dir+=uid_AnimStepWalk;
                            dir:=dir mod 360;
                         end;
           end;

         case uidi of
         UID_UGTurret      : if(upgrs_cur[upgr_uac_TurretArmor]>0)then
                               if(upgrs_cur[upgr_uac_TurretPlasma]>0)
                               then SpriteList_AddUnit(vx,vy,spr_depth,0,0,0,@spr_b7_a,spr_alpha)
                               else SpriteList_AddUnit(vx,vy,spr_depth,0,0,0,@spr_b4_a,spr_alpha);
         UID_UATurret      : if(upgrs_cur[upgr_uac_TurretArmor]>0)then
                                    SpriteList_AddUnit(vx,vy,spr_depth,0,0,0,@spr_b9_a,spr_alpha);
         UID_UACommandCenter,
         UID_UCommandCenter: if(upgrs_cur[upgr_uac_CCAttack]>0)then
                               with uid_arms[0] do
                                    SpriteList_AddUnit(vx+aw_offset_x,vy+aw_offset_y,
                                                                spr_depth,0,0,0,@spr_ptur,spr_alpha);
         end;
      end
      else
        if(uid_eid_bcrater>0)and(uid_eid_BuildHellType)then
        begin
           if(buffs[ub_Invisibility]>0)
           then spr_alphab:=128
           else spr_alphab:=255;

           SpriteList_AddEffect(vx,vy+uid_eid_bcrater_y,sd_liquidFront+uid_eid_bcrater_y+y,0,EID2Spr(uid_eid_bcrater),spr_alphab);
        end;

      if(ui_ColoredShadow)
      then ColorShadow:=PlayerGetColorCur(playeri,true)
      else ColorShadow:=c_ablack;

      SpriteList_AddUnit(vx,vy,spr_depth,shadowz,ColorShadow,ColorAura,spr,spr_alpha);
   end;
end;

procedure unit_AddSpriteDead(pu:PTUnit);
var spr:PTMWTexture;
begin
   with pu^ do
   with uid^ do
   with player^ do
     if(hits>=hits_fdead)then
     begin
        spr:=unit_GetSprite(pu);

        if(spr<>pspr_dummy)then
          if(unit_FogReveal(pu))then
            if(RectInCam(vx,vy,spr^.hw,spr^.hh,0))then
              SpriteList_AddDoodad(vx,vy,unit_GetSpriteDepth(pu),-32000,spr,byte(mm3i(0,abs(hits-hits_fdead)*4,255)),0,0);
     end;
end;

procedure unit_AddSpritesAndMarks(noanim:boolean);
var
u :integer;
pu:PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=@g_units[u];
      with pu^ do
        if not(IsUnitRange(transportU,nil))then
          if(hits<=0)
          then unit_AddSpriteDead (pu)
          else
          begin
             if(playeri=UIPlayer)then unit_UIMarks(pu);
             unit_AddSpriteAlive(pu,noanim);
          end;
   end;

   if(ui_CommandercPU<>nil)then
     case m_brush of
     -255..-1: with ui_CommandercPU^ do
                 UnitsInfo_AddLine(x,y,m_brushx,m_brushy,ui_blink_color1[ui_blink2_colorb]);
     end;
end;

