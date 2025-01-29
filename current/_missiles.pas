{$IFDEF _FULLGAME}

procedure missile_InitCLData;
var m:byte;
begin
   for m:=0 to 255 do
   with g_mids[m] do
   begin
      ms_smodel   :=spr_pdmodel;

      // sprite model
      case m of
MID_Imp      : ms_smodel:=@spr_h_p0;
MID_Cacodemon: ms_smodel:=@spr_h_p1;
MID_Baron    : ms_smodel:=@spr_h_p2;
MID_Blizzard,
MID_Mine,
MID_HRocket  : ms_smodel:=@spr_h_p3;
MID_Revenant : ms_smodel:=@spr_h_p4;
MID_Mancubus : ms_smodel:=@spr_h_p5;
MID_YPlasma  : ms_smodel:=@spr_h_p7;
MID_BPlasma  : ms_smodel:=@spr_u_p0;
MID_Bullet,
MID_MChaingun,
MID_Chaingun : ms_smodel:=@spr_u_p1;
MID_SShot,
MID_SSShot   : ms_smodel:=@spr_u_p1s;
MID_BFG      : ms_smodel:=@spr_u_p2;
MID_ArchFire : ;
MID_Flyer    : ms_smodel:=@spr_u_p3;
MID_Tank,
MID_Granade,
MID_URocketS,
MID_URocket  : ms_smodel:=@spr_u_p8;
      end;

      // tracer
      case m of
MID_Granade,
MID_HRocket,
MID_URocketS,
MID_URocket,
MID_Revenant : begin
               ms_eid_fly   :=MID_Bullet;
               ms_eid_fly_st:=4;
               end;
MID_Blizzard : begin
               ms_eid_fly   :=MID_Granade;
               ms_eid_fly_st:=1;
               ms_eid_decal :=EID_db_h0;
               end;
      end;

      // death sound and effect (common)
      case m of
MID_Mancubus,
MID_YPlasma,
MID_BPlasma,
MID_Imp,
MID_Cacodemon,
MID_Baron    : ms_snd_death[false]:=snd_pexp;
MID_ArchFire,
MID_Blizzard,
MID_Mine,
MID_Tank,
MID_Granade,
MID_HRocket,
MID_URocket,
MID_Revenant : ms_snd_death[false]:=snd_exp;
MID_Bullet,
MID_Chaingun,
MID_MChaingun,
MID_SShot,
MID_SSShot   : begin
               ms_snd_death   [false]:=snd_rico;
               ms_snd_death_ch[false]:=5;
               end;
MID_BFG      : begin
               ms_snd_death[false]:=snd_bfg_exp;
               ms_eid_target_eff  :=EID_BFG;
               end;
MID_Flyer    : ms_snd_death[false]:=snd_flyer_a;
      end;
      ms_snd_death[true ]:=ms_snd_death[false];
      ms_eid_death    [false]:=m;
      ms_eid_death    [true ]:=m;
      ms_eid_death_cnt[false]:=1;
      ms_eid_death_cnt[true ]:=1;
      ms_eid_death_r  [false]:=0;
      ms_eid_death_r  [true ]:=0;

      // death sound and effect
      case m of
MID_URocketS : begin
                  ms_snd_death    [true ]:=snd_exp;
                  ms_eid_death_cnt[true ]:=4;
                  ms_eid_death_r  [true ]:=20;
                  ms_snd_death    [false]:=snd_exp;
                  ms_eid_death_cnt[false]:=4;
                  ms_eid_death_r  [false]:=20;
               end;
MID_Bullet,
MID_Chaingun,
MID_MChaingun,
MID_SShot,
MID_SSShot   : begin
                  ms_snd_death    [true]:=nil;
                  ms_snd_death_ch [true]:=0;
                  ms_eid_death    [true]:=eid_blood;
                  ms_eid_death_cnt[true]:=0;
               end;
      end;
      case m of
MID_SShot    : begin
                  ms_eid_death_cnt[false]:=2;
                  ms_eid_death_cnt[true ]:=2;
                  ms_eid_death_r  [false]:=5;
                  ms_eid_death_r  [true ]:=5;
               end;
MID_SSShot   : begin
                  ms_eid_death_cnt[false]:=4;
                  ms_eid_death_cnt[true ]:=4;
                  ms_eid_death_r  [false]:=8;
                  ms_eid_death_r  [true ]:=8;
               end;
      end;
   end;

   ms_eid_bio_death_uids:=[];
   for m:=0 to 255 do
     with g_uids[m] do
       if(not _ukmech)or(m in [UID_Cyberdemon,UID_Mastermind,UID_Arachnotron])then ms_eid_bio_death_uids+=[m];
end;

{$ENDIF}

function ApplyDamageMod(tu:PTUnit;dmod:byte;base_damage:integer):integer;
var i:byte;
begin
   ApplyDamageMod:=base_damage;
   if(tu<>nil)then
     for i:=0 to MaxDamageModFactors do
       with g_dmods[dmod][i] do
         if(dm_flags>0)then
           if(CheckUnitBaseFlags(tu,dm_flags))then
             case dm_factor of
                0   : ApplyDamageMod:=0;
                25  : ApplyDamageMod:=            (base_damage div 4);
                50  : ApplyDamageMod:=            (base_damage div 2);
                75  : ApplyDamageMod:=            (base_damage div 4)*3;
                100 : ;
                125 : ApplyDamageMod:=base_damage+(base_damage div 4);
                150 : ApplyDamageMod:=base_damage+(base_damage div 2);
                175 : ApplyDamageMod:=base_damage+(base_damage div 4)*3;
                200 : ApplyDamageMod:=base_damage* 2;
                300 : ApplyDamageMod:=base_damage* 3;
                500 : ApplyDamageMod:=base_damage* 5;
             else     ApplyDamageMod:=round(base_damage*100/dm_factor);
             end;
end;

// ;uVisionSource:PTUnit
procedure missile_add(mxt,myt,mvx,mvy,mtar:integer;msid,mplayer:byte;mfst,mfet,mfake:boolean;adddmg:integer;mdmod:byte);
var m,d:integer;
    tu:PTUnit;
begin
    for m:=1 to MaxUnits do
    with g_missiles[m] do
    if(vstep<=0)then
    begin
       x      := mxt;  // end point
       y      := myt;
       vx     := mvx;  // start point
       vy     := mvy;
       tar    := mtar;
       mid    := msid;
       player := mplayer;
       mfs    := mfst; // start floor
       mfe    := mfet; // end floor
       fake   := mfake;
       dmod   := mdmod;

       dtars  := 0;
       dir    := point_dir(vx,vy,x,y);
       d      := point_dist_rint(x,y,vx,vy);

       tu:=nil;
       IsUnitRange(tar,@tu);

       damage:=adddmg;
       if(player<=LastPlayer)and(tu<>nil)then
        with g_players[player] do
        begin
           if(mid=MID_URocket)and(tu^.ukfly)and(upgr[upgr_uac_airsp]>0)then mid:=MID_URocketS;
           if(not tu^.uid^._ukmech)then
            case mid of
           MID_SSShot : damage+=upgr[upgr_uac_ssgup]*BaseDamageBonus3;
           MID_SShot  : damage+=upgr[upgr_uac_ssgup]*BaseDamageBonus1;
            end;
        end;

       with g_mids[mid] do
       begin
          damage+=mid_base_damage;
          homing:=mid_homing;

          if(mid_speed>0)
          then vstep:=d div mid_speed
          else vstep:=-mid_speed;
          if(vstep<=0)then vstep:=1;

          hvstep:=vstep div 2;

          if(tu<>nil)then
          begin
             x-=sign(tu^.x-vx)*g_random(tu^.uid^._missile_r);
             y-=sign(tu^.y-vy)*g_random(tu^.uid^._missile_r);
          end;

          if(tar<=0)or(mid_base_splashr>0)
          then mtars:=MaxUnits
          else mtars:=1;

          {$IFDEF _FULLGAME}
          ms_eid_bio_death:=false;
          {$ENDIF}
       end;

       break;
    end;
end;

procedure missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
ud,rdamage: integer;
     painX: byte;
begin
   with g_missiles[m] do
   with g_mids[mid] do
    if(IsUnitRange(tar,@tu))then
     if(tu^.hits>0)and(not IsUnitRange(tu^.transport,nil))then
     begin
        if(not mid_noflycheck)and(mfs<>tu^.ukfly)then exit;
        if(tu^.uidi in mid_nodamage)then exit;

        teams  :=g_players[player].team=tu^.player^.team;

        if(teams)then
          if(mid_base_splashr<=0)
          then exit
          else
            if(not mid_teamdamage)then exit;

        ud:=point_dist_rint(vx,vy,tu^.x,tu^.y)-tu^.uid^._r-mid_size;
        if(ud<0)then ud:=0;

        rdamage:=ApplyDamageMod(tu,dmod,damage);
        painX:=1;

        if(ud<=0)and(dtars=0)then // direct target
        begin
           {$IFDEF _FULLGAME}
           ms_eid_bio_death:=tu^.uidi in ms_eid_bio_death_uids;
           {$ENDIF}

           mtars-=1;
           dtars+=1;

           if(not fake)
           then unit_damage(tu,rdamage,painX,player,false);
        end
        else
          if(mid_base_splashr>0)and(ud<mid_base_splashr)and(not tu^.uid^._splashresist)then // splash damage
          begin
             {$IFDEF _FULLGAME}
             if(ms_eid_target_eff>0)then effect_add(tu^.vx,tu^.vy,SpriteDepth(tu^.vy+1,tu^.ukfly),ms_eid_target_eff);
             {$ENDIF}

             mtars-=1;

             if(not fake)then
             begin
                rdamage:=mm3i(0,trunc(rdamage*(1-(ud/mid_base_splashr))),rdamage);
                unit_damage(tu,rdamage,painX,player,false);
             end;
          end;
     end;
end;

procedure missile_Cycle;
const  mb_s0 = fr_fps1 div 5;
       mb_s1 = fr_fps1-mb_s0;
var m,u:integer;
     tu:PTUnit;
begin
   for m:=1 to MaxMissiles do
   with g_missiles[m] do
   with g_mids[mid] do
   if(vstep>0)then
   begin
      tu:=nil;
      if(IsUnitRange(tar,@tu))then
       if(homing>mh_none)then
        if(tu^.buff[ub_teleport]>0)
        then homing:=mh_none
        else
          if(tu^.x<>tu^.vx)
          or(tu^.y<>tu^.vy)
          or(max2i(abs(tu^.x-x),abs(tu^.y-y))>tu^.uid^._missile_r)then
            case homing of
mh_magnetic : begin
                 x  +=sign(tu^.x-x)*3;
                 y  +=sign(tu^.y-y)*3;
                 mfe:=tu^.ukfly;
              end;
mh_homing   : begin
                 x  :=tu^.x;
                 y  :=tu^.y;
                 mfe:=tu^.ukfly;
              end;
            end;

      if(mid=MID_Blizzard)then
      begin
         if(vstep>mb_s1)
         then vy-=fr_fps1
         else
           if(vstep=mb_s1)then
           begin
              vx:=x;
              vy:=y-(fr_fps1*mb_s0);
           end
           else
             if(vstep<=mb_s0)then vy+=fr_fps1;
      end
      else
      begin
         vx+=(x-vx) div vstep;
         vy+=(y-vy) div vstep;
      end;

      vstep-=1;
      if(vstep<=hvstep)then mfs:=mfe;

      if(mid_ystep>0)then vy-=vstep div mid_ystep;

      if(vstep=0)then
      begin
         if(damage>0)and(mid_base_splashr>=0)then
          if IsUnitRange(tar,nil)and(mtars=1)
          then missle_damage(m)
          else
            for u:=1 to MaxUnits do
            begin
               tar:=u;
               missle_damage(m);
               if(mtars<=0)then break;
            end;

         {$IFDEF _FULLGAME}
         missile_ExplodeEffect(m);
         {$ENDIF}
      end
      {$IFDEF _FULLGAME}
      else
        if(ms_eid_fly_st>0)and(ms_eid_fly>0)then
         if((vstep mod ms_eid_fly_st)=0)then effect_add(vx,vy,SpriteDepth(vy,mfs),ms_eid_fly);
      {$ENDIF};
   end;
end;




