
procedure _unit_movevis(pu:PTUnit);
begin
   with(pu^)do
    if(vx<>x)or(vy<>y)then
     if(speed=0)or(inapc>0)then
     begin
        vstp:=0;
        vx  :=x;
        vy  :=y;
     end
     else
     begin
        if(vstp=0)then vstp:=UnitStepNum;
        Inc(vx,(x-vx) div vstp);
        Inc(vy,(y-vy) div vstp);
        dec(vstp,1);
     end;
end;

procedure _unit_move(pu:PTUnit);
var mdist:integer;
    tu:PTUnit;
begin
  with(pu^)do
  if(bld)then
  with(puid^)do
   if(inapc>0)then
   begin
      tu    :=@_units[inapc];
      x     :=tu^.x;
      y     :=tu^.y;
      {$IFDEF _FULLGAME}
      mmx   :=tu^.mmx;
      mmy   :=tu^.mmy;
      fx    :=tu^.fx;
      fy    :=tu^.fy;
      {$ENDIF}
   end
   else
     if(onlySVCode)then
      if(_canmove(pu))then
       if(x=vx)and(y=vy)then
        if(x<>mv_x)or(y<>mv_y)then
        begin
           mdist:=dist2(x,y,mv_x,mv_y);
           if(mdist<=speed)then
           begin
              x:=mv_x;
              y:=mv_y;
              mdir:=p_dir(vx,vy,x,y);
           end
           else
           begin
              if(mdist>70)
              then mdist:=8+random(25)
              else mdist:=60;

              mdir:=dir_turn(mdir,p_dir(x,y,mv_x,mv_y),mdist);

              x:=x+round(speed*cos(mdir*degtorad));
              y:=y-round(speed*sin(mdir*degtorad));
           end;
           if(_uf=uf_ground)and(_solid)then _unit_npush(pu);
           _unit_correctcoords(pu);
           {$IFDEF _FULLGAME}
           _unit_sfog(pu);
           _unit_mmcoords(pu);
           {$ENDIF}
        end;
end;

procedure _udetect(pu,tu:PTUnit;ud:integer);
begin
   with (pu^) do
   with (puid^) do
   begin
      if(ud<=(tu^.srng+_r))then
      begin
         if(buff[ub_invis]=0)
         then _addtoint(@vsnt[_players[tu^.player].team],vid_fps)
         else
           if(tu^.buff[ub_detect]>0)and(tu^.bld)then
           begin
              _addtoint(@vsnt[_players[tu^.player].team],vid_fps);
              _addtoint(@vsni[_players[tu^.player].team],vid_fps);
           end;
       end;
   end;
end;

procedure _unit_auto_enemy(pu,tu:PTUnit;ud:integer;awp:pbyte;aad:pinteger);
var awpc:byte;
begin
   with (pu^) do
    with _players[player] do
     if(_uvision(team,tu))then
     begin
        awpc:=_attackweap(pu,tu);

        if(awpc>MaxAttacks)or(awpc>awp^)then exit;

        with puid^ do
        with _a_weap[awpc] do
         case aw_order of
           0         : exit;
           uo_attack : if(uo_id[0]<>uo_attack)then
                        if(aattack=false)then exit;
         else
           if(tu^.inapc<>inapc)then exit;
           if(uo_id[0]=uo_attack)then exit;
           if(aorder<>aw_order)then exit;
         end;

        if(_canattacktar(pu,tu,false,awpc,ud)>0)then
         if(awp^<>awpc)then
         begin
            aad^ :=ud;
            a_tar:=tu^.unum;
            awp^ :=awpc;
         end
         else
           if(ud<aad^)then
           begin
              aad^ :=ud;
              a_tar:=tu^.unum;
           end;
     end;
end;

procedure _unit_code1_n(pu:PTUnit);
var aad,
    uc,
    ud : integer;
    awp: byte;
    tu,
    apc: PTUnit;
begin
   with (pu^) do
   with (puid^) do
   with _players[player] do
   begin
      apc:=@_units[inapc];
      if(apc^.inapc>0)then exit;

      vsnt:=apc^.vsnt;

      if(uclord=_uclord_c)then
      begin
         aad   :=32000;
         awp   :=255;
         a_tar :=0;

         if(_canattack(pu)=false)then exit;

         if(apc^.a_tar>0)then
         begin
            if(_target_check(pu,@_units[apc^.a_tar])<=MaxAttacks)then a_tar:=apc^.a_tar;
            exit;
         end;

         if(apc^.aattack=false)then exit;

         for uc:=1 to MaxUnits do
         begin
            tu:=@_units[uc];
            if(tu^.hits<=idead_hits)then continue;
            if(tu^.inapc>0)then
            begin
               if(tu^.inapc<>inapc)
               then continue
               else ud:=0;
            end
            else ud:=dist2(x,y,tu^.x,tu^.y);

            _unit_auto_enemy(pu,tu,ud,@awp,@aad);
         end;
      end;
   end;
end;

procedure _unit_code1(pu:PTUnit);
var uc,
    ud,
   aad : integer;
    tu : PTUnit;
   awp : byte;
_aatta,
_cnmv  : boolean;
begin
   with (pu^) do
   with (puid^) do
   with _players[player] do
   if(uclord=_uclord_c)then
   begin
      _cnmv :=_canmove(pu);
      aad   :=32000;
      a_tar :=0;
      awp   :=255;

      _aatta:=false;
      if(_canattack(pu))then
       if(uo_id[0]<>uo_attack)
       then _aatta:=(_toids[uo_id[0]].cattack)and(aattack or (aorder>0))
       else
         if(uo_tar[0]=0)then _aatta:=true;

      for uc:=1 to MaxUnits do
      begin
         tu:=@_units[uc];

         if(tu^.hits<=idead_hits)then continue;

         if(uc<>unum)then
         begin
            ud:=dist2(x,y,tu^.x,tu^.y);
            _udetect(pu,tu,ud);
         end
         else ud:=0;

         if(tu^.inapc>0)or(bld=false)then continue;

         if(_aatta)then _unit_auto_enemy(pu,tu,ud,@awp,@aad);

         if(_cnmv)and(tu^.hits>0)and(uc<>unum)then
          if(_r<=tu^.puid^._r)or(tu^.speed=0)then
           if(tu^.puid^._solid)and(_solid)and(sign(uf)=sign(tu^.uf))then _unit_push(pu,tu,ud);
       end;

      if(speed>0)and(_uf=uf_ground)and(_solid)then _unit_npush(pu);
   end;
end;

procedure _unit_code2(pu:PTUnit);
begin
   with (pu^) do
   with (puid^) do
   with _players[player] do
   begin
      _unit_upgr(pu);

      if(bld)then
      begin
         if(un_r>0)then
          if(menerg<cenerg)or(army>=MaxPlayerUnits)
          then _unit_cunt(pu)
          else
          begin
             dec(un_r,1);
             if(_warpten)then un_r:=0;
             if(un_r=0)then
             begin
                _barrack_spawn(pu,un_t);
                un_r:=1;
                _unit_cunt(pu);
             end;
          end;

         if(up_r>0)then
          if(menerg<cenerg)
          then _unit_cupt(pu)
          else
          begin
             dec(up_r,1);
             if(_warpten)then up_r:=0;
             if(up_r=0)then
             begin
                inc(upgr[up_t],1);
                up_r:=1;
                _unit_cupt(pu);
             end;
          end;
      end
      else
      begin
         if(menerg<cenerg)
         then _unit_kill(pu,false,false)
         else
           if(uclord=_uclord_c)then
           begin
              if(buff[ub_pain]=0)then inc(hits,_bldstep);
              if(hits>_mhits)or(_warpten)then hits:=_mhits;
              if(hits=_mhits)then
              begin
                 bld:=true;
                 _unit_bldcntinc(pu);
                 dec(cenerg,_renerg);
                 inc(menerg,_generg);
                 _unit_unload(pu);
                 buff[ub_born]:=vid_h2fps;
                 {$IFDEF _FULLGAME}
                 _ueff_create(pu);
                 {$ENDIF}
              end;
           end;
      end;
   end;
end;

procedure _unit_death(pu:PTUnit);
begin
   with (pu^) do
   with (puid^) do
    with _players[player] do
    begin
       if(buff[ub_resur]=0)then
       begin
          {$IFDEF _FULLGAME}
          if(uclord=_uclord_c)and(fsr>0)then dec(fsr,1);
          {$ENDIF}
          if(OnlySVCode)then
          begin
             if(uf>uf_ground)then
              if(zfall<_zfall)then
              begin
                 inc(zfall,1);
                 if(y<map_mw)then
                 begin
                    inc(y,1);
                    inc(vy,1);
                 end;
              end;
             dec(hits,1);
             if(hits<=dead_hits)then
             begin
                _unit_remove(pu);
                exit;
             end;
          end;
       end
       else
        if(OnlySVCode)then
        begin
           if(uf>uf_ground)then
           begin
              if(hits<=rdead_hits)then
              begin
                 hits:=rdead_hits;
                 zfall:=0;
              end;
              if(zfall<_zfall)then
              begin
                 inc(zfall,1);
                 if(y>0)then
                 begin
                    dec(y,1);
                    dec(vy,1);
                 end;
              end;
           end;

           inc(hits,1);
           if(hits>=0)then
           begin
              uo_n     :=0;
              uo_id [0]:=0;
              uo_tar[0]:=0;
              uo_x  [0]:=x;
              uo_y  [0]:=y;
              mdir   :=270;
              tdir   :=270;
              hits   :=_mhits;
              zfall  :=0;
              buff[ub_resur]:=0;
              buff[ub_born ]:=vid_h2fps;
              {$IFDEF _FULLGAME}
              _unit_clfog(pu);
              if(player=HPlayer)then _ueff_create(pu);
              {$ENDIF}
           end;
        end;
    end;
end;


procedure _obj_cycle;
var u : integer;
   pu : PTUnit;
begin
   for u:=1 to MaxUnits do
    with _units[u] do
     if(hits>dead_hits)then
     begin
        pu:=@_units[u];
        if(hits>0)then
        begin
           _unit_think   (pu);
           _unit_counters(pu);
           _unit_movevis (pu);
           _unit_move    (pu);
           if(onlySVCode)then
           begin
              if(inapc=0)then
              begin
                 _unit_code1(pu);
                 _unit_code2(pu);
              end
              else _unit_code1_n(pu);
           end
           else _unit_upgr(pu);
        end
        else
        begin
           _unit_movevis (pu);
           _unit_counters(pu);
           _unit_death   (pu);
        end;
     end;

   _missileCycle;
end;


