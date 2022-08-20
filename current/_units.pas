


procedure _unit_death(pu:PTUnit);
var tu  : PTUnit;
    uc  : integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
    if(hits>dead_hits)then
    begin
       if(cycle_order=_cycle_order)then
       begin
          for uc:=1 to MaxUnits do
           if(uc<>unum)then
           begin
              tu:=@_units[uc];
              if(tu^.hits>dead_hits)then _unit_detect(pu,tu,dist2(x,y,tu^.x,tu^.y));
           end;
       end;

       if(buff[ub_resur]<=0)then
       begin
          if(ServerSide)or(hits>fdead_hits)then hits-=1;
          {$IFDEF _FULLGAME}
          if(cycle_order=_cycle_order)and(fsr>1)then fsr-=1;
          {$ENDIF}

          if(ServerSide)then
           if(hits<=dead_hits)then _unit_remove(pu);
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
              buff[ub_resur]:=0;
              buff[ub_summoned]:=fr_fps;
              {$IFDEF _FULLGAME}
              _unit_fog_r(pu);
              _unit_summon_effects(pu,nil);
              {$ENDIF}
           end;
        end;
    end;
end;




procedure _unit_damage(pu:PTUnit;damage,pain_f:integer;pl:byte);
var armor:integer;
begin
   if(ServerSide=false)then exit;

   with pu^ do
   if(buff[ub_invuln]<=0)and(hits>0)then
   with uid^ do
   begin
      armor:=0;
      if(bld)then
      begin
         armor:=_base_armor;
         with player^ do
          if(_ukbuilding)
          then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_build_armor[_urace]])*5
          else
            if(_ukmech)
            then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_mech_armor[_urace]])*3
            else armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_bio_armor [_urace]])*2;
      end;

     // if(pl=HPlayer)then
     // writeln(uidi,' ',damage,' ',armor);

      case uidi of
UID_Knight : if(buff[ub_advanced]>0)then damage:=damage div 2;
      else
      end;

      case g_mode of
gm_invasion    : if(playeri=0)then damage:=damage div 2;
      end;

      if(_baseregen<0)then begin armor:=0;damage:=hits;end;

      damage-=armor;

      if(damage<=0)then
       if(_random(abs(damage)+1)=0)
       then damage:=1
       else exit;

      if(hits<=damage)
      then _unit_kill(pu,false,(hits-damage)<=_fastdeath_hits[buff[ub_advanced]>0],true)
      else
      begin
         hits-=damage;
         buff[ub_damaged]:=fr_fps;

         if(not _ukbuilding)and(not _ukmech)then
          if(pain_f>0)and(_painc>0)and(painc>0)and(buff[ub_pain]<=0)then
          begin
             if(uidi=UID_Mancubus)and(buff[ub_advanced]>0)then exit;

             if(pain_f>pains)
             then pains:=0
             else pains-=pain_f;

             if(pains=0)then
             begin
                pains:=painc;

                buff[ub_pain]:=max2(order_period,a_rld);

                with player^ do
                 if(_urace=r_hell)then
                  if(upgr[upgr_hell_pains]>0)then pains+=upgr[upgr_hell_pains]*3;

                {$IFDEF _FULLGAME}
                _unit_pain_effects(pu,nil);
                {$ENDIF}
             end;
          end;
      end;
   end;
end;

function _unit_morph(pu:PTUnit;ouid:byte;obld:boolean;bhits:integer;advanced_mode:byte):cardinal;
var puid:PTUID;
     adv:boolean;
begin
   _unit_morph:=0;
   with pu^     do
   with player^ do
   begin
      puid:=@_uids[ouid];

      if(not obld)or(puid^._ukbuilding)then
       if(menergy<=0)then
       begin
          _unit_morph:=ureq_energy;
          exit;
       end;
      if(not obld)then
      begin
         if((cenergy-uid^._genergy)<puid^._renergy)or(menergy<=uid^._genergy)then
         begin
            _unit_morph:=ureq_energy;
            exit;
         end;
         if(_collisionr(x,y,puid^._r,unum,puid^._ukbuilding,puid^._ukfly,true)>0)then
         begin
            _unit_morph:=ureq_place;
            exit;
         end;
      end;
      if(a_units[ouid]<=0)then
      begin
         _unit_morph:=ureq_max;
         exit;
      end;

      case advanced_mode of
      0:   adv:=false;
      1:   adv:=buff[ub_advanced]>0;
      else adv:=true;
      end;

      _unit_kill(pu,true,true,false);
      _unit_add(vx,vy,ouid,playeri,obld,true,adv);

      if(bhits<0)then bhits:=puid^._mhits div abs(bhits);

      if(bhits>0)and(_LastCreatedUnitP<>nil)then
       if(not _LastCreatedUnitP^.bld)then _LastCreatedUnitP^.hits:=mm3(1,bhits,puid^._mhits);
   end;
end;

procedure _unit_push(pu,tu:PTUnit;uds:single);
var t:single;
   ud:integer;
tusolid:boolean;
begin
   with pu^ do
   with uid^ do
   begin
      t :=uds;
      tusolid:=((tu^.speed<=0)or(not tu^.bld))and(pu^.player=tu^.player);
      if(tusolid)
      then uds-=tu^.uid^._r
      else uds-=tu^.uid^._r+_r;
      ud:=round(uds);

      if(uds<0)then
      begin
         if((tu^.x=x)and(tu^.y=y))then
         begin
            case _random(4) of
            0: x-=ud;
            1: x+=ud;
            2: y-=ud;
            3: y+=ud;
            end;
         end
         else
         begin
            x+=round(uds*(tu^.x-x)/t)+_randomr(2);
            y+=round(uds*(tu^.y-y)/t)+_randomr(2);
         end;

         _unit_correctXY(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         vstp+=trunc(uds/speed*UnitStepTicks);

         if(a_rld<=0)then
          if(tusolid)
          then dir:=_DIR360(dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 ))
          else dir:=_DIR360(dir-( min2(90,max2(-90,dir_diff(dir,p_dir(vx,vy,x,y)))) div 2 ));

         if(tu^.x=tu^.uo_x)and(tu^.y=tu^.uo_y)and(uo_tar=0)then
         begin
            ud:=dist2(uo_x,uo_y,tu^.x,tu^.y)-_r-tu^.uid^._r;
            if(ud<=0)then
            begin
               uo_x:=x;
               uo_y:=y;
            end;
         end;
      end;
   end;
end;

procedure _unit_dpush(pu:PTUnit;td:PTDoodad);
var t,uds:single;
      ud :integer;
begin
   with pu^ do
   with uid^ do
   begin
      t  :=distr(x,y,td^.x,td^.y);
      uds:=t-(_r+td^.r);
      ud :=round(uds);

      if(uds<0)then
      begin
         if((td^.x=x)and(td^.y=y))then
         begin
            case _random(4) of
            0: x-=ud;
            1: x+=ud;
            2: y-=ud;
            3: y+=ud;
            end;
         end
         else
         begin
            x+=trunc(ud*(td^.x-x)/t)+_randomr(2);
            y+=trunc(ud*(td^.y-y)/t)+_randomr(2);
         end;

         _unit_correctXY(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         vstp+=trunc(uds/speed*UnitStepTicks);

         if(a_rld<=0)then dir:=_DIR360(dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 ));

         ud:=dist2(uo_x,uo_y,td^.x,td^.y)-_r-td^.r;
         if(ud<=0)then
         begin
            uo_x:=x;
            uo_y:=y;
         end;
      end;
   end;
end;

procedure _unit_npush(pu:PTUnit;ignore_liquid:boolean);
var i,dx,dy:integer;
begin
   dx:=pu^.x div dcw;
   dy:=pu^.y div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
    with map_dcell[dx,dy] do
     if(n>0)then
      for i:=0 to n-1 do
       with l[i]^ do
        if(r>0)and(t>0)then
        begin
           if(ignore_liquid)then
            if(t in dids_liquids)then continue;
           _unit_dpush(pu,l[i]);
        end;
end;

procedure _unit_npush_dcell(pu:PTUnit);
begin
   with pu^ do
    if(speed>0)and(ukfly=uf_ground)and(solid)and(bld)then _unit_npush(pu,uid^._ukfloater);
end;

procedure _unit_move(pu:PTUnit);
var mdist,ss:integer;
    ddir    :single;
begin
   with pu^ do
    if(x=vx)and(y=vy)then
     if(x<>mv_x)or(y<>mv_y)then
      if(not _IsUnitRange(inapc,nil))then
       if(_canmove(pu))then
       begin
          ss:=speed;

          if(buff[ub_slooow]>0)then ss:=max2(2,ss div 2);

          mdist:=dist(x,y,mv_x,mv_y);
          if(mdist<=speed)then
          begin
             x:=mv_x;
             y:=mv_y;
             dir:=p_dir(vx,vy,x,y);
          end
          else
          begin
             with uid^ do
              if(not _ukbuilding)then
               with player^ do
                if(_ukmech)
                then ss+=upgr[upgr_race_mech_mspeed[_urace]]*2
                else ss+=upgr[upgr_race_bio_mspeed [_urace]]*2;

             if(mdist>70)
             then mdist:=8+_random(25)
             else mdist:=50;

             dir:=dir_turn(dir,p_dir(x,y,mv_x,mv_y),mdist);

             ddir:=dir*degtorad;
             x:=x+round(ss*cos(ddir));
             y:=y-round(ss*sin(ddir));
          end;
          _unit_npush_dcell(pu);
          _unit_correctXY(pu);
          {$IFDEF _FULLGAME}
          _unit_mmcoords(pu);
          _unit_sfog(pu);
          {$ENDIF}
       end;
end;

function _target_weapon_check(pu,tu:PTUnit;ud:integer;cw:byte;checkvis,nosrangecheck:boolean):byte;
var awr:integer;
     au:PTUnit;
canmove:boolean;
begin
   _target_weapon_check:=0;

   //pu - attacker
   //tu - target

   if(checkvis)then
    if(_uvision(pu^.player^.team,tu,false)=false)then exit;
   if(cw>MaxUnitWeapons)then exit;
   if(tu^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=dist(pu^.x,pu^.y,tu^.x,tu^.y);

   with pu^ do
   with uid^ do
   with player^ do
   with _a_weap[cw] do
   begin
      if(aw_rld=0)then exit;

      // Weapon type requirements
      case aw_type of
wpt_resurect : if(tu^.buff[ub_resur]>0)
               or(tu^.buff[ub_pain ]>0)
               or(tu^.hits<=fdead_hits)
               or(tu^.hits> 0         )then exit;
wpt_heal     : if(tu^.hits<=0)
               or(tu^.hits>=tu^.uid^._mhits)
               or(tu^.bld=false       )
               or(tu^.buff[ub_heal]>0 )then exit;
      end;

      // transport check
      au:=nil;
      if(_IsUnitRange(inapc,@au))then
      begin
         if(_IsUnitRange(tu^.inapc,nil))then
         begin
            if(au<>tu)and(inapc<>tu^.inapc)then exit;
            if(aw_max_range>=0)then exit; // only melee attack
         end
         else
           if(au<>tu)then
           begin
             if(aw_max_range< 0)then exit; // melee
           end
           else
             if(aw_max_range>=0)then exit; // ranged
      end
      else
        if(_IsUnitRange(tu^.inapc,nil))then exit;

      // UID and UPID requirements

      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0         )then exit;
      if(aw_rupgr>0)and(upgr  [aw_rupgr]< aw_rupgr_l)then exit;

      // requirements to attacker and some flags

      if not(tu^.uidi in aw_uids)then exit;

      if(cf(@aw_reqf,@wpr_adv ))and(buff[ub_advanced]<=0)then exit;
      if(cf(@aw_reqf,@wpr_nadv))and(buff[ub_advanced]> 0)then exit;

      if(cf(@aw_reqf,@wpr_air   ))then
       if(ukfly=uf_ground)or(tu^.ukfly=uf_ground)then exit;
      if(cf(@aw_reqf,@wpr_ground))then
       if(ukfly=uf_fly)or(tu^.ukfly=uf_fly)then exit;

      if(cf(@aw_reqf,@wpr_zombie))then
      begin
         if(tu^.bld=false)
         or(tu^.uid^._zombie_uid =0)
         or(tu^.uid^._zombie_hits<tu^.hits)
         or(tu^.hits<=fdead_hits)then exit;
      end;

      // requirements to target

      if(cf(@aw_tarf,@wtr_owner_p )=false)and(tu^.playeri      =playeri  )then exit;
      if(cf(@aw_tarf,@wtr_owner_a )=false)and(tu^.player^.team =team     )then exit;
      if(cf(@aw_tarf,@wtr_owner_e )=false)and(tu^.player^.team<>team     )then exit;

      if(cf(@aw_tarf,@wtr_hits_h  )=false)and((0<tu^.hits)
                                          and(tu^.hits< tu^.uid^._mhits ))then exit;
      if(cf(@aw_tarf,@wtr_hits_d  )=false)and(tu^.hits<=0                )then exit;
      if(cf(@aw_tarf,@wtr_hits_a  )=false)and(tu^.hits =tu^.uid^._mhits  )then exit;

      if(cf(@aw_tarf,@wtr_bio     )=false)and(not tu^.uid^._ukmech       )then exit;
      if(cf(@aw_tarf,@wtr_mech    )=false)and(tu^.uid^._ukmech           )then exit;
      if(cf(@aw_tarf,@wtr_building)=false)and(tu^.uid^._ukbuilding       )then exit;

      if(cf(@aw_tarf,@wtr_bld     )=false)and(tu^.bld                    )then exit;
      if(cf(@aw_tarf,@wtr_nbld    )=false)and(tu^.bld =false             )then exit;

      if(cf(@aw_tarf,@wtr_ground  )=false)and(tu^.ukfly = uf_ground      )then exit;
      if(cf(@aw_tarf,@wtr_fly     )=false)and(tu^.ukfly = uf_fly         )then exit;

      if(cf(@aw_tarf,@wtr_adv     )=false)and(tu^.buff[ub_advanced]> 0   )then exit;
      if(cf(@aw_tarf,@wtr_nadv    )=false)and(tu^.buff[ub_advanced]<=0   )then exit;


      if(not tu^.uid^._ukbuilding )then
      begin
      if(cf(@aw_tarf,@wtr_light   )=false)and    (tu^.uid^._uklight      )then exit;
      if(cf(@aw_tarf,@wtr_nlight  )=false)and not(tu^.uid^._uklight      )then exit;
      end
      else
      begin
      if(cf(@aw_tarf,@wtr_stun    )=false)and((tu^.buff[ub_pain]> 0)
                                            or(tu^.buff[ub_stun]> 0)     )then exit;
      if(cf(@aw_tarf,@wtr_nostun  )=false)and((tu^.buff[ub_pain]<=0)
                                           and(tu^.buff[ub_stun]<=0)     )then exit;
      end;

      // Distance requirements
      if(aw_max_range=0) // = srange
      then awr:=ud-srange
      else
        if(aw_max_range<0) // melee
        then awr:=ud-(_r+tu^.uid^._r-aw_max_range)  // need inapc check
        else
          if(aw_max_range>=aw_fsr0)  // relative srange
          then awr:=ud-(srange+(aw_max_range-aw_fsr))
          else awr:=ud-aw_max_range; // absolute

      canmove:=(speed>0)and(uo_id<>ua_hold)and(au=nil);

      if(awr<0)then
      begin
         if(ud>=aw_min_range)
         then _target_weapon_check:=3    // can attack now
         else
           if(canmove)
           then _target_weapon_check:=2  // need move farther
           else ;                        // target too close & cant move
      end
      else
        if(canmove)then
         if(ud<=srange)or(nosrangecheck)
         then _target_weapon_check:=1   // need move closer
         else ;                         // target too far & cant move
   end;
end;

function _unit_target2weapon(pu,tu:PTUnit;ud:integer;cw:byte;action:pbyte):byte;
var i,a:byte;
begin
   _unit_target2weapon:=255;

   // pu - attacker
   // tu - target

   if(_uvision(pu^.player^.team,tu,false)=false)then exit;
   if(tu^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=dist(pu^.x,pu^.y,tu^.x,tu^.y);
   if(cw>MaxUnitWeapons)then cw:=MaxUnitWeapons;
   if(action<>nil)then action^:=0;

   for i:=0 to cw do
   begin
      a:=_target_weapon_check(pu,tu,ud,i,false,action<>nil);
      if(a=0)then continue;
      if(action<>nil)then action^:=a;
      _unit_target2weapon:=i;
      break;
   end;
end;

//aw_tarprior

function _unitWeaponPriority(tu:PTUnit;priorset:byte):integer;
var i:integer;
procedure incPrio;
begin
   _unitWeaponPriority+=i;
   i:=i div 2;
end;
begin
   i:=1024;
   _unitWeaponPriority:=0;
   with tu^  do
   with uid^ do
   case priorset of
wtp_building         : if(    _ukbuilding  )then incPrio;
wtp_building_nlight  : begin
                       if(    _ukbuilding  )then incPrio;
                       if(not _uklight     )then incPrio;
                       end;
wtp_unit_light_bio   : begin
                       if(not _ukbuilding  )then incPrio;
                       if(    _uklight     )then incPrio;
                       if(not _ukmech      )then incPrio;
                       end;
wtp_unit_bio_light   : begin
                       if(not _ukbuilding  )then incPrio;
                       if(not _ukmech      )then incPrio;
                       if(    _uklight     )then incPrio;
                       end;
wtp_unit_bio_nlight  : begin
                       if(not _ukbuilding  )then incPrio;
                       if(not _ukmech      )then incPrio;
                       if(not _uklight     )then incPrio;
                       end;
wtp_unit_bio_nostun  : begin
                       if(not _ukbuilding  )then incPrio;
                       if(not _ukmech      )then incPrio;
                       if (buff[ub_stun]<=0)
                       and(buff[ub_pain]<=0)then incPrio;
                       end;
wtp_unit_mech_nostun : begin
                       if(not _ukbuilding  )then incPrio;
                       if(    _ukmech      )then incPrio;
                       if (buff[ub_stun]<=0)
                       and(buff[ub_pain]<=0)then incPrio;
                       end;
wtp_unit_mech        : begin
                       if(not _ukbuilding  )then incPrio;
                       if(    _ukmech      )then incPrio;
                       end;
wtp_bio              : if(not _ukmech      )then incPrio;
wtp_light            : if(    _uklight     )then incPrio;
wtp_unit_light       : begin
                       if(not _ukbuilding  )then incPrio;
                       if(    _uklight     )then incPrio;
                       end;
wtp_scout            : if(bld)and(hits>0)and(not _ukbuilding)then
                       if(not _IsUnitRange(inapc,nil))then
                       begin
                          if(apcm=0   )then incPrio;
                          if(speed>0)
                         and(apcc=apcm)then incPrio;
                          if(ukfly    )then incPrio;
                       end;
   end;
end;

procedure _unit_target(pu,tu:PTUnit;ud:integer;a_tard:pinteger;t_weap:pbyte;a_tarp:PPTUnit;t_prio:pinteger);
var tw:byte;
n_prio:integer;
begin
   with pu^ do
   with uid^ do
   begin
      tw:=_unit_target2weapon(pu,tu,ud,t_weap^,nil);

      if(tw>MaxUnitWeapons)then exit;

      if(tw>t_weap^)
      then exit
      else
       with _a_weap[tw] do
        if(tw<t_weap^)
        then n_prio:=_unitWeaponPriority(tu,aw_tarprior)
        else
        begin
           n_prio:=_unitWeaponPriority(tu,aw_tarprior);
           if(n_prio>t_prio^)then ;
           if(n_prio=t_prio^)then
           case aw_tarprior of
wtp_distance         : if(ud>a_tard^)then exit;
wtp_rmhits           : if(tu^.uid^._mhits<a_tarp^^.uid^._mhits)then exit;
           else
              if(aw_max_range<0)and(aw_type=wpt_directdmg)
              then begin if(ud>a_tard^)then exit; end
              else if(tu^.hits>a_tarp^^.hits)then exit;  // default
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

procedure _unit_aura_effects(pu,tu:PTUnit;ud:integer);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      case uidi of
UID_HKeep: if(ud<srange)and(team<>tu^.player^.team)and(upgr[upgr_hell_paina]>0)then _unit_damage(tu,upgr[upgr_hell_paina],upgr[upgr_hell_paina],playeri);
      end;
   end;
end;


procedure _unit_capture_point(pu:PTUnit);
var i :byte;
begin
  if(g_mode=gm_KotH)
  or(g_mode=gm_ecapture)
  or(g_mode=gm_capture)then
   with pu^ do
    for i:=1 to MaxCPoints do
     with g_cpoints[i] do
      if(cpcapturer>0)then
       if(dist(x,y,cpx,cpy)<=cpcapturer)then
       begin
          cpunitsp[playeri     ]+=uid^._limituse;
          cpunitst[player^.team]+=uid^._limituse;
       end;
end;


procedure _unit_mcycle(pu:PTUnit);
var uc,
t_prio,
a_tard,
uontar,
uontard,
    ud : integer;
    uds: single;
a_tarp,
    puo,
    tu : PTUnit;
tu_inapc,
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
      a_tard  := 32000;
      a_tarp  := nil;
      t_weap  := 255;
      t_prio  := 0;
      uontar  := 0;
      uontard := 32000;

      if(g_mode=gm_royale)then
       if((dist(x,y,map_hmw,map_hmw)+_missile_r)>=g_royal_r)then
       begin
          _unit_kill(pu,false,false,true);
          exit;
       end;

      if(_ukbuilding)and(menergy<=0)then
      begin
         _unit_kill(pu,false,false,true);
         exit;
      end;

      uo_vision:=false;

      pushout      := solid and _canmove(pu) and (a_rld<=0) and bld;
      attack_target:= _canattack(pu,false);
      aicode       := (state=ps_comp);//and(sel);
      fteleport_tar:= ((uo_tar<1)or(MaxUnits<uo_tar)) and (_ability=uab_teleport);
      swtarget     := false;
      puo:=nil;
      if(_IsUnitRange(uo_tar,@puo))and(aicode=false)then
       if(puo^.player=player)and(puo^.hits>0)and(puo^.rld>0)then
        case _uids[puo^.uidi]._ability of
uab_teleport,
uab_uac__unit_adv : swtarget:=true;
        end;

      if(aicode)then
      begin
         ai_clear_vars(pu);
         ai_collect_data(pu,pu,0);
      end;

      if(attack_target)then _unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=_punits[uc];

         if(tu^.hits>fdead_hits)then
         begin
            uds:=distr(x,y,tu^.x,tu^.y);
            ud :=round(uds);

            tu_inapc:=(0<tu^.inapc)and(tu^.inapc<=MaxUnits);

            if(not tu_inapc)then _unit_detect(pu,tu,ud);

            if(attack_target)then _unit_target(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio);

            if(aicode)then ai_collect_data(pu,tu,ud);

            if(tu^.hits>0)then
            begin
               if(tu_inapc)then continue;

               _unit_aura_effects(pu,tu,ud);

               if(pushout)then
                if(_r<=tu^.uid^._r)or(tu^.speed<=0)or(not tu^.bld)then
                 if(tu^.solid)and(ukfly=tu^.ukfly)then _unit_push(pu,tu,uds);

               if(swtarget)then
                if(ud<srange)and(tu^.playeri=playeri)and(tu^.uidi=puo^.uidi)and(tu^.rld<puo^.rld)then
                 if((0<tu^.uo_tar)and(tu^.uo_tar<=MaxUnits)and(tu^.uo_tar=puo^.uo_tar))
                 or((tu^.uo_x=puo^.uo_x)and(tu^.uo_y=puo^.uo_y))
                 then uo_tar:=tu^.unum;

               if(fteleport_tar)then
               begin
                  ud:=dist(uo_x,uo_y,tu^.x,tu^.y);
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

      _unit_npush_dcell(pu);

      if(fteleport_tar)and(uontar>0)then uo_tar:=uontar;

      if(aicode)then ai_code(pu);

      {$IFDEF _FULLGAME}
      //if(playeri=HPlayer)and(alrm_r<srange)and(alrm_b=false)then ui_addalrm(mmx,mmy,_isbuilding);
      {$ENDIF}
   end;
end;

procedure _unit_mcycle_cl(pu,au:PTUnit);
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
      if(ServerSide)then
      begin
         a_tar  :=0;
         a_tard :=32000;
         t_weap :=255;
         a_tarp :=nil;
         t_prio :=0;
         ftarget:=_canattack(pu,false);
      end
      else ftarget:=false;

      if(au<>nil)then
      begin
         if(_IsUnitRange(au^.inapc,nil))then exit;
         vsnt   :=au^.vsnt;
         udetect:=false;
      end
      else udetect:=true;

      if(udetect=false)and(ftarget=false)then exit;  // in apc & client side

      if(ftarget)and(ServerSide)then _unit_target(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=_punits[uc];
         if(tu^.hits>fdead_hits)then
         begin
            ud:=dist2(x,y,tu^.x,tu^.y);
            if(udetect)then _unit_detect(pu,tu,ud);
            if(ftarget)then _unit_target(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio);
         end;
      end;

      {$IFDEF _FULLGAME}
      //if(playeri=HPlayer)and(alrm_r<srange)and(alrm_b=false)then ui_addalrm(mmx,mmy,_isbuilding);
      {$ENDIF}
   end;
end;

procedure _unit_uac_unit_adv(pu,tu:PTUnit);
begin
   // pu - target
   // tu - caster
   with pu^  do
   with uid^ do
   begin
      if(tu^.buff[ub_advanced]>0)
      then buff[ub_stun]:=_tprod div 4
      else buff[ub_stun]:=_tprod div 2;
      //gear_time[_ukmech];

      buff[ub_advanced]:=_ub_infinity;

      {if(tu^.buff[ub_advanced]>0)
      then tu^.rld:=uac_adv_base_reload[_ukmech] div 2
      else tu^.rld:=uac_adv_base_reload[_ukmech];}
      tu^.rld:=uac_adv_base_reload;

      GameLogUnitPromoted(pu);
      {$IFDEF _FULLGAME}
      SoundPlayUnit(snd_unit_adv[_urace],pu,nil);
      {$ENDIF}
   end;
end;

procedure _unit_hell_unit_adv(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      buff[ub_advanced]:=_ub_infinity;

      GameLogUnitPromoted(pu);
      {$IFDEF _FULLGAME}
      _unit_PowerUpEff(pu,snd_unit_adv[_urace],nil);
      {$ENDIF}
   end;
end;

procedure _unit_building_start_adv(pu:PTUnit;upgr:boolean);
begin
   with pu^     do _unit_morph(pu,uidi,false,-6+(4*byte(upgr)),2);
end;

function _ability_uac__unit_adv(pu,tu:PTUnit;tdm:integer):boolean;
begin
   // pu - target
   // tu - caster
   _ability_uac__unit_adv:=false;
   with pu^  do
   with uid^ do
   if(tdm<=melee_r)and(tu^.rld<=0)and(not _ukbuilding)and(tu^.hits>0)then
   begin
      if(tu^.bld)and(_urace=tu^.uid^._urace)and(player^.team=tu^.player^.team)and(buff[ub_advanced]<=0)and(_ability<>uab_advance)and(hits>0)then
      begin
         _unit_uac_unit_adv(pu,tu);
         _ability_uac__unit_adv:=true;
      end;
      uo_x  :=tu^.uo_x;
      uo_y  :=tu^.uo_y;
      uo_tar:=tu^.uo_tar;
   end;
end;

function _ability_hell_unit_adv(pu,tu:PTUnit):boolean;
begin
   // pu - target
   // tu - caster
   _ability_hell_unit_adv:=false;
   with pu^  do
   with uid^ do
   begin
      if(not _ukbuilding)and(bld)and(_ability<>uab_advance)then
       with tu^.player^ do
        if(tu^.bld)and(tu^.hits>0)and(hits>0)and(_urace=tu^.uid^._urace)and(player^.team=tu^.player^.team)then
         if(buff[ub_advanced]<=0)and(upgr[upgr_hell_6bld]>0)then
         begin
            upgr[upgr_hell_6bld]-=1;
            _unit_hell_unit_adv(pu);
            _ability_hell_unit_adv:=true;
         end;
      _unit_clear_order(tu,false);
      _unit_clear_order(pu,false);
   end;
end;

function _ability_building_adv(pu,tu:PTUnit):boolean;
begin
   // pu - target
   // tu - caster
   _ability_building_adv:=false;
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(_ukbuilding)and(bld)and(_ability=0)then
       if(_isbarrack)or(_issmith)then
       if(tu^.uid^._ukbuilding)and(player^.team=tu^.player^.team)and(tu^.rld<=0)and(tu^.bld)and(tu^.hits>0)and(hits>0)then
        if(buff[ub_advanced]<=0)and(cenergy>=_renergy)then
        begin
           _unit_building_start_adv(pu, tu^.buff[ub_advanced]>0 );
           tu^.rld:=building_adv_reload[tu^.buff[ub_advanced]>0];
           {$IFDEF _FULLGAME}
           if(playeri=HPlayer)then
           SoundPlayUnitCommand(snd_building[_urace]);
           {$ENDIF}
           _ability_building_adv:=true;
        end;

      tu^.uo_tar:=0;
   end;
end;

function _ability_hell_vision(pu,tu:PTUnit):boolean;
begin
   // pu - target
   // tu - caster
   _ability_hell_vision:=false;
   with tu^     do
   with player^ do
   begin
      if(bld)and(hits>0)and(pu^.bld)and(pu^.hits>0)and(team=pu^.player^.team)then
       if(pu^.buff[ub_hvision]<hell_vision_time)and(upgr[upgr_hell_heye]>0)then
       begin
          pu^.buff[ub_hvision]:=hell_vision_time*upgr[upgr_hell_heye];
          rld:=heyenest_reload;
          {$IFDEF _FULLGAME}
          _unit_HvisionEff(pu,nil);
          {$ENDIF}
       end;

      uo_tar:=0;
      _ability_hell_vision:=true;
   end;
end;

function _ability_teleport(pu,tu:PTUnit;td:integer):boolean;
var tt:PTUnit;
    tr:integer;
begin
   // pu - target
   // tu - teleporter
   _ability_teleport:=false;
   with pu^  do
   with uid^ do
      if(not _ukbuilding)and(ukfly=false)and(tu^.hits>0)and(tu^.bld)then
       if(player^.team=tu^.player^.team)and(buff[ub_teleeff]<=0)then
        if(td<=melee_r)then
        begin
           if(tu^.rld<=0)then
           begin
              if(not _IsUnitRange(tu^.uo_tar,@tt))then exit;
              if(tu^.player^.team<>tt^.player^.team)then exit;
              if(tt^.hits<=0)then exit;

              tu^.uo_x:=tt^.x;
              tu^.uo_y:=tt^.y;

              if(ukfly=uf_ground)then
               if(pf_isobstacle_zone(tu^.pfzone))then exit;

              tr:=_r+tt^.uid^._r;

              if(ukfly=tt^.ukfly)
              then _unit_teleport(pu,tu^.uo_x+(tr*sign(x-tu^.uo_x)),tu^.uo_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF})
              else _unit_teleport(pu,tu^.uo_x,tu^.uo_y                      {$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});

              _teleport_rld(tu,_mhits);
              _ability_teleport:=true;
           end;
        end
        else
          if(tu^.buff[ub_advanced]>0)and(td>base_r)then
           if(tu^.rld<=0)then
           begin
              _unit_teleport(pu,tu^.x,tu^.y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
              _teleport_rld(tu,_mhits);
              uo_x  :=x;
              uo_y  :=y;
              uo_tar:=0;
              _ability_teleport:=true;
           end
           else
           begin
              uo_x  :=x;
              uo_y  :=y;
              _ability_teleport:=true;
           end;
end;

function _unit_load(pu,tu:PTUnit):boolean;
begin
   //pu - transport
   //tu - target
   _unit_load:=false;
   if(_itcanapc(pu,tu))then
   with pu^ do
   begin
      apcc+=tu^.uid^._apcs;
      tu^.inapc:=unum;
      tu^.a_tar:=0;
      if(uo_tar=tu^.unum)then     uo_tar:=0;
      if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
      _unit_desel(tu);
      {$IFDEF _FULLGAME}
      SoundPlayUnit(snd_inapc,pu,nil);
      {$ENDIF}
      _unit_load:=true;
   end;
end;
function _unit_unload(pu,tu:PTUnit):boolean;
begin
   //pu - transport
   //tu - target
   _unit_unload:=false;
   if(pu=nil)then
    if(not _IsUnitRange(tu^.inapc,@pu))then exit;
   with tu^ do
    if(inapc=pu^.unum)and(pu^.buff[ub_clcast]<=0)then
    begin
       pu^.buff[ub_clcast]:=fr_4hfps;
       pu^.apcc-=uid^._apcs;
       inapc:=0;
       x    :=pu^.x-_randomr(pu^.uid^._r);
       y    :=pu^.y-_randomr(pu^.uid^._r);
       uo_x :=x;
       uo_y :=y;
       {$IFDEF _FULLGAME}
       SoundPlayUnit(snd_inapc,pu,nil);
       {$ENDIF}
       _unit_unload:=true;
    end;
   with pu^ do
    if(apcc=0)then uo_id:=ua_amove;
end;

procedure _unit_inapc_target(pu,au:PTUnit);
var tu:PTUnit;
begin
   // pu - unit inside
   // au - apc
   with pu^ do
   begin
      x  :=au^.x;
      y  :=au^.y;
      {$IFDEF _FULLGAME}
      fx :=au^.fx;
      fy :=au^.fy;
      mmx:=au^.mmx;
      mmy:=au^.mmy;
      {$ENDIF}

      if(ServerSide)then
      begin
         if(au^.uo_id=ua_unload)or(au^.apcc>au^.apcm)then
          if(not au^.ukfly)or(not pf_isobstacle_zone(au^.pfzone))then
           if(_unit_unload(au,pu))then exit;

         if(au^.uo_id in [ua_move,ua_hold,ua_amove])then uo_id:=au^.uo_id;
         if(_IsUnitRange(au^.uo_tar,@tu))then
         begin
            a_tar:=au^.uo_tar;
            if(_unit_target2weapon(pu,tu,-1,255,nil)<=MaxUnitWeapons)then uo_id:=ua_amove;
         end;
      end;
   end;
end;

function _unit_action(pu:PTUnit):boolean;
begin
   _unit_action:=false;
   with pu^ do
    if(_IsUnitRange(inapc,nil)=false)then
     with uid^ do
      if(apcc>0)then
      begin
         uo_id:=ua_unload;
         _unit_action:=true;
      end
      else
       if(_canability(pu))then
        with player^ do
         case _ability of
uab_spawnlost     : if(buff[ub_cast]<=0)and(buff[ub_clcast]<=0)then
                    begin
                       buff[ub_cast  ]:=fr_2hfps;
                       buff[ub_clcast]:=fr_2fps;
                       _ability_unit_spawn(pu,UID_LostSoul);
                       _unit_action:=true;
                    end;
uab_advance       : if(zfall=0)then
                    begin
                        if(buff[ub_advanced]>0)
                        then buff[ub_advanced]:=0
                        else buff[ub_advanced]:=_ub_infinity;
                       _unit_action:=true;
                    end;
uab_rebuild       : case uidi of
                    UID_UGTurret   : _unit_action:=not PlayerSetProdError(playeri,glcp_unit,UID_UATurret   ,_unit_morph(pu,UID_UATurret   ,false,-2,1),pu);
                    UID_UATurret   : _unit_action:=not PlayerSetProdError(playeri,glcp_unit,UID_UGTurret   ,_unit_morph(pu,UID_UGTurret   ,false,-2,1),pu);
                    UID_HSymbol    : _unit_action:=not PlayerSetProdError(playeri,glcp_unit,UID_HASymbol   ,_unit_morph(pu,UID_HASymbol   ,false,-4,1),pu);
                    UID_UGenerator : _unit_action:=not PlayerSetProdError(playeri,glcp_unit,UID_UAGenerator,_unit_morph(pu,UID_UAGenerator,false,-2,1),pu);
                    end;
uab_buildturret   : if(buff[ub_advanced]>0)then _unit_action:=not PlayerSetProdError(playeri,glcp_unit,UID_UGTurret,_unit_morph(pu,UID_UGTurret,false,-2,0),pu);
         else
            if(buff[ub_advanced]<=0)then
             if(_isbarrack)or(_issmith)then
              if(uid_x[uid_race_9bld[race]]>0)then _unit_action:=_ability_building_adv(pu,@_units[uid_x[uid_race_9bld[race]]]);
         end;
end;

// target units
procedure _unit_uo_tar(pu:PTUnit);
var tu: PTUnit;
     w: byte;
td,tdm: integer;
function StayAtTarget:boolean;
begin
   StayAtTarget:=true;
   if(tdm<=melee_r)then exit;
   StayAtTarget:=false;
end;
begin
   with pu^  do
   with uid^ do
   begin
      if(uo_tar=unum)then uo_tar:=0;
      if(_IsUnitRange(uo_tar,@tu))then
      begin
         if(_IsUnitRange(tu^.inapc,nil))
         or(_uvision(player^.team,tu,false)=false)then
         begin
            uo_tar:=0;
            exit;
         end;

         td :=dist(x,y,tu^.x,tu^.y);
         if(tu^.solid)
         then tdm:=td-(_r+tu^.uid^._r)
         else tdm:=td- _r;

         if(tdm<melee_r)then
         begin
            if(_unit_load(pu,tu))then exit;
            if(_unit_load(tu,pu))then exit;
         end;

         case _ability of
uab_teleport     : if(tu^.player^.team<>player^.team   )then begin uo_tar:=0;exit; end;
uab_hell_unit_adv: if(_ability_hell_unit_adv(tu,pu    ))then exit;//team, race=race
uab_building_adv : if(_ability_building_adv (tu,pu    ))then exit;//team
uab_hell_vision  : if(_ability_hell_vision  (tu,pu    ))then exit;//team
         end;

         case tu^.uid^._ability of
uab_uac__unit_adv: if(_ability_uac__unit_adv(pu,tu,tdm))then exit;//team, race=race
uab_hell_unit_adv: if(_ability_hell_unit_adv(pu,tu    ))then exit;//team
uab_teleport     : if(_ability_teleport     (pu,tu,tdm))then exit;//team
         end;

         w:=_unit_target2weapon(pu,tu,td,255,nil);
         if(w<=MaxUnitWeapons)then
         begin
            a_tar :=uo_tar;
            uo_id :=ua_amove;
         end;

         if(StayAtTarget)then
         begin
            uo_x:=x;
            uo_y:=y;
            exit;
         end;

         if(player=tu^.player)and(tu^.ukfly)then
          if(_itcanapc(tu,pu))and(not _IsUnitRange(tu^.uo_tar,nil))then
          begin
             tu^.uo_x:=x;
             tu^.uo_y:=y;
          end;

         uo_x:=tu^.vx;
         uo_y:=tu^.vy;
      end;
   end;
end;

procedure _resurrect(tu:PTUnit);
begin
   with tu^ do
   begin
      buff[ub_resur]:=fr_2fps;
      zfall:=-uid^._zfall;
      ukfly:= uid^._ukfly;
   end;
end;

function _makezimba(pu,tu:PTUnit):boolean;
var _h:single;
    _o:byte;
    _f:boolean;
    _d,
    _z,
    _a:integer;
 _zuid:PTUID;
    {$IFDEF _FULLGAME}
    _s:integer;
    {$ENDIF}
begin
   _makezimba:=false;

   if(tu^.uid^._zombie_uid=0)then exit;
   _zuid:=@_uids[tu^.uid^._zombie_uid];

   with pu^ do
   with uid^ do
   with player^ do
   begin
      if((armylimit-_limituse+_zuid^._limituse)>MaxPlayerLimit)then exit;
      if(_zuid^._ukbuilding)then
       if((menergy-_genergy+_zuid^._genergy)<=0)then exit;
   end;

   _h:=tu^.hits/tu^.uid^._mhits;
   _d:=tu^.dir;
   _o:=pu^.order;
   _a:=tu^.buff[ub_advanced];
   _f:=tu^.ukfly;
   _z:=tu^.zfall;
   {$IFDEF _FULLGAME}
   _s:=tu^.shadow;
   {$ENDIF}
   _unit_kill(pu,true,true,false);

   _unit_add(tu^.x,tu^.y,tu^.uid^._zombie_uid,pu^.playeri,true,true,_a>0);
   if(_LastCreatedUnit>0)then
   with _LastCreatedUnitP^ do   // визуальные проблемы когда захватывается летающий СС
   begin
      order:=_o;
      dir  :=_d;
      ukfly:=_f;
      hits := trunc(uid^._mhits*_h);
      zfall:=_z;
      buff[ub_advanced]:=_a;
      {$IFDEF _FULLGAME}
      shadow:=_s;
      {$ENDIF}
      if(hits<=0)then
      begin
         _unit_dec_Kcntrs(_LastCreatedUnitP);
         _resurrect(_LastCreatedUnitP);
      end;{
      else
      begin
         buff[ub_summoned]:=fr_fps;
         //_unit_summon_effects(pu,nil);
      end;}
   end;

   _unit_kill(tu,true,true,false);
   _makezimba:=true;
end;

procedure _unit_attack(pu:PTUnit);
var w,a   : byte;
     tu   : PTUnit;
upgradd,c : integer;
attackinmove: boolean;
{$IFDEF _FULLGAME}
attackervis,
targetvis: boolean;
{$ENDIF}
begin
   with pu^ do
   begin
      if(_IsUnitRange(a_tar,@tu)=false)then exit;

      if(ServerSide)then
      begin
         if(a_rld<=0)then
         begin
            w:=_unit_target2weapon(pu,tu,-1,255,@a);

            if(w>MaxUnitWeapons)or(a=0)then
            begin
               if(ServerSide)then a_tar:=0;
               exit;
            end;

            a_weap:=w;
         end
         else
         begin
            a:=_target_weapon_check(pu,tu,-1,a_weap,true,false);
            if(a=0)then
            begin
               if(ServerSide)then a_tar:=0;
               exit;
            end;
         end;

         upgradd:=0;

         with uid^ do
          with _a_weap[a_weap] do
           attackinmove:=cf(@aw_reqf,@wpr_move);

         case a of
         0: exit;
         1: begin
               mv_x:=tu^.x;
               mv_y:=tu^.y;
               exit;
            end;
         2: begin
               if(not attackinmove)or(uo_bx<=0)then
                if(x=tu^.x)and(y=tu^.y)then
                begin
                   mv_x:=x-_random(2);
                   mv_y:=y-_random(2);
                end
                else
                begin
                   mv_x:=x-(tu^.x-x);
                   mv_y:=y-(tu^.y-y);
                end;
               exit;
            end;
         3:
            if(not attackinmove)then
            begin
               mv_x:=x;
               mv_y:=y;
            end;
         else exit;
         end;
      end
      else
      begin
         if(a_weap>MaxUnitWeapons)then exit;

         with uid^ do
          with _a_weap[a_weap] do
           attackinmove:=cf(@aw_reqf,@wpr_move);
      end;

      if(not _canattack(pu,true))then
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
         targetvis  :=PointInScreenP(tu^.vx,tu^.vy,tu^.player);
         attackervis:=PointInScreenP(    vx,    vy,    player);
         {$ENDIF}

         if(a_rld<=0)then
         begin
            a_rld    :=aw_rld;
            a_tar_cl :=a_tar;
            a_weap_cl:=a_weap;
            if(not attackinmove)then
             if(x<>tu^.x)
             or(y<>tu^.y)then dir:=p_dir(x,y,tu^.x,tu^.y);
            {$IFDEF _FULLGAME}
            _unit_attack_effects(pu,true,@attackervis);
            {$ENDIF}
         end;

         if(cycle_order=_cycle_order)then
         begin
            if(cf(@aw_reqf,@wpr_tvis))then _AddToInt(@tu^.vsnt[player^.team],vistime);
            _AddToInt(@vsnt[tu^.player^.team],vistime);
         end;

         {$IFDEF _FULLGAME}
         if(targetvis)then
          if(aw_eid_target>0)and(aw_eid_target_onlyshot=false)then
          begin
             if(not _IsUnitRange(tu^.inapc,nil))then
              if((G_Step mod fr_3hfps)=0)then _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.ukfly),aw_eid_target);
             if(aw_snd_target<>nil)then
              if((G_Step mod fr_fps)=0)then SoundPlayUnit(aw_snd_target,tu,@targetvis);
          end;
         {$ENDIF}

         if(a_rld in aw_rld_s)then
         begin
            {$IFDEF _FULLGAME}
            _unit_attack_effects(pu,false,@attackervis);
            if(targetvis)then
             if(aw_eid_target>0)and(aw_eid_target_onlyshot)then
             begin
                if(not _IsUnitRange(tu^.inapc,nil))then
                _effect_add(tu^.vx-_randomr(tu^.uid^._missile_r),tu^.vy-_randomr(tu^.uid^._missile_r),_depth(tu^.vy+1,tu^.ukfly),aw_eid_target);

                SoundPlayUnit(aw_snd_target,tu,@targetvis);
             end;
            {$ENDIF}
            if(aw_dupgr>0)and(aw_dupgr_s>0)then upgradd:=player^.upgr[aw_dupgr]*aw_dupgr_s;
            if(not attackinmove)then
             if(x<>tu^.x)
             or(y<>tu^.y)then dir:=p_dir(x,y,tu^.x,tu^.y);
            case aw_type of
wpt_missle     : if(cf(@aw_reqf,@wpr_sspos))
                 then _missile_add(vx,vy,vx,vy,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,upgradd)
                 else
                   if(aw_count=0)
                   then _missile_add(tu^.x,tu^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,upgradd)
                   else
                     if(aw_count>0)
                     then for c:=1 to aw_count do _missile_add(tu^.x,tu^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,upgradd)
                     else
                       if(aw_count<0)then
                       begin
                          _missile_add(tu^.x,tu^.y,vx-aw_count+aw_x,vy-aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,upgradd);
                          _missile_add(tu^.x,tu^.y,vx+aw_count+aw_x,vy+aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,tu^.ukfly,upgradd);
                       end;
wpt_unit       : _ability_unit_spawn(pu,aw_oid);
            else
               if(ServerSide)then
                case aw_type of
wpt_resurect : _resurrect(tu);
wpt_heal     : begin
                  tu^.hits:=mm3(1,tu^.hits+aw_count+upgradd,tu^.uid^._mhits);
                  tu^.buff[ub_heal]:=aw_rld;
               end;
wpt_directdmg: if(not cf(@aw_reqf,@wpr_zombie))
               then _unit_damage(tu,_unit_melee_damage(pu,tu,aw_count+upgradd),2,playeri)
               else
                 if(not _makezimba(pu,tu))
                 then _unit_damage(tu,_unit_melee_damage(pu,tu,aw_count+upgradd),2,playeri);
               end;
            end;

            if(ServerSide)then
             if(cf(@aw_reqf,@wpr_suicide))then _unit_kill(pu,false,true,true);
         end;
      end;
   end;
end;

procedure _unit_order(pu:PTUnit);
var apctu:PTUnit;
begin
   with pu^ do
    if(hits<=0)then exit;

   apctu:=nil;
   if(_IsUnitRange(pu^.inapc,@apctu))then _unit_inapc_target(pu,apctu);

   with pu^ do
   if(ServerSide=false)
   then _unit_attack(pu)
   else
   begin
      if(apctu=nil)then
      begin
         _unit_uo_tar(pu);

         mv_x:=uo_x;
         mv_y:=uo_y;

         if(uo_id=ua_paction)then
          case uid^._ability of
uab_spawnlost:  begin
                   mv_x:=x;
                   mv_y:=y;
                   uo_id:=ua_amove;
                   _unit_action(pu);
                   uo_id:=ua_paction;
                end
          else
             if(speed<=0)
             then uo_id:=ua_amove
             else
               if(x=uo_x)and(y=uo_y)then
               begin
                  uo_id:=ua_amove;
                  _unit_action(pu);
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

      if(uo_id=ua_amove)then _unit_attack(pu);

      if(apctu=nil)then
       if(_canmove(pu)=false)then
       begin
          mv_x:=x;
          mv_y:=y;
       end
       else
         if(mp_x<>mv_x)or(mp_y<>mv_y)then
         begin
            if(uid^._slowturn=false)then
             if(x<>mv_x)or(y<>mv_y)then dir:=p_dir(x,y,mv_x,mv_y);
            mp_x:=mv_x;
            mp_y:=mv_y;
         end;
   end;
end;

function _unit_player_order(pu:PTUnit;order_id,order_tar,order_x,order_y:integer):boolean;
begin
   _unit_player_order:=false;
   with pu^     do
   with uid^    do
   with player^ do
   case order_id of
co_destroy :  _unit_kill(pu,false,order_tar>0,true);
co_rcamove,
co_rcmove  :  begin     // right click
                 case _ability of
           uab_uac_rstrike : if(_unit_ability_umstrike(pu,order_x,order_y))then exit;
           uab_radar       : if(_unit_ability_uradar  (pu,order_x,order_y))then exit;
           uab_hinvuln     : if(_unit_ability_hinvuln (pu,order_tar      ))then exit;
           uab_htowertele  : if(order_tar<>unum)and(_IsUnitRange(order_tar,nil))and(_attack>atm_none)
                             then uo_tar:=order_tar
                             else if(_unit_ability_htteleport(pu,order_x,order_y))then exit;
           uab_hkeeptele   : if(_unit_ability_hkteleport(pu,order_x,order_y))then exit;
           uab_hell_unit_adv,
           uab_building_adv: uo_tar:=order_tar;
                 else
                    uo_tar:=0;
                    uo_x  :=order_x;
                    uo_y  :=order_y;
                    uo_bx :=-1;

                    if(order_tar<>unum)then uo_tar:=order_tar;
                    if(order_id<>co_rcmove)or(speed<=0)
                    then uo_id:=ua_amove
                    else uo_id:=ua_move;
                 end;
              end;
co_stand,
co_move,
co_patrol,
co_astand,
co_amove,
co_apatrol :  if(speed>0)then   // attack, move, patrol, stand, hold
              begin
                 case order_id of
           co_stand,
           co_astand:  begin
                          uo_x  :=x;
                          uo_y  :=y;
                          uo_bx :=-1;
                          uo_tar:=0;
                          a_tar :=0;
                       end;
           co_move,
           co_patrol,
           co_amove,
           co_apatrol: begin
                          uo_x  :=order_x;
                          uo_y  :=order_y;
                          uo_bx :=-1;
                          uo_tar:=0;
                          case order_id of
                      co_patrol,
                      co_apatrol: begin   // patrol
                                     uo_bx:=x;
                                     uo_by:=y;
                                  end;
                          end;
                       end;
                 end;
                 case order_id of
           co_stand  : begin
                          uo_id :=ua_hold;
                          a_tar :=0;
                       end;
           co_move,
           co_patrol : begin
                          uo_id :=ua_move;
                          a_tar :=0;
                       end;
           co_astand,
           co_amove,
           co_apatrol: uo_id:=ua_amove;
                 end;
              end;
co_paction :  if(uo_id<>ua_paction)or((ucl_cs[true]+ucl_cs[false])=1)then
              begin
                 uo_x  :=order_x;
                 uo_y  :=order_y;
                 uo_bx :=-1;
                 a_tar :=0;
                 uo_tar:=0;
                 if((_ability=0)and(apcc<=0))or(speed<=0)
                 then uo_id:=ua_amove
                 else
                 begin
                    case uidi of
                    UID_HCommandCenter,
                    UID_UCommandCenter: begin
                                           _push_out(uo_x,uo_y,_r,@uo_x,@uo_y,false, (upgr[upgr_uac_ccldoodads]<=0)and(upgr[upgr_hell_hktdoodads]<=0) );
                                           uo_y-=fly_hz;
                                        end;
                    end;
                    uo_id:=ua_paction;
                 end;
                 exit;
              end;
co_action  :  _unit_action(pu);
co_supgrade:  if(0<=order_tar)and(order_tar<=255)then _unit_supgrade (pu,order_tar);
co_cupgrade:  if(0<=order_tar)and(order_tar<=255)then _unit_cupgrade (pu,order_tar);
co_suprod  :  if(0<=order_tar)and(order_tar<=255)then _unit_straining(pu,order_tar);
co_cuprod  :  if(0<=order_tar)and(order_tar<=255)then _unit_ctraining(pu,order_tar);
co_pcancle :  begin
                 _unit_ctraining(pu,255);
                 _unit_cupgrade (pu,255);
              end;
   end;
   _unit_player_order:=true;
end;

procedure _unit_prod(pu:PTUnit);
var i:integer;
procedure _uXCheck(pui:pinteger);
var tu:PTUnit;
begin
   if(not _IsUnitRange(pui^,@tu))
   then pui^:=pu^.unum
   else
    if(tu^.rld>pu^.rld)
    then pui^:=pu^.unum;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   if(bld)and(hits>0)then
   begin
      _unit_end_uprod(pu);
      _unit_end_pprod(pu);

      _uXCheck(@uid_x[            uidi]);
      _uXCheck(@ucl_x[_ukbuilding,_ucl]);

      // REGENERATION
      if(cycle_order=_cycle_regen)then
      if(buff[ub_damaged]<=0)then
      begin
         i:=_baseregen;
         if(i>=0)then
          if(_ukbuilding)
          then i+=upgr[upgr_race_build_regen[_urace]]
          else
            if(_ukmech)
            then i+=upgr[upgr_race_mech_regen[_urace]]
            else i+=upgr[upgr_race_bio_regen [_urace]];

         if(i>0)then
         begin
            hits+=i;
            if(hits>_mhits)then hits:=_mhits;
         end;
      end;
   end
   else
     if(cenergy<0)
     then _unit_kill(pu,false,false,true)
     else
     begin
        if(_cycle_order=cycle_order)and(buff[ub_damaged]<=0)then
        begin
           hits+=_bstep;
           hits+=_bstep*upgr[upgr_fast_build];
        end;

        if(hits>=_mhits){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
        begin
           hits:=_mhits;
           bld :=true;
           _unit_bld_inc_cntrs(pu);
           cenergy+=_renergy;
           GameLogUnitReady(pu);
        end;
     end;
end;

procedure _unit_reveal(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   with player^ do
   begin
      _AddToInt(@vsnt[team],vistime);
      _AddToInt(@vsni[team],vistime);
      if(ServerSide)and(cycle_order=_cycle_order)then
       if{$IFDEF _FULLGAME}(menu_s2<>ms2_camp)and{$ENDIF}(n_builders=0)then
        for i:=0 to MaxPlayers do
        begin
           _AddToInt(@vsnt[i],fr_fps);
           if(g_mode<>gm_invasion)or(playeri>0)then _AddToInt(@vsni[i],fr_fps);
        end;
   end;
end;

procedure _obj_cycle();
var u : integer;
    pu,
    au: PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=_punits[u];
      with pu^ do
      if(hits>dead_hits)then
      begin
         _unit_reveal  (pu);
         _unit_counters(pu);

         if(hits>0)then
         begin
            _unit_upgr (pu);
            _unit_order(pu);

            if(ServerSide)then
            begin
               _unit_move(pu);
               _unit_prod(pu);
               if(player^.state=ps_comp)then ai_scout_pick(pu);
            end;

            au:=nil;
            if(cycle_order=_cycle_order)and(hits>0)then
             if(ServerSide)and(not _IsUnitRange(inapc,@au))
             then _unit_mcycle   (pu)
             else _unit_mcycle_cl(pu,au);
         end
         else _unit_death(pu);

         _unit_movevis(pu);
         _unit_capture_point(pu);
      end;
   end;

   _missileCycle;
end;

////////////////////////////////////////////////////////////////////////////////




