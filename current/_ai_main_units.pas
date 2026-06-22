
////////////////////////////////////////////////////////////////////////////////
//
//    UNITS AI
//

procedure ai_Global_Units(pu:PTUnit);
var
tar_dist,
tar_x,
tar_y,
tar_r,
tar_weight:integer;
tar_zone  :word;
////  GROUP ACTIONS
procedure MainTargetClear;
begin
   tar_weight:=NOTSET;
   tar_dist  :=NOTSET;
end;
procedure MainTargetSet(tu:PTUnit;tx,ty,tdist:integer;tz:word;tweight,tr:integer);
begin
   if(tu<>nil)then
   begin
      tx:=tu^.x;
      ty:=tu^.y;
      tz:=tu^.mapZone;
   end;
   with pu^ do
     if(mapZone=tz)or(tdist<base_r1)or(isfly)then
     begin
        if(tweight<tar_weight)
        then
        else
          if(tweight>tar_weight)
          then exit
          else
            if(tdist<tar_dist)
            then
            else exit;

        tar_x     :=tx;
        tar_y     :=ty;
        tar_r     :=tr;
        tar_dist  :=tdist;
        tar_zone  :=tz;
        tar_weight:=tweight;
     end;
end;
procedure MainTargetSetKeyPoint;
var p:integer;
begin
   if(ai_keypoint_d<NOTSET)then
     with ai_keypoint_kp^ do
     begin
        p:=ai_keypoint_d;
        case map_scenario of
        mc_koth     : if(ai_keypoint_d>kp_RCapture)
                      then p:=p div 4
                      else p:=p*3;
        mc_keypoints: p:=p div 2;
        end;
        MainTargetSet(nil,kp_x,kp_y,ai_keypoint_d ,kp_zone,p,kp_RCapture);
     end;
end;
procedure MainTargetSetDefault;
begin
   MainTargetSetKeyPoint;
   with pu^ do
     if(map_scenario<>mc_koth)
     or(aiu_alarm_d<base_r1h)then
       MainTargetSet(nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,aiu_alarm_zone,aiu_alarm_d,0);
   if(ai_BaseDef_d<NOTSET)then
     with ai_BaseDef_u^ do
       MainTargetSet(nil,aiu_alarm_x,aiu_alarm_y,ai_BaseDef_d,mapZone,ai_BaseDef_d div 2,0);
end;

function MainTargetGo(wrect:integer):boolean;
begin
   MainTargetGo:=false;
   if(tar_dist<NOTSET)then
   begin
      MainTargetGo:=true;
      ai_RunTo(pu,nil,tar_x,tar_y,tar_dist,wrect);
   end;
end;
function FollowCommander:boolean;
var
commander_d:integer;
commander_u:PTUnit;
begin
   FollowCommander:=false;
   commander_d:=NOTSET;
   commander_u:=nil;
   if(pu^.uid^.uid_FlyLevelLikeTarget)then exit;
   if(pu^.isfly)then
   begin
      commander_u:=ai_commander_fly_u;
      commander_d:=ai_commander_fly_d;
      if(ai_commander_grd_u<>nil)then
        if(ai_commander_grd_u^.group<>aic_group_AttackWait)then
        begin
           commander_u:=ai_commander_grd_u;
           commander_d:=ai_commander_grd_d;
        end
   end
   else
   begin
      commander_u:=ai_commander_grd_u;
      commander_d:=ai_commander_grd_d;
   end;
   if(commander_u=nil)
   then commander_u:=pu;

   FollowCommander:=(pu<>commander_u);
   if(FollowCommander)then
   begin
      ai_RunTo(pu,commander_u,0,0,commander_d,-pu^.srange);
      if(commander_d>pu^.srange)and(pu^.a_rld<=0)and(not IsUnitRange(pu^.a_tar,nil))then
      begin
         commander_u^.uo_x:=commander_u^.x;
         commander_u^.uo_y:=commander_u^.y;
      end;
   end;
end;
function TryTeleporting(toU:PTUnit):boolean;
begin
   TryTeleporting:=false;
   if(ai_HTeleportNearest_d<base_r2)then
   begin
      TryTeleporting:=true;
      pu^.uo_x:=ai_HTeleportNearest_u^.x;
      pu^.uo_y:=ai_HTeleportNearest_u^.y;
      if(ai_HTeleportNearest_d<ai_HTeleportNearest_u^.uid^.uid_r)then
      begin
         ai_HTeleportNearest_u^.rpoint_tar:=toU^.unum;
         unit_ability_teleport(pu,ai_HTeleportNearest_u,ai_HTeleportNearest_d);
      end;
   end;
end;
function DefendBase:boolean;
begin
   DefendBase:=false;

   if(ai_BaseDef_d<NOTSET)then
     with ai_BaseDef_u^ do
     begin
        DefendBase:=true;
        if(pu^.isfly)
        then ai_RunTo(pu,nil,aiu_alarm_x,aiu_alarm_y,ai_BaseDef_d,0)
        else
          if(pu^.mapZone=mapZone)then
          begin
             if(ai_BaseDef_d>base_r6)then
                if(TryTeleporting(ai_BaseDef_u))then exit;
             ai_RunTo(pu,nil,aiu_alarm_x,aiu_alarm_y,ai_BaseDef_d,0)
          end
          else DefendBase:=TryTeleporting(ai_BaseDef_u);
     end;
end;
function TransportDropAndRunOut:boolean;
begin
   TransportDropAndRunOut:=false;
   with pu^ do
     case(transportC>0)of
     true : if(tar_dist<base_r1)and(tar_zone=mapZone)then
            begin
               MainTargetGo(-base_r1);
               uo_id:=unit_Ability2Act(pu,uab_Unload);
               TransportDropAndRunOut:=true;
            end;
     false: if(ai_enemy_battle_d<base_r1)and(buffs[ub_damaged]>0)then   //???
            begin
               ai_RunFrom(pu,ai_enemy_battle_u,0,0,ai_enemy_battle_d);
               TransportDropAndRunOut:=true;
            end;
     end;
   //with pu^ do if(isselected)then writeln('TransportDropAndRunOut ',TransportDropAndRunOut,' tar_dist=',tar_dist,' tar_zone=',tar_zone,' mapZone=',mapZone);
end;
procedure TransportGoForUnit(tu:PTUnit;du:integer);
begin
   with pu^ do
   begin
      uo_x:=tu^.x;
      uo_y:=tu^.y;
      if(du<=uid^.uid_r)
      then uo_tar:=tu^.unum
      else uo_tar:=0;
   end;
end;
function TransportBaseDefenders:boolean;
begin
   TransportBaseDefenders:=false;
   if(ai_BaseDef_d<NOTSET)then
     with pu^ do
       if(ai_TransportTar_BDefend_d<NOTSET)
       and((ai_TransportTar_BDefend_d<ai_BaseDef_d)or(transportC<=0))then
       begin
          TransportBaseDefenders:=true;
          TransportGoForUnit(ai_TransportTar_BDefend_u,ai_TransportTar_BDefend_d);
          //with pu^ do if(isselected)then writeln('TransportDefendBase 1',TransportBaseDefenders);
       end
       else
         if(pu^.transportC>0)then
         begin
            ai_RunTo(pu,ai_BaseDef_u,0,0,ai_BaseDef_d,-pu^.srange);
            TransportBaseDefenders:=true;
            //with pu^ do if(isselected)then writeln('TransportDefendBase 2',TransportBaseDefenders);
         end;
end;
function TransportTransferAttackers:boolean;
begin
   TransportTransferAttackers:=false;
   if(tar_dist<NOTSET)then
     if(ai_GroupAll_ulimit[aic_group_AttackWait]>0)
     or(ai_GroupIn_ulimit [aic_group_AttackWait]>0)then
       with pu^ do
        if(ai_TransportTar_Attack_d=NOTSET)
        or((tar_dist<ai_TransportTar_Attack_d)and(transportC>0))then
        begin
           if(transportC>0)then
             if(tar_dist<base_r1)and(tar_zone=mapZone)then
             begin
                uo_id:=unit_Ability2Act(pu,uab_Unload);
                //if(not FollowCommander)then
                MainTargetGo(base_r1);
                TransportTransferAttackers:=true;
             end
             else
             begin
                if(not FollowCommander)then
                  MainTargetGo(base_r1);
                TransportTransferAttackers:=true;
             end;
        end
        else
        begin
           TransportGoForUnit(ai_TransportTar_Attack_u,ai_TransportTar_Attack_d);
           TransportTransferAttackers:=true;
        end;
   //with pu^ do if(isselected)then writeln('TransportTransferAttackers ',TransportTransferAttackers);
end;
function TransportGeneratorTeam:boolean;
begin
   TransportGeneratorTeam:=false;
   if(ai_generator_d<NOTSET)then
     if(ai_GroupAll_ulimit[aic_group_GenWait]>0)
     or(ai_GroupIn_ulimit [aic_group_GenWait]>0)then
       with pu^ do
        if(ai_TransportTar_GenTeam_d=NOTSET)
        or((ai_generator_d<ai_TransportTar_GenTeam_d)and(transportC>0))then
        begin
           if(transportC>0)then
             with ai_generator_kp^ do
             begin
                if(ai_generator_d<srange)and(kp_zone=mapZone)then
                  uo_id:=unit_Ability2Act(pu,uab_Unload);
                ai_RunTo(pu,nil,kp_x,kp_y,ai_generator_d,0);
                TransportGeneratorTeam:=true;
             end;
        end
        else
        begin
           TransportGoForUnit(ai_TransportTar_GenTeam_u,ai_TransportTar_GenTeam_d);
           TransportGeneratorTeam:=true;
        end;
end;

////  SET GROUPS
function NeedScouting:boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
     NeedScouting:=((aip_flags and aif_army_scout)>0)
                and((aip_flags and aif_army_early_attack0)=0)
                and(map_scenario<>mc_koth)
                and(uid_AI_TargetWeight=0);
end;
function NeedCaptureGenerators:boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
     NeedCaptureGenerators:=(ai_generator_d<NOTSET)
                         and(map_generators>0)
                         and(ai_energy_future<aip_MaxEnergy)
                         and(uid_LimitUse<=keyPoint_MaxLimitAI)
                         and(uid_AI_TargetWeight=0);
end;
procedure CheckSetGeneratorGuard;
begin
   with pu^ do
   with uid^ do
     if(ai_generator_d<srange)and(ai_nearGenGuards<keyPoint_MinLimit)and(uid_AI_TargetWeight=0)then
       group:=aic_group_GenGuard;
end;
procedure SetGroupsForHome;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(NeedScouting)then
        if (ai_GroupAll_ucount[aic_group_Scout]=0)
        and(ai_ScoutCandidate_u=pu)
        and(ai_enemy_d>base_r2)then
        begin
           group:=aic_group_Scout;
           exit;
        end;

      if(ai_BaseDef_d>base_r2)then
      begin
         if(NeedCaptureGenerators)then
           if ((ai_GroupAll_ulimit[aic_group_Home      ]
               +ai_GroupAll_ulimit[aic_group_GenAssault]
               +ai_GroupAll_ulimit[aic_group_GenWait   ]
               +ai_GroupAll_ulimit[aic_group_Scout     ])>=aip_MaxUnitMinPart)
           and((ai_GroupAll_ulimit[aic_group_GenAssault]+
                ai_GroupAll_ulimit[aic_group_GenWait   ])< aip_MaxUnitMinPart)then
           begin
              group:=aic_group_GenAssault;
              exit;
           end;

         if (map_scenario=mc_koth)
         and(ai_keypoint_d<NOTSET)
         and(g_tick>=keyPoint_KotH_pause)
         and(ai_armylimit_alive_u>aip_MaxUnitMinPart)then
           with ai_keypoint_kp^ do
             if(kp_zone<>mapZone)
             then group:=aic_group_AttackWait
             else group:=aic_group_AttackNow;
      end;

      if(units_bld_l[true]<=0)
      or((ai_AttackGroupFlyLimit=0)and(ai_GroupAll_ulimit[aic_group_AttackWait]>0)and(uid_CanAttack)and(isfly))then
      begin
         group:=aic_group_AttackNow;
         exit;
      end;

      case uidi of
      UID_LostSoul,
      UID_Phantom : if(NeedCaptureGenerators)
                    then group:=aic_group_GenAssault
                    else group:=aic_group_AttackNow;
      end;

      CheckSetGeneratorGuard;
   end;
end;
////
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      uo_id :=ua_amove;
      uo_tar:=0;

      if(res_energyl_cur<0)then
      begin
         ai_Cancel_Prod(pu);
         if(hits<=0)then exit;
      end;

      //if(isselected)then writeln(ai_NeedLimitForTransport,' ',ai_enemy_d>base_r2,' ',-ai_ownDead_limit,' ',(armylimit+prod_unit_Limit)>(MaxPlayerLimit-g_uids[UID_HTeleport].uid_LimitUse));

      if(ai_NeedSuicide(pu))then
      begin
         ai_Suicide(pu);
         if(hits<=0)then exit;
      end;

      if(not iscomplete)then exit;

      MainTargetClear;

      // SET GROUP
      //if(isselected)then writeln('aiu_alarm_d ',aiu_alarm_d,' ',aiu_alarm_zone,' ',mapZone);

      if(transportM>0)
      then group:=aic_group_Transport
      else
        if(units_bld_l[true]=0)
        then group:=aic_group_AttackNow
        else
          case group of
          aic_group_Home           : SetGroupsForHome;
          aic_group_AttackNow,
          aic_group_AttackWait     : begin
                                        MainTargetSetDefault;
                                        if(tar_dist =NOTSET)
                                        then group:=aic_group_AttackWait
                                        else group:=aic_group_AttackNow;
                                     end;
          aic_group_Scout          : if(not NeedScouting)
                                     then group:=aic_group_Home
                                     else
                                       if(ai_ScoutCandidate_u<>pu)and(ai_BaseOwn_d<base_r1)
                                       then group:=aic_group_Home;
          aic_group_GenAssault,
          aic_group_GenWait        : if(not NeedCaptureGenerators)
                                     then group:=aic_group_Home
                                     else
                                       if(isfly)
                                       then group:=aic_group_GenAssault
                                       else
                                         if(ai_generator_kp^.kp_Zone<>mapZone)
                                         then group:=aic_group_GenWait
                                         else
                                           if(group=aic_group_GenWait)
                                           then group:=aic_group_GenAssault;
          aic_group_GenGuard       : if(ai_generator_d=NOTSET)
                                     then group:=aic_group_Home
                                     else
                                       if(ai_generator_d>srange)
                                       or(ai_generator_kp^.kp_Zone<>mapZone)
                                       then group:=aic_group_Home;
          aic_group_Transport      : if(transportM<=0)then group:=aic_group_Home;
          else group:= aic_group_Home;
          end;

     { if(isselected)then
      begin
         writeln(group);
         if(ai_generator_d<NOTSET)then
           writeln(ai_generator_kp^.kp_Zone,' ',mapZone);

      end;  }

      // GROUP ACTIONS
      case group of
      aic_group_Home           : if(not DefendBase)then
                                   if(not FollowCommander)then
                                   begin
                                      MainTargetSet(nil,aiu_alarm_x,aiu_alarm_y,aiu_alarm_d,aiu_alarm_zone,0,0);
                                      if(tar_dist<srange)
                                      then MainTargetGo(0)
                                      else ai_BaseIdle(pu,aic_BaseIdle_r);
                                   end;
      aic_group_Transport      : begin
                                    MainTargetSetDefault;
                                    if(ai_enemy_d<base_r1)then
                                      MainTargetSet(ai_enemy_u,0,0,ai_enemy_d,0,ai_enemy_d,0);
                                    if(not TransportDropAndRunOut)then
                                      if(not TransportBaseDefenders)then
                                        if(not TransportTransferAttackers)then
                                          if(not TransportGeneratorTeam)then
                                          begin
                                             if(not FollowCommander)then
                                               ai_BaseIdle(pu,aic_BaseIdle_r);

                                             if(transportC>0)then
                                               if(ai_BaseOwn_d<srange)
                                               or(ai_BaseOwn_d=NOTSET)
                                               then uo_id:=unit_Ability2Act(pu,uab_Unload);
                                          end;
                                 end;
      aic_group_GenAssault,
      aic_group_GenGuard       : begin
                                    if(ai_generator_d<NOTSET)then
                                      with ai_generator_kp^ do
                                        MainTargetSet(nil,kp_x,kp_y,ai_generator_d,mapZone,ai_generator_d,round(kp_RCapture*0.6));

                                    if(tar_dist=NOTSET)
                                    then group:=aic_group_Home
                                    else
                                      case group of
                                      aic_group_GenGuard  : if(tar_dist<=srange)
                                                            then MainTargetGo(tar_r)
                                                            else
                                                            begin
                                                               group:=aic_group_GenAssault;
                                                               MainTargetGo(tar_r);
                                                            end;
                                      aic_group_GenAssault: if(tar_dist<tar_r)then
                                                            begin
                                                               group:=aic_group_GenGuard;
                                                               MainTargetGo(tar_r);
                                                            end
                                                            else
                                                              if(not FollowCommander)
                                                              or(tar_dist<=srange)then
                                                                MainTargetGo(tar_r);
                                      end;
                                 end;
      aic_group_AttackNow      : begin
                                    MainTargetSetDefault;
                                    if(tar_dist<=base_r1h)
                                    then MainTargetGo(tar_r)
                                    else
                                      if(not FollowCommander)then
                                        MainTargetGo(tar_r);
                                    CheckSetGeneratorGuard;
                                 end;
      aic_group_AttackWait,
      aic_group_GenWait        : if(not DefendBase)then
                                   if(ai_HTeleportNearest_u<>nil)then
                                   begin
                                      {if(isselected)then
                                      begin
                                         if(ai_HTeleportTarget_u<>nil)then
                                         begin
                                            UnitsInfo_AddLine(x,y,ai_HTeleportTarget_u^.x,ai_HTeleportTarget_u^.y,c_aqua);
                                            writeln('ai_HTeleportTarget_u ',ai_HTeleportTarget_u^.mapZone,' ',mapZone);
                                         end;
                                         UnitsInfo_AddLine(x,y,ai_HTeleportNearest_u^.x,ai_HTeleportNearest_u^.y,c_orange);
                                      end;  }
                                      case group of
                                      aic_group_AttackWait: if(map_scenario=mc_koth)and(ai_HTeleportTarKOTH_u<>nil)
                                                            then TryTeleporting(ai_HTeleportTarKOTH_u)
                                                            else
                                                              if(ai_HTeleportTarget_u<>nil)
                                                              then TryTeleporting(ai_HTeleportTarget_u)
                                                              else ai_RunTo(pu,ai_HTeleportNearest_u,0,0,ai_HTeleportNearest_d,aic_BaseIdle_r);
                                      aic_group_GenWait   : if(ai_HTeleportTarGen_u<>nil)
                                                            then TryTeleporting(ai_HTeleportTarGen_u)
                                                            else ai_RunTo(pu,ai_HTeleportNearest_u,0,0,ai_HTeleportNearest_d,aic_BaseIdle_r);
                                      end;
                                   end
                                   else
                                   begin
                                      if(ai_HTeleportRemote_u<>nil)then
                                        ai_UnitAbility(ai_HTeleportRemote_u,uab_Recall,unum,0,0);

                                      if(not FollowCommander)then
                                        ai_BaseIdle(pu,aic_BaseIdle_r);
                                   end;

      aic_group_Scout          : begin
                                    uo_id:=ua_move;
                                    if(ai_enemy_battle_u<>nil)and(ai_enemy_battle_d<srange)
                                    then ai_RunFrom(pu,ai_enemy_battle_u,0,0,ai_enemy_battle_d)
                                    else ai_DefaultIdle(pu);
                                 end;
      end;

      if((aip_flags and aif_army_smart_micro)>0)then
        if(u_royal_d<=aic_BaseIdle_r)then
        begin
           uo_id:=ua_move;
           uo_x :=map_SizeH;
           uo_y :=map_SizeH;
           exit;
        end
        else
        begin
           if(ai_choosen)then
             case uidi of
             UID_Phantom,
             UID_LostSoul: if(ai_generator_d<NOTSET)then
                             with ai_generator_kp^ do
                             begin
                                if(ai_generator_d>srange)then uo_id:=ua_move;
                                ai_RunTo(pu,nil,kp_x,kp_y,ai_generator_d,aic_BaseIdle_r);
                                exit;
                             end;
             end;
           case uidi of
           UID_Pain     : if (min2i(x,abs(map_Size1-x))>srange)
                          and(min2i(y,abs(map_Size1-y))>srange)then
                            if(ai_enemy_battle_d<base_r1h)then
                            begin
                               uo_id:=ua_move;
                               ai_RunFrom(pu,ai_enemy_battle_u,0,0,ai_enemy_battle_d);
                            end;
           UID_Phantom  : if(ai_ZombieTarget_d<base_r2 )then ai_RunTo(pu,ai_ZombieTarget_u,0,0,ai_ZombieTarget_d,0);
           UID_Medic,
           UID_ZMedic   : if(ai_HealTar_d     <base_r2 )then ai_RunTo(pu,ai_HealTar_u     ,0,0,ai_HealTar_d     ,0);
           UID_Engineer,
           UID_ZEngineer: if(ai_RepairTar_d   <base_r3 )then ai_RunTo(pu,ai_RepairTar_u   ,0,0,ai_RepairTar_d   ,0);
           end;
        end;
      if(uo_id=ua_amove)then
      begin
         if((aip_flags and aif_army_smart_Target)>0)then
         begin
            if(uid_AI_Siedge)and(ai_enemy_build_d<base_r1h)and(ai_enemy_build_d<NOTSET)
            then uo_tar:=ai_enemy_build_u^.unum
            else
              if(ai_PrimaryTarget_u<>nil)and(uid_AI_TargetWeight=0)
              then uo_tar:=ai_PrimaryTarget_u^.unum;
         end;

         if((aip_flags and aif_ability_other)>0)then ai_AbilitiesCommon(pu);
      end;

     { if(isselected)then
      begin
         //writeln('ai_PrimaryTarget_u ',ai_PrimaryTarget_u<>nil);
         if(ai_PrimaryTarget_u<>nil)then
           UnitsInfo_AddLine(x,y,ai_PrimaryTarget_u^.x,ai_PrimaryTarget_u^.y,c_orange);
        // UnitsInfo_AddLine(x,y,uo_x,uo_y,c_white);
        // UnitsInfo_AddLine(x,y,move_x,move_y,c_lime);
      end; }
   end;
end;


