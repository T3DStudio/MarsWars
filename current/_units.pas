

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
              hits :=_mhits;
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

procedure unit_damage(pu:PTUnit;damage,pain_f:integer;pl:byte;IgnoreArmor:boolean);
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
          if(_ukbuilding)
          then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_build[_urace]])*UpgradeBuildArmorBonus
          else
            if(_ukmech)
            then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_mech[_urace]])*UpgradeUnitArmorBonus
            else armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_bio [_urace]])*UpgradeUnitArmorBonus;

         if(level>0)then armor+=level*_level_armor;

         damage-=armor;
      end;

      if(damage<=0)then damage:=1;

      if(hits<=damage)then
      begin
         if(ServerSide)
         then unit_kill(pu,false,(hits-damage)<=_fastdeath_hits,true,false,false);
      end
      else
      begin
         buffs[ub_Damaged]:=fr_fps2;

         if(ServerSide)
         then hits-=damage
         else
           if(buffs[ub_Pain]<=0)then exit;

         if(not _ukbuilding)and(not _ukmech)then
          if(pain_f>0)and(_painc>0)then // and(buffs[ub_Pain]<=0)
          begin
             if(pain_f>pains)
             then pains:=0
             else pains-=pain_f;

             if(pains=0)then
             begin
                pains:=_painc;

                buffs[ub_Pain]:=max2i(pain_time,a_rld);

                with player^ do
                  if(_urace=r_hell)then
                    if(upgr[upgr_hell_pains]>0)then pains+=_painc_upgr_step*upgr[upgr_hell_pains];
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
aselect     : boolean;
begin
   unit_morph:=0;
   with pu^     do
   with player^ do
   begin
      if(hits<=0)then
      begin
         unit_morph:=ureq_unknown;
         exit;
      end;

      puid  :=@g_uids[ouid];
      aTeamDetection:=TeamDetection;
      aTeamVision   :=TeamVision;
      aselect:=sel;

      if(a_units[ouid]<=0)then
      begin
         unit_morph:=ureq_max;
         exit;
      end;
      if((armylimit-pu^.uid^._limituse+puid^._limituse+uprodl)>MaxPlayerLimit)then
      begin
         unit_morph:=ureq_armylimit;
         exit;
      end;
      if(not obld)or(puid^._ukbuilding)then
        if(menergy<=0)then
        begin
           unit_morph:=ureq_energy;
           exit;
        end;
      if(not obld)then
      begin
         if(ukfly)or(transportC>0)then
         begin
            unit_morph:=ureq_unknown;
            exit;
         end;
         if((cenergy-uid^._genergy)<puid^._renergy)or(menergy<=uid^._genergy)then
         begin
            unit_morph:=ureq_energy;
            exit;
         end;
         if(CheckCollisionR(x,y,puid^._r,unum,puid^._ukbuilding,puid^._ukfly,true )>0)then
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

   if(bhits<0)then bhits:=puid^._mhits div abs(bhits);
   if(LastCreatedUnitP<>nil)then
     with LastCreatedUnitP^ do
     begin
        TeamDetection:=aTeamDetection;
        TeamVision:=aTeamVision;
        if(bhits>0)then
          if(not iscomplete)then hits:=mm3i(1,bhits,puid^._mhits-1);
        if(aselect)then unit_select(LastCreatedUnitP);
     end;
end;

procedure unit_push(pu,tu:PTUnit;uds:single);
var t:single;
   ud:integer;
shortcollision,
dirturn:boolean;
begin
   // pu from tu
   with pu^ do
   with uid^ do
   begin
      t :=uds;
      shortcollision:=((tu^.speed<=0)or(not tu^.iscomplete))and(pu^.player=tu^.player);
      if(shortcollision)
      then uds-=tu^.uid^._r
      else uds-=tu^.uid^._r+_r;
      ud:=round(uds);

      dirturn:=(a_rld<=0)and((tu^.speed<=0)or(not tu^.iscomplete)or(tu^.uid^._ukbuilding)or((tu^.x=tu^.uo_x)and(tu^.y=tu^.uo_y)) );

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

         if(dirturn)then
          if(vx<>x)or(vy<>y)then
           if(shortcollision)
           then dir:=dir_MOD360(dir-(                  dir_diff(dir,point_dir(vx,vy,x,y))   div 2 ))
           else dir:=dir_MOD360(dir-( min2i(90,max2i(-90,dir_diff(dir,point_dir(vx,vy,x,y)))) div 2 ));

         if(tu^.x=tu^.uo_x)and(tu^.y=tu^.uo_y)and(uo_tar=0)then
         begin
            ud:=point_dist_rint(uo_x,uo_y,tu^.x,tu^.y)-_r-tu^.uid^._r;
            if(ud<=0)then
            begin
               uo_x:=x;
               uo_y:=y;
            end;
         end;
      end;
   end;
end;

procedure unit_PushFromObstacle(pu:PTUnit;td:PTDoodad);
var t,uds:single;
      ud :integer;
begin
   with pu^ do
   with uid^ do
   begin
      t  :=point_dist_real(x,y,td^.x,td^.y);
      uds:=t-(_r+td^.r);
      ud :=round(uds);

      if(uds<0)then
      begin
         if((td^.x=x)and(td^.y=y))then
         begin
            case g_random(4) of
            0: unit_SetXY(pu,x-ud,y   ,mvxy_none);
            1: unit_SetXY(pu,x+ud,y   ,mvxy_none);
            2: unit_SetXY(pu,x   ,y-ud,mvxy_none);
            3: unit_SetXY(pu,x   ,y+ud,mvxy_none);
            end;
         end
         else unit_SetXY(pu,x+round(ud*(td^.x-x)/t)+g_randomr(2),
                            y+round(ud*(td^.y-y)/t)+g_randomr(2),mvxy_none);

         vstp+=round(uds/speed*UnitStepTicks);

         if(a_rld<=0)then
          if(vx<>x)or(vy<>y)then dir:=dir_MOD360(dir-(dir_diff(dir,point_dir(vx,vy,x,y)) div 2 ));

         if(uo_id=ua_psability)then exit;

         ud:=point_dist_rint(uo_x,uo_y,td^.x,td^.y)-_r-td^.r;
         if(ud<=0)then
         begin
            uo_x:=x;
            uo_y:=y;
         end;
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
     if(n>0)then
      for i:=0 to n-1 do
       with l[i]^ do
        if(r>0)and(t>0)then unit_PushFromObstacle(pu,l[i]);
end;

procedure unit_move(pu:PTUnit);
var mdist,ss:integer;
    ddir    :single;
begin
   with pu^ do
    if(x=vx)and(y=vy)then
     if(x<>mv_x)or(y<>mv_y)then
      if(not IsUnitRange(transport,nil))then
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
              if(not _ukbuilding)then
               with player^ do
                if(_ukmech)
                then ss+=upgr[upgr_race_mspeed_mech[_urace]]*2
                else ss+=upgr[upgr_race_mspeed_bio [_urace]]*2;

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
         if((armylimit+pTarget^.uid^._limituse+uprodl)>MaxPlayerLimit)then exit;

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
      zfall:=-uid^._zfall;
      ukfly:= uid^._ukfly;
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
   if(cw>MaxUnitWeapons)then exit;
   if(pTarget^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=point_dist_int(pAttacker^.x,pAttacker^.y,pTarget^.x,pTarget^.y);

   with pAttacker^ do
   with uid^ do
   with player^ do
   with _a_weap[cw] do
   begin
      if(aw_rld=0)then exit;

      // Weapon type requirements
      case aw_type of
wpt_resurect : if(not unit_StartResurrection(pAttacker,pTarget,true))then exit;
wpt_heal     : if(pTarget^.hits<=0)
               or(pTarget^.hits>=pTarget^.uid^._mhits)
               or(pTarget^.iscomplete=false     )
               or(pTarget^.buffs[ub_Heal]>0      )then exit;
      end;

      // transport check
      au:=nil;
      if(IsUnitRange(transport,@au))then
      begin
         if(IsUnitRange(pTarget^.transport,nil))then
         begin
            if(au<>pTarget)and(transport<>pTarget^.transport)then exit;
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
        if(IsUnitRange(pTarget^.transport,nil))then exit;

      // UID and UPID requirements

      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0         )then exit;
      if(aw_rupgr>0)and(upgr  [aw_rupgr]< aw_rupgr_l)then exit;

      // requirements to attacker and some flags

      if not(pTarget^.uidi in aw_uids)then exit;

      if((aw_reqf and wpr_air   )>0)then
       if(ukfly=uf_ground)or(pTarget^.ukfly=uf_ground)then exit;
      if((aw_reqf and wpr_ground)>0)then
       if(ukfly=uf_fly   )or(pTarget^.ukfly=uf_fly   )then exit;
      if((aw_reqf and wpr_reload)>0)then
       if(rld>0)then exit;

      if(aw_type=wpt_directdmgZ)then
      begin
         if(pTarget^.iscomplete=false)
         or(pTarget^.uid^._zombie_uid =0)
         or(pTarget^.uid^._zombie_hits<pTarget^.hits)
         or(pTarget^.hits<=fdead_hits          )then exit;
         if(pTarget^.player^.team=team)and(pTarget^.hits>0)then exit;

         if((armylimit-_limituse+pTarget^.uid^._limituse+uprodl)>MaxPlayerLimit)then exit;
         if((menergy-_genergy+pTarget^.uid^._genergy)<=0)then exit;
         if(pTarget^.uid^._isbuilder)and(e_builders>=PlayerMaxBuilders)then exit;
      end;

      // requirements to target

      if((aw_tarf and wtr_owner_p  )=0)and(pTarget^.playeri      =playeri       )then exit;
      if((aw_tarf and wtr_owner_a  )=0)and(pTarget^.player^.team =team          )then exit;
      if((aw_tarf and wtr_owner_e  )=0)and(pTarget^.player^.team<>team          )then exit;

      if((aw_tarf and wtr_hits_h   )=0)and((0<pTarget^.hits)
                                       and(pTarget^.hits< pTarget^.uid^._mhits ))then exit;
      if((aw_tarf and wtr_hits_d   )=0)and(pTarget^.hits<=0                     )then exit;
      if((aw_tarf and wtr_hits_a   )=0)and(pTarget^.hits =pTarget^.uid^._mhits  )then exit;

      if((aw_tarf and wtr_complete )=0)and(pTarget^.iscomplete                  )then exit;
      if((aw_tarf and wtr_ncomplete)=0)and(pTarget^.iscomplete =false           )then exit;

      if(not pTarget^.uid^._ukbuilding  )then
      begin
      if((aw_tarf and wtr_stun     )=0)and(pTarget^.buffs[ub_Pain]> 0           )then exit;
      if((aw_tarf and wtr_nostun   )=0)and(pTarget^.buffs[ub_Pain]<=0           )then exit;
      end;

      if(not CheckUnitBaseFlags(pTarget,aw_tarf))then exit;

      // Distance requirements
      if(aw_max_range=aw_srange) // = srange
      then awr:=ud-srange
      else
        if(aw_max_range<aw_srange) // melee
        then awr:=ud-(_r+pTarget^.uid^._r-aw_max_range)  // need transport check
        else
          if(aw_max_range>=aw_fsr0)  // relative srange
          then awr:=ud-(srange+(aw_max_range-aw_fsr))
          else awr:=ud-aw_max_range; // absolute
      if(aw_max_range>=aw_srange)then
      begin
         if(pTarget^.ukfly)
         then awr-=_a_BonusAntiFlyRange
         else awr-=_a_BonusAntiGroundRange;
         if(pTarget^.uid^._ukbuilding)
         then awr-=_a_BonusAntiBuildingRange
         else awr-=_a_BonusAntiUnitRange;
      end;

      canmove:=(speed>0)and(uo_id<>ua_hold)and(au=nil);
      pfcheck:=(ukfly)or(ukfloater)or(pfzone=pTarget^.pfzone);

      // pfzone check for melee

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
   if(cw>MaxUnitWeapons)then cw:=MaxUnitWeapons;
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
                       incPrio(    _ukbuilding   );
                       incPrio(_genergy>0);
                       incPrio(not iscomplete    );
                       end;
wtp_BuildingHeavy    : begin
                       incPrio((   _ukbuilding  )
                            and(not _uklight    ));
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioLight     : begin
                       incPrio((not _ukbuilding )
                            and(not _ukmech     )
                            and(    _uklight    ));
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioHeavy     : begin
                       incPrio((not _ukbuilding )
                            and(not _ukmech     )
                            and(not _uklight    ));
                       incPrio(not iscomplete    );
                       end;
wtp_UnitMech         : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBio          : begin
                       incPrio(not _ukbuilding   );
                       incPrio(not _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_Bio              : begin
                       incPrio(not _ukmech       );
                       incPrio((not _ukbuilding)or(not iscomplete));
                       end;
wtp_Light            : incPrio(    _uklight      );
wtp_GroundLight      : begin
                       incPrio((    _uklight    )
                            and(not ukfly       ));
                       incPrio(_genergy        >0);
                       end;
wtp_Fly              : begin
                       incPrio(     ukfly        );
                       incPrio(not iscomplete    );
                       end;
wtp_nolost_hits      : ;
wtp_UnitLight        : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_limit            : incPrio(not _ukbuilding   );
wtp_limitaround      : GetWeaponPriority+=pTarget^.aiu_limitaround_ally div ul1;
wtp_Scout            : begin
                       incPrio(_limituse<ul3);
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

      if(tw>MaxUnitWeapons)then exit;

      unit_target:=true;

      if(tw>t_weap^)
      then exit
      else
       with _a_weap[tw] do
        if(tw<t_weap^)
        then n_prio:=GetWeaponPriority(tu,aw_tarprior,ai_HighPriorityTarget(player,tu))
        else
        begin
           n_prio:=GetWeaponPriority(tu,aw_tarprior,ai_HighPriorityTarget(player,tu));

           case aw_tarprior of
           //wtp_heal      : if(tu<>pu)then n_prio+=1;
           wtp_limit     : n_prio+=tu^.uid^._limituse;
           end;

           //if(n_prio>t_prio^)then ;
           if(n_prio=t_prio^)then
           case aw_tarprior of
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

wtp_Rmhits            : if(tu^.uid^._mhits<a_tarp^^.uid^._mhits)
                        then exit
                        else
                          if(tu^.uid^._mhits=a_tarp^^.uid^._mhits)then
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

procedure unit_aura_effects(pAuraSrcUnit,pTarget:PTUnit;ud:integer);
begin
   // pAuraSrcUnit - aura source
   // pTarget - target
   with pAuraSrcUnit^     do
   with uid^    do
   with player^ do
   case uidi of
UID_HAKeep,
UID_HKeep     : if(ud<srange)
               and(not pTarget^.uid^._ukbuilding)
               and(team<>pTarget^.player^.team)then
                 if(pTarget^.buffs[ub_Decay]<=fr_fpsd2)and(upgr[upgr_hell_paina]>0)then
                 begin
                    AddToInt(@TeamVision[pTarget^.player^.team],MinVisionTime);
                    unit_damage(pTarget,DecayAuraDamage,1,playeri,true);
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
      if(cpCaptureR>0)then
       if(point_dist_int(x,y,cpx,cpy)<=cpCaptureR)then
       begin
          cpUnitsPlayer[playeri     ]+=uid^._limituse;
          cpUnitsTeam  [player^.team]+=uid^._limituse;
       end;
end;

procedure unit_mcycle(pu:PTUnit);
var uc,
t_prio,
a_tard,
uontar,
uontard,
    ud : integer;
    uds: single;
a_tarp,
    puo,
tu_transport,
    tu : PTUnit;
swtarget,
aicode,
fteleport_tar,
attack_target,
pushout: boolean;
t_weap : byte;
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
      uontar  := 0;
      uontard := NOTSET;
      tu_transport:=nil;
      if(StayWaitForNewTarget>0)
      then StayWaitForNewTarget-=1;

      u_royal_cd:=NOTSET;
      u_royal_d :=NOTSET;
      if(map_scenario=mc_royale)then
      begin
         u_royal_cd:=point_dist_int(x,y,map_hmw,map_hmw);
         u_royal_d :=g_royal_r-u_royal_cd;
         if(u_royal_d<_missile_r)then
         begin
            unit_kill(pu,false,false,true,true,false);
            exit;
         end;
      end;

      if(_ukbuilding)and(menergy<=0)then
      begin
         unit_kill(pu,false,false,true,false,true);
         exit;
      end;

      pushout      := solid and unit_canMove(pu) and (a_rld<=0);
      attack_target:= unit_canAttack(pu,false);
      aicode       := (state=ps_AI);//and(sel);
      fteleport_tar:= (not IsUnitRange(uo_tar,nil))and(_ability=uab_Teleport);
      swtarget     := false;
      puo:=nil;
      if(IsUnitRange(uo_tar,@puo))and(aicode=false)then
       if(puo^.player=player)and(puo^.hits>0)and(puo^.rld>0)then
        case g_uids[puo^.uidi]._ability of
uab_Teleport      : swtarget:=true;
        end;

      aiu_InitVars(pu);
      if(aicode){or(sel)}then
      begin
         ai_InitVars(pu);
         ai_CollectData(pu,pu,0,nil);
      end;
      aiu_CollectData(pu,pu,0,nil);

      if(attack_target)then unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=g_punits[uc];

         if(tu^.hits>fdead_hits)then
         begin
            uds:=point_dist_real(x,y,tu^.x,tu^.y);
            ud :=round(uds);

            tu_transport:=nil;
            IsUnitRange(tu^.transport,@tu_transport);

            if(tu_transport=nil)then unit_detect(pu,tu,ud);

            if(attack_target)then unit_target(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio);

            aiu_CollectData(pu,tu,ud,tu_transport);
            if(aicode){or(sel)}then ai_CollectData(pu,tu,ud,tu_transport);

            if(tu^.hits>0)and(tu_transport=nil)then
            begin
               unit_aura_effects(pu,tu,ud);

               if(pushout)then
                if(_r<=tu^.uid^._r)or(tu^.speed<=0)or(not tu^.iscomplete)then
                 if(tu^.solid)and(ukfly=tu^.ukfly)then unit_push(pu,tu,uds);

               if(swtarget)then
                if(ud<srange)and(tu^.playeri=playeri)and(tu^.uidi=puo^.uidi)and(tu^.rld<puo^.rld)and(tu^.iscomplete)then
                 if((0<tu^.uo_tar)and(tu^.uo_tar<=MaxUnits)and(tu^.uo_tar=puo^.uo_tar))
                 or((tu^.uo_x=puo^.uo_x)and(tu^.uo_y=puo^.uo_y))
                 then uo_tar:=tu^.unum;

               if(fteleport_tar)then
               begin
                  ud:=point_dist_int(uo_x,uo_y,tu^.x,tu^.y)-tu^.uid^._r;
                  if(ud<srange)and(ud<uontard)then
                   if(team=tu^.player^.team)then
                   begin
                      uontar :=uc;
                      uontard:=ud;
                   end;
               end;
            end;
         end;
      end;

      unit_PushFromObstacles(pu);

      if(fteleport_tar)and(uontar>0)then uo_tar:=uontar;

      if(attack_target)and(a_tard<NOTSET)then StayWaitForNewTarget:=0;

      {$IFNDEF DEBUG1}
      aiu_code(pu);
      if(aicode){and(playeri=LocalPlayer)}then ai_code(pu);
      {$ENDIF}

      if(buffs[ub_Damaged]>0)then GameLogUnitAttacked(pu);
   end;
end;

procedure unit_mcycle_cl(pu,au:PTUnit);
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

      if(au<>nil)then
      begin
         if(IsUnitRange(au^.transport,nil))then exit;
         TeamVision   :=au^.TeamVision;
         udetect:=false;
      end
      else udetect:=true;

      if(not udetect)and(not ftarget)then exit;  // in apc & client side

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
               if(au=nil)and(tu^.hits>0)then
                if(tu^.transport<=0)or(MaxUnits<tu^.transport)then unit_aura_effects(pu,tu,ud);
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
      unit_ability_HellVision:=ureq_unknown;
      if(not iscomplete)
      or(hits<=0)then exit;

      unit_ability_HellVision:=ureq_reloading;
      if(rld>0)then exit;
   end;

   unit_ability_HellVision:=ureq_invalidtar;
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
      unit_ability_Recall:=ureq_unknown;
      if(not iscomplete)
      or(hits<=0)then exit;

      unit_ability_Recall:=ureq_reloading;
      if(rld>0)then exit;
   end;

   unit_ability_Recall:=ureq_rupid;
   with pu^.player^ do
     if(upgr[upgr_hell_rteleport]<=0)
     then exit;

   unit_ability_Recall:=ureq_invalidtar;
   if(not IsUnitRange(tar,@tu))then exit;
   with tu^ do
   with uid^ do
     if(_ukbuilding)
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
         teleport_CalcReload(pu,tu^.uid^._limituse);
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
      if(not _ukbuilding)and(iscomplete)and(ukfly=false)and(tu^.hits>0)and(tu^.iscomplete)then
       if(playeri=tu^.playeri)and(buffs[ub_Teleport]<=0)then
        if(td<=tu^.uid^._r)then
        begin
           if(tu^.rld<=0)then
           begin
              if(not IsUnitRange(tu^.uo_tar,@tt))then exit;
              if(tu^.player^.team<>tt^.player^.team)then exit;
              if(tt^.hits<=0)then exit;

              if(ukfly=uf_ground)then
               if(pf_IfObstacleZone(tt^.pfzone))then exit;

              tu^.uo_x:=tt^.x;
              tu^.uo_y:=tt^.y;

              tr:=_r+tt^.uid^._r;

              if(ukfly=tt^.ukfly)
              then unit_teleport(pu,tu^.uo_x+(tr*sign(x-tu^.uo_x)),tu^.uo_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF})
              else unit_teleport(pu,tu^.uo_x                      ,tu^.uo_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});

              teleport_CalcReload(tu,_limituse);
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
        transportC+=tu^.uid^._transportS;
        tu^.transport:=unum;
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
     if(not IsUnitRange(tu^.transport,@pu))then exit;
   with tu^ do
   if(transport=pu^.unum)and(pu^.buffs[ub_CCast]<=0)then
   begin
      pu^.buffs[ub_CCast]:=fr_fpsd4;
      pu^.transportC-=uid^._transportS;
      transport:=0;
      x    :=pu^.x-g_randomr(pu^.uid^._r);
      y    :=pu^.y-g_randomr(pu^.uid^._r);
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
          if(not ptransport^.ukfly)or(not pf_IfObstacleZone(ptransport^.pfzone))then
           if(unit_UnLoad(ptransport,pu))then exit;

         if(ptransport^.uo_id=ua_move )
         or(ptransport^.uo_id=ua_hold )
         or(ptransport^.uo_id=ua_amove)then uo_id:=ptransport^.uo_id;

         if(IsUnitRange(ptransport^.uo_tar,@tu))then
         begin
            a_tar:=ptransport^.uo_tar;
            if(unit_target2weapon(pu,tu,-1,255,nil)<=MaxUnitWeapons)then uo_id:=ua_amove;
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
         if(IsUnitRange(tu^.transport,nil))
         or(CheckUnitTeamVision(player^.team,tu,false)=false)then
         begin
            uo_tar:=0;
            uo_id :=ua_amove;
            exit;
         end;

         td :=point_dist_int(x,y,tu^.x,tu^.y);
         if(tu^.solid)
         then tdm:=td-(_r+tu^.uid^._r)
         else tdm:=td- min2i(_r,tu^.uid^._r);

         if(tdm<melee_r)then
         begin
            if(unit_Load(pu,tu))then exit;
            if(unit_Load(tu,pu))then exit;
         end;

         case _ability of
uab_Teleport     : if(tu^.player^.team<>player^.team )then begin uo_tar:=0;exit; end;
         end;

         case tu^.uid^._ability of
uab_Teleport     : if(unit_ability_teleport(pu,tu,td))then exit;//team
         end;

         w:=unit_target2weapon(pu,tu,td,255,@a);
         if(w<=MaxUnitWeapons)then
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

   if(pTarget^.uid^._zombie_uid=0)then exit;
   _zuid:=@g_uids[pTarget^.uid^._zombie_uid];

   with pPhantom^ do
   with uid^ do
   with player^ do
   begin
      if((armylimit-_limituse+_zuid^._limituse+uprodl)>MaxPlayerLimit)then exit;
      if((menergy-_genergy+_zuid^._genergy)<=0)then exit;
      if(pTarget^.uid^._isbuilder)and(e_builders>=PlayerMaxBuilders)then exit;
   end;

   if(not pTarget^.iscomplete)
   or(pTarget^.uid^._zombie_uid =0)
   or(pTarget^.uid^._zombie_hits<pTarget^.hits)
   or(pTarget^.hits<=fdead_hits          )then exit;

   if(ServerSide)then
   begin
      _h:=pTarget^.hits/pTarget^.uid^._mhits;
      _d:=pTarget^.dir;
      _o:=pPhantom^.group;
      _f:=pTarget^.ukfly;
      _z:=pTarget^.zfall;
      _l:=pTarget^.level;
      {$IFDEF _FULLGAME}
      _s:=pTarget^.shadow;
      {$ENDIF}

      unit_kill(pPhantom,true,true,false,false,true);
      unit_add(pTarget^.x,pTarget^.y,pPhantom^.unum,pTarget^.uid^._zombie_uid,pPhantom^.playeri,true,true,_l);
      unit_kill(pTarget,true,true,false,false,true);

      if(LastCreatedUnit>0)then
      with LastCreatedUnitP^ do
      begin
         group:=_o;
         dir  :=_d;
         ukfly:=_f;
         hits := trunc(uid^._mhits*_h);
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
   if(level<MaxUnitLevel)then
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
var w,a   : byte;
pTarget   : PTUnit;
damage,
upgradd,c : integer;
fakemissile,
attackinmove: boolean;
{$IFDEF _FULLGAME}
attackervis,
targetvis : boolean;
{$ENDIF}
procedure visEffects;
var i:byte;
begin
   with pAttacker^ do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if((aw_reqf and wpr_avis)>0)then
      begin
         AddToInt(@pTarget^.TeamVision[player^.team],MinVisionTime);
         {$IFDEF _FULLGAME}
         if not(a_rld in aw_rld_a)then
           if(AddToInt(@pTarget^.buffs[ub_ArchFire ],fr_fps1))then SoundPlayUnit(snd_archvile_fire,pTarget,@targetvis);
         {$ENDIF}
      end;
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
      if(IsUnitRange(a_tar,@pTarget)=false)then exit;

      if(ServerSide)then
      begin
         if(a_rld<=0)then
         begin
            w:=unit_target2weapon(pAttacker,pTarget,-1,255,@a);

            if(w>MaxUnitWeapons)or(a=0)then
            begin
               if(ServerSide)then
               begin
                  a_tar:=0;
                  StayWaitForNewTarget:=1;
               end;
               exit;
            end;

            a_weap:=w;
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
          with _a_weap[a_weap] do
           attackinmove:=(aw_reqf and wpr_move)>0;

         case a of
wmove_closer    : begin
                     if(not attackinmove)then
                     begin
                        mv_x:=pTarget^.x;
                        mv_y:=pTarget^.y;
                     end;
                     exit;
                  end;
wmove_farther   : begin
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
wmove_noneed    : if(not attackinmove)then
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
         if(a_weap>MaxUnitWeapons)then exit;

         if(pTarget^.hits<=fdead_hits)then exit;

         with uid^ do
          with _a_weap[a_weap] do
           attackinmove:=(aw_reqf and wpr_move)>0;
      end;

      if(not unit_canAttack(pAttacker,true))then
      begin
         mv_x:=x;
         mv_y:=y;
         exit;
      end;

      // attack code
      with uid^ do
      with _a_weap[a_weap] do
      begin
         {$IFDEF _FULLGAME}
         targetvis  :=ui_CheckUnitUIPlayerVision(pTarget  ,true);
         attackervis:=ui_CheckUnitUIPlayerVision(pAttacker,true);
         {$ENDIF}

         if(a_rld<=0)then
         begin
            a_shots  +=1;
            a_rld    :=aw_rld;
            a_tar_cl :=a_tar;
            a_weap_cl:=a_weap;

            if(ServerSide)and(not _ukbuilding)then
              if((aw_max_range<0)and(aw_type=wpt_directdmg))
              or(aw_type=wpt_heal)
              then unit_AddExp(pAttacker,aw_rld*2)
              else unit_AddExp(pAttacker,aw_rld  );
            if(not attackinmove)then
            begin
               if(x<>pTarget^.x)
               or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
               if(ServerSide)then StayWaitForNewTarget:=(a_rld div order_period)+1;
            end;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,true,@attackervis);
            {$ENDIF}
            visEffects;
         end;

         if(cycle_order=g_cycle_order)then visEffects;

         {$IFDEF _FULLGAME}
         if(targetvis)then
          if(aw_eid_target>0)and(aw_eid_target_onlyshot=false)then
          begin
             if(not IsUnitRange(pTarget^.transport,nil))then
              if((g_tick mod fr_fpsd3)=0)then effect_add(pTarget^.vx-g_randomr(pTarget^.uid^._missile_r),pTarget^.vy-g_randomr(pTarget^.uid^._missile_r),draw_SpriteDepth(pTarget^.vy+1,pTarget^.ukfly),aw_eid_target);
             if(aw_snd_target<>nil)then
              if((g_tick mod fr_fps1)=0)then SoundPlayUnit(aw_snd_target,pTarget,@targetvis);
          end;
         {$ENDIF}

         if(a_rld in aw_rld_s)then
         begin
            if(aw_fakeshots=0)
            then fakemissile:=false
            else fakemissile:=(a_shots mod aw_fakeshots)>0;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,false,@attackervis);
            if(targetvis)then
             if(aw_eid_target>0)and(aw_eid_target_onlyshot)then
             begin
                if(not IsUnitRange(pTarget^.transport,nil))then
                effect_add(pTarget^.vx-g_randomr(pTarget^.uid^._missile_r),pTarget^.vy-g_randomr(pTarget^.uid^._missile_r),draw_SpriteDepth(pTarget^.vy+1,pTarget^.ukfly),aw_eid_target);

                SoundPlayUnit(aw_snd_target,pTarget,@targetvis);
             end;
            {$ENDIF}
            if(aw_dupgr>0)and(aw_dupgr_s>0)then upgradd:=player^.upgr[aw_dupgr]*aw_dupgr_s;
            if(level>0)and(not _ukbuilding)then upgradd+=level*_level_damage;
            if(not attackinmove)then
              if(x<>pTarget^.x)
              or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
            case aw_type of
wpt_missle     : if(aw_oid>0)then
                  if(aw_count=0)
                  then missile_add(pTarget^.x,pTarget^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod)
                  else
                    if(aw_count>0)
                    then for c:=1 to aw_count do missile_add(pTarget^.x,pTarget^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod)
                    else
                      if(aw_count<0)then
                      begin
                         missile_add(pTarget^.x,pTarget^.y,vx-aw_count+aw_x,vy-aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod);
                         missile_add(pTarget^.x,pTarget^.y,vx+aw_count+aw_x,vy+aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod);
                      end;
wpt_unit       : if(not fakemissile)then ability_unit_spawn(pAttacker,aw_oid);
wpt_directdmg  : if(not fakemissile)and(aw_count>0)then
                 begin
                    damage:=ApplyDamageMod(pTarget,aw_dmod,aw_count+upgradd);
                    unit_damage(pTarget,damage,1,playeri,false);
                 end;
wpt_directdmgZ : if(not fakemissile)and(aw_count>0)then
                  if(not unit_TryZombification(pAttacker,pTarget))then
                  begin
                     damage:=ApplyDamageMod(pTarget,aw_dmod,aw_count+upgradd);
                     unit_damage(pTarget,damage,1,playeri,false);
                  end;
wpt_suicide    : if(ServerSide)then unit_kill(pAttacker,false,true,true,false,true);
            else
              if(ServerSide)and(not fakemissile)then
              case aw_type of
wpt_resurect   : begin
                    unit_StartResurrection(pAttacker,pTarget,false);
                    if((aw_reqf and wpr_reload)>0)then rld:=max2i(0,aw_count*fr_fps1);
                 end;
wpt_heal       : begin
                    pTarget^.hits:=mm3i(1,pTarget^.hits+aw_count+upgradd,pTarget^.uid^._mhits);
                    pTarget^.buffs[ub_Heal]:=aw_rld;
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
   if(IsUnitRange(pu^.transport,@apctu))then unit_InTransportCode(pu,apctu);

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
           case uid^._ability of
uab_SpawnLost:  begin
                   mv_x:=x;
                   mv_y:=y;
                   uo_id:=ua_amove;
                   unit_sability(pu,false);
                   uo_id:=ua_psability;
                end;
uab_CCFly    :  if(x=uo_x)and(y=uo_y)then
                begin
                   uo_id:=ua_amove;
                   unit_sability(pu,false);
                end;
           else
             if(speed<=0)
             then uo_id:=ua_amove
             else
               if(x=uo_x)and(y=uo_y)then
               begin
                  uo_id:=ua_amove;
                  unit_sability(pu,false);
               end;
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
               if(not uid^._slowturn)and(player^.state<>ps_AI)then
                 if(x<>mv_x)or(y<>mv_y)then dir:=point_dir(x,y,mv_x,mv_y);
               mp_x:=mv_x;
               mp_y:=mv_y;
            end;
   end;
end;

procedure unit_SetDefaultUO(pu:PTUnit;aid,atar,ax,ay,apx,apy:integer;atarz,nospeedcheck:boolean);
begin
   with pu^ do
   begin
      uo_id :=aid;
      uo_tar:=atar;
      if(atarz)
      then a_tar:=0;
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
function s_hits:longint;
begin
   with pu^ do
   with uid^ do
     if(_rebuild_uid=uidi)or(g_uids[_rebuild_uid]._genergy>0)
     then s_hits:=g_uids[_rebuild_uid]._hhmhits
     else s_hits:=g_uids[_rebuild_uid]._hmhits;
end;
begin
   unit_rebuild:=ureq_unknown;

   if(not ui_rebuild(pu)) then exit;

   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_rebuild:=CheckUnitReqs(player,_rebuild_uid,true);
      if(unit_rebuild>0)then exit;

      if(_rebuild_ruid>0)then
        if(uid_eb[_rebuild_ruid]<=0)then unit_rebuild:=ureq_ruid;

      if(_rebuild_rupgr>0)and(_rebuild_rupgrl>0)then
        if(upgr[_rebuild_rupgr]<_rebuild_rupgrl)then unit_rebuild:=ureq_rupid;

      if(unit_rebuild>0)then exit;

      unit_rebuild:=unit_morph(pu,_rebuild_uid,false,s_hits,(level+1)*byte(_rebuild_uid=uidi),true );

      if(check)or(unit_rebuild>0)then exit;

      unit_morph(pu,_rebuild_uid,false,s_hits,(level+1)*byte(_rebuild_uid=uidi),false);
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

      if(_ability_no_obstacles)then
       if(pf_IfObstacleZone(pfzone))then AddUREQ(ureq_place);

      if(_ability_ruid>0)then
       if(uid_eb[_ability_ruid]<=0)then AddUREQ(ureq_ruid);

      if(_ability_rupgr>0)and(_ability_rupgrl>0)then
       if(upgr[_ability_rupgr]<_ability_rupgrl)then AddUREQ(ureq_rupid);
   end;
end;

function unit_sability(pu:PTUnit;check:boolean):cardinal;
begin
   unit_sability:=ureq_unknown;

   if(not ui_ability(pu,false)) then exit;

   unit_sability:=unit_AbilityBasicChecks(pu);
   if(unit_sability>0)then exit;

   with pu^ do
   with uid^ do
   with player^ do
   case _ability of
   uab_RebuildInPoint  : unit_sability:=unit_rebuild(pu,true);
   uab_SpawnLost       : if(buffs[ub_Cast]>0)
                         or(buffs[ub_CCast]>0)then unit_sability:=ureq_reloading;
   uab_CCFly           : if(zfall<>0)
                         or(buffs[ub_CCast]>0)then unit_sability:=ureq_reloading;
   uab_ToUACDron       : unit_sability:=unit_morph(pu,uid_UACDron,false,g_uids[uid_UACDron]._hmhits,0,true);
   uab_Unload          : if(transportC=0)
                         or(transportM=0)then unit_sability:=ureq_unknown;
   else  unit_sability:=ureq_unknown;
   end;

   if(check)or(unit_sability>0)then exit;

   with pu^ do
   with uid^ do
   with player^ do
   case _ability of
   uab_RebuildInPoint  : unit_rebuild(pu,false);
   uab_SpawnLost       : begin
                            buffs[ub_Cast ]:=fr_fpsd2;
                            buffs[ub_CCast]:=fr_fps2;
                            if(upgr[upgr_hell_phantoms]>0)
                            then ability_unit_spawn(pu,UID_Phantom )
                            else ability_unit_spawn(pu,UID_LostSoul);
                         end;
   uab_CCFly           : if(level>0)
                         then level:=0
                         else level:=1;
   uab_ToUACDron       : unit_morph(pu,uid_UACDron,false,g_uids[uid_UACDron]._hmhits,0,false);
   uab_Unload          : uo_id:=ua_unload;
   end;
end;

function unit_pability(pu:PTUnit;taru,tarx,tary:integer;check:boolean):cardinal;
begin
   unit_pability:=ureq_unknown;

   if(not ui_ability(pu,true )) then exit;

   unit_pability:=unit_AbilityBasicChecks(pu);
   if(unit_pability>0)then exit;

   with pu^ do
   with uid^ do
   with player^ do
   case _ability of
   uab_Teleport        : ;
   uab_UACScan         : unit_pability:=unit_ability_UACScan    (pu,tarx,tary  ,true);
   uab_UACStrike       : unit_pability:=unit_ability_UACStrike  (pu,tarx,tary  ,true);
   uab_HTowerBlink     : ;
   uab_HKeepBlink      :;
   uab_RebuildInPoint  :;
   uab_HInvulnerability:;
   uab_SpawnLost       :;
   uab_HellVision      :;
   uab_CCFly           :;
   uab_Unload          : if(transportC=0)
                         or(transportM=0)then unit_pability:=ureq_unknown;
   else  unit_pability:=ureq_unknown;
   end;


   if(check)or(unit_pability>0)then exit;

   with pu^ do
   with uid^ do
   with player^ do
   case _ability of
   uab_Teleport        : unit_pability:=unit_ability_Recall(pu,taru,NOTSET,false);
   uab_UACScan         : unit_pability:=unit_ability_UACScan    (pu,tarx,tary  ,false);
   uab_UACStrike       : unit_pability:=unit_ability_UACStrike  (pu,tarx,tary  ,false);
   uab_HTowerBlink     : unit_pability:=unit_ability_HTowerBlink(pu,tarx,tary  ,false);
   uab_HKeepBlink      : unit_pability:=unit_ability_HKeepBlink (pu,tarx,tary  ,false);
   uab_HInvulnerability: unit_pability:=unit_ability_HInvuln    (pu,taru       ,false);
   uab_HellVision      : unit_pability:=unit_ability_HellVision (pu,taru       ,false);
   uab_CCFly           : if(speed>0)
                         then unit_SetDefaultUO(pu,ua_psability,0,tarx,tary-fly_hz,-1,-1,true ,false)
                         else
                         begin
                            unit_pability:=unit_sability(pu,false);
                            if(unit_pability=0)then
                            unit_SetDefaultUO(pu,ua_psability,0,tarx,tary-fly_hz,-1,-1,true,true);
                         end;
   uab_SpawnLost,
   uab_RebuildInPoint,
   uab_Unload          : unit_SetDefaultUO(pu,ua_psability,0,tarx,tary,-1,-1,true,false);
   end;
end;

procedure unit_prod(pu:PTUnit);
var i:integer;
procedure _uXCheck(pui:pinteger);
var tu:PTUnit;
begin
   if(not IsUnitRange(pui^,@tu))
   then pui^:=pu^.unum;
   {else
    if(tu^.rld>pu^.rld)
    then pui^:=pu^.unum;}
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   if(iscomplete)and(hits>0)then
   begin
      unit_end_uprod(pu);
      unit_end_pprod(pu);

      _uXCheck(@uid_x[            uidi]);
      _uXCheck(@ucl_x[_ukbuilding,_ucl]);

      // REGENERATION
      if(cycle_order=g_cycle_regen)then
       if(buffs[ub_Damaged]<=0)and(hits<_mhits)then
       begin
          i:=upgr[_upgr_regen];
          if(_ukbuilding)
          then i+=upgr[upgr_race_regen_build[_urace]]
          else
            if(_ukmech)
            then i+=upgr[upgr_race_regen_mech[_urace]]
            else i+=upgr[upgr_race_regen_bio [_urace]];
          i:=(i*BaseArmorBonus1)+_baseregen;

          if(i>0)then
          begin
             hits+=i;
             if(hits>_mhits)then hits:=_mhits;
          end;
       end;
   end
   else
     if(cenergy>=0)then
     begin
        if(g_cycle_order=cycle_order)and(buffs[ub_Damaged]<=0)then
        begin
           hits+=_bstep;
           hits+=_bstep*upgr[upgr_fast_build];
        end;

        if(hits>=_mhits){$IFDEF DEBUG0}or(test_InstaProd){$ENDIF}then
        begin
           hits:=_mhits;
           iscomplete :=true;
           unit_bld_inc_cntrs(pu);
           cenergy+=_renergy;
           GameLogUnitReady(pu);
        end;
     end;
end;

procedure GameObjectsCode;
var u : integer;
    pu,
    transportu: PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=g_punits[u];
      with pu^ do
      if(hits>dead_hits)then
      begin
         if(cycle_order=g_cycle_order)
         then unit_reveal(pu,false);

         unit_counters(pu);

         if(hits>0)then
         begin
            unit_Bonuses (pu);
            unit_order(pu);

            if(hits<=0)then continue;

            if(ServerSide)then
            begin
               unit_move(pu);
               unit_prod(pu);

               if(player^.state=ps_AI)then ai_scout_pick(pu);
            end;

            transportu:=nil;
            if(cycle_order=g_cycle_order)and(hits>0)then
              if(ServerSide)and(not IsUnitRange(transport,@transportu))
              then unit_mcycle   (pu)
              else unit_mcycle_cl(pu,transportu);

            if(ServerSide)then
              if(not IsUnitRange(transport,nil))then
                unit_CaptureKPoint(pu);
         end
         else unit_death(pu);

         unit_MoveVis(pu);
      end;
   end;

   missile_Cycle;
end;

////////////////////////////////////////////////////////////////////////////////




