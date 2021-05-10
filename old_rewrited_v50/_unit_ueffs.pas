
/////////////////////////////////////////////////////////////////////////////////
////
////   UNIT EFFECTS
////
////////

{
_ueff2snd - main sounds
_ueffeid  - additional effect
_ueffeid  - additional terrain effect
_ueffeids - effect sound
}

procedure _ueff_eff(pu:PTUnit;efft:byte;adv,mainsnd:boolean);
begin
   with (pu^) do
   begin
      if(mainsnd)then PlayUSND(_ueff2snd(uid,efft,adv),pu);
      with puid^ do
      begin
         PlayUSND(_ueffeids[adv,efft],pu);
         _effect_uadd(pu,_ueffeid1[adv,efft]);
         _effect_uadd(pu,_ueffeid2[adv,efft],-5);
      end;
   end;
end;

procedure _ueff_create(pu:PTUnit);
begin
   with (pu^) do
    if(bld=false)
    then _ueff_eff(pu,ueff_startb,buff[ub_advanced]>0,(player=HPlayer))
    else _ueff_eff(pu,ueff_create,buff[ub_advanced]>0,(player=HPlayer));
end;

procedure _ueff_foot(pu:PTUnit);
begin
   with (pu^) do
   begin
      if(foota>0)
      then dec(foota,1)
      else
      begin
         _ueff_eff(pu,ueff_foot,buff[ub_advanced]>0,true);
         foota:=puid^._foota;
      end;
   end;
end;

procedure _ueff_pain(pu:PTUnit);
begin
   with (pu^) do _ueff_eff(pu,ueff_pain,buff[ub_advanced]>0,true);
end;

procedure _ueff_death(pu:PTUnit;fd:boolean);
begin
   with (pu^) do
    if(fd)
    then _ueff_eff(pu,ueff_fdeath,buff[ub_advanced]>0,true)
    else _ueff_eff(pu,ueff_death ,buff[ub_advanced]>0,true);
end;

/////////////////////////////////////////////////////////////////////////////////
////
////   MISSILE EFFECTS
////
////////

procedure _missile_effect(m:integer);
var i :byte;
    d,
    sl:integer;
begin
   with _missiles[m] do
   begin
      with _players[HPlayer] do
       if(_nhp3(vx,vy,team)=false)then exit;

      d :=map_flydpth[mf]+vy;
      sl:=sr*2;
      for i:=1 to _meeffn do _effect_add(vx-sr+random(sl),vy-sr+random(sl),d,_meeff);

      case _mesndc of
      0  : ;
      1  : PlayUSND(_mesnd);
      else if(random(_mesndc)=0)then PlayUSND(_mesnd);
      end;
   end;
end;


