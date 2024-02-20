

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
        for uc:=1 to MaxUnits do
          if(uc<>unum)then
          begin
             tu:=g_punits[uc];
             if(tu^.hits>fdead_hits)then unit_detect(pu,tu,point_dist_rint(x,y,tu^.x,tu^.y));
          end;

      if(buff[ub_Resurect]<=0)then
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
           if(hits<-fr_fpsd2)then hits:=-fr_fpsd2;
           hits+=1;
           if(hits>=0)then
           begin
              unit_clear_order(pu,true);
              zfall:=0;
              dir  :=270;
              hits :=_hmhits;
              buff[ub_Resurect]:=0;
              buff[ub_Summoned]:=fr_fps1;
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
   if(buff[ub_Invuln]<=0)and(hits>0)then
   with uid^ do
   begin

      armor:=0;

      if(iscomplete)and(not IgnoreArmor)then
      begin
         armor:=_base_armor;
         with player^ do
          if(_ukbuilding)
          then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_build[_urace]])*BaseArmorBonus2
          else
            if(_ukmech)
            then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_mech[_urace]])*BaseArmorBonus1
            else armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_bio [_urace]])*BaseArmorBonus1;

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
         buff[ub_Damaged]:=fr_fps2;

         if(ServerSide)
         then hits-=damage
         else
           if(buff[ub_Pain]<=0)then exit;

         if(not _ukbuilding)and(not _ukmech)then
          if(pain_f>0)and(_painc>0)then // and(buff[ub_Pain]<=0)
          begin
             if(pain_f>pains)
             then pains:=0
             else pains-=pain_f;

             if(pains=0)then
             begin
                pains:=_painc;

                buff[ub_Pain]:=max2(pain_time,a_reload);

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

function unit_morph(pu:PTUnit;ouid:byte;obld:boolean;bhits:integer;ulevel:byte;Check:boolean):cardinal;
var puid: PTUID;
    avsni,
    avsnt: TUnitVisionData;
   select: boolean;
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
      avsni :=vsni;
      avsnt :=vsnt;
      select:=isselected;

      if(a_units[ouid]<=0)then
      begin
         unit_morph:=ureq_max;
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
         if(uid^._isbuilder)and(n_builders<=1)then
         begin
            unit_morph:=ureq_needbuilders;
            exit;
         end;
         if((cenergy-uid^._genergy)<puid^._renergy)or(menergy<=uid^._genergy)then
         begin
            unit_morph:=ureq_energy;
            exit;
         end;
         if(CheckCollisionR(x,y,puid^._r,unum,puid^._ukbuilding,puid^._ukfly,(upgr[upgr_race_extbuilding[puid^._urace]]=0)or(puid^._isbarrack)or(puid^._ability=uab_Teleport) )>0)then
         begin
            unit_morph:=ureq_place;
            exit;
         end;
      end;

      if(Check)then exit;

      vx:=x;
      vy:=y;
      unit_kill(pu,true,true,false,false,true);
      unit_add(x,y,unum,ouid,playeri,obld,true,ulevel);
   end;

   if(bhits<0)then bhits:=puid^._mhits div abs(bhits);
   if(LastCreatedUnitP<>nil)then
     with LastCreatedUnitP^ do
     begin
        vsni:=avsni;
        vsnt:=avsnt;
        if(bhits>0)then
          if(not iscomplete)then hits:=mm3(1,bhits,puid^._mhits-1);
        if(select)then
        begin
           isselected:=true;
           unit_PC_select_inc(LastCreatedUnitP);
        end;
     end;
end;

procedure unit_PushFromUnit(pu,tu:PTUnit;uds:single);
var t:single;
   ud:integer;
shortcollision:boolean;
begin
   // pu - pushing unit
   // tu - unit-obstacle
   with pu^ do
   with uid^ do
   begin
      t :=uds;
      shortcollision:=((tu^.speed<=0)or(not tu^.iscomplete))and(pu^.player=tu^.player);
      if(shortcollision)
      then uds-=tu^.uid^._r
      else uds-=tu^.uid^._r+_r;
      ud:=round(uds);

      if(uds<0)then
      begin
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

         if(a_reload<=0)then
           if(vx<>x)or(vy<>y)then
             if(shortcollision)
             then dir:=_DIR360(dir-(                  dir_diff(dir,point_dir(vx,vy,x,y))   div 2 ))
             else dir:=_DIR360(dir-( min2(90,max2(-90,dir_diff(dir,point_dir(vx,vy,x,y)))) div 2 ));

         if(tu^.x=tu^.ua_x)and(tu^.y=tu^.ua_y)and(tu^.ua_bx<0)and(not IsUnitRange(ua_tar,nil))then
         begin
            ud:=point_dist_rint(ua_x,ua_y,tu^.x,tu^.y)-_r-tu^.uid^._r;
            if(ud<=0)then
            begin
               ua_x:=x;
               ua_y:=y;
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

         if(a_reload<=0)then
           if(vx<>x)
           or(vy<>y)then dir:=_DIR360(dir-(dir_diff(dir,point_dir(vx,vy,x,y)) div 2 ));

         ud:=point_dist_rint(ua_x,ua_y,td^.x,td^.y)-_r-td^.r;
         if(ud<=0)then
         begin
            ua_x:=x;
            ua_y:=y;
         end;
      end;
   end;
end;

procedure unit_PushFromObstaclesDCell(pu:PTUnit);
var i,dx,dy:integer;
begin
   dx:=pu^.x div dcw;
   dy:=pu^.y div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
     with map_dcell[dx,dy] do
       if(n>0)then
         for i:=0 to n-1 do
           with l[i]^ do
             if(r>0)and(t>0)then unit_PushFromObstacle(pu,l[i]);
end;

procedure unit_PushFromObstacles(pu:PTUnit);
begin
   with pu^ do
     if(speed>0)and(ukfly=uf_ground)and(solid)and(iscomplete)and(not ukfloater)then unit_PushFromObstaclesDCell(pu);
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

          if(buff[ub_Slow]>0)then ss:=max2(2,ss div 2);

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
                then ss+=upgr[upgr_race_mspeed_mech[_urace]]*3
                else ss+=upgr[upgr_race_mspeed_bio [_urace]]*3;

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

function target_weapon_check(pu,tu:PTUnit;ud:integer;cw:byte;checkvis,nosrangecheck:boolean):byte;
var awr   :integer;
transportu:PTUnit;
pfcheck,
canmove   :boolean;
begin
   target_weapon_check:=wmove_impassible;

   //pu - attacker
   //tu - target

   if(checkvis)then
    if(CheckUnitTeamVision(pu^.player^.team,tu,false)=false)then exit;
   if(cw>MaxUnitWeapons)then exit;
   if(tu^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=point_dist_int(pu^.x,pu^.y,tu^.x,tu^.y);

   with pu^ do
   with uid^ do
   with player^ do
   with _a_weap[cw] do
   begin
      if(aw_reload=0)then exit;

      // Weapon type requirements
      case aw_type of
wpt_resurect : if(tu^.buff[ub_Resurect]>0  )
               or(tu^.buff[ub_Pain ]>0     )
               or(tu^.hits<=fdead_hits     )
               or(tu^.hits> 0              )then exit;
wpt_heal     : if(tu^.hits<=0)
               or(tu^.hits>=tu^.uid^._mhits)
               or(tu^.iscomplete=false     )
               or(tu^.buff[ub_Heal]>0      )then exit;
      end;

      // transport check
      transportu:=nil;
      if(IsUnitRange(transport,@transportu))then
      begin
         if(IsUnitRange(tu^.transport,nil))then
         begin
            if(transportu<>tu)and(transport<>tu^.transport)then exit;
            if(aw_max_range>=0)then exit; // only melee attack
         end
         else
           if(transportu<>tu)then
           begin
             if(aw_max_range< 0)then exit; // melee
           end
           else
             if(aw_max_range>=0)then exit; // ranged
      end
      else
        if(IsUnitRange(tu^.transport,nil))then exit;

      // UID and UPID requirements

      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0         )then exit;
      if(aw_rupgr>0)and(upgr  [aw_rupgr]< aw_rupgr_l)then exit;

      // requirements to attacker and some flags

      if not(tu^.uidi in aw_uids)then exit;

      if((aw_reqf and wpr_air   )>0)then
       if(ukfly=uf_ground)or(tu^.ukfly=uf_ground)then exit;
      if((aw_reqf and wpr_ground)>0)then
       if(ukfly=uf_fly   )or(tu^.ukfly=uf_fly   )then exit;
      if((aw_reqf and wpr_reload)>0)then
       if(reload>0)then exit;

      if(aw_type=wpt_directdmgZ)then
      begin
         if(tu^.iscomplete=false)
         or(tu^.uid^._zombie_uid =0)
         or(tu^.uid^._zombie_hits<tu^.hits)
         or(tu^.hits<=fdead_hits          )then exit;
      end;

      // requirements to target

      if((aw_tarf and wtr_owner_p  )=0)and(tu^.playeri      =playeri  )then exit;
      if((aw_tarf and wtr_owner_a  )=0)and(tu^.player^.team =team     )then exit;
      if((aw_tarf and wtr_owner_e  )=0)and(tu^.player^.team<>team     )then exit;

      if((aw_tarf and wtr_hits_h   )=0)and((0<tu^.hits)
                                       and(tu^.hits< tu^.uid^._mhits ))then exit;
      if((aw_tarf and wtr_hits_d   )=0)and(tu^.hits<=0                )then exit;
      if((aw_tarf and wtr_hits_a   )=0)and(tu^.hits =tu^.uid^._mhits  )then exit;

      if((aw_tarf and wtr_complete )=0)and(tu^.iscomplete             )then exit;
      if((aw_tarf and wtr_ncomplete)=0)and(tu^.iscomplete =false      )then exit;

      if(not tu^.uid^._ukbuilding  )then
      begin
      if((aw_tarf and wtr_stun     )=0)and(tu^.buff[ub_Pain]> 0       )then exit;
      if((aw_tarf and wtr_nostun   )=0)and(tu^.buff[ub_Pain]<=0       )then exit;
      end;

      if(not CheckUnitBaseFlags(tu,aw_tarf))then exit;

      // Distance requirements
      if(aw_max_range=0) // = srange
      then awr:=ud-srange
      else
        if(aw_max_range<0) // melee
        then awr:=ud-(_r+tu^.uid^._r-aw_max_range)  // need transport check
        else
          if(aw_max_range>=aw_fsr0)  // relative srange
          then awr:=ud-(srange+(aw_max_range-aw_fsr))
          else awr:=ud-aw_max_range; // absolute
      if(aw_max_range>=0)then
       if(tu^.ukfly)
       then awr-=_a_BonusAntiFlyRange
       else awr-=_a_BonusAntiGroundRange;

      canmove:=(speed>0)and(ua_id<>ua_hold)and(transportu=nil);
      pfcheck:=(ukfly)or(ukfloater)or(pfzone=tu^.pfzone);

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
   if(tu^.hits<=fdead_hits)or(tu^.buff[ub_Invuln]>0)then exit;
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

function _unitWeaponPriority(tu:PTUnit;priorset:byte;highprio:boolean):integer;
var i:integer;
procedure incPrio(add:boolean);
begin
   if(add)
   then _unitWeaponPriority+=i;
   i:=i div 2;
end;
begin
   i:=4096;
   _unitWeaponPriority:=0;

   incPrio(tu^.buff[ub_Invuln]<=0);
   incPrio(highprio);

   with tu^  do
   with uid^ do
   case priorset of
wtp_building         : incPrio(    _ukbuilding   );
wtp_BuildingHeavy    : begin
                       incPrio(    _ukbuilding   );
                       incPrio(not _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitLightBio     : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _uklight      );
                       incPrio(not _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioLight     : begin
                       incPrio(not _ukbuilding   );
                       incPrio(not _ukmech       );
                       incPrio(    _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioHeavy     : begin
                       incPrio(not _ukbuilding   );
                       incPrio(not _ukmech       );
                       incPrio(not _uklight      );
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
                       incPrio(not iscomplete    );
                       end;
wtp_Light            : incPrio(    _uklight      );
wtp_Fly              : begin
                       incPrio(     ukfly        );
                       incPrio(uidi<>UID_LostSoul);
                       incPrio(not iscomplete    );
                       end;
wtp_nolost_hits      : incPrio(uidi<>UID_LostSoul);
wtp_UnitLight       : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_limit            : incPrio(not _ukbuilding   );
wtp_Scout            : begin
                       incPrio(_limituse<ul3);
                       incPrio(ukfly or ukfloater);
                       incPrio(transportM<=0);
                       _unitWeaponPriority+=speed;
                       end;
   end;
end;

function _unit_target(pu,tu:PTUnit;ud:integer;a_tard:pinteger;t_weap:pbyte;a_tarp:PPTUnit;t_prio:pinteger):boolean;
var tw:byte;
n_prio:integer;
begin
   _unit_target:=false;
   with pu^ do
   with uid^ do
   begin
      tw:=unit_target2weapon(pu,tu,ud,t_weap^,nil);

      if(tw>MaxUnitWeapons)then exit;

      _unit_target:=true;

      if(tw>t_weap^)
      then exit
      else
       with _a_weap[tw] do
        if(tw<t_weap^)
        then n_prio:=_unitWeaponPriority(tu,aw_tarprior,ai_HighPriorityTarget(player,tu))
        else
        begin
           n_prio:=_unitWeaponPriority(tu,aw_tarprior,ai_HighPriorityTarget(player,tu));

           case aw_tarprior of
           wtp_notme_hits: if(tu<>pu)then n_prio+=1;
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

procedure unit_aura_effects(pu,tu:PTUnit;ud:integer);
begin
   // pu - aura source
   // tu - target
   with pu^     do
   with uid^    do
   with player^ do
   case uidi of
UID_HAKeep,
UID_HKeep     : if(ud<srange)
               and(not tu^.uid^._ukbuilding)
               and(team<>tu^.player^.team)then
                 if(tu^.buff[ub_Decay]<=fr_fpsd2)and(upgr[upgr_hell_paina]>0)then
                 begin
                    unit_damage(tu,DecayAuraDamage,1,playeri,true);
                    tu^.buff[ub_Decay]:=fr_fps1;
                 end;
   end;
end;

procedure unit_capture_point(pu:PTUnit);
var i :byte;
begin
   with pu^ do
    for i:=1 to MaxCPoints do
     with g_cpoints[i] do
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
nup_tar,
uontard,
    ud : integer;
    uds: single;
a_tarp,
pup_tar,
tu_transport,
    tu : PTUnit;
good_target,
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
      nup_tar  := 0;
      uontard := NOTSET;
      tu_transport:=nil;
      if(StayWaitForNextTarget>0)
      then StayWaitForNextTarget-=1;

      u_royal_cd:=NOTSET;
      u_royal_d :=NOTSET;
      if(g_mode=gm_royale)then
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

      pushout      := solid and unit_canMove(pu) and (a_reload<=0);
      attack_target:= unit_canAttack(pu,false);
      aicode       := (state=ps_comp);//and(isselected);
      fteleport_tar:= (not IsUnitRange(ua_tar,nil))and(_ability=uab_Teleport);
      swtarget     := false;
      pup_tar:=nil;
      if(IsUnitRange(ua_tar,@pup_tar))and(aicode=false)then
        if(pup_tar^.player=player)and(pup_tar^.hits>0)and(pup_tar^.reload>0)then
          case g_uids[pup_tar^.uidi]._ability of
uab_Teleport      : swtarget:=true;
          end;

      aiu_InitVars(pu);
      if(aicode)then
      begin
         ai_InitVars(pu);
         ai_CollectData(pu,pu,0,nil,false);
      end;
      aiu_CollectData(pu,pu,0,nil,false);

      if(attack_target)then _unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

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

            if(attack_target)
            then good_target:=_unit_target(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio)
            else good_target:=false;

            aiu_CollectData(pu,tu,ud,tu_transport,good_target);
            if(aicode)then ai_CollectData(pu,tu,ud,tu_transport,good_target);

            if(tu^.hits>0)and(tu_transport=nil)then
            begin
               unit_aura_effects(pu,tu,ud);

               if(pushout)then
                 if(_r<=tu^.uid^._r)or(tu^.speed<=0)or(not tu^.iscomplete)then
                   if(tu^.solid)and(ukfly=tu^.ukfly)then unit_PushFromUnit(pu,tu,uds);

               if(swtarget)then
                 if(ud<srange)and(tu^.playeri=playeri)and(tu^.uidi=pup_tar^.uidi)and(tu^.reload<pup_tar^.reload)then
                   if(IsUnitRange(tu^.ua_tar,nil)and(tu^.ua_tar=pup_tar^.ua_tar))
                   or((tu^.ua_x=pup_tar^.ua_x)and(tu^.ua_y=pup_tar^.ua_y))
                   then ua_tar:=tu^.unum;

               if(fteleport_tar)then
               begin
                  ud:=point_dist_int(ua_x,ua_y,tu^.x,tu^.y)-tu^.uid^._r;
                  if(ud<srange)and(ud<uontard)then
                   if(team=tu^.player^.team)then
                   begin
                      nup_tar:=uc;
                      uontard:=ud;
                   end;
               end;
            end;
         end;
      end;

      unit_PushFromObstacles(pu);

      if(fteleport_tar)and(nup_tar>0)then ua_tar:=nup_tar;

      if(attack_target)and(a_tard<NOTSET)then StayWaitForNextTarget:=0;

      aiu_code(pu);
      if(aicode){and(playeri=PlayerClient)}then ai_code(pu);

      if(buff[ub_Damaged]>0)then GameLogUnitAttacked(pu);
   end;
end;

procedure unit_mcycle_cl(pu,transportu:PTUnit);
var uc,a_tard,
t_prio,
    ud : integer;
a_tarp,
    tu : PTUnit;
t_weap : byte;
udetect,
attack_target: boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      StayWaitForNextTarget:=0;
      if(ServerSide)then
      begin
         a_tar  :=0;
         a_tard :=NOTSET;
         t_weap :=255;
         a_tarp :=nil;
         t_prio :=0;
         attack_target:=unit_canAttack(pu,false);
      end
      else attack_target:=false;

      if(transportu<>nil)then
      begin
         if(IsUnitRange(transportu^.transport,nil))then exit;
         vsnt   :=transportu^.vsnt;
         udetect:=false;
      end
      else udetect:=true;

      if(udetect=false)and(attack_target=false)then exit;  // in transport & client side

      if(attack_target)and(ServerSide)then _unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

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
               if(transportu=nil)and(tu^.hits>0)then
                if(not IsUnitRange(tu^.transport,nil))then unit_aura_effects(pu,tu,ud);
            end;
            if(attack_target)then _unit_target(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio);
         end;
      end;
   end;
end;



function unit_load(pu,tu:PTUnit):boolean;
begin
   //pu - transport
   //tu - target
   unit_load:=false;
   if(unit_CheckTransport(pu,tu))then
   with pu^ do
   begin
      transportC+=tu^.uid^._transportS;
      tu^.transport:=unum;
      tu^.a_tar:=0;
      if(ua_tar=tu^.unum)then     ua_tar:=0;
      if(tu^.ua_tar=unum)then tu^.ua_tar:=0;
      unit_UnSelect(tu);
      {$IFDEF _FULLGAME}
      SoundPlayUnit(snd_transport,pu,nil);
      {$ENDIF}
      unit_load:=true;
   end;
end;
function _unit_unload(pu,tu:PTUnit):boolean;
begin
   //pu - transport
   //tu - target
   _unit_unload:=false;
   if(pu=nil)then
     if(not IsUnitRange(tu^.transport,@pu))then exit;
   with tu^ do
     if(transport=pu^.unum)and(pu^.buff[ub_CCast]<=0)then
     begin
        pu^.buff[ub_CCast]:=fr_fpsd4;
        pu^.transportC-=uid^._transportS;
        transport:=0;
        x    :=pu^.x-g_randomr(pu^.uid^._r);
        y    :=pu^.y-g_randomr(pu^.uid^._r);
        ua_x :=x;
        ua_y :=y;
        {$IFDEF _FULLGAME}
        SoundPlayUnit(snd_transport,pu,nil);
        {$ENDIF}
        _unit_unload:=true;
     end;
   with pu^ do
    if(transportC<=0)then ua_id:=ua_attack;
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
         if(ptransport^.ua_id=uo_unload)or(ptransport^.transportC>ptransport^.transportM)then
           if(not ptransport^.ukfly)or(not pf_IfObstacleZone(ptransport^.pfzone))then
             if(_unit_unload(ptransport,pu))then exit;

         if(ptransport^.ua_id=ua_move  )
         or(ptransport^.ua_id=ua_hold  )
         or(ptransport^.ua_id=ua_attack)then ua_id:=ptransport^.ua_id;

         if(IsUnitRange(ptransport^.ua_tar,@tu))then
         begin
            a_tar:=ptransport^.ua_tar;
            if(unit_target2weapon(pu,tu,-1,255,nil)<=MaxUnitWeapons)then ua_id:=uo_attack;
         end;
      end;
   end;
end;

function _unit_rebuild(pu:PTUnit;Check:boolean):boolean;
function _getMHits(uid:byte):integer;
begin
   with g_uids[uid] do
    if(_isbarrack)
    or(_issmith  )
    or((_attack>0)and(not _isbuilder))
    then _getMHits:=_hhmhits
    else _getMHits:=_hmhits;
end;
begin
   _unit_rebuild:=false;
   with pu^ do
    with uid^ do
     if(not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_canRebuild(pu),pu))then
      _unit_rebuild:=not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_morph(pu,_rebuild_uid,false,trunc(_getMHits(_rebuild_uid)*(hits/_mhits)),_rebuild_level,Check),pu);
end;

function unit_sability(pu:PTUnit;Check:boolean):boolean;
begin
   unit_sability:=false;
   with pu^ do
   with uid^ do
     if(transportC>0)then
     begin
        unit_sability:=true;
        if(not Check)then ua_id:=ua_unload;
     end
     else
       if(not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_canAbility(pu),pu))then
         with player^ do
           case _ability of
uab_SpawnLost     : if(buff[ub_Cast]<=0)and(buff[ub_CCast]<=0)then
                    begin
                       unit_sability:=true;
                       if(not Check)then
                       begin
                          buff[ub_Cast ]:=fr_fpsd2;
                          buff[ub_CCast]:=fr_fps2;
                          if(upgr[upgr_hell_phantoms]>0)
                          then ability_SpawnUnitStep(pu,UID_Phantom )
                          else ability_SpawnUnitStep(pu,UID_LostSoul);
                       end;
                    end;
uab_CCFly         : if(zfall=0)and(buff[ub_CCast]<=0)then
                    begin
                       unit_sability:=true;
                       if(not Check)then
                         if(level>0)
                         then level:=0
                         else level:=1;
                    end;
uab_RebuildInPoint: unit_sability:=_unit_rebuild(pu,Check);
           else
              PlayerSetProdError(playeri,lmt_argt_unit,uidi,ureq_usepsaorder,pu);
           end;
end;
function unit_psability(pu:PTUnit;o_x,o_y,o_tar:integer;Check:boolean):boolean;
begin
   unit_psability:=false;
   with pu^ do
   with uid^ do
     if(transportC>0)then
     begin
        unit_psability:=true;
        if(not Check)then unit_SetOrder(pu,0,o_x,o_y,-1,-1,ua_psability);
     end
     else
       if(not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_canAbility(pu),pu))then
         with uid^ do
         begin
            case _ability of
uab_UACStrike        : unit_psability:=unit_ability_UACStrike  (pu,o_x,o_y     ,Check);
uab_UACScan          : unit_psability:=unit_ability_UACScan    (pu,o_x,o_y     ,Check);
uab_HInvulnerability : unit_psability:=unit_ability_HInvuln    (pu,o_tar       ,Check);
uab_HTowerBlink      : unit_psability:=unit_ability_HTowerBlink(pu,o_x,o_y     ,Check);
uab_HKeepBlink       : unit_psability:=unit_ability_HKeepBlink (pu,o_x,o_y     ,Check);
uab_HellVision       : unit_psability:=unit_ability_HellVision (pu,o_tar       ,Check);
uab_Teleport         : unit_psability:=unit_ability_RevTeleport(pu,o_tar,NOTSET,Check);
uab_RebuildInPoint   : begin
                          unit_psability:=true;
                          if(not Check)then
                            if(speed>0)then
                            begin
                               _push_out(o_x,o_y,g_uids[_rebuild_uid]._r,unum,@o_x,@o_y,false, not ukfloater or(player^.upgr[upgr_race_extbuilding[uid^._urace]]<=0) );
                               unit_SetOrder(pu,0,o_x,o_y,-1,-1,ua_psability);
                            end
                            else unit_SetOrder(pu,0,o_x,o_y,-1,-1,ua_psability);
                       end;
uab_CCFly            : if(speed>0)then
                       begin
                          unit_psability:=true;
                          if(not Check)then
                          begin
                             _push_out(o_x,o_y,_r,unum,@o_x,@o_y,false, player^.upgr[upgr_race_extbuilding[uid^._urace]]<=0 );
                             unit_SetOrder(pu,0,o_x,o_y-fly_hz,-1,-1,ua_psability);
                          end;
                       end
                       else
                         if(unit_sability(pu,Check))then
                           if(Check)
                           then unit_psability:=true
                           else
                           begin
                              _push_out(o_x,o_y,_r,unum,@o_x,@o_y,false, player^.upgr[upgr_race_extbuilding[uid^._urace]]<=0 );
                              unit_SetOrder(pu,0,o_x,o_y-fly_hz,-1,-1,ua_psability);
                              unit_psability:=true;
                           end;

            end;
         end;
end;

procedure unit_StartResurrection(tu:PTUnit);
begin
   with tu^ do
   begin
      buff[ub_Resurect]:=fr_fps2;
      zfall:=-uid^._zfall;
      ukfly:= uid^._ukfly;
   end;
end;

function unit_TryZombification(pu,tu:PTUnit):boolean;
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

   //pu - zombificator
   //tu - target

   if(tu^.uid^._zombie_uid=0)then exit;
   _zuid:=@g_uids[tu^.uid^._zombie_uid];

   with pu^ do
   with uid^ do
   with player^ do
   begin
      if((armylimit-_limituse+_zuid^._limituse)>MaxPlayerLimit)then exit;
      if((menergy-_genergy+_zuid^._genergy)<=0)then exit;
   end;

   if(tu^.iscomplete=false)
   or(tu^.uid^._zombie_uid =0)
   or(tu^.uid^._zombie_hits<tu^.hits)
   or(tu^.hits<=fdead_hits          )then exit;

   if(ServerSide)then
   begin
      _h:=tu^.hits/tu^.uid^._mhits;
      _d:=tu^.dir;
      _o:=pu^.group;
      _f:=tu^.ukfly;
      _z:=tu^.zfall;
      _l:=tu^.level;
      {$IFDEF _FULLGAME}
      _s:=tu^.shadow;
      {$ENDIF}

      unit_kill(pu,true,true,false,false,true);
      unit_add(tu^.x,tu^.y,pu^.unum,tu^.uid^._zombie_uid,pu^.playeri,true,true,_l);
      unit_kill(tu,true,true,false,false,true);

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
            unit_PC_base_dec(LastCreatedUnitP);
            unit_StartResurrection(LastCreatedUnitP);
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
         a_exp_next:=level*ExpLevel1+ExpLevel1;
         GameLogUnitPromoted(pu);
         {$IFDEF _FULLGAME}
         effect_LevelUp(pu,0,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_attack(pu:PTUnit):boolean;
var w,a   : byte;
     tu   : PTUnit;
damage,
painX,
upgradd,c : integer;
fakemissile,
AttackInMove: boolean;
{$IFDEF _FULLGAME}
attackervis,
targetvis : boolean;
{$ENDIF}
procedure AttackEffects;
var i:byte;
begin
   with pu^ do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if((aw_reqf and wpr_avis)>0)then
      begin
         AddToInt(@tu^.vsnt[player^.team],vistime);
         {$IFDEF _FULLGAME}
         if not(a_reload in aw_rld_a)then
           if(AddToInt(@tu^.buff[ub_ArchFire],fr_fps1))then SoundPlayUnit(snd_archvile_fire,tu,@targetvis);
         {$ENDIF}
      end;
      AddToInt(@vsnt[tu^.player^.team],a_reload+1);
      AddToInt(@vsnt[tu^.player^.team],vistime);
      for i:=0 to MaxPlayers do
        if(tu^.vsnt[i]>0)
        or(    vsnt[i]>0)then
        begin
                vsnt[i]:=max2(vsnt[i],tu^.vsnt[i]);
            tu^.vsnt[i]:=vsnt[i];
        end;
   end;
end;
begin
   unit_attack:=false;
   with pu^ do
   begin
      if(not IsUnitRange(a_tar,@tu))then exit;

      if(ServerSide)then
      begin
         if(a_reload<=0)then
         begin
            w:=unit_target2weapon(pu,tu,-1,255,@a);

            if(w>MaxUnitWeapons)or(a=0)then
            begin
               if(ServerSide)then
               begin
                  a_tar:=0;
                  StayWaitForNextTarget:=1;
               end;
               exit;
            end;

            a_weap:=w;
         end
         else
         begin
            a:=target_weapon_check(pu,tu,-1,a_weap,true,false);

            if(a=0)then
            begin
               if(ServerSide)then
               begin
                  a_tar:=0;
                  StayWaitForNextTarget:=1;
               end;
               exit;
            end;
         end;

         unit_attack:=true;

         upgradd:=0;

         with uid^ do
          with _a_weap[a_weap] do
           AttackInMove:=(aw_reqf and wpr_move)>0;

         case a of
wmove_closer    : begin
                     if(not AttackInMove)then
                     begin
                        mv_x:=tu^.x;
                        mv_y:=tu^.y;
                     end;
                     exit;
                  end;
wmove_farther   : begin
                     if(not AttackInMove)or(ua_bx<=0)then
                       if(x=tu^.x)and(y=tu^.y)then
                       begin
                          mv_x:=x-g_randomr(2);
                          mv_y:=y-g_randomr(2);
                       end
                       else
                       begin
                          mv_x:=x-(tu^.x-x);
                          mv_y:=y-(tu^.y-y);
                       end;
                     exit;
                  end;
wmove_noneed    : if(not AttackInMove)then
                  begin
                     mv_x:=x;
                     mv_y:=y;
                  end;
         else
           StayWaitForNextTarget:=1;
           exit;
         end;
      end
      else
      begin
         unit_attack:=true;
         if(a_weap>MaxUnitWeapons)then exit;

         if(tu^.hits<=fdead_hits)then exit;

         with uid^ do
          with _a_weap[a_weap] do
           AttackInMove:=(aw_reqf and wpr_move)>0;
      end;

      if(not unit_canAttack(pu,true))then
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
         targetvis  :=CheckUnitUIVisionScreen(tu);
         attackervis:=CheckUnitUIVisionScreen(pu);
         {$ENDIF}

         if(a_reload<=0)then
         begin
            a_shots  +=1;
            a_reload :=aw_reload;
            a_tar_cl :=a_tar;
            a_weap_cl:=a_weap;

            if(ServerSide)and(not _ukbuilding)then
              if((aw_max_range<0)and(aw_type=wpt_directdmg))
              or((playeri=0)and(g_mode=gm_invasion))
              then unit_AddExp(pu,aw_reload*2)
              else unit_AddExp(pu,aw_reload  );
            if(not AttackInMove)then
            begin
               if(x<>tu^.x)
               or(y<>tu^.y)then dir:=point_dir(x,y,tu^.x,tu^.y);
               if(ServerSide)then StayWaitForNextTarget:=(a_reload div order_period)+1;
            end;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pu,true,@attackervis);
            {$ENDIF}
            AttackEffects;
         end;

         if(cycle_order=g_cycle_order)then AttackEffects;

         {$IFDEF _FULLGAME}
         if(targetvis)then
          if(aw_eid_target>0)and(aw_eid_target_onlyshot=false)then
          begin
             if(not IsUnitRange(tu^.transport,nil))then
              if((G_Step mod fr_fpsd3)=0)then effect_add(tu^.vx,tu^.vy,SpriteDepth(tu^.vy+1,tu^.ukfly),aw_eid_target);
             if(aw_snd_target<>nil)then
              if((G_Step mod fr_fps1)=0)then SoundPlayUnit(aw_snd_target,tu,@targetvis);
          end;
         {$ENDIF}

         if(a_reload in aw_rld_s)then
         begin
            if(aw_fakeshots=0)
            then fakemissile:=false
            else fakemissile:=(a_shots mod aw_fakeshots)>0;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pu,false,@attackervis);
            if(targetvis)then
             if(aw_eid_target>0)and(aw_eid_target_onlyshot)then
             begin
                if(not IsUnitRange(tu^.transport,nil))then
                effect_add(tu^.vx-g_randomr(tu^.uid^._missile_r),tu^.vy-g_randomr(tu^.uid^._missile_r),SpriteDepth(tu^.vy+1,tu^.ukfly),aw_eid_target);

                SoundPlayUnit(aw_snd_target,tu,@targetvis);
             end;
            {$ENDIF}
            if(aw_dupgr>0)and(aw_dupgr_s>0)then upgradd:=player^.upgr[aw_dupgr]*aw_dupgr_s;
            if(level>0)and(not _ukbuilding)then upgradd+=level*_level_damage;
            if(not AttackInMove)then
              if(x<>tu^.x)
              or(y<>tu^.y)then dir:=point_dir(x,y,tu^.x,tu^.y);
            case aw_type of
wpt_missle     : if(aw_oid>0)then
                  if(aw_count=0)
                  then missile_add(tu^.x,tu^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,fakemissile,upgradd,aw_dmod)
                  else
                    if(aw_count>0)
                    then for c:=1 to aw_count do missile_add(tu^.x,tu^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,fakemissile,upgradd,aw_dmod)
                    else
                      if(aw_count<0)then
                      begin
                         missile_add(tu^.x,tu^.y,vx-aw_count+aw_x,vy-aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,fakemissile,upgradd,aw_dmod);
                         missile_add(tu^.x,tu^.y,vx+aw_count+aw_x,vy+aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,fakemissile,upgradd,aw_dmod);
                      end;
wpt_unit       : if(not fakemissile)then ability_SpawnUnitStep(pu,aw_oid);
wpt_directdmg  : if(not fakemissile)and(aw_count>0)then
                 begin
                    damage:=ApplyDamageMod(tu,aw_dmod,aw_count+upgradd);
                    painX :=1;
                    unit_damage(tu,damage,painX,playeri,false);
                 end;
wpt_directdmgZ : if(not fakemissile)and(aw_count>0)then
                  if(not unit_TryZombification(pu,tu))then
                  begin
                     damage:=ApplyDamageMod(tu,aw_dmod,aw_count+upgradd);
                     painX :=1;
                     unit_damage(tu,damage,1,playeri,false);
                  end;
wpt_suicide    : if(ServerSide)then unit_kill(pu,false,true,true,false,true);
            else
              if(ServerSide)and(not fakemissile)then
              case aw_type of
wpt_resurect   : begin
                    unit_StartResurrection(tu);
                    if((aw_reqf and wpr_reload)>0)then reload:=max2(0,aw_count*fr_fps1);
                 end;
wpt_heal       : begin
                    tu^.hits:=mm3(1,tu^.hits+aw_count+upgradd,tu^.uid^._mhits);
                    tu^.buff[ub_Heal]:=aw_reload;
                 end;
              end;
            end;
         end;
      end;
   end;
end;

{procedure _unit_order(pu,transportu:PTUnit);
begin
   with pu^ do
    if(hits<=0)then exit;

   if(transportu<>nil)then _unit_InTransportCode(pu,transportu);

   with pu^ do
   if(ServerSide=false)then
   begin
      _unit_attack(pu);

      if(transportu=nil)and(cycle_order=_cycle_order)then
        if(mp_x<>x)or(mp_y<>y)then
        begin
           mp_x:=x;
           mp_y:=y;
        end;
   end
   else
   begin
      if(transportu=nil)then
      begin
         _unit_uo_tar(pu);

         uo_x:=mm3(1,uo_x,map_mw);
         uo_y:=mm3(1,uo_y,map_mw);

         mv_x:=uo_x;
         mv_y:=uo_y;

         if(uo_id=ua_psability)then
           case uid^._ability of
uab_SpawnLost:  begin
                   mv_x:=x;
                   mv_y:=y;
                   uo_id:=ua_amove;
                   _unit_sability(pu);
                   uo_id:=ua_psability;
                end;
uab_CCFly    :  if(x=uo_x)and(y=uo_y)then
                begin
                   uo_id:=ua_amove;
                   _unit_sability(pu);
                end;
           else
             if(speed<=0)
             then uo_id:=ua_amove
             else
               if(x=uo_x)and(y=uo_y)then
               begin
                  uo_id:=ua_amove;
                  _unit_sability(pu);
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
      then _unit_attack(pu)
      else StayWaitForNextTarget:=0;

      if(apctu=nil)then
        if(unit_canmove(pu))then
          if(mp_x<>mv_x)or(mp_y<>mv_y)then
          begin
             if(not uid^._slowturn)and(player^.state<>ps_comp)then
               if(x<>mv_x)or(y<>mv_y)then dir:=point_dir(x,y,mv_x,mv_y);
             mp_x:=mv_x;
             mp_y:=mv_y;
          end;
   end;
end;
 }

{
procedure _unit_uo_tar(pu:PTUnit);
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
      if(_IsUnitRange(uo_tar,@tu))then
      begin
         if(_IsUnitRange(tu^.transport,nil))
         or(CheckUnitTeamVision(player^.team,tu,false)=false)then
         begin
            uo_tar:=0;
            exit;
         end;

         td :=point_dist_int(x,y,tu^.x,tu^.y);
         if(tu^.solid)
         then tdm:=td-(_r+tu^.uid^._r)
         else tdm:=td- min2(_r,tu^.uid^._r);

         if(tdm<melee_r)then
         begin
            if(_unit_load(pu,tu))then exit;
            if(_unit_load(tu,pu))then exit;
         end;

         case _ability of
uab_Teleport     : if(tu^.player^.team<>player^.team )then begin uo_tar:=0;exit; end;
         end;

         case tu^.uid^._ability of
uab_Teleport     : if(_ability_teleport(pu,tu,td))then exit;//team
         end;

         w:=_unit_target2weapon(pu,tu,td,255,@a);
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
          if(_itcanapc(tu,pu))and(not _IsUnitRange(tu^.uo_tar,nil))and(tu^.uo_x=tu^.x)and(tu^.uo_y=tu^.y)then
          begin
             tu^.uo_x:=x;
             tu^.uo_y:=y;
          end;

         uo_x:=tu^.vx;
         uo_y:=tu^.vy;
      end;
end;
}

procedure unit_OrderTarget(pu:PTUnit);
var
tu     : PTUnit;
td,tdm : integer;
a,w    : byte;
begin
   with pu^  do
   with uid^ do
   if(ua_tar=unum)or(ua_bx>=0)
   then ua_tar:=0
   else
     if(IsUnitRange(ua_tar,@tu))then
     begin
        if(IsUnitRange(tu^.transport,nil))
        or(not CheckUnitTeamVision(player^.team,tu,false))then
        begin
           ua_tar:=0;
           exit;
        end;

        td :=point_dist_int(x,y,tu^.x,tu^.y);
        if(tu^.solid)
        then tdm:=td-    (_r+tu^.uid^._r)
        else tdm:=td-min2(_r,tu^.uid^._r);

        if(tdm<melee_r)then
        begin
           if(unit_load(pu,tu))then exit;
           if(unit_load(tu,pu))then exit;
        end;

        case _ability of
uab_Teleport     : if(tu^.player^.team<>player^.team)then begin ua_tar:=0;exit; end;
        end;

        case tu^.uid^._ability of
uab_Teleport     : if(ability_teleport(pu,tu,td))then exit;//team
        end;

        w:=unit_target2weapon(pu,tu,td,255,@a);
        if(w<=MaxUnitWeapons)then
        begin
           a_tar :=ua_tar;
           ua_id :=ua_attack;
        end;

        if(tdm<=melee_r)then
        begin
           ua_x:=x;
           ua_y:=y;
           exit;
        end;

        if(player=tu^.player)and(tu^.ukfly)then
          if(unit_CheckTransport(tu,pu))and(not IsUnitRange(tu^.ua_tar,nil))and(tu^.ua_x=tu^.x)and(tu^.ua_y=tu^.y)then
          begin
             tu^.ua_x:=x;
             tu^.ua_y:=y;
          end;

        ua_x:=tu^.vx;
        ua_y:=tu^.vy;
     end;
end;

procedure unit_BaseBehavior(pu,transportu:PTUnit);
begin
   if(transportu<>nil)then unit_InTransportCode(pu,transportu);

   with pu^ do
   if(ServerSide=false)then
   begin
      unit_attack(pu);

      if(transportu=nil)and(cycle_order=g_cycle_order)then
        if(mp_x<>x)or(mp_y<>y)then
        begin
           mp_x:=x;
           mp_y:=y;
        end;
   end
   else
   begin
      if(transportu=nil)then
      begin
         unit_OrderTarget(pu);

         ua_x:=mm3(1,ua_x,map_mw);
         ua_y:=mm3(1,ua_y,map_mw);

         mv_x:=ua_x;
         mv_y:=ua_y;

         if(ua_id=ua_psability)then
           case uid^._ability of
         uab_SpawnLost: begin
                           mv_x:=x;
                           mv_y:=y;
                           ua_id:=ua_attack;
                           unit_sability(pu,false);
                           ua_id:=ua_psability;
                        end;
           else
               if(speed<=0)and( uid^._ability<>uab_CCFly)
               then ua_id:=ua_attack
               else
                 if(x=ua_x)and(y=ua_y)then
                 begin
                    ua_id:=ua_attack;
                    unit_sability(pu,false);
                 end;
           end
         else
           if(x=ua_x)and(y=ua_y)then
             if(ua_bx>=0)then
             begin
                ua_x :=ua_bx;
                ua_y :=ua_by;
                ua_bx:=x;
                ua_by:=y;
             end
             else
               if(ua_id=ua_move)then ua_id:=ua_attack;
      end;

      if(ua_id=ua_attack)
      then unit_attack(pu)
      else StayWaitForNextTarget:=0;

      if(transportu=nil)then
        if(unit_canMove(pu))then
          if(mp_x<>mv_x)or(mp_y<>mv_y)then
          begin
             if(not uid^._slowturn)and(player^.state<>ps_comp)then
               if(x<>mv_x)or(y<>mv_y)then dir:=point_dir(x,y,mv_x,mv_y);
             mp_x:=mv_x;
             mp_y:=mv_y;
          end;
   end;
end;

{function _unit_player_order(pu:PTUnit;order_id,order_tar,order_x,order_y:integer):boolean;
procedure _setUO(aid,atar,ax,ay,apx,apy:integer;atarz,nospeedcheck:boolean);
begin
   with pu^     do
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
begin
   _unit_player_order:=true;
   with pu^     do
   with uid^    do
   with player^ do
   case order_id of
co_destroy  : _unit_kill(pu,false,false,true,false,true);
co_rcamove,
co_rcmove   : begin     // right click
                 uo_tar:=0;
                 uo_x  :=order_x;
                 uo_y  :=order_y;
                 uo_bx :=-1;

                 if(order_tar<>unum)then uo_tar:=order_tar;
                 if(order_id<>co_rcmove)or(speed<=0)
                 then uo_id:=ua_amove
                 else uo_id:=ua_move;
              end;
co_stand    : _setUO(ua_hold, 0        ,x      ,y      ,-1,-1,true ,false);
co_move     : _setUO(ua_move ,order_tar,order_x,order_y,-1,-1,true ,false);
co_patrol   : _setUO(ua_move ,0        ,order_x,order_y, x, y,true ,false);
co_astand   : _setUO(ua_amove,0        ,x      ,y      ,-1,-1,false,false);
co_amove    :
         if(_IsUnitRange(order_tar,nil))
         then _setUO(ua_move ,order_tar,order_x,order_y,-1,-1,false,false)
         else _setUO(ua_amove,0        ,order_x,order_y,-1,-1,false,false);
co_apatrol  : _setUO(ua_amove,0        ,order_x,order_y, x, y,false,false);
co_psability: if(uo_id<>ua_psability)
              or((ucl_cs[true]+ucl_cs[false])=1)then
                if(transportM>0)and(transportC>0)then
                begin
                   _setUO(ua_psability,0,order_x,order_y,-1,-1,true ,false);
                   exit;
                end
                else
                  case _ability of
0                    : ;
uab_UACStrike        : if(_unit_ability_UACStrike  (pu,order_x,order_y ))then exit;
uab_UACScan          : if(_unit_ability_uradar     (pu,order_x,order_y ))then exit;
uab_HInvulnerability : if(_unit_ability_HInvuln    (pu,order_tar       ))then exit;
uab_HTowerBlink      : if(_unit_ability_HTowerBlink(pu,order_x,order_y ))then exit;
uab_HKeepBlink       : if(_unit_ability_HKeepBlink (pu,order_x,order_y ))then exit;
uab_HellVision       : if(_unit_ability_HellVision (pu,order_tar       ))then exit;
uab_Teleport         : if(_unit_ability_RevTeleport(pu,order_tar,NOTSET))then exit;
uab_CCFly            : if(speed>0)then
                       begin
                          if(_canAbility(pu)=0)then
                          begin
                             _setUO(ua_psability,0,order_x,order_y,-1,-1,true ,false);
                             _push_out(uo_x,uo_y,_r,unum,@uo_x,@uo_y,false, upgr[upgr_race_extbuilding[uid^._urace]]<=0 );
                             uo_y-=fly_hz;
                             exit;
                          end;
                       end
                       else
                         if(_unit_sability(pu))then
                         begin
                            _setUO(ua_psability,0,order_x,order_y,-1,-1,true ,true);
                            _push_out(uo_x,uo_y,_r,unum,@uo_x,@uo_y,false, upgr[upgr_race_extbuilding[uid^._urace]]<=0 );
                            uo_y-=fly_hz;
                            exit;
                         end;
uab_RebuildInPoint   : begin
                          if(speed>0)then
                          begin
                             _setUO(ua_psability,0,order_x,order_y,-1,-1,true ,false);
                             _push_out(uo_x,uo_y,_uids[_rebuild_uid]._r,unum,@uo_x,@uo_y,false, not ukfloater or (upgr[upgr_race_extbuilding[uid^._urace]]<=0) );
                          end
                          else _setUO(ua_psability,0,order_x,order_y,-1,-1,true ,false);
                          exit;
                       end;
                  else
                    _setUO(ua_psability,0,order_x,order_y,-1,-1,true ,false);
                    exit;
                  end;
co_rebuild :  if(_unit_rebuild (pu))then exit;
co_sability:  if(_unit_sability(pu))then
               if(uo_id<>ua_unload)then exit;
   end;
   _unit_player_order:=false;
end;     }



procedure unit_prod(pu:PTUnit);
var i:integer;
procedure uXCheck(pui:pinteger);
var tu:PTUnit;
begin
   if(not IsUnitRange(pui^,@tu))
   then pui^:=pu^.unum;
   {else
    if(tu^.reload>pu^.reload)
    then pui^:=pu^.unum;}
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   if(iscomplete)and(hits>0)then
   begin
      unit_ProdUnitEnd(pu);
      unit_ProdUpgrEnd(pu);

      uXCheck(@uid_x[            uidi]);
      uXCheck(@ucl_x[_ukbuilding,_ucl]);

      // REGENERATION
      if(cycle_order=g_cycle_regen)then
       if(buff[ub_Damaged]<=0)and(hits<_mhits)then
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
        if(g_cycle_order=cycle_order)and(buff[ub_Damaged]<=0)then
        begin
           hits+=_bstep;
           hits+=_bstep*upgr[upgr_fast_build];
        end;

        if(hits>=_mhits){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
        begin
           hits:=_mhits;
           iscomplete :=true;
           unit_PC_complete_inc(pu);
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
      transportu:=nil;
      pu:=g_punits[u];
      with pu^ do
      if(hits>dead_hits)then
      begin
         if(cycle_order=g_cycle_order)
         then unit_reveal(pu,false);

         unit_BaseCounters(pu);

         if(hits>0)then
         begin
            IsUnitRange(transport,@transportu);

            unit_Bonuses(pu);
            unit_BaseBehavior(pu,transportu);

            if(hits<=0)then continue;

            if(ServerSide)then
            begin
               unit_move(pu);
               unit_prod(pu);

               if(player^.state=ps_comp)then ai_scout_pick(pu);
            end;

            transportu:=nil;
            if(cycle_order=g_cycle_order)and(hits>0)then
              if(ServerSide)and(transportu=nil)
              then unit_mcycle   (pu)
              else unit_mcycle_cl(pu,transportu);

            if(ServerSide)then
              if(transportu=nil)then
                unit_capture_point(pu);
         end
         else unit_death(pu);

         unit_MoveSprite(pu);
      end;
   end;

   missile_Cycle;
end;

////////////////////////////////////////////////////////////////////////////////




