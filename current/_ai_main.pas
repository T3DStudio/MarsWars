
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON
//

procedure ai_Suicide(pu:PTUnit);
begin
   unit_kill(pu,false,false,true,false,true);
end;

procedure ai_RunTo(pu,otar:PTUnit;ox,oy,odist,ow:integer);
begin
   with pu^  do
   begin
      if(otar<>nil)then
      begin
         ox:=otar^.x;
         oy:=otar^.y;
      end;
      if(odist<0)
      or(odist=NOTSET)then odist:=point_dist_int(x,y,ox,oy);
      if(ow=0)or(odist>base_r1)then
      begin
         uo_x:=ox;
         uo_y:=oy;
      end
      else
        if(ow<0)then
        begin
           if(ox=x)
           then uo_x:=ox+g_randomr(-ow)
           else uo_x:=ox+(sign(ox-x)*g_random(-ow));
           if(oy=y)
           then uo_x:=oy+g_randomr(-ow)
           else uo_y:=oy+(sign(oy-y)*g_random(-ow));
        end
        else
        begin
           uo_x:=ox-g_randomr(ow);
           uo_y:=oy-g_randomr(ow);
        end;
      uo_tar:=0;
   end;
end;

procedure ai_DefaultIdle(pu:PTUnit;force:boolean=false);
begin
   with pu^ do
   begin
      uo_x:=mm3i(1,uo_x,map_Size1);
      uo_y:=mm3i(1,uo_y,map_Size1);
      if(point_dist_rint(x,y,uo_x,uo_y)<srange)
      or(force)
      or(not isfly and (mapZone<>map_GetZone(uo_x,uo_y)))
      or(g_CheckRoyalBattlePoint(uo_x,uo_y,base_r1))
      then ai_RunTo(pu,nil,g_random(map_Size1),
                           g_random(map_Size1),NOTSET,0);
   end;
end;

procedure ai_BaseIdle(pu:PTUnit;idle_r:integer);
var
base_u:PTUnit;
base_d:integer;
begin
   if(ai_BaseOwn_d=NOTSET)then
   begin
      base_u:=ai_BaseAlly_u;
      base_d:=ai_BaseAlly_d;
   end
   else
   begin
      base_u:=ai_BaseOwn_u;
      base_d:=ai_BaseOwn_d;
   end;

   if(base_d=NOTSET)
   then ai_DefaultIdle(pu)
   else
     if(idle_r<base_d)and(base_d<NOTSET)
     then ai_RunTo(pu,base_u,0,0,base_d,base_r1)
     else
       with pu^ do
         if(aiu_alarm_d<NOTSET)
         then ai_RunTo(pu,nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,0)
         else
           if(point_dist_rint(x,y,uo_x,uo_y)<idle_r)then
             ai_RunTo(pu,nil,g_random(map_Size1),
                             g_random(map_Size1),NOTSET,0);
end;

procedure ai_RunFrom(pu,tu:PTUnit;tx,ty,td:integer);
var
px,py:integer;
begin
   if(tu<>nil)then
   begin
      tx:=tu^.x;
      ty:=tu^.y;
   end;
   with pu^ do
     if(min2i(x,abs(map_Size1-x))<srange)
     or(min2i(y,abs(map_Size1-y))<srange)
     then ai_DefaultIdle(pu)
     else
     begin
        if(tx=x)and(ty=y)then
        begin
           px:=0;
           py:=0;
           case g_tick mod 4 of
           0: px:= 1;
           1: px:=-1;
           2: py:= 1;
           3: py:=-1;
           end;
        end
        else
        begin
           if(td<0)
           or(td=NOTSET)then td:=point_dist_int(x,y,tx,ty);
           if(td<1)then td:=1;
           px:=round(((tx-x)/td)*srange);
           py:=round(((ty-y)/td)*srange);
        end;

        uo_x:=x-px;
        uo_y:=y-py;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//  BUILD ORDER
//

{$include _ai_buildorder.pas}

////////////////////////////////////////////////////////////////////////////////
//
//    OTHER
//

function ai_IsTowerUsefull(pTower:PTUnit):boolean;
begin
   ai_IsTowerUsefull:=true;

   if(ai_generator_d<NOTSET)then
     if (ai_generator_d<ai_generator_kp^.kp_RCapture)
     and(ai_generator_d>ai_generator_kp^.kp_RNoBuild)then exit;

   with pTower^ do
   with player^ do
     if (aiu_alarm_timer<0)
     and(-aiu_alarm_timer>aic_TowerLifeTime)then
       if(ai_curr_Towers>aip_MinTowers)
       or((ai_BaseAlly_d>base_r1)and(ai_BaseOwn_d>base_r1))then
         ai_IsTowerUsefull:=false;
end;

function ai_NeedSuicide(pu:PTUnit):boolean;
var i:integer;
begin
   ai_NeedSuicide:=false;

   with pu^     do
   with uid^    do
   with player^ do
     if((ai_selfUID_nocomplete=0)and(    iscomplete))
     or((ai_selfUID_nocomplete>0)and(not iscomplete))then
       case uidi of
       UID_HCommandCenter,
       UID_HACommandCenter: if ((units_uid_e[UID_HCommandCenter]+units_uid_e[UID_HACommandCenter])>=PlayerMaxBuilders)
                            and(ai_available_HKeep)then ai_NeedSuicide:=true;

       UID_UWeaponFactory,
       UID_HPools,
       UID_UBarracks,
       UID_UFactory,
       UID_HBarracks,
       UID_HGate          : if(not unit_IsProducting(pu))then
                              if(units_uid_c[uidi]>1)and(ai_selfUID_minLevel=level)then
                              begin
                                 case uidi of
                                 UID_UBarracks: if(units_uid_c[UID_UBarracks]<units_uid_c[UID_UFactory ])then exit;
                                 UID_UFactory : if(units_uid_c[UID_UFactory ]<units_uid_c[UID_UBarracks])then exit;
                                 UID_HGate    : if(res_UACLoot>0)and(units_uid_c[UID_HBarracks]> 3)then exit;
                                 UID_HBarracks: if(res_UACLoot>0)and(units_uid_c[UID_HBarracks]<=3)then exit;
                                 end;

                                 i:=ai_GetLevel(pu);
                                 if(uid_isbarrack)and((ai_curr_UnitProds-i-4)>ai_need_UnitProds)then ai_NeedSuicide:=true;
                                 if(uid_isforge  )and((ai_curr_UpgrProds-i-2)>ai_need_UpgrProds)then ai_NeedSuicide:=true;
                              end;
       UID_HFTower,
       UID_HTotem         : if (not ai_IsTowerUsefull(pu))then ai_NeedSuicide:=true;
       UID_UGTurret,
       UID_UATurret       : if (upgrs_cur[upgr_uac_DronTurret]=0)
                            and(not ai_IsTowerUsefull(pu))then ai_NeedSuicide:=true;
       else
          //if(not uid_isbuilding)then
          //  if((MaxPlayerLimit-armylimit-prod_unit_Limit-ai_ownDead_limit)<ai_NeedFreeLimit)and(ai_enemy_d>base_r2)and(a_rld=0)then ai_NeedSuicide:=true;
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UPGRADE/TRANSFORM ABILITIES
//

function ai_AbilitiesTransformIf(pu:PTUnit):boolean;
begin
   with pu^ do
     ai_AbilitiesTransformIf:=(buffs[ub_damaged]<=0)
                           and(hits>uid^.uid_MaxHitsh);
end;

procedure ai_AbilitiesTransform(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     case uidi of
UID_HKeep,
UID_HCommandCenter,
UID_UCommandCenter: if(u_royal_d>base_r3)
                    or(map_scenario<>mc_royale)then
                      if(ai_curr_UnitProds>1)
                      and(ai_BuildersInConstruction<units_builders_e)
                      and((aip_flags and aif_army_early_attack0)=0)
                      and(units_bld_l[false]>=aip_MaxUnitMinPart)
                      then
                        case uidi of
                        UID_HKeep         : ai_UnitAbility(pu,uab_ToHAKeep         ,0,0,0);
                        UID_HCommandCenter: ai_UnitAbility(pu,uab_ToHACommandCenter,0,0,0);
                        UID_UCommandCenter: ai_UnitAbility(pu,uab_ToUACommandCenter,0,0,0);
                        end;
UID_HGate,
UID_HBarracks,
UID_UBarracks,
UID_UFactory,
UID_HPools,
UID_UWeaponFactory: if(u_royal_d>base_r3)
                    or(map_scenario<>mc_royale)then
                      if(not unit_IsProducting(pu))then
                        case uidi of
                        UID_HGate         : ai_UnitAbility(pu,uab_ToHGate         ,0,0,0);
                        UID_HBarracks     : ai_UnitAbility(pu,uab_ToHBarracks     ,0,0,0);
                        UID_UBarracks     : ai_UnitAbility(pu,uab_ToUBarracks     ,0,0,0);
                        UID_UFactory      : ai_UnitAbility(pu,uab_ToUFactory      ,0,0,0);
                        UID_HPools        : ai_UnitAbility(pu,uab_ToHPools        ,0,0,0);
                        UID_UWeaponFactory: ai_UnitAbility(pu,uab_ToUWeaponFactory,0,0,0);
                        end;

UID_URadar        : ai_UnitAbility(pu,uab_LvlUpURadar    ,0,0,0);
UID_URMStation    : ai_UnitAbility(pu,uab_LvlUpURMStation,0,0,0);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    OTHER ABILITIES
//

procedure ai_ability_TowerBlink2Dir(pCaster:PTunit;tx,ty,tStep,tdirSpread:integer);
var tdir:integer;
begin
   with pCaster^ do
   begin
      tdir:=point_dir(x,y,tx,ty)+tdirSpread;
      tx:=x+trunc(tStep*cos(tdir*DEGTORAD));
      ty:=y-trunc(tStep*sin(tdir*DEGTORAD));
      if(ai_UnitAbility(pCaster,uab_HTowerBlink,0,tx,ty))then aiu_alarm_timer:=0;
   end;
end;
function ai_ability_KeepShift(pCaster:PTunit;tx,ty:integer):boolean;
begin
   with pCaster^ do
   begin
      ai_ability_KeepShift:=ai_UnitAbility(pCaster,uab_HKeepShift,0,tx,ty);
      aiu_BuildAttempts:=0;
   end;
end;

function ai_ability_CCLift(pCaster:PTunit):boolean;
begin
   ai_ability_CCLift:=false;
   with pCaster^ do
   begin
      //if(isselected)then writeln('ai_ability_CCLift');
      case uidi of
      UID_HCommandCenter,
      UID_HACommandCenter: ai_ability_CCLift:=ai_UnitAbility(pCaster,uab_HellCCLand,0,0,0);
      UID_UCommandCenter,
      UID_UACommandCenter: ai_ability_CCLift:=ai_UnitAbility(pCaster,uab_UACCCLand ,0,0,0);
      end;
      aiu_BuildAttempts:=0;
   end;
end;

function ai_AbilityMagic(pCaster,pTarget:PTUnit;aid:byte):boolean;
begin
   ai_AbilityMagic:=false;
   if(pTarget<>nil)then
     with pTarget^ do
       ai_AbilityMagic:=ai_UnitAbility(pCaster,aid,unum,x,y);
end;

function ai_AbilityDronToTower:boolean;
begin
   ai_AbilityDronToTower:=false;
   if(u_royal_d>base_r1)then
   begin
      if(ai_generator_d<NOTSET)then
        if (ai_generator_d<ai_generator_kp^.kp_RCapture)
        and(ai_generator_d>ai_generator_kp^.kp_RNoBuild)then ai_AbilityDronToTower:=true;
      if(ai_keypoint_d <NOTSET)and(map_scenario=mc_koth)then
        if(ai_keypoint_d <ai_keypoint_kp^.kp_RCapture)then ai_AbilityDronToTower:=true;
   end;
end;

procedure ai_AbilitiesCommon(pCaster:PTunit);
var
cx,cy,cd:integer;
begin
   cd:=NOTSET;
   with pCaster^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HFTower,
     UID_HTotem      : if(a_rld<=0)and(aiu_alarm_d>srange)then
                       begin
                          if(ai_keypoint_d<NOTSET)then
                            with ai_keypoint_kp^ do
                              if(kp_zone=mapZone)then
                              begin
                                 if(ai_keypoint_d<kp_RCapture)then exit;
                                 if(ai_keypoint_d<cd)then
                                 begin
                                    cx:=kp_x;
                                    cy:=kp_y;
                                    cd:=ai_keypoint_d;
                                 end;
                              end;
                          if(ai_generator_d<NOTSET)then
                            with ai_generator_kp^ do
                              if(kp_zone=mapZone)then
                              begin
                                 if(ai_generator_d<=kp_RCapture)then exit;
                                 if(ai_generator_d<cd)then
                                 begin
                                    cx:=kp_x;
                                    cy:=kp_y;
                                    cd:=ai_generator_d;
                                 end;
                              end;
                          if(aiu_alarm_d<cd)and(aiu_alarm_d<NOTSET)then
                            if(aiu_alarm_d<base_r2)
                            or((aip_flags and aif_ability_TowerRush)>0)then
                            begin
                               cx:=aiu_alarm_x;
                               cy:=aiu_alarm_y;
                               cd:=aiu_alarm_d;
                            end;


                          if(cd<NOTSET)
                          then ai_ability_TowerBlink2Dir(pCaster,cx,cy,cd,g_randomr(30))  //srange
                          else
                            if(srange<ai_BaseOwn_d)and(ai_BaseOwn_d<NOTSET)then
                              if(aiu_alarm_d=NOTSET)then
                                ai_ability_TowerBlink2Dir(pCaster,ai_BaseOwn_u^.x,ai_BaseOwn_u^.y,min2i(cd,srange),g_randomr(30));
                       end;
     UID_HTeleport   : if(ai_enemy_battle_d<base_r1h)and(ai_HTeleportRecall_u<>nil)then
                         if(ai_HTeleportRecall_u^.aiu_alarm_d>base_r2)then
                           ai_UnitAbility(pCaster,uab_Recall,ai_HTeleportRecall_u^.unum,0,0);
     UID_HAltar      : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_SphereTurbo_u  ,uab_SphereTurbo  ))
                          then aip_timer_magic:=aip_pause_magic
                          else
                            if(ai_AbilityMagic(pCaster,ai_SphereDDamage_u,uab_SphereDDamage))
                            then aip_timer_magic:=aip_pause_magic
                            else
                              if(ai_AbilityMagic(pCaster,ai_SphereRDamage_u,uab_SphereRDamage))
                              then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_UHPowerConductor
                     : if(aip_timer_magic=0)then
                       begin
                          if(ai_AbilityMagic(pCaster,ai_SphereInvuln_u,uab_SphereInvuln))
                          then aip_timer_magic:=aip_pause_magic
                          else
                            if(ai_AbilityMagic(pCaster,ai_SphereSoul_u,uab_SphereSoul))
                            then aip_timer_magic:=aip_pause_magic
                            else
                              if(ai_SphereInvis_u<>ai_SphereInvuln_u)then
                                if(ai_AbilityMagic(pCaster,ai_SphereInvis_u,uab_SphereInvis))
                                then aip_timer_magic:=aip_pause_magic;
                       end;
     UID_UAcademy    : if(aip_timer_magic=0)then
                         if(ai_AbilityMagic(pCaster,ai_Heroic_u,uab_UACGeneral))then aip_timer_magic:=aip_pause_magic;
     UID_URMStation  : if(aip_timer_superweapon=0)then
                         if(ai_AbilityMagic(pCaster,ai_Strike_u,uab_UACStrike ))then aip_timer_superweapon:=aip_pause_superweapon;

     UID_Pain        : if ((units_bld_l[false]+prod_unit_Limit)<aip_MaxUnitLimit)
                       and((MaxPlayerLimit-armylimit-prod_unit_Limit)>ul1)then
                       begin
                          if(upgrs_cur[upgr_hell_Phantoms]>0)
                          then cx:=UID_Phantom
                          else cx:=UID_LostSoul;

                          if(units_uid_e[cx]<units_uid_m[cx])then
                            if((base_r1h<ai_enemy_battle_d)and(ai_enemy_battle_d<base_r2))
                            or((ai_ZombieTarget_d<base_r1h)and(upgrs_cur[upgr_hell_Phantoms]>0))
                            or(units_uid_e[cx]=0)then
                              ai_UnitAbility(pCaster,uab_SpawnLost,0,0,0);
                       end;
     UID_UACDron     : if(ai_enemy_d>base_r1)and(ai_AbilityDronToTower)then
                         if(ai_towers_near_AG<=ai_towers_near_AA)
                         then ai_UnitAbility(pCaster,uab_ToUGTurretTo,0,x,y)
                         else ai_UnitAbility(pCaster,uab_ToUATurretTo,0,x,y);

     UID_UGTurret,
     UID_UATurret    : if (upgrs_cur[upgr_uac_DronTurret]>0)
                       and(not ai_IsTowerUsefull(pCaster))
                       then ai_UnitAbility(pCaster,uab_ToUACDron,0,0,0)
                       else
                         if(ai_enemy_d>base_r2)then
                           case uidi of
                           UID_UGTurret: if(ai_towers_near_AG>0)and(ai_towers_near_AA=0)then ai_UnitAbility(pCaster,uab_ToUAATurret,0,0,0);
                           UID_UATurret: if(ai_towers_near_AA>0)and(ai_towers_near_AG=0)then ai_UnitAbility(pCaster,uab_ToUAGTurret,0,0,0);
                           end;

     end;

   with pCaster^ do
     with player^ do
       if(mapZone<>zone_solid)and(ai_HEyeNest_u<>nil)and(ai_near_HEye<=0)and(ai_need_heye_u=nil)and(aip_timer_magic=0)then
         if(ai_UnitAbility(ai_HEyeNest_u,uab_HEyeSpawn,0,x,y))then aip_timer_magic:=aip_pause_magic;

   if(ai_Bribe_u<>nil)
   or(ai_Hack_u <>nil)then
     if(IsUnitRange(pCaster^.player^.units_uid_u[UID_UAcademy],@pCaster))then
       with pCaster^.player^ do
       begin
          if(ai_Bribe_u<>nil)and(aip_timer_magic=0)then
            if(ai_UnitAbility(pCaster,uab_Bribe,ai_Bribe_u^.unum,0,0))then aip_timer_magic:=aip_pause_magic;
          if(ai_Hack_u <>nil)and(aip_timer_magic=0)then
            if(ai_UnitAbility(pCaster,uab_Hack ,ai_Hack_u^ .unum,0,0))then aip_timer_magic:=aip_pause_magic;
       end;
end;


procedure ai_AbilitiesDetection(pCaster:PTunit);
begin
   with pCaster^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HEyeNest: begin
                      //if(isselected)then writeln('ai_need_heye_d ',ai_need_heye_d,' ai_AvailableDetectors ',ai_AvailableDetectors);
                      if(ai_need_heye_d<NOTSET)then
                        if(ai_UnitAbility(pCaster,uab_HEyeVision,ai_need_heye_u^.unum,0,0))then
                          aip_timer_detection:=aip_pause_detection;
                   end;
     UID_URadar  : begin
                      if(ai_enemy_inv_d<NOTSET)then
                        if(ai_UnitAbility(pCaster,uab_UACScan   ,0,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y))then
                          aip_timer_detection:=aip_pause_detection;
                      if(ai_need_heye_u<>nil)then
                        if(ai_UnitAbility(pCaster,uab_UACScan   ,0,ai_need_heye_u^.x,ai_need_heye_u^.y))then
                          aip_timer_detection:=aip_pause_detection;

                      if(map_GeneratorT<mapg_inf)and(ai_choosen)and(units_uid_e[uidi]>2)then
                      begin
                         if(ai_generator_d=NOTSET)then
                           if(group=8)
                           then group:=9
                           else group:=8
                         else
                           with ai_generator_kp^ do
                             if(ai_UnitAbility(pCaster,uab_UACScan,0,kp_x,kp_y))then
                             begin
                                if(group=8)
                                then group:=9
                                else group:=8;
                                exit;
                             end;
                      end;

                      if(aiu_alarm_d=NOTSET)then
                        ai_UnitAbility(pCaster,uab_UACScan,0,g_random(map_Size1),g_random(map_Size1));
                   end;
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MAIN MOVE
//

procedure ai_AbilitiesBuilderMove(pBuilder:PTUnit);
const
met_koth   = 1;
met_royale = 2;
met_hits   = 3;
met_build  = 4;
var
ldir,lx,ly:integer;
alarmType :byte;
function RoyalCR:integer;
begin
   RoyalCR:=min2i(g_royal_RCur div 3,base_r1h);
end;

function moveEventType:byte;
begin
   moveEventType:=0;
   case map_scenario of
   mc_koth  : with pBuilder^ do
              with player^ do
                if (ai_choosen)
                and(map_scenario=mc_koth)
                and(ai_keypoint_d<NOTSET)
                and(units_builders_c>=aip_MaxBuilders)
                and(ai_BuildersInTransform=0)then
                  if ((units_uid_e[UID_HKeep]+units_uid_e[UID_HAKeep])=0)
                  or not (pBuilder^.uidi in [UID_HCommandCenter,UID_HACommandCenter,UID_UCommandCenter,UID_UACommandCenter])then
                    with ai_keypoint_kp^ do
                      if(kp_RCapture<ai_keypoint_d)
                      or(pBuilder^.isfly)then
                      begin
                         moveEventType:=met_koth;
                         exit;
                      end;
   mc_royale: case pBuilder^.isfly of
              true : if(u_royal_d<base_r1h)then
                     begin
                        moveEventType:=met_royale;
                        exit;
                     end;
              false: if(u_royal_d<base_r1)then
                     begin
                        moveEventType:=met_royale;
                        exit;
                     end;
              end;

   end;

   with pBuilder^ do
     if(not (map_scenario=mc_koth))
     or(ai_keypoint_d>keyPoint_KotR)then
       if (ai_enemy_d<base_r2)
       and(hits<uid^.uid_MaxHitsh)then
       begin
          moveEventType:=met_hits;
          exit;
       end;

   with pBuilder^ do
     if(not pBuilder^.isfly)then
       if(ai_MinBuildAttempts>50)and(ai_MinBuildAttempts=aiu_BuildAttempts)then
       begin
          moveEventType:=met_build;
          exit;
       end;
end;
function checkLandingPlace(lx,ly,lr:integer):boolean;
begin
   checkLandingPlace:=false;
   with pBuilder^ do
   with uid^ do
   begin
      if(point_dist_int(uo_x,uo_y,lx,ly)>=lr)then exit;
      if(map_scenario=mc_royale)then
        if(base_r1h>(g_royal_RCur-point_dist_int(uo_x,uo_y,g_royal_Rx,g_royal_Ry)))then exit;
      if(CheckCollisionR(uo_x,uo_y,uid_r,unum,uid_isbuilding,true,255,pBuilder)<>cbr_no)then exit;
   end;
   checkLandingPlace:=true;
end;
procedure setLandingPlace(lx,ly,ld,lr:integer);
begin
   with pBuilder^ do
   with uid^ do
     if(ld>lr)then
     begin
        uo_x:=lx;
        uo_y:=ly;
     end
     else
       if(checkLandingPlace(uo_x,uo_y,lr))then
       begin
          if(point_dist_int(x,y,uo_x,uo_y)<uid_r)then
          begin
             uo_id :=ua_ability2;
             uo_tar:=0;
          end
          else uo_id:=ua_amove;
       end
       else
       begin
          uo_x:=lx-g_randomr(lr);
          uo_y:=ly-g_randomr(lr);
          math_push_out(uo_x,uo_y,uid_r,unum,@uo_x,@uo_y,true,playeri );
       end;
end;
begin
   if((pBuilder^.player^.aip_flags and aif_base_BuilderMove )>0)
   then alarmType:=moveEventType
   else exit;
   {if(pBuilder^.isselected)then
   begin
      writeln('alarmType ',alarmType,' ',ai_choosen,' ',u_royal_d,' ',base_r1h,' ',(u_royal_d<base_r1h));
      //writeln('ai_choosen ',ai_choosen,' (map_scenario=mc_koth)=',(map_scenario=mc_koth),' ai_keypoint_d=',ai_keypoint_d);
   end;}
   with pBuilder^ do
   with uid^    do
   with player^ do
     case uidi of
     UID_HKeep,
     UID_HAKeep         : case alarmType of
                          met_koth  : with ai_keypoint_kp^ do
                                        ai_ability_KeepShift(pBuilder,kp_x+g_randomr(keyPoint_KotRW),
                                                                      kp_y+g_randomr(keyPoint_KotRW));
                          met_royale: begin
                                         lx:=RoyalCR;
                                         ai_ability_KeepShift(pBuilder,g_royal_Rx+g_randomr(lx),
                                                                       g_royal_Ry+g_randomr(lx));
                                      end;
                          met_hits  : begin
                                         lx:=g_random(map_size1);
                                         ly:=g_random(map_size1);
                                         if(not ai_alarm_CheckPoint(pBuilder,lx,ly,base_r2))then
                                           ai_ability_KeepShift(pBuilder,lx,ly);
                                      end;
                          met_build : begin
                                         if(aiu_alarm_d<base_r4)
                                         then ldir:=point_dir(aiu_alarm_x,aiu_alarm_y,x,y)-g_randomr(45)
                                         else ldir:=g_random(360);
                                         ai_ability_KeepShift(pBuilder,
                                            x+trunc((srange+uid_r)*cos(ldir*degtorad)),
                                            y-trunc((srange+uid_r)*sin(ldir*degtorad)));
                                      end;
                          end;
     UID_HCommandCenter,
     UID_HACommandCenter,
     UID_UCommandCenter,
     UID_UACommandCenter: if(zfall=0)then
                            case isfly of
                            true : case alarmType of
                                   met_koth  : with ai_keypoint_kp^ do
                                                 setLandingPlace(kp_x,kp_y,ai_keypoint_d,keyPoint_KotRW);
                                   met_royale: begin
                                                  lx:=min2i(g_royal_RCur div 3,base_r1h);
                                                  setLandingPlace(g_royal_Rx,g_royal_Ry,u_royal_cd,lx);
                                               end;
                                   met_hits  : ai_RunFrom(pBuilder,ai_enemy_u,0,0,ai_enemy_d);
                                   // met_build
                                   else
                                      if(ai_BaseOwn_d<NOTSET)
                                      then setLandingPlace(ai_BaseOwn_u^.x,ai_BaseOwn_u^.y,ai_BaseOwn_d,base_r1)
                                      else setLandingPlace(x,y,0,base_r1h);
                                   end;
                            false: if(alarmType>0)then ai_ability_CCLift(pBuilder);
                            end;
     end;
end;

procedure ai_Cancel_Prod(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
     if(prod_unit_Now>0)then
     begin
        if(uid_isbarrack)then unit_ProdStopUnit(pu,255,false,true,false);
     end
     else
       if(prod_upgr_Now>0)then
       begin
          if(uid_isforge)then unit_ProdStopUpgrade(pu,255,false,true,false);
       end
       else
         if(ai_UnitsInTransform>0)then
         begin
            if(transformTimer>0)then unit_TransformStop(pu,false);
         end
         else
           if(not iscomplete)then
             if((energyCur_BldGens>0)and(uid_gen_EnergyLevel=0))
             or(uid_gen_EnergyLevel=0)
             //if((uid_gen_EnergyLevel>0)and(energyCur_BldGens >0))
             //or((uid_gen_EnergyLevel=0)and(energyCur_BldOther>0))
             then ai_Suicide(pu);
end;


////////////////////////////////////////////////////////////////////////////////
//
//    BUILDINGS AI
//

procedure ai_Global_Buildings(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      ai_CalcBuildNeed(pu);

      if(uid_isbuilder)and(not isfly)and(zfall=0)and(build_cd<=0)then ai_Builder(pu);

      //if(isselected)then writeln(ai_curr_UnitProds,' ',ai_need_UnitProds,' ',ai_selfUID_nocomplete);

      if((aip_flags and aif_base_suicide)>0)then
        if(ai_NeedSuicide(pu))then
        begin
           ai_Suicide(pu);
           exit;
        end;

      if(res_energyl_cur<0)then
      begin
         ai_Cancel_Prod(pu);
         exit;
      end;

      if(uid_isbarrack)and(prod_unit_Now>0)and((armylimit+prod_unit_Limit)>MaxPlayerLimit)then
        unit_ProdStopUnit(pu,255,false,true,false);

      if(not iscomplete)then exit;

      if(uid_isforge  )and(aip_MaxUpgradeLevel>0)then ai_Forge(pu);
      if(uid_isbarrack)and(aip_MaxUnitLimit   >0)then
        if((aip_flags and aif_army_smart_order)>0)
        then ai_Barrack(pu,uprod_base  )
        else ai_Barrack(pu,uprod_random);

      // Transformation
      //if(isselected)then writeln(aiu_alarm_d);
        {writeln(ai_AbilitiesTransformIf(pu),' ',
                aiu_limitaround_ally,' ',
                aiu_limitaround_enemy,' ',
                (buffs[ub_damaged]<=0),' ',
                (hits>uid^.uid_MaxHitsh),' ',
                ai_flags_BaseAMain,' ',
                (res_energyl_max-energyCur_builds-energyCur_transforms),' ',uid_req_EnergyLevel);   }

      case ai_AbilitiesTransformIf(pu) of
      true : case uid_isbuilder of
             true : if(ai_flags_BaseAMain)then
                    begin
                       if(transformTimer<=0)then
                         ai_AbilitiesTransform(pu);
                       if(transformTimer>0)then exit;
                    end;
             false: if(ai_flags_BaseAOther)then
                    begin
                       if(transformTimer<=0)then
                         ai_AbilitiesTransform(pu);
                       if(transformTimer>0)then exit;
                    end;
             end;
      false: if(transformTimer>0)then unit_TransformStop(pu,false);
      end;

      {if(isselected)and(ai_enemy_inv_d<NOTSET)then
      begin
         UnitsInfo_AddLine(x,y,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y+1,c_blue);
         UnitsInfo_AddLine(x+2,y,uo_x,uo_y+2,c_yellow);
      end; }

      if(aip_timer_detection=0)then
        if((aip_flags and aif_ability_detection)>0)then ai_AbilitiesDetection(pu);
      if(uid_isbuilder)then                             ai_AbilitiesBuilderMove(pu);
      if((aip_flags and aif_ability_other      )>0)then ai_AbilitiesCommon(pu);
   end;
end;


////////////////////////////////////////////////////////////////////////////////
//
//    UNITS AI
//

{$include _ai_main_units.pas}

////////////////////////////////////////////////////////////////////////////////
//
//    MAIN
//

procedure ai_Local_Code(pu:PTUnit);
var i:integer;
    l:longint;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      {if(isselected)and(ai_enemy_d<NOTSET)then
      begin
         UnitsInfo_AddLine(x+1,y,ai_enemy_u^.x,ai_enemy_u^.y+1,c_orange);
         writeln('ai_enemy_d ',ai_enemy_d,' srange',srange,' ai_enemy_z ',ai_enemy_u^.mapZone);
      end;}

      // correct alarm in position
      i:=max2i(200,srange);
      if(ai_enemy_d>=srange)then ai_Alarm_SetForTeam(team,x,y,0,i,false,0);// erase alarm point here
      if(ai_enemy_d<NOTSET)then
      begin
         with ai_enemy_u^ do
         begin
            l:=uid^.uid_LimitUse;
            if(ai_enemy_d<srange)then l+=aiu_limitaround_enemy;
            ai_Alarm_SetForTeam(team,x,y,l,i,uid^.uid_isbuilding,mapZone);
         end;
         ai_Local_SetCurrentAlarm(pu,ai_enemy_u,0,0,ai_enemy_d,0);
      end;

      // base alarm
      for i:=0 to ai_LastAlarm do
        with ai_TeamAlarms[team,i] do
          if(aia_limit>0)then
            if(uid_isfly)
            or(isfly)
            or(aia_zone=mapZone)
            or(uid_isbarrack)
            or(uid_ability_isradar)then
              ai_Local_SetCurrentAlarm(pu,nil,aia_x,aia_y,point_dist_int(aia_x,aia_y,x,y),aia_zone);

      case(aiu_alarm_d<base_r2)of
      true : if(aiu_alarm_timer<0)
             then aiu_alarm_timer:=0
             else
               if(aiu_alarm_timer<(aiu_alarm_timer.MaxValue-order_period))
               then aiu_alarm_timer+=order_period;
      false: if(aiu_alarm_timer>0)
             then aiu_alarm_timer:=0
             else
               if(aiu_alarm_timer>(aiu_alarm_timer.MinValue+order_period))
               then aiu_alarm_timer-=order_period;
      end;
   end;
end;

procedure ai_Global_Code(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      //if(isselected)then
      //  if(ai_HTeleportNearest_u<>nil)then UnitsInfo_AddLine(x,y,ai_HTeleportNearest_u^.x,ai_HTeleportNearest_u^.y,c_lime);
      //if(isselected)then writeln('ai_selfUID_minLevel=',ai_selfUID_minLevel,'  ai_selfUID_nocomplete=',ai_selfUID_nocomplete);
      {if(isselected)then
      begin
         //writeln(aiu_alarm_timer,' ',aic_TowerLifeTime);
         //writeln((ai_generator_d<NOTSET),' ',(ai_keypoint_d<NOTSET));
         if(ai_generator_d<NOTSET)then
           with ai_generator_kp^ do
           begin
              UnitsInfo_AddLine(x,y,kp_x,kp_y,c_blue);
              //writeln( kp_LimitPlayerP[playeri],' ',(keyPoint_MinLimit  +uid_LimitUse),' ',ai_generator_d,' ',kp_RCapture);
           end;
         {if(ai_keypoint_d<NOTSET)then
           with ai_keypoint_kp^ do UnitsInfo_AddLine(x+2,y,kp_x,kp_y,c_green);
         //if(ai_BaseOwn_d<NOTSET)then UnitsInfo_AddLine(x,y,ai_BaseOwn_u^.x,ai_BaseOwn_u^.y,c_lime); }


         //writeln((ai_need_heye_u<>nil),' ',(ai_enemy_inv_u<>nil),' ',ai_need_detect);
         //if(ai_need_heye_u<>nil)then UnitsInfo_AddLine(x,y,ai_need_heye_u^.x,ai_need_heye_u^.y,c_lime);
         //if(ai_enemy_inv_u<>nil)then UnitsInfo_AddLine(x,y,ai_enemy_inv_u^.x,ai_enemy_inv_u^.y,c_aqua);
      end;}
     { if(isselected)then
      with player^ do
      begin
        { writeln('res_energyl_max=',res_energyl_max,
                ' units=',energyCur_units,
                ' upgrades=',energyCur_upgrades,
                ' transforms=',energyCur_transforms,
                ' BldOther=',energyCur_BldOther,
                ' BldGens=',energyCur_BldGens,
                ' ',res_energyl_max-energyCur_units-energyCur_upgrades-energyCur_transforms-energyCur_BldOther); }

        { writeln({ai_curr_Towers,' ',
                 aip_MinTowers,' ',
                 ai_IsTowerUsefull(pu),' ',
                 ai_BaseAlly_d,' ',ai_BaseOwn_d,' ',
                 (upgrs_cur[upgr_uac_DronTurret]>0),' ',
                 aiu_alarm_timer,' ',
                 aic_TowerLifeTime}
                 (upgrs_cur[upgr_uac_DronTurret]>0)
                                        and(not ai_IsTowerUsefull(pu))
                 );}
      end;  }

      if(uid_isbuilding)
      then ai_Global_Buildings(pu)
      else ai_Global_Units    (pu);

      //if(isselected)then writeln((ai_need_heye_u<>nil),' ',(ai_enemy_inv_u<>nil),' ',ai_need_detect);
   end;
end;


