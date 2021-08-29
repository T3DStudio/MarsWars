

function _unit_OnDecorCheck(ux,uy:integer):boolean;
const dr = 64;
var i,dx,dy,ud,dp:integer;
begin
   dx:=ux div dcw;
   dy:=uy div dcw;
   _unit_OnDecorCheck:=false;
   dp:=0;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
   with map_dcell[dx,dy] do
    for i:=1 to n do
     with l[i-1]^ do
      if(r>0)and(t>0)then
      begin
         ud:=(dist2(x,y,ux,uy)-r);
         if(ud<0)then dp+=1;
         ud+=dr;
         if(ud<0)or(dp>1)then
         begin
            _unit_OnDecorCheck:=true;
            exit;
         end;
      end;
end;

procedure _unit_remove(pu:PTUnit);
begin
   with pu^ do
    with player^ do
    begin
       _unit_dec_Rcntrs(pu);

       if(G_WTeam=255)then
        if(playeri>0)or not(g_mode in [gm_inv,gm_aslt])then
         if(army=0){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
         and(state>ps_none)then net_chat_add(name+str_player_def,playeri,255);
    end;
end;

procedure _unit_death(pu:PTUnit);
var tu  : PTUnit;
    uc  : integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
    if(hits>dead_hits)then
    begin
       if(uclord=_uclord_c)then
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
          if(uclord=_uclord_c)and(fsr>1)then fsr-=1;
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
              buff[ub_born ]:=fr_fps;
              {$IFDEF _FULLGAME}
              _unit_fog_r(pu);
              _unit_ready_effects(pu,nil);
              {$ENDIF}
           end;
        end;
    end;
end;


procedure _check_missiles(u:integer);
var i:integer;
begin
   for i:=1 to MaxUnits do
    with _missiles[i] do
     if(vst>0)and(tar=u)then tar:=0;
end;

procedure _unit_kill(pu:PTUnit;instant,fastdeath:boolean);
var i :integer;
    tu:PTunit;
begin
   with pu^ do
   with player^ do
   begin
      if(instant=false)then
      begin
         with uid^ do fastdeath:=fastdeath or (_fastdeath_hits[buff[ub_advanced]>0]>=0) or _ismech;
         buff[ub_pain]:=fr_fps; // prevent fast resurrecting

         {$IFDEF _FULLGAME}
         _unit_death_effects(pu,fastdeath,nil);
         {$ENDIF}
      end;

      {$IFDEF _FULLGAME}
      if(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
      {$ENDIF}

      _unit_dec_Kcntrs(pu);

      with uid^ do
      begin
         if(_isbuilding)then build_cd:=min2(build_cd+fr_3fps,max_build_reload);
         zfall:=_zfall;
      end;

      x      :=vx;
      y      :=vy;
      uo_x   :=x;
      uo_y   :=y;
      uo_bx  :=-1;
      uo_by  :=-1;
      uo_tar :=0;
      mv_x   :=x;
      mv_y   :=y;
      a_tar  :=0;
      rld    :=0;

      for i:=1 to MaxUnits do
      if(i<>unum)then
      begin
         tu:=@_units[i];
         if(tu^.hits>0)then
         begin
            if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
            if(apcc>0)then
             if(tu^.inapc=unum)then
             begin
                if(uf>uf_ground)or(inapc>0)
                then _unit_kill(tu,true,false)
                else
                begin
                   tu^.inapc:=0;
                   apcc-=tu^.uid^._apcs;
                   tu^.x+=_randomr(uid^._r);
                   tu^.y+=_randomr(uid^._r);
                   tu^.uo_x:=tu^.x;
                   tu^.uo_y:=tu^.y;
                   if(tu^.hits>apc_exp_damage)then
                   begin
                      tu^.hits-=apc_exp_damage;
                      tu^.buff[ub_invuln]:=10;
                   end
                   else _unit_kill(tu,true,false);
                end;
             end;
         end;
      end;
      _check_missiles(unum);

      if(instant)then
      begin
         hits:=ndead_hits;
         _unit_remove(pu);
      end
      else
        if(fastdeath)
        then hits:=fdead_hits
        else hits:=0;
   end;
end;

procedure _unit_damage(pu:PTUnit;dam,p:integer;pl:byte);
const build_arm_f = 16;
       unit_arm_f = 24;
var arm:integer;
begin
   if(ServerSide=false)or(dam<0)then exit;

   with pu^ do
   with uid^ do
   begin
      if(buff[ub_invuln]>0)or(hits<0)then exit;

      arm:=0;

      with player^ do
      begin
         if(_isbuilding)then
         begin
            if(bld)then
            begin
               arm:=upgr[upgr_race_build_armor[_urace]];

               case uidi of
               UID_UCTurret,
               UID_UPTurret,
               UID_URTurret: if(g_addon=false)
                             then arm+=1
                             else
                               if(upgr[upgr_uac_turarm]>0)then arm+=upgr[upgr_uac_turarm];
               end;

               if(dam>=build_arm_f)
               then arm+=(dam div build_arm_f)*arm;

               arm+=5;
            end;
         end
         else
         begin
            if(_ismech)
            then arm:=upgr[upgr_race_mech_armor[_urace]]
            else arm:=upgr[upgr_race_bio_armor [_urace]];

            if(dam>=unit_arm_f)
            then arm+=(dam div unit_arm_f)*arm;

            case uidi of
              UID_Demon     : arm+=2;
              UID_Archvile  : arm+=3;
            else
               if(uidi in armor_massive)then arm+=3;
            end;
         end;

         if(_upgr_armor>0)then arm+=upgr[_upgr_armor];

         case uidi of
UID_Baron : if(buff[ub_advanced]>0)then
             if(g_addon)
             then arm+=dam div 2
             else arm+=dam div 3;
         else
         end;

         case g_mode of
gm_inv    : if(playeri=0)then dam:=dam div 2;
         end;
      end;

      dam-=arm;

      if(dam<=0)then
       if(_random(abs(dam)+1)=0)
       then dam:=1
       else dam:=0;

      if(hits<=dam)
      then _unit_kill(pu,false,(hits-dam)<=_fastdeath_hits[buff[ub_advanced]>0])
      else
      begin
         hits-=dam;

         if(_ismech)
         then buff[ub_pain]:=fr_2fps
         else
           if(_painc>0)and(painc>0)and(buff[ub_pain]=0)then
           begin
              if(uidi=UID_Mancubus)and(buff[ub_advanced]>0)then exit;

              if(p>pains)
              then pains:=0
              else pains-=p;

              if(pains=0)then
              begin
                 pains:=painc;

                 buff[ub_pain      ]:=pain_time;
                 buff[ub_stopattack]:=buff[ub_pain];

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


{


procedure _unit_bteleport(pu:PTUnit);
begin
   with pu^ do
    with player^ do
     if(bld)then
      if(upgr[upgr_mainm]>0)and(buff[ub_clcast]=0)then
       if(_unit_grbcol(uo_x,uo_y,r,255,0,upgr[upgr_mainonr]=0)=0)then
       begin
          dec(upgr[upgr_mainm],1);
          {$IFDEF _FULLGAME}
          if(_uvision(_players[HPlayer].team,pu,true))then
           if(_nhp(x,y) or _nhp(uo_x,uo_y))then PlaySND(snd_cubes,nil);
          _effect_add(x,y,0,EID_HKT_h);
          {$ENDIF}
          buff[ub_clcast ]:=vid_fps;
          buff[ub_teleeff]:=vid_fps;
          x :=uo_x;
          y :=uo_y;
          vx:=x;
          vy:=y;
          {$IFDEF _FULLGAME}
          _effect_add(x,y,0,EID_HKT_s);
          _unit_sfog(pu);
          _unit_mmcoords(pu);
          {$ENDIF}
       end;
end;
}

procedure _unit_action(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   if(apcc>0)
   then uo_id:=ua_unload
   else
    if(_canmove(pu))then
     if(inapc=0)then
     with player^ do
     case _ability of
uab_spawnlost  : if(buff[ub_cast]<=0)and(buff[ub_clcast]<=0)then
                 begin
                    buff[ub_cast  ]:=fr_hfps;
                    buff[ub_clcast]:=fr_2fps;
                    _ability_unit_spawn(pu,UID_LostSoul);
                 end;
uab_morph2heye : if(upgr[upgr_hell_heye]>0)and(menerg>0)then
                 begin
                    _unit_kill(pu,true,true);
                    _unit_add(vx,vy,UID_HEye,playeri,true,true);
                    buff[ub_cast]:=fr_fps;
                    {$IFDEF _FULLGAME}
                    _pain_lost_fail(vx,vy,_depth(vy+1,uf),nil);
                    {$ENDIF}
                 end;
uab_umine      : if(upgr[upgr_uac_mines]>0)and(buff[ub_clcast]<=0)then
                 if((army+uproda)<MaxPlayerUnits)and(menerg>0)then
                 begin
                    _unit_add(vx,vy,UID_UMine,playeri,true,true);
                    buff[ub_clcast]:=fr_fps;
                 end;
     end;

{   case uidi of
UID_HCommandCenter,
UID_UCommandCenter:
                if(apcc>0)
                then uo_id:=ua_unload
                else
                if(buff[ub_clcast]=0)then
                 if(upgr[upgr_mainm]>0)or(race=r_hell)then
                 begin
                    if(buff[ub_advanced]=0)then
                    begin
                       buff[ub_advanced]:= _ub_infinity;
                       speed            := 5;
                       uf               := uf_fly;
                       buff[ub_clcast]  := uaccc_fly;
                       dec(y,buff[ub_clcast]);
                       {$IFDEF _FULLGAME}
                       PlaySND(snd_ccup,pu);
                       {$ENDIF}
                       uo_x:=x;
                       uo_y:=y;
                    end
                    else
                      if(_unit_grbcol(x,y+uaccc_fly,r,255,0,upgr[upgr_mainonr]=0)=0)then
                      begin
                         buff[ub_advanced]:= 0;
                         speed            := 0;
                         uf               := uf_ground;
                         buff[ub_clcast]  := uaccc_fly;
                         inc(y,buff[ub_clcast]);
                         vy:=y;
                         {$IFDEF _FULLGAME}
                         PlaySND(snd_inapc,pu);
                         {$ENDIF}
                         uo_x:=x;
                         uo_y:=y;
                      end;
                 end;
   else
   end;  }
end;

procedure _unit_push(pu,tu:PTUnit;ud:integer);
var t:integer;
begin
   with pu^ do
   with uid^ do
   begin
      t:=ud;
      if(tu^.speed<=0)and(pu^.player=tu^.player)
      then ud-=tu^.uid^._r
      else ud-=tu^.uid^._r+_r;

      if(ud<0)then
      begin
         if(tu^.x=x)and(tu^.y=y)then
         begin
            x+=_randomr(2);
            y+=_randomr(2);
         end
         else
         begin
            if(t<=0)then t:=1;
            x+=trunc(ud*(tu^.x-x)/t);
            y+=trunc(ud*(tu^.y-y)/t);
         end;

         vstp:=UnitStepNum;

         _unit_correctXY(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         dir:=_DIR360(dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 ));

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
var t,ud:integer;
begin
   with pu^ do
   with uid^ do
   begin
      ud:=dist(x,y,td^.x,td^.y);
      t :=ud;
      ud-=_r+td^.r-8;

      if(ud<0)then
      begin
         if(td^.x=x)and(td^.y=y)then
         begin
            x+=_randomr(2);
            y+=_randomr(2);
         end
         else
         begin
            if(t<=0)then t:=1;
            x+=trunc(ud*(td^.x-x)/t);
            y+=trunc(ud*(td^.y-y)/t);
         end;

         vstp:=UnitStepNum;

         _unit_correctXY(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         if(a_rld<=0)then dir:=_DIR360(dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 ));

         t:=dist2(uo_x,uo_y,td^.x,td^.y)-_r-td^.r;
         if(t<=0)then
         begin
            uo_x:=x;
            uo_y:=y;
         end;
      end;
   end;
end;

procedure _unit_npush(pu:PTUnit);
var i,dx,dy:integer;
begin
   dx:=pu^.x div dcw;
   dy:=pu^.y div dcw;

   if(0<=dx)and(dx<=dcn)and(0<=dy)and(dy<=dcn)then
   with map_dcell[dx,dy] do
    for i:=1 to n do
     with l[i-1]^ do
      if(r>0)and(t>0)then _unit_dpush(pu,l[i-1]);
end;

procedure _unit_npush_dcell(pu:PTUnit);
begin
   with pu^ do
    if(speed>0)and(uf=uf_ground)and(solid)then _unit_npush(pu);
end;

procedure _unit_move(pu:PTUnit);
var mdist,ss:integer;
    ddir    :single;
    tu      :PTUnit;
begin
   with pu^ do
   if(_IsUnitRange(inapc,@tu))then
   begin
      _unit_asapc(pu,tu);
      if(tu^.uo_id in [ua_move,ua_hold,ua_amove])then
      begin
         uo_id  := tu^.uo_id;
         uo_tar := tu^.uo_tar;
      end;

      {if(tu^.uo_id<>uo_id)then
       if(tu^.uo_id in [ua_hold,ua_amove,ua_move])then
       begin
          uo_id:=tu^.uo_id;
          if(uo_id<>ua_amove)then a_tar:=0;
       end;
      if(tu^.a_tar=tu^.uo_tar)then
      begin
         a_tar:=tu^.uo_tar;
         uo_id:=ua_move;
      end;  }
   end
   else
    if(ServerSide)then
     if(_canmove(pu))then
      if(x=vx)and(y=vy)then
       if(x<>mv_x)or(y<>mv_y)then
       begin
          ss:=speed;

          if(buff[ub_slooow]>0)then ss:=ss div 2;

          if(ss<2)then ss:=2;

          mdist:=dist2(x,y,mv_x,mv_y);
          if(mdist<=speed)then
          begin
             x:=mv_x;
             y:=mv_y;
             dir:=p_dir(vx,vy,x,y);
          end
          else
          begin
             {if(uidi=UID_UTransport)and(buff[ub_pain]>0)then dec(spup,2); }
             with uid^ do
              if(_isbuilding=false)then
               with player^ do
                case _ismech of
                false: ss+=upgr[upgr_race_bio_mspeed [_urace]];
                true : ss+=upgr[upgr_race_mech_mspeed[_urace]];
                end;

             if(mdist>70)
             then mdist:=8+_random(25)
             else mdist:=50;

             dir:=dir_turn(dir,p_dir(x,y,mv_x,mv_y),mdist);

             ddir:=dir*degtorad;
             x:=x+trunc(ss*cos(ddir));
             y:=y-trunc(ss*sin(ddir));
          end;
          _unit_npush_dcell(pu);
          _unit_correctXY(pu);
          {$IFDEF _FULLGAME}
          _unit_mmcoords(pu);
          _unit_sfog(pu);
          {$ENDIF}
       end;
end;

{

{$include _ai.pas}

function _player_sight(player:byte;tu:PTUnit;vision:boolean):boolean;
begin
   _player_sight:=true;

   with _players[player] do
    if(vision)
    then exit
    else
     if(tu^.buff[ub_invis]=0)then
     begin
        if(tu^.isbuild)and(tu^.speed=0)then
         if(cf(@ai_flags,@aif_nofogblds))then exit;

        if(tu^.isbuild=false)then
         if(cf(@ai_flags,@aif_nofogunts))then exit;
     end;

   _player_sight:=false;
end;

procedure _unit_tardetect(pu,tu:PTUnit;ud:integer);
var
 vision,
 teams:boolean;
begin
   with pu^ do
   begin
      with player^ do
      begin
         teams:=(team=tu^.player^.team);

         if(tu^.hits>0)then
         begin
            vision:=_uvision(team,tu,false);

            if(onlySVCode)and(state=ps_comp)and(vision)then _unit_aiUBC(pu,tu,ud,teams);

            if(_player_sight(playeri,tu,vision))then
             if(teams=false)then
             begin
                if(tu^.buff[ub_invuln]=0)then
                 if(alrm_b=false)or(ud<base_rr)then
                  if(ud<alrm_r)then
                  begin
                     alrm_x:=tu^.x;
                     alrm_y:=tu^.y;
                     alrm_r:=ud;
                     alrm_b:=false;
                  end;
             end
             else
               if(state=ps_comp)then
                if(tu^.isbuild)or(tu^.alrm_r<0)then
                 if(isbuild=false)and(tu^.alrm_r<base_rr)then
                  if not(tu^.uidi in [UID_UMine,UID_HEye])then
                  begin
                     ud:=dist2(x,y,tu^.alrm_x,tu^.alrm_y);
                     if(ud<alrm_r)or((tu^.isbuild)and(alrm_b=false))then
                      if(ud<base_3r)or(order<>2)then
                      begin
                         alrm_x:=tu^.alrm_x;
                         alrm_y:=tu^.alrm_y;
                         alrm_r:=ud;
                         if(tu^.isbuild)then
                          if(cf(@ai_flags,@aif_help))then alrm_b:=true;
                      end;
                  end;
         end;
      end;

      if(onlySVCode)then
      begin
         with player^ do
          if(bld)and(tu^.hits>0)then
          begin
             if(uidi=UID_HKeep)then
              if(upgr[upgr_paina]>0)and(ud<sr)then
               if(teams=false)then
               begin
                  if not(tu^.uidi in [UID_HEye,UID_UMine])then  _unit_damage(tu,upgr[upgr_paina] shl 1,upgr[upgr_paina],playeri);
               end
               else tu^.buff[ub_toxin]:=-vid_fps;
          end;

         if(uo_id=ua_amove)then
         begin
            if(rld_t>0)and(uidi=UID_Archvile)then exit;

            if(_unit_target(pu,tu,ud,false)>0)then
             if(_TarPrioDT(pu,tu,ud))then
             begin
                tar1 :=tu^.unum;
                tar1d:=ud;
             end;
         end;
      end;
   end;
end;



procedure _unit_cp(pu:PTUnit);
var i : byte;
    ud:integer;
begin
   with pu^ do
   with player^ do
   begin
      for i:=1 to MaxPlayers do
       with g_ct_pl[i] do
       begin
          ud:=dist2(x,y,px,py);

          if(ud<=g_ct_pr)and(_players[pl].team<>team)then
           if(ct<g_ct_ct[race])
           then inc(ct,vid_hfps)
           else
             if(ct>=g_ct_ct[race])then
             begin
                pl:=playeri;
                ct:=0;
             end;

          if(_players[pl].team<>team)or(pl=0)or(ct>0)then
          begin
             if(ud<ai_ptd)then
             begin
                ai_ptd:=ud;
                ai_pt :=i;
             end;
          end;
       end;

      if(ai_pt>0)then
      begin
         alrm_x:=g_ct_pl[ai_pt].px;
         alrm_y:=g_ct_pl[ai_pt].py;
      end;
   end;
end;

}

function _target_weapon_check(pu,tu:PTUnit;ud:integer;cw:byte;checkvis,nosrangecheck:boolean):byte;
var awr:integer;
begin
   _target_weapon_check:=0;

   if(checkvis)then
    if(_uvision(pu^.player^.team,tu,false)=false)then exit;
   if(cw>MaxUnitWeapons)then exit;
   if(tu^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=dist2(pu^.x,pu^.y,tu^.x,tu^.y);

   with pu^ do
   with uid^ do
   with player^ do
   with _a_weap[cw] do
   begin
      // Weapon type requirements

      case aw_type of
wpt_resurect : if(tu^.buff[ub_resur]>0)
               or(tu^.buff[ub_pain ]>0)
               or(tu^.hits<=fdead_hits)
               or(tu^.hits> 0         )then exit;
wpt_heal     : if(tu^.hits<=0)
               or(tu^.hits>=tu^.uid^._mhits)
               or(tu^.bld=false       )then exit;
      end;

      // UID and UPID requirements

      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0         )then exit;
      if(aw_rupgr>0)and(upgr  [aw_rupgr]< aw_rupgr_l)then exit;

      // requirements to attacker and some flags

      if not(tu^.uidi in aw_uids)then exit;

      if(cf(@aw_reqf,@wpr_adv ))and(buff[ub_advanced]<=0)then exit;
      if(cf(@aw_reqf,@wpr_nadv))and(buff[ub_advanced]> 0)then exit;

      if(cf(@aw_reqf,@wpr_zombie))then
      begin
         if(tu^.bld=false)
         or(tu^.uid^._zombie_uid =0)
         or(tu^.uid^._zombie_hits<hits)
         or(tu^.hits<=fdead_hits)then exit;
         if(tu^.hits<=0)and(tu^.uid^._isbuilding)then exit;
      end;

      // requirements to target

      if(cf(@aw_tarf,@wtr_owner_p )=false)and(playeri =tu^.playeri       )then exit;
      if(cf(@aw_tarf,@wtr_owner_a )=false)and(team    =tu^.player^.team  )then exit;
      if(cf(@aw_tarf,@wtr_owner_e )=false)and(team   <>tu^.player^.team  )then exit;

      if(cf(@aw_tarf,@wtr_hits_h  )=false)and
                                 (0<tu^.hits)and(tu^.hits<tu^.uid^._mhits)then exit;

      if(cf(@aw_tarf,@wtr_hits_d  )=false)and(tu^.hits<=0                )then exit;
      if(cf(@aw_tarf,@wtr_hits_a  )=false)and(tu^.hits =tu^.uid^._mhits  )then exit;

      if(cf(@aw_tarf,@wtr_bio     )=false)and(tu^.uid^._ismech=false     )then exit;
      if(cf(@aw_tarf,@wtr_mech    )=false)and
                        (tu^.uid^._ismech)and(tu^.uid^._isbuilding=false )then exit;
      if(cf(@aw_tarf,@wtr_building)=false)and(tu^.uid^._isbuilding       )then exit;

      if(cf(@aw_tarf,@wtr_bld     )=false)and(tu^.bld                    )then exit;
      if(cf(@aw_tarf,@wtr_nbld    )=false)and(tu^.bld =false             )then exit;

      if(cf(@aw_tarf,@wtr_ground  )=false)and(tu^.uf = uf_ground         )then exit;
      if(cf(@aw_tarf,@wtr_soaring )=false)and(tu^.uf = uf_soaring        )then exit;
      if(cf(@aw_tarf,@wtr_fly     )=false)and(tu^.uf = uf_fly            )then exit;

      if(cf(@aw_tarf,@wtr_adv     )=false)and(tu^.buff[ub_advanced]> 0   )then exit;
      if(cf(@aw_tarf,@wtr_nadv    )=false)and(tu^.buff[ub_advanced]<=0   )then exit;

      // Distance requirements

      if(aw_range=0)
      then awr:=ud-srange
      else
        if(aw_range>0)
        then awr:=ud-aw_range
        else
          if(_IsUnitRange(inapc,nil))
          then exit
          else awr:=ud-(_r+tu^.uid^._r-aw_range);

      if(awr<0)or(ServerSide=false)
      then _target_weapon_check:=2      // can attack now
      else
        if(speed>0)and(uo_id<>ua_hold)and(_IsUnitRange(inapc,nil)=false)then
         if(ud<=srange)or(nosrangecheck)
         then _target_weapon_check:=1  // need move closer
         else exit;                    // target too far
   end;
end;

function _unit_target2weapon(pu,tu:PTUnit;ud:integer;cw:byte;action:pbyte):byte;
var i,a:byte;
begin
   _unit_target2weapon:=255;

   if(_uvision(pu^.player^.team,tu,false)=false)then exit;
   if(tu^.hits<=fdead_hits)then exit;
   if(ud<0)then ud:=dist2(pu^.x,pu^.y,tu^.x,tu^.y);
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


procedure _unit_target(pu,tu:PTUnit;ud:integer;a_tard:pinteger;t_weap:pbyte);
var tw:byte;
begin
   with pu^ do
   with uid^ do
   begin
      tw:=_unit_target2weapon(pu,tu,ud,t_weap^,nil);

      if(tw>MaxUnitWeapons)then exit;

      if(tw>t_weap^)
      then exit
      else
        if(tw<t_weap^)
        then // high weapon priority
        else
          if(ud>a_tard^)then exit;

      t_weap^:=tw;
      a_tar  :=tu^.unum;
      a_tard^:=ud;
   end;
end;

procedure _unit_mcycle(pu:PTUnit);
var uc,a_tard,
    ud: integer;
    tu: PTUnit;
cunload,
ftarget,
  push: boolean;
t_weap: byte;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      a_tar   := 0;
      a_tard  := 32000;
      t_weap  := 255;

      if(g_mode=gm_royl)then
       if((dist(x,y,map_hmw,map_hmw)+_missile_r)>=g_royal_r)then
       begin
          _unit_kill(pu,false,false);
          exit;
       end;

      if(_isbuilding)and(menerg<=0)then
      begin
         _unit_kill(pu,false,false);
         exit;
      end;

      cunload:=true;
      if(uf>uf_ground)and(apcm>0)and(apcc>0)and(uo_id=ua_unload)then
       if(_unit_OnDecorCheck(x,y))then cunload:=false;

      push    := solid and _canmove(pu);
      ftarget := _canattack(pu);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=@_units[uc];
         if(tu^.hits>fdead_hits)then
         begin
            ud:=dist2(x,y,tu^.x,tu^.y);

            if(tu^.inapc<=0)then
            begin
               _unit_detect(pu,tu,ud);
               if(ftarget)then _unit_target(pu,tu,ud,@a_tard,@t_weap);
            end;

            if(tu^.hits>0)then
            begin
               if(tu^.inapc>0)then // unload
               begin
                  if(tu^.inapc=unum)and(uo_id=ua_unload)and(cunload)then
                  begin
                     if(apcc>0)then
                     begin
                        apcc-=tu^.uid^._apcs;
                        tu^.inapc:=0;
                        tu^.x    :=x-_randomr(_r);
                        tu^.y    :=y-_randomr(_r);
                        tu^.uo_x :=tu^.x;
                        tu^.uo_y :=tu^.y;
                     end;
                     if(apcc=0)then
                     begin
                        {$IFDEF _FULLGAME}
                        PlaySND(snd_inapc,pu,nil);
                        {$ENDIF}
                        uo_id:=ua_amove;
                     end;
                  end;
                  continue;
               end;

               if(push)then
                if(_r<=tu^.uid^._r)or(tu^.speed<=0)then
                 if(tu^.solid)and((uf=uf_ground)=(tu^.uf=uf_ground))then _unit_push(pu,tu,ud);

               ud-=_r+tu^.uid^._r;

               if(player=tu^.player)then
               begin

                  if(ud<melee_r)then
                   if(uo_tar=uc)or(tu^.uo_tar=unum)then
                    if(_itcanapc(pu,tu))then
                    begin
                       //if(state=ps_comp)and(order<>1)then tu^.order:=order;
                       apcc+=tu^.uid^._apcs;
                       tu^.inapc:=unum;
                       tu^.a_tar:=0;
                       if(    uo_tar=uc  )then     uo_tar:=0;
                       if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
                       _unit_desel(tu);
                       {$IFDEF _FULLGAME}
                       PlaySND(snd_inapc,pu,nil);
                       {$ENDIF}
                       continue;
                    end;

               end;
            end;
         end;
      end;

      _unit_npush_dcell(pu);

      {$IFDEF _FULLGAME}
      //if(playeri=HPlayer)and(alrm_r<srange)and(alrm_b=false)then ui_addalrm(mmx,mmy,_isbuilding);
      {$ENDIF}
   end;
end;

procedure _unit_mcycle_cl(pu:PTUnit);
var uc,a_tard,
    ud : integer;
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
         ftarget:=_canattack(pu);
      end
      else ftarget:=false;

      if(_IsUnitRange(inapc,@tu))then
      begin
         if(tu^.inapc>0)then exit;
         vsnt   :=tu^.vsnt;
         udetect:=false;
      end
      else udetect:=true;

      if(udetect=false)and(ftarget=false)then exit;  // in apc & client side

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=@_units[uc];
         if(tu^.hits>fdead_hits)then
         begin
            ud:=dist2(x,y,tu^.x,tu^.y);
            if(udetect)then _unit_detect(pu,tu,ud);
            if(ftarget)then _unit_target(pu,tu,ud,@a_tard,@t_weap);
         end;
      end;

      {$IFDEF _FULLGAME}
      //if(playeri=HPlayer)and(alrm_r<srange)and(alrm_b=false)then ui_addalrm(mmx,mmy,_isbuilding);
      {$ENDIF}
   end;
end;


function _move2uotar(uu,tu:PTUnit;td:integer):boolean;
begin
   _move2uotar:=true;
   {if(tu^.uidi=UID_HTeleport)then exit;
   _move2uotar:=(tu^.x<>tu^.uo_x)or(tu^.y<>tu^.uo_y)or(td>uu^.sr);
   dec(td,uu^.r+tu^.r);
   if(td<=-melee_r)then _move2uotar:=false;
   if(tu^.playeri=uu^.playeri)then
    if(_itcanapc(tu,uu))then
    begin
       _move2uotar:=true;
       if(tu^.uf>uf_ground)and(tu^.uo_tar=0)then
       begin
          tu^.uo_x:=uu^.x;
          tu^.uo_y:=uu^.y;
       end;
    end;}
end;

procedure _unit_uac_unit_adv(pu,tu:PTUnit);
begin
   with pu^  do
   with uid^ do
   begin
      buff[ub_gear    ]:=gear_time[_ismech];

      if(ServerSide)then
      begin
         buff[ub_advanced]:=_ub_infinity;

         if(tu^.player^.upgr[upgr_uac_6bld]>0)
         then tu^.rld:=uac_adv_base_reload[_ismech] div tu^.player^.upgr[upgr_uac_6bld]
         else tu^.rld:=uac_adv_base_reload[_ismech];
      end;

      {$IFDEF _FULLGAME}
      PlaySND(snd_unit_adv[_urace],pu,nil);
      {$ENDIF}
   end;
end;

procedure _unit_hell_unit_adv(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      buff[ub_advanced]:=_ub_infinity;
      {$IFDEF _FULLGAME}
      _unit_PowerUpEff(pu,snd_unit_adv[_urace]);
      {$ENDIF}
   end;
end;

procedure _unit_building_start_adv(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      _unit_bld_dec_cntrs(pu);
      buff[ub_advanced]:=_ub_infinity;
      bld := false;
      hits:= 1;
      cenerg-=_renerg;
   end;
end;

function _ability_uac__unit_adv(pu,tu:PTUnit;tdm:integer):boolean;
begin
   // pu - target
   // tu - caster
   _ability_uac__unit_adv:=false;
   with pu^  do
   with uid^ do
   if(tdm<=speed)and(tu^.rld<=0)and(_isbuilding=false)and(tu^.hits>0)then
   begin
      if(tu^.buff[ub_advanced]>0)and(tu^.bld)and(buff[ub_advanced]<=0)then _unit_uac_unit_adv(pu,tu);
      uo_x  :=tu^.uo_x;
      uo_y  :=tu^.uo_y;
      uo_tar:=tu^.uo_tar;
      _ability_uac__unit_adv:=true;
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
      if(_isbuilding=false)and(bld)then
       with tu^.player^ do
        if(tu^.bld)and(tu^.hits>0)then
         if(buff[ub_advanced]<=0)and(upgr[upgr_hell_6bld]>0)then
         begin
            upgr[upgr_hell_6bld]-=1;
            _unit_hell_unit_adv(pu);
         end;
      _unit_clear_order(tu,false);
      _unit_clear_order(pu,false);
      _ability_hell_unit_adv:=true;
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
      if(_isbuilding)and(bld)and(_ability=0)then
       if(_isbarrack)or(_issmith)then
       if(tu^.uid^._isbuilding)and(tu^.rld<=0)and(tu^.bld)and(tu^.hits>0)then
        if(buff[ub_advanced]<=0)and(cenerg>=_renerg)then
        begin
           _unit_building_start_adv(pu);
           tu^.rld:=building_adv_reload[tu^.buff[ub_advanced]>0];
           {$IFDEF _FULLGAME}
           PlayCommandSound(snd_building[_urace]);
           {$ENDIF}
        end;

      tu^.uo_tar:=0;

      _ability_building_adv:=true;
   end;
end;

function _ability_teleport(pu,tu:PTUnit;td:integer):boolean;
begin
   _ability_teleport:=false;
   with pu^  do
   with uid^ do
   begin
      if(_isbuilding=false)and(tu^.hits>0)and(tu^.bld)then
       if(player^.team=tu^.player^.team)and(buff[ub_teleeff]<=0)then
        if(td<=tu^.uid^._r)then
        begin
           if(dist2(x,y,tu^.uo_x,tu^.uo_y)>tu^.uid^._srange)and(tu^.rld<=0) then
           begin
              if(uf=uf_ground)then
               if(tu^.buff[ub_transpause]>0)
               then exit
               else
                 if(_unit_OnDecorCheck(tu^.uo_x,tu^.uo_y))then exit;

              _unit_teleport(pu,tu^.uo_x,tu^.uo_y);
              _teleport_rld(tu,_mhits);
              _ability_teleport:=true;
           end;
        end
        else
          if(tu^.buff[ub_advanced]>0)and(td>base_rr)then
           if(tu^.rld<=0)then
           begin
              _unit_teleport(pu,tu^.x,tu^.y);
              _teleport_rld(tu,_mhits);
              _ability_teleport:=true;
           end
           else
           begin
              uo_x:=x;
              uo_y:=y;
           end;
   end;
end;

procedure _unit_uo_tar(pu:PTUnit);
var tu: PTUnit;
     w: byte;
td,tdm: integer;
teams : boolean;
begin
   with pu^ do
   with uid^ do
   begin
      if(uo_tar=unum)then uo_tar:=0;
      if(_IsUnitRange(uo_tar,@tu))then
      begin
         if(_IsUnitRange(tu^.inapc,nil))then
         begin
            uo_tar:=0;
            exit;
         end;
         if(_uvision(player^.team,tu,false)=false)then
         begin
            uo_tar:=0;
            exit;
         end;

         td :=dist2(x,y,tu^.x,tu^.y);
         tdm:=td-(_r+tu^.uid^._r);

         if(playeri=tu^.playeri)then
         begin

            // target units
            case tu^.uid^._ability of
uab_uac__unit_adv: if(_ability_uac__unit_adv(pu,tu,tdm))then exit;
uab_hell_unit_adv: if(_ability_hell_unit_adv(pu,tu    ))then exit;
//uab_building_adv : if(_ability_building_adv (pu,tu    ))then exit;
            end;

            case _ability of
uab_hell_unit_adv: if(_ability_hell_unit_adv(tu,pu    ))then exit;
uab_building_adv : if(_ability_building_adv (tu,pu    ))then exit;
            end;
         end;

         w:=_unit_target2weapon(pu,tu,td,255,nil);
         if(w<=MaxUnitWeapons)then
         begin
            a_tar :=uo_tar;
            uo_id :=ua_amove;
         end;

         if(_move2uotar(pu,tu,tdm))then
         begin
            uo_x:=tu^.vx;
            uo_y:=tu^.vy;
         end;

         case tu^.uid^._ability of
uab_teleport: _ability_teleport(pu,tu,td);
         end;
      end;
   end;
end;

procedure _resurrect(tu:PTUnit);
begin
   with tu^ do
   begin
      buff[ub_resur]:=fr_2fps;
      zfall:=-uid^._zfall;
   end;
end;

procedure _makezimba(pu,tu:PTUnit);
var _h:single;
    _o:byte;
    _d,
    _a:integer;
begin
   _h:=tu^.hits/tu^.uid^._mhits;
   _d:=tu^.dir;
   _o:=pu^.order;
   _a:=tu^.buff[ub_advanced];

   _unit_kill(pu,true,true);

   _unit_add(tu^.x,tu^.y,tu^.uid^._zombie_uid,pu^.playeri,true,true);
   if(_LastCreatedUnit>0)then
   with _LastCreatedUnitP^ do
   begin
      order:=_o;
      dir  :=_d;
      buff[ub_advanced]:=_a;
      hits :=trunc(uid^._mhits*_h);
      if(hits<=0)then
      begin
         buff[ub_born]:=0;
         _unit_dec_Kcntrs(_LastCreatedUnitP);
         _resurrect(_LastCreatedUnitP);
      end;
   end;

   _unit_kill(tu,true,true);
end;

procedure _unit_attack(pu:PTUnit);
var w,a  : byte;
     tu  : PTUnit;
upgradd,c: integer;
begin
   with pu^ do
   begin
      if(_canattack(pu)=false)then exit;
      if(_IsUnitRange(a_tar,@tu)=false)then exit;

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

      case a of
      0: exit;
      1: begin
            if(ServerSide)then
            begin
               mv_x:=tu^.x;
               mv_y:=tu^.y;
            end;
            exit;
         end;
      else
         if(ServerSide)then
         begin
            mv_x:=x;
            mv_y:=y;
         end;
      end;

      // attack code
      with uid^ do
      with _a_weap[a_weap] do
      begin
         if(a_rld=0)then
         begin
            a_rld:=aw_rld;
            dir    :=p_dir(x,y,tu^.x,tu^.y);
            if(ServerSide)then buff[ub_stopattack]:=max2(a_rld,_uclord_p);
            {$IFDEF _FULLGAME}
            _unit_attack_effects(pu,true,nil);
            a_aweap:=a_weap;
            {$ENDIF}
         end;

         if(uclord=_uclord_c)then
         begin
            if(cf(@aw_reqf,@wpr_tvis))then _AddToInt(@tu^.vsnt[player^.team],vistime);
            _AddToInt(@vsnt[tu^.player^.team],vistime);
         end;

         {$IFDEF _FULLGAME}
         if(aw_eid_target>0)then
          if(_PointInScreen2(tu^.vx,tu^.vy,@_players[HPlayer])=false)then exit;
          begin
             if((G_Step mod fr_3hfps)=0)then _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.uf),aw_eid_target);
             if(aw_snd_target<>nil)then
              if((G_Step mod fr_fps  )=0)then PlaySND(aw_snd_target,tu,nil);
          end;
         {$ENDIF}

         if(a_rld in aw_rld_s)then
         begin
            {$IFDEF _FULLGAME}
            _unit_attack_effects(pu,false,nil);
            {$ENDIF}
            if(aw_dupgr>0)and(aw_dupgr_s>0)then
             upgradd:=player^.upgr[aw_dupgr]*aw_dupgr_s;
            dir    :=p_dir(x,y,tu^.x,tu^.y);
            case aw_type of
wpt_missle     : if(cf(@aw_reqf,@wpr_sspos))
                 then _missile_add(vx,vy,vx,vy,a_tar,aw_oid,playeri,uf,tu^.uf,upgradd)
                 else
                   if(aw_count=0)
                   then _missile_add(tu^.x,tu^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,uf,tu^.uf,upgradd)
                   else
                     if(aw_count>0)
                     then for c:=1 to aw_count do _missile_add(tu^.x,tu^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,uf,tu^.uf,upgradd)
                     else
                       if(aw_count<0)then
                       begin
                          _missile_add(tu^.x,tu^.y,vx-aw_count+aw_x,vy-aw_count+aw_y,a_tar,aw_oid,playeri,uf,tu^.uf,upgradd);
                          _missile_add(tu^.x,tu^.y,vx+aw_count+aw_x,vy+aw_count+aw_y,a_tar,aw_oid,playeri,uf,tu^.uf,upgradd);
                       end;
wpt_unit       : _ability_unit_spawn(pu,aw_oid);
            else
               if(ServerSide)then
                case aw_type of
wpt_resurect : _resurrect(tu);
wpt_heal     : if(tu^.hits>0)then tu^.hits:=min2(tu^.hits+aw_count+upgradd,tu^.uid^._mhits);
wpt_directdmg: if(cf(@aw_reqf,@wpr_zombie))
               then _makezimba(pu,tu)
               else _unit_damage(tu,aw_count+upgradd,2,playeri);
                end;
            end;

            if(ServerSide)then
             if(cf(@aw_reqf,@wpr_suicide))then _unit_kill(pu,false,true);
         end;
      end;
   end;
end;

procedure _unit_order(pu:PTUnit);
begin
   with pu^ do
   if(ServerSide=false)
   then _unit_attack(pu)
   else
   begin
      if(_IsUnitRange(inapc,nil)=false)then
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
               _unit_turn(pu);
            end
            else
              if(uo_id=ua_move)then uo_id:=ua_amove;
      end;
      if(uo_id=ua_amove)then _unit_attack(pu);
      if(buff[ub_stopattack]>0)then
       if(buff[ub_stopattack]=1)then
       begin
          buff[ub_stopattack]:=0;
          _unit_turn(pu);
       end
       else
       begin
          mv_x:=x;
          mv_y:=y;
       end;
   end;
end;


procedure _unit_prod(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(bld)then
      begin
         _unit_end_uprod(pu);
         _unit_end_pprod(pu);

         if(uid_x[            uidi]<=0)then uid_x[            uidi]:=unum;
         if(ucl_x[_isbuilding,_ucl]<=0)then ucl_x[_isbuilding,_ucl]:=unum;
      end
      else
        if(cenerg<0)
        then _unit_kill(pu,false,false)
        else
          if(buff[ub_pain]<=0)then
          begin
             if(_uclord_c=uclord)then
             begin
                hits+=_bstep;
                hits+=_bstep*upgr[upgr_fast_build];
             end;

             if(hits>=_mhits){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
             begin
                hits:=_mhits;
                bld :=true;
                _unit_bld_inc_cntrs(pu);
                cenerg+=_renerg;
                {$IFDEF _FULLGAME}
                _unit_ready_effects(pu,nil);
                {$ENDIF}
             end;
          end;
   end;
end;

procedure _unit_reveal(pu:PTUnit);
var i : byte;
begin
   with pu^ do
   with player^ do
   begin
      _AddToInt(@vsnt[team],vistime);
      _AddToInt(@vsni[team],vistime);
      if(ServerSide)and(uclord=_uclord_c)then
       if{$IFDEF _FULLGAME}(menu_s2<>ms2_camp)and{$ENDIF}(n_builders=0)then
        for i:=0 to MaxPlayers do
        begin
           _AddToInt(@vsnt[i],fr_fps);
           if(g_mode<>gm_inv)or(playeri>0)then _AddToInt(@vsni[i],fr_fps);
        end;
   end;
end;

procedure _obj_cycle;
var u : integer;
    pu: PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      pu:=@_units[u];
      with pu^ do
      if(hits>dead_hits)then
      begin
         _unit_reveal(pu);

         if(hits>0)then
         begin
            _unit_counters(pu);
            _unit_upgr    (pu);
            _unit_order   (pu);
            _unit_move    (pu);

            if(ServerSide)then _unit_prod(pu);

            if(uclord=_uclord_c)then
             if(ServerSide)and(inapc=0)
             then _unit_mcycle   (pu)
             else _unit_mcycle_cl(pu);
         end
         else
         begin
            _unit_counters(pu);
            _unit_death(pu);
         end;

         _unit_movevis (pu);
      end;
   end;

   _missileCycle;
end;

////////////////////////////////////////////////////////////////////////////////




