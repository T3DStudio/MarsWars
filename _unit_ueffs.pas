
procedure _ueff_eff(pu:PTUnit;efft:byte;adv:boolean);
begin
   with (pu^) do
   begin
      PlayUSND(_ueff2snd(uid,efft,adv),pu);
      with puid^ do
      begin
         PlayUSND(_ueffeids[adv,efft],pu);
         _effect_uadd(pu,_ueffeid[adv,efft]);
      end;
   end;
end;

procedure _ueff_create(pu:PTUnit);
begin
   with (pu^) do
   begin
      if(_menu=false)then
       if(bld=false)then
       begin
          if(player=HPlayer)then PlayUSND(_ueff2snd(uid,ueff_startb,buff[ub_advanced]>0));
          _ueff_eff(pu,ueff_startb,buff[ub_advanced]>0);
       end
       else
       begin
          if(player=HPlayer)then PlayUSND(_ueff2snd(uid,ueff_create,buff[ub_advanced]>0));
          _ueff_eff(pu,ueff_create,buff[ub_advanced]>0);
       end;
   end;
end;

procedure _ueff_foot(pu:PTUnit);
begin
   with (pu^) do
   begin
      if(foota>0)
      then dec(foota,1)
      else
      begin
         PlayUSND(_ueff2snd(uid,ueff_foot,buff[ub_advanced]>0),pu);
         _ueff_eff(pu,ueff_foot,buff[ub_advanced]>0);
         foota:=puid^._foota;
      end;
   end;
end;

procedure _ueff_pain(pu:PTUnit);
begin
   with (pu^) do
   begin
      PlayUSND(_ueff2snd(uid,ueff_pain,buff[ub_advanced]>0),pu);
      _ueff_eff(pu,ueff_pain,buff[ub_advanced]>0);
   end;
end;

{procedure _unit_effect(pu:PTUnit;efft:byte;alt:boolean=false);
begin
   with (pu^) do
   begin
      case efft of
      ueff_startb,
      ueff_create  : buff[ub_born]:=vid_h2fps;
      end;
      {$IFDEF _FULLGAME}
      case efft of
    ueff_startb,
    ueff_create  : if(_menu=false)then
                    if(bld=false)
                    then PlayGSND(_ueff2snd(uid,ueff_startb))
                    else PlayGSND(_ueff2snd(uid,ueff_create));
    ueff_death,
    ueff_adeath  : begin
                      if(alt=false)
                      then PlayUSND(_ueff2snd(uid,ueff_death ),pu)
                      else PlayUSND(_ueff2snd(uid,ueff_adeath),pu);
                   end;
    ueff_command : if(_menu=false)then PlayGSND(_ueff2snd(uid,efft));
    {ueff_pain   :;
    ueff_death   :;
    ueff_dattack :;
    ueff_mattack :;
    ueff_foot}
      else
         {PlayUSND(_ueff2snd(uid,efft ),pu);
         with puid^ do
         begin
            PlayUSND(_ueffeids[efft],pu);
            _effect_uadd(pu,_ueffeid[efft]);
         end;
      end;
      {$ENDIF}
   end;
end; } }

