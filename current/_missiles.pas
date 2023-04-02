{$IFDEF _FULLGAME}

procedure InitMissiles;
var m:byte;
begin
   FillChar(_mid_effs,SizeOf(_mid_effs),0);

   for m:=0 to 255 do
   with _mid_effs[m] do
   begin
      ms_smodel   :=spr_pdmodel;

      // sprite model
      case m of
MID_Imp      : ms_smodel:=@spr_h_p0;
MID_Cacodemon: ms_smodel:=@spr_h_p1;
MID_Baron    : ms_smodel:=@spr_h_p2;
MID_Blizzard,
MID_Granade,
MID_Mine,
MID_HRocket  : ms_smodel:=@spr_h_p3;
MID_Revenant : ms_smodel:=@spr_h_p4;
MID_Mancubus : ms_smodel:=@spr_h_p5;
MID_YPlasma  : ms_smodel:=@spr_h_p7;
MID_BPlasma  : ms_smodel:=@spr_u_p0;
MID_Bullet,
MID_Chaingun2,
MID_Chaingun : ms_smodel:=@spr_u_p1;
MID_SShot,
MID_SSShot   : ms_smodel:=@spr_u_p1s;
MID_BFG      : ms_smodel:=@spr_u_p2;
MID_ArchFire : ;
MID_Flyer    : ms_smodel:=@spr_u_p3;
MID_Tank,
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
MID_Chaingun2,
MID_SShot,
MID_SSShot   : begin
               ms_snd_death   [false]:=snd_rico;
               ms_snd_death_ch[false]:=5;
               end;
MID_BFG      : ms_snd_death[false]:=snd_bfg_exp;
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
MID_Chaingun2,
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
end;


{$ENDIF}

const
mh_none     = 0;
mh_magnetic = 1;
mh_homing   = 2;


//procedure _d25 (d:pinteger);begin d^:=d^ div 4;     end;
procedure _d50 (d:pinteger);begin d^:=d^ div 2;     end;
procedure _d150(d:pinteger);begin d^:=d^+(d^ div 2);end;
procedure _d200(d:pinteger);begin d^:=d^*2;         end;
procedure _d300(d:pinteger);begin d^:=d^*3;         end;
procedure _d500(d:pinteger);begin d^:=d^*5;         end;


function _unit_melee_damage(pu,tu:PTUnit;damage:integer):integer;
begin
   case pu^.uidi of
   UID_Phantom,
   UID_LostSoul: if(    tu^.uid^._ukmech )then _d50 (@damage);
   UID_Demon   : if(not tu^.uid^._uklight)then _d150(@damage);
   end;

   _unit_melee_damage:=damage;
end;

procedure _missile_add(mxt,myt,mvx,mvy,mtar:integer;msid,mpl:byte;mfst,mfet,mfake:boolean;adddmg:integer);
var m,d:integer;
    tu:PTUnit;
begin
   for m:=1 to MaxUnits do
   with _missiles[m] do
   if(vstep=0)then
   begin
      x      := mxt;  // end point
      y      := myt;
      vx     := mvx;  // start point
      vy     := mvy;
      tar    := mtar;
      mid    := msid;
      player := mpl;
      mfs    := mfst; // start floor
      mfe    := mfet; // end floor
      mtars  := 0;
      ntars  := 0;
      ystep  := 0;
      dir    := 270;
      homing := mh_none;
      fake   := mfake;

      d:=point_dist_rint(x,y,vx,vy);

      {$IFDEF _FULLGAME}
      ms_eid_bio_death:=false;
      {$ENDIF}
      tu:=nil;
      _IsUnitRange(tar,@tu);

      with _players[player] do
       case mid of
MID_URocketS,
MID_URocket : begin
                 if(upgr[upgr_uac_airsp]>0)then mid:=MID_URocketS;
                 if(tu<>nil)then
                  if(not tu^.ukfly)then mid:=MID_URocket;
              end;
       end;

      case mid of
MID_Imp        : begin damage:=BaseDamage1  ; vstep:=d div 15; splashr :=0  ;         end;
MID_Cacodemon  : begin damage:=BaseDamage1h ; vstep:=d div 15; splashr :=0  ;         end;
MID_Baron      : begin damage:=BaseDamage2  ; vstep:=d div 15; splashr :=0  ;         end;
MID_Revenant   : begin damage:=BaseDamage1h ; vstep:=d div 12; splashr :=0  ;         end;
MID_URocketS   : begin damage:=BaseDamage1  ; vstep:=d div 12; splashr :=rocket_sr;   end;
MID_URocket    : begin damage:=BaseDamage1  ; vstep:=d div 12; splashr :=0;           end;
MID_Mancubus   : begin damage:=BaseDamage1  ; vstep:=d div 15; splashr :=0  ;         end;
MID_YPlasma    : begin damage:=BaseDamage1  ; vstep:=d div 15; splashr :=0  ;         end;
MID_ArchFire   : begin damage:=BaseDamage8  ; vstep:=1;        splashr :=16 ;         end;

MID_Bullet     : begin damage:=BaseDamageh  ; vstep:=3;        splashr :=0  ;         end;
MID_Chaingun2,
MID_Chaingun   : begin damage:=BaseDamage1  ; vstep:=3;        splashr :=0  ;         end;
MID_BPlasma    : begin damage:=BaseDamage1  ; vstep:=d div 15; splashr :=0  ;         end;
MID_BFG        : begin damage:=BaseDamage4  ; vstep:=d div 12; splashr :=100;         end;
MID_Flyer      : begin damage:=BaseDamage1  ; vstep:=d div 20; splashr :=0  ;         end;
MID_HRocket    : begin damage:=BaseDamage5  ; vstep:=d div 15; splashr :=rocket_sr;   end;
MID_Granade    : begin damage:=BaseDamage1  ; vstep:=d div 12; splashr :=tank_sr;     ystep:=3;end;
MID_Tank       : begin damage:=BaseDamage1  ; vstep:=3;        splashr :=tank_sr;     end;
MID_Mine       : begin damage:=BaseDamage10 ; vstep:=1;        splashr :=mine_sr;     end;
MID_Blizzard   : begin damage:=BaseDamage10 ; vstep:=fr_fps1;  splashr :=blizzard_sr; end;
MID_SShot      : begin damage:=BaseDamage1  ; vstep:=3;        splashr :=0  ;         end;
MID_SSShot     : begin damage:=BaseDamage3  ; vstep:=3;        splashr :=0  ;         end;
      else
         vstep:=0;
         exit;
      end;

      dir:=point_dir(vx,vy,x,y);

      if(vstep<=0)then vstep:=1;

      hvstep:=vstep div 2;

      damage+=adddmg;
      if(player<=MaxPlayers)and(tu<>nil)then
       if(not tu^.uid^._ukmech)then
        with _players[player] do
         case mid of
         MID_SSShot        : damage+=upgr[upgr_uac_painn]*BaseDamageBonush3;
         MID_SShot         : damage+=upgr[upgr_uac_painn]*BaseDamageBonus1;
         end;

      if(mtars=0)then
       if(tar<=0)or(splashr>0)
       then mtars:=MaxUnits
       else mtars:=1;

      if(homing=mh_none)then
       case mid of
MID_Revenant,
MID_URocket,
MID_URocketS   : homing:=mh_homing;
MID_BFG        : ;
       else      homing:=mh_magnetic;
       end;


      if(tu<>nil)then
      begin
         x-=sign(tu^.x-vx)*_random(tu^.uid^._missile_r);
         y-=sign(tu^.y-vy)*_random(tu^.uid^._missile_r);
      end;

      break;
   end;
end;

function MissileUIDCheck(mid,uid:byte):boolean;
begin
   MissileUIDCheck:=false;

   case mid of
MID_Imp       : if(uid=UID_Imp        )then exit;
MID_Cacodemon : if(uid=UID_Cacodemon  )then exit;
MID_Baron     : if(uid=UID_Knight     )
                or(uid=UID_Baron      )then exit;
MID_Mancubus  : if(uid=UID_Mancubus   )then exit;
MID_YPlasma   : if(uid=UID_Arachnotron)then exit;
MID_Revenant  : if(uid=UID_Revenant   )then exit;
MID_Mine      : if(uid=UID_UMine      )then exit;
   end;

   MissileUIDCheck:=true;
end;


procedure _missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
ud,rdamage: integer;
     painX: byte;
begin
   with _missiles[m] do
    if(_IsUnitRange(tar,@tu))then
     if(tu^.hits>0)and(not _IsUnitRange(tu^.transport,nil))then
     begin
        if(mid<>MID_Blizzard)then
         if(mfs<>tu^.ukfly)or(MissileUIDCheck(mid,tu^.uidi)=false)then exit;

        teams  :=_players[player].team=tu^.player^.team;
        rdamage:=damage;

        if(teams)then
         if(splashr<=0)
         then exit
         else
           case mid of
           MID_BFG,
           MID_ArchFire: exit;
           end;

        ud:=point_dist_rint(vx,vy,tu^.x,tu^.y)-tu^.uid^._r;
        if(mid=MID_Mine)
        then ud-=25
        else
          if(splashr<=0)then ud-=12;

        if(ud<0)then ud:=0;

        /////////////////////////////////

        if(not  tu^.uid^._ukbuilding)then// units
        begin
        if (    tu^.uid^._uklight)then  // units        light
            case mid of
            MID_Chaingun2,
            MID_Baron       : _d150(@rdamage);
            end;

        if (    tu^.uid^._uklight)
        and(not tu^.uid^._ukmech )then  // units  bio   light
            case mid of
            MID_Chaingun    : _d150(@rdamage);
            end;

        if (not tu^.uid^._uklight)
        and(not tu^.uid^._ukmech )then  // units  bio   heavy
            case mid of
            MID_Imp,
            MID_SShot,
            MID_SSShot      : _d150(@rdamage);
            end;

        if (    tu^.uid^._ukmech)then   // units  mech
            case mid of
            MID_YPlasma,
            MID_Cacodemon   : _d150(@rdamage);
            MID_BPlasma     : _d150(@rdamage);
            end;

        if(mid=MID_BFG)then rdamage:=trunc(rdamage*tu^.uid^._limituse/MinUnitLimit );

        end
        else ///////////////////////////// buildings
            case mid of
            MID_Blizzard    : _d500(@rdamage);
            MID_HRocket,
            MID_Granade,
            MID_Mine,
            MID_Mancubus,
            MID_Tank        : _d300(@rdamage);
            end;

        if (    tu^.uid^._uklight)then  // light
            case mid of
            MID_HRocket,
            MID_Blizzard,
            MID_Mine        : _d50 (@rdamage);
            end;

        if (    tu^.uid^._ukmech)then   // mech
            case mid of
            MID_SSShot      : _d50 (@rdamage);
            end;

        if(     tu^.ukfly       )
        or(tu^.uidi=UID_Phantom )
        or(tu^.uidi=UID_LostSoul)then   // fly
            case mid of
            MID_Revenant,
            MID_URocketS,
            MID_URocket     : _d150(@rdamage);
            end;

        case mid of
            MID_BPlasma,
            MID_Chaingun,
            MID_Chaingun2   : painX:=2;
            MID_SSShot      : painX:=3;
        else                  painX:=1;
        end;

        if(ud<=0)and(ntars=0)then // first direct target
        begin
           {$IFDEF _FULLGAME}
           ms_eid_bio_death:=(not tu^.uid^._ukmech)or(tu^.uidi in [UID_Cyberdemon,UID_Mastermind,UID_Arachnotron]);
           {$ENDIF}

           mtars-=1;
           ntars+=1;

           if(not fake)
           then _unit_damage(tu,rdamage,painX,player,false);
        end
        else
          if(splashr>0)and(ud<splashr)and(not tu^.uid^._splashresist)then // splash damage
          begin
             {$IFDEF _FULLGAME}
             if(mid=MID_BFG)then _effect_add(tu^.vx,tu^.vy,_SpriteDepth(tu^.vy+1,tu^.ukfly),EID_BFG);
             {$ENDIF}

             mtars-=1;
             ntars+=1;

             if(not fake)then
             begin
                rdamage:=mm3(0,trunc(rdamage*(1-(ud/splashr))),rdamage);
                _unit_damage(tu,rdamage,painX,player,false);
             end;
          end;
     end;
end;

procedure _missileCycle;
const  mb_s0 = fr_fps1 div 5;
       mb_s1 = fr_fps1-mb_s0;
var m,u:integer;
     tu:PTUnit;
begin
   for m:=1 to MaxMissiles do
   with _missiles[m] do
   if(vstep>0)then
   begin
      if(_IsUnitRange(tar,@tu))then
       if(homing>mh_none)then
        if(tu^.buff[ub_teleport]>0)
        then homing:=mh_none
        else
          if(tu^.x<>tu^.vx)
          or(tu^.y<>tu^.vy)
          or(max2(abs(tu^.x-x),abs(tu^.y-y))>tu^.uid^._missile_r)then
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

      if(ystep>0)then vy-=vstep div ystep;

      if(vstep=0)then
      begin
         if(damage>0)and(splashr>=0)then
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
        with _mid_effs[mid] do
         if(ms_eid_fly_st>0)and(ms_eid_fly>0)then
          if((vstep mod ms_eid_fly_st)=0)then _effect_add(vx,vy,_SpriteDepth(vy,mfs),ms_eid_fly);
      {$ENDIF};
   end;
end;




