

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
         if(ud<0)then inc(dp,1);
         inc(ud,dr);
         if(ud<0)or(dp>1)then
         begin
            _unit_OnDecorCheck:=true;
            exit;
         end;
      end;
end;

{procedure _unit_UACUpgr(pu:PTUnit;tu:PTUnit);
begin
   with pu^ do
   begin
      buff[ub_gear    ]:=gear_time[mech];
      buff[ub_advanced]:=_bufinf;
      with tu^.player^ do
      begin
         if(mech)
         then tu^.rld_t:=mech_adv_rel[(g_addon=false)or(upgr[upgr_6bld2]>0)]
         else tu^.rld_t:= uac_adv_rel[(g_addon=false)or(upgr[upgr_6bld2]>0)];
      end;
      {$IFDEF _FULLGAME}
      PlaySND(snd_uupgr,pu);
      {$ENDIF}
   end;
end; }



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
          if(ServerSide)or(hits>fdead_hits)then dec(hits,1);
          {$IFDEF _FULLGAME}
          if(uclord=_uclord_c)and(fsr>1)then dec(fsr,1);
          {$ENDIF}

          if(ServerSide)then
           if(hits<=dead_hits)then _unit_remove(pu);
       end
       else
        if(ServerSide)then
        begin
           if(hits<-80)then hits:=-80;
           inc(hits,1);
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
              if(playeri=HPlayer)then _unit_snd_ready(uidi,buff[ub_advanced]>0);
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
   if(unum>0)then
   with player^ do
   begin
      if(instant=false)then
      begin
         with uid^ do fastdeath:=fastdeath or _fastdeath[buff[ub_advanced]>0] or _ismech;
         buff[ub_pain]:=fr_fps; // prevent fast resurrecting

         {$IFDEF _FULLGAME}
         _unit_death_effects(pu,fastdeath,true)
         {$ENDIF}
      end;

      {$IFDEF _FULLGAME}
      if(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
      {$ENDIF}

      _unit_dec_Kcntrs(pu);

      with uid^ do
      begin
         if(_isbuilding)then bld_r:=fr_2fps;
         if(_zfall>0)and(uf>uf_ground)then zfall:=_zfall;
         if(_zfall<0)and(uf=uf_ground)then zfall:=_zfall;
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
      a_tard :=32000;
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
                   dec(apcc,tu^.uid^._apcs);
                   inc(tu^.x,_randomr(uid^._r));
                   inc(tu^.y,_randomr(uid^._r));
                   tu^.uo_x:=tu^.x;
                   tu^.uo_y:=tu^.y;
                   if(tu^.hits>apc_exp_damage)then
                   begin
                      dec(tu^.hits,apc_exp_damage);
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
   if(ServerSide=false)then exit;

   with pu^ do
   with uid^ do
   begin
      if(buff[ub_invuln]>0)or(hits<0)or(dam<0)then exit;

      arm:=0;

      with player^ do
      begin
         if(_isbuilding)then
         begin
            if(bld)then
            begin
               {arm:=upgr[upgr_build];
               if(uidi in [UID_UTurret,UID_UPTurret,UID_URTurret])then
                if(g_addon=false)
                then inc(arm,1)
                else
                 if(upgr[upgr_turarm]>0)then inc(arm,upgr[upgr_turarm]);

               if(dam<build_arm_f)
               then inc(arm,(dam div build_arm_f)*arm);
               inc(arm,5);  }
            end;
         end
         else
           if(_ismech)then
           begin
              {if(race=r_uac)then
              begin
                 if(dam<unit_arm_f)
                 then inc(arm,upgr[upgr_mecharm])
                 else inc(arm,(dam div unit_arm_f)*upgr[upgr_mecharm]);

                 inc(arm,3);
              end;  }
           end
           else
           begin
              {if(dam<unit_arm_f)
              then inc(arm,upgr[upgr_armor])
              else inc(arm,(dam div unit_arm_f)*upgr[upgr_armor]);

              case uidi of
              UID_Demon,
              UID_Cacodemon : inc(arm,2);
              UID_Baron,
              UID_Archvile  : inc(arm,3);
              else
                 if(uidi in armor_massive)then inc(arm,3);
              end;}
           end;

         case uidi of
UID_Baron : if(buff[ub_advanced]>0)then inc(arm,dam div 2);
         else
         end;

         if(g_mode in [gm_inv,gm_aslt])and(playeri=0)then dam:=dam div 2;
      end;

      dec(dam,arm);

      if(dam<=0)then
       if(random(abs(dam)+1)=0)
       then dam:=1
       else dam:=0;

      if(hits<=dam)
      then _unit_kill(pu,false,(hits-dam)<gavno_dth_h)
      else
      begin
         dec(hits,dam);

         if(_ismech)
         then buff[ub_pain]:=fr_2fps
         else
           if(_painc>0)and(painc>0)and(buff[ub_pain]=0)then
           begin
              //if(uidi=UID_Mancubus)and(buff[ub_advanced]>0)then exit;

              if(p>pains)
              then pains:=0
              else dec(pains,p);

              if(pains=0)then
              begin
                 pains:=painc;

                 buff[ub_pain      ]:=pain_time;
                 buff[ub_stopattack]:=pain_time;

                { if(uidi in [UID_Mancubus,UID_ArchVile,UID_ZBFG])then rld_t:=0;

                 with player^ do
                  if(race=r_hell)then
                   if(upgr[upgr_pains]>0)then inc(pains,upgr[upgr_pains]*3); }
                 {$IFDEF _FULLGAME}
                 _unit_pain_effects(pu,true);
                 {$ENDIF}
              end;
           end;
      end;
   end;
end;

{$Include _missiles.pas}
{
procedure _unit_URocketL(pu:PTUnit);
var i:byte;
begin
   with pu^ do
    if(bld)then
     with player^ do
      if(rld_t=0)and(race=r_uac)then
       if(upgr[upgr_blizz]>0)and(rld_t=0)then
       begin
          for i:=0 to MaxPlayers do _addtoint(@vsnt[i],vid_2fps);
          _miss_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,playeri,uf_soaring,false);
          rld_t:=vid_fps*10;
          dec(upgr[upgr_blizz],1);
          {$IFDEF _FULLGAME}
          _uac_rocketl_eff(pu);
          {$ENDIF}
       end;
end;

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

procedure _unit_b247teleport(pu:PTUnit);
begin
   with pu^ do
    with player^ do
     if(bld)then
      if(upgr[upgr_b478tel]>0)and(buff[ub_clcast]=0)then
       if(dist2(x,y,uo_x,uo_y)<sr)and(_unit_grbcol(uo_x,uo_y,r,255,0,true)=0)then
       begin
          dec(upgr[upgr_b478tel],1);
          _unit_teleport(pu,uo_x,uo_y);
          buff[ub_clcast ]:=vid_fps;
          buff[ub_teleeff]:=vid_fps;
       end;
end;

procedure _unit_morph(pu:PTUnit;nuid:byte;ubld:boolean);
begin
   with pu^ do
    with player^ do
    begin
       _unit_dec_Kcntrs(pu);
       _unit_dec_Rcntrs(pu);

       uidi :=nuid;
       _unit_sclass(pu);

       _unit_inc_cntrs(pu,ubld);
    end;
end;

procedure _unit_start_prod_adv(pu:PTUnit);
begin
   with pu^ do
    with player^ do
     if(buff[ub_advanced]=0)and((menerg-cenerg)>=renerg)then
     begin
        _unit_dec_Kcntrs(pu);
        if(bld_s=0)then bld_s:=1;
        hits:=100;
        bld :=false;
        inc(cenerg,renerg);
        buff[ub_advanced]:=_bufinf;
     end;
end; }

procedure _unit_action(pu:PTUnit);
begin
{   with pu^ do
   if(bld)then
   with player^ do
   case uidi of
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
UID_Engineer :  if(army<MaxPlayerUnits)and(upgr[upgr_mines]>0)and(menerg>0)and(inapc=0)and(buff[ub_cast]=0)then
                begin
                   _unit_add(vx,vy,UID_UMine,playeri,true);
                   buff[ub_cast]:=vid_hfps;
                end;
UID_APC,
UID_FAPC     :  if(apcc>0)then uo_id:=ua_unload;

UID_Pain     :  if(_canmove(pu))and(rld_t=0)then
                begin
                   buff[ub_cast]:=vid_hfps;
                   rld_t:=rld_r;
                   _pain_action(pu);
                end;
UID_UMine     :  if(upgr[upgr_minesen]>0)then if(buff[ub_advanced]>0)then buff[ub_advanced]:=0 else buff[ub_advanced]:=_ub_infinity;
UID_LostSoul :  if(upgr[upgr_vision]>0)then
                begin
                   {$IFDEF _FULLGAME}
                   _effect_add(vx,vy,vy+1,UID_LostSoul);
                   if(playeri=HPlayer)then PlaySND(snd_hellbar,nil);
                   {$ENDIF}
                   _unit_morph(pu,UID_HEye,true);
                   order:=0;
                end;
UID_Major,
UID_ZMajor   : if(buff[ub_advanced]>0)and(buff[ub_clcast]=0)then
               begin
                  if(uf>uf_ground)then
                   if(_unit_OnDecorCheck(x,y))then exit;

                  if(buff[ub_cast]>0)
                  then buff[ub_cast]:=0
                  else buff[ub_cast]:=_ub_infinity;

                  buff[ub_clcast]:=vid_fps;

                  {$IFDEF _FULLGAME}
                  if(buff[ub_cast]>0)
                  then PlaySND(snd_jetpon ,pu)
                  else PlaySND(snd_jetpoff,pu);
                  {$ENDIF}
               end;
{UID_HMilitaryUnit,
UID_UWeaponFactory,
UID_HPools,
UID_UMilitaryUnit,
UID_HGate    : if(ucl_eb[true,9]>0)then
               begin
                  if(ucl_x[9]<=0)or(MaxUnits<ucl_x[9])then exit;

               end;  }

   else
   end;  }
end;

procedure _unit_push(pu,tu:PTUnit;ud:integer);
var ix,iy,t:integer;
begin
   with pu^ do
   with uid^ do
   begin
      t:=ud;
      if(tu^.speed<=0)and(pu^.player=tu^.player)
      then dec(ud,tu^.uid^._r   )
      else dec(ud,tu^.uid^._r+_r);

      if(ud<0)then
      begin
         if(t<=0)then t:=1;

         ix:=trunc(ud*(tu^.x-x)/t)+integer(2*_random(2)-1);
         iy:=trunc(ud*(tu^.y-y)/t)+integer(2*_random(2)-1);

         inc(x,ix);
         inc(y,iy);

         vstp:=UnitStepNum;

         _unit_correctcoords(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         dir:=(360+dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 )) mod 360;

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
var ix,iy,t,ud:integer;
begin
   with pu^ do
   with uid^ do
   begin
      ud:=dist(x,y,td^.x,td^.y);
      t :=ud;
      dec(ud,_r+td^.r-8);

      if(ud<0)then
      begin
         if(t<=0)then t:=1;
         ix:=trunc(ud*(td^.x-x)/t)+integer(2*_random(2)-1);
         iy:=trunc(ud*(td^.y-y)/t)+integer(2*_random(2)-1);

         inc(x,ix);
         inc(y,iy);

         vstp:=UnitStepNum;

         _unit_correctcoords(pu);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(pu);
         _unit_sfog(pu);
         {$ENDIF}

         if(a_rld<=0)then dir:=(360+dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 )) mod 360;

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
    with player^ do
     if(speed>0)and(uf=uf_ground)and(solid)then _unit_npush(pu);
end;

procedure _unit_move(pu:PTUnit);
var mdist,ss:integer;
    tu:PTUnit;
begin
   with pu^ do
   if(inapc>0)then
   begin
      tu     :=@_units[inapc];
      x      := tu^.x;
      y      := tu^.y;
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
      {$IFDEF _FULLGAME}
      mmx    := tu^.mmx;
      mmy    := tu^.mmy;
      fx     := tu^.fx;
      fy     := tu^.fy;

      if(playeri=HPlayer)then
       if(tu^.sel)then inc(ui_units_inapc[uidi],1);
      {$ENDIF}
   end
   else
    if(ServerSide)then
     if(_canmove(pu))then
      if(x=vx)and(y=vy)then
       if(x<>mv_x)or(y<>mv_y)then
       begin
           mdist:=dist2(x,y,mv_x,mv_y);
           if(mdist<=speed)then
           begin
              x:=mv_x;
              y:=mv_y;
              dir:=p_dir(vx,vy,x,y);
           end
           else
           begin
              ss:=speed;

              {if(uidi=UID_UTransport)and(buff[ub_pain]>0)then dec(spup,2);
              with player^ do
              begin
                 if(race=r_uac)and(isbuild=false)then
                  case mech of
                  true : if(upgr[upgr_mechspd]>0)then inc(spup,upgr[upgr_mechspd]);
                  false: if(upgr[upgr_mspeed ]>0)then inc(spup,upgr[upgr_mspeed ]);
                  end;
              end; }
              if(buff[ub_slooow]>0)then ss:=ss div 2;

              if(ss<2)then ss:=2;

              if(mdist>70)
              then mdist:=8+_random(25)
              else mdist:=50;

              dir:=dir_turn(dir,p_dir(x,y,mv_x,mv_y),mdist);

              x:=x+trunc(ss*cos(dir*degtorad));
              y:=y-trunc(ss*sin(dir*degtorad));
           end;
           _unit_npush_dcell(pu);
           _unit_correctcoords(pu);
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

procedure _unit_code1(pu:PTUnit);
var uc,
    ud   :integer;
    tu   :PTUnit;
    push :boolean;
begin
   with pu^ do
   with player^ do
   begin
      ai_pt :=0;
      ai_ptd:=32000;

      if(g_mode=gm_ct)and(isbuild=false)then _unit_cp(pu);

      if(state=ps_comp)then ai_code1(pu);

      if(uf>uf_ground)and(apcm>0)and(apcc>0)and(uo_id=ua_unload)then
       if(_unit_OnDecorCheck(x,y))then uo_id:=ua_move;

      tar1d   := 32000;
      tar1    := 0;
      tar1p   := 0;
      push    := solid and _canmove(pu);
      if(alrm_r<0)
      then inc(alrm_r,1)
      else alrm_r:=32000;
      alrm_b  :=false;

      for uc:=1 to MaxUnits do
       if(uc<>unum)then
       begin
          tu:=@_units[uc];

          if(tu^.hits>0)then
          begin
             if(tu^.inapc>0)then // unload
             begin
                if(tu^.inapc=unum)and(uo_id=ua_unload)then
                begin
                   if(apcc>0)then
                   begin
                      dec(apcc,tu^.apcs);
                      tu^.inapc:=0;
                      inc(tu^.x,randomr(r));
                      inc(tu^.y,randomr(r));
                      tu^.uo_x :=tu^.x;
                      tu^.uo_y :=tu^.y;
                   end;
                   if(apcc=0)then
                   begin
                      {$IFDEF _FULLGAME}
                      PlaySND(snd_inapc,pu);
                      {$ENDIF}
                      uo_id:=ua_amove;
                   end;
                end;
                continue;
             end;

             ud:=dist2(x,y,tu^.x,tu^.y);

             _udetect(pu,tu,ud);
             _unit_tardetect(pu,tu,ud);

             if(push)then
              if(r<=tu^.r)or(tu^.speed=0)then
               if(tu^.solid)and(sign(uf)=sign(tu^.uf))and(ud<sr)then _unit_push(pu,tu,ud);

             dec(ud,r+tu^.r);

             if(playeri=tu^.playeri)then
             begin
                if(state=ps_comp)then
                 if(_unit_aiC(pu,tu,ud))then continue;

                if(ud<melee_r)then
                 if(uo_tar=uc)or(tu^.uo_tar=unum)then
                  if(_itcanapc(pu,tu))then
                  begin
                     if(state=ps_comp)and(order<>1)then tu^.order:=order;
                     inc(apcc,tu^.apcs);
                     tu^.inapc:=unum;
                     tu^.tar1 :=0;
                     if(uo_tar=uc)then uo_tar:=0;
                     if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
                     {$IFDEF _FULLGAME}
                     PlaySND(snd_inapc,pu);
                     {$ENDIF}
                     _unit_desel(tu);
                  end;
             end;
          end
          else
            if(tu^.hits>dead_hits)then
            begin
               ud:=dist2(x,y,tu^.x,tu^.y);
               _udetect(pu,tu,ud);
               _unit_tardetect(pu,tu,ud);
            end;
       end;

      _unit_npush2(pu);

      {$IFDEF _FULLGAME}
      if(playeri=HPlayer)and(alrm_r<sr)and(alrm_b=false)then ui_addalrm(mmx,mmy,isbuild);
      {$ENDIF}

      case uidi of
      UID_Medic   : if(x=mv_x)and(y=mv_y)then
                     if(tar1=0)and(hits<mhits)then
                     begin
                        tar1 :=unum;
                        tar1d:=0;
                     end;
      end;

      {$IFDEF _FULLGAME}
      if(_testdmg=false)then
      {$ENDIF}
      if(state=ps_comp)then _unit_ai1(pu);
   end;
end;



procedure _unit_portalspawn(pu:PTUnit;uids:TSoB);
begin
   with pu^ do
   with player^ do
   if(rld_t=0)then
   begin
      repeat
         inc(rld_a,1);
         if(rld_a>255)or(rld_a<0)then rld_a:=0;
      until rld_a in uids;

      _unit_add(x,y,rld_a,playeri,true);

      if(_lcu>0)then
      begin
         _lcup^.buff[ub_teleeff]:=vid_fps;
         {$IFDEF _FULLGAME}
         PlaySND(snd_teleport,pu);
         _effect_add(_lcup^.x,_lcup^.y,_lcup^.y+map_flydpth[_lcup^.uf]+5,EID_Teleport);
         {$ENDIF}
      end;

      rld_t:=army;
   end;
end;



procedure _unit_code2(pu:PTUnit);
begin
   with pu^ do
   with player^ do
   begin
      if(onlySVCode)then
      begin
         {$IFDEF _FULLGAME}
         if(playeri=0)and(_testdmg)then
          if(sel)then
          begin
             if(k_shift>2)then _unit_desel(pu);

             x :=m_mx;
             y :=m_my;
             vx:=m_mx;
             vy:=m_my;

             _unit_mmcoords(pu);
             _unit_sfog(pu);

             if(hits<mhits)then
             begin
                bld_s :=mhits-hits;
                hits:=mhits;
             end;
          end;
         {$ENDIF}

         if(_uclord_c=_uclord)then
          case uidi of
          UID_HEye: if(hits>1)
                    then dec(hits,1)
                    else begin _unit_kill(pu,false,false);exit;end;
          end;

         if(isbuild)then
         begin
            if(menerg=0)
            then _unit_kill(pu,false,false)
            else
              if(bld=false)then
              begin
                 if(menerg<cenerg)
                 then _unit_kill(pu,false,false)
                 else
                   if(buff[ub_pain]=0)then
                   begin
                      {$IFDEF _FULLGAME}
                      if(_warpten)
                      then hits:=mhits
                      else
                      {$ENDIF}
                        if(_uclord_c<>_uclord)then exit;
                      inc(hits,bld_s);
                      if(upgr[upgr_advbld]>0)then inc(hits,bld_s);
                      if(hits>=mhits)then
                      begin
                         hits:=mhits;
                         bld :=true;
                         inc(ucl_eb[isbuild,ucl],1);
                         inc(uid_eb[uidi],1);

                         inc(menerg,generg);
                         dec(cenerg,_ulst[cl2uid[race,true,ucl]].renerg);

                         _unit_done_inc_cntrs(pu);
                      end;
                   end;
              end
              else
              begin
                 _unit_prod(pu);

                 //if(uidi=UID_CoopPortal)then _unit_portalspawn(pu,coopspawn);
              end;
         end;
      end;

      if(hits>0)and(bld)then
      begin
         if(isbuild)then
         if(ucl_x[ucl]=0)then ucl_x[ucl]:=unum;
         if(uid_x[uidi]=0)then uid_x[uidi]:=unum;
      end;
   end;
end; }

function _unit_target2weapon(pu,tu:PTUnit;ud:integer;cw:byte):byte;
var i:byte;
begin
   _unit_target2weapon:=255;
   if(ud<0)then ud:=dist2(pu^.x,pu^.y,tu^.x,tu^.y);
   with pu^ do
   with uid^ do
   with player^ do
   for i:=0 to min2(cw,MaxUnitWeapons) do
   with _a_weap[i] do
   begin
      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0)then continue;
      if(aw_rupgr>0)and(upgr  [aw_rupgr] =0)then continue;

      // requirements to attacker

      if(cf(@aw_reqf,@wpr_adv ))and(buff[ub_advanced]<=0)then continue;
      if(cf(@aw_reqf,@wpr_nadv))and(buff[ub_advanced]> 0)then continue;

      if not(tu^.uidi in aw_uids)then continue;

      // requirements to target

      if(cf(@aw_tarf,@wtr_owner_p ))and (playeri<>tu^.playeri       )then continue;
      if(cf(@aw_tarf,@wtr_owner_a ))and (team   <>tu^.player^.team  )then continue;
      if(cf(@aw_tarf,@wtr_owner_e ))and (team   = tu^.player^.team  )then continue;

      if(cf(@aw_tarf,@wtr_hits_h  ))and((tu^.hits<=0)
                                      or(tu^.uid^._mhits<=tu^.hits ))then continue;
      if(cf(@aw_tarf,@wtr_hits_d  ))and (tu^.hits> 0                )then continue;
      if(cf(@aw_tarf,@wtr_hits_a  ))and (tu^.hits<=0                )then continue;

      if(cf(@aw_tarf,@wtr_bio     ))and (tu^.uid^._ismech           )then continue;
      if(cf(@aw_tarf,@wtr_mech    ))and (tu^.uid^._ismech=false     )then continue;
      if(cf(@aw_tarf,@wtr_building))and (tu^.uid^._isbuilding       )then continue;

      if(cf(@aw_tarf,@wtr_bld     ))and (tu^.bld=false              )then continue;
      if(cf(@aw_tarf,@wtr_nbld    ))and (tu^.bld                    )then continue;

      if(cf(@aw_tarf,@wtr_ground  ))and (tu^.uf<>uf_ground          )then continue;
      if(cf(@aw_tarf,@wtr_soaring ))and (tu^.uf<>wtr_soaring        )then continue;
      if(cf(@aw_tarf,@wtr_fly     ))and (tu^.uf<>wtr_fly            )then continue;

      if(cf(@aw_tarf,@wtr_adv     ))and (tu^.buff[ub_advanced]<=0   )then continue;
      if(cf(@aw_tarf,@wtr_nadv    ))and (tu^.buff[ub_advanced]> 0   )then continue;

      _unit_target2weapon:=i;
      break
   end;
end;


procedure _unit_target(pu,tu:PTUnit;ud:integer;t_weap:pbyte);
var tw:byte;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      tw:=_unit_target2weapon(pu,tu,ud,t_weap^);

      if(tw>MaxUnitWeapons)then exit;

      if(tw>t_weap^)
      then exit
      else
        if(tw<t_weap^)
        then
        else
          if(ud>a_tard)then exit;

      t_weap^:=tw;
      a_tar  :=tu^.unum;
      a_tard :=ud;
   end;
end;

procedure _unit_mcycle(pu:PTUnit);
var uc,
    ud: integer;
    tu: PTUnit;
ftarget,
  push: boolean;
t_weap: byte;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      a_tar   := 0;
      a_tard  := 32000;
      t_weap  := 255;

      if(_isbuilding)and(menerg<=0)then
      begin
         _unit_kill(pu,false,false);
         exit;
      end;

      push    := solid and _canmove(pu);
      ftarget := _canattack(pu);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=@_units[uc];
         if(tu^.hits>fdead_hits)then
         begin
            ud:=dist2(x,y,tu^.x,tu^.y);
            _unit_detect(pu,tu,ud);

            if(ftarget)then  _unit_target(pu,tu,ud,@t_weap);

            if(tu^.hits>0)then
            begin
               if(push)then
                if(_r<=tu^.uid^._r)or(tu^.speed<=0)then
                 if(tu^.solid)and((uf=uf_ground)=(tu^.uf=uf_ground))then _unit_push(pu,tu,ud);

               //dec(ud,r+tu^.r);
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
var uc,
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

      if(_IsUnitRange(inapc))then
      begin
         if(_units[inapc].inapc>0)then exit;
         vsnt   :=_units[inapc].vsnt;
         udetect:=false;
      end
      else udetect:=true;

      if(udetect=false)and(udetect=ftarget)then exit;  // in apc & client side

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=@_units[uc];
         if(tu^.hits>fdead_hits)then
         begin
            ud:=dist2(x,y,tu^.x,tu^.y);
            if(udetect)then _unit_detect(pu,tu,ud);
            if(ftarget)then _unit_target(pu,tu,ud,@t_weap);
         end;
      end;

      {$IFDEF _FULLGAME}
      //if(playeri=HPlayer)and(alrm_r<srange)and(alrm_b=false)then ui_addalrm(mmx,mmy,_isbuilding);
      {$ENDIF}
   end;
end;
{
procedure _unit_code1_n(pu:PTUnit);
var uc,
    ud:integer;
    tu:PTUnit;
begin
   with pu^ do
   begin
      if(alrm_r<0)
      then alrm_r:=0
      else alrm_r:=32000;

      tar1d   := 32000;
      tar1    := 0;
      tar1p   := 0;

      if(0<inapc)and(inapc<=MaxUnits)then
      begin
         if(_units[inapc].inapc>0)then exit;
         vsnt:=_units[inapc].vsnt;

         if(OnlySVCode)then
         case uidi of
         UID_Engineer: begin
                          tu:=@_units[inapc];
                          if(tu^.buff[ub_pain]=0)then
                           if(tu^.hits<tu^.mhits)then
                           begin
                              tar1 :=inapc;
                              tar1d:=0;
                              tar1p:=11;
                           end;
                       end;
         end;
      end;

      for uc:=1 to MaxUnits do
       if(uc<>unum)then
       begin
          tu:=@_units[uc];
          if(tu^.hits>dead_hits)then
          begin
             ud:=dist2(x,y,tu^.x,tu^.y);
             if(inapc=0)then _udetect(pu,tu,ud);
             if(tu^.hits>0)and(tu^.inapc=0)then _unit_tardetect(pu,tu,ud);
          end;
       end;

      {$IFDEF _FULLGAME}
      if(playeri=HPlayer)and(alrm_r<sr)and(alrm_b=false)then ui_addalrm(mmx,mmy,isbuild);
      {$ENDIF}
   end;
end;
}


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

{procedure _unit_uo_tar(pu:PTUnit);
var tu: PTUnit;
td,tdm: integer;
teams : boolean;
begin
   with pu^ do
   with uid^ do
   begin
      if(uo_tar=unum)then uo_tar:=0;
      if(_IsUnitRange(uo_tar))and(inapc=0)then
      begin
         tu:=@_units[uo_tar];
         if(_IsUnitRange(tu^.inapc))then
         begin
            uo_tar:=0;
            exit;
         end;

         td :=dist2(x,y,tu^.x,tu^.y);
         tdm:=td-(_r+tu^.uid^._r);

         if(playeri=tu^.playeri)then
         begin
            {/// HELL ADV
            if(uidi=UID_HMonastery)and(tu^.isbuild=false)then
            begin
               with player^ do
                if(tu^.buff[ub_advanced]<=0)and(bld)and(upgr[upgr_6bld]>0)and(buff[ub_advanced]>0)then
                begin
                   dec(upgr[upgr_6bld],1);
                   tu^.buff[ub_advanced]:=_bufinf;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(tu,snd_hupgr);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            if(tu^.uidi=UID_HMonastery)and(isbuild=false)then
            begin
               with player^ do
                if(buff[ub_advanced]=0)and(tu^.bld)and(upgr[upgr_6bld]>0)then
                begin
                   dec(upgr[upgr_6bld],1);
                   buff[ub_advanced]:=_bufinf;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(pu,snd_hupgr);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            // UAC ADV
            if(tu^.uidi=UID_UVehicleFactory)and(isbuild=false)then
             if(tdm<=melee_r)and(tu^.rld_t=0)then
             begin
                uo_x  :=x;
                uo_y  :=y;
                uo_tar:=0;
                if(tu^.buff[ub_advanced]>0)and(tu^.bld)and(buff[ub_advanced]<=0)then
                begin
                   _unit_UACUpgr(pu,tu);
                   uo_x  :=tu^.uo_x;
                   uo_y  :=tu^.uo_y;
                   uo_tar:=tu^.uo_tar;
                end;
                exit;
             end;
            // PROD ADV
            if(uidi in [UID_HFortress,UID_UNuclearPlant])then
             if(tu^.buff[ub_advanced]<=0)and(tu^.bld)and(rld_t<=0)then
              if(tu^.isbarrack)or(tu^.issmith)then
              begin
                 _unit_start_prod_adv(tu);
                 with player^ do
                  rld_t :=advprod_rld[upgr[upgr_9bld]>0];
                 uo_x  :=x;
                 uo_y  :=y;
                 uo_tar:=0;
                 exit;
              end;
            /// HELL INVULN
            if(uidi=UID_HAltar)and(tu^.isbuild=false)then
            begin
               with player^ do
                if(tu^.buff[ub_invuln]=0)and(bld)and(upgr[upgr_hinvuln]>0)then
                begin
                   dec(upgr[upgr_hinvuln],1);
                   tu^.buff[ub_invuln]:=hinvuln_time;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(tu,snd_hpower);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            if(tu^.uidi=UID_HAltar)and(isbuild=false)then
            begin
               with player^ do
                if(buff[ub_invuln]=0)and(tu^.bld)and(upgr[upgr_hinvuln]>0)then
                begin
                   dec(upgr[upgr_hinvuln],1);
                   buff[ub_invuln]:=hinvuln_time;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(pu,snd_hpower);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end; }
         end;

         teams:=(player^.team=tu^.player^.team);

         if(teams=false)then
          if(_uvision(player^.team,tu,false)=false)then
          begin
             uo_tar:=0;
             exit;
          end
          else
          begin
             a_tar:=uo_tar;
             uo_id:=ua_amove;
          end;

         if(_move2uotar(pu,tu,td))then
         begin
            uo_x:=tu^.vx;
            uo_y:=tu^.vy;
         end;

         {if(teams)then
          if(tu^.uidi=UID_HTeleport)and(tu^.bld)and(isbuild=false)then
           if(td<=tu^.r)then
           begin
              if(dist2(x,y,tu^.uo_x,tu^.uo_y)>tu^.sr)and(tu^.rld_t=0) then
              begin
                 if(uf=uf_ground)then
                  if(tu^.buff[ub_cnttrans]>0)
                  then exit
                  else
                    if(_unit_OnDecorCheck(tu^.uo_x,tu^.uo_y))then exit;

                 _unit_teleport(pu,tu^.uo_x,tu^.uo_y);
                 _teleport_rld(tu,mhits);
                 exit;
              end;
           end
           else
             if(tu^.buff[ub_advanced]>0)and(td>base_rr)then
              if(tu^.rld_t=0)then
              begin
                 _unit_teleport(pu,tu^.x,tu^.y);
                 _teleport_rld(tu,mhits);
                 exit;
              end
              else
              begin
                 uo_x:=x;
                 uo_y:=y;
              end; }
      end;
   end;
end; }

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
      if(_IsUnitRange(uo_tar))then
      begin
         tu:=@_units[uo_tar];
         if(_IsUnitRange(tu^.inapc))then
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
            // advancing & altar invuln
         end;

         w:=_unit_target2weapon(pu,tu,td,255);
         if(w<=MaxUnitWeapons)then
         begin
            a_tar :=uo_tar;
            a_tard:=td;
            uo_id :=ua_amove;
         end;

         if(_move2uotar(pu,tu,td))then
         begin
            uo_x:=tu^.vx;
            uo_y:=tu^.vy;
         end;

         if(_isbuilding=false)and(tu^.hits>0)and(tu^.bld)and(tu^.uid^._ability=uab_teleport)then
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
                 exit;
              end;
           end
           else
             if(tu^.buff[ub_advanced]>0)and(td>base_rr)then
              if(tu^.rld<=0)then
              begin
                 _unit_teleport(pu,tu^.x,tu^.y);
                 _teleport_rld(tu,_mhits);
                 exit;
              end
              else
              begin
                 uo_x:=x;
                 uo_y:=y;
              end;
      end;
   end;
end;

procedure _unit_attack(pu:PTUnit);
var w:byte;
begin
   with pu^ do
   begin
      if(_IsUnitRange(a_tar)=false)then exit;

      w:=_unit_target2weapon(pu,@_units[a_tar],a_tard,255);


   end;
end;

procedure _unit_order(pu:PTUnit);
var tu:PTUnit;
    td:integer;
    i :byte;
begin
   with pu^ do
   begin

      if(ServerSide=false)
      then //attack procedure
      else
      begin
         if(_IsUnitRange(inapc)=false)then
         begin
            _unit_uo_tar(pu);

            mv_x:=uo_x;
            mv_y:=uo_y;

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

             if(buff[ub_stopattack]>0)then
             begin
                mv_x:=x;
                mv_y:=y;
            end;
         end;
         if(uo_id=ua_amove)then _unit_attack(pu);
      end;
   end;
end;


     { //_unit_uo_tar(pu);
      mv_x:=uo_x;
      mv_y:=uo_y;

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

       if(buff[ub_stopafa]>0)then
       begin
          mv_x:=x;
          mv_y:=y;
       end;

      {tar1d:=32000;
      if(0<tar1)and(tar1<=MaxUnits)then
      begin
         tu:=@_units[tar1];
         td:=dist2(x,y,tu^.x,tu^.y);
         i :=_unit_target(pu,tu,td,false);
         if(onlySVCode)then
           case i of
         0 : tar1 :=0;
         1 : begin
                mv_x :=tu^.x;
                mv_y :=tu^.y;
                tar1d:=td;
             end;
         2,3
           : begin
                tar1d:=td;
                melee:=(i=3);
                if(_canattack(pu))then _unit_attack(pu);
                if(inapc>0)then exit;
                if(tar1=uo_tar)then
                begin
                   uo_x:=x;
                   uo_y:=y;
                end
                else
                  if(tar1<>unum)then
                   case uidi of
                   UID_Flyer : if(buff[ub_advanced]>0)then exit;
                   UID_APC,
                   UID_FAPC,
                   UID_UCommandCenter,
                   UID_HCommandCenter: exit;
                   else
                   end;
                mv_x :=x;
                mv_y :=y;
                if(x<>tu^.x)or(y<>tu^.y)then dir:=p_dir(x,y,tu^.x,tu^.y);
                if(rld_t>0)and(buff[ub_stopafa]=0)then
                 if(_uclord_p>rld_t)
                 then buff[ub_stopafa]:=_uclord_p
                 else buff[ub_stopafa]:=rld_t;
             end;
           end
         else
           case i of
          2,3
            : begin
                 tar1d:=td;
                 melee:=(i=3);
                 if(_canattack(pu))then _unit_attack(pu);
                 if(inapc>0)then exit;
                 if(tar1<>unum)then
                  case uidi of
                  UID_Flyer : if(buff[ub_advanced]>0)then exit;
                  UID_APC,
                  UID_FAPC,
                  UID_UCommandCenter,
                  UID_HCommandCenter: exit;
                  else
                  end;
                 if(x<>tu^.x)or(y<>tu^.y)then dir:=p_dir(x,y,tu^.x,tu^.y);
              end;
           end;  }  }

procedure _unit_prod(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(bld)then
      begin
         if(rld>0)then dec(rld,1);

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
                inc(hits,_bstep);
                inc(hits,_bstep*upgr[upgr_fast_build]);
             end;

             if(hits>=_mhits){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
             begin
                hits:=_mhits;
                bld :=true;
                _unit_bld_inc_cntrs(pu);
                inc(cenerg,_renerg);
                {$IFDEF _FULLGAME}
                if(_isbuilding)and(playeri=HPlayer)then PlayInGameAnoncer(snd_constr_complete[_urace]);
                {$ENDIF}
             end;
          end;
   end;
end;

procedure _unit_nfog(pu:PTUnit);
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
         _unit_nfog(pu);

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




