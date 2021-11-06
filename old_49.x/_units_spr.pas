
function _unit_spr(u:PTUnit):PTUSprite;
var an,td:integer;
begin
   _unit_spr:=@spr_dummy;

   with u^ do
   if(hits>0)then
    case uid of

UID_LostSoul :
begin
   td:=((dir+23) mod 360) div 45;
   an:=0;
   if(buff[ub_pain]>0)
   then an:=16
   else
     if(rld>rld_a)
     then an:=8
     else
       if(wanim)then an:=8;

   _unit_spr:=@spr_LostSoul[td+an];
end;

UID_ZEngineer:
begin
   td:=((dir+23) mod 360) div 45;

   if(wanim)then anim+=anims;
   anim:=anim mod 400;
   an:=4*td+(anim div 100);

   _unit_spr:=@spr_ZEngineer[an];
end;

UID_Imp,       // common 0-47, pain, 1 attack
UID_Demon,
UID_ZFormer,
UID_ZSergant,
UID_ZBomber,
UID_ZBFG,
UID_Baron,
UID_Cyberdemon:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=40+td
   else
     if(rld>rld_a)
     then an:=32+td
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 400;
        an:=4*td+(anim div 100);
     end;

   case uid of
UID_Imp       : _unit_spr:=@spr_Imp    [an];
UID_Demon     : _unit_spr:=@spr_Demon  [an];
UID_ZFormer   : _unit_spr:=@spr_ZFormer[an];
UID_ZSergant  : if(buff[ub_advanced]>0)
                then _unit_spr:=@spr_ZSSergant[an]
                else _unit_spr:=@spr_ZSergant [an];
UID_ZBomber   : _unit_spr:=@spr_ZBomber[an];
UID_ZBFG      : _unit_spr:=@spr_ZBFG   [an];
UID_Baron     : if(buff[ub_advanced]>0)
                then _unit_spr:=@spr_Baron [an]
                else _unit_spr:=@spr_Knight[an];
UID_Cyberdemon: _unit_spr:=@spr_Cyberdemon [an];
   end;
end;

UID_ZCommando:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=48+td
   else
     if(rld>0)
     then if (rld>rld_a)
          then an:=32+td
          else an:=40+td
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 400;
        an:=4*td+(anim div 100);
     end;

   _unit_spr:=@spr_ZCommando[an];
end;

UID_ZMajor :
begin
   td:=((dir+23) mod 360) div 45;
   if(uf>uf_ground)then
   begin
      an:=0;
      if(buff[ub_pain]=0)then
       if(rld>0)then an:=8;

      _unit_spr:=@spr_ZFMajor[an+td];
   end
   else
   begin
      if(buff[ub_pain]>0)
      then an:=40+td
      else
        if(rld>0)
        then an:=32+td
        else
        begin
           if(wanim)then anim+=anims;
           anim:=anim mod 400;
           an:=4*td+(anim div 100);
        end;
      _unit_spr:=@spr_ZMajor[an];
   end;
end;

UID_Cacodemon:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=16+td
   else
     if(rld>rld_a)
     then an:=8+td
     else an:=td;

   _unit_spr:=@spr_Cacodemon[an];
end;

UID_Mastermind:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=64+td
   else
     if(rld>0)then
     begin
        an:=48+(td*2);
        if(rld>rld_a)then an+=1;
     end
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 600;
        an:=6*td+(anim div 100);
     end;

   _unit_spr:=@spr_Mastermind[an];
end;

UID_Pain:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=24+td
   else
     if(rld>rld_a)or(buff[ub_cast]>0)
     then an:=16+td
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 200;
        an:=2*td+(anim div 100);
     end;

   _unit_spr:=@spr_Pain[an];
end;

UID_Arachnotron:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=56+td
   else
     if(rld>0)
     then an:=48+td
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 600;
        an:=6*td+(anim div 100);
     end;

   _unit_spr:=@spr_Arachnotron[an];
end;

UID_Revenant:
begin
   td:=((dir+23) mod 360) div 45;      //48 melee 56 distn 64 pain
   if(buff[ub_pain]>0)
   then an:=64+td
   else
     if(rld>revenant_ra[melee])
     then if(melee)
          then an:=48+td
          else an:=56+td
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 600;
        an:=6*td+(anim div 100);
     end;

   _unit_spr:=@spr_Revenant[an];
end;

UID_Mancubus:
begin
   td:=((dir+23) mod 360) div 45;
   if(buff[ub_pain]>0)
   then an:=64+td
   else
     if(rld>0)and(tar1>0)
     then if(rld>120)or(((rld div 20) mod 2)=0)
          then an:=48+td            //50
          else an:=56+td
     else
     begin
        if(wanim)then anim+=anims;
        anim:=anim mod 600;
        an:=6*td+(anim div 100);
     end;

   _unit_spr:=@spr_Mancubus[an];
end;

UID_Archvile:
begin
   td:=((dir+23) mod 360) div 45;      //48 dist 56 dist 2  64 melee 72 pain
   if(buff[ub_pain]>0)
   then an:=72+td
   else
     if(buff[ub_cast]>0)
     then an:=64+td
     else
       if(rld>0)then
       begin
            if(rld>rld_a)
            then an:=48+td
            else an:=56+td
       end
       else
       begin
          if(wanim)then anim+=anims;
          anim:=anim mod 600;
          an:=6*td+(anim div 100);
       end;

   _unit_spr:=@spr_Archvile[an];
end;

UID_APC:
begin
   td:=((dir+23) mod 360) div 45;

   if(wanim)then anim+=anims;
   anim:=anim mod 200;
   an:=2*td+(anim div 100);

   _unit_spr:=@spr_APC[an];
end;

UID_FAPC:
begin
   td:=((dir+12) mod 360) div 23;
   _unit_spr:=@spr_FAPC[td];
end;

UID_Engineer,
UID_Sergant,
UID_Bomber,
UID_BFG:
begin
   td:=((dir+23) mod 360) div 45;

   if(rld>rld_a)
   then an:=32+td
   else
   begin
      if(wanim)then anim+=anims;
      anim:=anim mod 400;
      an:=4*td+(anim div 100);
   end;

   case uid of
UID_Engineer  : _unit_spr:=@spr_Engineer[an];
UID_Sergant   : if(buff[ub_advanced]>0)
                then _unit_spr:=@spr_SSergant[an]
                else _unit_spr:=@spr_Sergant [an];
UID_Bomber    : _unit_spr:=@spr_Bomber[an];
UID_BFG       : _unit_spr:=@spr_BFG[an];
   end;
end;

UID_Medic:
begin
   td:=((dir+23) mod 360) div 45;

   if(rld>rld_a)
   then if(melee)
        then an:=40+td
        else an:=32+td
   else
   begin
      if(wanim)then anim+=anims;
      anim:=anim mod 400;
      an:=4*td+(anim div 100);
   end;

   _unit_spr:=@spr_Medic[an];
end;

UID_Commando:
begin
   td:=((dir+23) mod 360) div 45;

   if(rld>0)
   then if (rld>rld_a)
        then an:=32+td
        else an:=40+td
   else
   begin
      if(wanim)then anim+=anims;
      anim:=anim mod 400;
      an:=4*td+(anim div 100);
   end;

   _unit_spr:=@spr_Commando[an];
end;

UID_Major:
begin
   td:=((dir+23) mod 360) div 45;

   if(uf>uf_ground)then
   begin
      an:=0;
      if(rld>0) then an:=8;

      _unit_spr:=@spr_FMajor[an+td];
   end
   else
   begin
      if(rld>0)
      then an:=32+td
      else
      begin
         if(wanim)then anim+=anims;
         anim:=anim mod 400;
         an:=4*td+(anim div 100);
      end;
      _unit_spr:=@spr_Major[an];
   end;
end;

UID_Tank:
begin
   td:=((dir+23) mod 360) div 45;

   if(rld>rld_a)
   then an:=16+td
   else
   begin
      if(wanim)then anim+=anims;
      anim:=anim mod 200;
      an:=2*td+(anim div 100);
   end;

   _unit_spr:=@spr_Tank[an];
end;

UID_Terminator:
begin
   td:=((dir+23) mod 360) div 45;
   if(rld>rld_a)//and(tar>0) //32   //40
   then
     if(buff[ub_clcast]>45)
     then an:=32+td
     else an:=40+td
   else
   begin
      if(wanim)then anim+=anims;
      anim:=anim mod 400;
      an:=4*td+(anim div 100);
   end;

   _unit_spr:=@spr_Terminator[an];
end;

UID_Flyer:
begin
   td:=((dir+23) mod 360) div 45;

   an:=0;
   if(rld>rld_a) then an:=8;

   _unit_spr:=@spr_Flyer[an+td];
end;

UID_UTransport:
begin
   td:=((dir+23) mod 360) div 45;

   _unit_spr:=@spr_trans[td];
end;


UID_HKeep          : begin if(bld)then _unit_spr:=@spr_HKeep          [3] else _unit_spr:=@spr_Hkeep          [(hits*3) div mhits];end;
UID_HGate          : begin if(bld)then _unit_spr:=@spr_HGate          [3] else _unit_spr:=@spr_HGate          [(hits*3) div mhits];end;
UID_HSymbol        : begin if(bld)then _unit_spr:=@spr_HSymbol        [3] else _unit_spr:=@spr_HSymbol        [(hits*3) div mhits];end;
UID_HPools         : begin if(bld)then _unit_spr:=@spr_HPools         [3] else _unit_spr:=@spr_HPools         [(hits*3) div mhits];end;
UID_HTower         : begin if(bld)then _unit_spr:=@spr_HTower         [3] else _unit_spr:=@spr_HTower         [(hits*3) div mhits];end;
UID_HTeleport      : begin if(bld)then _unit_spr:=@spr_HTeleport      [3] else _unit_spr:=@spr_HTeleport      [(hits*3) div mhits];end;

UID_HMonastery     : _unit_spr:=@spr_HMonastery;
UID_HTotem         : _unit_spr:=@spr_HTotem;
UID_HAltar         : _unit_spr:=@spr_HAltar;
UID_HFortress      : _unit_spr:=@spr_HFortress;
UID_HEye           : _unit_spr:=@spr_HEye;

UID_UCommandCenter : begin if(bld)then _unit_spr:=@spr_UCommandCenter [3] else _unit_spr:=@spr_UCommandCenter [(hits*3) div mhits];end;
UID_UMilitaryUnit  : begin if(bld)then _unit_spr:=@spr_UMilitaryUnit  [3] else _unit_spr:=@spr_UMilitaryUnit  [(hits*3) div mhits];end;
UID_UGenerator     : begin if(bld)then _unit_spr:=@spr_UGenerator     [3] else _unit_spr:=@spr_UGenerator     [(hits*3) div mhits];end;
UID_UWeaponFactory : begin if(bld)then _unit_spr:=@spr_UWeaponFactory [3] else _unit_spr:=@spr_UWeaponFactory [(hits*3) div mhits];end;
UID_UTurret        : begin if(bld)then _unit_spr:=@spr_UTurret        [3] else _unit_spr:=@spr_UTurret        [(hits*3) div mhits];end;
UID_URadar         : begin if(bld)then _unit_spr:=@spr_URadar         [3] else _unit_spr:=@spr_URadar         [(hits*3) div mhits];end;
UID_UVehicleFactory: begin if(bld)then _unit_spr:=@spr_UVehicleFactory[3] else _unit_spr:=@spr_UVehicleFactory[(hits*3) div mhits];end;
UID_UPTurret       : begin if(bld)then _unit_spr:=@spr_UPTurret       [3] else _unit_spr:=@spr_UPTurret       [(hits*3) div mhits];end;
UID_URTurret       : begin if(bld)then _unit_spr:=@spr_URTurret       [3] else _unit_spr:=@spr_URTurret       [(hits*3) div mhits];end;
UID_URocketL       : begin if(bld)then _unit_spr:=@spr_URocketL       [3] else _unit_spr:=@spr_URocketL       [(hits*3) div mhits];end;

UID_UBaseMil       : _unit_spr:=@spr_ubase[0];
UID_UBaseCom       : _unit_spr:=@spr_ubase[1];
UID_UBaseGen       : _unit_spr:=@spr_ubase[2];
UID_UBaseRef       : _unit_spr:=@spr_ubase[3];
UID_UBaseNuc       : _unit_spr:=@spr_ubase[4];
UID_UBaseLab       : _unit_spr:=@spr_ubase[5];

UID_Mine           : _unit_spr:=@spr_Mine;

UID_HMilitaryUnit  : _unit_spr:=@spr_HBar;

UID_UCBuild        : _unit_spr:=@spr_cbuild[anims];
UID_USPort         : _unit_spr:=@spr_sport[anims];

UID_CoopPortal,
UID_Portal         : _unit_spr:=@spr_u_portal;

    end
   else
    if(hits>dead_hits)then
    case uid of
UID_Cacodemon:begin td:=24+abs(hits div 8 );if(td>29)then td:=29;_unit_spr:=@spr_Cacodemon[td];end;//24-29

UID_Imp        : begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_Imp        [td];end; // 48-52
UID_Demon      : begin td:=48+abs(hits div 8 );if(td>53)then td:=53;_unit_spr:=@spr_Demon      [td];end; // 48-53
UID_Cyberdemon : begin td:=48+abs(hits div 9 );if(td>56)then td:=56;_unit_spr:=@spr_Cyberdemon [td];end; // 48-56
UID_Mastermind : begin td:=72+abs(hits div 18);if(td>81)then td:=81;_unit_spr:=@spr_Mastermind [td];end; // 72-81
UID_Revenant   : begin td:=72+abs(hits div 8 );if(td>76)then td:=76;_unit_spr:=@spr_Revenant   [td];end; // 72-76
UID_Mancubus   : begin td:=72+abs(hits div 14);if(td>78)then td:=78;_unit_spr:=@spr_Mancubus   [td];end; // 72-78
UID_Arachnotron: begin td:=64+abs(hits div 14);if(td>69)then td:=69;_unit_spr:=@spr_Arachnotron[td];end; // 64-69
UID_ArchVile   : begin td:=80+abs(hits div 14);if(td>85)then td:=85;_unit_spr:=@spr_ArchVile   [td];end; // 80-85
UID_Engineer   : begin td:=40+abs(hits div 8 );if(td>44)then td:=44;_unit_spr:=@spr_Engineer   [td];end; // 40-44
UID_Medic      : begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_Medic      [td];end; // 48-52
UID_Commando   : begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_Commando   [td];end; // 48-52
UID_Bomber     : begin td:=40+abs(hits div 8 );if(td>44)then td:=44;_unit_spr:=@spr_Bomber     [td];end; // 40-44
UID_Major      : if(uf=uf_ground)then
                 begin td:=40+abs(hits div 8 );if(td>44)then td:=44;_unit_spr:=@spr_Major      [td];end; // 40-44
UID_BFG        : begin td:=40+abs(hits div 8 );if(td>44)then td:=44;_unit_spr:=@spr_BFG        [td];end; // 40-44
UID_ZFormer    : begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_ZFormer    [td];end; // 48-52
UID_ZCommando  : begin td:=56+abs(hits div 8 );if(td>59)then td:=59;_unit_spr:=@spr_ZCommando  [td];end; // 56-59
UID_ZBomber    : begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_ZBomber    [td];end; // 48-52
UID_ZMajor     : if(uf=uf_ground)then
                 begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_ZMajor     [td];end; // 48-52
UID_ZBFG       : begin td:=48+abs(hits div 8 );if(td>52)then td:=52;_unit_spr:=@spr_ZBFG       [td];end; // 48-52

UID_Baron:
begin td:=48+abs(hits div 8);if(td>52)then td:=52;if(buff[ub_advanced]>0)then _unit_spr:=@spr_Baron    [td]else _unit_spr:=@spr_Knight  [td];end;//48-52
UID_Sergant:
begin td:=40+abs(hits div 8);if(td>44)then td:=44;if(buff[ub_advanced]>0)then _unit_spr:=@spr_SSergant [td]else _unit_spr:=@spr_Sergant [td];end;//48-52
UID_ZEngineer,
UID_ZSergant:
begin td:=48+abs(hits div 8);if(td>52)then td:=52;if(buff[ub_advanced]>0)then _unit_spr:=@spr_ZSSergant[td]else _unit_spr:=@spr_ZSergant[td];end;//48-52

    end;
end;

