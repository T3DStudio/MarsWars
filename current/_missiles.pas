{$IFDEF _FULLGAME}

procedure initMissiles;
var m:byte;
begin
   FillChar(_mids,SizeOf(_mids),0);

   for m:=0 to 255 do
   with _mids[m] do
   begin
      ms_smodel   :=spr_pdmodel;
      ms_alt_death:=false;

      // sprite moddel
      case m of
MID_Imp      : ms_smodel:=@spr_h_p0;
MID_Cacodemon: ms_smodel:=@spr_h_p1;
MID_Baron    : ms_smodel:=@spr_h_p2;
MID_Blizzard,
MID_Granade,
MID_Mine,
MID_HRocket  : ms_smodel:=@spr_h_p3;
MID_Revenant : ms_smodel:=@spr_h_p4;
MID_RevenantS: ms_smodel:=@spr_h_p4;
MID_Mancubus : ms_smodel:=@spr_h_p5;
MID_YPlasma  : ms_smodel:=@spr_h_p7;
MID_BPlasma  : ms_smodel:=@spr_u_p0;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet  : ms_smodel:=@spr_u_p1;
MID_SShot,
MID_SSShot   : begin
               ms_smodel:=@spr_u_p1;
               ms_alt_death:=true;
               end;
MID_BFG      : ms_smodel:=@spr_u_p2;
MID_Tank,
MID_StunMine     : ;
MID_ArchFire : ;
MID_Flyer    : ms_smodel:=@spr_u_p3;
      end;

      // tracer
      case m of
MID_Granade,
MID_HRocket,
MID_RevenantS: begin
               ms_eid_fly   :=MID_Bullet;
               ms_eid_fly_st:=5;
               end;
MID_Blizzard : begin
               ms_eid_fly   :=MID_Granade;
               ms_eid_fly_st:=1;
               ms_eid_decal :=EID_db_h0;
               end;
      end;

      // death sound
      case m of
MID_Mancubus,
MID_YPlasma,
MID_BPlasma,
MID_Imp,
MID_Cacodemon,
MID_Baron    : ms_snd_death:=snd_pexp;
MID_StunMine : ms_snd_death:=snd_electro;
MID_ArchFire,
MID_Blizzard,
MID_Mine,
MID_Tank,
MID_Granade,
MID_HRocket,
MID_Revenant,
MID_RevenantS: ms_snd_death:=snd_exp;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
MID_SShot,
MID_SSShot   : begin
               ms_snd_death   :=snd_rico;
               ms_snd_death_ch:=5;
               end;
MID_BFG      : ms_snd_death:=snd_bfg_exp;
MID_Flyer    : ms_snd_death:=snd_flyer_a;
      end;


   end;
end;


{$ENDIF}

procedure _d1  (d:pinteger);begin d^:=0             end;
procedure _d25 (d:pinteger);begin d^:=d^ div 4;     end;
procedure _d50 (d:pinteger);begin d^:=d^ div 2;     end;
procedure _d75 (d:pinteger);begin d^:=d^-(d^ div 4);end;
procedure _d125(d:pinteger);begin d^:=d^+(d^ div 4);end;
procedure _d150(d:pinteger);begin d^:=d^+(d^ div 2);end;
procedure _d200(d:pinteger);begin d^:=d^*2;         end;
procedure _d225(d:pinteger);begin d^:=(d^ div 4)*9; end;

{
function _unit_melee_damage(pu,tu:PTUnit;damage:integer):integer;
begin
   with pu^.player^ do
    if(upgr[upgr_melee]>0)then
     case race of
       r_hell : inc(damage,upgr[upgr_melee]*4);
       r_uac  : inc(damage,upgr[upgr_melee]*2);
     end;

   case pu^.uidi of
   UID_LostSoul: begin
                    if(tu^.mech               )then _d25 (@damage) else
                    if(tu^.uf=uf_ground       )then _d50 (@damage);
                 end;
   UID_Demon   : begin
                    if(tu^.mech               )then _d50 (@damage);
                 end;
   end;

   _unit_melee_damage:=damage;
end; }

procedure _missile_add(mxt,myt,mvx,mvy,mtar:integer;msid,mpl,mfst,mfet:byte;adddmg:integer);
var m:integer;
    tu:PTUnit;
begin
   for m:=1 to MaxUnits do
   with _missiles[m] do
   if(vst=0)then
   begin
      x      := mxt;
      y      := myt;
      vx     := mvx;
      vy     := mvy;
      tar    := mtar;
      mid    := msid;
      player := mpl;
      mfe    := mfet;
      mfs    := mfst;
      mtars  := 0;
      ntars  := 0;
      ystep  := 0;
      dir    := 270;

      sr:=dist2(x,y,vx,vy);


      case mid of
MID_Imp        : begin dam:=10 ; vst:=sr div 8 ; sr :=0  ;       end;
MID_Cacodemon  : begin dam:=30 ; vst:=sr div 8 ; sr :=0  ;       end;
MID_Baron      : begin dam:=50 ; vst:=sr div 8 ; sr :=0  ;       end;
MID_RevenantS,
MID_Revenant   : begin dam:=30 ; vst:=sr div 11; sr :=0  ;       dir:=p_dir(vx,vy,x,y);end;
MID_Mancubus   : begin dam:=35 ; vst:=sr div 8 ; sr :=0  ;       dir:=p_dir(vx,vy,x,y);end;
MID_YPlasma    : begin dam:=10 ; vst:=sr div 16; sr :=0  ;       end;
MID_ArchFire   : begin dam:=90 ; vst:=1;         sr :=15 ;       end;

MID_MBullet,
MID_TBullet,
MID_Bullet     : begin dam:=6  ; vst:=1;         sr :=0  ;       end;
MID_Bulletx2   : begin dam:=12 ; vst:=1;         sr :=0  ;       end;
MID_BPlasma    : begin dam:=15 ; vst:=sr div 15; sr :=0  ;       end;
MID_BFG        : begin dam:=125; vst:=sr div 8 ; sr :=125;       end;
MID_Flyer      : begin dam:=16 ; vst:=sr div 60; sr :=0  ;       end;
MID_HRocket    : begin dam:=100; vst:=sr div 15; sr :=rocket_sr; dir:=p_dir(vx,vy,x,y);end;
MID_Granade    : begin dam:=50 ; vst:=sr div 10; sr :=rocket_sr; ystep:=3;end;
MID_Tank       : begin dam:=75 ; vst:=1;         sr :=rocket_sr; end;
MID_StunMine   : begin dam:=5  ; vst:=1;         sr :=100;       end;
MID_Mine       : begin dam:=150; vst:=1;         sr :=100;       end;
MID_Blizzard   : begin dam:=250; vst:=fr_fps;    sr :=blizz_r;   dir:=p_dir(vx,vy,x,y);end;
MID_SShot      : begin           vst:=1;         sr :=mm3(10,dist2(x,y,vx,vy) div 8,30);mtars:=3;
                       dam:=8 +(30-sr);{ [9  28] }               end;
MID_SSShot     : begin           vst:=1;         sr :=mm3(10,dist2(x,y,vx,vy) div 6,40);mtars:=5;
                       dam:=13+(40-sr);{ [12 41] }               end;
      else
         vst:=0;
         exit;
      end;

      if(vst<=0)then vst:=1;

      if(mtars=0)then
       if(tar=0)or(sr>0)
       then mtars:=MaxUnits
       else mtars:=1;

      dam+=adddmg;

      if(mid=MID_Revenant)then
       if(_players[player].upgr[upgr_hell_revmis]>0)then mid:=MID_RevenantS;

      if(mid=MID_RevenantS)
      then homing:=true
      else
        if(_IsUnitRange(tar,@tu))then
        begin
           x+=_randomr(tu^.uid^._missile_r);
           y+=_randomr(tu^.uid^._missile_r);
        end;

      break;
   end;
end;

{ with _players[player] do
 begin
    if(upgr[upgr_attack]>0)then
     case mid of
MID_SShot,
MID_Imp,
MID_BPlasma    : inc(dam,upgr[upgr_attack]*2);
MID_SSShot,
MID_YPlasma,
MID_Revenant,
MID_RevenantS,
MID_Flyer,
MID_HRocket,
MID_BFG,
MID_Mancubus,
MID_Cacodemon,
MID_Baron,
MID_Mine       : inc(dam,upgr[upgr_attack]*3);
MID_ArchFire,
MID_Granade,
MID_Tank       : inc(dam,upgr[upgr_attack]*5);
MID_Blizzard   : ;
     else inc(dam,upgr[upgr_attack]);
     end;

    if(race=r_hell)then
    if(upgr[upgr_misfst]>0)then
     case mid of
MID_Imp,
MID_Cacodemon,
MID_Baron      : vst:=vst-(vst div 2);
     end;
 end;}

function _miduid(mid,uid:byte):boolean;
begin
   _miduid:=false;

   case mid of
MID_Imp       : if(uid=UID_Imp        )then exit;
MID_Cacodemon : if(uid=UID_Cacodemon  )then exit;
MID_Baron     : if(uid=UID_Baron      )then exit;
MID_Mancubus  : if(uid=UID_Mancubus   )then exit;
MID_YPlasma   : if(uid=UID_Arachnotron)then exit;
MID_Revenant,
MID_RevenantS : if(uid=UID_Revenant   )then exit;
MID_StunMine  : if(uid=UID_UMine      )then exit;
   end;

   _miduid:=true;
end;


procedure _missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
d,damd: integer;
     p: byte;
begin
   with _missiles[m] do
   begin
      tu:=@_units[tar];

      if(tu^.hits>0)and(_miduid(mid,tu^.uidi))and(tu^.inapc=0)then
      if(abs(mfs-tu^.uf)<2)then
      begin
         teams:=_players[player].team=tu^.player^.team;
         damd :=dam;

         if(teams)and(sr>0)then
          case mid of
          MID_BFG,
          MID_StunMine,
          MID_SShot,
          MID_SSShot,
          MID_ArchFire: exit;
          end;

         d:=dist2(vx,vy,tu^.x,tu^.y)-tu^.uid^._r;
         if(sr=0)then d-=10;
         if(d <0)then d:=0;

         if(ServerSide)then
         begin
            if(teams)then
             if(tu^.uid^._isbuilding)
             then damd:=damd div 4
             else damd:=damd div 2;
            p:=1;

             { /////////////////////////////////
              if(tu^.uidi in armor_lite)then
                 case mid of
                 MID_Blizzard   : _d25 (@damd);
                 MID_BFG,
                 MID_Baron,
                 MID_HRocket,
                 MID_Mancubus,
                 MID_Granade,
                 MID_Tank,
                 MID_BPlasma,
                 MID_SShot,
                 MID_SSShot      : _d50 (@damd);
                 MID_Revenant,
                 MID_RevenantS   : _d75 (@damd);
                 MID_Cacodemon   : _d125(@damd);
                 MID_MBullet,
                 MID_TBullet,
                 MID_Bullet,
                 MID_Bulletx2    : _d150(@damd);
                 end;

              if(tu^.uidi in armor_massive)then
                 case mid of
                 MID_SShot,
                 MID_SSShot,
                 MID_MBullet,
                 MID_TBullet,
                 MID_Bullet      : _d50 (@damd);
                 MID_Cacodemon   : _d75 (@damd);
                 end;

              if(tu^.mech)then
              begin
                 case mid of
                 MID_SShot,
                 MID_SSShot,
                 MID_MBullet,
                 MID_TBullet,
                 MID_Bullet      : _d25 (@damd);
                 MID_BFG,
                 MID_Cacodemon,
                 MID_Imp         : _d50 (@damd);
                 MID_Baron       : _d75 (@damd);
                 else
                   // mechs
                   if(tu^.isbuild=false)then
                   case mid of
                   MID_Revenant,
                   MID_RevenantS,
                   MID_BPlasma     : _d150(@damd);
                   MID_Granade,
                   MID_Mancubus    : _d50 (@damd);
                   MID_Bulletx2    : _d75 (@damd);
                   end
                   else
                   // buildings
                   case mid of
                   //MID_Flyer,
                   MID_Archfire    : _d50 (@damd);
                   MID_Bulletx2    : _d25 (@damd);
                   MID_Blizzard,
                   MID_HRocket,
                   MID_Mancubus,
                   MID_Granade,
                   MID_Tank        : _d150(@damd);
                   MID_Revenant,
                   MID_RevenantS,
                   MID_BPlasma     : _d75 (@damd);
                   end;
                 end;
              end;

              if(tu^.uf>uf_ground)then
              begin
                 case mid of
                 MID_YPlasma,
                 MID_Flyer       : _d225(@damd);
                 end;
                 if(tu^.isbuild=false)then
                 case mid of
                 MID_BPlasma,
                 MID_Imp         : _d50 (@damd);
                 MID_Cacodemon,
                 MID_Revenant,
                 MID_RevenantS,
                 MID_Mancubus,
                 MID_Baron       : _d75 (@damd);
                 end;
              end;


             if(tu^.isbuild=false)then
              if(tu^.uf>uf_soaring)then
              case mid of
              MID_Blizzard    : if(tu^.isbuild=false)then _d50 (@damd);
              MID_SShot,
              MID_SSShot      : _d50 (@damd);
              end;

              case mid of
              MID_SShot       : p:=2;
              MID_SSShot      : p:=4;
              end;
           end; }
         end;

         if(d<=0)and(ntars=0)then // direct and first target
         begin
            if(ServerSide)then
             if(tu^.buff[ub_invuln]=0)then
             begin
                if((mid=MID_TBullet)and(tu^.uid^._ismech=false))
                or((mid=MID_MBullet)and(tu^.uid^._ismech)and(tu^.uid^._isbuilding=false))
                or (mid=MID_StunMine)then
                begin
                   tu^.buff[ub_stun]:=fr_fps;
                   tu^.buff[ub_pain]:=fr_fps;
                end;
                {$IFDEF _FULLGAME}
                if(mid=MID_StunMine)then _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.uf),MID_BPlasma);
                {$ENDIF}
             end;

            {$IFDEF _FULLGAME}
            if(mid in [MID_SShot,MID_SSShot,MID_Bullet,MID_Bulletx2,MID_TBullet,MID_MBullet])
            then _unit_bullet_puff(tu);
            {$ENDIF}

            mtars-=1;
            ntars+=1;

            if(ServerSide)then _unit_damage(tu,damd,p,player);
         end
         else
           if(sr>0)and(d<sr)then
           begin
              if(mid in [MID_SShot,MID_SSShot])then
              begin
                 {$IFDEF _FULLGAME}
                 _unit_bullet_puff(tu);
                 {$ENDIF}
                 mtars-=1;
                 ntars+=1;
                 _unit_damage(tu,damd,p,player);
                 exit;
              end;

              {$IFDEF _FULLGAME}
              if(mid=MID_BFG)then _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.uf),EID_BFG);
              {$ENDIF}
              if(ServerSide)then
               if(mid=MID_StunMine)then
               begin
                  tu^.buff[ub_stun]:=fr_fps;
                  tu^.buff[ub_pain ]:=fr_fps;
                  {$IFDEF _FULLGAME}
                  _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.uf),MID_BPlasma);
                  {$ENDIF}
               end;

              if(mid in [MID_HRocket,MID_Tank,MID_Granade])then
              begin
                 if(tu^.uidi in [UID_Cyberdemon,UID_Mastermind,UID_Tank])then exit;
                 if(tu^.uidi in armor_lite)then damd:=damd div 2;
              end;

              {$IFDEF _FULLGAME}
              if(mid in [MID_Bullet,MID_Bulletx2,MID_TBullet,MID_MBullet])
              then _unit_bullet_puff(tu);
              {$ENDIF}

              mtars-=1;
              ntars+=1;

              if(ServerSide)then
              begin
                 damd:=mm3(0,trunc(damd*(1-(d/sr))),dam);
                 _unit_damage(tu,damd,p,player);
              end;
           end;
      end;
   end;
end;

procedure _missileCycle;
const  mb_s0 = fr_fps div 5;
       mb_s1 = fr_fps-mb_s0;
var m,u:integer;
     tu:PTUnit;
begin
   for m:=1 to MaxMissiles do
   with _missiles[m] do
   if(vst>0)then
   begin
      if(homing)and(_IsUnitRange(tar,@tu))then
      begin
         x  :=tu^.x;
         y  :=tu^.y;
         mfs:=tu^.uf;
      end;

      if(mid=MID_Blizzard)then
      begin
         if(vst>mb_s1)
         then vy-=fr_fps
         else
           if(vst=mb_s1)then
           begin
              vx:=x;
              vy:=y-(fr_fps*mb_s0);
           end
           else
             if(vst<=mb_s0)then vy+=fr_fps;
      end
      else
      begin
         vx+=(x-vx) div vst;
         vy+=(y-vy) div vst;
      end;
      vst-=1;

      if(ystep>0)then vy-=vst div ystep;

      if(vst=0)then
      begin
         if(dam>0)then
          if _IsUnitRange(tar,nil)and(mtars=1)
          then _missle_damage(m)
          else
            for u:=1 to MaxUnits do
            begin
               tar:=u;
               _missle_damage(m);
               if(mtars<=0)then break;
            end;

         {$IFDEF _FULLGAME}
         _missile_explode_effect(m);
         {$ENDIF}
      end
      {$IFDEF _FULLGAME}
      else
        with _mids[mid] do
         if(ms_eid_fly_st>0)and(ms_eid_fly>0)then
          if((vst mod ms_eid_fly_st)=0)then _effect_add(vx,vy,_depth(vy,mfs),ms_eid_fly);
       {$ENDIF};
   end;
end;




