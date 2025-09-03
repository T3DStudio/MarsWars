

procedure unit_death(pu:PTUnit);
var tu  : PTUnit;
    uc  : integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
    if(hits>dead_hits)then
    begin
       if(cycle_order=g_cycle_order)then
       begin
          for uc:=1 to MaxUnits do
           if(uc<>unum)then
           begin
              tu:=@g_units[uc];
              if(tu^.hits>dead_hits)then unit_detect(pu,tu,point_dist_rint(x,y,tu^.x,tu^.y));
           end;
       end;

       if(buffs[ub_Resurect]<=0)then
       begin
          if(ServerSide)or(hits>fdead_hits)then hits-=1;
          {$IFDEF _FULLGAME}
          if(cycle_order=g_cycle_order)and(fsr>1)then fsr-=1;
          {$ENDIF}

          if(ServerSide)then
           if(hits<=dead_hits)then unit_remove(pu);
       end
       else
        if(ServerSide)then
        begin
           if(hits<-80)then hits:=-80;
           hits+=1;
           if(hits>=0)then
           begin
              zfall:=0;
              uo_id:=ua_amove;
              uo_x :=x;
              uo_y :=y;
              dir  :=270;
              hits :=uid_MaxHits1;
              buffs[ub_Resurect]:=0;
              buffs[ub_Summoned]:=fr_fps1;
              {$IFDEF _FULLGAME}
              unit_CalcFogR(pu);
              effect_UnitSummon(pu,nil);
              {$ENDIF}
           end;
        end;
    end;
end;

procedure unit_damage(pu:PTUnit;damage:integer;pl:byte;IgnoreArmor:boolean);
var armor:integer;
begin
   with pu^ do
   if(buffs[ub_Invuln]<=0)and(hits>0)then
   with uid^ do
   begin
      armor:=0;

      if(iscomplete)and(not IgnoreArmor)then
      begin
         armor:=0;//_base_armor;
         with player^ do
           if(uid_isbuilding)
           then armor+=integer(upgr[uid_upgr_Armor]+upgr[upgr_race_armor_build[uid_race]])*UpgradeBuildArmorBonus
           else
             if(uid_ismech)
             then armor+=integer(upgr[uid_upgr_Armor]+upgr[upgr_race_armor_mech[uid_race]])*UpgradeUnitArmorBonus
             else armor+=integer(upgr[uid_upgr_Armor]+upgr[upgr_race_armor_bio [uid_race]])*UpgradeUnitArmorBonus;

         if(level>0)then armor+=level*uid_LevelBonusArmor;

         damage-=armor;
      end;

      if(damage<=0)then damage:=1;

      if(hits<=damage)then
      begin
         if(ServerSide)
         then unit_kill(pu,false,(hits-damage)<=uid_FastDeathHits,true,false,false);
      end
      else
      begin
         buffs[ub_Damaged]:=fr_fps2;

         if(ServerSide)
         then hits-=damage
         else
           if(buffs[ub_Pain]<=0)then exit;

         if(not uid_isbuilding)and(not uid_ismech)then
           if(uid_PainC>0)then
           begin
              if(pains>0)then pains-=1;
              if(pains=0)then
              begin
                 pains:=uid_PainC;

                 buffs[ub_Pain]:=max2i(pain_time,a_rld);

                 with player^ do
                   if(uid_race=r_hell)then
                     if(upgr[upgr_hell_PainFactor]>0)then pains+=uid_PainCUpgrStep*upgr[upgr_hell_PainFactor];
                 if(level>0)then pains+=level*2;

                 {$IFDEF _FULLGAME}
                 effect_UnitPain(pu,nil);
                 {$ENDIF}
              end;
          end;
      end;
   end;
end;

function unit_morph(pu:PTUnit;ouid:byte;obld:boolean;bhits:integer;ulevel:byte;check:boolean):cardinal;
var puid   : PTUID;
aTeamDetection,
aTeamVision: TUnitVisionData;
aselect    : boolean;
auo_x,
auo_y      : integer;
begin
   unit_morph:=0;
   with pu^     do
   with player^ do
   begin
      if(hits<=0)then
      begin
         unit_morph:=ureq_other;
         exit;
      end;

      puid  :=@g_uids[ouid];
      aTeamDetection:=TeamDetection;
      aTeamVision   :=TeamVision;
      aselect:=isselected;
      auo_x  :=uo_x;
      auo_y  :=uo_y;

      if(a_units[ouid]<=0)then
      begin
         unit_morph:=ureq_max;
         exit;
      end;
      if((armylimit-pu^.uid^.uid_LimitUse+puid^.uid_LimitUse+uprodl)>MaxPlayerLimit)then
      begin
         unit_morph:=ureq_armylimit;
         exit;
      end;
      if(not obld)or(puid^.uid_isbuilding)then
        if(menergy<=0)then
        begin
           unit_morph:=ureq_energy;
           exit;
        end;
      if(not obld)then
      begin
         if(ukfly)or(transportC>0)then
         begin
            unit_morph:=ureq_other;
            exit;
         end;
         if((cenergy-uid^.uid_EnergyGen)<puid^.uid_EnergyReq)or(menergy<=uid^.uid_EnergyGen)then
         begin
            unit_morph:=ureq_energy;
            exit;
         end;
         if(CheckCollisionR(x,y,puid^.uid_r,unum,puid^.uid_isbuilding,puid^.uid_isfly,true )>0)then
         begin
            unit_morph:=ureq_place;
            exit;
         end;
      end;

      if(check)then exit;

      vx:=x;
      vy:=y;
      unit_kill(pu,true,true,false,false,true);
      unit_add(x,y,unum,ouid,playeri,obld,true,ulevel);
   end;

   if(bhits<0)then bhits:=puid^.uid_MaxHits1 div abs(bhits);
   if(LastCreatedUnitP<>nil)then
     with LastCreatedUnitP^ do
     begin
        if(UnitHaveRPoint(uidi))then
        begin
           uo_x:=auo_x;
           uo_y:=auo_y;
        end;
        TeamDetection:=aTeamDetection;
        TeamVision:=aTeamVision;
        if(bhits>0)then
          if(not iscomplete)then hits:=mm3i(1,bhits,puid^.uid_MaxHits1-1);
        if(aselect)then unit_select(LastCreatedUnitP);
     end;
end;

procedure unit_push(pu,tu:PTUnit;uds:single);
var t:single;
   ud:integer;
shortCollision,
dirTurn:boolean;
begin
   // pu from tu
   with pu^ do
   with uid^ do
   begin
      t :=uds;
      shortCollision:=(pu^.playeri=tu^.playeri)and((tu^.speed<=0)or(not tu^.iscomplete));
      if(shortCollision)
      then uds-=tu^.uid^.uid_r
      else uds-=tu^.uid^.uid_r+uid_r;
      ud:=round(uds);

      dirTurn:=(a_rld<=0)and((tu^.speed<=0)or(not tu^.iscomplete)or(tu^.uid^.uid_isbuilding)or((tu^.x=tu^.uo_x)and(tu^.y=tu^.uo_y)) );

      if(uds<0)then
      begin
         AddToInt(@tu^.TeamVision[player^.team],MinVisionTime);

         if((tu^.x=x)and(tu^.y=y))then
         begin
            case g_random(4) of
            0: unit_SetXY(pu,x-ud,y   ,mvxy_none);
            1: unit_SetXY(pu,x+ud,y   ,mvxy_none);
            2: unit_SetXY(pu,x   ,y-ud,mvxy_none);
            3: unit_SetXY(pu,x   ,y+ud,mvxy_none);
            end;
         end
         else unit_SetXY(pu,x+round(uds*(tu^.x-x)/t)+g_randomr(2),
                            y+round(uds*(tu^.y-y)/t)+g_randomr(2),mvxy_none);

         vstp+=round(uds/speed*UnitStepTicks);

         if(dirTurn)then
           if(vx<>x)or(vy<>y)then
             if(shortCollision)
             then dir:=dir_MOD360(dir-(                    dir_diff(dir,point_dir(vx,vy,x,y))   div 2 ))
             else dir:=dir_MOD360(dir-( min2i(90,max2i(-90,dir_diff(dir,point_dir(vx,vy,x,y)))) div 2 ));

         if(tu^.x=tu^.uo_x)and(tu^.y=tu^.uo_y)and(uo_tar=0)then
         begin
            ud:=point_dist_rint(uo_x,uo_y,tu^.x,tu^.y)-uid_r-tu^.uid^.uid_r;
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
i,
udi:integer;
begin
   with pu^ do
   with uid^ do
   begin
      t  :=point_dist_real(x,y,pObstacle^.o_x,pObstacle^.o_y);
      uds:=t-(uid_r+pObstacle^.o_r);
      udi:=round(uds);

      if(uds>=0)then exit;

      if((pObstacle^.o_x=x)and(pObstacle^.o_y=y))then
      begin
         case g_random(4) of
         0: unit_SetXY(pu,x-udi,y   ,mvxy_none);
         1: unit_SetXY(pu,x+udi,y   ,mvxy_none);
         2: unit_SetXY(pu,x   ,y-udi,mvxy_none);
         3: unit_SetXY(pu,x   ,y+udi,mvxy_none);
         end;
      end
      else unit_SetXY(pu,x+round(udi*(pObstacle^.o_x-x)/t)+g_randomr(2),
                         y+round(udi*(pObstacle^.o_y-y)/t)+g_randomr(2),mvxy_none);

      vstp+=round(uds/speed*UnitStepTicks);

      if(a_rld<=0)then
        if(vx<>x)or(vy<>y)then dir:=dir_MOD360(dir-(dir_diff(dir,point_dir(vx,vy,x,y)) div 2 ));

      if(uo_id=ua_psability)then exit;

      if(pObstacle^.o_x=uo_x)and(pObstacle^.o_y=uo_y)then
      begin
         uo_x-=sign(pObstacle^.o_x-x);
         uo_y-=sign(pObstacle^.o_y-y);
      end;

      uds:=point_dist_real(uo_x,uo_y,pObstacle^.o_x,pObstacle^.o_y);
      i  :=uid_r+pObstacle^.o_r;
      if(uds<=i)then
      begin
         i+=2;
         uo_x:=pObstacle^.o_x-round((pObstacle^.o_x-uo_x)/uds*i);
         uo_y:=pObstacle^.o_y-round((pObstacle^.o_y-uo_y)/uds*i);
      end;
   end;
end;

procedure unit_PushFromObstacles(pu:PTUnit);
var i,dx,dy:integer;
begin
   with pu^ do
     if(speed<=0)
     or(ukfly<>uf_ground)
     or(ukfloater)
     or(not solid)
     or(not iscomplete)then exit;

   dx:=pu^.x div MapObstaclesGridW;
   dy:=pu^.y div MapObstaclesGridW;

   if(0<=dx)and(dx<=MapObstaclesGridN)and(0<=dy)and(dy<=MapObstaclesGridN)then
    with map_ObstaclesGrid[dx,dy] do
     if(oc_n>0)then
      for i:=0 to oc_n-1 do
       with oc_l[i]^ do
        if(o_r>0)and(o_type>0)then unit_PushFromObstacle(pu,oc_l[i]);
end;

procedure unit_move(pu:PTUnit);
var mdist,ss:integer;
    ddir    :single;
begin
   with pu^ do
    if(x=vx)and(y=vy)then
     if(x<>mv_x)or(y<>mv_y)then
      if(not IsUnitRange(transportU,nil))then
       if(unit_canMove(pu))then
       begin
          ss:=speed;

          if(buffs[ub_Slow]>0)then ss:=max2i(2,ss div 2);

          mdist:=point_dist_int(x,y,mv_x,mv_y);
          if(mdist<=speed)then
          begin
             unit_SetXY(pu,mv_x,mv_y,mvxy_none);
             dir:=point_dir(vx,vy,x,y);
          end
          else
          begin
             with uid^ do
              if(not uid_isbuilding)then
               with player^ do
                if(uid_ismech)
                then ss+=upgr[upgr_race_mspeed_mech[uid_race]]*2
                else ss+=upgr[upgr_race_mspeed_bio [uid_race]]*2;

             if(mdist>70)
             then mdist:=8+g_random(25)
             else mdist:=50;

             dir:=dir_turn(dir,point_dir(x,y,mv_x,mv_y),mdist);

             ddir:=dir*degtorad;
             unit_SetXY(pu,x+round(ss*cos(ddir)),
                            y-round(ss*sin(ddir)),mvxy_none);
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
      if(pTarget^.buffs[ub_Resurect]>0)
      or(pTarget^.buffs[ub_Pain    ]>0)
      or(pTarget^.hits<=fdead_hits   )
      or(pTarget^.hits> 0            )then exit;
   end;

   if(pResurrector<>nil)then
     if(pTarget^.player^.team<>pResurrector^.player^.team)then
       with pResurrector^ do
       with uid^ do
       with player^ do
         if((armylimit+pTarget^.uid^.uid_LimitUse+uprodl)>MaxPlayerLimit)then exit;

   unit_StartResurrection:=true;

   if(check)then exit;

   if(pResurrector<>nil)then
     if(pTarget^.player^.team<>pResurrector^.player^.team)then
     begin
        unit_add(pTarget^.x,pTarget^.y,pResurrector^.unum,pTarget^.uidi,pResurrector^.playeri,true,false,pTarget^.level);

        if(LastCreatedUnit>0)then
        with LastCreatedUnitP^ do
        begin
           hits := pTarget^.hits;
           unit_dec_Kcntrs(LastCreatedUnitP);
        end;
        unit_kill(pTarget,true,true,false,false,true);
        pTarget:=LastCreatedUnitP;
     end;

   with pTarget^ do
   begin
      buffs[ub_Resurect]:=fr_fps2;
      zfall:=-uid^.uid_zfall;
      ukfly:= uid^.uid_isfly;
   end;
end;

function target_weapon_check(pAttacker,pTarget:PTUnit;ud:integer;cw:byte;checkvis,nosrangecheck:boolean):byte;
var awr:integer;
     au:PTUnit;
pfcheck,
canmove:boolean;
begin
   target_weapon_check:=wmove_impassible;

   //pAttacker - attacker
   //pTarget - target

   if(checkvis)then
     if(not CheckUnitTeamVision(pAttacker^.player^.team,pTarget,false))then exit;
   if(cw>LastUnitArms)then exit;
   if(pTarget^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=point_dist_int(pAttacker^.x,pAttacker^.y,pTarget^.x,pTarget^.y);

   with pAttacker^ do
   with uid^ do
   with player^ do
   with uid_arms[cw] do
   begin
      if(aw_reload=0)then exit;

      // Weapon type requirements
      case aw_type of
wpt_resurect : if(not unit_StartResurrection(pAttacker,pTarget,true))then exit;
wpt_heal     : if(pTarget^.hits<=0)
               or(pTarget^.hits>=pTarget^.uid^.uid_MaxHits1)
               or(not pTarget^.iscomplete)
               or(pTarget^.buffs[ub_Heal]>0)then exit;
      end;

      // transportU check
      au:=nil;
      if(IsUnitRange(transportU,@au))then
      begin
         if(IsUnitRange(pTarget^.transportU,nil))then
         begin
            if(au<>pTarget)and(transportU<>pTarget^.transportU)then exit;
            if(aw_max_range>=0)then exit; // only melee attack
         end
         else
           if(au<>pTarget)then
           begin
             if(aw_max_range< 0)then exit; // melee
           end
           else
             if(aw_max_range>=0)then exit; // ranged
      end
      else
        if(IsUnitRange(pTarget^.transportU,nil))then exit;

      // UID and UPID requirements

      if(aw_req_uid >0)and(uid_eb[aw_req_uid ]<=0)then exit;
      if(aw_req_upgr>0)and(upgr  [aw_req_upgr] =0)then exit;

      // requirements to attacker and some flags

      if not(pTarget^.uidi in aw_tar_uids)then exit;

      if((aw_req_flags and wpr_air   )>0)then
        if(ukfly=uf_ground)or(pTarget^.ukfly=uf_ground)then exit;
      if((aw_req_flags and wpr_ground)>0)then
        if(ukfly=uf_fly   )or(pTarget^.ukfly=uf_fly   )then exit;
      if((aw_req_flags and wpr_reload)>0)then
        if(rld>0)then exit;

      if(aw_type=wpt_directdmgZ)then
      begin
         if(pTarget^.iscomplete=false)
         or(pTarget^.uid^.uid_ZombieUID =0)
         or(pTarget^.uid^.uid_ZombieHits<pTarget^.hits)
         or(pTarget^.hits<=fdead_hits)then exit;
         if (pTarget^.player^.team=team)
         and(pTarget^.hits>0)then exit;

         if((armylimit-uid_LimitUse+pTarget^.uid^.uid_LimitUse+uprodl)>MaxPlayerLimit)then exit;
         if((menergy-uid_EnergyGen+pTarget^.uid^.uid_EnergyGen)<=0)then exit;
         if(pTarget^.uid^.uid_isbuilder)and(e_builders>=PlayerMaxBuilders)then exit;
      end;

      // requirements to target

      if((aw_tar_Flags and wtr_owner_p  )=0)and(pTarget^.playeri      =playeri       )then exit;
      if((aw_tar_Flags and wtr_owner_a  )=0)and(pTarget^.player^.team =team          )then exit;
      if((aw_tar_Flags and wtr_owner_e  )=0)and(pTarget^.player^.team<>team          )then exit;

      if((aw_tar_Flags and wtr_hits_h   )=0)and((0<pTarget^.hits)
                                      and(pTarget^.hits< pTarget^.uid^.uid_MaxHits1 ))then exit;
      if((aw_tar_Flags and wtr_hits_d   )=0)and(pTarget^.hits<=0                     )then exit;
      if((aw_tar_Flags and wtr_hits_a   )=0)and(pTarget^.hits =pTarget^.uid^.uid_MaxHits1)then exit;

      if((aw_tar_Flags and wtr_complete )=0)and(    pTarget^.iscomplete              )then exit;
      if((aw_tar_Flags and wtr_ncomplete)=0)and(not pTarget^.iscomplete              )then exit;

      if(not pTarget^.uid^.uid_isbuilding  )then
      begin
      if((aw_tar_Flags and wtr_stun     )=0)and(pTarget^.buffs[ub_Pain]> 0           )then exit;
      if((aw_tar_Flags and wtr_nostun   )=0)and(pTarget^.buffs[ub_Pain]<=0           )then exit;
      end;

      if(not CheckUnitBaseFlags(pTarget,aw_tar_Flags))then exit;

      // Distance requirements
      if(aw_max_range=aw_srange) // = srange
      then awr:=ud-srange
      else
        if(aw_max_range<aw_srange) // melee
        then awr:=ud-(uid_r+pTarget^.uid^.uid_r-aw_max_range)  // need transportU check
        else
          if(aw_max_range>=aw_fsr0)  // relative srange
          then awr:=ud-(srange+(aw_max_range-aw_fsr))
          else awr:=ud-aw_max_range; // absolute

      if(pTarget^.ukfly)
      then awr-=uid_arms_BonusAntiFlyRange
      else awr-=uid_arms_BonusAntiGroundRange;
      if(pTarget^.uid^.uid_isbuilding)
      then awr-=uid_arms_BonusAntiBuildingRange
      else awr-=uid_arms_BonusAntiUnitRange;

      canmove:=(speed>0)and(uo_id<>ua_hold)and(au=nil);
      pfcheck:=(ukfly)or(ukfloater)or(mapZone=pTarget^.mapZone);

      // mapZone check for melee

      if(awr<0)then
      begin
         if(ud>=aw_min_range)
         then target_weapon_check:=wmove_noneed     // can attack now
         else
           if(canmove)
           then target_weapon_check:=wmove_farther  // need move farther
           else ;                                    // target too close & cant move
      end
      else
        if(canmove)and(pfcheck)then
         if(ud<=(srange+TargetCheckSRangeBonus))or(nosrangecheck)
         then target_weapon_check:=wmove_closer     // need move closer
         else ;                                      // target too far & cant move
   end;
end;

function unit_target2weapon(pu,tu:PTUnit;ud:integer;cw:byte;action:pbyte):byte;
var i,a:byte;
begin
   unit_target2weapon:=255;

   // pu - attacker
   // tu - target

   if(CheckUnitTeamVision(pu^.player^.team,tu,false)=false)then exit;
   if(tu^.hits<=fdead_hits)or(tu^.buffs[ub_Invuln]>0)then exit;
   if(ud<0)then ud:=point_dist_int(pu^.x,pu^.y,tu^.x,tu^.y);
   if(cw>LastUnitArms)then cw:=LastUnitArms;
   if(action<>nil)then action^:=0;

   for i:=0 to cw do
   begin
      a:=target_weapon_check(pu,tu,ud,i,false,action<>nil);
      if(a=wmove_impassible)then continue;
      if(action<>nil)then action^:=a;
      unit_target2weapon:=i;
      break;
   end;
end;

function GetWeaponPriority(pTarget:PTUnit;priorset:byte;highprio:boolean):integer;
var i:integer;
procedure incPrio(add:boolean);
begin
   if(add)
   then GetWeaponPriority+=i;
   i:=i div 2;
end;
begin
   i:=8192;
   GetWeaponPriority:=0;

   with pTarget^  do
   with uid^ do
   case priorset of
wtp_building         : begin
                       incPrio(    uid_isbuilding   );
                       incPrio(uid_EnergyGen>0);
                       incPrio(not iscomplete    );
                       end;
wtp_BuildingHeavy    : begin
                       incPrio((   uid_isbuilding  )
                            and(not uid_islight    ));
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioLight     : begin
                       incPrio((not uid_isbuilding )
                            and(not uid_ismech     )
                            and(    uid_islight    ));
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioHeavy     : begin
                       incPrio((not uid_isbuilding )
                            and(not uid_ismech     )
                            and(not uid_islight    ));
                       incPrio(not iscomplete    );
                       end;
wtp_UnitMech         : begin
                       incPrio(not uid_isbuilding   );
                       incPrio(    uid_ismech       );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBio          : begin
                       incPrio(not uid_isbuilding   );
                       incPrio(not uid_ismech       );
                       incPrio(not iscomplete    );
                       end;
wtp_Bio              : begin
                       incPrio(not uid_ismech       );
                       incPrio((not uid_isbuilding)or(not iscomplete));
                       end;
wtp_Light            : incPrio(    uid_islight      );
wtp_GroundLight      : begin
                       incPrio((    uid_islight    )
                            and(not ukfly       ));
                       incPrio(uid_EnergyGen        >0);
                       end;
wtp_Fly              : begin
                       incPrio(     ukfly        );
                       incPrio(not iscomplete    );
                       end;
wtp_nolost_hits      : ;
wtp_UnitLight        : begin
                       incPrio(not uid_isbuilding   );
                       incPrio(    uid_islight      );
                       incPrio(not iscomplete    );
                       end;
wtp_limit            : incPrio(not uid_isbuilding   );
wtp_limitaround      : GetWeaponPriority+=pTarget^.aiu_limitaround_ally div ul1;
wtp_Scout            : begin
                       incPrio(uid_LimitUse<ul3);
                       incPrio(ukfly or ukfloater);
                       incPrio(transportM<=0);
                       GetWeaponPriority+=speed;
                       end;
   end;
   with pTarget^  do
   with uid^ do
   incPrio((uidi<>UID_LostSoul)and(uidi<>UID_Phantom));
   incPrio(highprio);
end;

function unit_target(pu,tu:PTUnit;ud:integer;a_tard:pinteger;t_weap:pbyte;a_tarp:PPTUnit;t_prio:pinteger):boolean;
var tw:byte;
n_prio:integer;
begin
   unit_target:=false;
   with pu^ do
   with uid^ do
   begin
      tw:=unit_target2weapon(pu,tu,ud,t_weap^,nil);

      if(tw>LastUnitArms)then exit;

      unit_target:=true;

      if(tw>t_weap^)
      then exit
      else
       with uid_arms[tw] do
        if(tw<t_weap^)
        then n_prio:=GetWeaponPriority(tu,aw_tar_prior,ai_HighPriorityTarget(player,tu))
        else
        begin
           n_prio:=GetWeaponPriority(tu,aw_tar_prior,ai_HighPriorityTarget(player,tu));

           case aw_tar_prior of
           //wtp_heal      : if(tu<>pu)then n_prio+=1;
           wtp_limit     : n_prio+=tu^.uid^.uid_LimitUse;
           end;

           //if(n_prio>t_prio^)then ;
           if(n_prio=t_prio^)then
           case aw_tar_prior of
wtp_max_hits          : if(tu^.hits       <a_tarp^^.hits       )
                        then exit
                        else
                          if(tu^.hits     =a_tarp^^.hits       )then
                            if(ud         >a_tard^             )then exit;
wtp_distance          : if(ud             >a_tard^             )then exit;
wtp_nolost_hits,
wtp_hits              : if(tu^.hits       >a_tarp^^.hits       )
                        then exit
                        else
                          if(tu^.hits     =a_tarp^^.hits       )then
                            if(ud         >a_tard^             )then exit;

wtp_Rmhits            : if(tu^.uid^.uid_MaxHits1<a_tarp^^.uid^.uid_MaxHits1)
                        then exit
                        else
                          if(tu^.uid^.uid_MaxHits1=a_tarp^^.uid^.uid_MaxHits1)then
                            if(ud           >a_tard^             )then exit;
wtp_heal              : if(tu^.hits     >a_tarp^^.hits       )
                        then exit
                        else
                          if(tu^.hits   =a_tarp^^.hits       )then
                            if(ud       >a_tard^             )then exit;
           else
              if(aw_max_range<0)and(aw_type=wpt_directdmg)
              then begin if(ud  >a_tard^             )then exit; end
              else
                if(tu^.hits     >a_tarp^^.hits       )
                then exit
                else
                  if(tu^.hits   =a_tarp^^.hits       )then
                    if(ud       >a_tard^             )then exit;
           end;
           if(n_prio<t_prio^)then exit;
        end;

      t_prio^:=n_prio;
      t_weap^:=tw;
      a_tar  :=tu^.unum;
      a_tard^:=ud;
      a_tarp^:=tu;
   end;
end;

procedure unit_AuraEffects(pAuraSrcUnit,pTarget:PTUnit;ud:integer);
begin
   // pAuraSrcUnit - aura source
   // pTarget - target
   with pAuraSrcUnit^     do
   with uid^    do
   with player^ do
   case uidi of
UID_HAKeep,
UID_HKeep     : if(ud<srange)
               and(not pTarget^.uid^.uid_isbuilding)
               and(pTarget^.iscomplete)
               and(team<>pTarget^.player^.team)then
                  if(pTarget^.buffs[ub_Decay]<=fr_fpsh)and(upgr[upgr_hell_DecayAura]>0)then
                  begin
                     AddToInt(@TeamVision[pTarget^.player^.team],MinVisionTime);
                     unit_damage(pTarget,DecayAuraDamage,playeri,true);
                     pTarget^.buffs[ub_Decay]:=fr_fps1;
                  end;
   end;
end;

procedure unit_CaptureKPoint(pu:PTUnit);
var i :byte;
begin
   with pu^ do
    for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
      if(kpCaptureR>0)then
       if(point_dist_int(x,y,kpx,kpy)<=kpCaptureR)then
       begin
          kpUnitsPlayer[playeri     ]+=uid^.uid_LimitUse;
          kpUnitsTeam  [player^.team]+=uid^.uid_LimitUse;
       end;
end;

procedure unit_mcycle(pu:PTUnit);
var uc,
t_prio,
a_tard,
    udi : integer;
    uds: single;
a_tarp,
tu_transport,
    tu : PTUnit;
aicode,
attack_target,
pushout: boolean;
t_weap : byte;
NearTeleport    :boolean;
NearTeleport_tu :PTUnit;
teleport_NewTaru,
teleport_NewTard:integer;
teleport_NewTar :boolean;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      a_tar   := 0;
      a_tard  := NOTSET;
      a_tarp  := nil;
      t_weap  := 255;
      t_prio  := 0;
      teleport_NewTaru := 0;
      teleport_NewTard:= NOTSET;
      tu_transport:=nil;
      if(StayWaitForNewTarget>0)
      then StayWaitForNewTarget-=1;

      u_royal_cd:=NOTSET;
      u_royal_d :=NOTSET;
      if(map_scenario=mc_royale)then
      begin
         u_royal_cd:=point_dist_int(x,y,map_hSize,map_hSize);
         u_royal_d :=g_royal_r-u_royal_cd;
         if(u_royal_d<uid_missileR)then
         begin
            unit_kill(pu,false,false,true,true,false);
            exit;
         end;
      end;

      if(uid_isbuilding)and(menergy<=0)then
      begin
         unit_kill(pu,false,false,true,false,true);
         exit;
      end;

      pushout      := solid and unit_canMove(pu) and (a_rld<=0);
      attack_target:= unit_canAttack(pu,false);
      aicode       := (state=ps_AI);//and(isselected);
      teleport_NewTar:= (not IsUnitRange(uo_tar,nil))and(uid_ability=uab_Teleport);
      NearTeleport   := false;
      NearTeleport_tu:=nil;
      if(IsUnitRange(uo_tar,@NearTeleport_tu))and(not aicode)then
        if(NearTeleport_tu^.player=player)and(NearTeleport_tu^.hits>0)and(NearTeleport_tu^.rld>0)then
          case g_uids[NearTeleport_tu^.uidi].uid_ability of
uab_Teleport : NearTeleport:=true;
          end;

      ai_Local_InitVars(pu);
      if(aicode){or(isselected)}then
      begin
         ai_Global_InitVars(pu);
         ai_Global_CollectData(pu,pu,0,nil);
      end;
      ai_Local_CollectData(pu,pu,0,nil);

      if(attack_target)then unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
        if(uc<>unum)then
        begin
           tu:=g_punits[uc];

           if(tu^.hits>fdead_hits)then
           begin
              uds:=point_dist_real(x,y,tu^.x,tu^.y);
              udi:=round(uds);

              tu_transport:=nil;
              IsUnitRange(tu^.transportU,@tu_transport);

              if(tu_transport=nil)then unit_detect(pu,tu,udi);

              if(attack_target)then unit_target(pu,tu,udi,@a_tard,@t_weap,@a_tarp,@t_prio);

              ai_Local_CollectData(pu,tu,udi,tu_transport);
              if(aicode){or(isselected)}then ai_Global_CollectData(pu,tu,udi,tu_transport);

              if(tu^.hits>0)and(tu_transport=nil)then
              begin
                 unit_AuraEffects(pu,tu,udi);

                 if(pushout)then
                   if(uid_r<=tu^.uid^.uid_r)or(tu^.speed<=0)or(not tu^.iscomplete)then
                     if(tu^.solid)and(ukfly=tu^.ukfly)then unit_push(pu,tu,uds);

                 if(NearTeleport)then
                   if(udi<srange)and(tu^.playeri=playeri)and(tu^.uidi=NearTeleport_tu^.uidi)and(tu^.rld<NearTeleport_tu^.rld)and(tu^.iscomplete)then
                     if((0<tu^.uo_tar)and(tu^.uo_tar<=MaxUnits)and(tu^.uo_tar=NearTeleport_tu^.uo_tar))
                     or((tu^.uo_x=NearTeleport_tu^.uo_x)and(tu^.uo_y=NearTeleport_tu^.uo_y))
                     then uo_tar:=tu^.unum;

                 if(teleport_NewTar)then
                 begin
                    udi:=point_dist_int(uo_x,uo_y,tu^.x,tu^.y)-tu^.uid^.uid_r;
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

      if(teleport_NewTar)and(teleport_NewTaru>0)then uo_tar:=teleport_NewTaru;

      if(attack_target)and(a_tard<NOTSET)then StayWaitForNewTarget:=0;

      {$IFNDEF DEBUG1}
      ai_Local_Code(pu);
      if(aicode){and(playeri=LocalPlayer)}then ai_Global_Code(pu);
      {$ENDIF}

      if(buffs[ub_Damaged]>0)then GameLogUnitAttacked(pu);
   end;
end;

procedure unit_mcycle_cl(pu,pTransportU:PTUnit);
var uc,a_tard,
t_prio,
    ud : integer;
a_tarp,
    tu : PTUnit;
t_weap : byte;
udetect,
ftarget: boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      StayWaitForNewTarget:=0;
      if(ServerSide)then
      begin
         a_tar  :=0;
         a_tard :=NOTSET;
         t_weap :=255;
         a_tarp :=nil;
         t_prio :=0;
         ftarget:=unit_canAttack(pu,false);
      end
      else ftarget:=false;

      if(pTransportU<>nil)then
      begin
         if(IsUnitRange(pTransportU^.transportU,nil))then exit;
         TeamVision   :=pTransportU^.TeamVision;
         udetect:=false;
      end
      else udetect:=true;

      if(not udetect)and(not ftarget)then exit;  // in trnasport & client side

      if(ftarget)and(ServerSide)then unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
        if(uc<>unum)then
        begin
           tu:=g_punits[uc];
           if(tu^.hits>fdead_hits)then
           begin
              ud:=point_dist_rint(x,y,tu^.x,tu^.y);

              if(udetect)then
              begin
                 unit_detect(pu,tu,ud);
                 if(pTransportU=nil)and(tu^.hits>0)then
                   if(not IsUnitRange(tu^.transportU,nil))then unit_AuraEffects(pu,tu,ud);
              end;
              if(ftarget)then unit_target(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio);
           end;
        end;
   end;
end;

function unit_ability_HellVision(pu:PTUnit;target:integer;check:boolean):cardinal;
var tu:PTUnit;
begin
   // pu - caster
   // tu - target
   with pu^     do
   begin
      unit_ability_HellVision:=ureq_other;
      if(not iscomplete)
      or(hits<=0)then exit;

      unit_ability_HellVision:=ureq_reloading;
      if(rld>0)then exit;
   end;

   unit_ability_HellVision:=ureq_InvalidTarget;
   if(not IsUnitRange(target,@tu))then exit;

   with tu^ do
     if(not iscomplete)
     or(hits<=0)
     or(pu^.player^.team<>player^.team)
     or(buffs[ub_HVision]>fr_fps1)
     or(buffs[ub_Detect]>0)then exit;

   with pu^     do
   with player^ do
   begin
      unit_ability_HellVision:=0;
      if(check)then exit;

      tu^.buffs[ub_HVision]:=hell_vision_time;
      rld:=hell_vision_reload;
      {$IFDEF _FULLGAME}
      effect_LevelUp(tu,EID_Hvision,nil);
      {$ENDIF}
   end;
end;

function unit_ability_Recall(pu:PTUnit;tar,tard:integer;check:boolean):cardinal;
var tu:PTUnit;
begin
   // pu - teleporter

   with pu^ do
   begin
      unit_ability_Recall:=ureq_other;
      if(not iscomplete)
      or(hits<=0)then exit;

      unit_ability_Recall:=ureq_reloading;
      if(rld>0)then exit;
   end;

   unit_ability_Recall:=ureq_rupid;
   with pu^.player^ do
     if(upgr[upgr_hell_Recall]<=0)
     then exit;

   unit_ability_Recall:=ureq_InvalidTarget;
   if(not IsUnitRange(tar,@tu))then exit;
   with tu^ do
   with uid^ do
     if(uid_isbuilding)
     or(not iscomplete)
     or(ukfly)
     or(hits<=0)
     or(buffs[ub_Teleport]>0)
     or(pu^.playeri<>playeri)
     then exit;

   with pu^  do
   with uid^ do
   with player^ do
   begin
      if(tard=NOTSET)
      or(tard<0     )then tard:=point_dist_int(x,y,tu^.x,tu^.y);
      if(tard>base_1r)then
      begin
         unit_ability_Recall:=0;

         if(check)then exit;

         unit_teleport(tu,x,y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
         teleport_CalcReload(pu,tu^.uid^.uid_LimitUse);
         tu^.uo_x  :=tu^.x;
         tu^.uo_y  :=tu^.y;
         tu^.uo_tar:=0;
      end;
   end;
end;

function unit_ability_teleport(pu,tu:PTUnit;td:integer):boolean;
var tt:PTUnit;
    tr:integer;
begin
   // pu - target
   // tu - teleporter
   // td = dist2(pu,tu)
   if(td=NOTSET)then td:=point_dist_int(pu^.x,pu^.y,tu^.x,tu^.y);
   unit_ability_teleport:=false;
   with pu^  do
    with uid^ do
      if(not uid_isbuilding)and(iscomplete)and(ukfly=false)and(tu^.hits>0)and(tu^.iscomplete)then
       if(playeri=tu^.playeri)and(buffs[ub_Teleport]<=0)then
        if(td<=tu^.uid^.uid_r)then
        begin
           if(tu^.rld<=0)then
           begin
              if(not IsUnitRange(tu^.uo_tar,@tt))then exit;
              if(tu^.player^.team<>tt^.player^.team)then exit;
              if(tt^.hits<=0)then exit;

              if(ukfly=uf_ground)then
                if(map_IfObstacleZone(tt^.mapZone))then exit;

              tu^.uo_x:=tt^.x;
              tu^.uo_y:=tt^.y;

              tr:=uid_r+tt^.uid^.uid_r;

              if(ukfly=tt^.ukfly)
              then unit_teleport(pu,tu^.uo_x+(tr*sign(x-tu^.uo_x)),tu^.uo_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF})
              else unit_teleport(pu,tu^.uo_x                      ,tu^.uo_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});

              teleport_CalcReload(tu,uid_LimitUse);
              unit_ability_teleport:=true;
           end;
        end;
end;

function unit_Load(pu,tu:PTUnit):boolean;
begin
   //pu - transport
   //tu - target
   unit_Load:=false;
   if(unit_CheckTransport(pu,tu))then
     with pu^ do
     begin
        transportC+=tu^.uid^.uid_TransportSize;
        tu^.transportU:=unum;
        tu^.a_tar:=0;
        if(uo_tar=tu^.unum)then     uo_tar:=0;
        if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
        unit_UnSelect(tu);
        {$IFDEF _FULLGAME}
        SoundPlayUnit(snd_transport,pu,nil);
        {$ENDIF}
        unit_Load:=true;
     end;
end;
function unit_UnLoad(pu,tu:PTUnit):boolean;
begin
   //pu - transport
   //tu - target
   unit_UnLoad:=false;
   if(pu=nil)then
     if(not IsUnitRange(tu^.transportU,@pu))then exit;
   with tu^ do
   if(transportU=pu^.unum)and(pu^.buffs[ub_CCast]<=0)then
   begin
      pu^.buffs[ub_CCast]:=fr_fpsq;
      pu^.transportC-=uid^.uid_TransportSize;
      transportU:=0;
      x    :=pu^.x-g_randomr(pu^.uid^.uid_r);
      y    :=pu^.y-g_randomr(pu^.uid^.uid_r);
      uo_x :=x;
      uo_y :=y;
      {$IFDEF _FULLGAME}
      SoundPlayUnit(snd_transport,pu,nil);
      {$ENDIF}
      unit_UnLoad:=true;
   end;
   with pu^ do
     if(transportC=0)then uo_id:=ua_amove;
end;

procedure unit_InTransportCode(pu,ptransport:PTUnit);
var tu:PTUnit;
begin
   // pu - unit inside
   // ptransport - transport
   with pu^ do
   begin
      x  :=ptransport^.x;
      y  :=ptransport^.y;
      {$IFDEF _FULLGAME}
      fx :=ptransport^.fx;
      fy :=ptransport^.fy;
      mmx:=ptransport^.mmx;
      mmy:=ptransport^.mmy;
      {$ENDIF}

      if(ServerSide)then
      begin
         if(ptransport^.uo_id=ua_unload)or(ptransport^.transportC>ptransport^.transportM)then
          if(not ptransport^.ukfly)or(not map_IfObstacleZone(ptransport^.mapZone))then
           if(unit_UnLoad(ptransport,pu))then exit;

         if(ptransport^.uo_id=ua_move )
         or(ptransport^.uo_id=ua_hold )
         or(ptransport^.uo_id=ua_amove)then uo_id:=ptransport^.uo_id;

         if(IsUnitRange(ptransport^.uo_tar,@tu))then
         begin
            a_tar:=ptransport^.uo_tar;
            if(unit_target2weapon(pu,tu,-1,255,nil)<=LastUnitArms)then uo_id:=ua_amove;
         end;
      end;
   end;
end;

// target units
procedure unit_uo_tar(pu:PTUnit);
var tu: PTUnit;
     a,
     w: byte;
td,tdm: integer;
begin
   with pu^  do
   with uid^ do
   if(uo_tar=unum)
   then uo_tar:=0
   else
      if(IsUnitRange(uo_tar,@tu))then
      begin
         if(IsUnitRange(tu^.transportU,nil))
         or(not CheckUnitTeamVision(player^.team,tu,false))then
         begin
            uo_tar:=0;
            uo_id :=ua_amove;
            exit;
         end;

         td :=point_dist_int(x,y,tu^.x,tu^.y);
         if(tu^.solid)
         then tdm:=td-(uid_r+tu^.uid^.uid_r)
         else tdm:=td- min2i(uid_r,tu^.uid^.uid_r);

         if(tdm<melee_r)then
         begin
            if(unit_Load(pu,tu))then exit;
            if(unit_Load(tu,pu))then exit;
         end;

         case uid_ability of
uab_Teleport     : if(tu^.player^.team<>player^.team )then begin uo_tar:=0;exit; end;
         end;

         case tu^.uid^.uid_ability of
uab_Teleport     : if(unit_ability_teleport(pu,tu,td))then exit;//team
         end;

         w:=unit_target2weapon(pu,tu,td,255,@a);
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

         if(player=tu^.player)and(tu^.ukfly)then
           if(unit_CheckTransport(tu,pu))and(not IsUnitRange(tu^.uo_tar,nil))and(tu^.uo_x=tu^.x)and(tu^.uo_y=tu^.y)then
           begin
              tu^.uo_x:=x;
              tu^.uo_y:=y;
           end;

         uo_x:=tu^.vx;
         uo_y:=tu^.vy;
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
      if((armylimit-uid_LimitUse+_zuid^.uid_LimitUse+uprodl)>MaxPlayerLimit)then exit;
      if((menergy-uid_EnergyGen+_zuid^.uid_EnergyGen)<=0)then exit;
      if(pTarget^.uid^.uid_isbuilder)and(e_builders>=PlayerMaxBuilders)then exit;
   end;

   if(not pTarget^.iscomplete)
   or(pTarget^.uid^.uid_ZombieUID =0)
   or(pTarget^.uid^.uid_ZombieHits<pTarget^.hits)
   or(pTarget^.hits<=fdead_hits          )then exit;

   if(ServerSide)then
   begin
      _h:=pTarget^.hits/pTarget^.uid^.uid_MaxHits1;
      _d:=pTarget^.dir;
      _o:=pPhantom^.group;
      _f:=pTarget^.ukfly;
      _z:=pTarget^.zfall;
      _l:=pTarget^.level;
      {$IFDEF _FULLGAME}
      _s:=pTarget^.shadow;
      {$ENDIF}

      unit_kill(pPhantom,true,true,false,false,true);
      unit_add(pTarget^.x,pTarget^.y,pPhantom^.unum,pTarget^.uid^.uid_ZombieUID,pPhantom^.playeri,true,true,_l);
      unit_kill(pTarget,true,true,false,false,true);

      if(LastCreatedUnit>0)then
      with LastCreatedUnitP^ do
      begin
         group:=_o;
         dir  :=_d;
         ukfly:=_f;
         hits := trunc(uid^.uid_MaxHits1*_h);
         zfall:=_z;
         {$IFDEF _FULLGAME}
         shadow:=_s;
         {$ENDIF}
         if(hits<=0)then
         begin
            unit_dec_Kcntrs(LastCreatedUnitP);
            unit_StartResurrection(nil,LastCreatedUnitP,false);
         end;
      end;
   end;
   unit_TryZombification:=true;
end;

procedure unit_AddExp(pu:PTUnit;exp:cardinal);
begin
   with pu^ do
   if(level<LastUnitLevel)then
   with uid^ do
   begin
      a_exp+=exp;
      if(a_exp>=a_exp_next)then
      begin
         level+=1;
         a_exp:=0;
         a_exp_next:=ExpLevel1; //level*ExpLevel1+
         GameLogUnitPromoted(pu);
         {$IFDEF _FULLGAME}
         effect_LevelUp(pu,0,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_attack(pAttacker:PTUnit):boolean;
var arm,a   : byte;
pTarget   : PTUnit;
damage,
upgradd,c : integer;
fakemissile,
attackinmove: boolean;
{$IFDEF _FULLGAME}
vis_Attacker,
vis_Target : boolean;
{$ENDIF}
procedure visEffects;
var i:byte;
begin
   with pAttacker^ do
   with uid^ do
   with uid_arms[a_weap] do
   begin
      AddToInt(@TeamVision[pTarget^.player^.team],a_rld+1);
      AddToInt(@TeamVision[pTarget^.player^.team],MinVisionTime);
      for i:=0 to LastPlayer do
        if(pTarget^.TeamVision[i]>0)
        or(         TeamVision[i]>0)then
        begin
                     TeamVision[i]:=max2i(TeamVision[i],pTarget^.TeamVision[i]);
            pTarget^.TeamVision[i]:=TeamVision[i];
        end;
   end;
end;
begin
   unit_attack:=false;
   with pAttacker^ do
   begin
      if(not IsUnitRange(a_tar,@pTarget))then exit;

      if(ServerSide)then
      begin
         if(a_rld<=0)then
         begin
            arm:=unit_target2weapon(pAttacker,pTarget,-1,255,@a);

            if(arm>LastUnitArms)or(a=0)then
            begin
               if(ServerSide)then
               begin
                  a_tar:=0;
                  StayWaitForNewTarget:=1;
               end;
               exit;
            end;

            a_weap:=arm;
         end
         else
         begin
            a:=target_weapon_check(pAttacker,pTarget,-1,a_weap,true,false);

            if(a=0)then
            begin
               if(ServerSide)then
               begin
                  a_tar:=0;
                  StayWaitForNewTarget:=1;
               end;
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
                              mv_x:=pTarget^.x;
                              mv_y:=pTarget^.y;
                           end;
                           exit;
                        end;
         wmove_farther: begin
                           if(not attackinmove)or(uo_bx<=0)then
                             if(x=pTarget^.x)and(y=pTarget^.y)then
                             begin
                                mv_x:=x-g_randomr(2);
                                mv_y:=y-g_randomr(2);
                             end
                             else
                             begin
                                mv_x:=x-(pTarget^.x-x);
                                mv_y:=y-(pTarget^.y-y);
                             end;
                           exit;
                        end;
         wmove_noneed : if(not attackinmove)then
                        begin
                           mv_x:=x;
                           mv_y:=y;
                        end;
         else
              // wmove_impassible
             StayWaitForNewTarget:=1;
             exit;
         end;
      end
      else
      begin
         unit_attack:=true;
         if(a_weap>LastUnitArms)then exit;

         if(pTarget^.hits<=fdead_hits)then exit;

         with uid^ do
           with uid_arms[a_weap] do
             attackinmove:=(aw_req_flags and wpr_move)>0;
      end;

      if(not unit_canAttack(pAttacker,true))then
      begin
         mv_x:=x;
         mv_y:=y;
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

            if(ServerSide)and(not uid_isbuilding)then
              if((aw_max_range<0)and(aw_type=wpt_directdmg))
              or(aw_type=wpt_heal)
              then unit_AddExp(pAttacker,aw_reload*2)
              else unit_AddExp(pAttacker,aw_reload  );
            if(not attackinmove)then
            begin
               if(x<>pTarget^.x)
               or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
               if(ServerSide)then StayWaitForNewTarget:=(a_rld div order_period)+1;
            end;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,true,@vis_Attacker);
            {$ENDIF}
            visEffects;
         end;

         if(cycle_order=g_cycle_order)then visEffects;

         {$IFDEF _FULLGAME}
         if(vis_Target)then
           if(aw_eid_target>0)and(not aw_eid_target_onlyshot)then
           begin
              if(not IsUnitRange(pTarget^.transportU,nil))then
                if((g_tick mod fr_fpst)=0)then effect_add(pTarget^.vx-g_randomr(pTarget^.uid^.uid_missileR),
                                                          pTarget^.vy-g_randomr(pTarget^.uid^.uid_missileR),
                                                          draw_SpriteDepth(pTarget^.vy+1,pTarget^.ukfly),aw_eid_target);
              if(aw_snd_target<>nil)then
                if((g_tick mod fr_fps1)=0)then SoundPlayUnit(aw_snd_target,pTarget,@vis_Target);
           end;
         {$ENDIF}

         if(a_rld in aw_ShotPoints)then
         begin
            if(aw_FakeShotsN=0)
            then fakemissile:=false
            else fakemissile:=(a_shots mod aw_FakeShotsN)>0;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,false,@vis_Attacker);
            if(vis_Target)then
             if(aw_eid_target>0)and(aw_eid_target_onlyshot)then
             begin
                if(not IsUnitRange(pTarget^.transportU,nil))then
                effect_add(pTarget^.vx-g_randomr(pTarget^.uid^.uid_missileR),pTarget^.vy-g_randomr(pTarget^.uid^.uid_missileR),draw_SpriteDepth(pTarget^.vy+1,pTarget^.ukfly),aw_eid_target);

                SoundPlayUnit(aw_snd_target,pTarget,@vis_Target);
             end;
            {$ENDIF}
            if(aw_impact_upgr>0)and(aw_impact_upgrStep>0)then upgradd:=player^.upgr[aw_impact_upgr]*aw_impact_upgrStep;
            if(level>0)and(not uid_isbuilding)then upgradd+=level*uid_LevelBonusDamage;
            if(not attackinmove)then
              if(x<>pTarget^.x)
              or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
            case aw_type of
wpt_missle     : if(aw_object_id>0)then
                  if(aw_object_count=0)
                  then missile_add(pTarget^.x,pTarget^.y,vx+aw_offset_x,vy+aw_offset_y,a_tar,aw_object_id,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_impact_dmod)
                  else
                    if(aw_object_count>0)
                    then for c:=1 to aw_object_count do missile_add(pTarget^.x,pTarget^.y,vx+aw_offset_x,vy+aw_offset_y,a_tar,aw_object_id,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_impact_dmod)
                    else
                      if(aw_object_count<0)then
                      begin
                         missile_add(pTarget^.x,pTarget^.y,vx-aw_object_count+aw_offset_x,vy-aw_object_count+aw_offset_y,a_tar,aw_object_id,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_impact_dmod);
                         missile_add(pTarget^.x,pTarget^.y,vx+aw_object_count+aw_offset_x,vy+aw_object_count+aw_offset_y,a_tar,aw_object_id,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_impact_dmod);
                      end;
wpt_unit       : if(not fakemissile)then ability_unit_spawn(pAttacker,aw_object_id);
wpt_directdmg  : if(not fakemissile)and(aw_object_count>0)then
                 begin
                    damage:=ApplyDamageMod(pTarget,aw_impact_dmod,aw_object_count+upgradd);
                    unit_damage(pTarget,damage,playeri,false);
                 end;
wpt_directdmgZ : if(not fakemissile)and(aw_object_count>0)then
                  if(not unit_TryZombification(pAttacker,pTarget))then
                  begin
                     damage:=ApplyDamageMod(pTarget,aw_impact_dmod,aw_object_count+upgradd);
                     unit_damage(pTarget,damage,playeri,false);
                  end;
wpt_suicide    : if(ServerSide)then unit_kill(pAttacker,false,true,true,false,true);
            else
              if(ServerSide)and(not fakemissile)then
                case aw_type of
wpt_resurect    : begin
                     unit_StartResurrection(pAttacker,pTarget,false);
                     if((aw_req_flags and wpr_reload)>0)then rld:=max2i(0,aw_object_count*fr_fps1);
                  end;
wpt_heal        : begin
                     pTarget^.hits:=mm3i(1,pTarget^.hits+aw_object_count+upgradd,pTarget^.uid^.uid_MaxHits1);
                     pTarget^.buffs[ub_Heal]:=aw_reload;
                  end;
                end;
            end;
         end;
      end;
   end;
end;

procedure unit_order(pu:PTUnit);
var apctu:PTUnit;
begin
   with pu^ do
    if(hits<=0)then exit;

   apctu:=nil;
   if(IsUnitRange(pu^.transportU,@apctu))then unit_InTransportCode(pu,apctu);

   with pu^ do
   if(not ServerSide)then
   begin
      unit_attack(pu);

      if(apctu=nil)and(cycle_order=g_cycle_order)then
        if(mp_x<>x)or(mp_y<>y)then
        begin
           mp_x:=x;
           mp_y:=y;
        end;
   end
   else
   begin
      if(apctu=nil)then
      begin
         unit_uo_tar(pu);

         uo_x:=mm3i(1,uo_x,map_Size);
         uo_y:=mm3i(1,uo_y,map_Size);

         mv_x:=uo_x;
         mv_y:=uo_y;

         if(uo_id=ua_psability)then
           case uid^.uid_ability of
uab_SpawnLost     : begin
                       mv_x:=x;
                       mv_y:=y;
                       uo_id:=ua_amove;
                       unit_sability(pu,false);
                       uo_id:=ua_psability;
                    end;
uab_UACCCLand         : if(x=uo_x)and(y=uo_y)then
                    begin
                       uo_id:=ua_amove;
                       unit_sability(pu,false);
                    end;
uab_RebuildInPoint: if(speed<=0)
                    then uo_id:=ua_amove
                    else
                      if(x=uo_x)and(y=uo_y)then
                      begin
                         uo_id:=ua_amove;
                         GameLogBits2Message(playeri,uidi,lmt_argt_unit,unit_rebuild(pu,false),x,y);
                      end;
           else uo_id:=ua_amove;
           end
         else
           if(x=uo_x)and(y=uo_y)then
            if(uo_bx>=0)then
            begin
               uo_x :=uo_bx;
               uo_bx:=x;
               uo_y :=uo_by;
               uo_by:=y;
            end
            else
              if(uo_id=ua_move)then uo_id:=ua_amove;
      end;

      if(uo_id=ua_amove)
      then unit_attack(pu)
      else StayWaitForNewTarget:=0;

      if(uo_id=ua_amove)and(StayWaitForNewTarget>0)then
      begin
         mv_x:=x;
         mv_y:=y;
      end
      else
        if(apctu=nil)then
          if(unit_canMove(pu))then
            if(mp_x<>mv_x)or(mp_y<>mv_y)then
            begin
               if(not uid^.uid_SlowTurn)and(player^.state<>ps_AI)then
                 if(x<>mv_x)or(y<>mv_y)then dir:=point_dir(x,y,mv_x,mv_y);
               mp_x:=mv_x;
               mp_y:=mv_y;
            end;
   end;
end;

procedure unit_SetDefaultUO(pu:PTUnit;aid,atar,ax,ay,apx,apy:integer;aResetatar,nospeedcheck:boolean);
begin
   with pu^ do
   begin
      uo_id :=aid;
      uo_tar:=atar;
      if(aResetatar)then a_tar:=0;
      if(speed>0)or(nospeedcheck)then
      begin
         uo_x  :=ax;
         uo_y  :=ay;
         uo_bx :=apx;
         uo_by :=apy;
      end;
   end;
end;

function unit_rebuild(pu:PTUnit;check:boolean):cardinal;
begin
   unit_rebuild:=ureq_other;

   if(not ui_HaveRebuild(pu))then exit;

   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_rebuild:=0;

      if(uid_rebuild_ruid>0)then
        if(uid_eb[uid_rebuild_ruid]<=0)then unit_rebuild:=ureq_ruid;

      if(uid_rebuild_rupgr>0)then
        if(upgr[uid_rebuild_rupgr]<=0)then unit_rebuild:=ureq_rupid;

      if(unit_rebuild>0)then exit;

      if(uid_rebuild_uid=uidi)
      then unit_rebuild:=unit_morph(pu,uid_rebuild_uid,false,1,level+1,true )
      else unit_rebuild:=unit_morph(pu,uid_rebuild_uid,false,1,level  ,true );

      if(check)or(unit_rebuild>0)then exit;

      if(uid_rebuild_uid=uidi)
      then unit_morph(pu,uid_rebuild_uid,false,1,level+1,false)
      else unit_morph(pu,uid_rebuild_uid,false,1,level  ,false);
   end;
end;

function unit_AbilityBasicChecks(pu:PTUnit):cardinal;
procedure AddUREQ(ureq:cardinal);
begin
   unit_AbilityBasicChecks:=unit_AbilityBasicChecks or ureq;
end;
begin
   unit_AbilityBasicChecks:=0;
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(rld>0)then AddUREQ(ureq_reloading);

      if(uid_ability_ReqNoObstacles)then
        if(map_IfObstacleZone(mapZone))then AddUREQ(ureq_place);

      if(uid_ability_ReqUID>0)then
        if(uid_eb[uid_ability_ReqUID]<=0)then AddUREQ(ureq_ruid);

      if(uid_ability_ReqUpgr>0)then
        if(upgr[uid_ability_ReqUpgr]=0)then AddUREQ(ureq_rupid);
   end;
end;

function unit_sability(pCaster:PTUnit;check:boolean):cardinal;
begin
   unit_sability:=ureq_other;

   if(not ui_HaveAbility(pCaster,false)) then exit;

   unit_sability:=unit_AbilityBasicChecks(pCaster);
   if(unit_sability>0)then exit;

   with pCaster^ do
   with uid^ do
   with player^ do
   case uid_ability of
   uab_SpawnLost       : if(buffs[ub_Cast]>0)
                         or(buffs[ub_CCast]>0)then unit_sability:=ureq_reloading;
   uab_UACCCLand           : if(zfall<>0)
                         or(buffs[ub_CCast]>0)then unit_sability:=ureq_reloading;
   uab_ToUACDron       : unit_sability:=unit_morph(pCaster,uid_UACDron,false,g_uids[uid_UACDron].uid_MaxHitsh,0,true);
   uab_Unload          : if(transportC=0)
                         or(transportM=0)then unit_sability:=ureq_other;
   else  unit_sability:=ureq_other;
   end;

   if(check)or(unit_sability>0)then exit;

   with pCaster^ do
   with uid^ do
   with player^ do
   case uid_ability of
   uab_RebuildInPoint  : unit_rebuild(pCaster,false);
   uab_SpawnLost       : begin
                            buffs[ub_Cast ]:=fr_fpsh;
                            buffs[ub_CCast]:=fr_fps2;
                            if(upgr[upgr_hell_Phantoms]>0)
                            then ability_unit_spawn(pCaster,UID_Phantom )
                            else ability_unit_spawn(pCaster,UID_LostSoul);
                         end;
   uab_UACCCLand           : if(level>0)
                         then level:=0
                         else level:=1;
   uab_ToUACDron       : unit_morph(pCaster,uid_UACDron,false,g_uids[uid_UACDron].uid_MaxHitsh,0,false);
   uab_Unload          : uo_id:=ua_unload;
   end;
end;

function unit_pability(pCaster:PTUnit;taru,tarx,tary:integer;check:boolean):cardinal;
begin
   unit_pability:=ureq_other;

   if(not ui_HaveAbility(pCaster,true )) then exit;

   unit_pability:=unit_AbilityBasicChecks(pCaster);
   if(unit_pability>0)then exit;

   with pCaster^ do
   with uid^ do
   with player^ do
   case uid_ability of
   uab_Teleport        : if(upgr[upgr_hell_Recall]<=0)then
                           unit_pability:=ureq_rupid;
   uab_UACScan         : unit_pability:=unit_ability_UACScan    (pCaster,tarx,tary  ,true);
   uab_UACStrike       : unit_pability:=unit_ability_UACStrike  (pCaster,tarx,tary  ,true);
   uab_HTowerBlink     : ;
   uab_HKeepShift      :;
   uab_RebuildInPoint  :;
   uab_SphereInvuln:;
   uab_SpawnLost       :;
   uab_HEyeVision      :;
   uab_UACCCLand           :;
   uab_Unload          : if(transportC=0)
                         or(transportM=0)then unit_pability:=ureq_other;
   else  unit_pability:=ureq_other;
   end;


   if(check)or(unit_pability>0)then exit;

   with pCaster^ do
   with uid^ do
   with player^ do
   case uid_ability of
   uab_Teleport        : unit_pability:=unit_ability_Recall     (pCaster,taru,NOTSET,false);
   uab_UACScan         : unit_pability:=unit_ability_UACScan    (pCaster,tarx,tary  ,false);
   uab_UACStrike       : unit_pability:=unit_ability_UACStrike  (pCaster,tarx,tary  ,false);
   uab_HTowerBlink     : unit_pability:=unit_ability_HTowerBlink(pCaster,tarx,tary  ,false);
   uab_HKeepShift      : unit_pability:=unit_ability_HKeepBlink (pCaster,tarx,tary  ,false);
   uab_SphereInvuln: unit_pability:=unit_ability_HInvuln    (pCaster,taru       ,false);
   uab_HEyeVision      : unit_pability:=unit_ability_HellVision (pCaster,taru       ,false);
   uab_UACCCLand           : if(speed>0)
                         then unit_SetDefaultUO(pCaster,ua_psability,0,tarx,tary-fly_hz,-1,-1,true ,false)
                         else
                         begin
                            unit_pability:=unit_sability(pCaster,false);
                            if(unit_pability=0)then
                            unit_SetDefaultUO(pCaster,ua_psability,0,tarx,tary-fly_hz,-1,-1,true,true);
                         end;
   uab_SpawnLost,
   uab_RebuildInPoint,
   uab_Unload          : unit_SetDefaultUO(pCaster,ua_psability,0,tarx,tary,-1,-1,true,false);
   end;
end;

procedure unit_prod(pu:PTUnit);
var i:integer;
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
   if(iscomplete)and(hits>0)then
   begin
      unit_end_uprod(pu);
      unit_end_pprod(pu);

      uXCheck(@uid_x[            uidi]);
      uXCheck(@ucl_x[uid_isbuilding,uid_class]);

      // REGENERATION
      if(cycle_order=g_cycle_regen)then
       if(buffs[ub_Damaged]<=0)and(hits<uid_MaxHits1)then
       begin
          i:=upgr[uid_upgr_Regen];
          if(uid_isbuilding)
          then i+=upgr[upgr_race_regen_build[uid_race]]
          else
            if(uid_ismech)
            then i+=upgr[upgr_race_regen_mech[uid_race]]
            else i+=upgr[upgr_race_regen_bio [uid_race]];
          i:=(i*BaseArmorBonus1)+uid_BaseRegen;

          if(i>0)then
          begin
             hits+=i;
             if(hits>uid_MaxHits1)then hits:=uid_MaxHits1;
          end;
       end;
   end
   else
     if(cenergy>=0)then
     begin
        if(g_cycle_order=cycle_order)and(buffs[ub_Damaged]<=0)then
        begin
           hits+=uid_ProdHitStep;
           hits+=uid_ProdHitStep*upgr[upgr_fast_build];
        end;

        if(hits>=uid_MaxHits1){$IFDEF DEBUG0}or(test_InstaProd){$ENDIF}then
        begin
           hits:=uid_MaxHits1;
           iscomplete :=true;
           unit_bld_inc_cntrs(pu);
           cenergy+=uid_EnergyReq;
           GameLogUnitReady(pu);
        end;
     end;
end;

procedure GameObjectsCode;
var u : integer;
pu,
pTransportU: PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=g_punits[u];
      with pu^ do
      if(hits>dead_hits)then
      begin
         if(cycle_order=g_cycle_order)then
           unit_reveal(pu,false);

         unit_counters(pu);

         if(hits>0)then
         begin
            unit_Bonuses(pu);
            unit_order(pu);

            if(hits<=0)then continue;

            if(ServerSide)then
            begin
               unit_move(pu);
               unit_prod(pu);

               if(player^.state=ps_AI)then ai_Global_ScoutPick(pu);
            end;

            pTransportU:=nil;
            if(cycle_order=g_cycle_order)and(hits>0)then
              if(ServerSide)and(not IsUnitRange(transportU,@pTransportU))
              then unit_mcycle   (pu)
              else unit_mcycle_cl(pu,pTransportU);

            if(ServerSide)then
              if(not IsUnitRange(transportU,nil))then
                unit_CaptureKPoint(pu);
         end
         else unit_death(pu);

         unit_MoveVis(pu);
      end;
   end;

   missile_Cycle;
end;

////////////////////////////////////////////////////////////////////////////////




