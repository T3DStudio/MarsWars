

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
         if(_isbuilding)then build_cd:=min2(build_cd+fr_3fps,max_build_reload);
         {if(_zfall>0)and(uf>uf_ground)then zfall:=_zfall;
         if(_zfall<0)and(uf=uf_ground)then zfall:=_zfall;}
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
               if(uidi in [UID_UCTurret,UID_UPTurret,UID_URTurret])then
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

         case g_mode of
gm_inv    : if(playeri=0)then dam:=dam div 2;
         end;
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
              if(uidi=UID_Mancubus)and(buff[ub_advanced]>0)then exit;

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
   with pu^ do
   if(bld)then
   with uid^ do
   if(apcc>0)
   then uo_id:=ua_unload
   else
     with player^ do
     case _ability of
uab_spawnlost: ;
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
UID_HMilitaryUnit,
UID_UWeaponFactory,
UID_HPools,
UID_UMilitaryUnit,
UID_HGate    : if(ucl_eb[true,9]>0)then
               begin
                  if(ucl_x[9]<=0)or(MaxUnits<ucl_x[9])then exit;

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
      then dec(ud,tu^.uid^._r   )
      else dec(ud,tu^.uid^._r+_r);

      if(ud<0)then
      begin
         if(tu^.x=x)and(tu^.y=y)then
         begin
            inc(x,_randomr(2));
            inc(y,_randomr(2));
         end
         else
         begin
            if(t<=0)then t:=1;
            inc(x,trunc(ud*(tu^.x-x)/t));
            inc(y,trunc(ud*(tu^.y-y)/t));
         end;

         vstp:=UnitStepNum;

         _unit_correctcoords(pu);
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
      dec(ud,_r+td^.r-8);

      if(ud<0)then
      begin
         if(td^.x=x)and(td^.y=y)then
         begin
            inc(x,_randomr(2));
            inc(y,_randomr(2));
         end
         else
         begin
            if(t<=0)then t:=1;
            inc(x,trunc(ud*(td^.x-x)/t));
            inc(y,trunc(ud*(td^.y-y)/t));
         end;

         vstp:=UnitStepNum;

         _unit_correctcoords(pu);
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


      {$ENDIF}
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
             {if(uidi=UID_UTransport)and(buff[ub_pain]>0)then dec(spup,2);
             with player^ do
             begin
                if(race=r_uac)and(isbuild=false)then
                 case mech of
                 true : if(upgr[upgr_mechspd]>0)then inc(spup,upgr[upgr_mechspd]);
                 false: if(upgr[upgr_mspeed ]>0)then inc(spup,upgr[upgr_mspeed ]);
                 end;
             end; }

             if(mdist>70)
             then mdist:=8+_random(25)
             else mdist:=50;

             dir:=dir_turn(dir,p_dir(x,y,mv_x,mv_y),mdist);

             ddir:=dir*degtorad;
             x:=x+trunc(ss*cos(ddir));
             y:=y-trunc(ss*sin(ddir));
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

      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0)then exit;
      if(aw_rupgr>0)and(upgr  [aw_rupgr] =0)then exit;

      // requirements to attacker and some flags

      if not(tu^.uidi in aw_uids)then exit;

      if(cf(@aw_reqf,@wpr_adv ))and(buff[ub_advanced]<=0)then exit;
      if(cf(@aw_reqf,@wpr_nadv))and(buff[ub_advanced]> 0)then exit;

      if(cf(@aw_reqf,@wpr_zombie))then
       if(tu^.bld=false)
       or(tu^.uid^._zombie_uid=0)
       or(hits>tu^.uid^._zombie_hits)then exit;

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

      if(awr<0)
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
        then
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
   with pu^ do
   with uid^ do
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
                        dec(apcc,tu^.uid^._apcs);
                        tu^.inapc:=0;
                        tu^.x    :=x-_random(_r);
                        tu^.y    :=y-_random(_r);
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

               if(push)then
                if(_r<=tu^.uid^._r)or(tu^.speed<=0)then
                 if(tu^.solid)and((uf=uf_ground)=(tu^.uf=uf_ground))then _unit_push(pu,tu,ud);

               dec(ud,_r+tu^.uid^._r);

               if(player=tu^.player)then
               begin

                  if(ud<melee_r)then
                   if(uo_tar=uc)or(tu^.uo_tar=unum)then
                    if(_itcanapc(pu,tu))then
                    begin
                       //if(state=ps_comp)and(order<>1)then tu^.order:=order;
                       inc(apcc,tu^.uid^._apcs);
                       tu^.inapc:=unum;
                       tu^.a_tar:=0;
                       if(    uo_tar=uc  )then     uo_tar:=0;
                       if(tu^.uo_tar=unum)then tu^.uo_tar:=0;
                       _unit_desel(tu);
                       {$IFDEF _FULLGAME}
                       PlaySND(snd_inapc,pu);
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

procedure _unit_uac_unit_adv(pu,tu:PTUnit);
begin
   with pu^ do
   with uid^ do
   begin
      buff[ub_gear    ]:=gear_time[_ismech];
      buff[ub_advanced]:=_ub_infinity;
      tu^.rld:=uac_adv_rel[_ismech,(g_addon=false)or(tu^.player^.upgr[upgr_uac_6bld2]>0)];
      {$IFDEF _FULLGAME}
      PlaySND(snd_uac_reload,pu);
      {$ENDIF}
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
uab_uac_unit_adv:
            if(tdm<=speed)and(tu^.rld<=0)and(_isbuilding=false)then
            begin
               if(tu^.buff[ub_advanced]>0)and(tu^.bld)and(buff[ub_advanced]<=0)then _unit_uac_unit_adv(pu,tu);
               uo_x  :=tu^.uo_x;
               uo_y  :=tu^.uo_y;
               uo_tar:=tu^.uo_tar;
            end;
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
var w,a:byte;
   tu:PTUnit;
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
            a_tar:=0;
            exit;
         end;

         a_weap:=w;
      end
      else
      begin
         a:=_target_weapon_check(pu,tu,-1,a_weap,true,false);
         if(a=0)then
         begin
            a_tar:=0;
            exit;
         end;
      end;

      if(ServerSide)then
      case a of
      0: exit;
      1: begin
         mv_x:=tu^.x;
         mv_y:=tu^.y;
         exit;
         end;
      else
         mv_x:=x;
         mv_y:=y;
      end;

      // attack code
      with uid^ do
      with _a_weap[a_weap] do
      begin
         if(a_rld=0)then
         begin
            a_rld:=aw_rld;
            dir:=p_dir(x,y,uo_x,uo_y);
            {$IFDEF _FULLGAME}
            PlaySND(aw_snd,pu);
            {$ENDIF}
            if(ServerSide)then
            buff[ub_stopattack]:=max2(aw_rld,_uclord_p);
         end;

         if(a_rld in aw_rld_s)then
         begin
            dir:=p_dir(x,y,mv_x,mv_y);
            case aw_type of
wpt_missle     : _missile_add(tu^.x,tu^.y,vx,vy,a_tar,aw_oid,playeri,uf,false);
wpt_unit       : with player^ do
                 if((army+uproda)>=MaxPlayerUnits)then
                 begin
                    // dead effect
                 end
                 else
                   if(ServerSide)then
                   begin
                   end;
            else
               if(ServerSide)then
               case aw_type of
wpt_resurect : begin
               tu^.buff[ub_resur]:=fr_2fps;
               tu^.zfall:=-tu^.uid^._zfall;
               end;
wpt_heal     : if(tu^.hits>0)then tu^.hits:=min2(tu^.hits+aw_count,tu^.uid^._mhits);
wpt_directdmg: _unit_damage(tu,aw_count,2,playeri);
               end;
            end;
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
      begin
         mv_x:=x;
         mv_y:=y;
      end;
   end;
end;


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




