{$IFDEF _FULLGAME}

procedure InitClientDataMissiles;
var m:byte;
begin
   for m:=0 to 255 do
   with g_mids[m] do
   begin
      mid_SpriteModel   :=spr_pdmodel;

      // sprite model
      case m of
MID_Imp        : mid_SpriteModel:=@spr_h_p0;
MID_Cacodemon  : mid_SpriteModel:=@spr_h_p1;
MID_Baron      : mid_SpriteModel:=@spr_h_p2;
MID_Blizzard,
MID_CyberRocket: mid_SpriteModel:=@spr_h_p3;
MID_Revenant   : mid_SpriteModel:=@spr_h_p4;
MID_Mancubus   : mid_SpriteModel:=@spr_h_p5;
MID_YPlasma    : mid_SpriteModel:=@spr_h_p7;
MID_BPlasma    : mid_SpriteModel:=@spr_u_p0;
MID_Bullet,
MID_SChaingun,
MID_Chaingun   : mid_SpriteModel:=@spr_u_p9;
MID_SShot,
MID_SSShot     : mid_SpriteModel:=@spr_u_p1s;
MID_BFG        : mid_SpriteModel:=@spr_u_p2;
MID_ArchFire   : ;
MID_Flyer      : mid_SpriteModel:=@spr_u_p3;
MID_Tank,
MID_Granade,
MID_URocketS,
MID_URocket    : mid_SpriteModel:=@spr_u_p8;
      end;

      // tracer
      case m of
MID_Granade,
MID_CyberRocket,
MID_URocketS,
MID_URocket,
MID_Revenant   : begin
                 mid_eid_FlyTrace:=MID_Bullet;
                 mid_eid_FlyStep :=4;
                 end;
MID_Blizzard   : begin
                  mid_eid_FlyTrace:=MID_Granade;
                 mid_eid_FlyStep :=1;
                 mid_eid_Decal   :=EID_db_h1;
                 end;
      end;

      // death sound and effect (common)
      case m of
MID_Mancubus,
MID_YPlasma,
MID_BPlasma,
MID_Imp,
MID_Cacodemon,
MID_Baron     : mid_snd_death[false]:=snd_explode_plasma;
MID_ArchFire,
MID_Blizzard,
MID_Tank,
MID_Granade,
MID_CyberRocket,
MID_URocket,
MID_Revenant  : mid_snd_death[false]:=snd_explode;
MID_Bullet,
MID_SChaingun,
MID_Chaingun,
MID_SShot,
MID_SSShot    : begin
                mid_snd_death    [false]:=snd_rico;
                mid_snd_DeathSkip[false]:=5;
                end;
MID_BFG       : begin
                mid_snd_death[false]:=snd_explode_bfg;
                mid_eid_target_eff  :=EID_BFG;
                end;
MID_Flyer     : mid_snd_death[false]:=snd_explode_flyer;
      end;
      mid_snd_death [true ]:=mid_snd_death[false];
      mid_eid_death [false]:=m;
      mid_eid_death [true ]:=m;
      mid_eid_DeathN[false]:=1;
      mid_eid_DeathN[true ]:=1;
      mid_eid_DeathR[false]:=0;
      mid_eid_DeathR[true ]:=0;

      // death sound and effect
      case m of
MID_URocketS  : begin
                   mid_snd_death [true ]:=snd_explode;
                   mid_eid_DeathN[true ]:=4;
                   mid_eid_DeathR[true ]:=20;
                   mid_snd_death [false]:=snd_explode;
                   mid_eid_DeathN[false]:=4;
                   mid_eid_DeathR[false]:=20;
                end;
MID_Bullet,
MID_SChaingun,
MID_Chaingun,
MID_SShot,
MID_SSShot    : begin
                   mid_snd_death    [true]:=nil;
                   mid_snd_DeathSkip[true]:=0;
                   mid_eid_death    [true]:=eid_blood;
                   mid_eid_DeathN   [true]:=0;
                end;
      end;
      case m of
MID_SShot     : begin
                   mid_eid_DeathN[false]:=2;
                   mid_eid_DeathN[true ]:=2;
                   mid_eid_DeathR[false]:=5;
                   mid_eid_DeathR[true ]:=5;
                end;
MID_SSShot    : begin
                   mid_eid_DeathN[false]:=4;
                   mid_eid_DeathN[true ]:=4;
                   mid_eid_DeathR[false]:=12;
                   mid_eid_DeathR[true ]:=12;
                end;
      end;
   end;

   missiles_UIDsBioEff:=[];
   for m:=0 to 255 do
     with g_uids[m] do
       if(not uid_ismech)or(m in [UID_Cyberdemon,UID_Mastermind,UID_Arachnotron])then missiles_UIDsBioEff+=[m];
end;

{$ENDIF}

function ApplyDamageMod(tu:PTUnit;dmod:byte;base_damage:integer):integer;
var i:byte;
begin
   ApplyDamageMod:=base_damage;
   if(tu<>nil)then
     for i:=0 to LastDamageModFactor do
      with g_DamageMods[dmod][i] do
       if(dm_TargetFlags>0)then
        if(CheckUnitBaseFlags(tu,dm_TargetFlags))then
         case dm_Factor of
       0   : ApplyDamageMod:=0;
       25  : ApplyDamageMod:=               (ApplyDamageMod div 4);
       50  : ApplyDamageMod:=               (ApplyDamageMod div 2);
       75  : ApplyDamageMod:=               (ApplyDamageMod div 4)*3;
       100 : ;
       125 : ApplyDamageMod:=ApplyDamageMod+(ApplyDamageMod div 4);
       150 : ApplyDamageMod:=ApplyDamageMod+(ApplyDamageMod div 2);
       175 : ApplyDamageMod:=ApplyDamageMod+(ApplyDamageMod div 4)*3;
       200 : ApplyDamageMod:=ApplyDamageMod* 2;
       300 : ApplyDamageMod:=ApplyDamageMod* 3;
       350 : ApplyDamageMod:=ApplyDamageMod* 3+(ApplyDamageMod div 2);
       400 : ApplyDamageMod:=ApplyDamageMod* 4;
       500 : ApplyDamageMod:=ApplyDamageMod* 5;
         else ApplyDamageMod:=round(ApplyDamageMod/100*dm_Factor);
         end;
end;

procedure missile_add(mtox,mtoy,mx,my,mtar:integer;msid,mplayer:byte;mfst,mfet,mfake:boolean;adddmg:integer;mdmod:byte;mdmgX:single=1);
var m,d:integer;
    tu:PTUnit;
begin
    for m:=0 to MaxUnits do
      with g_missiles[m] do
        if(m_vstep<=0)then
        begin
           m_tox    := mtox;  // end point
           m_toy    := mtoy;
           m_x      := mx;    // start point
           m_y      := my;
           m_tar    := mtar;
           m_mid    := msid;
           m_playeri:= mplayer;
           m_mfs    := mfst;  // start floor
           m_mfe    := mfet;  // end floor
           m_fake   := mfake;
           m_dmod   := mdmod;

           m_dtars  := 0;
           m_dir    := point_dir(m_x,m_y,m_tox,m_toy);
           d        := point_dist_rint(m_tox,m_toy,m_x,m_y);

           {if(m_mid=MID_Blizzard)and(rpls_pstate=rpls_read)then
           begin
              ui_Camera_MoveToPoint(m_tox,m_toy);
              g_status:=gs_replaypause;
              rpls_ForwardSkip:=0;
           end;}

           tu:=nil;
           IsUnitRange(m_tar,@tu);

           {$IFDEF _FULLGAME}
           if(not ServerSide)then
             if(d>base_r1h)and(tu<>nil)then exit;
           {$ENDIF}

           m_damage:=adddmg;
           if(m_playeri<=LastPlayer)and(tu<>nil)then
             with g_PlayersGame[m_playeri] do
               if(m_mid=MID_URocket)and(tu^.isfly)and(upgrs_cur[upgr_uac_AASplash]>0)then m_mid:=MID_URocketS;

           with g_mids[m_mid] do
           begin
              m_damage+=mid_base_damage;
              m_damage:=round(m_damage*mdmgX);
              m_homing:=mid_homing;

              if(mid_speed>0)
              then m_vstep:=d div mid_speed
              else m_vstep:=-mid_speed;
              if(m_vstep<=0)then m_vstep:=1;

              m_hvstep:=m_vstep div 2;

              if(tu<>nil)then
              begin
                 m_tox-=sign(tu^.x-m_x)*g_random(tu^.uid^.uid_missileR);
                 m_toy-=sign(tu^.y-m_y)*g_random(tu^.uid^.uid_missileR);
              end;

              if(m_tar<=0)or(mid_base_SplashR>0)
              then m_mtars:=MaxUnits
              else m_mtars:=1;

              {$IFDEF _FULLGAME}
              m_eid_DeathType:=false;
              {$ENDIF}
           end;

           break;
        end;
end;

procedure missle_damage(m:integer);
var tu: PTUnit;
teams : boolean;
ud,rdamage: integer;
begin
   with g_missiles[m] do
   with g_mids[m_mid] do
    if(IsUnitRange(m_tar,@tu))then
     if(tu^.hits>0)and(not IsUnitRange(tu^.transportU,nil))then
     begin
        if(not mid_noFlyCheck)and(m_mfs<>tu^.isfly)then exit;
        if(tu^.uidi in mid_ImmuneUnits)then exit;

        if(m_playeri<=LastPlayer)
        then teams:=g_PlayersGame[m_playeri].team=tu^.player^.team
        else teams:=false;

        if(teams)then
          if(mid_base_SplashR<=0)
          then exit
          else
            if(not mid_TeamDamage)then exit;

        ud:=point_dist_rint(m_x,m_y,tu^.x,tu^.y)-tu^.uid^.uid_r-mid_size;
        if(ud<0)then ud:=0;

        if(m_fake)
        then rdamage:=0
        else rdamage:=ApplyDamageMod(tu,m_dmod,m_damage);

        if(ud<=0)and((m_dtars=0)or(mid_size>0))then // direct target
        begin
           {$IFDEF _FULLGAME}
           m_eid_DeathType:=tu^.uidi in missiles_UIDsBioEff;
           {$ENDIF}

           m_mtars-=1;
           m_dtars+=1;

           unit_damage(tu,rdamage,m_playeri,false);
        end
        else
          if(mid_base_SplashR>0)and(ud<mid_base_SplashR)and(not tu^.uid^.uid_isbuilding)and(not tu^.uid^.uid_ismech)then // splash m_damage
          begin
             {$IFDEF _FULLGAME}
             if(mid_eid_target_eff>0)then effect_add(tu^.vx,tu^.vy,draw_DefaultSpriteDepth(tu^.vy+1,tu^.isfly),mid_eid_target_eff);
             {$ENDIF}

             m_mtars-=1;

             if(not m_fake)then
               rdamage:=mm3i(0,trunc(rdamage*(1-(ud/mid_base_SplashR))),rdamage);
             unit_damage(tu,rdamage,m_playeri,false);
          end;
     end;
end;

procedure missile_Cycle;
const  mb_s0 = fr_fps1 div 5;
       mb_s1 = fr_fps1-mb_s0;
var m,u:integer;
     tu:PTUnit;
begin
   for m:=0 to MaxMissiles do
   with g_missiles[m] do
   with g_mids[m_mid] do
   if(m_vstep>0)then
   begin
      tu:=nil;
      if(IsUnitRange(m_tar,@tu))then
       if(m_homing>mh_none)then
        if(tu^.buffs[ub_Teleported]>0)
        then m_homing:=mh_none
        else
          if(tu^.x<>tu^.vx)
          or(tu^.y<>tu^.vy)
          or(max2i(abs(tu^.x-m_tox),abs(tu^.y-m_toy))>tu^.uid^.uid_missileR)then
            case m_homing of
mh_magnetic : begin
                 m_tox  +=sign(tu^.x-m_tox)*3;
                 m_toy  +=sign(tu^.y-m_toy)*3;
                 m_mfe:=tu^.isfly;
              end;
mh_homing   : begin
                 m_tox  :=tu^.x;
                 m_toy  :=tu^.y;
                 m_mfe:=tu^.isfly;
              end;
            end;

      if(m_mid=MID_Blizzard)then
      begin
         if(m_vstep>mb_s1)
         then m_y-=fr_fps1
         else
           if(m_vstep=mb_s1)then
           begin
              m_x:=m_tox;
              m_y:=m_toy-(fr_fps1*mb_s0);
           end
           else
             if(m_vstep<=mb_s0)then m_y+=fr_fps1;
      end
      else
      begin
         m_x+=(m_tox-m_x) div m_vstep;
         m_y+=(m_toy-m_y) div m_vstep;
      end;

      m_vstep-=1;
      if(m_vstep<=m_hvstep)then m_mfs:=m_mfe;

      if(mid_ystep>0)then m_y-=m_vstep div mid_ystep;

      if(m_vstep=0)then
      begin
         if(m_damage>0)and(mid_base_SplashR>=0)then
          if IsUnitRange(m_tar,nil)and(m_mtars=1)
          then missle_damage(m)
          else
            for u:=1 to MaxUnits do
            begin
               m_tar:=u;
               missle_damage(m);
               if(m_mtars<=0)then break;
            end;

         {$IFDEF _FULLGAME}
         missile_explode_effect(m);
         {$ENDIF}
      end
      {$IFDEF _FULLGAME}
      else
        if(mid_eid_FlyStep>0)and(mid_eid_FlyTrace>0)then
         if((m_vstep mod mid_eid_FlyStep)=0)then
           if(ui_CheckMapPointFogVision(m_x,m_y,true))then effect_add(m_x,m_y,draw_DefaultSpriteDepth(m_y,m_mfs),mid_eid_FlyTrace);
      {$ENDIF};
   end;
end;




