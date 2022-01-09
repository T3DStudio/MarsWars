{$IFDEF _FULLGAME}

procedure initMissiles;
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
MID_RevenantS: ms_smodel:=@spr_h_p4;
MID_Mancubus : ms_smodel:=@spr_h_p5;
MID_YPlasma  : ms_smodel:=@spr_h_p7;
MID_BPlasma  : ms_smodel:=@spr_u_p0;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
MID_SShot,
MID_SSShot   : ms_smodel:=@spr_u_p1;
MID_BFG      : ms_smodel:=@spr_u_p2;
MID_Tank,
MID_StunMine     : ;
MID_ArchFire : ;
MID_Flyer    : ms_smodel:=@spr_u_p3;
MID_URocket  : ms_smodel:=@spr_u_p8;
      end;

      // tracer
      case m of
MID_Granade,
MID_HRocket,
MID_URocket,
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

      // death sound and effect (common)
      case m of
MID_Mancubus,
MID_YPlasma,
MID_BPlasma,
MID_Imp,
MID_Cacodemon,
MID_Baron    : ms_snd_death[false]:=snd_pexp;
MID_StunMine : ms_snd_death[false]:=snd_electro;
MID_ArchFire,
MID_Blizzard,
MID_Mine,
MID_Tank,
MID_Granade,
MID_HRocket,
MID_Revenant,
MID_RevenantS: ms_snd_death[false]:=snd_exp;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
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
MID_URocket  : begin
                  ms_snd_death    [true ]:=snd_exp;
                  ms_eid_death_cnt[true ]:=4;
                  ms_eid_death_r  [true ]:=20;
                  ms_snd_death    [false]:=snd_exp;
                  ms_eid_death_cnt[false]:=4;
                  ms_eid_death_r  [false]:=20;
               end;
MID_Bullet,
MID_Bulletx2,
MID_TBullet,
MID_MBullet,
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

procedure _d1  (d:pinteger);begin d^:=0             end;
procedure _d25 (d:pinteger);begin d^:=d^ div 4;     end;
procedure _d50 (d:pinteger);begin d^:=d^ div 2;     end;
procedure _d75 (d:pinteger);begin d^:=d^-(d^ div 4);end;
procedure _d125(d:pinteger);begin d^:=d^+(d^ div 4);end;
procedure _d150(d:pinteger);begin d^:=d^+(d^ div 2);end;
procedure _d200(d:pinteger);begin d^:=d^*2;         end;
procedure _d225(d:pinteger);begin d^:=(d^ div 4)*9; end;


function _unit_melee_damage(pu,tu:PTUnit;damage:integer):integer;
begin
   case pu^.uidi of
   UID_LostSoul: begin
                    if(tu^.uid^._ukmech   )then _d25(@damage) else
                    if(tu^.ukfly=uf_ground)then _d50(@damage);
                 end;
   UID_Demon   : begin
                    if(tu^.uid^._ukmech)then _d50(@damage);
                 end;
   end;

   _unit_melee_damage:=damage;
end;

procedure _missile_add(mxt,myt,mvx,mvy,mtar:integer;msid,mpl:byte;mfst,mfet:boolean;adddmg:integer);
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

      d:=dist2(x,y,vx,vy);

      {$IFDEF _FULLGAME}
      ms_eid_bio_death:=false;
      {$ENDIF}

      case mid of
MID_Imp        : begin damage:=20 ; vstep:=d div 10; splashr :=0  ;       end;
MID_Cacodemon  : begin damage:=40 ; vstep:=d div 10; splashr :=0  ;       end;
MID_Baron      : begin damage:=60 ; vstep:=d div 10; splashr :=0  ;       end;
MID_RevenantS,
MID_Revenant   : begin damage:=20 ; vstep:=d div 10; splashr :=0  ;       dir:=p_dir(vx,vy,x,y);end;
MID_URocket    : begin damage:=20 ; vstep:=d div 10; splashr :=rocket_sr; dir:=p_dir(vx,vy,x,y);end;
MID_Mancubus   : begin damage:=40 ; vstep:=d div 10; splashr :=0  ;       dir:=p_dir(vx,vy,x,y);end;
MID_YPlasma    : begin damage:=15 ; vstep:=d div 15; splashr :=0  ;       end;
MID_ArchFire   : begin damage:=200; vstep:=1;        splashr :=15 ;       end;

MID_MBullet,
MID_TBullet,
MID_Bullet     : begin damage:=8  ; vstep:=1;        splashr :=0  ;       end;
MID_Bulletx2   : begin damage:=15 ; vstep:=1;        splashr :=0  ;       end;
MID_BPlasma    : begin damage:=15 ; vstep:=d div 15; splashr :=0  ;       end;
MID_BFG        : begin damage:=200; vstep:=d div 10; splashr :=125;       end;
MID_Flyer      : begin damage:=15 ; vstep:=d div 60; splashr :=0  ;       end;
MID_HRocket    : begin damage:=200; vstep:=d div 15; splashr :=rocket_sr; dir:=p_dir(vx,vy,x,y);end;
MID_Granade    : begin damage:=50 ; vstep:=d div 10; splashr :=rocket_sr; ystep:=3;end;
MID_Tank       : begin damage:=75 ; vstep:=1;        splashr :=rocket_sr; end;
MID_StunMine   : begin damage:=1  ; vstep:=1;        splashr :=100;       end;
MID_Mine       : begin damage:=300; vstep:=1;        splashr :=100;       end;
MID_Blizzard   : begin damage:=500; vstep:=fr_fps;   splashr :=blizz_r;   dir:=p_dir(vx,vy,x,y);end;
MID_SShot      : begin damage:=20 ; vstep:=1;        splashr :=0;         end;
MID_SSShot     : begin damage:=40 ; vstep:=1;        splashr :=0;         end;
      else
         vstep:=0;
         exit;
      end;

      if(vstep<=0)then vstep:=1;

      hvstep:=vstep div 2;

      if(mtars=0)then
       if(tar<=0)or(splashr>0)
       then mtars:=MaxUnits
       else mtars:=1;

      damage+=adddmg;

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

function MissileUIDCheck(mid,uid:byte):boolean;
begin
   MissileUIDCheck:=false;

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

   MissileUIDCheck:=true;
end;


procedure _missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
d,damd: integer;
     p: byte;
begin
   with _missiles[m] do
    if(_IsUnitRange(tar,@tu))then
     if(tu^.hits>0)and(MissileUIDCheck(mid,tu^.uidi))and(_IsUnitRange(tu^.inapc,nil)=false)then
      if(mfs=tu^.ukfly)then
      begin
         teams:=_players[player].team=tu^.player^.team;
         damd :=damage;

         if(teams)then
          if(splashr<=0)
          then exit
          else
            case mid of
            MID_BFG,
            MID_StunMine,
            MID_ArchFire: exit;
            end;

         d:=dist2(vx,vy,tu^.x,tu^.y)-tu^.uid^._r;
         if(splashr<=0)then d-=10;
         if(d<0)then d:=0;

         if(ServerSide)then
         begin
            if(teams)then
             if(tu^.uid^._ukbuilding)
             then damd:=damd div 4
             else damd:=damd div 2;
            p:=1;

              /////////////////////////////////

            if(tu^.uid^._uklight)then
                case mid of
                MID_Cacodemon   : _d200(@damd);
                MID_Blizzard,
                MID_BFG,
                MID_HRocket,
                MID_Mancubus,
                MID_Granade,
                MID_Tank        : _d50(@damd);
                MID_MBullet,
                MID_TBullet,
                MID_Bullet,
                MID_Bulletx2    : _d150(@damd);
                end;

            if (not tu^.uid^._uklight)
            and(not tu^.uid^._ukmech )then
                case mid of
                MID_Imp,
                MID_SShot,
                MID_SSShot      : _d200(@damd);
                end;

            if(tu^.uid^._ukmech)then
                case mid of
                MID_BPlasma,
                MID_YPlasma     : _d200(@damd);
                end;

            if(tu^.uid^._ukbuilding)then
                case mid of
                MID_Blizzard,
                MID_HRocket,
                MID_Mancubus,
                MID_Granade     : _d200(@damd);
                end;

            if(tu^.uid^._ukfly)then
                case mid of
                MID_URocket,
                MID_Revenant,
                MID_RevenantS,
                MID_Flyer       : _d200(@damd);
                end;

            case mid of
                MID_SShot       : p:=2;
                MID_SSShot      : p:=3;
            end;
         end;

         if(d<=0)and(ntars=0)then // direct and first target
         begin
            {$IFDEF _FULLGAME}
            ms_eid_bio_death:=not tu^.uid^._ukmech;
            {$ENDIF}

            if(ServerSide)then
             if(tu^.buff[ub_invuln]<=0)and(tu^.uid^._ukbuilding=false)then
             begin
                if((mid=MID_TBullet )and(not tu^.uid^._ukmech ))
                or((mid=MID_MBullet )and(    tu^.uid^._ukmech))
                or (mid=MID_StunMine)then
                begin
                   tu^.buff[ub_stun]:=fr_fps;
                   tu^.buff[ub_pain]:=fr_fps;
                end;
                {$IFDEF _FULLGAME}
                if(mid=MID_StunMine)then _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.ukfly),MID_BPlasma);
                {$ENDIF}
             end;

            mtars-=1;
            ntars+=1;

            if(ServerSide)then _unit_damage(tu,damd,p,player);
         end
         else
           if(splashr>0)and(d<splashr)then // splash damage
           begin
              {$IFDEF _FULLGAME}
              if(mid=MID_BFG)then _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.ukfly),EID_BFG);
              {$ENDIF}

              if(ServerSide)then
               if(mid=MID_StunMine)then
               begin
                  tu^.buff[ub_stun]:=fr_fps;
                  tu^.buff[ub_pain]:=fr_fps;
                  {$IFDEF _FULLGAME}
                  _effect_add(tu^.vx,tu^.vy,_depth(tu^.vy+1,tu^.ukfly),MID_BPlasma);
                  {$ENDIF}
               end;

              if(mid<>MID_BFG)then
               if(tu^.uid^._splashresist)then exit;

              mtars-=1;
              ntars+=1;

              if(ServerSide)then
              begin
                 damd:=mm3(0,trunc(damd*(1-(d/splashr))),damd);
                 _unit_damage(tu,damd,p,player);
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
   if(vstep>0)then
   begin
      if(homing)and(_IsUnitRange(tar,@tu))then
      begin
         x  :=tu^.x;
         y  :=tu^.y;
         //mfs:=tu^.ukfly;
      end;

      if(mid=MID_Blizzard)then
      begin
         if(vstep>mb_s1)
         then vy-=fr_fps
         else
           if(vstep=mb_s1)then
           begin
              vx:=x;
              vy:=y-(fr_fps*mb_s0);
           end
           else
             if(vstep<=mb_s0)then vy+=fr_fps;
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
          if((vstep mod ms_eid_fly_st)=0)then _effect_add(vx,vy,_depth(vy,mfs),ms_eid_fly);
      {$ENDIF};
   end;
end;




