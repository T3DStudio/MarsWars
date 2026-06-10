

procedure unit_death(pu:PTUnit);
var tu  : PTUnit;
    uc  : integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
     if(hits>hits_dead)then
     begin
        if(cycle_order=g_cycle_order)then
        begin
           for uc:=1 to MaxUnits do
            if(uc<>unum)then
            begin
               tu:=@g_units[uc];
               if(tu^.hits>hits_dead)then unit_detect(pu,tu,point_dist_rint(x,y,tu^.x,tu^.y));
            end;
        end;

        if(buffs[ub_Resurected]<=0)then
        begin
           {$IFDEF _FULLGAME}
           if(ServerSide)or(hits>hits_fdead)then
           {$ENDIF}
           hits-=1;

           {$IFDEF _FULLGAME}
            with g_unitsVis[unum] do
             if(cycle_order=g_cycle_order)and(fsr>1)then fsr-=1;
           if(ServerSide)then
           {$ENDIF}
             if(hits<=hits_dead)then unit_remove(pu);
        end
        else
        begin
           if(hits<hits_resurrected)then hits:=hits_resurrected;

           {$IFDEF _FULLGAME}
           if(ServerSide)or(hits<-1)then
           {$ENDIF}
           hits+=1;

           {$IFDEF _FULLGAME}
           if(ServerSide)then
           {$ENDIF}
             if(hits>=0)then
             begin
                zfall     :=0;
                uo_id     :=ua_amove;
                uo_x      :=x;
                uo_y      :=y;
                uo_tar    :=0;
                rpoint_x  :=x;
                rpoint_y  :=y;
                rpoint_tar:=0;
                dir       :=270;
                hits      :=uid_MaxHits1;
                buffs[ub_Resurected]:=0;
                {$IFDEF _FULLGAME}
                unit_CalcFogR(pu);
                {$ENDIF}
                GameLog_UnitResurrected(pu);
             end;
        end;
     end;
end;

procedure unit_damage(pTarget:PTUnit;damage:integer;damagePlayer:byte;IgnoreArmor:boolean);
var armor:integer;
begin
   with pTarget^ do
   with uid^ do
   begin
      if(buffs[ub_SphereInvuln]>0)
      or(hits<=0)
      or(damage<=0)
      then exit;

      //damage:=1;

      armor:=0;
      if(iscomplete)and(not IgnoreArmor)then
      begin
         if(buffs[ub_SphereRDamage]>0)then damage-=damage div 2;
         if(buffs[ub_Heroic       ]>0)then damage-=damage div 3;

         with player^ do
         begin
            if(uid_Armor_upgr1>0)then armor+=integer(upgrs_cur[uid_Armor_upgr1])*uid_Armor_upgrV;
            if(uid_Armor_upgr2>0)then armor+=integer(upgrs_cur[uid_Armor_upgr2])*uid_Armor_upgrV;
         end;

         if(level>0)and(not uid_isbuilding)then armor+=level*uid_LevelBonusArmor;

         damage-=armor;
      end;

      if(damage<=0)then damage:=1;

      if(hits<=damage)then
      begin
         {$IFDEF _FULLGAME}
         if(ServerSide)then
         {$ENDIF}
         begin
            unit_kill(pTarget,false,(hits-damage)<=uid_FastDeathHits,true,false,false);
            if(damagePlayer<=LastPlayer)and(iscomplete)then
              with g_PlayersMain[damagePlayer] do
              begin
                 if(race<>r_hell)then
                 res_HellPower:=min2i(HellPower_Max,res_HellPower+uid_bounty_HellPower);
                 res_UACLoot  :=min2i(UACLoot_Max  ,res_UACLoot  +uid_bounty_UACLoot  );
              end;
         end;
      end
      else
      begin
         buffs[ub_Damaged]:=fr_fps2;
         {$IFDEF _FULLGAME}
         if(not ServerSide)then
         begin
            if(buffs[ub_PainState]<=0)then exit;
         end
         else
         {$ENDIF}
         hits-=damage;

         if(not uid_isbuilding)and(not uid_ismech)then
           if(uid_PainState_Base>0)then
           begin
              if(pains>0)then pains-=1;
              if(pains<=0)then
              begin
                 pains:=uid_PainState_Base;

                 buffs[ub_PainState]:=max2i(pain_time,a_rld);

                 with player^ do
                   if(uid_PainState_upgr>0)then
                     pains+=integer(upgrs_cur[uid_PainState_upgr])*uid_PainState_upgrV;

                 if(level>0)then pains+=level*uid_LevelBonusPainC;

                 {$IFDEF _FULLGAME}
                 effect_UnitPain(pTarget,nil);
                 {$ENDIF}
              end;
          end;
      end;
   end;
end;

function unit_morph(pu:PTUnit;ouid:byte;ocomplete:boolean;bhits:integer;ulevel:byte;check:boolean;summoned:boolean=true):byte;
var
pOldU  :PTUnit;
pNewUID:PTUID;
begin
   unit_morph:=0;
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(hits<=0)then
      begin
         unit_morph:=lmt_Invalid_Order;
         exit;
      end;
      pOldU  :=g_punits[0];
      pOldU^ :=pu^;
      pNewUID:=@g_uids[ouid];

      if(units_uid_m[ouid]<=0)then
      begin
         unit_morph:=lmt_Req_MaxCount;
         exit;
      end;
      if((armylimit-uid_LimitUse+pNewUID^.uid_LimitUse+prod_unit_Limit)>MaxPlayerLimit)then
      begin
         unit_morph:=lmt_Req_Limit;
         exit;
      end;
      if(not ocomplete)or(pNewUID^.uid_isbuilding)then
        if(res_energyl_max<=0)then
        begin
           unit_morph:=lmt_Req_Energy;
           exit;
        end;
      if(not ocomplete)then
      begin
         if(isfly)or(transportC>0)then
         begin
            unit_morph:=lmt_Invalid_Order;
            exit;
         end;
         if((res_energyl_cur-uid_gen_EnergyLevel)<pNewUID^.uid_req_EnergyLevel)or(res_energyl_max<=uid_gen_EnergyLevel)then
         begin
            unit_morph:=lmt_Req_Energy;
            exit;
         end;
         if(res_HellPower<pNewUID^.uid_req_HellPower)then
         begin
            unit_morph:=lmt_Req_HellPower;
            exit;
         end;
         if(res_UACLoot<pNewUID^.uid_req_UACLoot)then
         begin
            unit_morph:=lmt_Req_UACLoot;
            exit;
         end;
         if(CheckCollisionR(x,y,pNewUID^.uid_r,unum,pNewUID^.uid_isbuilding,true,255)<>cbr_no)then
         begin
            unit_morph:=lmt_prod_BadPlace;
            exit;
         end;
      end;

      if(ulevel>LastUnitLevel)then
      begin
         if(uidi=ouid)and(level>=LastUnitLevel)
         then unit_morph:=lmt_unit_MaxLevel
         else unit_morph:=lmt_Invalid_Order;
         exit;
      end;

      if(check)then exit;

      vx:=x;
      vy:=y;
   end;

   with pOldU^ do
   with player^ do
   begin
      units_all_e+=1;   // ??? костыль что бы игрок не проигрывал если трансформируется единственное здание/юнит
      unit_kill(pu,true,true,false,false,true);
      units_all_e-=1;
      unit_add(x,y,unum,ouid,playeri,ocomplete,summoned,ulevel);

      //res_HellPower-=pNewUID^.uid_req_HellPower;
      //res_UACLoot  -=pNewUID^.uid_req_UACLoot;
   end;

   if(LastCreatedUnitP<>nil)then
     with LastCreatedUnitP^ do
     begin
        if(bhits<0)then bhits:=pNewUID^.uid_MaxHits1 div abs(bhits);
        with uid^ do
          if(uid_HaveRallyPoint)then
          begin
             rpoint_tar:=pOldU^.rpoint_tar;
             rpoint_x  :=pOldU^.rpoint_x;
             rpoint_y  :=pOldU^.rpoint_y;
          end;
        TeamDetection:=pOldU^.TeamDetection;
        TeamVision   :=pOldU^.TeamVision;
        if(bhits>0)then
          if(not iscomplete)then hits:=mm3i(1,bhits,uid^.uid_MaxHits1-1);
        if(pOldU^.isselected)then unit_select(LastCreatedUnitP);
        buffs[ub_Heroic]:=pOldU^.buffs[ub_Heroic];
        if(pOldU^.uidi=uidi)then rld:=pOldU^.rld;
     end;
end;

procedure unit_PushFromUnit(pUnit,pUObstacle:PTUnit;uds:single);
var t:single;
   ud:integer;
shortCollision,
dirTurn:boolean;
begin
   // pUnit from pUObstacle
   with pUnit^ do
   with uid^ do
   begin
      t :=uds;
      shortCollision:=(pUnit^.playeri=pUObstacle^.playeri)and((pUObstacle^.speed<=0)
                                                            or(not pUObstacle^.iscomplete)
                                                            or(pUObstacle^.transformTimer>0));
      if(shortCollision)
      then uds-=pUObstacle^.uid^.uid_r
      else uds-=pUObstacle^.uid^.uid_r+uid_r;
      ud:=round(uds);

      dirTurn:=(a_rld<=0)and( (pUObstacle^.speed<=0)
                            or(not pUObstacle^.iscomplete)
                            or(pUObstacle^.transformTimer>0)
                            or(pUObstacle^.uid^.uid_isbuilding)
                            or((pUObstacle^.x=pUObstacle^.uo_x)and(pUObstacle^.y=pUObstacle^.uo_y)) );

      if(uds<0)then
      begin
         AddToInt(@pUObstacle^.TeamVision[player^.team],MinVisionTime);

         if((pUObstacle^.x=x)and(pUObstacle^.y=y))then
         begin
            case g_random(4) of
            0: unit_SetXY(pUnit,x-ud,y   ,mvxy_none,isfly);
            1: unit_SetXY(pUnit,x+ud,y   ,mvxy_none,isfly);
            2: unit_SetXY(pUnit,x   ,y-ud,mvxy_none,isfly);
            3: unit_SetXY(pUnit,x   ,y+ud,mvxy_none,isfly);
            end;
         end
         else unit_SetXY(pUnit,x+round(uds*(pUObstacle^.x-x)/t)+g_randomr(2),
                               y+round(uds*(pUObstacle^.y-y)/t)+g_randomr(2),mvxy_none,isfly);

         vstp+=round(uds/speed*UnitStepTicks);

         if(dirTurn)then
           if(vx<>x)or(vy<>y)then
             if(shortCollision)
             then dir:=dir_MOD360(dir-(         dir_diff(dir,point_dir(vx,vy,x,y))     div 2 ))
             else dir:=dir_MOD360(dir-(mm3i(-90,dir_diff(dir,point_dir(vx,vy,x,y)),90) div 2 ));

         if(pUObstacle^.x=pUObstacle^.uo_x)and(pUObstacle^.y=pUObstacle^.uo_y)and(uo_tar=0)then
         begin
            ud:=point_dist_rint(uo_x,uo_y,pUObstacle^.x,pUObstacle^.y)-uid_r-pUObstacle^.uid^.uid_r;
            if(ud<=0)then
            begin
               uo_x:=x;
               uo_y:=y;
            end;
         end;
      end;
   end;
end;

procedure unit_PushFromObstacle(pu:PTUnit;pObstacle:PTObstacle);
var
t,
uds:single;
udi:integer;
procedure push_Outside;
begin
   with pu^ do
   with uid^ do
   begin
      uds:=t-(uid_r+pObstacle^.o_rO);

      if(uds>=0)then exit;

      udi:=round(uds);

      if((pObstacle^.o_x=x)and(pObstacle^.o_y=y))then
      begin
         case g_random(4) of
         0: unit_SetXY(pu,x-udi,y   ,mvxy_none,false);
         1: unit_SetXY(pu,x+udi,y   ,mvxy_none,false);
         2: unit_SetXY(pu,x   ,y-udi,mvxy_none,false);
         3: unit_SetXY(pu,x   ,y+udi,mvxy_none,false);
         end;
      end
      else unit_SetXY(pu,x+round(udi*(pObstacle^.o_x-x)/t)+g_randomr(2),
                         y+round(udi*(pObstacle^.o_y-y)/t)+g_randomr(2),mvxy_none,false);

      vstp+=round(uds/speed*UnitStepTicks);

      if(a_rld<=0)then
        if(vx<>x)or(vy<>y)then dir:=dir_MOD360(dir-(dir_diff(dir,point_dir(vx,vy,x,y)) div 2 ));

      if(uo_id=ua_ability1)
      or(uo_id=ua_ability2)
      or(uo_id=ua_ability3)then exit;

      if(pObstacle^.o_x=uo_x)and(pObstacle^.o_y=uo_y)then
      begin
         uo_x-=sign(pObstacle^.o_x-x);
         uo_y-=sign(pObstacle^.o_y-y);
      end;

      uds:=point_dist_real(uo_x,uo_y,pObstacle^.o_x,pObstacle^.o_y);
      udi:=uid_r+pObstacle^.o_rO;
      if(uds<=udi)then
      begin
         udi+=2;
         uo_x:=pObstacle^.o_x-round((pObstacle^.o_x-uo_x)/uds*udi);
         uo_y:=pObstacle^.o_y-round((pObstacle^.o_y-uo_y)/uds*udi);
      end;
   end;
end;
procedure push_InSide;
begin
   with pu^ do
   with uid^ do
   begin
      udi:=pObstacle^.o_rI-uid_r;
      if(t<udi)then exit;

      unit_SetXY(pu,pObstacle^.o_x-round(udi*(pObstacle^.o_x-x)/t),
                    pObstacle^.o_y-round(udi*(pObstacle^.o_y-y)/t),mvxy_none,false);


      vstp+=round(udi/speed*UnitStepTicks);

      if(a_rld<=0)then
        if(vx<>x)or(vy<>y)then dir:=dir_MOD360(dir-(dir_diff(dir,point_dir(vx,vy,x,y)) div 2 ));

      if(uo_id=ua_ability1)
      or(uo_id=ua_ability2)
      or(uo_id=ua_ability3)then exit;

      uds:=point_dist_real(uo_x,uo_y,pObstacle^.o_x,pObstacle^.o_y);
      udi:=pObstacle^.o_rI-uid_r;
      if(uds>udi)then
      begin
         udi-=2;
         uo_x:=pObstacle^.o_x-round((pObstacle^.o_x-uo_x)/uds*udi);
         uo_y:=pObstacle^.o_y-round((pObstacle^.o_y-uo_y)/uds*udi);
      end;
   end;
end;
begin
   with pu^ do
   with uid^ do
   begin
      t  :=point_dist_real(x,y,pObstacle^.o_x,pObstacle^.o_y);

      if(pObstacle^.o_rI<=0)
      or(pObstacle^.o_rM<=t)
      then push_Outside
      else push_InSide;
   end;
end;

procedure unit_PushFromObstacles(pu:PTUnit);
var i,
dx,dy,
dx0,dy0,
dx1,dy1:integer;
begin
   with pu^ do
     if(speed<=0)
     or(isfly<>uf_ground)
     or(uid^.uid_isfly) //and uid_FlyLevelLikeTarget ???
     or(not uid^.uid_issolid)
     or(zfall<>0)
     or(transformTimer>0)
     or(not iscomplete)then exit;

   with pu^ do
   with uid^ do
   begin
      dx0:=(x-uid_r) div MapObstaclesGridW;
      dy0:=(y-uid_r) div MapObstaclesGridW;
      dx1:=(x+uid_r) div MapObstaclesGridW;
      dy1:=(y+uid_r) div MapObstaclesGridW;
   end;
   for dx:=dx0 to dx1 do
   for dy:=dy0 to dy1 do
     if (0<=dx)and(dx<=MapObstaclesGridN)
     and(0<=dy)and(dy<=MapObstaclesGridN)then
       with map_ObstaclesGrid[dx,dy] do
         if(oc_n>0)then
           for i:=0 to oc_n-1 do
             with oc_l[i]^ do
               if(o_rO>0)then unit_PushFromObstacle(pu,oc_l[i]);
   unit_UpdateXY(pu);
end;

procedure unit_move(pu:PTUnit);
var mdist:integer;
    ddir :single;
begin
   with pu^ do
    if(x=vx)and(y=vy)and(speed>0)then
     if(x<>move_x)or(y<>move_y)then
       if(unit_canMove(pu))then
       begin
          if(move_px<>move_x)or(move_py<>move_y)then
          begin
             //if(player^.state<>ps_AI)then
               if(x<>move_x)
               or(y<>move_y)then dir:=point_dir(x,y,move_x,move_y);
             move_px:=move_x;
             move_py:=move_y;
          end;

          mdist:=point_dist_int(x,y,move_x,move_y);
          if(mdist<=speed)then
          begin
             unit_SetXY(pu,move_x,move_y,mvxy_none,isfly);
             dir:=point_dir(vx,vy,x,y);
          end
          else
          begin
             if(mdist>70)
             then mdist:=8+g_random(25)
             else mdist:=50;

             dir:=dir_turn(dir,point_dir(x,y,move_x,move_y),mdist);

             ddir:=dir*degtorad;
             unit_SetXY(pu,x+round(speed*cos(ddir)),
                           y-round(speed*sin(ddir)),mvxy_none,isfly);
          end;
          unit_PushFromObstacles(pu);
       end;
end;

function unit_StartResurrection(pResurrector,pTarget:PTUnit;check:boolean):boolean;
begin
   // pResurrector - resurrector
   // pTarget - target
   unit_StartResurrection:=false;

   with pTarget^ do
   begin
      if(buffs[ub_Resurected]>0)
      or(buffs[ub_PainState ]>0)
      or(hits<=hits_fdead      )
      or(hits>0                )then exit;
   end;

   if(pResurrector<>nil)then
     if(pTarget^.player^.team<>pResurrector^.player^.team)then
       with pResurrector^ do
       with uid^ do
       with player^ do
         if((armylimit+pTarget^.uid^.uid_LimitUse+prod_unit_Limit)>MaxPlayerLimit)then exit;

   unit_StartResurrection:=true;

   if(check)then exit;

   if(pResurrector<>nil)then
     if(pTarget^.player^.team<>pResurrector^.player^.team)then
     begin
        unit_add(pTarget^.x,pTarget^.y,pResurrector^.unum,pTarget^.uidi,pResurrector^.playeri,true,false,pTarget^.level);

        if(LastCreatedUnit>0)then
          with LastCreatedUnitP^ do
          begin
             hits:=pTarget^.hits;
             unit_DecCounters_Kill(LastCreatedUnitP);
          end;
        unit_kill(pTarget,true,true,false,false,true);
        pTarget:=LastCreatedUnitP;
     end;

   with pTarget^ do
   begin
      buffs[ub_Resurected]:=fr_fps2;
      zfall:=-uid^.uid_zfall;
      isfly:= uid^.uid_isfly;
   end;
end;

function unit_CheckArmForTarget(pAttacker,pTarget:PTUnit;udist:integer;armN:byte;checkVis,noSRangeCheck:boolean):byte;
var awr:integer;
//     au:PTUnit;
pfcheck,
canmove:boolean;
begin
   unit_CheckArmForTarget:=wmove_impassible;

   //pAttacker - attacker
   //pTarget - target

   if(checkVis)then
     if(not CheckUnitTeamVision(pAttacker^.player^.team,pTarget,false))then exit;
   if(armN>LastUnitArms)then exit;
   if(pTarget^.hits<=hits_fdead)then exit;
   if(udist<0)then udist:=point_dist_int(pAttacker^.x,pAttacker^.y,pTarget^.x,pTarget^.y);

   with pAttacker^ do
   with uid^ do
   with player^ do
   with uid_arms[armN] do
   begin
      if(aw_reload=0)then exit;

      // Weapon type requirements
      case aw_type of
wpt_resurect : if(not unit_StartResurrection(pAttacker,pTarget,true))then exit;
wpt_heal     : if(pTarget^.hits<=0)
               or(pTarget^.hits>=pTarget^.uid^.uid_MaxHits1)
               or(not pTarget^.iscomplete)
               or(pTarget^.uid^.uid_Regen_Base<0)
               then exit;
      end;

      // transportU check
      if(IsUnitRange(transportU,nil))
      or(IsUnitRange(pTarget^.transportU,nil))then exit;

      // UID and UPID requirements

      if(aw_req_uid >0)and(units_uid_c[aw_req_uid ]<=0)then exit;
      if(aw_req_upgr>0)and(upgrs_cur  [aw_req_upgr] =0)then exit;

      // requirements to attacker and some flags

      if not(pTarget^.uidi in aw_tar_uids)then exit;

      if((aw_req_flags and wpr_air   )>0)then
        if(isfly=uf_ground)or(pTarget^.isfly=uf_ground)then exit;
      if((aw_req_flags and wpr_ground)>0)then
        if(isfly=uf_fly   )or(pTarget^.isfly=uf_fly   )then exit;
      if((aw_req_flags and wpr_reload)>0)then
        if(rld>0)then exit;

      if(aw_type=wpt_directdmgZ)then
      begin
         if(not pTarget^.iscomplete)
         or(pTarget^.uid^.uid_ZombieUID =0)
         or(pTarget^.uid^.uid_ZombieHits<pTarget^.hits)
         or(pTarget^.hits<=hits_fdead)then exit;
         if (pTarget^.player^.team=team)
         and(pTarget^.hits>0)then exit;

         if((armylimit-uid_LimitUse+pTarget^.uid^.uid_LimitUse+prod_unit_Limit)>MaxPlayerLimit)then exit;
         if(uid_gen_EnergyLevel>0)then
           if((res_energyl_max-uid_gen_EnergyLevel+pTarget^.uid^.uid_gen_EnergyLevel)<=0)then exit;
         if(pTarget^.uid^.uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders)then exit;
      end;

      // requirements to target

      if((aw_tar_Flags and wtr_owner_p  )=0)and(pTarget^.playeri      =playeri      )then exit;
      if((aw_tar_Flags and wtr_owner_a  )=0)and(pTarget^.player^.team =team         )then exit;
      if((aw_tar_Flags and wtr_owner_e  )=0)and(pTarget^.player^.team<>team         )then exit;

      if((aw_tar_Flags and wtr_hits_h   )=0)and((0<pTarget^.hits)
                                      and(pTarget^.hits< pTarget^.uid^.uid_MaxHits1))then exit;
      if((aw_tar_Flags and wtr_hits_d   )=0)and(pTarget^.hits<=0                    )then exit;
      if((aw_tar_Flags and wtr_hits_a   )=0)and(pTarget^.hits =
                                                         pTarget^.uid^.uid_MaxHits1 )then exit;

      if((aw_tar_Flags and wtr_complete )=0)and(    pTarget^.iscomplete             )then exit;
      if((aw_tar_Flags and wtr_ncomplete)=0)and(not pTarget^.iscomplete             )then exit;

      if(not CheckUnitBaseFlags(pTarget,aw_tar_Flags))then exit;

      // Distance requirements
      if(aw_max_range=aw_srange)        // ranged (range)
      then awr:=udist-srange
      else
        if(aw_max_range<aw_srange)      // melee
        then awr:=udist-(uid_r+pTarget^.uid^.uid_r-aw_max_range)
        else                            // ranged
          if(aw_max_range>=aw_fsr0)     // relative srange
          then awr:=udist-(srange+(aw_max_range-aw_fsr))
          else awr:=udist-aw_max_range; // absolute range

      if(aw_max_range>=aw_srange)then
      begin
         if(pTarget^.isfly)
         then awr-=uid_arms_BonusAntiFlyRange
         else awr-=uid_arms_BonusAntiGroundRange;
         if(pTarget^.uid^.uid_isbuilding)
         then awr-=uid_arms_BonusAntiBuildingRange
         else awr-=uid_arms_BonusAntiUnitRange;
      end;
      canmove:=(speed>0)and(uo_id<>ua_hold);
      pfcheck:=(isfly)or(uid_FlyLevelLikeTarget)or(mapZone=pTarget^.mapZone);

      // mapZone check for melee

      if(awr<0)then
      begin
         if(udist>=aw_min_range)
         then unit_CheckArmForTarget:=wmove_noneed     // can attack now
         else
           if(canmove)
           then unit_CheckArmForTarget:=wmove_farther  // need move farther
           else ;                                      // target too close & cant move
      end
      else
        if(canmove)and(pfcheck)then
          if(udist<=(srange+TargetCheckSRangeBonus))or(noSRangeCheck)
          then unit_CheckArmForTarget:=wmove_closer     // need move closer
          else ;                                        // target too far & cant move
   end;
end;

function unit_target2arm(pAttacker,pTarget:PTUnit;udist:integer;LastArm:byte;action:pbyte):byte;
var i,a:byte;
begin
   unit_target2arm:=255;

   // pAttacker - attacker
   // pTarget - target

   if(not CheckUnitTeamVision(pAttacker^.player^.team,pTarget,false))then exit;

   if(pTarget^.hits<=hits_fdead)
   or(pTarget^.buffs[ub_SphereInvuln]>0)then exit;

   if(udist<0)then udist:=point_dist_int(pAttacker^.x,pAttacker^.y,pTarget^.x,pTarget^.y);
   if(LastArm>LastUnitArms)then LastArm:=LastUnitArms;
   if(action<>nil)then action^:=wmove_impassible;

   for i:=0 to LastArm do
   begin
      a:=unit_CheckArmForTarget(pAttacker,pTarget,udist,i,false,action<>nil);
      if(a=wmove_impassible)then continue;
      if(action<>nil)then action^:=a;
      unit_target2arm:=i;
      break;
   end;
end;

function unit_ArmGetFactor(pArm:PTUnitArm;pTarget:PTUnit):single;
var dmod:byte;
begin
   unit_ArmGetFactor:=1;
   with pArm^ do
     case aw_type of
     wpt_missle,
     wpt_directdmg,
     wpt_directdmgZ
                   : if(aw_impact_dmod>0)then
                       for dmod:=0 to LastDamageModFactor do
                         with g_DamageMods[aw_impact_dmod][dmod] do
                           if(dm_TargetFlags>0)then
                             if(CheckUnitBaseFlags(pTarget,dm_TargetFlags))then
                               unit_ArmGetFactor*=(dm_factor/100);
     end;
end;

function unit_ArmTarget(pAttacker,n_tarp:PTUnit;udist:integer;a_tard:pinteger;a_arm:pbyte;a_tarp:PPTUnit;a_fac:psingle):boolean;
var
n_arm:byte;
n_fac:single;
begin
   // n_tarp = next target
   // a_tarp = current target
   unit_ArmTarget:=false;
   with pAttacker^ do
   with uid^ do
   begin
      {if (isselected)
      and(n_tarp^.uidi=UID_Cacodemon)
      and(unum<>n_tarp^.unum)then writeln(unum,' ',n_tarp^.unum,' ',udist,' ',uid_r+n_tarp^.uid^.uid_r-aw_dmelee);  }

      n_arm:=unit_target2arm(pAttacker,n_tarp,udist,a_arm^,nil);

      if(n_arm>LastUnitArms)then exit;

      unit_ArmTarget:=true;

      if(n_arm>a_arm^)
      then exit
      else
        if(n_arm<a_arm^)
        then n_fac:=unit_ArmGetFactor(@uid_arms[n_arm],n_tarp)
        else
        begin
           n_fac:=unit_ArmGetFactor(@uid_arms[n_arm],n_tarp);
           with uid_arms[n_arm] do
             case aw_type of
             wpt_heal      : if(n_tarp^.hits<a_tarp^^.hits)
                             then
                             else
                             if(n_tarp^.hits>a_tarp^^.hits)
                             then exit
                             else
                               if(udist<a_tard^)
                               then
                               else exit;
             wpt_missle,
             wpt_directdmg,
             wpt_directdmgZ: case(aw_max_range<aw_srange)of
                             true : if(udist<a_tard^) // melee weapon
                                    then
                                    else exit;
                             false: if(n_fac>a_fac^)  // ranged weapon
                                    then
                                    else
                                    if(n_fac<a_fac^)
                                    then exit
                                    else
                                      if(n_tarp^.hits<a_tarp^^.hits)
                                      then
                                      else
                                      if(n_tarp^.hits>a_tarp^^.hits)
                                      then exit
                                      else
                                        if(udist<a_tard^)
                                        then
                                        else exit;
                             end
             else
               if(udist<=a_tard^) // nearest
               then
               else exit;
             end;
        end;

      a_fac^ :=n_fac;
      a_arm^ :=n_arm;
      a_tar  :=n_tarp^.unum;
      a_tard^:=udist;
      a_tarp^:=n_tarp;
   end;
end;

procedure unit_AuraEffects(pAuraSrcUnit,pTarget:PTUnit;udist:integer);
begin
   // pAuraSrcUnit - aura source
   // pTarget - target
   with pAuraSrcUnit^     do
   with uid^    do
   with player^ do
   case uidi of
UID_HAKeep,
UID_HKeep     : if(udist<srange)
               and(not pTarget^.uid^.uid_isbuilding)
               and(pTarget^.iscomplete)
               and(team<>pTarget^.player^.team)then
                  if(pTarget^.buffs[ub_DecayAura]<=fr_fpsh)and(upgrs_cur[upgr_hell_DecayAura]>0)then
                  begin
                     AddToInt(@TeamVision[pTarget^.player^.team],MinVisionTime);
                     unit_damage(pTarget,DecayAuraDamage,playeri,true);
                     pTarget^.buffs[ub_DecayAura]:=fr_fps1;
                  end;
   end;
end;

procedure unit_CaptureKeyPoint(pu:PTUnit);
var
kpi:byte;
d  :integer;
begin
   if(map_KeyPointsN>0)then
     with pu^ do
       for kpi:=0 to map_KeyPointsN-1 do
         with map_KeyPointsL[kpi] do
         begin
            d:=point_dist_int(x,y,kp_x,kp_y);
            if(kp_TeamData[MaxPlayers].kptd_Active)and(kp_RCapture>0)then
              if(d<=(kp_RCapture+uid^.uid_r))then
              begin
                 kp_LimitPlayerC[playeri     ]+=uid^.uid_LimitUse;
                 kp_LimitTeamC  [player^.team]+=uid^.uid_LimitUse;
              end;

            // update team data
            with uid^ do
              if(uid_ability_isradar)and(iscomplete)and(transformTimer<=0)then
                if(buffs[ub_Cast]>0)then
                  d:=min2i(d,point_dist_int(uo_x,uo_y,kp_x,kp_y));
            with kp_TeamData[pu^.player^.team] do
              if(d<=(kp_RCapture+srange))then
                kptd_VisTimer:=MinVisionTime;
         end;
end;

procedure unit_AllCycleServer(pu:PTUnit);
var
t_fac,uds       : single;
a_tard,uc,udi   : integer;
a_tarp,
tu_transport,tu : PTUnit;
aicode,
attack_target,
isattackable,
pushout         : boolean;
t_weap          : byte;
NearTeleport    : boolean;
NearTeleport_tu : PTUnit;
teleport_NewTaru,
teleport_NewTard: integer;
teleport_NewTar : boolean;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      a_tar   := 0;
      a_tard  := NOTSET;
      a_tarp  := nil;
      t_weap  := 255;
      t_fac   := 1;
      teleport_NewTaru:= 0;
      teleport_NewTard:= NOTSET;
      tu_transport    :=nil;
      if(StayWaitForNewTarget>0)
      then StayWaitForNewTarget-=1;

      pushout        := uid_issolid and unit_canMove(pu) and ((a_rld<=0)or uid_isbuilding);
      attack_target  := unit_canAttack(pu,false);//and(playeri=UIPlayer);
      aicode         := (state=ps_AI);//and(isselected);
      teleport_NewTar:= (not IsUnitRange(rpoint_tar,nil))and(uid_ability_isteleport);
      NearTeleport   := false;
      NearTeleport_tu:= nil;
      if(IsUnitRange(uo_tar,@NearTeleport_tu))and(not aicode)then
        if (NearTeleport_tu^.player=player)
        and(NearTeleport_tu^.hits>0)
        and(NearTeleport_tu^.uid^.uid_ability_isteleport)then
          if(NearTeleport_tu^.rld>0)
          or(not NearTeleport_tu^.iscomplete)
          or(NearTeleport_tu^.transformTimer>0)then NearTeleport:=true;

      isattackable:=false;
      if(attack_target)then
        isattackable:=unit_ArmTarget(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_fac);

      ai_Local_InitVars(pu);
      if(aicode){or(isselected)}then
      begin
         ai_Global_InitVars(pu);
         ai_Global_CollectData(pu,pu,0,nil,isattackable);
      end;
      ai_Local_CollectData(pu,pu,0,nil);

      for uc:=1 to MaxUnits do
        if(uc<>unum)then
        begin
           tu:=g_punits[uc];

           if(tu^.hits>hits_fdead)then
           begin
              uds:=point_dist_real(x,y,tu^.x,tu^.y);
              udi:=round(uds);

              tu_transport:=nil;
              IsUnitRange(tu^.transportU,@tu_transport);

              if(tu_transport=nil)then unit_detect(pu,tu,udi);

              isattackable:=false;
              if(attack_target)then
                isattackable:=unit_ArmTarget(pu,tu,udi,@a_tard,@t_weap,@a_tarp,@t_fac);

              ai_Local_CollectData(pu,tu,udi,tu_transport);
              if(aicode)then
              ai_Global_CollectData(pu,tu,udi,tu_transport,isattackable);

              if(tu^.hits>0)and(tu_transport=nil)then
              begin
                 unit_AuraEffects(pu,tu,udi);

                 if(pushout)then
                   if(uid_r<=tu^.uid^.uid_r)
                   or(tu^.speed<=0)
                   or(not tu^.iscomplete)
                   or(tu^.transformTimer>0)then
                     if(tu^.uid^.uid_issolid)and(isfly=tu^.isfly)then unit_PushFromUnit(pu,tu,uds);

                 if(NearTeleport)then
                   if (udi<srange)
                   and(tu^.playeri=playeri)
                   and(tu^.uidi=NearTeleport_tu^.uidi)
                   and(tu^.rld<NearTeleport_tu^.rld)
                   and(tu^.iscomplete)
                   and(tu^.transformTimer<=0)then
                     if((0<tu^.uo_tar)and(tu^.uo_tar<=MaxUnits)and(tu^.uo_tar=NearTeleport_tu^.uo_tar))
                     or((tu^.rpoint_x=NearTeleport_tu^.rpoint_x)and(tu^.rpoint_y=NearTeleport_tu^.rpoint_y))
                     then uo_tar:=tu^.unum;

                 if(teleport_NewTar)then
                 begin
                    udi:=point_dist_int(rpoint_x,rpoint_y,tu^.x,tu^.y)-tu^.uid^.uid_r;
                    if(udi<srange)and(udi<teleport_NewTard)then
                      if(team=tu^.player^.team)then
                      begin
                         teleport_NewTaru:=uc;
                         teleport_NewTard:=udi;
                      end;
                 end;
              end;
           end;
        end;

      unit_PushFromObstacles(pu);

      if(teleport_NewTar)and(teleport_NewTaru>0)then rpoint_tar:=teleport_NewTaru;

      if(attack_target)and(a_tard<NOTSET)then StayWaitForNewTarget:=0;

      ai_Local_Code(pu);
      if(aicode){and(playeri=LocalPlayer)}then ai_Global_Code(pu);
      {if(TestMode>0)then
        if(isselected)then
        begin
           if(aiu_alarm_d<NOTSET)then UnitsInfo_AddLine(x,y,aiu_alarm_x,aiu_alarm_y,c_red);
        end;   }

      if(buffs[ub_Damaged]>0)then GameLog_UnitAttacked(pu);
   end;
end;

procedure unit_AllCycleClient(pu:PTUnit);
var
uc,ud  : integer;
pTarget: PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
     for uc:=1 to MaxUnits do
       if(uc<>unum)then
       begin
          pTarget:=g_punits[uc];
          if(pTarget^.hits>hits_fdead)then
          begin
             ud:=point_dist_rint(x,y,pTarget^.x,pTarget^.y);

             unit_detect(pu,pTarget,ud);
             if(pTarget^.hits>0)then
               if(not IsUnitRange(pTarget^.transportU,nil))then unit_AuraEffects(pu,pTarget,ud);
          end;
       end;
end;

function unit_Load(pTransport,pPassenger:PTUnit):boolean;
begin
   unit_Load:=false;
   if(unit_CheckTransport(pTransport,pPassenger))then
     with pTransport^ do
     begin
        transportC+=pPassenger^.uid^.uid_TransportSize;
        pPassenger^.transportU:=unum;
        pPassenger^.a_tar:=0;
        if(uo_tar=pPassenger^.unum)then             uo_tar:=0;
        if(pPassenger^.uo_tar=unum)then pPassenger^.uo_tar:=0;
        unit_UnSelect(pPassenger);
        {$IFDEF _FULLGAME}
        snd_SoundPlayUnit(snd_Transport,pTransport,nil);
        {$ENDIF}
        unit_Load:=true;
     end;
end;
function unit_UnLoad(pTransport,pPassenger:PTUnit):boolean;
begin
   unit_UnLoad:=false;
   if(pTransport=nil)then
     if(not IsUnitRange(pPassenger^.transportU,@pTransport))then exit;
   with pPassenger^ do
     if(transportU=pTransport^.unum)and(pTransport^.buffs[ub_SpecPause]<=0)then
     begin
        pTransport^.buffs[ub_SpecPause]:=fr_fpsq;
        pTransport^.transportC-=uid^.uid_TransportSize;
        transportU:=0;
        x     :=pTransport^.x-g_randomr(pTransport^.uid^.uid_missileR);
        y     :=pTransport^.y-g_randomr(pTransport^.uid^.uid_missileR);
        uo_x  :=x;
        uo_y  :=y;
        uo_tar:=0;
        uo_id :=ua_amove;
        {$IFDEF _FULLGAME}
        with g_unitsVis[unum] do
        begin
           fx :=g_unitsVis[pTransport^.unum].fx;
           fy :=g_unitsVis[pTransport^.unum].fy;
           mmx:=g_unitsVis[pTransport^.unum].mmx;
           mmy:=g_unitsVis[pTransport^.unum].mmy;
        end;
        snd_SoundPlayUnit(snd_Transport,pTransport,nil);
        {$ENDIF}
        unit_UnLoad:=true;
     end;
   with pTransport^ do
     if(transportC=0)then uo_id:=ua_amove;
end;

// target units
procedure unit_uo_tar(pu:PTUnit);
var
pTar  : PTUnit;
a, w  : byte;
td,tdm: integer;
begin
   pTar:=nil;
   with pu^  do
   with uid^ do
   if(uo_tar=unum)
   then uo_tar:=0
   else
      if(IsUnitRange(uo_tar,@pTar))then
      begin
         if(IsUnitRange(pTar^.transportU,nil))
         or(not CheckUnitTeamVision(player^.team,pTar,false))then
         begin
            uo_tar:=0;
            //uo_id :=ua_amove;
            exit;
         end;

         td :=point_dist_int(x,y,pTar^.x,pTar^.y);
         if(pTar^.uid^.uid_issolid)
         then tdm:=td-      (uid_r+pTar^.uid^.uid_r)
         else tdm:=td- min2i(uid_r,pTar^.uid^.uid_r);

         if(tdm<melee_r)then
         begin
            if(unit_Load(pu,pTar))then exit;
            if(unit_Load(pTar,pu))then exit;
         end;

         if(uid_ability_isteleport)then
           if(pTar^.player^.team<>player^.team )then begin uo_tar:=0;exit; end;

         if(pTar^.uid^.uid_ability_isteleport)then
           if(unit_ability_teleport(pu,pTar,td))then exit;//team

         w:=unit_target2arm(pu,pTar,td,255,@a);
         if(w<=LastUnitArms)then
         begin
            a_tar :=uo_tar;
            uo_id :=ua_amove;
         end;

         if(tdm<=melee_r)then
         begin
            uo_x:=x;
            uo_y:=y;
            exit;
         end;

         if(player=pTar^.player)and(pTar^.isfly)then
           if(unit_CheckTransport(pTar,pu))and(not IsUnitRange(pTar^.uo_tar,nil))and(pTar^.uo_x=pTar^.x)and(pTar^.uo_y=pTar^.y)then
           begin
              pTar^.uo_x:=x;
              pTar^.uo_y:=y;
           end;

         uo_x:=pTar^.vx;
         uo_y:=pTar^.vy;
      end;
end;

function unit_TryZombification(pPhantom,pTarget:PTUnit):boolean;
var _h:single;
    _l,
    _o:byte;
    _f:boolean;
    _d,
    _z:integer;
 _zuid:PTUID;
_pvar:pinteger;
    {$IFDEF _FULLGAME}
    _s:integer;
    {$ENDIF}
begin
   unit_TryZombification:=false;

   //pPhantom - zombificator
   //pTarget - target

   if(pTarget^.uid^.uid_ZombieUID=0)then exit;
   _zuid:=@g_uids[pTarget^.uid^.uid_ZombieUID];

   with pPhantom^ do
   with uid^ do
   with player^ do
   begin
      if((armylimit-uid_LimitUse+_zuid^.uid_LimitUse+prod_unit_Limit)>MaxPlayerLimit)then exit;
      if(uid_gen_EnergyLevel>0)then
        if((res_energyl_max-uid_gen_EnergyLevel+_zuid^.uid_gen_EnergyLevel)<=0)then exit;
      if(pTarget^.uid^.uid_isbuilder)and(units_builders_e>=PlayerMaxBuilders)then exit;
   end;

   if(not pTarget^.iscomplete)
   or(pTarget^.uid^.uid_ZombieHits<pTarget^.hits)
   or(pTarget^.hits<=hits_fdead)then exit;

   {$IFDEF _FULLGAME}
   if(ServerSide)then
   {$ENDIF}
   begin
      _h:=pTarget^.hits/pTarget^.uid^.uid_MaxHits1;
      _d:=pTarget^.dir;
      _o:=pPhantom^.group;
      _f:=pTarget^.isfly;
      _z:=pTarget^.zfall;
      _l:=pTarget^.level;
      {$IFDEF _FULLGAME}
      _s:=g_unitsVis[pTarget^.unum].shadowz;
      {$ENDIF}
      _pvar:=@pPhantom^.player^.units_all_e;
      _pvar^+=1;
      unit_kill(pPhantom,true,true,false,false,true);
      _pvar^-=1;
      unit_add(pTarget^.x,pTarget^.y,pPhantom^.unum,pTarget^.uid^.uid_ZombieUID,pPhantom^.playeri,true,true,_l);
      unit_kill(pTarget,true,true,false,false,true);

      if(LastCreatedUnit>0)then
      with LastCreatedUnitP^ do
      begin
         group:=_o;
         dir  :=_d;
         isfly:=_f;
         hits := trunc(uid^.uid_MaxHits1*_h);
         zfall:=_z;
         {$IFDEF _FULLGAME}
         with g_unitsVis[unum] do
           shadowz:=_s;
         {$ENDIF}
         if(hits<=0)then
         begin
            unit_DecCounters_Kill(LastCreatedUnitP);
            unit_StartResurrection(nil,LastCreatedUnitP,false);
         end;
      end;
   end;
   unit_TryZombification:=true;
end;

function unit_attack(pAttacker:PTUnit):boolean;
var arm,a   : byte;
pTarget     : PTUnit;
damage,
upgradd,c   : integer;
fakemissile,
attackinmove: boolean;
impactX     : single;
{$IFDEF _FULLGAME}
vis_Attacker,
vis_Target  : boolean;
procedure targetEffects(now:boolean);
begin
   with pAttacker^ do
   with uid^ do
   with uid_arms[a_weap] do
   begin
      if(not IsUnitRange(pTarget^.transportU,nil))then
        if((g_tick mod fr_fpst)=0)
        or(now)then effect_add(pTarget^.vx-random(pTarget^.uid^.uid_missileR)+random(pTarget^.uid^.uid_missileR),
                               pTarget^.vy-random(pTarget^.uid^.uid_missileR)+random(pTarget^.uid^.uid_missileR),
                               draw_DefaultSpriteDepth(pTarget^.vy+1,pTarget^.isfly),aw_eid_target);

      if(aw_snd_target<>nil)then
        if((g_tick mod fr_fps1)=0)
        or(now)then snd_SoundPlayUnit(aw_snd_target,pTarget,@vis_Target);
   end;
end;
{$ENDIF}
procedure teamVisionProc;
var t:byte;
begin
   with pAttacker^ do
   with uid^ do
   with uid_arms[a_weap] do
   begin
      AddToInt(@TeamVision[pTarget^.player^.team],a_rld+1);
      AddToInt(@TeamVision[pTarget^.player^.team],MinVisionTime);
      for t:=0 to LastPlayer do
        if(pTarget^.TeamVision[t]>0)
        or(         TeamVision[t]>0)then
        begin
                     TeamVision[t]:=max2i(TeamVision[t],pTarget^.TeamVision[t]);
            pTarget^.TeamVision[t]:=TeamVision[t];
        end;
   end;
end;
function CheckShotPoint:boolean;
begin
   CheckShotPoint:=false;
   with pAttacker^ do
     with uid^ do
       with uid_arms[a_weap] do
         if(a_rld=255)
         then CheckShotPoint:= a_rld in aw_ShotPoints
         else CheckShotPoint:=(a_rld in aw_ShotPoints)and(not((a_rld+1) in aw_ShotPoints))
end;
begin
   unit_attack:=false;
   with pAttacker^ do
   begin
      if(not IsUnitRange(a_tar,@pTarget))then exit;

      {$IFDEF _FULLGAME}
      if(ServerSide)then
      begin
      {$ENDIF}
         if(a_rld<=0)then
         begin
            arm:=unit_target2arm(pAttacker,pTarget,-1,255,@a);

            if(arm>LastUnitArms)or(a=0)then
            begin
               a_tar:=0;
               StayWaitForNewTarget:=1;
               exit;
            end;

            a_weap:=arm;
         end
         else
         begin
            a:=unit_CheckArmForTarget(pAttacker,pTarget,-1,a_weap,true,false);

            if(a=0)then
            begin
               a_tar:=0;
               StayWaitForNewTarget:=1;
               exit;
            end;
         end;

         unit_attack:=true;

         upgradd:=0;

         with uid^ do
           with uid_arms[a_weap] do
             attackinmove:=(aw_req_flags and wpr_move)>0;

         case a of
         wmove_closer : begin
                           if(not attackinmove)then
                           begin
                              move_x:=pTarget^.x;
                              move_y:=pTarget^.y;
                           end;
                           exit;
                        end;
         wmove_farther: begin
                           if(not attackinmove)or(uo_bx<=0)then
                             if(x=pTarget^.x)and(y=pTarget^.y)then
                             begin
                                move_x:=x-g_randomr(2);
                                move_y:=y-g_randomr(2);
                             end
                             else
                             begin
                                move_x:=x-(pTarget^.x-x);
                                move_y:=y-(pTarget^.y-y);
                             end;
                           exit;
                        end;
         wmove_noneed : if(not attackinmove)then
                        begin
                           move_x:=x;
                           move_y:=y;
                        end;
         else
              // wmove_impassible
             StayWaitForNewTarget:=1;
             exit;
         end;
      {$IFDEF _FULLGAME}
      end
      else
      begin
         unit_attack:=true;
         if(a_weap>LastUnitArms)then exit;

         if(pTarget^.hits<=hits_fdead)then exit;

         with uid^ do
           with uid_arms[a_weap] do
             attackinmove:=(aw_req_flags and wpr_move)>0;
      end;
      {$ENDIF}

      if(not unit_canAttack(pAttacker,true))then
      begin
         move_x:=x;
         move_y:=y;
         exit;
      end;

      // attack code
      with uid^ do
      with uid_arms[a_weap] do
      begin
         {$IFDEF _FULLGAME}
         vis_Target  :=ui_CheckUnitUIPlayerVision(pTarget  ,true);
         vis_Attacker:=ui_CheckUnitUIPlayerVision(pAttacker,true);
         {$ENDIF}

         if(a_rld<=0)then
         begin
            a_shots  +=1;
            a_rld    :=aw_reload;
            a_tar_cl :=a_tar;
            a_weap_cl:=a_weap;

            if{$IFDEF _FULLGAME}(ServerSide)and{$ENDIF}(not uid_isbuilding)then
              unit_AddExp(pAttacker,aw_reload,false,false);
            if(not attackinmove)then
            begin
               if(x<>pTarget^.x)
               or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
               {$IFDEF _FULLGAME}
               if(ServerSide)then
               {$ENDIF}
               StayWaitForNewTarget:=(a_rld div order_period)+1;
            end;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,true,@vis_Attacker);
            if(vis_Target)and(aw_eid_target>0)and(aw_eid_target_onstart)then targetEffects(true);
            {$ENDIF}
            teamVisionProc;
         end;

         if(cycle_order=g_cycle_order)then teamVisionProc;

         {$IFDEF _FULLGAME}
         if(vis_Target)and(aw_eid_target>0)and(aw_eid_target_onfire)then targetEffects(false);
         {$ENDIF}

         if(CheckShotPoint)then
         begin
            if(aw_FakeShotsN=0)
            then fakemissile:=false
            else fakemissile:=(a_shots mod aw_FakeShotsN)>0;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,false,@vis_Attacker);
            if(vis_Target)and(aw_eid_target>0)and(aw_eid_target_onshot)then targetEffects(true);
            {$ENDIF}

            // Impact bonuses
            if(aw_impact_upgr>0)and(aw_impact_upgrStep>0)then upgradd:=player^.upgrs_cur[aw_impact_upgr]*aw_impact_upgrStep;
            if(level>0)and(not uid_isbuilding)then upgradd+=level*uid_LevelBonusDamage;

            impactX:=1;
            if(buffs[ub_SphereDDamage]>0)then impactX*=2;
            if(buffs[ub_Heroic       ]>0)then impactX*=1.5;

            if(not attackinmove)then
              if(x<>pTarget^.x)
              or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
            case aw_type of
wpt_missle     : if(aw_object_id>0)then
                   if(aw_object_count<0)then
                   begin
                      missile_add(pTarget^.x,pTarget^.y,vx-aw_object_count+aw_offset_x,vy-aw_object_count+aw_offset_y,a_tar,aw_object_id,playeri,isfly,pTarget^.isfly,fakemissile,upgradd,aw_impact_dmod,impactX);
                      missile_add(pTarget^.x,pTarget^.y,vx+aw_object_count+aw_offset_x,vy+aw_object_count+aw_offset_y,a_tar,aw_object_id,playeri,isfly,pTarget^.isfly,fakemissile,upgradd,aw_impact_dmod,impactX);
                   end
                   else
                     if(aw_object_count>1)then
                     begin
                        for c:=1 to aw_object_count do
                        missile_add(pTarget^.x,pTarget^.y,vx+aw_offset_x,vy+aw_offset_y,a_tar,aw_object_id,playeri,isfly,pTarget^.isfly,fakemissile,upgradd,aw_impact_dmod,impactX);
                     end
                     else missile_add(pTarget^.x,pTarget^.y,vx+aw_offset_x,vy+aw_offset_y,a_tar,aw_object_id,playeri,isfly,pTarget^.isfly,fakemissile,upgradd,aw_impact_dmod,impactX);

wpt_directdmg  : if(not fakemissile)and(aw_object_count>0)then
                 begin
                    damage:=ApplyDamageMod(pTarget,aw_impact_dmod,aw_object_count+upgradd);
                    unit_damage(pTarget,round(damage*impactX),playeri,false);
                 end;
wpt_directdmgZ : if(not fakemissile)and(aw_object_count>0)then
                   if(not unit_TryZombification(pAttacker,pTarget))then
                   begin
                      damage:=ApplyDamageMod(pTarget,aw_impact_dmod,aw_object_count+upgradd);
                      unit_damage(pTarget,round(damage*impactX),playeri,false);
                   end;
wpt_unit       : if(not fakemissile)then unit_ArmSpawnUnit(pAttacker,aw_object_id);
            else
              if{$IFDEF _FULLGAME}(ServerSide)and{$ENDIF}(not fakemissile)then
                case aw_type of
wpt_resurect    : begin
                     unit_StartResurrection(pAttacker,pTarget,false);
                     if((aw_req_flags and wpr_reload)>0)then rld:=max2i(0,aw_object_count*fr_fps1);
                  end;
wpt_heal        : begin
                     damage:=round((aw_object_count+upgradd)*impactX);
                     pTarget^.hits:=mm3i(1,pTarget^.hits+damage,pTarget^.uid^.uid_MaxHits1);
                  end;
                end;
            end;
         end;
      end;
   end;
end;

procedure unit_Production(pu:PTUnit);
procedure uXCheck(pui:pinteger);
var tu:PTUnit;
begin
   if(not IsUnitRange(pui^,@tu))
   then pui^:=pu^.unum;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      unit_end_UnitProd(pu);
      unit_end_UpgrProd(pu);

      uXCheck(@units_uid_u[               uidi     ]);
      uXCheck(@units_ucl_u[uid_isbuilding,uid_uibtn]);
    end;
end;

procedure unit_Completing(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     if(res_energyl_cur>=0)then
     begin
        if(g_cycle_order=cycle_order)and(buffs[ub_Damaged]<=0)then
        begin
           hits+=uid_ProdHitStep;
           hits+=uid_ProdHitStep*upgrs_cur[upgr_fprod_build];
           if(buffs[ub_SphereTurbo]>0)then
           hits+=uid_ProdHitStep;
        end;

        if(hits>=uid_MaxHits1){$IFDEF DEBUG0}or(test_InstaProd){$ENDIF}then
        begin
           hits:=uid_MaxHits1;
           iscomplete :=true;
           unit_IncCounters_Complete(pu);
           if(uid_gen_EnergyLevel>0)
           then energyCur_BldGens -=uid_req_EnergyLevel
           else energyCur_BldOther-=uid_req_EnergyLevel;
           res_energyl_cur +=uid_req_EnergyLevel;
           GameLog_UnitReady(pu);
        end;
     end;
end;

procedure unit_InTransportCode(pu,pTransport:PTUnit);
begin
   with pu^ do
   begin
      x:=pTransport^.x;
      y:=pTransport^.y;
      vx:=x;
      vy:=y;
      StayWaitForNewTarget:=0;
      a_tar:=0;
      TeamVision:=pTransport^.TeamVision;

      {$IFDEF _FULLGAME}
      if(ServerSide)then
      {$ENDIF}
        if(unit_GetCastingAbility(pTransport)=uab_unload)
        or(pTransport^.transportC>pTransport^.transportM)then
          if(not pTransport^.isfly)
          or(not map_IfObstacleZone(pTransport^.mapZone))then
          begin
             unit_UnLoad(pTransport,pu);
             if(pTransport^.transportC<=0)then
               pTransport^.uo_id:=ua_amove;
          end;
   end;
end;

procedure unit_UpdateRPointTar(pu:PTUnit);
var
ptar:PTUnit;
begin
   with pu^ do
   begin
      if(IsUnitRange(rpoint_tar,@ptar))then
      begin
         rpoint_x:=ptar^.vx;
         rpoint_y:=ptar^.vy;
      end;
      rpoint_x:=mm3i(1,rpoint_x,map_Size1);
      rpoint_y:=mm3i(1,rpoint_y,map_Size1);
   end;
end;

function unit_SetAbilityOrder(pu:PTUnit;aaid:byte;atar,ax,ay:integer;check:boolean):boolean;
begin
   unit_SetAbilityOrder:=false;
   with pu^ do
   with uid^ do
     with g_aids[aaid] do
       case ua_type of
       uat_notarget : begin
                      unit_SetAbilityOrder:=true;
                      if(check)then exit;
                      uo_id :=unit_Ability2Act(pu,aaid);
                      end;
       uat_point    : begin
                      unit_SetAbilityOrder:=true;
                      if(check)then exit;
                      uo_id :=unit_Ability2Act(pu,aaid);
                      uo_tar:=0;
                      uo_bx :=-1;
                      uo_by :=-1;
                      if(buffs[ub_Cast]<=0)then
                      begin
                         uo_x:=ax;
                         uo_y:=ay;
                      end;
                      end;
       uat_UnitAny,
       uat_UnitOwn,
       uat_UnitAlly,
       uat_UnitEnemy: begin
                      unit_SetAbilityOrder:=true;
                      if(check)then exit;
                      uo_id :=unit_Ability2Act(pu,aaid);
                      uo_tar:=atar;
                      uo_bx :=-1;
                      uo_by :=-1;
                      if(buffs[ub_Cast]<=0)then
                      begin
                         uo_x:=x;
                         uo_y:=y;
                      end;
                      end;
       end;
end;

function unit_SetBaseOrder(pu:PTUnit;aorder,atar,ax,ay:integer;check:boolean):boolean;
var skipOrder:boolean;
begin
   unit_SetBaseOrder:=false;
   with pu^ do
   with uid^ do
   begin
      skipOrder:=false;
      if(uid_NoOrderWhenCast)then
        if(buffs[ub_Cast]>0)then skipOrder:=true;

      case aorder of
      co_rcamove,
      co_rcmove : if(uid_HaveRallyPoint)then // right click
                  begin
                     unit_SetBaseOrder:=true;
                     if(check)then exit;
                     rpoint_tar:=atar;
                     rpoint_x  :=ax;
                     rpoint_y  :=ay;
                  end
                  else
                    if(not skipOrder)then
                      if(speed>0)or((uid_CanAttack)and(IsUnitRange(atar,nil)))then
                      begin
                         unit_SetBaseOrder:=true;
                         if(check)then exit;
                         uo_tar:=atar;
                         uo_bx :=-1;
                         uo_by :=-1;
                         if(speed>0)then
                         begin
                            uo_x:=ax;
                            uo_y:=ay;
                         end
                         else
                         begin
                            uo_x:=x;
                            uo_y:=y;
                         end;
                         if(aorder=co_rcamove)or(speed<=0)
                         then uo_id:=ua_amove
                         else uo_id:=ua_move;
                      end;
      co_stand,
      co_astand,
      co_move,
      co_amove,
      co_patrol,
      co_apatrol: if(not skipOrder)then
                  begin
                     case aorder of
                     co_astand,
                     co_amove  : if(speed<=0)and(not uid_CanAttack)then exit;
                     co_move,
                     co_stand,
                     co_patrol,
                     co_apatrol: if(speed<=0)then exit;
                     end;

                     unit_SetBaseOrder:=true;
                     if(check)then exit;
                     // uo_tar
                     case aorder of
                     co_move,
                     co_amove  : uo_tar:=atar;
                     else        uo_tar:=0;
                     end;
                     // uo_bx
                     case aorder of
                     co_patrol,
                     co_apatrol: begin
                                 uo_bx :=x;
                                 uo_by :=y;
                                 end;
                     else
                                 uo_bx :=-1;
                                 uo_by :=-1;
                     end;
                     // uo_x
                     case aorder of
                     co_stand,
                     co_astand : begin
                                 uo_x  :=x;
                                 uo_y  :=y;
                                 end;
                     else
                                 uo_x  :=ax;
                                 uo_y  :=ay;
                     end;
                     // uo_id
                     case aorder of
                     co_stand  : uo_id:=ua_hold;
                     co_move,
                     co_patrol : uo_id:=ua_move;
                     co_astand,
                     co_amove,
                     co_apatrol: uo_id:=ua_amove;
                     end;
                  end;
      end;
   end;
end;

function unit_DefaultUOMove(pu:PTUnit):boolean;
begin
   unit_DefaultUOMove:=false;
   with pu^ do
   begin
      if(uo_bx>=0)then // patrol
      begin
         uo_tar:=0;
         if(x=uo_x)and(y=uo_y)then
         begin
            uo_x :=uo_bx;
            uo_bx:=x;
            uo_y :=uo_by;
            uo_by:=y;
         end;
      end
      else
      begin
         unit_uo_tar(pu);
         unit_DefaultUOMove:=(x=uo_x)and(y=uo_y);
      end;

      uo_x:=mm3i(1,uo_x,map_Size1);
      uo_y:=mm3i(1,uo_y,map_Size1);
      move_x:=uo_x;
      move_y:=uo_y;
   end;
end;

function unit_AbilityCheck(pCaster:PTUnit;aid:byte;liteCheck:boolean):byte;
begin
   unit_AbilityCheck:=lmt_Invalid_Order;

   with pCaster^ do
   with uid^ do
   begin
      // HAVE ABILITY
      if(hits<=0)
      or(not iscomplete)
      or(transformTimer>0)
      or(aid=0)then exit;

      with g_aids[aid] do
        if(ua_type=uat_none)then exit;

      if not(aid in player^.a_ability)then exit;

      case aid of
      uab_Unload,
      uab_UnloadTo : if(transportM<=0)then exit;
      else
        if (uid_ability1<>aid)
        and(uid_ability2<>aid)
        and(uid_ability3<>aid)then exit;

        if not(aid in player^.a_ability)then exit;
      end;

      unit_AbilityCheck:=0;
      if(liteCheck)then exit;

      // CAN CAST ABILITY
      with player^ do
      with g_aids[aid] do
      begin
         if( ua_reload       >0)and(rld>0)then unit_AbilityCheck:=lmt_ability_reload;
         if((ua_req_uid      >0)and(units_uid_c[ua_req_uid ]   <=0))
         or((ua_req_upgr     >0)and(upgrs_cur  [ua_req_upgr]   <=0))then unit_AbilityCheck:=lmt_Req_Common;
         if( ua_req_HellPower>0)and(ua_req_HellPower>res_HellPower )then unit_AbilityCheck:=lmt_Req_HellPower;
         if( ua_req_UACLoot  >0)and(ua_req_UACLoot  >res_UACLoot   )then unit_AbilityCheck:=lmt_Req_UACLoot;
         if( ua_type=uat_passive)then exit;
      end;

      if(unit_AbilityCheck>0)then exit;

      case aid of
      uab_HellCCLand,
      uab_HellCCLandTo,
      uab_UACCCLand,
      uab_UACCCLandTo      : if(rld>0)then unit_AbilityCheck:=lmt_ability_reload;

      uab_HEyeVision       : unit_AbilityCheck:=unit_ability_HellVision   (pCaster,0        ,true );
      uab_HEyeSpawn        : unit_AbilityCheck:=unit_ability_SpawnEvilEye (pCaster,0,0      ,true );

      uab_SphereSoul       : unit_AbilityCheck:=unit_ability_SphereSoul   (pCaster,0        ,true );
      uab_SphereInvis      : unit_AbilityCheck:=unit_ability_SphereInvis  (pCaster,0        ,true );
      uab_SphereInvuln     : unit_AbilityCheck:=unit_ability_SphereInvuln (pCaster,0        ,true );

      uab_SphereRDamage    : unit_AbilityCheck:=unit_ability_SphereRDamage(pCaster,0        ,true );
      uab_SphereDDamage    : unit_AbilityCheck:=unit_ability_SphereDDamage(pCaster,0        ,true );
      uab_SphereTurbo      : unit_AbilityCheck:=unit_ability_SphereTurbo  (pCaster,0        ,true );

      uab_UACGeneral       : unit_AbilityCheck:=unit_ability_UACGeneral   (pCaster,0        ,true );
      uab_Bribe            : unit_AbilityCheck:=unit_ability_Bribe        (pCaster,0  ,true ,true );
      uab_Hack             : unit_AbilityCheck:=unit_ability_Bribe        (pCaster,0  ,false,true );

      uab_HTowerBlink      : unit_AbilityCheck:=unit_ability_HTowerBlink  (pCaster,x,y      ,true );
      uab_HKeepShift       : unit_AbilityCheck:=unit_ability_HKeepBlink   (pCaster,x,y      ,true );

      uab_UACStrike        : unit_AbilityCheck:=unit_ability_UACStrike    (pCaster,x,y      ,true );
      uab_UACScan          : unit_AbilityCheck:=unit_ability_UACScan      (pCaster,x,y      ,true );

      uab_Unload,
      uab_UnloadTo         : if(transportC=0)
                             or(transportM=0)then unit_AbilityCheck:=lmt_Invalid_Order;

      uab_ToHAKeep         : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HAKeep         ,true);
      uab_ToHACommandCenter: unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HACommandCenter,true);
      uab_ToHGate          : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HGate          ,true);
      uab_ToHPools         : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HPools         ,true);
      uab_ToHBarracks      : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HBarracks      ,true);
      uab_ToHSymbol2       : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HSymbol2       ,true);
      uab_ToHSymbol3       : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HSymbol3       ,true);
      uab_ToHSymbol4       : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_HSymbol4       ,true);

      uab_ToUACommandCenter: unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UACommandCenter,true);
      uab_ToUBarracks      : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UBarracks      ,true);
      uab_ToUFactory       : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UFactory       ,true);
      uab_ToUWeaponFactory : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UWeaponFactory ,true);
      uab_ToUGenerator2    : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UGenerator2    ,true);
      uab_ToUGenerator3    : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UGenerator3    ,true);
      uab_ToUGenerator4    : unit_AbilityCheck:=unit_TransformStart(pCaster,uid_UGenerator4    ,true);
      uab_ToUAGTurret      : unit_AbilityCheck:=unit_morph(pCaster,uid_UGTurret ,false,-2,level,true);
      uab_ToUAATurret      : unit_AbilityCheck:=unit_morph(pCaster,uid_UATurret ,false,-2,level,true);
      uab_ToUACDron        : unit_AbilityCheck:=unit_morph(pCaster,uid_UACDron  ,false,-2,0    ,true);

      uab_LvlUpURadar      : unit_AbilityCheck:=unit_AddExp(pCaster,0,true,true);
      uab_LvlUpURMStation  : unit_AbilityCheck:=unit_AddExp(pCaster,0,true,true);
      end;
   end;
end;

function unit_AbilityExec(pCaster:PTUnit;aid:byte):byte;
var pTarget:PTUnit;
begin
   with pCaster^ do
   with uid^ do
   begin
      unit_AbilityExec:=unit_AbilityCheck(pCaster,aid,false);

      with g_aids[aid] do
      begin
         if(unit_AbilityExec>0)
         or(ua_type=uat_passive)then
         begin
            uo_id:=ua_amove;
            exit;
         end;
         case ua_type of
         uat_UnitAny,
         uat_UnitOwn,
         uat_UnitAlly,
         uat_UnitEnemy : begin
                            pTarget:=nil;
                            unit_AbilityExec:=lmt_invalid_Target;
                            if(IsUnitRange(uo_tar,@pTarget))then
                              if(ability_CheckTarget(aid,pCaster^.player,pTarget^.player))then
                                unit_AbilityExec:=0;
                            if(unit_AbilityExec>0)then
                            begin
                               GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y);
                               unit_OrderClear(pCaster,ua_amove);
                               exit;
                            end;
                         end;
         end;
      end;

      with g_aids[aid] do
      case aid of
      uab_Recall         : begin
                              unit_AbilityExec:=unit_ability_Recall(pCaster,uo_tar,NOTSET,false);
                              unit_OrderClear(pCaster,ua_amove);
                              if(unit_AbilityExec>0)
                              then GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y);
                           end;
      uab_UACScan,
      uab_UACStrike,
      uab_SphereSoul,
      uab_SphereInvis,
      uab_SphereInvuln,
      uab_SphereRDamage,
      uab_SphereDDamage,
      uab_SphereTurbo,
      uab_UACGeneral,
      uab_Bribe,
      uab_Hack,
      uab_HEyeVision,
      uab_HEyeSpawn,
      uab_HTowerBlink    : begin
                              case aid of
                              uab_UACScan         : unit_AbilityExec:=unit_ability_UACScan      (pCaster,uo_x,uo_y      ,false);
                              uab_UACStrike       : unit_AbilityExec:=unit_ability_UACStrike    (pCaster,uo_x,uo_y      ,false);
                              uab_SphereSoul      : unit_AbilityExec:=unit_ability_SphereSoul   (pCaster,uo_tar         ,false);
                              uab_SphereInvis     : unit_AbilityExec:=unit_ability_SphereInvis  (pCaster,uo_tar         ,false);
                              uab_SphereInvuln    : unit_AbilityExec:=unit_ability_SphereInvuln (pCaster,uo_tar         ,false);
                              uab_SphereRDamage   : unit_AbilityExec:=unit_ability_SphereRDamage(pCaster,uo_tar         ,false);
                              uab_SphereDDamage   : unit_AbilityExec:=unit_ability_SphereDDamage(pCaster,uo_tar         ,false);
                              uab_SphereTurbo     : unit_AbilityExec:=unit_ability_SphereTurbo  (pCaster,uo_tar         ,false);
                              uab_UACGeneral      : unit_AbilityExec:=unit_ability_UACGeneral   (pCaster,uo_tar         ,false);
                              uab_Bribe           : unit_AbilityExec:=unit_ability_Bribe        (pCaster,uo_tar   ,false,false);
                              uab_Hack            : unit_AbilityExec:=unit_ability_Bribe        (pCaster,uo_tar   ,true ,false);
                              uab_HEyeVision      : unit_AbilityExec:=unit_ability_HellVision   (pCaster,uo_tar         ,false);
                              uab_HEyeSpawn       : unit_AbilityExec:=unit_ability_SpawnEvilEye (pCaster,uo_x,uo_y      ,false);
                              uab_HTowerBlink     : unit_AbilityExec:=unit_ability_HTowerBlink  (pCaster,uo_x,uo_y      ,false);
                              end;
                              uo_id:=ua_amove;
                              if(unit_AbilityExec>0)
                              then GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y)
                              else
                              begin
                                 rld:=ua_reload;
                                 if(ua_rldDec_level>0)then rld:=max2i(0,rld-(ua_rldDec_level*level));
                                 player^.res_HellPower-=ua_req_HellPower;
                                 player^.res_UACLoot  -=ua_req_UACLoot;
                              end;
                           end;
      uab_HKeepShift     : begin
                              unit_AbilityExec:=unit_ability_HKeepBlink(pCaster,uo_x,uo_y,false);
                              unit_OrderClear(pCaster,ua_amove);
                              if(unit_AbilityExec>0)
                              then GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y)
                              else
                                if(ua_req_upgr>0)then player^.upgrs_cur[ua_req_upgr]-=1;
                           end;
      uab_SpawnLost      : begin
                              unit_AbilityExec:=unit_ability_SpawnLost(pCaster,false);
                              uo_id:=ua_amove;
                              if(unit_AbilityExec>0)
                              then GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y);
                           end;
      uab_SpawnLostTo    : begin
                              uo_tar:=0;
                              uo_bx :=-1;
                              uo_by :=-1;
                              move_x:=x;
                              move_y:=y;
                              // spawn lost to uo_x,uo_y
                              unit_ability_SpawnLost(pCaster,false);
                           end;

      uab_Unload         : begin
                              uo_tar:=0;
                              unit_DefaultUOMove(pCaster);
                              // Check obstacle zone??????
                           end;
      uab_UnloadTo       : begin
                              uo_tar:=0;
                              uo_bx :=-1;
                              uo_by :=-1;
                              move_x:=uo_x;
                              move_y:=uo_y;
                              if(x=uo_x)and(y=uo_y)then
                              begin
                                 uo_id:=unit_Ability2Act(pCaster,uab_Unload);
                                 if(uo_id=0)then unit_OrderClear(pCaster,ua_amove);
                              end;
                           end;

      uab_HellCCLand,
      uab_UACCCLand      : begin
                              if(buffs[ub_AltMode]>0)
                              then buffs[ub_AltMode]:=0
                              else buffs[ub_AltMode]:=ub_infinity;
                              unit_OrderClear(pCaster,ua_amove);
                           end;
      uab_HellCCLandTo,
      uab_UACCCLandTo    : begin
                              uo_tar:=0;
                              uo_bx :=-1;
                              uo_by :=-1;
                              if(zfall<>0)then
                              begin
                                 move_x:=x;
                                 move_y:=y;
                              end
                              else
                                if(buffs[ub_AltMode]>0)then
                                begin
                                   move_x:=uo_x;
                                   move_y:=uo_y-fly_hz;
                                   if(x=move_x)and(y=move_y)then
                                   begin
                                      buffs[ub_AltMode]:=0;
                                      unit_OrderClear(pCaster,ua_amove);
                                   end;
                                end
                                else
                                  if(x=uo_x)and(y=uo_y)
                                  then unit_OrderClear(pCaster,ua_amove)
                                  else buffs[ub_AltMode]:=ub_infinity;
                           end;

      uab_ToHAKeep,
      uab_ToHACommandCenter,
      uab_ToHGate,
      uab_ToHPools,
      uab_ToHBarracks,
      uab_ToHSymbol2,
      uab_ToHSymbol3,
      uab_ToHSymbol4,

      uab_ToUACommandCenter,
      uab_ToUBarracks,
      uab_ToUFactory,
      uab_ToUWeaponFactory,
      uab_ToUGenerator2,
      uab_ToUGenerator3,
      uab_ToUGenerator4,
      uab_ToUAGTurret,
      uab_ToUAATurret,
      uab_ToUACDron,
      uab_LvlUpURadar,
      uab_LvlUpURMStation: begin
                              case aid of
                              uab_ToHAKeep         : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HAKeep         ,false);
                              uab_ToHACommandCenter: unit_AbilityExec:=unit_TransformStart(pCaster,uid_HACommandCenter,false);
                              uab_ToHGate          : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HGate          ,false);
                              uab_ToHPools         : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HPools         ,false);
                              uab_ToHBarracks      : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HBarracks      ,false);
                              uab_ToHSymbol2       : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HSymbol2       ,false);
                              uab_ToHSymbol3       : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HSymbol3       ,false);
                              uab_ToHSymbol4       : unit_AbilityExec:=unit_TransformStart(pCaster,uid_HSymbol4       ,false);

                              uab_ToUACommandCenter: unit_AbilityExec:=unit_TransformStart(pCaster,uid_UACommandCenter,false);
                              uab_ToUBarracks      : unit_AbilityExec:=unit_TransformStart(pCaster,uid_UBarracks      ,false);
                              uab_ToUFactory       : unit_AbilityExec:=unit_TransformStart(pCaster,uid_UFactory       ,false);
                              uab_ToUWeaponFactory : unit_AbilityExec:=unit_TransformStart(pCaster,uid_UWeaponFactory ,false);
                              uab_ToUGenerator2    : unit_AbilityExec:=unit_TransformStart(pCaster,uid_UGenerator2    ,false);
                              uab_ToUGenerator3    : unit_AbilityExec:=unit_TransformStart(pCaster,uid_UGenerator3    ,false);
                              uab_ToUGenerator4    : unit_AbilityExec:=unit_TransformStart(pCaster,uid_UGenerator4    ,false);
                              uab_ToUAGTurret      : unit_AbilityExec:=unit_morph(pCaster,uid_UGTurret ,false,-2,level,false);
                              uab_ToUAATurret      : unit_AbilityExec:=unit_morph(pCaster,uid_UATurret ,false,-2,level,false);
                              uab_ToUACDron        : unit_AbilityExec:=unit_morph(pCaster,uid_UACDron  ,false,-2,0    ,false);

                              uab_LvlUpURadar      : unit_AbilityExec:=unit_AddExp(pCaster,0,true,false);
                              uab_LvlUpURMStation  : unit_AbilityExec:=unit_AddExp(pCaster,0,true,false);
                              end;

                              unit_OrderClear(pCaster,ua_amove);
                              if(unit_AbilityExec>0)
                              then GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y)
                              else
                              begin
                                 player^.res_HellPower-=ua_req_HellPower;
                                 player^.res_UACLoot  -=ua_req_UACLoot;
                              end;
                           end;

      uab_ToUATurretTo,
      uab_ToUGTurretTo   : begin
                              uo_tar:=0;
                              uo_bx :=-1;
                              uo_by :=-1;
                              move_x:=uo_x;
                              move_y:=uo_y;
                              //if(x=uo_x)and(y=uo_y)then
                              if(max2i(abs(x-uo_x),abs(y-uo_y))<speed)then
                              begin
                                 unit_SetXY(pCaster,uo_x,uo_y,mvxy_none);
                                 case aid of
                                 uab_ToUATurretTo: unit_AbilityExec:=unit_morph(pCaster,uid_UATurret,false,-2,0,false);
                                 uab_ToUGTurretTo: unit_AbilityExec:=unit_morph(pCaster,uid_UGTurret,false,-2,0,false);
                                 end;
                                 unit_OrderClear(pCaster,ua_amove);
                                 if(unit_AbilityExec>0)
                                 then GameLog_ReqMsg(playeri,aid,lmt_argt_ability,unit_AbilityExec,x,y);
                              end;
                           end;
      else unit_OrderClear(pCaster,ua_amove);
      end;
   end;
end;

procedure unit_Order(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   case uo_id of
   ua_hold     : begin
                    uo_tar:=0;
                    uo_x  :=x;
                    uo_y  :=y;
                    uo_bx :=-1;
                    uo_by :=-1;
                    move_x:=uo_x;
                    move_y:=uo_y;
                 end;
   ua_ability1 : unit_AbilityExec(pu,uid_ability1);
   ua_ability2 : unit_AbilityExec(pu,uid_ability2);
   ua_ability3 : unit_AbilityExec(pu,uid_ability3);
   else
      // ua_move
      // ua_amove

      // default move to uo vars
      if(unit_DefaultUOMove(pu))then
        if(unit_GetCastingAbility(pu)<>uab_unload)
        then uo_id:=ua_amove
        else
          if(transportC<=0)then uo_id:=ua_amove;

      // attack
      if(uo_id=ua_amove)then
      begin
         unit_attack(pu);
         if(StayWaitForNewTarget>0)then
         begin
            move_x:=x;
            move_y:=y;
         end;
      end
      else StayWaitForNewTarget:=0;
   end;
end;

procedure unit_BehaviorSpecial(pu:PTUnit);
var tu:PTUnit;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      case uidi of
      UID_HCommandCenter,
      UID_HACommandCenter,
      UID_UCommandCenter,
      UID_UACommandCenter   : if(not iscomplete)or(transformTimer>0)then
                              begin
                                 speed:=0;
                                 isfly:=uf_ground;
                              end
                              else
                                if(buffs[ub_AltMode]>0)then
                                begin
                                   if(isfly<>uf_fly)then
                                   begin
                                      {$IFDEF _FULLGAME}
                                      snd_SoundPlayUnit(snd_CCenterLiftUp ,pu,nil);
                                      if(ServerSide)then
                                      {$ENDIF}
                                      zfall-=fly_hz;

                                      isfly:=uf_fly;
                                   end;
                                   speed:=uid_MSpeed_Base;
                                end
                                else
                                begin
                                   if(isfly<>uf_ground)then
                                   begin
                                      {$IFDEF _FULLGAME}
                                      snd_SoundPlayUnit(snd_Transport,pu,nil);
                                      if(ServerSide)then
                                      {$ENDIF}
                                      begin
                                         zfall+=fly_hz;
                                         unit_OrderClear(pu,255);
                                      end;
                                      isfly:=uf_ground;
                                   end;
                                   speed:=0;

                                   if{$IFDEF _FULLGAME}(ServerSide)and{$ENDIF}(zfall<>0)then
                                     if(CheckCollisionR(x,y+zfall,uid_r,unum,uid_isbuilding,true,255,pu)<>cbr_no)then
                                     begin
                                        buffs[ub_AltMode]:=ub_infinity;
                                        GameLog_ReqMsg(playeri,uid_ability1,lmt_argt_ability,lmt_ability_BadPlace,x,y);
                                     end;
                                end;
      end;
      if(uid_FlyLevelLikeTarget)then
        if(not iscomplete)or(transformTimer>0)
        then isfly:=uid_isfly
        else
        begin
           tu:=nil;
           if(IsUnitRange(a_tar,@tu))and(a_rld>0)then buffs[ub_SpecPause]:=fr_fpsh;
           if(buffs[ub_PainState]<=0)then
             if(buffs[ub_SpecPause]>0)and(tu<>nil)then isfly:=tu^.isfly else isfly:=uid_isfly;
        end;
   end;
end;

procedure unit_BehaviorBase(pu:PTUnit);
var
pTransport:PTUnit;
i         :integer;
begin
   pTransport:=nil;
   with pu^ do
   with uid^ do
   with player^ do
     if(IsUnitRange(pu^.transportU,@pTransport))
     then unit_InTransportCode(pu,pTransport)
     else
       {$IFDEF _FULLGAME}
       if(not ServerSide)then // CLIENT-SIDE
       begin
          // rallly point
          unit_UpdateRPointTar(pu);

          // special states
          unit_BehaviorSpecial(pu);

          // attack
          if(iscomplete)and(transformTimer<=0)then
            unit_attack(pu);

          unit_CaptureKeyPoint(pu);

          if(cycle_order=g_cycle_order)then
          begin
             if(move_px<>x)or(move_py<>y)then
             begin
                move_px:=x;
                move_py:=y;
             end;
             unit_AllCycleClient(pu);
          end;
       end
       else
       {$ENDIF}
       begin                   // SERVER-SIDE
          // rallly point
          unit_UpdateRPointTar(pu);

          // special states
          unit_BehaviorSpecial(pu);

          // building and prod
          if(not iscomplete)
          then unit_Completing(pu)
          else
            if(transformTimer>0)then
            begin
               if(buffs[ub_SphereTurbo]>0)
               then transformTimer-=2
               else transformTimer-=1;

               if(transformTimer<1){$IFDEF DEBUG0}or(test_InstaProd){$ENDIF} then transformTimer:=1;
               if(transformTimer=1)then
               begin
                  energyCur_transforms-=g_uids[transformUID].uid_req_EnergyLevel;
                  res_energyl_cur     +=g_uids[transformUID].uid_req_EnergyLevel;
                  transformTimer:=0;
                  if(transformUID<>uidi)
                  then unit_morph(pu,transformUID,true,integer.MaxValue,0,false,false)
                  else
                    if(level<LastUnitLevel)then
                      unit_morph(pu,transformUID,true,integer.MaxValue,level+1,false,false);
                  GameLog_UnitReady(pu);
               end;
            end
            else
            begin
               //if(state=ps_AI)then ai_Global_ScoutPick(pu);

               // unit&upgrades production
               unit_Production(pu);

               // order exec
               unit_Order(pu);

               // move
               unit_move(pu);

               // REGENERATION
               if(cycle_order=g_cycle_regen)then
                 case(uid_Regen_Base>=0)of
                 true : if(hits<uid_MaxHits1)then
                        begin
                           i:=uid_Regen_Base;
                           if(uid_Regen_upgr>0)then
                             i+=integer(upgrs_cur[uid_Regen_upgr])*BaseRegen1;
                           if(buffs[ub_SphereTurbo]>0)then i*=2;

                           if(i>0)then
                           begin
                              hits+=i;
                              if(hits>uid_MaxHits1)then hits:=uid_MaxHits1;
                           end;
                        end;
                 false: if(hits>0)then
                        begin
                           hits+=uid_Regen_Base;
                           if(hits<=0)then
                           begin
                              hits:=1;
                              unit_kill(pu,false,true,false,true,true);
                              exit;
                           end;
                        end;
                 end;
               if(buffs[ub_SphereSoul]>0)then
               begin
                  hits+=soul_regen;
                  if(hits>uid_MaxHits1)then hits:=uid_MaxHits1;
               end;
            end;

          unit_CaptureKeyPoint(pu);

          if(cycle_order=g_cycle_order)then
          begin
             u_royal_cd:=NOTSET;
             u_royal_d :=NOTSET;
             if(map_scenario=mc_royale)then
             begin
                u_royal_cd:=point_dist_int(x,y,map_Sizeh,map_Sizeh);
                u_royal_d :=g_royal_r-u_royal_cd;
                if(u_royal_d<uid_missileR)then
                begin
                   unit_kill(pu,false,false,true,true,false);
                   exit;
                end;
             end;

             if(uid_isbuilding)and(res_energyl_max<=0)then
             begin
                unit_kill(pu,false,false,true,false,true);
                exit;
             end;

             unit_AllCycleServer(pu);
          end;
       end;
end;


procedure GameObjectsCode;
var
u : integer;
pu: PTUnit;
begin
   // units cycle
   for u:=1 to MaxUnits do
   begin
      pu:=g_punits[u];
      with pu^ do
        if(hits>hits_dead)then
        begin
           if(cycle_order=g_cycle_order)then
             unit_TeamReveal(pu,false);

           unit_BaseTimers(pu);

           if(hits>0)then
           begin
              if(cycle_order=g_cycle_order)then
                unit_Bonuses(pu);
              unit_BehaviorBase(pu);
           end
           else unit_death(pu);

           unit_MoveVis(pu);
        end;
   end;

   // missiles cycle
   missile_Cycle;
end;

////////////////////////////////////////////////////////////////////////////////

