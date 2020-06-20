
{
imp      10
caco     10
revenant 10
baron    15
hrocket  20
mancubus 20
plasma   25
}

function _miss_set(m:integer):boolean;
begin
   _miss_set:=false;
   with _missiles[m] do
    case mid of
    MID_Imp           : begin step:=15 ;dam :=12 ;depuids:=[UID_Imp      ];end;
    MID_Cacodemon     : begin step:=15 ;dam :=30 ;depuids:=[UID_Cacodemon];end;
    MID_Baron         : begin step:=20 ;dam :=50 ;depuids:=[UID_Knight   ];end;
    MID_HRocket       : begin step:=20 ;dam :=100;sr :=45 ; end;
    MID_URocket       : begin step:=20 ;dam :=55 ;sr :=45 ; end;
    MID_Granade       : begin step:=9  ;dam :=50 ;sr :=45 ; pora:=2;       end;
    MID_Mine          : begin           dam:=180 ;sr :=100; end;
    MID_ArchFire      : begin           dam:=100 ;sr :=13 ; end;
    MID_Revenant      : begin step:=15; dam:=30  ;depuids:=[UID_Revenant ];end;
    MID_Mancubus      : begin step:=20; dam:=45  ;depuids:=[UID_Mancubus ];end;
    MID_BPlasma       : begin step:=20; dam:=20  ;          end;
    MID_YPlasma       : begin step:=20; dam:=15  ;          end;
    MID_BFG           : begin step:=10; dam:=110 ;sr :=120; end;
    MID_TBullet,
    MID_Bullet        : begin           dam:=6;  end;
    MID_Bulletx2      : begin           dam:=12; end;
    MID_Blizzard      : begin step:=200;dam:=225; sr :=175; end;
    MID_SShot         :
       begin
          sr :=dist2(x,y,vx,vy) div 4;
          if(sr>60)then sr:=60;
          if(sr<8 )then sr:=8;
          dam:=4+(60-sr); // [4 56]
          mtars:=5;
       end;
    MID_SSShot :
       begin
          vst:=1;
          sr :=(dist2(x,y,vx,vy) div 3);
          if(sr>80)then sr:=80;
          if(sr<8 )then sr:=8;
          dam:=7+(80-sr); // [7 79]
          mtars:=8;
       end;

      else exit;
      end;
   _miss_set:=true;
end;

procedure _miss_add(mx,my,mvx,mvy,mtar:integer;msid,mpl,mft,mflags:byte);
var m,m0,
    dd:integer;
begin
   m0:=0;
   for m:=1 to MaxMissiles do
    with _missiles[m] do
     if(vst=0)then
     begin
        m0:=m;
        break;
     end;

   if(m0>0)then
    with _missiles[m0] do
    begin
       x      := mx;
       y      := my;
       vx     := mvx;
       vy     := mvy;
       tar    := mtar;
       mid    := msid;
       player := mpl;
       mf     := mft;

       mtars  := 1;
       sr     := 0;
       pains  := 1;
       pora   := 0;
       homing := false;
       depuids:= [];
       step   := 0;

       if(_miss_set(m0)=false)then exit;

       dir:=((p_dir(vx,vy,x,y)+23) mod 360) div 45;
       dd :=dist2(x,y,vx,vy);

       if(step=0)
       then vst:=1
       else vst:=dd div step;

       if((mflags and mf_2xspd )>0)then vst:=vst div 2
  else if((mflags and mf_insta )>0)then vst:=1;
       if((mflags and mf_ihhdam)>0)then inc(dam,dam shl 2);
       if((mflags and mf_ihdam )>0)then inc(dam,dam shl 1);
       if((mflags and mf_i1dam )>0)then inc(dam,dam);

       if(vst<=0)then vst:=1;

       if(mtars=0)then
        if(tar=0)or(sr>0)
        then mtars:=MaxUnits
        else mtars:=1;
    end;
end;

procedure _missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
d,damd: integer;
begin
   with _missiles[m] do
   begin
      tu:=@_units[tar];

      if(tu^.hits>0)and not(tu^.uid in depuids)and(tu^.inapc=0)then
        if(abs(mf-tu^.uf)<2)then
        begin
           teams:=_players[player].team=_players[tu^.player].team;

           damd:=dam;

           if(teams)then
            if(tu^.puid^._itbuild)
            then damd:=damd div 4
            else damd:=damd div 2;

           d:=dist2(vx,vy,tu^.x,tu^.y)-tu^.puid^._r;
           if(sr=0)then dec(d,10);

           if(d<=0)then // direct
           begin
              dec(mtars,1);
              _unit_damage(tu,damd,pains);
           end
           else
            if(sr>0)and(d<sr)then
            begin
               dec(mtars,1);
               damd:=trunc(damd*(1-(d/sr)) );
               _unit_damage(tu,damd,pains);
            end;

           {

           case mid of
             MID_Bulletx2 : p:=2;
             MID_SShot    : begin
                               p:=3;
                               if(tu^.mech   )then damd:=damd div 2;
                               if(tu^.isbuild)then damd:=damd div 2;
                            end;
             MID_SSShot   : begin
                               p:=5;
                               if(tu^.mech   )then damd:=damd div 2;
                               if(tu^.isbuild)then damd:=damd div 2;
                            end;
           else
             p:=1;
           end;

           if(tu^.uid in demons)then
           begin
              if(mid=MID_Baron  )then damd:=damd div 2;
              if(mid=MID_Imp    )then damd:=damd*2;
              if(mid=MID_YPlasma)then damd:=damd*3;
           end;

           if(tu^.isbuild)then
           begin
              if(mid in [MID_Cacodemon,MID_Mancubus,MID_Blizzard,
                         MID_HRocket,MID_URocket,MID_Granade])then damd:=damd*2;
              if(mid=MID_ArchFire)then damd:=damd div 2;
              if(mid in [MID_Granade,MID_URocket,MID_Blizzard])and(teams=false)and(tu^.uid in uacbase)then inc(damd,damd div 2);
           end
           else
           begin
              if(tu^.mech)then
               if(mid in [MID_BPlasma])then inc(damd,8);

              if(mid in [MID_Revenant,MID_RevenantS])then
               if(tu^.mech)or(tu^.uid in [UID_Arachnotron,UID_Cyberdemon,UID_Mastermind])then damd:=damd*2;

              if(mid in [MID_Granade,MID_URocket,MID_HRocket,MID_Blizzard,MID_Mine])then
               if(tu^.r<13)then damd:=damd div 2;
           end;

           if(tu^.buff[ub_shield]>0)then
            if(mid in [MID_Imp,
                       MID_Cacodemon,
                       MID_Baron,
                       MID_Mancubus,
                       MID_YPlasma,
                       MID_BPlasma,
                       MID_BFG       ])then dec(damd,damd div 4);

           if(mid in [MID_Bullet,MID_TBullet])then
           begin
              if(tu^.mech)
              then damd:=damd div 2
              else
                if(tu^.r<13)then damd:=damd*2;
              if(tu^.uid=UID_Octobrain)then damd:=damd*3;
           end;

           if(tu^.r<13)then
           begin
              if(mid=MID_Bulletx2)then damd:=damd*3;
              if(mid=MID_Mancubus)then damd:=damd div 2;
           end;

           if(d<=0)then // direct
           begin
              if(mid=MID_TBullet)and(tu^.mech=false)then
              begin
                 tu^.buff[ub_toxin]:=vid_fps;
                 tu^.buff[ub_pain ]:=vid_fps;
              end;

              if(mid in [MID_SShot,MID_SSShot,MID_Bullet,MID_Bulletx2,MID_TBullet])then
              begin
                 if(tu^.mech)
                 then _effect_add(x,y,tu^.vy+map_flydpth[tu^.uf]+1,MID_Bullet)
                 else _effect_add(x,y,tu^.vy+map_flydpth[tu^.uf]+1,EID_Blood);
              end;

              dec(mtars,1);
              _unit_damage(tar,damd,p,player);
           end
           else
             if(sr>0)and(d<sr)then
             begin
                if(mid in [MID_SShot,MID_SSShot])then
                begin
                   if(teams)then exit;
                   dec(mtars,1);
                   _unit_damage(tar,damd,p,player);
                   if(tu^.mech)
                   then _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,MID_Bullet)
                   else _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,EID_Blood);
                   exit;
                end;

                if(mid in [MID_HRocket,MID_URocket,MID_Granade])then
                begin
                   if(tu^.uid in [UID_Cyberdemon,UID_Mastermind])then exit;
                end;

                if(mid=MID_BFG)then
                begin
                   if(teams)then exit;
                   if(tu^.uid in marines)then damd:=damd div 2;
                   _effect_add(tu^.vx,tu^.vy,tu^.vy+map_flydpth[tu^.uf]+1,EID_BFG);
                end;

                dec(mtars,1);
                damd:=trunc(damd*(1-(d/sr)) );
                _unit_damage(tar,damd,p,player);
             end;  }
        end;
   end;
end;


procedure _missileCycle;
var m,u:integer;
begin
   for m:=1 to MaxMissiles do
    with _missiles[m] do
     if(vst>0)then
     begin
        if(tar>0)and(homing)then
        begin
           x  :=_units[tar].x;
           y  :=_units[tar].y;
           mf :=_units[tar].uf;
        end;

        inc(vx,(x-vx) div vst);
        inc(vy,(y-vy) div vst);
        dec(vst,1);

        case pora of
        1  : dec(vy,vst shl 2);
        2  : dec(vy,vst div 3);
        10 : dec(vy,vst*2);
        end;

        if(vst=0)then
        begin
           if(dam>0)then
            if(tar>0)and(mtars=1)
            then _missle_damage(m)
            else
              for u:=1 to MaxUnits do
              begin
                 tar:=u;
                 _missle_damage(m);
                 if(mtars<=0)then break;
              end;

           {$IFDEF _FULLGAME}
           _missile_effect(m);
           {$ENDIF}
        end;
     end;
end;



